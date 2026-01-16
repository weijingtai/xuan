import 'package:persistence_core/model/types.dart';

/// Persistence-core ports (contracts) for local-first sync.
///
/// 功能说明：
/// - 本文件定义同步引擎与具体存储/网络实现之间的接口契约（Ports）。
/// - 上层（SyncCoordinator/SyncRuntime）只依赖这些接口，不依赖具体实现（Drift/Firebase）。
///
/// 设计原则：
/// - 以 scopeUid（通常为用户 uid）作为多账号隔离的最小单位。
/// - 方法签名尽量保持最小、稳定，便于跨子项目复用。

/// Local outbox storage.
///
/// 功能说明：
/// - 存储“本地已确认写入但尚未成功同步到远端”的操作记录（[OutboxRecord]）。
/// - 提供批量取出待推送记录、以及推送成功/失败后的状态回写。
///
/// 约束：
/// - 推荐实现保证 peekBatch 的返回顺序稳定（通常按 createdAtUtc 升序）。
/// - 必须以 [scopeUid] 做隔离，避免跨账号错推。
abstract class OutboxStore {
  /// Enqueues a new outbox record.
  ///
  /// 参数说明：
  /// - [record]: 待入队的 outbox 记录。
  ///
  /// 约束：
  /// - 推荐以 operationId 作为唯一键，避免重复入队导致重复推送。
  Future<void> enqueue(OutboxRecord record);

  /// Returns a batch of outbox records for pushing.
  ///
  /// 参数说明：
  /// - [scopeUid]: 作用域 uid（通常为用户 uid）。
  /// - [limit]: 最大返回条数。
  ///
  /// 返回值：
  /// - 待推送的 outbox 记录列表（通常包含 pending/failed）。
  ///
  /// 约束：
  /// - 返回的记录应当是“可重试”的集合：pending + failed（不包含 dead/success）。
  /// - 推荐排序稳定（createdAtUtc 升序），便于重试公平与测试确定性。
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required int limit,
  });

  /// Marks one outbox record as successfully pushed.
  ///
  /// 参数说明：
  /// - [operationId]: 要标记的操作 id。
  /// - [atUtc]: 标记时间（UTC）。
  ///
  /// 约束：
  /// - 建议实现允许幂等调用（重复 success 不应报错）。
  Future<void> markSuccess({
    required String operationId,
    required DateTime atUtc,
  });

  /// Marks one outbox record as failed.
  ///
  /// 参数说明：
  /// - [operationId]: 要标记的操作 id。
  /// - [attempt]: 本次失败后的尝试次数（一般为 record.attempt + 1）。
  /// - [errorCode]: 错误分类 code（建议与 [SyncErrorCode] 对齐）。
  /// - [errorMessage]: 用于诊断的错误信息。
  /// - [atUtc]: 标记时间（UTC）。
  /// - [isDead]: 是否进入死信（达到最大尝试次数阈值）。
  ///
  /// 约束：
  /// - 当 [isDead] 为 true 时，该记录后续不应再被 [peekBatch] 返回。
  Future<void> markFailed({
    required String operationId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  });

  /// Returns count of records eligible for pushing (pending + failed).
  ///
  /// 参数说明：
  /// - [scopeUid]: 作用域 uid。
  ///
  /// 返回值：
  /// - 待推送积压数量。
  Future<int> backlogCount(String scopeUid);

  /// Watches count of records eligible for pushing (pending + failed).
  ///
  /// 用途：
  /// - 上层运行时（例如 SyncRuntime）可以订阅该 stream，在 outbox 发生变化时
  ///   触发一次 push（并配合退避定时器实现“非轮询”的重试）。
  ///
  /// 返回值：
  /// - 广播或单播 stream 均可；建议至少在订阅后尽快发出一次当前值。
  Stream<int> watchBacklogCount(String scopeUid);

  /// Returns count of dead-letter records.
  ///
  /// 参数说明：
  /// - [scopeUid]: 作用域 uid。
  ///
  /// 返回值：
  /// - dead 状态记录数量。
  Future<int> deadCount(String scopeUid);
}

/// Storage for per-scope, per-entityType pull cursors and sync markers.
///
/// 功能说明：
/// - 存储远端增量拉取游标（cursor），使 pull 支持断点续拉。
/// - 提供 pull/push 的时间戳标记（用于诊断/可观测性）。
///
/// 约束：
/// - cursor 必须按 (scopeUid, entityType) 隔离。
/// - [setCursorIfNewer] 必须避免 cursor 回退。
abstract class SyncStateStore {
  /// Gets the last stored cursor for (scopeUid, entityType).
  ///
  /// 返回值：
  /// - 若从未拉取过则返回 null。
  Future<PullCursor?> getCursor({
    required String scopeUid,
    required String entityType,
  });

  /// Sets cursor only if it is newer than the current one.
  ///
  /// 参数说明：
  /// - [cursor]: 候选 cursor。
  /// - [atUtc]: 写入时间（UTC）。
  ///
  /// 约束：
  /// - 若 cursor 类型与既有 cursor 不一致，推荐拒绝覆盖（避免混用策略）。
  Future<void> setCursorIfNewer({
    required String scopeUid,
    required String entityType,
    required PullCursor cursor,
    required DateTime atUtc,
  });

  /// Clears cursor and markers for (scopeUid, entityType).
  ///
  /// 用途：
  /// - 账号切换/数据重置/强制全量重拉时使用。
  Future<void> clear({
    required String scopeUid,
    required String entityType,
  });

  /// Records that pull succeeded for (scopeUid, entityType) at [atUtc].
  Future<void> markPulledAt({
    required String scopeUid,
    required String entityType,
    required DateTime atUtc,
  });

  /// Records that push succeeded for [scopeUid] at [atUtc].
  Future<void> markPushedAt({
    required String scopeUid,
    required DateTime atUtc,
  });
}

/// Remote read/write gateway.
///
/// 功能说明：
/// - 将 outbox 操作推送到远端（[push]）。
/// - 按游标增量拉取远端变更（[listChanges]）。
///
/// 典型实现：
/// - Firestore：push=写业务文档+写 oplog；listChanges=按 serverTime/cursor 查询 oplog。
abstract class RemoteGateway {
  /// Pushes one [OutboxRecord] to remote.
  ///
  /// 返回值：
  /// - 成功返回 null。
  /// - 失败返回 [SyncError]，用于 outbox 状态回写与诊断。
  Future<SyncError?> push(OutboxRecord record);

  /// Lists remote changes for one entity type since [sinceCursor].
  ///
  /// 参数说明：
  /// - [scopeUid]: 作用域 uid。
  /// - [entityType]: 实体类型。
  /// - [sinceCursor]: 断点续拉游标，null 表示从头开始（或服务端默认）。
  /// - [limit]: 单页最大条数。
  ///
  /// 返回值：
  /// - [RemoteChangesPage]：包含 changes、nextCursor 与 hasMore。
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  });
}

/// Applies remote changes to local storage.
///
/// 功能说明：
/// - 将 [RemoteGateway.listChanges] 返回的 [RemoteChange] 回填到本地数据库。
/// - 给出逐条处理结果（outcomes），并指示是否允许推进 cursor。
///
/// 关键约束（防回环）：
/// - 回填本地不得进入 outbox（否则会产生远端->本地->远端的回环）。
abstract class LocalApplier {
  /// Applies a batch of remote changes into local storage.
  ///
  /// 参数说明：
  /// - [scopeUid]: 作用域 uid。
  /// - [entityType]: 实体类型。
  /// - [changes]: 从远端拉取到的变更集合。
  ///
  /// 返回值：
  /// - [LocalApplyResult]：包含 appliedCount、outcomes、lastError、canAdvanceCursor。
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  });
}

/// Device identity metadata attached to operations.
///
/// 用途：
/// - 诊断同步问题（区分不同设备）。
/// - 冲突处理的平局破坏因子（例如 deviceId）。
/// - oplog 审计信息。
class DeviceIdentity {
  /// Creates a [DeviceIdentity].
  ///
  /// 参数说明：
  /// - [deviceId]: 设备唯一标识（稳定且不含敏感信息）。
  /// - [platform]: 平台标识（例如 ios/android/macos/windows/web）。
  /// - [formFactor]: 设备形态（例如 phone/tablet/desktop）。
  /// - [model]/[osVersion]/[appVersion]: 可选诊断信息。
  const DeviceIdentity({
    required this.deviceId,
    required this.platform,
    required this.formFactor,
    this.model,
    this.osVersion,
    this.appVersion,
  });

  final String deviceId;
  final String platform;
  final String formFactor;
  final String? model;
  final String? osVersion;
  final String? appVersion;
}

/// Provides [DeviceIdentity].
///
/// 典型实现：
/// - Flutter 侧通过 platform channel / package_info_plus / device_info_plus 获取。
abstract class DeviceIdentityProvider {
  /// Returns current device identity.
  Future<DeviceIdentity> get();
}

/// Provides current sync scope uid.
///
/// 用途：
/// - 将具体认证系统（FirebaseAuth/自研账号）与同步引擎解耦。
abstract class AuthScopeProvider {
  /// Returns current scope uid.
  ///
  /// 约定：
  /// - 返回值通常等同于当前登录用户的 uid。
  Future<String> getScopeUid();
}
