# PRDs - Persistence Sync（Local-first + Remote + 无感知同步）

## 1. 背景与问题

当前 xuan 项目各子项目均采用：
- Local：Drift/SQLite（关系型存储，离线可用）
- KV：SharedPreferences（轻量偏好/设置）
- Remote：Firebase 文档数据库（跨端数据访问）

现状痛点：
- 各子项目的持久化实现分散，跨端同步逻辑难以统一复用
- 调用层若直接感知同步，会导致业务代码复杂、难测试、难替换技术栈
- 后续更换本地/远端技术（如 Drift→其他，Firestore→REST）成本不可控

---

## 2. 目标（Goals）

- **G1 无感知同步**：调用层仅依赖 Repository 业务接口（读/写/删/监听），不感知同步流程。
- **G2 Local-first**：写入先落本地成功即返回；断网可用；网络恢复自动同步。
- **G3 跨端一致**：同账号多端数据可自动汇聚与分发；远端变更可回填本地并触发 UI 自动刷新。
- **G4 可观测可运维**：同步状态、错误、积压可被观测；支持重试与降级开关。
- **G5 可替换性**：隔离 Drift/Firestore 技术细节；未来替换本地或远端实现，不修改 Domain/UseCase/调用层。

---

## 3. 非目标（Non-Goals）

- 不在本阶段实现多用户实时协作编辑（可作为未来扩展）
- 不强制所有子项目统一业务表结构
- 不要求将所有 SharedPreferences 全量上云（仅同步必要的“跨端偏好”）

---

## 4. 术语定义

- **Local-first**：本地作为主要工作区与 UI 数据源；远端作为汇聚与分发。
- **Outbox**：本地变更队列表，保证离线写入、幂等重试与崩溃恢复。
- **SyncCoordinator**：同步协调器，负责 Push/Pull、冲突、重试与状态上报。
- **SyncState**：同步游标/状态记录，用于增量拉取与 scope 隔离。
- **Scope**：同步作用域，通常为 uid（登录账号维度）。

---

## 5. 用户故事（User Stories）

- US1：用户在手机端新增/修改模板，电脑端自动看到更新（无需手动同步）
- US2：用户离线编辑模板，联网后自动上传，其他端自动回填
- US3：同步失败不影响继续使用本地功能，但用户能看到同步失败提示
- US4：用户切换账号后，不会串数据，同步游标与队列隔离

---

## 6. 功能需求（Functional Requirements）

### 6.1 Repository 无感知同步
- FR1：Repository 对外只提供业务接口：get/watch/save/delete
- FR2：Repository 读路径只读本地；远端变更通过回填本地触发 UI 更新
- FR3：Repository 写路径先写本地，再把变更写入 Outbox（同一事务）

### 6.2 同步引擎（SyncCoordinator）
- FR4：支持 Push（消费 Outbox 上云），失败自动重试与退避
- FR5：支持 Pull（远端→本地增量回填），幂等执行不产生重复副作用
- FR6：支持冲突处理策略按实体类型配置（默认 LWW）
- FR7：支持 scope 隔离（uid 维度），账号切换可安全重置

### 6.3 Outbox（本地变更队列）
- FR8：记录操作类型（upsert/softDelete）、实体类型/ID、operationId（幂等）
- FR9：记录重试次数、最后错误、状态（pending/sent/failed/dead）
- FR10：可批量消费、可清理历史成功记录

### 6.4 SyncState（同步状态）
- FR11：记录每个实体类型在某 scope 下的增量游标（cursor=updatedAt 或 revision）
- FR12：记录 lastPulledAt/lastPushedAt/lastError，供可观测性使用

### 6.5 远端（Firestore）契约
- FR13：以用户隔离的 collection 设计：users/{uid}/...
- FR14：每个文档具备：id、updatedAt、deletedAt、revision（或 etag）、schemaVersion
- FR15：支持按 cursor 增量查询（updatedAt/revision 升序）

---

## 7. 数据一致性与冲突策略

### 7.1 默认策略（起步）
- CR1：revision 优先比较；revision 相同时比较 updatedAt；仍相同时用 deviceId 破平局
- CR2：冲突不允许静默丢数据：至少可检测并记录（状态/冲突副本策略由实体配置决定）

### 7.2 回填防回环规则
- CR3：由 Pull 回填产生的本地写入，不得再次进入 Outbox（避免回环同步）
- CR4：仅用户主动写入（调用 Repository 的 save/delete）进入 Outbox

---

## 8. 安全与权限（Security）

- SR1：远端读写必须绑定 Firebase Auth uid
- SR2：Firestore Rules 强制用户只能访问 users/{uid}/... 自己的数据
- SR3：不在日志中输出敏感字段与 token
- SR4：必要时支持远端字段级权限扩展（未来协作场景）

---

## 9. 性能与成本（Performance/Cost）

- PR1：Push/Pull 批处理（batch size 可配置），避免频繁小读写
- PR2：Pull 增量拉取优先（cursor），避免全量扫描
- PR3：监听数量可控：默认不对所有集合无限 watch；可按页面/实体启停
- PR4：提供 outbox 积压阈值告警（开发诊断）

---

## 10. 可观测性（Observability）

- OR1：SyncStatus：idle/syncing/error + lastSuccessAt + lastErrorSummary
- OR2：诊断信息：outbox pending 数量、dead 数量、最近一次 pull/push 时间
- OR3：可配置同步开关（全局停用/仅 Wi-Fi/仅前台）

---

## 11. 技术约束与集成方式

- 采用 Ports & Adapters：
  - Domain 仅依赖 Repository
  - Data 层通过 LocalDataSource/RemoteDataSource/SyncCoordinator 隔离 Drift/Firestore
- sync_core 建议放在 common（或独立 package data_core），供所有子项目复用
- 依赖注入：延续 Provider 注入风格（创建本地 DB、Remote 客户端、SyncCoordinator）

---

## 12. 里程碑与验收

- M1：Outbox + Push 可用
  - 离线写入可排队；网络恢复自动上传；不影响调用层
- M2：Pull 回填可用
  - 多端数据可见；调用层无感知；回填不回环
- M3：试点实体稳定
  - 冲突可检测；状态可观测；账号 scope 隔离正确
- M4：推广至更多实体
  - 每新增实体只需实现映射与测试，不改调用层
