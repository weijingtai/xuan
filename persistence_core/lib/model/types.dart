/// Error categories produced by sync operations.
///
/// 用途：
/// - 对外稳定的错误分类，用于：outbox 状态回写、诊断统计、重试策略选择。
/// - 具体实现（Firestore/HTTP）应尽量映射到这些枚举值。
enum SyncErrorCode {
  /// Network is unavailable or request timed out.
  network,

  /// Remote denied the operation (auth/rules/permission).
  permission,

  /// Conflict detected by remote or by local conflict strategy.
  conflict,

  /// Payload/schema is invalid and cannot be applied.
  invalidData,

  /// Any other unclassified error.
  unknown,
}

/// A structured sync error.
///
/// 功能说明：
/// - 该错误用于同步引擎对外报告与 outbox 回写。
/// - 该错误应当是“可序列化到日志/诊断系统”的最小信息集合。
class SyncError {
  /// Creates a [SyncError].
  ///
  /// 参数说明：
  /// - [code]: 错误分类。
  /// - [message]: 用于诊断的错误信息（避免包含敏感数据）。
  const SyncError({
    required this.code,
    required this.message,
  });

  /// Error category.
  final SyncErrorCode code;

  /// Human-readable message for diagnostics.
  final String message;
}

/// High-level state of a sync run.
enum SyncRunState {
  /// Sync is not scheduled or has been explicitly stopped.
  stopped,

  /// Sync is idle and ready for the next run.
  idle,

  /// Sync is currently running push and/or pull.
  syncing,

  /// Last run ended with an error.
  error,
}

/// Snapshot of sync status and basic diagnostics.
///
/// 功能说明：
/// - 该类型用于向上层（例如 SyncRuntime / UI）暴露同步状态。
/// - 该类型不包含具体实现细节（不绑定 Drift/Firebase）。
///
/// 字段约定：
/// - `*AtUtc` 字段均为 UTC 时间。
/// - backlogCount/deadCount 可能为 null（例如未计算或不适用）。
class SyncStatus {
  /// Creates a [SyncStatus].
  ///
  /// 参数说明：
  /// - [state]: 同步状态。
  /// - [scopeUid]: 当前作用域 uid（通常为用户 uid）。
  /// - [backlogCount]/[deadCount]: outbox 积压与死信数量（可选）。
  /// - [lastSuccessAtUtc]: 最近一次成功（push 或 pull）完成时间。
  /// - [lastError]: 最近一次错误（若有）。
  /// - [lastPushAtUtc]/[lastPullAtUtc]: 最近一次 push/pull 完成时间（可选）。
  /// - [lastPullEntityType]/[lastPullOutcomes]: 最近一次 pull 的实体类型与结果摘要（可选）。
  const SyncStatus({
    required this.state,
    required this.scopeUid,
    required this.backlogCount,
    required this.deadCount,
    required this.lastSuccessAtUtc,
    required this.lastError,
    this.lastPushAtUtc,
    this.lastPullAtUtc,
    this.lastPullEntityType,
    this.lastPullOutcomes,
  });

  /// Current run state.
  final SyncRunState state;

  /// Current scope uid.
  final String? scopeUid;

  /// Pending+failed outbox count.
  final int? backlogCount;

  /// Dead-letter outbox count.
  final int? deadCount;

  /// Last successful run time in UTC.
  final DateTime? lastSuccessAtUtc;

  /// Last error if any.
  final SyncError? lastError;

  /// Last push completion time in UTC.
  final DateTime? lastPushAtUtc;

  /// Last pull completion time in UTC.
  final DateTime? lastPullAtUtc;

  /// Entity type of last pull.
  final String? lastPullEntityType;

  /// Outcomes of last pull (usually capped for memory).
  final List<ChangeApplyOutcome>? lastPullOutcomes;

  static const Object _unset = Object();

  /// Returns a new [SyncStatus] with selected fields overridden.
  ///
  /// 设计说明：
  /// - 为了支持把字段显式置为 null 与“保持不变”两种语义，本方法对大部分参数使用
  ///   `Object?` 哨兵值 [_unset]。
  ///
  /// 参数说明：
  /// - 对于 `Object? xxx = _unset` 的参数：
  ///   - 传 `_unset`：保持原值
  ///   - 传 `null`：将字段设置为 null
  ///   - 传具体值：覆盖为新值
  SyncStatus copyWith({
    SyncRunState? state,
    Object? scopeUid = _unset,
    Object? backlogCount = _unset,
    Object? deadCount = _unset,
    Object? lastSuccessAtUtc = _unset,
    Object? lastError = _unset,
    Object? lastPushAtUtc = _unset,
    Object? lastPullAtUtc = _unset,
    Object? lastPullEntityType = _unset,
    Object? lastPullOutcomes = _unset,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      scopeUid:
          identical(scopeUid, _unset) ? this.scopeUid : scopeUid as String?,
      backlogCount: identical(backlogCount, _unset)
          ? this.backlogCount
          : backlogCount as int?,
      deadCount:
          identical(deadCount, _unset) ? this.deadCount : deadCount as int?,
      lastSuccessAtUtc: identical(lastSuccessAtUtc, _unset)
          ? this.lastSuccessAtUtc
          : lastSuccessAtUtc as DateTime?,
      lastError: identical(lastError, _unset)
          ? this.lastError
          : lastError as SyncError?,
      lastPushAtUtc: identical(lastPushAtUtc, _unset)
          ? this.lastPushAtUtc
          : lastPushAtUtc as DateTime?,
      lastPullAtUtc: identical(lastPullAtUtc, _unset)
          ? this.lastPullAtUtc
          : lastPullAtUtc as DateTime?,
      lastPullEntityType: identical(lastPullEntityType, _unset)
          ? this.lastPullEntityType
          : lastPullEntityType as String?,
      lastPullOutcomes: identical(lastPullOutcomes, _unset)
          ? this.lastPullOutcomes
          : lastPullOutcomes as List<ChangeApplyOutcome>?,
    );
  }
}

/// Pull cursor base type.
///
/// 功能说明：
/// - 用于表达“远端增量拉取的断点”。
/// - 具体实现可选用不同 cursor 策略：时间戳、revision 等。
abstract class PullCursor {
  /// Creates a cursor.
  const PullCursor();
}

/// Cursor based on remote server update timestamp.
///
/// 约束：
/// - 当多个变更拥有相同的 serverUpdatedAtUtc 时，必须使用 [tieBreaker] 保证稳定排序。
class TimestampCursor extends PullCursor {
  /// Creates a [TimestampCursor].
  ///
  /// 参数说明：
  /// - [serverUpdatedAtUtc]: 远端 server time（UTC）。
  /// - [tieBreaker]: 平局破坏因子（建议使用 operationId）。
  const TimestampCursor({
    required this.serverUpdatedAtUtc,
    required this.tieBreaker,
  });

  /// Remote server updatedAt in UTC.
  final DateTime serverUpdatedAtUtc;

  /// Tie-breaker for stable ordering.
  final String tieBreaker;
}

/// Cursor based on monotonically increasing revision.
///
/// 约束：
/// - revision 必须单调递增，才能保证严格增量与不回退。
class RevisionCursor extends PullCursor {
  /// Creates a [RevisionCursor].
  ///
  /// 参数说明：
  /// - [revision]: 单调递增版本号。
  const RevisionCursor({required this.revision});

  /// Monotonically increasing revision.
  final int revision;
}

/// One remote change record fetched from remote.
///
/// 功能说明：
/// - 代表远端对某个实体的一次变更（upsert/softDelete 等）。
/// - [payloadJson] 由适配层定义 schema，并由本地 [LocalApplier] 解析与落库。
class RemoteChange {
  /// Creates a [RemoteChange].
  ///
  /// 参数说明：
  /// - [operationId]: 远端唯一操作 id（建议全局唯一，用于去重）。
  /// - [entityType]/[entityId]: 实体类型与实体 id。
  /// - [opType]: 操作类型字符串（例如 upsert/softDelete）。
  /// - [cursor]: 本条变更对应的增量游标。
  /// - [payloadJson]: 变更 payload（JSON 字符串）。
  /// - [serverTimeUtc]: 远端 server time（可选）。
  const RemoteChange({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.cursor,
    required this.payloadJson,
    required this.serverTimeUtc,
  });

  final String operationId;
  final String entityType;
  final String entityId;
  final String opType;
  final PullCursor cursor;
  final String payloadJson;
  final DateTime? serverTimeUtc;
}

/// One page of remote changes.
///
/// 功能说明：
/// - 由 [RemoteGateway.listChanges] 返回，用于分页拉取。
/// - 当 [hasMore] 为 true 时，上层可继续请求下一页。
class RemoteChangesPage {
  /// Creates a [RemoteChangesPage].
  ///
  /// 参数说明：
  /// - [changes]: 当前页变更集合。
  /// - [nextCursor]: 下一次请求应使用的游标（可选）。
  /// - [hasMore]: 是否还有更多数据。
  const RemoteChangesPage({
    required this.changes,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<RemoteChange> changes;
  final PullCursor? nextCursor;
  final bool hasMore;
}

/// Decision made when applying one remote change.
enum ChangeApplyDecision {
  /// Successfully applied.
  applied,

  /// Skipped intentionally (already applied, older, etc.).
  skipped,

  /// Failed to apply.
  failed,
}

/// Reason code for a skipped change.
///
/// 用途：
/// - 诊断：为什么某条变更没有被应用。
/// - 统计：冲突率、无效 payload 数等。
enum SkipReasonCode {
  /// The operationId has already been applied locally.
  alreadyApplied,

  /// Remote is older than local state.
  olderThanLocal,

  /// Conflict was resolved by LWW and remote lost.
  conflictLwwLost,

  /// Payload is invalid.
  invalidPayload,

  /// Any other reason.
  unknown,
}

/// Outcome of applying a single [RemoteChange].
///
/// 功能说明：
/// - 由 [LocalApplier] 产出，用于上层记录诊断信息。
class ChangeApplyOutcome {
  /// Creates a [ChangeApplyOutcome].
  ///
  /// 参数说明：
  /// - [operationId]: 变更操作 id。
  /// - [entityType]/[entityId]: 实体类型与实体 id。
  /// - [decision]: 应用决策。
  /// - [reason]: 如果 decision=skipped，可给出原因。
  /// - [message]: 可选诊断消息。
  const ChangeApplyOutcome({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.decision,
    required this.reason,
    required this.message,
  });

  final String operationId;
  final String entityType;
  final String entityId;
  final ChangeApplyDecision decision;
  final SkipReasonCode? reason;
  final String? message;
}

/// Result of applying a batch of remote changes.
///
/// 关键字段：
/// - [canAdvanceCursor]: 是否允许推进 cursor（必须在本地回填成功后才允许）。
/// - [lastError]: 若不为 null，表示本次回填整体失败。
class LocalApplyResult {
  /// Creates a [LocalApplyResult].
  ///
  /// 参数说明：
  /// - [canAdvanceCursor]: 是否允许推进 cursor。
  /// - [appliedCount]: 成功应用条数。
  /// - [outcomes]: 逐条决策结果。
  /// - [lastError]: 最后错误（若有）。
  const LocalApplyResult({
    required this.canAdvanceCursor,
    required this.appliedCount,
    required this.outcomes,
    required this.lastError,
  });

  final bool canAdvanceCursor;
  final int appliedCount;
  final List<ChangeApplyOutcome> outcomes;
  final SyncError? lastError;
}

/// Local outbox record.
///
/// 功能说明：
/// - 表示本地一次需要推送到远端的操作。
/// - 该记录应当具备幂等性：同一 operationId 重试多次，远端结果应一致。
///
/// 字段约定：
/// - [operationId]: 全局唯一 id（建议 uuid）。
/// - [scopeUid]: 作用域 uid（通常为用户 uid）。
/// - [entityType]/[entityId]: 实体类型与 id。
/// - [opType]: 操作类型字符串（例如 upsert/softDelete）。
/// - [payloadJson]: 业务 payload（JSON 字符串）。
/// - [attempt]: 已尝试次数（用于退避/死信阈值）。
class OutboxRecord {
  /// Creates an [OutboxRecord].
  ///
  /// 参数说明：
  /// - [createdAtUtc]: 创建时间（UTC）。
  const OutboxRecord({
    required this.operationId,
    required this.scopeUid,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.payloadJson,
    required this.createdAtUtc,
    required this.attempt,
  });

  final String operationId;
  final String scopeUid;
  final String entityType;
  final String entityId;
  final String opType;
  final String payloadJson;
  final DateTime createdAtUtc;
  final int attempt;

  /// Returns a new [OutboxRecord] with selected fields overridden.
  ///
  /// 用途：
  /// - 本地状态回写时更新 attempt 等字段。
  OutboxRecord copyWith({
    String? operationId,
    String? scopeUid,
    String? entityType,
    String? entityId,
    String? opType,
    String? payloadJson,
    DateTime? createdAtUtc,
    int? attempt,
  }) {
    return OutboxRecord(
      operationId: operationId ?? this.operationId,
      scopeUid: scopeUid ?? this.scopeUid,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      opType: opType ?? this.opType,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      attempt: attempt ?? this.attempt,
    );
  }
}

/// Summary result of one push run.
class OutboxPushRunResult {
  /// Creates an [OutboxPushRunResult].
  const OutboxPushRunResult({
    required this.processed,
    required this.succeeded,
    required this.failed,
    required this.dead,
    required this.lastError,
  });

  final int processed;
  final int succeeded;
  final int failed;
  final int dead;
  final SyncError? lastError;

  /// True when [lastError] is not null.
  bool get hasError => lastError != null;
}

/// Summary result of one pull run.
class PullRunResult {
  /// Creates a [PullRunResult].
  const PullRunResult({
    required this.pages,
    required this.fetched,
    required this.applied,
    required this.skipped,
    required this.advanced,
    required this.outcomes,
    required this.lastError,
  });

  final int pages;
  final int fetched;
  final int applied;
  final int skipped;
  final bool advanced;
  final List<ChangeApplyOutcome> outcomes;
  final SyncError? lastError;

  /// True when [lastError] is not null.
  bool get hasError => lastError != null;
}
