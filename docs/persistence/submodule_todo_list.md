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

## 3. ToDo 列表（按模块归属执行）

> 说明：`persistence_*` 三个子模块已创建完成；下面每条任务都明确“在哪个 package/目录内完成”。

### 3.1 仓库级（xuan/docs 与 xuan/ 根目录）
- [x] R0 冻结 `persistence_core` Public API 清单（Types + Ports + 对外 export）
  - 位置：/Users/jingtaiwei/Git/codex/xuan/docs/persistence/submodule_todo_list.md（本文件的“API 约定”小节）
  - 验收：后续实现不随意改名/改签名；若必须修改需同步更新本文件
- [ ] R1 规划并固定三个 package 的目录约定
  - 位置：xuan/persistence_core、xuan/persistence_drift、xuan/persistence_firebase
  - 验收：目录分层一致（建议 lib/src + lib/exports），避免把实现散落在根 lib/

### 3.2 persistence_core（在 xuan/persistence_core 内完成）
- [x] C0 把 `persistence_core` 调整为纯 Dart 包（消除 flutter 依赖）
  - 位置：xuan/persistence_core/pubspec.yaml（移除 flutter 依赖与 flutter: 配置）
  - 验收：`dart analyze` 通过；不依赖 drift/firebase/flutter
- [x] C1 定义 core Types（从 common 同步实现抽离并归一）
  - 位置：xuan/persistence_core/lib/src/
  - 包含：SyncError/SyncErrorCode、SyncStatus/SyncRunState、PullCursor（TimestampCursor/RevisionCursor）、RemoteChange、RemoteChangesPage、ChangeApplyOutcome、LocalApplyResult
  - 验收：类型不暴露 drift/firestore 类型；能覆盖现有 SyncCoordinator 行为
- [x] C2 定义 core Ports（接口契约）
  - 位置：xuan/persistence_core/lib/src/ports/
  - 包含：OutboxStore、SyncStateStore、RemoteGateway、LocalApplier、DeviceIdentityProvider、AuthScopeProvider
  - 验收：SyncCoordinator 仅依赖 Ports + Types 即可工作
- [x] C3 迁移/重写 SyncCoordinator（保持现有语义）
  - 位置：xuan/persistence_core/lib/src/sync/
  - 要求：Push（消费 outbox）+ Pull（增量拉取 + cursor 推进）+ SyncStatus 更新
  - 验收：核心逻辑不引入具体存储/网络实现
- [x] C4 core 单测（状态机门禁）
  - 位置：xuan/persistence_core/test/
  - 覆盖：push 成功/失败/死信；pull cursor 推进/不推进；apply 失败不推进 cursor

### 3.3 persistence_drift（在 xuan/persistence_drift 内完成）
- [x] D0 配置依赖：依赖 persistence_core + drift
  - 位置：xuan/persistence_drift/pubspec.yaml
  - 验收：不依赖 firebase
- [x] D1 迁移 Drift 表结构（Outbox/SyncState）
  - 来源：common/lib/database/tables/tables.dart（OutboxRecords/SyncStates）
  - 位置：xuan/persistence_drift/lib/src/database/
  - 验收：字段/主键/索引语义保持一致（或提供迁移说明）
- [x] D2 实现 OutboxStore（DriftOutboxStore）
  - 来源：common/lib/database/daos/outbox_records_dao.dart
  - 位置：xuan/persistence_drift/lib/src/stores/
  - 验收：peekBatch 排序、markSuccess/markFailed、dead/backlog 统计行为与现状一致
- [x] D3 实现 SyncStateStore（DriftSyncStateStore）
  - 来源：common/lib/database/daos/sync_states_dao.dart
  - 位置：xuan/persistence_drift/lib/src/stores/
  - 验收：timestamp cursor compare + tieBreaker；revision cursor；scope 隔离
- [x] D4 drift 单测（store 行为门禁）
  - 位置：xuan/persistence_drift/test/
  - 覆盖：cursor 只增不减、scope 隔离、dead 标记与统计

### 3.4 persistence_firebase（在 xuan/persistence_firebase 内完成）
- [x] F0 配置依赖：依赖 persistence_core + cloud_firestore
  - 位置：xuan/persistence_firebase/pubspec.yaml
  - 验收：不依赖 drift
- [x] F1 迁移并实现 RemoteGateway（FirestoreRemoteGateway）
  - 来源：common/lib/persistence/firebase_remote_gateway.dart
  - 位置：xuan/persistence_firebase/lib/src/
  - 要求：push 幂等（operationId）+ oplog + entity upsert/softDelete；listChanges 基于 serverUpdatedAt + lastOperationId 分页
  - 验收：只接受 core 的 operation/change 类型；不依赖 common 的 OutboxRecordRow
- [x] F2 device 信息来源解耦
  - 位置：xuan/persistence_firebase/lib/src/
  - 要求：deviceIdentity 来自 core 的 DeviceIdentityProvider（不在 gateway 内部自建）
  - 验收：gateway 构造不需要 Flutter API
- [ ] F3 firebase 单测（最小门禁）
  - 位置：xuan/persistence_firebase/test/
  - 备注：若暂不启用 emulator，至少做 contract/mock 测试验证 query/cursor 与 payload 映射

### 3.5 common（在 xuan/common 内完成）
- [x] M0 试点实体回填对齐 core LocalApplier
  - 位置：xuan/common/lib/datasource/layout_template_local_data_source.dart
  - 要求：applyRemoteChanges 的输入/输出类型改为依赖 persistence_core（不依赖 common 内同步实现文件）
  - 验收：保留 LWW、软删、幂等；回填不入 outbox（复用既有测试）
- [x] M1 写入路径 outbox 入队解耦
  - 位置：xuan/common/lib/datasource/layout_template_local_data_source.dart、xuan/common/lib/repositories/layout_template_repository_impl.dart
  - 要求：业务写入不再直接 new drift DAO；改为通过 OutboxStore（后续由注入提供）
  - 验收：common 不再 import persistence_drift 的内部 DAO；只依赖 persistence_core 的 OutboxStore 接口
- [x] M2 scopeUid 与 collectionId 明确分离
  - 位置：涉及 enqueue 的函数签名与调用方
  - 要求：去除“collectionId 兜底当 scopeUid”的隐式逻辑；scopeUid 必须显式传入（后续由 AuthScopeProvider 提供）
  - 验收：接口层可清晰区分 collectionId 与 scopeUid

### 3.6 仓库根切换（在 xuan/ 根目录完成）
- [x] R2 更新依赖引用（pubspec.yaml）
  - 位置：xuan/pubspec.yaml、xuan/common/pubspec.yaml
  - 要求：让 xuan/common 依赖新包（persistence_core/drift/firebase），逐步移除对 common/lib/persistence/* 的依赖
  - 验收：全仓 `flutter pub get` 后可编译
- [x] R3 清理/弃用 common 内旧同步实现
  - 位置：xuan/common/lib/persistence/
  - 要求：实现源迁移后删除或转发导出（短期兼容）
  - 验收：sync 基础设施“唯一实现源”为三个新包
- [ ] R4 分包测试门禁
  - 位置：各 package 的 test/
  - 验收：persistence_core / persistence_drift / persistence_firebase 各自测试通过；迁移期间主工程可编译

---

## 4. API 约定（冻结区，P0.1 完成后更新）

- persistence_core exports（对外导出，冻结）
  - `package:persistence_core/persistence_core.dart`
    - `src/ports.dart`
    - `src/types.dart`
    - `src/sync_coordinator.dart`

- Core Types（冻结）
  - SyncErrorCode / SyncError
  - SyncRunState / SyncStatus
  - PullCursor / TimestampCursor / RevisionCursor
  - RemoteChange / RemoteChangesPage
  - ChangeApplyDecision / SkipReasonCode / ChangeApplyOutcome
  - LocalApplyResult
  - OutboxRecord
  - OutboxPushRunResult
  - PullRunResult

- Core Ports（冻结）
  - OutboxStore
  - SyncStateStore
  - RemoteGateway
  - LocalApplier
  - DeviceIdentity / DeviceIdentityProvider
  - AuthScopeProvider

- Core Sync（冻结）
  - OutboxPusher
  - SyncCoordinator

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