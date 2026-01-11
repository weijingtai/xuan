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
