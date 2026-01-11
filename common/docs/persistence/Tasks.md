# Persistence Sync（Local-first + Remote + 无感知同步）Todo List

> 目标：在不推倒现有 Drift/SQLite + SharedPreferences 的前提下，引入可复用的同步基础设施（Outbox + SyncCoordinator + SyncState），让调用层仅依赖 Repository 的业务接口、无感知数据同步；并可逐步扩展到各子项目。

---

## 0. 约束与验收口径

- 调用层（UI/UseCase）不出现 sync/upload/download/firestore/drift 等语义与类型
- 写入路径：先落本地成功即返回；同步异步进行，断网可写
- 读取路径：只读本地（watch）；远端回填触发本地更新后 UI 自动刷新
- 同步失败：不阻塞业务；可观测（状态/错误/重试）
- 远端与本地实现可替换：通过接口与注入切换实现，不改 Domain/UseCase

---

## 1. 任务拆分（原子化）

### T1 - 基线调研与约定冻结（必须先做）
- **输入契约**
  - common 当前可同步的核心实体清单（至少 1 个试点实体：建议 LayoutTemplate 或 card_template_setting）
  - 当前 Drift 表字段：id/updatedAt/deletedAt 的存在情况
  - 当前 Firebase/Firestore 的集合路径与认证方式（uid 维度）
- **输出契约**
  - 《同步字段约定》：id/updatedAt/deletedAt/revision/schemaVersion 的规范（写入/比较/迁移规则）
  - 《路径约定》：users/{uid}/... 的 collection 命名与分层
  - 《冲突策略默认值》：LWW + deviceId 破平局；哪些实体需要特殊策略
- **验收标准**
  - 试点实体的 Firestore 文档 schema 被明确（字段 + 类型 + 版本号）
  - 明确哪些 SharedPreferences 需要跨端同步、哪些保持本机
- **依赖**
  - 无

---

### T2 - 设计并落地 sync_core 的模块边界（只做骨架，不写业务）
- **输入契约**
  - T1 的约定冻结
- **输出契约**
  - sync_core 的目录结构与公共接口定义（Local/Remote/SyncCoordinator/Clock/DeviceId/Result）
  - 错误模型与可观测性模型（SyncStatus、SyncError 分类）
- **验收标准**
  - 所有子项目未来接入只需实现 RemoteDataSource + 注册实体映射，不需要复制同步逻辑
- **依赖**
  - T1

---

### T3 - Drift：新增 Outbox 表（本地变更队列）
- **输入契约**
  - T2 的接口与字段约定
- **输出契约**
  - Drift 表：outbox（operationId、entityType、entityId、op、payloadHash/summary、createdAt、attempt、lastError、status）
  - OutboxDao：enqueue、peekBatch、markSuccess、markFailed、prune
- **验收标准**
  - 单元测试：enqueue 与业务写入可在同一事务完成（原子性）
  - 单元测试：失败重试计数与状态流转正确
- **依赖**
  - T2

---

### T4 - Drift：新增 SyncState 表（增量拉取游标/同步元信息）
- **输入契约**
  - T1 的增量策略（cursor=updatedAt/revision）
- **输出契约**
  - Drift 表：sync_state（scope(uid)、entityType、lastPulledCursor、lastPushedAt、lastPulledAt、lastError）
  - SyncStateDao：get/set cursor、update timestamps、record error
- **验收标准**
  - 单元测试：cursor 更新幂等，scope 隔离生效
- **依赖**
  - T2

---

### T5 - SyncCoordinator：Outbox Push（本地→远端）状态机
- **输入契约**
  - OutboxDao + RemoteDataSource 接口
- **输出契约**
  - 同步循环：取 batch → 写远端（幂等）→ 标记成功/失败 → 退避重试
  - 错误分级：网络/权限/冲突/未知
  - SyncStatus 流：idle/syncing/error + lastSuccessAt
- **验收标准**
  - 单元测试：模拟远端失败后重试，成功后 outbox 清理
  - 单元测试：幂等 operationId 重放不产生重复写（远端侧需支持）
- **依赖**
  - T3、T2

---

### T6 - SyncCoordinator：Pull 增量回填（远端→本地）
- **输入契约**
  - SyncState cursor + RemoteDataSource 增量查询能力
- **输出契约**
  - 增量拉取：按 entityType + cursor 拉取变更集合
  - 本地回填：走 LocalDataSource 的 upsert/softDelete（不触发 UI 侧同步感知）
  - cursor 推进策略与“回填不入 outbox”的规则（防止回环）
- **验收标准**
  - 单元测试：同一批次拉取重复执行不会导致数据异常（幂等）
  - 单元测试：pull 写本地不会产生新的 outbox 记录
- **依赖**
  - T4、T2

---

### T7 - 试点实体接入（选择 1 个：LayoutTemplate 或 card_template_setting）
- **输入契约**
  - 该实体的 LocalDataSource 已存在或可快速补齐
  - Firestore schema/collection 路径已定
- **输出契约**
  - RemoteDataSource：serialize/deserialize、upsert、softDelete、listChanges(sinceCursor)
  - RepositoryImpl：写本地 + enqueue outbox；读本地 watch；初始化触发 pull
- **验收标准**
  - 集成测试：A 端保存 → 断网 → 恢复 → 自动同步 → B 端可见
  - 集成测试：B 端修改 → A 端自动回填 → UI 无需改动
- **依赖**
  - T5、T6

---

### T8 - 鉴权与多账号 scope 隔离策略（必须早定）
- **输入契约**
  - Firebase Auth 接入方式与 uid 可获取
- **输出契约**
  - scope 方案（二选一并落实）：
    - A：按 uid 分库名（更隔离但迁移成本高）
    - B：同库 + sync_state/outbox 按 uid scope（推荐起步）
  - 切换账号时的策略：停止同步→清 outbox?→重置 cursor→是否清本地缓存
- **验收标准**
  - 账号切换后不会串数据；同步游标不交叉
- **依赖**
  - T2

---

### T9 - 可观测性与运维开关（不影响调用层）
- **输入契约**
  - SyncStatus 模型
- **输出契约**
  - 开关：启用/停用同步、仅 Wi-Fi、后台同步策略（可选）
  - 诊断面板（开发入口）：显示 outbox 积压、最近错误、lastSyncAt
- **验收标准**
  - 同步失败可定位原因；不需要抓日志才能判断
- **依赖**
  - T5、T6

---

### T10 - 推广到更多实体（分批次）
- **输入契约**
  - 试点稳定 + 规范沉淀
- **输出契约**
  - 每个实体一张接入卡：collection、cursor、冲突策略、字段映射、验收用例
- **验收标准**
  - 每新增一个实体，不修改调用层；只新增 data 层接入代码与测试
- **依赖**
  - T7

---

## 2. 执行顺序（建议）

1. T1（冻结约定）
2. T2（sync_core 骨架）
3. T3（Outbox）
4. T4（SyncState）
5. T5（Push）
6. T6（Pull）
7. T7（试点实体）
8. T8（账号隔离）
9. T9（可观测性）
10. T10（推广）

---

## 3. 每阶段交付验收（快照）

- **里程碑 M1**：Outbox + Push 可用（离线写入可排队，网络恢复自动上传）
- **里程碑 M2**：Pull 回填可用（多端可见，调用层无感知）
- **里程碑 M3**：试点实体全链路稳定（含冲突与可观测性）
- **里程碑 M4**：推广到 N 个核心实体
