
---

## 附录 B：todo_list.md（原子化、可追踪、可执行的 ToDo）

> 规则：每个 ToDo 必须具备输入契约、输出契约、验收标准、依赖；完成后在同一位置标记状态（TODO → DOING → DONE）。

w### B.1 基础对齐（必须先做）
- [ ] TODO-B01《字段与排序约定冻结》（先做：所有后续实现都依赖这个约定）
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
    - [ ] B01-1 选择试点实体与 entityType 命名（输出：1 行命名 + 远端集合路径草案）。
    - [ ] B01-2 盘点本地 Drift：列出该实体本地表字段与类型（输出：字段清单）。
    - [ ] B01-3 盘点远端 Firestore：列出该实体远端 doc 字段与类型（输出：字段清单）。
    - [ ] B01-4 决定排序键方案（revision 或 serverUpdatedAt+operationId），写入《排序键约定》。
    - [ ] B01-5 明确 deletedAt 语义（何时写入、何时清理、墓碑保留窗口建议值）。
    - [ ] B01-6 形成《字段约定表》最终版（后续任务引用此表作为验收依据）。
  - 验收标准
    - 每个字段“来源/写入时机/用于比较还是用于展示”被明确。
    - 全量同步起点与分页排序键被明确（cursor 为空时从最早位置开始）。
  - 依赖：无。

- [ ] TODO-B02《路径与集合命名冻结》（先做：否则 RemoteGateway 无法实现）
  - 输入契约
    - 账号体系：uid 的获取方式与生命周期（登录/退出/切号）。
    - TODO-B01 输出的 entityType 命名。
  - 输出契约
    - 《路径分层》必须全部位于 `users/{uid}/...` 下：
      - `users/{uid}/oplog/{operationId}`（审计）
      - `users/{uid}/{module}/{collection}/{entityId}`（业务实体，module/collection 由子项目定义但需登记）
    - `RemotePathResolver`（命名约定，不是代码）：给定 `(uid, entityType, entityId)` 能得到唯一 doc path。
    - 《集合命名登记表》：每个 entityType 对应一个 collection path（含 module/collection 层级）。
  - 顺序步骤
    - [ ] B02-1 固化 uid scope 约定：scope=uid，且所有远端读写都必须带 scope。
    - [ ] B02-2 为试点实体写出 collection path（例：`users/{uid}/common/layout_templates/{templateUuid}`）。
    - [ ] B02-3 定义 oplog 路径与字段最小集合（引用 PRD 第 6 章）。
    - [ ] B02-4 写出 Rules 草案约束：仅允许同 uid 访问；禁止全局集合；限制 oplog 可更新字段范围。
    - [ ] B02-5 用 emulator 验证：跨 uid 读写被拒绝；合法路径允许。
  - 验收标准
    - 任意 entityType 都能映射到唯一远端 path。
    - Rules 可通过 emulator 验证“跨 uid 拒绝”。
  - 依赖：TODO-B01。

### B.2 contracts（Public API）
- [ ] TODO-B03《contracts 类型与 Ports 定稿》（Public API；子项目只能依赖这一层）
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
    - [ ] B03-1 列出 Public API 导出清单（contracts 允许 export 的文件/类型）。
    - [ ] B03-2 定义上述 datamodel 的字段与空值语义（哪些必填、哪些可选、为什么）。
    - [ ] B03-3 定义 Ports 的方法名、参数、返回语义（尤其是幂等与错误分类）。
    - [ ] B03-4 为 Cursor 写出“推进规则”文字契约（回填成功才推进；失败不得推进）。
    - [ ] B03-5 为 LocalApplier 写出“防回环”契约（RemoteApply 不得 enqueue outbox）。
    - [ ] B03-6 输出最终 contracts 冻结清单（作为 SemVer 的破坏性变更判定依据）。
  - 验收标准
    - 子项目只引入 contracts 不会被迫依赖 drift/firebase。
    - 任意实现（drift/firestore/未来 REST）都能按 Ports 替换接入。
  - 依赖：TODO-B01。

### B.3 persistence_core（sync 引擎）
- TODO-B04《SyncCoordinator Push 状态机》
  - 输入契约：OutboxStore 接口与错误分类。
  - 输出契约：Push 循环（批量、幂等重试、attempt、dead-letter、状态上报）。
  - 验收标准：单元测试覆盖 success/failed 重试/死信；同 operationId 重试不会造成重复副作用（通过 RemoteGateway mock 验证调用幂等）。
  - 依赖：TODO-B03。

- TODO-B05《SyncCoordinator Pull 增量 + 全量 bootstrap》
  - 输入契约：SyncStateStore cursor 规则（含 cursor 为空代表全量）。
  - 输出契约：按 entityType 拉取 changes、分页与断点续拉、回填成功才推进 cursor、防回环。
  - 验收标准：单元测试覆盖：cursor 为空全量分页、中断恢复、重复 changes 幂等、回填失败不推进。
  - 依赖：TODO-B03。

- TODO-B06《冲突框架与可观测性》
  - 输入契约：默认 LWW 与“可诊断”要求。
  - 输出契约：冲突检测/跳过原因码的最小实现；SyncStatus/backlog/lastError 的统一输出。
  - 验收标准：能在不抓日志情况下定位“为什么没应用某条 change”。
  - 依赖：TODO-B04、TODO-B05。

### B.4 persistence_drift（本地适配）
- TODO-B07《Outbox 表 + Store 实现》
  - 输入契约：OutboxRecord 模型与状态流转。
  - 输出契约：Drift 表与 DAO；enqueue/peekBatch/markSuccess/markFailed/backlogCount。
  - 验收标准：事务原子性测试：业务写入与 outbox 入队同事务；崩溃恢复后可重放。
  - 依赖：TODO-B03。

- TODO-B08《SyncState 表 + Store 实现》
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
