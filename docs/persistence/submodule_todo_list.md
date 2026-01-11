# Persistence 子模块迁移 ToDo List（persistence_core / persistence_drift / persistence_firebase）

## 0. 目标与范围

### 0.1 目标（Definition of Success）
- 把目前 `common` 内的同步能力迁移为三个可复用子模块：
  - `persistence_core`：纯 Dart，同步状态机与契约（Ports & Types）
  - `persistence_drift`：Drift/SQLite 适配（Outbox/SyncState 等 store 实现）
  - `persistence_firebase`：Firestore 适配（RemoteGateway 实现）
- `common` 不再“拥有”同步基础设施，只保留业务实体本地数据源与回填实现（LocalApplier）。
- 注入/接线（Provider/ServiceLocator）稍后进行，本文件只描述迁移任务与验收口径。

### 0.2 非目标（Out of Scope）
- 不做 Firebase 配置接入（google-services、firebase_options.dart 等）
- 不做任何 UI/页面改动
- 不做登录系统/真实 uid 的接入（只要求通路预留）

---

## 1. 当前可复用资产（迁移来源）

- 同步引擎与核心类型（现状在 common）
  - common/lib/persistence/outbox_pusher.dart（包含 SyncCoordinator、SyncStatus、Cursor、RemoteChange 等）
- Firestore 远端适配（现状在 common）
  - common/lib/persistence/firebase_remote_gateway.dart（FirestoreRemoteGateway）
- Drift 适配（现状在 common）
  - common/lib/database/daos/outbox_records_dao.dart
  - common/lib/database/daos/sync_states_dao.dart
  - common/lib/database/tables/tables.dart（OutboxRecords/SyncStates）
- 试点实体本地回填（现状在 common）
  - common/lib/datasource/layout_template_local_data_source.dart（applyRemoteChanges）
- 现有测试（可迁移/复用）
  - common/test/persistence/outbox_pusher_test.dart
  - common/test/datasource/layout_template_local_data_source_test.dart

---

## 2. 迁移总原则（必须遵守）

- Core 纯净：`persistence_core` 不依赖 `drift` / `cloud_firestore` / `flutter`
- Ports & Adapters：Core 只依赖接口（store/gateway/applier/provider）
- 单向依赖：
  - `persistence_drift` → `persistence_core`
  - `persistence_firebase` → `persistence_core`
  - `common` → 以上模块（后续注入时由 app 层组装）
- 回填不回环：RemoteApply 路径不得 enqueue outbox（必须保留并强化测试）
- 渐进迁移：保证每一步都可编译/可测，避免大爆炸式改动

---

## 3. ToDo 列表（按优先级与依赖顺序）

### P0：准备与冻结（必须先完成）
- [ ] P0.1 冻结 `persistence_core` Public API 清单
  - 输出：核心类型与 Ports 的命名/职责列表（写在本文件的“API 约定”小节或任务描述里即可）
  - 验收：后续实现都不得随意改名/改签名；若必须修改需同步更新本文件
- [ ] P0.2 依赖关系与目录规划
  - 输出：三个 package 的目录结构草案（lib/src/、test/、pubspec.yaml）
  - 验收：依赖方向满足“单向依赖”原则

### P1：建立 persistence_core（先接口后实现）
- [ ] P1.1 创建 `persistence_core` package（空实现可接受，但要能被引用）
  - 验收：`dart analyze` 通过；无 drift/firebase/flutter 依赖
- [ ] P1.2 定义核心类型（Types）
  - 包含（但不限于）：SyncError/SyncErrorCode、SyncStatus/SyncRunState、PullCursor（TimestampCursor/RevisionCursor）、RemoteChange、RemoteChangesPage、ApplyOutcome、LocalApplyResult
  - 验收：类型结构能覆盖现有 SyncCoordinator 行为；不泄露 drift/firestore 类型
- [ ] P1.3 定义 Ports（接口契约）
  - OutboxStore：
    - enqueue(operation)
    - peekBatch(scopeUid, limit)
    - markSuccess(operationId, atUtc)
    - markFailed(operationId, attempt, errorCode, errorMessage, atUtc, isDead)
    - backlogCount(scopeUid)
    - deadCount(scopeUid)
  - SyncStateStore：
    - get(scopeUid, entityType)
    - setCursorIfNewer(scopeUid, entityType, cursor, atUtc)
    - markPulledAt(scopeUid, entityType, atUtc)
    - markPushedAt(scopeUid, atUtc)
    - clear(scopeUid, entityType)
  - RemoteGateway：
    - push(operation) -> SyncError?
    - listChanges(scopeUid, entityType, sinceCursor, limit) -> RemoteChangesPage
  - LocalApplier：
    - applyRemoteChanges(scopeUid, entityType, changes) -> LocalApplyResult
  - Providers：
    - DeviceIdentityProvider（deviceId/platform/formFactor/appVersion 等）
    - AuthScopeProvider（scopeUid 获取；先定义接口，后续注入实现）
  - 验收：SyncCoordinator 可只依赖这些接口工作
- [ ] P1.4 迁移/重写 SyncCoordinator（实现保持现有语义）
  - Push：消费 Outbox → remotePush → 标记成功/失败/死信 → 更新 SyncStatus
  - Pull：根据 SyncState cursor 分页 listChanges → localApply → 成功后推进 cursor
  - 验收：
    - 通过 core 单测（fake store/gateway/applier）
    - 行为与当前 common 实现一致（状态更新、错误处理、游标推进条件）

### P2：建立 persistence_drift（实现 OutboxStore/SyncStateStore）
- [ ] P2.1 创建 `persistence_drift` package
  - 验收：能被 `persistence_core` 使用（依赖 core），不依赖 firebase
- [ ] P2.2 迁移 Drift 表结构（OutboxRecords / SyncStates）
  - 目标：把 common 的相关表迁移到 `persistence_drift`（或由 drift 包独立声明）
  - 验收：表字段/索引/主键保持一致或提供迁移策略说明
- [ ] P2.3 实现 DriftOutboxStore（适配 OutboxStore）
  - 复用逻辑：peekBatch / markSuccess / markFailed / backlogCount / deadCount
  - 验收：最小行为测试覆盖（成功、失败重试、达到 maxAttempts 标 dead）
- [ ] P2.4 实现 DriftSyncStateStore（适配 SyncStateStore）
  - 复用逻辑：timestamp cursor 的 compare + tieBreaker、revision cursor、markPulledAt/markPushedAt
  - 验收：cursor “只增不减”规则单测通过；scope 隔离有效
- [ ] P2.5 提供最小构造入口（不做注入）
  - 示例：`PersistenceDriftStores(appDb)` 暴露 outboxStore/syncStateStore
  - 验收：上层可直接 new 并传给 core

### P3：建立 persistence_firebase（实现 RemoteGateway）
- [ ] P3.1 创建 `persistence_firebase` package
  - 验收：依赖 core + cloud_firestore；不依赖 drift
- [ ] P3.2 迁移 FirestoreRemoteGateway 逻辑并对齐 core 接口
  - push：幂等（operationId）+ oplog 写入 + entity 写入/软删
  - listChanges：按 serverUpdatedAt + lastOperationId 排序分页，返回 nextCursor
  - 验收：不直接依赖 common 的 OutboxRecordRow；只接受 core 的 operation 类型
- [ ] P3.3 device 信息来源解耦
  - deviceIdentity 通过 provider 注入（不在 gateway 内部自建）
  - 验收：gateway 构造不需要 Flutter API

### P4：改造 common（只保留业务与 LocalApplier）
- [ ] P4.1 将 LayoutTemplateLocalDataSource 的回填能力对齐 core LocalApplier
  - 目标：保留 applyRemoteChanges 语义（LWW、软删、幂等、回填不入 outbox）
  - 验收：迁移/复用原有测试：applyRemoteChanges 不产生 outbox
- [ ] P4.2 业务写入的 outbox 入队解耦
  - 目标：common 的业务写入不要直接 new DAO；改为通过 OutboxStore/一个注入的 writer
  - 验收：common 不再 import drift 的 outbox dao（由 drift 包提供 store）
- [ ] P4.3 scopeUid 通路改造（先留口子，不实现登录）
  - 目标：去除“collectionId 兜底当 scopeUid”的隐式逻辑，改为由调用方显式传入 scopeUid（后续由 AuthScopeProvider 提供）
  - 验收：接口层能清晰区分 collectionId 与 scopeUid

### P5：测试迁移与门禁（确保迁移不出错）
- [ ] P5.1 core 单测：SyncCoordinator（push/pull 状态机）
  - 使用 fake stores/gateway/applier，覆盖：成功、失败重试、dead、cursor 推进/不推进条件
- [ ] P5.2 drift 单测：OutboxStore/SyncStateStore 行为
  - 覆盖：peekBatch 排序、失败标记、deadCount/backlogCount、timestamp cursor compare
- [ ] P5.3 firebase 单测：RemoteGateway（最小可测）
  - 若暂不启用 emulator：至少用 mock 方式验证 query/cursor 构造与 payload 映射（可后置）
- 验收：三个包各自 test 通过；迁移期间保持主工程可编译

### P6：清理与切换准备（不做注入，但保证“可被注入”）
- [ ] P6.1 删除/弃用 common 内旧同步实现（或短期转发导出）
  - 验收：代码库中 sync 基础设施的“唯一实现源”是三个新包
- [ ] P6.2 更新依赖引用（pubspec.yaml）
  - 根工程与 common 改为依赖新包（替换原先 common 内部实现引用）
  - 验收：全仓 `flutter pub get` 后可编译

---

## 4. API 约定（冻结区，P0.1 完成后更新）
- Core Types：待冻结
- Core Ports：待冻结
- 实体类型字符串：layout_template（保持不变）
- Cursor：timestamp + tieBreaker（lastOperationId），保持与现有 Firestore query 一致

---

## 5. 风险清单与应对
- 风险：迁移 drift 表导致数据迁移复杂
  - 应对：第一阶段先保持字段不变；如必须变更，单独列 migration 任务与脚本
- 风险：firebase 测试依赖 emulator 增加门槛
  - 应对：先以 mock/contract 测试为主，emulator 作为增强项后置
- 风险：scopeUid 与 collectionId 混用导致跨账号串数据
  - 应对：P4.3 强制显式传 scopeUid；后续注入阶段引入 AuthScopeProvider

---

## 6. 完成定义（Definition of Done）
- 三个包职责清晰且单向依赖成立
- `common` 不再承载同步基础设施实现
- 试点实体 layout_template 的：
  - 本地写入可 enqueue（通过 store）
  - remote 回填不入 outbox（测试覆盖）
- 不做任何注入也能通过单测证明核心正确性（core/drift/firebase 至少各有最小门禁）