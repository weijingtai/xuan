
---

## 附录 B：todo_list.md（原子化、可追踪、可执行的 ToDo）

> 规则：每个 ToDo 必须具备输入契约、输出契约、验收标准、依赖；完成后在同一位置标记状态（TODO → DOING → DONE）。

### B.1 基础对齐（必须先做）
- [x] TODO-B01《字段与排序约定冻结》（先做：所有后续实现都依赖这个约定）
  - 输入契约
    - 试点实体：LayoutTemplates 或 card_templates（选其一，先保证端到端跑通）。
    - 本地：对应 Drift 表/DAO 的字段现状（是否已有 revision/updatedAt/deletedAt/schemaVersion）。
    - 远端：Firestore 文档 schema 草案（字段与类型）。
  - 输出契约（产物必须“可引用”，后续任务直接按此实现）
    - `EntityType` 命名清单：例如 `layout_template`（统一 snake_case，作为同步的主键类型名）。
    - 《字段约定表》（每个 entityType 一份，至少包含以下字段与语义）：
      - `entityId`：业务主键（远端 docId 与本地 uuid 对齐）。
      - `schemaVersion`：远端文档结构版本（int）。
      - `updatedAt`：客户端更新时间（DateTime），仅用于 UI 排序/本地展示，不作为跨端游标权威。
      - `serverUpdatedAt`：服务端更新时间（serverTimestamp），作为默认增量/全量排序权威（timestamp）。
      - `revision`（可选）：若该实体具备单调递增版本，则定义其生成与比较规则（int）。
      - `deletedAt`：软删墓碑时间（timestamp|null），必须参与变更流。
      - `operationId`：变更唯一 id（string），用于 tie-breaker 与审计/去重。
    - 《排序键约定》（必须二选一并固化到表中）
      - A. `revision asc`（首选，仅当 revision 的生成规则跨端可靠）
      - B. `serverUpdatedAt asc + operationId asc`（默认；解决同毫秒乱序）
    - 《冲突比较约定》
      - 默认 LWW：先比 revision（若存在），否则比 serverUpdatedAt；平局用 operationId（或 deviceId）破平局。
  - 顺序步骤（逐条勾选，不允许并行跳过）
    - [x] B01-1 选择试点实体与 entityType 命名（输出：1 行命名 + 远端集合路径草案）。
    - [x] B01-2 盘点本地 Drift：列出该实体本地表字段与类型（输出：字段清单）。
    - [x] B01-3 盘点远端 Firestore：列出该实体远端 doc 字段与类型（输出：字段清单）。
    - [x] B01-4 决定排序键方案（revision 或 serverUpdatedAt+operationId），写入《排序键约定》。
    - [x] B01-5 明确 deletedAt 语义（何时写入、何时清理、墓碑保留窗口建议值）。
    - [x] B01-6 形成《字段约定表》最终版（后续任务引用此表作为验收依据）。
  - 验收标准
    - 每个字段“来源/写入时机/用于比较还是用于展示”被明确。
    - 全量同步起点与分页排序键被明确（cursor 为空时从最早位置开始）。
  - 依赖：无。

  - 冻结结果（试点实体：layout_template）
    - entityType：`layout_template`
    - 远端 collection path（草案）：`users/{uid}/modules/common/layout_templates/{templateUuid}`
    - Cursor / 排序键约定：`serverUpdatedAt asc + operationId asc`（全量与增量统一；解决同毫秒乱序）
    - 冲突策略：默认 LWW（先比 revision；本实体不使用 revision，则比 serverUpdatedAt；平局用 operationId 破平局）
    - deletedAt 墓碑保留：建议 90 天（或最近 100k 条，按成本二选一），过期可由 TTL/定时清理

  - 字段约定表（layout_template）
    - 本地表（Drift：`t_layout_templates`）字段现状
      - `uuid`：模板 id（主键，对齐远端 docId）
      - `collection_id`：本地分组 id（用于筛选/展示；同步时作为 doc 字段）
      - `name`：名称
      - `description`：描述（nullable）
      - `template_json`：模板内容 JSON（string；同步时作为远端 payload 的主要内容）
      - `version`：模板版本（int；业务层语义）
      - `updated_at`：客户端更新时间（DateTime；用于 UI 排序/本地展示）
      - `deleted_at`：软删时间（DateTime|null；同步时写入远端 deletedAt）
    - 远端文档（Firestore：`users/{uid}/modules/common/layout_templates/{uuid}`）字段建议
      - `schemaVersion: int`：远端文档结构版本（默认 1；结构升级时递增）
      - `entityId: string`：冗余存储（与 docId 相同，便于排障）
      - `collectionId: string`：对应本地 `collection_id`
      - `name: string`
      - `description: string|null`
      - `template: map`：对应本地 `template_json` 解析后的对象（用于跨端回填）
      - `version: int`：对应本地 `version`
      - `clientUpdatedAt: timestamp`：对应本地 `updated_at`（客户端时间，仅用于展示/对比参考）
      - `serverUpdatedAt: timestamp`：服务端时间（serverTimestamp；作为 Pull 增量/全量的排序权威字段）
      - `deletedAt: timestamp|null`：软删墓碑（必须参与变更流）
      - `lastOperationId: string`：最近一次变更的 operationId（作为 tie-breaker 字段来源）
      - `lastDeviceId: string`：最近一次写入的 deviceId（用于排障/冲突破平局的备用信息）
    - 字段语义与写入规则（关键）
      - 本地保存（UserWrite）：写业务表成功即返回；同事务写入 OutboxRecord（含 operationId、payloadSummary/hash）。
      - 远端 push：写入实体 doc 时必须同时写入 `lastOperationId` 并使用 serverTimestamp 更新 `serverUpdatedAt`。
      - 远端 pull：按 `serverUpdatedAt + lastOperationId` 分页拉取；回填本地时写入业务表但不得进入 outbox。

- [x] TODO-B02《路径与集合命名冻结》（先做：否则 RemoteGateway 无法实现）
  - 输入契约
    - 账号体系：uid 的获取方式与生命周期（登录/退出/切号）。
    - TODO-B01 输出的 entityType 命名。
  - 输出契约
    - 《路径分层》必须全部位于 `users/{uid}/...` 下：
      - `users/{uid}/oplog/{operationId}`（审计）
      - `users/{uid}/modules/{module}/{collection}/{entityId}`（业务实体，module/collection 由子项目定义但需登记）
    - `RemotePathResolver`（命名约定，不是代码）：给定 `(uid, entityType, entityId)` 能得到唯一 doc path。
    - 《集合命名登记表》：每个 entityType 对应一个 collection path（含 module/collection 层级）。
  - 顺序步骤
    - [x] B02-1 固化 uid scope 约定：scope=uid，且所有远端读写都必须带 scope。
    - [x] B02-2 为试点实体写出 collection path（例：`users/{uid}/modules/common/layout_templates/{templateUuid}`）。
    - [x] B02-3 定义 oplog 路径与字段最小集合（引用 PRD 第 6 章）。
    - [x] B02-4 写出 Rules 草案约束：仅允许同 uid 访问；禁止全局集合；限制 oplog 可更新字段范围。
    - [x] B02-5 用 emulator 验证：跨 uid 读写被拒绝；合法路径允许。
  - 验收标准
    - 任意 entityType 都能映射到唯一远端 path。
    - Rules 可通过 emulator 验证“跨 uid 拒绝”。
  - 依赖：TODO-B01。

  - 冻结结果（路径与集合命名）
    - 试点实体 collection path：`users/{uid}/modules/common/layout_templates/{templateUuid}`
    - 审计 oplog path：`users/{uid}/oplog/{operationId}`
    - RemotePathResolver 约定（命名约定，不是代码）
      - 输入：`(uid, entityType, entityId)`
      - 输出：`entityDocPath`
      - 规则：entityType 必须先在《集合命名登记表》登记；未登记的 entityType 禁止上线接入同步
    - 《集合命名登记表》（当前仅试点）
      - `layout_template` → `users/{uid}/modules/common/layout_templates/{entityId}`

  - Firestore Rules 草案（用于后续 emulator 验证）
    - 总体规则
      - 仅允许已登录用户访问 `users/{uid}`，且 `uid == request.auth.uid`
      - 禁止任何不含 uid 的路径读写（全局集合一律拒绝）
    - oplog（`users/{uid}/oplog/{operationId}`）
      - 允许：create/read/update（仅限同 uid）
      - update 限制：禁止修改不可变字段（operationId/entityType/entityId/op/clientTime/device.deviceId 等）；仅允许更新 `result.status/attempt/errorCode/errorMessage/syncedAt`
      - 状态机限制：仅允许 `pending → success|failed → dead`（禁止 success 回退为 pending）
    - 业务实体（例：`users/{uid}/modules/common/layout_templates/{templateUuid}`）
      - 允许：create/read/update（同 uid）
      - update 限制：必须包含 `lastOperationId` 与 `serverUpdatedAt`（serverTimestamp，由 SDK 写入）；禁止跨 uid 写入

### B.2 contracts（Public API）
- [x] TODO-B03《contracts 类型与 Ports 定稿》（Public API；子项目只能依赖这一层）
  - 输入契约
    - PRD：5.1 对外 API 冻结清单、7.1～7.6（Push/Pull/全量）、4.1（Public/Internal 边界）。
    - TODO-B01 的字段/游标/排序约定。
  - 输出契约（必须明确命名、字段、用途；禁止漂移）
    - Datamodel（类型定义）
      - `AuthScope { uid }`：同步作用域。
      - `DeviceIdentity { deviceId, platform, formFactor, model?, osVersion?, appVersion? }`：审计与冲突破平局信息。
      - `Operation { operationId, entityType, entityId, op, clientTime, payloadSummary?, payloadHash? }`：一条业务写操作的抽象。
      - `Cursor`：增量/全量游标，至少支持：
        - `RevisionCursor { revision }`
        - `TimestampCursor { serverUpdatedAt, tieBreaker }`（tieBreaker 默认用 operationId）
      - `RemoteChange { scope, operationId, entityType, entityId, op, cursor, payload, serverTime? }`：远端变更流元素。
      - `SyncError { code, message }`：错误分类必须至少覆盖 network/permission/conflict/invalidData/unknown。
      - `SyncStatus { state, scope?, backlogCount?, lastSuccessAt?, lastError? }`：可观测性输出。
    - Ports（接口定义；方法名即契约）
      - `OutboxStore`
        - `enqueue(record)`：入队（必须可被同事务调用）。
        - `peekBatch(scope, limit)`：按 createdAt 排序取 pending/failed。
        - `markSuccess(operationId)` / `markFailed(operationId, attempt, error, isDead)` / `backlogCount(scope)`。
      - `SyncStateStore`
        - `getCursor(scope, entityType)` / `setCursor(scope, entityType, cursor)` / `clearCursor(scope, entityType)`。
        - `markPulledAt(scope, entityType)` / `markPushedAt(scope)`（可选但建议作为诊断字段）。
      - `RemoteGateway`
        - `push(device, outboxRecord)`：执行 Push（内部必须写 oplog + 实体写入 + oplog 更新）。
        - `listChanges(scope, entityType, sinceCursor, limit)`：增量/全量统一入口；cursor 为空表示全量 bootstrap。
      - `LocalApplier`
        - `applyRemoteChanges(scope, entityType, changes)`：回填本地（必须保证不入 outbox）。
  - 顺序步骤
    - [x] B03-1 列出 Public API 导出清单（contracts 允许 export 的文件/类型）。
    - [x] B03-2 定义上述 datamodel 的字段与空值语义（哪些必填、哪些可选、为什么）。
    - [x] B03-3 定义 Ports 的方法名、参数、返回语义（尤其是幂等与错误分类）。
    - [x] B03-4 为 Cursor 写出“推进规则”文字契约（回填成功才推进；失败不得推进）。
    - [x] B03-5 为 LocalApplier 写出“防回环”契约（RemoteApply 不得 enqueue outbox）。
    - [x] B03-6 输出最终 contracts 冻结清单（作为 SemVer 的破坏性变更判定依据）。
  - 验收标准
    - 子项目只引入 contracts 不会被迫依赖 drift/firebase。
    - 任意实现（drift/firestore/未来 REST）都能按 Ports 替换接入。
  - 依赖：TODO-B01。

  - Public API 导出清单（contracts）
    - datamodel：AuthScope / DeviceIdentity / Operation / Cursor / RemoteChange / OutboxRecord / SyncError / SyncStatus / SyncPolicy
    - ports：Clock / DeviceIdentityProvider / OutboxStore / SyncStateStore / RemoteGateway / LocalApplier
    - coordinator：SyncCoordinator（start/stop/status/trigger/resetCursor）

  - Datamodel（命名、字段、用途）
    - `AuthScope { uid: String }`
      - 作用：所有同步读写的最小作用域；任何 Store/Gateway 接口必须显式带 scope。
    - `DeviceIdentity { deviceId: String, platform: String, formFactor: String, model?: String, osVersion?: String, appVersion?: String }`
      - 作用：审计与诊断；冲突破平局的备用信息；deviceId 必须为应用内随机 UUID。
    - `OperationType`（枚举）
      - 值：`upsert` / `softDelete`
      - 作用：统一表示写操作类型。
    - `Operation { operationId: String, entityType: String, entityId: String, opType: OperationType, clientTimeUtc: DateTime, deviceIdentity: DeviceIdentity, payloadSummary?: String, payloadHash?: String }`
      - 作用：一条业务写操作的抽象；operationId 全局唯一并用于远端幂等。
    - `Cursor`（密封类型 / 联合类型）
      - `RevisionCursor { revision: int }`
      - `TimestampCursor { serverUpdatedAtUtc: DateTime, tieBreaker: String }`
      - 作用：Pull 增量/全量的推进依据；tieBreaker 默认用 operationId。
    - `RemoteChange { scope: AuthScope, operationId: String, entityType: String, entityId: String, opType: OperationType, cursor: Cursor, payloadJson: String, serverTimeUtc?: DateTime }`
      - 作用：远端变更流元素；payloadJson 为实体聚合文档或必要补丁。
    - `OutboxStatus`（枚举）
      - 值：`pending` / `failed` / `success` / `dead`
      - 作用：本地 outbox 状态机。
    - `OutboxRecord { scope: AuthScope, operation: Operation, payloadJson: String, payloadSummary?: String, payloadHash?: String, createdAtUtc: DateTime, attempt: int, status: OutboxStatus, lastError?: SyncError, lastAttemptAtUtc?: DateTime }`
      - 作用：Outbox 持久化记录；必须支持崩溃恢复重放。
    - `SyncErrorCode`（枚举）
      - 值：`network` / `permission` / `conflict` / `invalidData` / `unknown`
      - 作用：稳定的错误分类，便于诊断与策略（例如退避/死信）。
    - `SyncError { code: SyncErrorCode, message: String }`
      - 作用：跨实现统一的错误表达。
    - `SyncRunState`（枚举）
      - 值：`stopped` / `idle` / `syncing` / `error`
      - 作用：同步状态机最小可观测输出。
    - `SyncStatus { state: SyncRunState, scope?: AuthScope, backlogCount?: int, lastSuccessAtUtc?: DateTime, lastError?: SyncError }`
      - 作用：对 UI/诊断输出的最小状态；调用层不应依赖内部调度细节。
    - `SyncPolicy { enabled: bool, pushBatchSize: int, pullBatchSize: int, pollInterval: Duration, minBackoff: Duration, maxBackoff: Duration, maxAttemptsBeforeDead: int }`
      - 作用：可运维的策略开关；保持可扩展但破坏性变更需升主版本。

  - Ports（接口名、方法名、语义）
    - `Clock.nowUtc()`：提供统一时间源（便于测试）。
    - `DeviceIdentityProvider.getDeviceIdentity()`：提供设备信息（便于装配与测试替换）。
    - `OutboxStore`
      - `enqueue(record: OutboxRecord)`：必须可在业务事务内调用；失败必须导致事务回滚。
      - `peekBatch(scope: AuthScope, limit: int)`：按 createdAt 升序返回 pending/failed。
      - `backlogCount(scope: AuthScope)`：用于 SyncStatus 观测。
      - `markSuccess(operationId: String, atUtc: DateTime)`：标记成功并可清理。
      - `markFailed(operationId: String, attempt: int, error: SyncError, atUtc: DateTime, isDead: bool)`：记录失败并更新 attempt。
    - `SyncStateStore`
      - `getCursor(scope: AuthScope, entityType: String) -> Cursor?`：不存在代表全量 bootstrap。
      - `setCursor(scope: AuthScope, entityType: String, cursor: Cursor, atUtc: DateTime)`：仅在本地回填成功后调用。
      - `clearCursor(scope: AuthScope, entityType: String, atUtc: DateTime)`：用于手动重置全量对齐。
      - `markPulledAt(scope: AuthScope, entityType: String, atUtc: DateTime)`：用于诊断。
      - `markPushedAt(scope: AuthScope, atUtc: DateTime)`：用于诊断。
    - `RemoteGateway`
      - `push(device: DeviceIdentity, record: OutboxRecord) -> SyncError?`：成功返回 null；失败返回错误分类；必须幂等。
      - `listChanges(scope: AuthScope, entityType: String, sinceCursor: Cursor?, limit: int) -> (changes: List<RemoteChange>, nextCursor: Cursor?, hasMore: bool)`：分页返回；cursor 为空表示全量。
    - `LocalApplier`
      - `applyRemoteChanges(scope: AuthScope, entityType: String, changes: List<RemoteChange>) -> ApplyResult`：回填本地且不入 outbox；用于决定 cursor 是否推进。

  - Cursor 推进规则（文字契约）
    - 仅当 `applyRemoteChanges` 对该页 changes 全部“成功回填或可判定为 SkippedOlder”时，才能推进到该页的 nextCursor。
    - 任意回填失败不得推进 cursor，避免数据丢失。

  - 防回环契约（文字契约）
    - RemoteApply 路径必须与 UserWrite 路径隔离；LocalApplier 是唯一允许 RemoteApply 的入口。
    - LocalApplier 的任何写入不得触发 OutboxStore.enqueue。

### B.3 persistence_core（sync 引擎）
- [x] DONE-B04《SyncCoordinator Push 状态机》
  - 输入契约：OutboxStore 接口与错误分类。
  - 输出契约：Push 循环（批量、幂等重试、attempt、dead-letter、状态上报）。
  - 验收标准：单元测试覆盖 success/failed 重试/死信；同 operationId 重试不会造成重复副作用（通过 RemoteGateway mock 验证调用幂等）。
  - 依赖：TODO-B03。

- [x] DONE-B05《SyncCoordinator Pull 增量 + 全量 bootstrap》
  - 输入契约：SyncStateStore cursor 规则（含 cursor 为空代表全量）。
  - 输出契约：按 entityType 拉取 changes、分页与断点续拉、回填成功才推进 cursor、防回环。
  - 验收标准：单元测试覆盖：cursor 为空全量分页、中断恢复、重复 changes 幂等、回填失败不推进。
  - 依赖：TODO-B03。

- [x] DONE-B06《冲突框架与可观测性》
  - 输入契约：默认 LWW 与“可诊断”要求。
  - 输出契约：冲突检测/跳过原因码的最小实现；SyncStatus/backlog/lastError 的统一输出。
  - 验收标准：能在不抓日志情况下定位“为什么没应用某条 change”。
  - 依赖：TODO-B04、TODO-B05。

### B.4 persistence_drift（本地适配）
- [x] DONE-B07《Outbox 表 + Store 实现》
  - 输入契约：OutboxRecord 模型与状态流转。
  - 输出契约：Drift 表与 DAO；enqueue/peekBatch/markSuccess/markFailed/backlogCount。
  - 验收标准：事务原子性测试：业务写入与 outbox 入队同事务；崩溃恢复后可重放。
  - 依赖：TODO-B03。

- [x] DONE-B08《SyncState 表 + Store 实现》
  - 输入契约：Cursor（revision/timestamp + tie-breaker）。
  - 输出契约：按 scope+entityType 读写 cursor；clear/reset；lastPulledAt/lastPushedAt 更新。
  - 验收标准：单元测试覆盖 scope 隔离、cursor 幂等更新、reset 后全量 bootstrap 生效。
  - 依赖：TODO-B03。

### B.5 persistence_firestore（远端适配 + 审计）
- TODO-B09《Firestore RemoteGateway：Push + Oplog》
  - 输入契约：Firestore 集合路径与 schemaVersion；oplog 字段与 rules。
  - 输出契约：写 oplog pending → 写实体 → 更新 oplog success/failed/dead；错误分类映射。
  - 验收标准：emulator 集成测试：断网/超时重试不产生重复 oplog；跨 uid 访问被 rules 拒绝。
  - 依赖：TODO-B02、TODO-B03。

- TODO-B10《Firestore RemoteGateway：listChanges（增量 + 全量分页）》
  - 输入契约：排序键（serverUpdatedAt + operationId 或 revision）与索引。
  - 输出契约：按 cursor 分页拉取 changes，返回 nextCursor/hasMore；支持 cursor 为空全量。
  - 验收标准：emulator 集成测试：同毫秒多条变更排序稳定；中断恢复不漏不重；墓碑可被拉取。
  - 依赖：TODO-B01、TODO-B09。

### B.6 应用装配与试点实体
- TODO-B11《账号 scope 生命周期与开关策略》
  - 输入契约：登录/退出/切号流程与产品策略（是否保留本地缓存）。
  - 输出契约：stop/freeze/reset/pull-on-login 的装配逻辑；策略开关（enabled/foregroundOnly/wifiOnly 可选）。
  - 验收标准：切号不串数据；旧 scope outbox 不会被新 scope push。
  - 依赖：TODO-B04～TODO-B08。

- TODO-B12《试点实体接入与 E2E 门禁》
  - 输入契约：选定 1 个 entityType（建议 LayoutTemplates 或 card_templates）及其本地 DAO。
  - 输出契约：Repository 写本地 + enqueue outbox；读本地 watch；RemoteGateway 映射与 LocalApplier 回填。
  - 验收标准：离线写→自动 push→另一端自动 pull；Pull 回填不入 outbox；重置 cursor 可重新全量对齐。
  - 依赖：TODO-B09、TODO-B10、TODO-B11。
