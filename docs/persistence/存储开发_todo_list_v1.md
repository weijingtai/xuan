# 存储开发 Todo List（V1，表级别）

版本：V1（2026-01-15）
范围：`common` 的 `AppDatabase` 全表 + Firestore(public/user) + persistence_* 同步闭环落地

---

## 0. 全局前置（表无关，但所有表依赖）

- [ ] 接入 SyncRuntime（两套）
  - [x] UserRuntime：scopeUid = active `appUserId`（支持 guest），push+pull
  - [ ] PublicRuntime：scopeUid 固定（建议 `public`），pull-only
- [x] 实现 CompositeLocalApplier（entityType → LocalApplier 路由），替换目前只注入 LayoutTemplateLocalDataSource 的单入口回填
- [ ] 扩展 FirestoreRemoteGateway entityType → doc path 映射
  - [x] user：`users/{appUserId}/modules/common/{entityType}/{entityId}`
  - [ ] public：`public/modules/common/{entityType}/{entityId}`
- [ ] Firestore Rules（P0 必做）
  - [ ] public：allow read；deny write（仅管理员/云函数可写）
  - [ ] user：基于 identity_map 映射校验 appUserId；仅允许读写自己的桶
  - [ ] entitlement：用户只读；写走云函数/后台（建议）
- [ ] 同步 payload 规范（V1）
  - [ ] schemaVersion=1；opType：upsert/softDelete；统一字段口径（entityId、deletedAt、clientUpdatedAt/updatedAt 等）
- [ ] 主键稳定化策略落地（V1）
  - [ ] 类型1（实体）：UUID/ULID
  - [ ] 类型2（映射）：stable_id = deterministic hash(scope+a+b)，本地保留复合唯一约束
  - [ ] 类型3（事件）：event_id = UUID/ULID，本地也以 event_id 为主标识（若需要多端可见）

---

## 1. 表级别接入矩阵（common/AppDatabase）

说明：
- 数据域：Public = 全局默认(pull-only)；User = 用户私有(push+pull)；Overlay = 用户覆盖层(push+pull)；Event = 事件表(按需 push+pull 或只 push 汇总)
- “当前表结构”以 `common/lib/database/tables/tables.dart` 为准

---

### 1.1 Skills（t_skills）

定位：全局 Skill Catalog（公共定义）。但用户是否可用取决于 entitlement。

- 数据域：Public（pull-only）
- 远端 entityType（建议）：`skill`
- 主键策略：
  - 当前为 `id INTEGER AUTOINCREMENT`（保留用于本地引用/外键）
  - 需要新增远端稳定键：`skill_code`（推荐）或 `skill_uuid`（推荐）
- 任务：
  - [ ] 设计 Skill 远端稳定标识：`skill_code`（短字符串）或 `uuid`
  - [ ] 本地表增加 `skill_code/uuid` 列，并建立唯一索引
  - [ ] public pull-only 回填：upsert/softDelete
  - [ ] 业务侧可用性判定：catalog ∩ entitlement
  - [ ] 迁移：为现有 skills 回填 skill_code/uuid（与 initial_data.sql 对齐）
  - [ ] 测试：public 更新 → 本地可见；客户端无法写 public

---

### 1.2 SkillClasses（t_skill_classes）

定位：既有全局默认（公共），也允许用户自定义维护（用户私有），并支持用户对默认项启用/禁用（Overlay）。

- 数据域：
  - Public：默认 SkillClasses（pull-only）
  - User：用户自建 SkillClasses（push+pull）
  - Overlay：用户对默认 SkillClasses 的 enabled/disabled（push+pull）
- 远端 entityType（建议）：
  - public：`skill_class_public`
  - user：`skill_class_user`
  - overlay：`skill_class_overlay`
- 主键策略：
  - 当前主键 `uuid TEXT`（可复用）
  - 需要在查询“最终视图”时区分来源（public/user）
- 任务：
  - [ ] 定义最终视图规则：user 自建优先 + overlay 禁用覆盖 public 默认
  - [ ] 为 overlay 建立本地表（仅存：targetId + enabled/disabled + updatedAt）
  - [ ] public pull-only 回填 SkillClasses（默认集）
  - [ ] user push+pull：用户新增/编辑/删除 SkillClasses
  - [ ] 统一查询 API：listEffectiveSkillClasses()
  - [ ] 测试：overlay 禁用在多端一致；public 更新不覆盖用户禁用

---

### 1.3 DivinationTypes（t_divination_types）

定位：同 SkillClasses —— 公共默认 + 用户自建 + overlay 启用/禁用。

- 数据域：Public + User + Overlay
- 远端 entityType（建议）：
  - public：`divination_type_public`
  - user：`divination_type_user`
  - overlay：`divination_type_overlay`
- 主键策略：当前主键 `uuid TEXT`（可复用）
- 任务：
  - [ ] public pull-only 回填默认 DivinationTypes
  - [ ] user push+pull：用户维护 DivinationTypes
  - [ ] overlay：用户禁用默认类型（不修改 public 本体）
  - [ ] 统一查询 API：listEffectiveDivinationTypes()
  - [ ] 测试：禁用/启用多端一致；public 更新不覆盖用户禁用

---

### 1.4 SubDivinationTypes（t_sub_divination_types）

定位：同 DivinationTypes —— 公共默认 + 用户自建 + overlay；表内已有 hiddenAt/isAvailable 等字段，需统一“enabled/disabled”语义。

- 数据域：Public + User + Overlay
- 远端 entityType（建议）：
  - public：`sub_divination_type_public`
  - user：`sub_divination_type_user`
  - overlay：`sub_divination_type_overlay`
- 主键策略：当前主键 `uuid TEXT`（可复用）
- 任务：
  - [ ] 补齐本地 DAO（当前未发现对应 DAO）
  - [ ] 统一 enabled/disabled：优先用 overlay 表表达用户选择；public 仍可提供 isAvailable
  - [ ] public pull-only 回填默认 SubDivinationTypes
  - [ ] user push+pull：用户维护 SubDivinationTypes
  - [ ] 统一查询 API：listEffectiveSubDivinationTypes()
  - [ ] 测试：overlay 规则与 public 字段交互可预测

---

### 1.5 DivinationSubDivinationTypeMappers（t_divination_sub_divination_type_mappers）

定位：类型-子类型映射。必须支持：公共默认映射 + 用户自建映射 + 用户禁用默认映射（Overlay）。同时当前表为自增主键，需 stable_id。

- 数据域：Public + User + Overlay
- 远端 entityType（建议）：
  - public：`divination_type_subtype_map_public`
  - user：`divination_type_subtype_map_user`
  - overlay：`divination_type_subtype_map_overlay`
- 主键策略（类型2）：
  - 需要 stable_id = hash(`scope|typeUuid|subTypeUuid`)
  - 本地保留复合唯一约束：(`typeUuid`,`subTypeUuid`,scope)
- 任务：
  - [ ] 本地表新增 `stable_id`（TEXT）列并回填
  - [ ] 增加复合唯一索引（typeUuid, subTypeUuid, scope）
  - [ ] public pull-only 回填默认映射
  - [ ] user push+pull：用户维护映射（新增/删除）
  - [ ] overlay：用户禁用默认映射（不改 public 本体）
  - [ ] 统一查询 API：listEffectiveMappings(typeUuid)
  - [ ] 测试：同一映射多端重复创建不重复；禁用规则稳定

---

### 1.6 LayoutTemplates（t_layout_templates）

定位：用户配置/资产（已接入同步样板）。

- 数据域：User（push+pull）
- 远端 entityType：`layout_template`（已存在）
- 主键策略：uuid（已稳定）
- 任务：
  - [x] 将 LayoutTemplateLocalDataSource 接入 CompositeLocalApplier 路由（保持现有行为）
  - [x] 确认 pullEntityTypes 包含 layout_template（user runtime）
  - [ ] 验收：A 端保存 → 断网 → 恢复 → 同步 → B 端可见（已有测试基础可复用）

---

### 1.7 CardTemplateMetas（t_card_template_meta）

定位：模板元信息（用户私有）。当前未接入同步（仅本地写）。

- 数据域：User（push+pull）
- 远端 entityType（建议）：`card_template_meta`
- 主键策略：templateUuid（TEXT）稳定，可作为 entityId
- 任务：
  - [ ] 定义 payload：包含 templateUuid + modifiedAt + deletedAt + authorUuid 等
  - [ ] 本地写入触发 outbox（upsert/softDelete）
  - [ ] LocalApplier 回填（LWW 以 modifiedAt/updatedAt 为准）
  - [ ] RemoteGateway 支持 entityType 映射
  - [ ] 测试：多端修改冲突策略一致

---

### 1.8 CardTemplateSettings（t_card_template_setting）

定位：模板运行时设置（用户私有）。当前未接入同步。

- 数据域：User（push+pull）
- 远端 entityType（建议）：`card_template_setting`
- 主键策略：templateUuid（稳定）
- 任务：
  - [ ] payload：templateUuid + settingJson + modifiedAt/deletedAt
  - [ ] 本地写入 enqueue outbox；pull 回填
  - [ ] LWW 冲突策略（modifiedAt 优先）
  - [ ] 测试：多端覆盖一致

---

### 1.9 CardTemplateSkillUsages（t_card_template_skill_usage）

定位：事件/日志（模板技能使用记录）。你已建议：若多端可见，则本地也用 eventId。

- 数据域：Event
- 同步策略二选一（先定口径）：
  - 方案 E1：多端可见（push+pull）
  - 方案 E2：仅远端汇总（只 push，不 pull；可复用 outbox 做离线补发）
- 主键策略（类型3）：
  - 新增 `event_id`（UUID/ULID）列；本地查询可保留自增 id 作为辅助排序
- 任务：
  - [ ] 明确是否需要多端可见（E1 或 E2）
  - [ ] 增加 event_id 并回填历史记录
  - [ ] 若 E1：实现 LocalApplier 回填；pullEntityTypes 增加该 entityType
  - [ ] 若 E2：实现 Outbox push-only；服务端统计去重基于 event_id
  - [ ] 测试：断网重试不重复计数/不重复事件

---

### 1.10 CombinedDivinations（t_combined_divinations）

定位：用户资产（组合占测），uuid 主键稳定。

- 数据域：User（push+pull）
- 远端 entityType（建议）：`combined_divination`
- 主键策略：uuid（稳定）
- 任务：
  - [ ] 定义 payload（含 divinationUuid、order、timestamps、deletedAt）
  - [ ] 本地写入 enqueue outbox；pull 回填
  - [ ] 冲突策略（LWW 基于 lastUpdatedAt/createdAt）
  - [ ] 测试：组合顺序(order) 多端更新一致性

---

### 1.11 Divinations（t_divinations）

定位：用户资产（占测记录），uuid 主键稳定。

- 数据域：User（push+pull）
- 远端 entityType（建议）：`divination`
- 主键策略：uuid（稳定）
- 任务：
  - [ ] 定义 payload（字段较多，建议 template：完整 upsert + softDelete）
  - [ ] 本地写入 enqueue outbox；pull 回填
  - [ ] 冲突策略：LWW（lastUpdatedAt/deletedAt）
  - [ ] 测试：跨设备编辑同一 divination 的冲突行为可预测

---

### 1.12 Seekers（t_seekers）

定位：用户资产（求测人），uuid 主键稳定。

- 数据域：User（push+pull）
- 远端 entityType（建议）：`seeker`
- 主键策略：uuid（稳定）
- 任务：
  - [ ] payload：完整 upsert + softDelete
  - [ ] LWW（lastUpdatedAt/deletedAt）
  - [ ] 测试：多端更新同一 seeker 合并规则一致

---

### 1.13 Panels（t_panels）

定位：用户资产（盘），uuid 主键稳定，且引用 Skills（全局）与 skill entitlements（用户权限）。

- 数据域：User（push+pull）
- 远端 entityType（建议）：`panel`
- 主键策略：uuid（稳定）
- 任务：
  - [ ] payload：upsert/softDelete
  - [ ] 业务约束：创建/使用 panel 前校验 entitlement（无权限不可用）
  - [ ] 测试：无授权 skill 时无法创建/使用对应 panel

---

### 1.14 TimingDivinations（t_timing_divinations）

定位：用户资产（时间占测记录），uuid 主键稳定。

- 数据域：User（push+pull）
- 远端 entityType（建议）：`timing_divination`
- 主键策略：uuid（稳定）
- 任务：
  - [ ] payload：upsert/softDelete
  - [ ] LWW（lastUpdatedAt/deletedAt 或 serverUpdatedAt）
  - [ ] 测试：多端更新一致

---

### 1.15 SeekerDivinationMappers（t_seeker_divination_mapper）

定位：用户映射表（seeker↔divination）。当前为自增主键，必须 stable_id（类型2）。

- 数据域：User（push+pull）
- 远端 entityType（建议）：`seeker_divination_map`
- 主键策略（类型2）：
  - stable_id = hash(`scope|seekerUuid|divinationUuid`)
  - 本地复合唯一约束（seekerUuid, divinationUuid, scope）
- 任务：
  - [ ] 新增 stable_id 并回填
  - [ ] 增加复合唯一索引
  - [ ] outbox/pull 回填支持
  - [ ] 测试：幂等创建同一映射不重复

---

### 1.16 DivinationPanelMappers（t_divination_panel_mappers）

定位：用户映射表（divination↔panel）。自增主键 → stable_id（类型2）。

- 数据域：User（push+pull）
- 远端 entityType（建议）：`divination_panel_map`
- 主键策略（类型2）：
  - stable_id = hash(`scope|divinationUuid|panelUuid`)
  - 本地复合唯一约束（divinationUuid, panelUuid, scope）
- 任务：
  - [ ] 新增 stable_id 并回填
  - [ ] outbox/pull 回填支持
  - [ ] 测试：映射幂等

---

### 1.17 PanelSkillClassMappers（t_panel_skill_class_mapper）

定位：用户映射表（panel↔skillClass）。自增主键 → stable_id（类型2）。注意 skillClass 同时存在 public/user 两套，映射应使用逻辑ID并携带来源口径。

- 数据域：User（push+pull）
- 远端 entityType（建议）：`panel_skill_class_map`
- 主键策略（类型2）：
  - stable_id = hash(`scope|panelUuid|skillClassLogicalId`)
  - 本地复合唯一约束（panelUuid, skillClassLogicalId, scope）
- 任务：
  - [ ] 明确 skillClassLogicalId 口径（public/user namespace）
  - [ ] 新增 stable_id 并回填
  - [ ] outbox/pull 回填支持
  - [ ] 测试：public/user skillClass 混用时不串数据

---

## 2. entitlement（用户权益）表（需要新增/落地到某个数据库）

说明：当前 `common` 的 AppDatabase 中未见 entitlement 表，但方案 V1 要求存在该能力。需要确定落在哪个 DB（common 业务库或独立权限库）。

- [ ] 设计 UserSkillEntitlement 本地表
  - 字段建议：appUserId、skill_code/uuid、status、validUntil、updatedAt、deletedAt
- [ ] 远端 entityType（建议）：`user_skill_entitlement`
- [ ] 同步策略：用户只读（pull），写由云函数/后台
- [ ] 规则：客户端不可写 entitlement
- [ ] 验收：授权变更可在多端生效；无授权不可用对应 skill

---

## 3. 迁移与回归（按表推进）

- [ ] 先落地“类型2/类型3”的稳定键迁移（映射表 + 事件表），否则全量同步无法正确幂等
- [ ] 为每张接入同步的表补齐 migration（AppDatabase schemaVersion 升级路径必须覆盖）
- [ ] 每个 entityType 至少具备：
  - [ ] 本地写入 enqueue outbox（若为 user 或需要 push）
  - [ ] 远端映射（RemoteGateway entityDoc）
  - [ ] 回填（LocalApplier.applyRemoteChanges）
  - [ ] 冲突策略（LWW/其它）可测
- [ ] 集成测试（Firestore emulator）
  - [ ] public：远端更新 → 本地可见
  - [ ] user：A 端写 → B 端可见
  - [ ] rules：public 写入被拒绝；entitlement 写入被拒绝；user 桶隔离

---

## 4. 实施顺序建议（最小可用优先）

- P0：CompositeLocalApplier + SyncRuntime + RemoteGateway 扩展 + Rules
- P1：Public 字典（Skills + 默认 type/subtype/class + 默认 mapper）
- P1：User 自定义字典 + Overlay（type/subtype/class + mapper）
- P1：entitlement（只读 pull）打通 + 业务 gating
- P2：用户资产表逐个接入（Divinations/Panels/Seekers/TimingDivinations/CombinedDivinations）
- P2：映射表 stable_id 全量迁移并接入同步（SeekerDivination/DivinationPanel/PanelSkillClass）
- P2：事件表按 E1/E2 决策落地（CardTemplateSkillUsages）
