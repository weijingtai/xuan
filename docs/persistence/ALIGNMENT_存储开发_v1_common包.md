# 存储开发（V1）与 common 包对齐（ALIGNMENT）

版本：V1（2026-01-15）

## 0. 输入材料

- docs/persistence/存储开发说明.md
- docs/persistence/存储开发_todo_list_v1.md
- common/lib/database/tables/tables.dart
- common/lib/datasource/layout_template_local_data_source.dart
- persistence_core / persistence_drift / persistence_firebase（仓库根目录 packages）
- xuan/lib/main.dart（当前应用装配）

## 1. 现状盘点（以代码为准）

### 1.1 common 本地库（Drift/AppDatabase）

- 业务库：common/lib/database/app_database.dart（表集合见 common/lib/database/tables/tables.dart）
- 现有表类型与主键特征（摘录）：
  - 稳定 uuid 主键（文本）：Divinations、Seekers、Panels、TimingDivinations、CombinedDivinations、LayoutTemplates、CardTemplateMetas、CardTemplateSettings 等
  - 自增主键（int autoincrement）：SeekerDivinationMappers、DivinationPanelMappers、PanelSkillClassMappers、DivinationSubDivinationTypeMappers、CardTemplateSkillUsages 等
  - Skills：当前为 id 自增主键（缺少远端稳定键字段）
  - 字典表：SkillClasses/DivinationTypes/SubDivinationTypes 均存在 isCustomized/isAvailable（以及 SubDivinationTypes.hiddenAt）

### 1.2 persistence_* 同步基础设施

- persistence_core：包含 SyncCoordinator + SyncRuntime（纯 Dart）。
- persistence_drift：提供 OutboxStore / SyncStateStore 的 Drift 实现（独立数据库 PersistenceDriftDatabase）。
- persistence_firebase：提供 FirestoreRemoteGateway（RemoteGateway 的 Firestore 实现）。

### 1.3 已落地样板（LayoutTemplate）

- common 内已存在 LayoutTemplateLocalDataSource，实现：
  - 本地写入业务表 + enqueue Outbox（entityType=layout_template）
  - pull 回填：LocalApplier.applyRemoteChanges 仅支持 entityType=layout_template

### 1.4 应用层装配现状（仓库根 xuan/lib/main.dart）

- 已装配 SyncCoordinator（OutboxStore/SyncStateStore/RemoteGateway/LocalApplier）。
- 当前未看到应用层对 SyncRuntime 的创建/持有/生命周期驱动（与 docs/persistence/Warning.md 的结论一致）。
- FirestoreRemoteGateway 当前实体路径映射仅支持 entityType=layout_template。
- FirestoreRemoteGateway 默认 module 为 persistence_firebase；现有装配未传 module 参数。

## 2. 文档方案（V1）与现状的一致点

- 数据归属拆分（Public pull-only vs User push+pull）的方向与 SyncCoordinator/RemoteGateway/Outbox 的抽象一致。
- “本地写入 + outbox 入队 + push + pull 回填 + 冲突处理”的闭环在 layout_template 上已经跑通。
- V1 要求的稳定 uuid 主键（类型1）已覆盖多张核心资产表与配置表：
  - Divinations / Seekers / Panels / TimingDivinations / CombinedDivinations / LayoutTemplates
  - CardTemplateMetas / CardTemplateSettings（以 templateUuid 为主键）

## 3. 文档方案（V1）与现状的差异（需要对齐/补齐）

### 3.1 同步调度层（SyncRuntime）缺失“两套 runtime”落地

V1 要求：
- PublicRuntime：scopeUid 固定（建议 public），pull-only
- UserRuntime：scopeUid=active appUserId，push+pull

现状：
- 已有 SyncRuntime 实现，但未在应用层使用与接线。
- SyncCoordinator 当前仅注入单一 LocalApplier（LayoutTemplateLocalDataSource），无法覆盖多 entityType 回填。

结论：
- V1 的“全表接入”在调度层与回填层均未齐备，属于结构性缺口。

### 3.2 RemoteGateway 的 entityType → Firestore 路径映射未对齐 V1

V1 要求的路径：
- user：users/{appUserId}/modules/common/{entityType}/{entityId}
- public：public/modules/common/{entityType}/{entityId}

现状：
- persistence_firebase 的 FirestoreRemoteGateway 目前只支持 layout_template，并写入 users/{scopeUid}/modules/{module}/layout_templates/{entityId}
- 未支持 public 根集合，也未支持 entityType 的通用路由
- module 默认值为 persistence_firebase（与 V1 的 common 模块隔离字段不一致）

结论：
- 需要把 RemoteGateway 的映射机制体系化（至少支持 common 模块 + public/user 双通道 + 多 entityType）。

### 3.3 稳定主键策略（Stable EntityId）未落地到 common 表结构

V1 对类型2/类型3 的要求：
- 映射表 stable_id（确定性 hash）+ 本地复合唯一约束
- 事件表 event_id（UUID/ULID），支持幂等补发/可选 pull

现状：
- 多张映射表仍使用自增主键，且无 stable_id 列：
  - DivinationSubDivinationTypeMappers / SeekerDivinationMappers / DivinationPanelMappers / PanelSkillClassMappers
- CardTemplateSkillUsages 为事件/日志性质，但无 event_id 列

结论：
- 这是全量同步的硬阻塞：未补齐 stable_id/event_id 前无法保证跨设备幂等与一致性。

### 3.4 “默认集 + 用户维护集 + overlay”模型未落地到本地数据模型

V1 要求：
- 默认集（public pull-only）与用户维护集（user push+pull）分离
- overlay 独立存储（用于禁用默认项、排序、别名等），避免 public 更新覆盖用户意图

现状：
- SkillClasses / DivinationTypes / SubDivinationTypes 存在 isCustomized/isAvailable 等字段，但仍在同表表达“默认+自定义+启用/禁用”语义
- 未发现 overlay 专用表
- 部分表的字段语义存在歧义：
  - SubDivinationTypes 同时存在 hiddenAt 与 isAvailable（与 overlay 的 enabled/disabled 语义可能冲突）

结论：
- 需要明确“最终视图（effective view）”的查询规则与落地方式（单表混合 vs 分表/overlay），否则无法保证 public 更新与用户选择可预测。

### 3.5 entitlement（用户权益）能力缺失

V1 要求：
- UserSkillEntitlement：用户只读（pull），写由云函数/后台
- 业务 gating：skill 可使用 = catalog ∩ entitlement

现状：
- common 的 AppDatabase 未见 entitlement 表
- Panels 表存在 skillId 外键引用 Skills（catalog），但未见 entitlement 的本地校验来源

结论：
- 需要新增 entitlement 数据源（本地表/独立库）与业务 gating 链路。

## 4. 对齐结论（当前状态的“可执行解释”）

### 4.1 当前已具备的最小闭环能力

- user scope 下 layout_template 的 push/pull 与回填样板闭环已经具备。

### 4.2 V1 全表落地的关键阻塞（按优先级）

1) 类型2/类型3 的 stable_id/event_id 未落地（硬阻塞）
2) LocalApplier 仍为单入口（硬阻塞）
3) FirestoreRemoteGateway 映射不支持多 entityType + public 通道（硬阻塞）
4) SyncRuntime 两套 runtime 未装配到应用运行时（功能缺口）
5) overlay 与 entitlement 未落地（业务模型缺口）

## 5. 对齐建议（默认决策，供后续 CONSENSUS 使用）

### 5.1 命名与隔离

- module 统一使用 common（与 V1 路径一致）
- public scopeUid 固定为 public（仅用于 cursor 隔离；远端路径不挂 users）
- user scopeUid 使用 appUserId（不使用 firebase auth uid 直分桶）

### 5.2 entityType 命名策略（建议）

- 延续现有样板：layout_template
- 其余按存储开发_todo_list_v1.md 的建议命名
- public/user/overlay 三域使用不同 entityType，避免同名但语义不同造成冲突

### 5.3 本地表改造策略（建议）

- 类型2 映射表：新增 stable_id（TEXT）并回填；增加复合唯一索引；同步主键使用 stable_id
- 类型3 事件表：新增 event_id（TEXT）并回填；同步主键使用 event_id
- Skills：增加 skill_code 或 uuid（唯一索引），作为远端稳定键
- overlay：新增专用表（仅存 targetId + enabled/disabled + updatedAt/deletedAt）

