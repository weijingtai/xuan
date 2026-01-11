
---

## 附录 A：tasks.md（工程化落地任务目标 / 关键点 / 难点）

> 本附录用于把 PRD 的“概念设计”转换为可落地的工程任务基线；所有子项目接入须以本清单为准，不得各自发明同步语义。

### A.1 总体任务目标（Definition of Success）
- T-Goal-1：形成 `persistence_*` 的稳定公共契约（contracts）并冻结 Public API（遵循 4.1），子项目只能依赖 Public 层。
- T-Goal-2：实现可复用同步引擎（SyncCoordinator）：Push（Outbox）+ Pull（增量 + 全量）+ 退避重试 + 死信 + 状态可观测。
- T-Goal-3：实现 Drift 适配层（OutboxStore/SyncStateStore），满足“业务写入 + outbox 入队同事务”的原子性要求。
- T-Goal-4：实现 Firestore 适配层（RemoteGateway + Oplog），满足幂等（operationId）与审计可追溯（pending/success/failed/dead）。
- T-Goal-5：选定 1 个试点实体跑通端到端：离线写→自动 push→另一端自动 pull→UI 仅靠本地 watch 刷新。
- T-Goal-6：补齐自动化测试分层与最小门禁：contracts / sync 状态机 / drift store / firestore gateway（emulator 或可替换实现）/ E2E。

### A.2 任务范围与边界（Scope / Out of Scope）
- In Scope：本 PRD 定义的同步与审计基础设施（Outbox、SyncState、SyncCoordinator、Oplog、冲突框架、全量同步 bootstrap）。
- Out of Scope：多用户协作实时合并（见 Non-Goals）、把所有业务模型迁入 persistence_*、强制各子项目共用同一物理数据库文件。

### A.3 工程关键点（必须前置对齐并固化为契约）
- Key-1：Public API 边界
  - Public：contracts 类型与 Ports（Operation/DeviceIdentity/AuthScope/Cursor/SyncStatus/错误模型/Store/Gateway/Applier 接口）+ SyncCoordinator 的生命周期与状态订阅。
  - Internal：调度策略与实现细节（批大小、退避、并发模型、统计/诊断实现）。
- Key-2：Outbox 原子性与崩溃恢复
  - 业务表写入与 outbox 入队必须同事务；崩溃恢复后 outbox 可重放且不破坏远端（幂等）。
- Key-3：幂等“边界”定义
  - 不仅 oplog docId=operationId 幂等；业务实体写入也必须可幂等重试（或具备明确的冲突拒绝语义）。
- Key-4：Pull 增量与全量的统一
  - Pull 必须支持 cursor 为空（全量 bootstrap），分页拉取、断点续拉；回填成功后推进 cursor。
- Key-5：防回环
  - RemoteApply 写本地不得进入 Outbox；必须有工程级入口隔离与测试门禁。
- Key-6：删除补漏与墓碑窗口
  - deletedAt 必须参与变更流；墓碑保留策略必须覆盖“最大离线窗口/全量窗口”，否则无法保证最终一致。
- Key-7：scope（uid）隔离
  - Outbox/SyncState 必须按 scope 隔离；账号切换要定义 stop/freeze/reset 策略，避免串数据与误 push。
- Key-8：可观测性
  - 统一 SyncStatus、backlog、最后错误分类、死信定位 operationId；必须能在不抓日志情况下定位问题。
- Key-9：Firestore 规则与索引
  - 强制 `users/{uid}/...` 路径隔离；oplog 允许的字段更新范围与状态流转必须受规则约束；常用复合索引需可验收。

### A.4 难点与风险（以及落地应对）
- Hard-1：游标/排序权威与稳定性
  - 风险：仅用 updatedAt/clientTime 会遭遇时钟漂移与同毫秒乱序。
  - 应对：为每个 entityType 固化排序键；全量/增量统一用稳定排序与 tie-breaker（例如 serverUpdatedAt + operationId）。
- Hard-2：聚合实体的 outbox payload
  - 风险：如果 outbox 只存“引用”，push 时读取到的本地状态可能已变，导致语义漂移。
  - 应对：默认 outbox 存“远端聚合快照/最小可写补丁”，并明确 schemaVersion 与 hash/summary。
- Hard-3：Pull 回填失败导致 cursor 卡死
  - 风险：单条坏数据阻塞全量推进。
  - 应对：定义 ApplyResult（transient/fatal）；fatal 进入死信并可诊断，避免无限阻塞（同时不静默丢失）。
- Hard-4：审计可信度
  - 风险：客户端直写 oplog 可能被篡改。
  - 应对：明确审计用途（排障 vs 不可抵赖）；排障场景用 rules 限制字段与状态流转；更强需求用服务器写入。
- Hard-5：资源消耗（后台/网络/批处理）
  - 风险：频繁轮询导致耗电与 Firestore 费用。
  - 应对：策略化调度（pollInterval、网络恢复触发、批大小、退避上限、仅前台/仅 Wi-Fi），并把指标暴露给运维。

### A.5 交付物（工程化最小集合）
- Deliver-1：`persistence_core`（contracts + SyncCoordinator）Public API 冻结清单与版本策略。
- Deliver-2：`persistence_drift`（Outbox/SyncState 表 + store 实现）与事务原子性测试。
- Deliver-3：`persistence_firestore`（RemoteGateway + oplog + listChanges）与 emulator/rules/索引验收说明。
- Deliver-4：`persistence_flutter`（可选装配）提供登录/退出/切号与生命周期集成样例。
- Deliver-5：试点实体 E2E 跑通与可复用 onboarding 模板。
