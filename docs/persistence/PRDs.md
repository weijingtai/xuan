# PRDs - persistence_*（Local-first + Drift/SQLite + Firebase/Firestore + 无感知同步 + 全量审计）

## 1. 背景与问题

当前 xuan 项目由多个子项目（common/daliuren/qizhengsiyu/…）组成。各子项目均采用：
- Local：Drift/SQLite（本地关系型存储）
- KV：SharedPreferences（轻量偏好/运行期配置）
- Remote：Firebase 文档数据库（用于跨端访问数据）

现状特征：
- 每个子项目有独立的本地数据库与 SharedPreferences key 前缀隔离
- common 提供共享模型与部分共享的本地存储能力
- 远端已采用 Firebase 文档数据库，但各模块数据层设计不统一

现状痛点：
- 缺少统一的“同步基础设施”：重试、幂等、冲突、增量拉取、设备来源记录等能力容易在各子项目重复实现
- 调用层若显式感知同步，会导致业务复杂、难测试、难替换远端/本地技术
- 需要“全量操作日志（审计）”：必须能追溯每一次写操作来自哪个终端、写了什么、是否成功、失败原因等

本 PRD 描述将同步与审计抽象为 `persistence_*` 系列模块（packages/submodules），用于统一承载数据同步与审计能力，并为各子项目提供一致的接入方式。

---

## 2. 目标（Goals）

- G1：调用层无感知同步  
  调用层（UI/UseCase）仅依赖 Repository 的业务接口（get/watch/save/delete），不出现 drift/firestore/sync 语义与类型。

- G2：Local-first 写入链路  
  写操作：先落本地成功即返回；断网可写；联网后自动同步到远端。

- G3：跨端一致性（同账号多端）  
  同一 uid 在不同平台/设备写入后，其他端通过 Pull 回填到本地并自动刷新 UI。

- G4：全量操作日志（审计）  
  每一次写操作生成唯一 operationId，并在远端形成 oplog 记录，包含 device 信息、时间戳、目标实体、操作类型、结果与错误。

- G5：可替换性（技术解耦）  
  支持未来替换本地实现（Drift→其他）或远端实现（Firestore→REST/GraphQL/…）而不影响 Domain/UseCase/调用层。

- G6：可观测与可运维  
  提供 SyncStatus、积压量、失败类型、死信等诊断能力；支持开关策略（停用同步/仅 Wi-Fi/仅前台）。

---

## 3. 非目标（Non-Goals）

- 不在本阶段实现多用户协作编辑（多用户实时冲突合并可作为后续增强）
- 不强制所有子项目共享同一份“物理本地数据库文件”（多 app 沙盒隔离下不可行）
- 不把所有业务模型放入 persistence_*；persistence_* 只承载基础设施与契约

---

## 4. 核心原则与设计约束

- P1：Ports & Adapters（六边形架构）  
  Domain 只依赖 Repository 接口；Data 层通过 Local/Remote/Sync 适配器对 Drift/Firestore 解耦。

- P2：Outbox Pattern（本地变更队列）  
  本地业务写入与 outbox 入队必须在同一事务内完成，保证离线、重试与崩溃恢复的正确性。

- P3：Pull 回填不回环  
  远端 Pull 回填写入本地不得再次进入 Outbox（防回环同步）。

- P4：幂等性（operationId 一致）  
  同一 operationId 的重试不得造成远端重复副作用；oplog docId 使用 operationId，天然幂等。

- P5：审计与同步同源  
  “一条业务写操作 = 一条 operationId = 一条 oplog 记录”，便于追溯与排障。

- P6：隐私与合规  
  deviceId 使用应用内生成并持久化的随机 UUID，不使用硬件唯一标识（IMEI/序列号/广告 ID）。审计日志不记录敏感业务字段，优先存摘要与 hash。

### 4.1 公共 API 稳定性与演进
- 目标：让子项目只依赖稳定层，避免“偷用内部实现”导致后续无法演进。
- 约定：persistence_* 的对外 API 分为 Public（稳定）与 Internal（可变），并在包内用目录与导出文件控制。
- Public（稳定）：contracts 中的类型与 Ports（Operation/DeviceIdentity/Cursor/SyncStatus/错误模型/Store 与 Gateway 接口），以及 SyncCoordinator 的启动/停止与状态订阅等最小能力。
- Internal（可变）：同步调度细节（退避算法、批大小策略）、远端写入顺序优化、诊断/统计实现、性能优化策略。
- 破坏性变更：必须提升主版本并提供迁移指引；子项目不得直接 import internal 路径。

---

## 5. 模块拆分（persistence_*）

### 5.1 persistence_core（契约 + 同步引擎）
职责：
- 契约层（contracts）：定义跨模块通用类型与接口（Ports），定义同步与审计通用模型（SyncStatus/SyncError/Cursor/Change/ConflictPolicy/Operation），定义 DeviceIdentity 与 AuthScope（uid）等可注入能力
- 同步引擎层（sync）：实现 SyncCoordinator 状态机：Push（消费 Outbox）、Pull（增量拉取回填）、退避重试、死信；提供冲突处理框架（默认 LWW：revision/updatedAt + deviceId 破平局），支持按实体类型配置；提供可观测性（状态流、积压统计、错误分类）

约束：
- 包内强制分层：sync 只依赖 contracts（建议以目录与依赖规约保持单向）
- 纯 Dart 优先：不依赖 Drift、不依赖 Firebase；可选最小化 Flutter 依赖（若需要提供基础的 platform/formFactor 类型定义）

输出（示例概念）：
- `DeviceIdentity { deviceId, platform, formFactor, model?, osVersion?, appVersion? }`
- `Operation { operationId, entityType, entityId, op, clientTime, deviceIdentity, payloadSummary?, payloadHash? }`
- `SyncStatus { state, lastSuccessAt?, lastError? }`
- `Cursor`（支持 timestamp 或 revision，未来可扩展复合游标）
- `SyncCoordinator`（以注入 Store/Gateway/Applier 的方式实现可替换性）

对外 API（建议冻结清单）：
- contracts：Operation/DeviceIdentity/AuthScope/Cursor/SyncStatus/SyncError（及错误分类枚举）、OutboxStore/SyncStateStore/RemoteGateway/LocalApplier 的接口定义
- sync：SyncCoordinator 的生命周期与状态订阅接口（start/stop、status stream/notifier、手动触发一次 pull/push 的可选入口）

内部 API（建议禁止被子项目直接依赖）：
- 同步调度实现（批大小/退避/并发模型）、内部事件总线、统计采集实现、调试面板实现

### 5.3 persistence_drift（本地适配层）
职责：
- Drift 实现的 OutboxStore 与 SyncStateStore（表 + DAO + 批处理查询）
- 提供 Drift 事务模板、软删除约定辅助（可选）

依赖：
- drift/drift_flutter
- persistence_core
- 不依赖 Firebase

### 5.4 persistence_firestore（远端适配层）
职责：
- Firestore RemoteGateway：upsert/softDelete、按 cursor 增量拉取 changes、批写与幂等
- Oplog 写入与更新（pending/success/failed/dead）
- 远端 schemaVersion 演进策略与字段约定

依赖：
- cloud_firestore、firebase_auth（以及项目实际使用的 firebase 包）
- persistence_core
- 不依赖 Drift

### 5.5 persistence_flutter（可选，装配与生命周期层）
职责：
- 与 Provider/应用生命周期集成：启动/暂停、网络恢复、登录切换 scope
- 提供 DeviceIdentityProvider 的 Flutter 实现（读取平台、屏幕、版本信息）
- 暴露 SyncStatus notifier 给 UI（可选，非业务必需）

依赖：
- Flutter / Provider
- persistence_core + 具体实现模块

---

## 6. 远端审计（全量操作日志 oplog）

### 6.1 Firestore 结构（建议）
- `users/{uid}/oplog/{operationId}`

字段建议（最小集合）：
- operationId（docId）
- entityType / entityId / op
- clientTime / serverTime（serverTimestamp）
- device（deviceId/platform/formFactor/model/osVersion/appVersion）
- payload（schemaVersion/summary/hash）
- result（status: pending|success|failed|dead, attempt, errorCode?, errorMessage?, syncedAt）

查询与索引（建议维度）：
- serverTime desc（按时间）
- entityType + entityId + serverTime desc（按实体追溯）
- result.status + serverTime desc（排查失败与死信）

索引策略（落地要求）：
- 必须为常用查询建立复合索引（Firestore 会在首次查询时报错提示需要的 index）：
  - (entityType, entityId, serverTime desc)
  - (result.status, serverTime desc)
- 以 operationId 作为 docId，不需要额外索引即可按 operationId 精确定位。

保留与清理策略（落地要求）：
- 默认保留最近 N 天（建议 30/90 天二选一）或最近 N 条（建议 10k/100k 二选一），超过阈值通过 TTL 或定期清理任务删除。
- 必须支持按 entityType 细分保留策略（关键实体更久、非关键更短）。

payload 裁剪策略（落地要求）：
- 默认禁止存完整业务 JSON（除非明确需要事件溯源重放），只允许存：schemaVersion + summary + hash。
- summary 推荐包含：变更字段列表/子项数量/版本号；禁止包含敏感字段（如精确定位、个人身份信息）。

Firestore Rules 验收清单（必须）：
- 只允许已登录用户访问 `users/{uid}` 下资源，且 uid 必须等于 request.auth.uid。
- oplog 只允许对 `users/{uid}/oplog/{operationId}` 的 create/update/read，禁止跨 uid。
- 禁止任何全局集合读写（不含 uid 的路径一律拒绝）。

---

## 7. 同步语义与一致性

### 7.1 Push（本地→远端）
- 输入：Outbox pending 操作 batch
- 流程（推荐顺序）：
  1) Upsert oplog：status=pending（幂等）
  2) 写业务实体文档（幂等/版本检查）
  3) 更新 oplog：status=success + syncedAt
  4) 标记 outbox 成功，可清理
- 失败处理：
  - 记录 oplog failed（attempt/错误码），outbox 保留待重试
  - 达到阈值进入 dead-letter（dead）

### 7.2 Pull（远端→本地）
- 输入：sync_state cursor（每 entityType / 每 scope）
- 输出：变更集合（upsert/softDelete）回填本地
- 关键规则：回填写本地不得入 outbox（防回环）
- cursor 推进：仅在本地回填成功后推进

### 7.3 冲突策略（默认）
- 优先比较 revision；若无 revision 则比较 updatedAt；平局用 deviceId 破平局。
- 冲突不可静默丢数据：至少要能检测并在诊断中呈现（未来可扩展冲突副本策略）。

### 7.4 Cursor / Revision 选择与排序规则（落地要求）
- 每个 entityType 必须选择一种增量游标：revision 或 updatedAt。
- 优先使用 revision（单调递增，便于严格增量）；没有 revision 的实体才使用 updatedAt。
- 当使用 updatedAt 时，必须定义稳定排序的平局破坏因子（建议：updatedAt + operationId 或 updatedAt + deviceId）。
- cursor 推进必须在本地回填成功后执行，失败不得推进，避免数据丢失。

### 7.5 回填不入 Outbox 的实现约束（落地要求）
- 本地写入必须区分来源：UserWrite 与 RemoteApply。
- RemoteApply 路径只能通过专用入口（例如 LocalApplier.applyRemoteChange），并显式禁止 enqueue outbox。
- 任意子项目接入新实体时，必须包含“回填不回环”的单元测试与集成用例。

### 7.6 全量同步（Full Sync / Bootstrap）

定义：
- 全量同步指某个 scope（uid）在某端首次启用同步时，将远端某些 entityType 的当前完整集合回填到本地，使本地进入“可增量维护”的初始一致状态。
- 全量同步不是一个独立协议：它是 Pull 的一种特殊形态，当 cursor 不存在/被重置时，从“最早位置”开始分页拉取直到追平。

触发条件（落地要求）：
- 首次登录（该 scope 在本端不存在 sync_state）。
- 明确执行“重置同步状态”（cursor 损坏、诊断需要、或产品提供的手动修复入口）。
- schemaVersion 发生需要重建本地聚合快照的变更时（可选，按实体类型配置）。

语义（落地要求）：
- Pull 必须支持 cursor 为空：`listChanges(sinceCursor: null)` 代表从该 entityType 的最早变更开始扫描。
- 全量同步必须分页：每次拉取固定上限 `limit`，并返回 `nextCursor` 或等价的“最后一条变更的 cursor”，用于断点续拉。
- cursor 推进规则不变：仅在本地回填成功后推进；若某页回填失败，不得推进该页的 cursor，避免丢数据。

实现建议（Firestore，落地要求）：
- 对每个 entityType 使用稳定排序键做分页：优先 `serverUpdatedAt asc, operationId asc`；如果实体选择 revision，则使用 `revision asc` 并定义平局破坏因子。
- 远端变化流的返回必须包含用于排序与推进的字段（serverUpdatedAt/revision 与 operationId）。
- 为避免“仅看变更流但漏删”，全量同步期间必须能拉到删除墓碑：deletedAt 必须参与 change 流，且墓碑保留窗口必须覆盖最大离线/全量窗口。

性能与体验（落地要求）：
- 全量同步过程中调用层仍只读本地；UI 是否提示“首次同步中”由产品决定，但必须能从 SyncStatus 观测到 `state=syncing` 与进度（至少：已拉取条数/预计未知也可）。
- 全量同步应支持中断与恢复：应用退出/切后台后，重启可从 sync_state 的 cursor 继续，不重复处理已成功回填的页面。

重置与纠偏（落地要求）：
- 必须提供可控的“重置某 scope 的某些 entityType 的 sync_state cursor”的能力。
- 重置后不得自动清空业务本地表，除非产品明确要求；默认策略是重新全量 pull 并通过 LocalApplier 以幂等 upsert/softDelete 方式收敛到远端状态。

验收用例（必须）：
- 新设备首次登录：能从 cursor 为空开始拉取，最终本地与远端在选定实体集合上对齐（至少满足：远端有的本地都有；远端删的本地被软删）。
- 全量过程中中断（杀进程/断网）后恢复：不丢数据、不无限重复，最终能追平并进入增量模式。
- 手动重置 cursor 后：能够重新全量对齐，且 pull 回填不入 outbox。

---

## 8. 面向子项目的开发指南（如何接入与扩展）

### 8.1 新增一个可同步实体（Entity Onboarding）
以 “card_templates” 为例的开发步骤（其他实体同理）：

1) 明确聚合边界（推荐聚合文档）
- card_templates 在本地可能分散为多表（settings/meta/skill_usage 等）。
- 远端建议以“聚合文档”形式存储（单 doc），降低同步复杂度：
  - `users/{uid}/common/card_templates/{templateUuid}`

2) Local 侧：实现 LocalApplier/LocalDataSource
- 提供本地写入接口：upsert/softDelete（内部使用现有 DAO + transaction）
- 提供本地读取聚合快照能力（供 push 组装远端文档）

3) Remote 侧：实现 RemoteGateway/RemoteDataSource
- 定义 doc schema（含 schemaVersion/revision/updatedAt/deletedAt）
- 实现：
  - upsert(doc)
  - softDelete(docId)
  - listChanges(sinceCursor)

4) 注册同步配置（persistence_core）
- entityType：如 `card_template`
- cursor：revision 或 updatedAt
- conflictPolicy：默认 LWW 或实体自定义
- serializer：payload summary/hash 生成策略（用于 oplog）

5) Repository 组合（对调用层无感知）
- save/delete：本地事务写业务表 + outbox enqueue（同事务）
- get/watch：只读本地（watch Drift），pull 回填自动刷新 UI
- 调用层无需任何 sync API

6) 配置注入（应用启动）
- 注入本地 store（drift）、远端 gateway（firestore）、sync coordinator、device identity provider
- 启动 coordinator：push loop + pull schedule

验收用例（必须）：
- 断网保存 → 本地立即可见 → 联网后自动同步 → 另一端可见
- 另一端修改 → 本端无需手动刷新 → 自动回填本地并刷新 UI
- 失败重试：远端写失败时 outbox 不丢；oplog 记录 failed；恢复后变 success
- 幂等：同 operationId 重试不会产生重复 oplog/重复实体副作用

### 8.2 迁移策略（本地与远端）
- 本地 Drift：
  - schemaVersion 增量迁移
  - outbox/sync_state 表作为基础设施，优先保持向后兼容
- 远端 Firestore：
  - schemaVersion 字段强制存在
  - 新字段向后兼容：旧端忽略，新端提供默认值
  - 如需结构性变更，优先新增字段并灰度迁移，再清理旧字段

### 8.3 设备信息与 deviceId 规范
- deviceId：首次启动生成 UUID，SharedPreferences 持久化
- device 详情（model/os/appVersion）：
  - 建议引入 device_info_plus + package_info_plus 获取
  - Web 使用 userAgent 作为补充
- 上传审计时注意隐私：不上传硬件唯一标识，不记录敏感字段

### 8.4 Firestore Rules 指南（必须）
- 强制路径隔离：`users/{uid}/...`
- oplog 只允许创建/更新同 uid 的文档
- 业务实体集合只允许访问同 uid 数据
- 禁止跨 uid 读写

### 8.5 成本控制与性能建议
- Push/Pull 批处理（batch size 可配置）。
- Pull 优先用 cursor 增量拉取，避免全量扫描。
- oplog payload 仅存摘要 + hash，避免写入大 JSON。
- 诊断面板提供积压量/失败量阈值提示。

### 8.6 账号切换与 scope 行为矩阵（落地要求）
- scope 默认采用 uid。
- 登录：启动 SyncCoordinator，设置 scope=uid，并触发一次 pull。
- 退出登录：停止 SyncCoordinator；是否保留本地缓存由产品策略决定，但 outbox 必须冻结（不再 push）。
- 切换账号：停止当前 coordinator → 清理或隔离 outbox/sync_state（推荐按 scope 隔离而非清空）→ 设置新 uid → 触发 pull。
- 必须明确并实现：同一设备上不同 uid 的数据是否共存（推荐共存但隔离），以及 UI 侧如何选择显示当前 uid 的数据。

### 8.7 测试策略分层（落地要求）
- contracts 测试：Operation/DeviceIdentity/Cursor/错误分类的序列化与向后兼容。
- sync 状态机测试：幂等、退避、死信、回环防护、cursor 推进条件。
- 适配层测试：drift store 的事务原子性与批处理；firestore gateway 的幂等写与增量查询。
- 端到端集成测试：A 端写入→上云→B 端回填；失败重试→最终一致；oplog 可按 operationId 追溯全链路。

---

## 9. 交付物与里程碑（面向 persistence_*）

### 9.1 版本与发布策略（落地要求）
- persistence_* 以 packages 形式存在时，必须采用语义化版本（SemVer）。
- Public API（见 4.1 与 5.1 对外 API 冻结清单）发生破坏性变更时，必须提升主版本并提供迁移说明。
- 每次发布必须更新变更摘要（changelog 或 release notes），并标注：新增能力、修复、破坏性变更。

### 9.2 交付物与里程碑
- M0：persistence_core 分层稳定（contracts + sync 接口与模型冻结）
- M1：drift outbox + sync_state 可用（含单元测试）
- M2：persistence_core 的 SyncCoordinator push/pull 可用（含幂等/退避/防回环）
- M3：firestore gateway + oplog 全量审计可用（含 rules/索引建议）
- M4：试点实体（card_templates）全链路跑通
- M5：推广到更多实体，形成标准化 onboarding 模板

---

## 10. 验收标准（Definition of Done）

- DoD1：调用层无感知  
  业务调用代码中不出现 drift/firestore/sync 的类型与 API。

- DoD2：离线可写 & 自动同步  
  断网写入成功、恢复网络自动 push，其他端 pull 后可见。

- DoD3：幂等与可追溯  
  operationId 唯一；oplog 与 outbox 可一一对应；重试不产生重复副作用。

- DoD4：防回环  
  pull 回填不产生 outbox；不会发生“同步触发同步”的回环。

- DoD5：可观测  
  同步状态、积压、失败类型可被观测；死信可定位 operationId 与错误原因。

- DoD6：安全合规  
  rules 限制 uid；设备信息不包含硬件唯一标识；审计不记录敏感字段。

- DoD7：全量同步（首次对齐/重置可恢复）  
  新设备首次登录或 cursor 为空/重置时，能够分页完成全量 pull 并回填到本地，支持中断恢复，最终进入增量同步模式；全量/回填流程不产生 outbox 回环。

## 11. 补充落地
下面是一份“落地补充清单”，每条都包含：**推荐决策** → **接口契约（需要在 contracts/实现里明确）** → **最小测试用例**。目标是把 PRD 里最容易踩坑但未定细节的点，一次性定死到可实现、可测试的层面。

**1) 增量游标（Cursor）与排序权威**
- 推荐决策
  - 默认用 **serverUpdatedAt（serverTimestamp）+ operationId** 作为稳定排序键；只有当某实体天然有单调递增 revision（且跨端可靠）时才用 revision。
  - Cursor 统一定义为“最后一条已成功回填的排序键”，避免仅用时间戳导致同毫秒乱序。
- 接口契约
  - `Cursor` 必须能表达复合键：`{ primary: Timestamp, tieBreaker: String }` 或等价结构。
  - `RemoteGateway.listChanges(entityType, scope, cursor, limit)` 返回的 changes 必须按上述键严格升序（或降序+可反转）并且包含用于推进 cursor 的字段：`serverUpdatedAt` 与 `operationId`。
- 最小测试
  - 同一 `serverUpdatedAt` 下两条变更（不同 operationId）拉取顺序稳定且可重复。
  - 本地回填失败时 cursor 不推进；重试后不漏数据也不重复应用。

**2) operationId 的生成与生命周期**
- 推荐决策
  - operationId 在本地生成（UUIDv4/ULID 均可），并作为：outbox 主键 + oplog docId + pull 的去重 key。
- 接口契约
  - `Operation` 至少包含：`operationId, scope(uid), entityType, entityId, opType, clientTime, deviceIdentity, payloadSummary, payloadHash, schemaVersion`。
  - `OutboxStore` 必须提供按状态（pending/processing/dead）与时间排序的批量读取，并保证 operationId 全局唯一（在 scope 内唯一也可，但需明确）。
- 最小测试
  - 崩溃恢复后重复 push 同一 operationId 不产生额外远端副作用（见第 3 条）。

**3) Push 幂等的“真实边界”（不仅是 oplog 幂等）**
- 推荐决策
  - 远端业务写入必须做到“同 operationId 重试不改变最终结果、不会产生重复写副作用”；建议采用 **幂等写策略 +（可选）条件写**。
- 接口契约
  - `RemoteGateway.push(Operation op, RemoteMutation mutation)` 必须保证：
    - 先 `upsertOplog(op, status=pending, attempt+1)`（幂等）
    - 再 `applyEntityMutation(mutation)`（幂等：upsert/merge，或带 precondition）
    - 最后 `updateOplog(status=success|failed|dead, error?)`
  - 明确冲突/旧写处理：`applyEntityMutation` 在“版本落后/被覆盖”时返回可分类错误（例如 `ConflictRejected` vs `TransientError`）。
- 最小测试
  - 模拟网络超时导致 client 重试：oplog 只有 1 条 doc（同 id），实体文档最终状态正确，attempt 递增。
  - 业务写失败时 outbox 不丢；恢复后可继续变为 success。

**4) Outbox 里存“快照”还是“delta/补丁”**
- 推荐决策（两种都能落地，但必须选一个作为默认）
  - 默认选 **快照（RemoteDocSnapshot）**：在本地事务内生成“对应远端 schema 的文档快照/必要字段集合”，写入 outbox。这样 push 时不依赖“当前本地最新状态”，避免后续编辑导致 operation 的语义漂移。
- 接口契约
  - `OutboxRecord` 必须携带 `mutationPayload`（快照或补丁），以及 `entitySchemaVersion`。
  - `LocalApplier` 与业务 DAO 必须提供“在同事务内产出快照”的能力（或者先写业务表、再基于写入参数构建快照，避免事务内二次读取成本）。
- 最小测试
  - 连续两次离线编辑同一 entity，形成两条 outbox：联网后按入队顺序 push，远端最终状态与本地一致，且两条 oplog 都可追溯到各自快照摘要/hash。

**5) Pull 回填的去重、乱序与部分失败处理**
- 推荐决策
  - Pull 以 operationId 去重；对同一 entity 的乱序到达，依赖“排序键 + 冲突策略”决定是否应用。
  - 回填采用“逐条应用 + 成功才推进 cursor”的策略，但要避免“一条坏数据卡死全量”：引入 **per-change 死信/跳过机制**（只在明确不可恢复错误时）。
- 接口契约
  - `LocalApplier.applyRemoteChange(change)` 返回结果需区分：`Applied | SkippedOlder | FailedTransient | FailedFatal`。
  - `SyncStateStore` 需要额外记录：`lastCursor`, `lastAppliedOperationIds(可选窗口)`, `fatalChangeDeadletters(可选)`。
- 最小测试
  - 同一 change 被重复拉取：第二次不重复写本地、不入 outbox。
  - 构造“旧版本 change”到达：被识别为 `SkippedOlder`，但仍可推进 cursor（避免阻塞）。

**6) “Pull 不回环”的工程约束（必须可被破坏性检测）**
- 推荐决策
  - 本地写路径强制区分来源：`UserWrite` 与 `RemoteApply`；RemoteApply 只能走专用入口，底层禁止 enqueue outbox。
- 接口契约
  - `LocalApplier.applyRemoteChange` 必须是唯一允许 RemoteApply 的入口；`OutboxStore.enqueue` 必须要求显式 `WriteSource == UserWrite`（或由上层封装保证）。
- 最小测试
  - 回填一个远端 upsert：本地数据更新，但 outbox 条数不增加。
  - 端到端：A 写→上云→B 回填→B 不会把同一变更再 push 回去。

**7) 删除（softDelete）与墓碑（tombstone）保留/补漏**
- 推荐决策
  - 远端实体文档保留 `deletedAt`（墓碑），并参与增量拉取；墓碑保留至少覆盖“最大离线窗口”（例如 30/90 天二选一，PRD 已提）。
  - 硬删除只能在确定所有客户端都不会再需要该 tombstone 的前提下（通常需要 TTL 足够长）。
- 接口契约
  - `RemoteChange` 必须能表达 delete：`op=softDelete, deletedAt, serverUpdatedAt`。
  - `LocalApplier` 需定义 delete 应用语义：软删标记 + 关联表如何处理（级联/保留）。
- 最小测试
  - B 端离线 14 天，A 端删除：B 上线后能拉到 tombstone 并删掉本地，不会漏删。

**8) 冲突策略从“默认 LWW”落到“可解释、可观测”**
- 推荐决策
  - 保留默认 LWW，但必须把“为什么没应用某条 change”记录到诊断里（至少包含 entityId、排序键、被谁覆盖）。
  - 对关键实体预留升级路径：支持“冲突副本”或“人工介入标记”。
- 接口契约
  - `ConflictPolicy` 输出不仅是 apply/skip，还要给出 reason code（用于诊断面板/日志聚合）。
- 最小测试
  - 两端同时编辑同一 entity：最终一致满足 LWW，且本地能查询到冲突诊断记录（哪条被跳过、原因）。

**9) Scope（uid）隔离：数据库形态与迁移策略必须提前定**
- 推荐决策
  - 基础设施表（outbox/sync_state/diagnostics）必须按 scope 隔离：推荐 **表加 `scope` 列**；业务表是否加 scope 取决于现状，但需要一个统一策略，避免“切号串数据”。
- 接口契约
  - 所有 Store/Gateway 接口都显式带 `AuthScope`（uid），不允许隐式全局变量。
  - 账号切换流程的状态机：stop→冻结旧 scope outbox→切换 scope→触发 pull→再允许 user writes enqueue。
- 最小测试
  - 同设备登录 A→写入→退出→登录 B：B 的 pull 不会污染 A 的本地集合；A 的 outbox 不会被拿去给 B push。

**10) Firestore Rules 与审计可信度（需要明确“审计是调试还是安全证据”）**
- 推荐决策
  - 明确审计用途：如果主要用于“排障/自查”，客户端写 oplog 可接受；如果要“不可抵赖/防篡改”，必须走服务器（Cloud Functions/自建服务）写 oplog 或至少服务器补签名。
- 接口契约
  - 若客户端直写：Rules 至少限制路径 uid、一致性字段不可任意改（例如禁止改 operationId/entityId/op/clientTime/deviceId），仅允许更新 `result` 子树中的有限字段。
- 最小测试
  - Rules 测试（可用 emulator）：跨 uid 读写被拒绝；非法字段更新被拒绝；合法状态流转允许。

**11) 同步调度与资源消耗（电量/流量/前后台）**
- 推荐决策
  - SyncCoordinator 需要明确：前台频率、后台暂停、网络恢复触发、批大小与退避上限；并保证“失败不忙等”。
- 接口契约
  - `SyncCoordinator.start(policy)`：policy 包含 `wifiOnly/foregroundOnly/maxBatch/backoff` 等。
  - `SyncStatus` 需包含 `state + lastSuccessAt + lastError + backlogCount(至少 outbox)`。
- 最小测试
  - 连续失败时退避生效（间隔递增且有上限）；恢复网络后能自动继续并清空积压。

**12) 端到端验收用例补齐为“可自动化”的最小集合**
- 推荐决策
  - 把 PRD 的验收用例固化成最小 E2E 清单（建议用 emulator/抽象 gateway 做集成测试）。
- 最小测试（建议作为 DoD 之外的“门禁”）
  - 离线写→本地立即可见→上线自动 push→另一端自动 pull→UI 更新。
  - 同 operationId 重试：oplog 不重复、实体不重复副作用、outbox 正确出队。
  - Pull 回填不入 outbox。
  - 删除补漏（长离线后仍能拉到 tombstone）。
  - 账号切换隔离。
