# PRDs：LayoutTemplate / CardTemplate 审计与使用统计（layout_template_aduit）

## 1. 背景与问题

当前工程中已经存在可持久化的“卡片模板”能力：`LayoutTemplate` 作为模板域模型，序列化为 JSON 存入 Drift 数据库表 `t_layout_templates`。

随着“模板可复用/可分享/可派生”的需求增长，模板本体数据之外，还需要三类扩展数据：

- 模板元信息（审计与来源追踪）
- 使用时可随时调整的设置（不进入编辑页、不修改模板本体）
- 以“查询/请求”为维度的技能使用记录（事件型日志）

本 PRD 目标是在不破坏现有 `LayoutTemplate` 存储与编辑流程的前提下，明确数据分层与表结构，支持后续实现与验收。

## 2. 目标（Goals）

- 将“模板本体”“模板元信息”“运行时设置”“使用日志”拆分为清晰的数据归属与持久化口径。
- 保持现有 `LayoutTemplate` JSON 存储方式可用，新增能力尽量以新增表实现，避免对 `template_json` 做侵入式变更。
- 支持以下核心能力：
  - 模板来源追踪（作者、从哪个模板/卡片派生等）
  - 使用时即时调整显示/颜色模式，不需要进入编辑页修改模板
  - 以 `query_uuid` 维度记录某模板在某技能下的使用时间（带时区的 timestamp），并支持按字段快速检索

## 3. 范围与非范围（Scope / Out of Scope）

### 3.1 范围

- 明确 `CardTemplate`（共享模板数据）的字段口径与来源（直接复用现有 `LayoutTemplate`）。
- 定义 `CardTemplateMeta`（模板元信息）所需字段及其作用。
- 定义 `CardTemplateSetting`（运行时设置覆盖层）的字段及其作用。
- 定义 `t_card_template_skill_usage`（技能使用日志表）的字段、索引与语义。

### 3.2 非范围

- 不在本 PRD 中实现 UI、交互与具体页面。
- 不在本 PRD 中定义云同步策略与冲突解决策略。
- 不在本 PRD 中引入 `use_count` 或时长统计（`total_use_duration_ms`）等聚合字段。

## 4. 术语与实体定义

### 4.1 CardTemplate（模板本体数据）

CardTemplate 指可被复用、复制、分享的“模板定义”。在现有工程里直接对应 `LayoutTemplate` 的序列化 JSON。

数据来源：

- Domain 模型：`LayoutTemplate`
- 持久化表：`t_layout_templates.template_json`

字段口径（现有 `LayoutTemplate`）：

- `uuid`：模板唯一标识（现有字段 `id`）
- `name`：模板名称
- `description`：模板描述
- `collectionId`：模板集合/分组标识
- `cardStyle`：卡片样式（全局字体、分割线、内容内边距等）
- `chartGroups[]`：分组信息（包含 `pillarOrder` 等）
- `rowConfigs[]`：行配置（可见性、标题显示、文本样式等）
- `editableTheme`：可编辑主题（Map JSON）
- `updatedAt`：最后更新时间

字段作用说明：

- `cardStyle`：定义模板在 UI 渲染时的全局视觉基调（divider、字体、padding）。
- `chartGroups.pillarOrder`：定义柱位的展示顺序与包含哪些柱位。
- `rowConfigs`：定义每种 `RowType` 是否显示、标题是否显示、以及其文本/颜色映射策略。
- `editableTheme`：用于更高级的主题扩展与渲染参数透传，避免频繁扩展模板结构。
- `updatedAt`：用于本地更新追踪与未来同步预留。

### 4.2 CardTemplateMeta（模板元信息）

CardTemplateMeta 用于记录模板的审计信息与来源追踪信息，不建议与运行时设置/个人偏好混存。

字段口径（需要新增/补齐）：

- `createdAt`：模板首次创建时间
- `modifiedAt`：模板最后修改时间（现有 `updatedAt` 可视为 `modifiedAt`）
- `deletedAt`：软删除时间（已有）
- `authorUuid`：作者/创建者标识。可以为空（例如系统默认模板）。
- `createFromCardUuid`：派生来源模板/卡片的 uuid
- `isCustomized`：是否为用户自定义模板（用于区分内置模板/系统模板与用户模板）

字段作用说明：

- `authorUuid`：用于展示“作者”、权限控制、以及模板归属管理。
- `createFromCardUuid`：用于 lineage 追踪（显示“从某模板复制”、回溯来源、模板变体分析）。
- `isCustomized`：用于筛选、展示标签（如“系统模板/自定义模板”）以及后续同步策略差异。

### 4.3 CardTemplateSetting（运行时设置覆盖层）

CardTemplateSetting 用于“使用时可随时调整”的设置，特点是：

- 不需要进入编辑页面修改
- 不应修改模板本体（不写回模板 JSON）
- 在渲染前与模板数据进行合并（覆盖层）

字段口径：

- `createdAt`：Setting 首次创建时间
- `modifiedAt`：Setting 最后修改时间
- `deletedAt`：Setting 软删除时间
- `templateUuid`：对应模板 uuid
- `showTitleColumn`：是否显示标题列（例如隐藏 `PillarType.rowTitleColumn`）
- `showInCellTitleGlobal`：是否启用单元格内标题（全局开关）
- `showInCellTitleByRowType`：Map<RowType, bool>，支持“每一行单独设定”
- `activeColorMode`：当前激活颜色模式（如 pure/colorful）
- `overridesBySkillId`：按 `t_skills.id` 的覆盖集合，用于不同技能下采用不同表现

字段作用说明：

- `showTitleColumn`：控制标题列是否参与渲染，从而影响布局与信息密度。
- `showInCellTitle*`：控制标题文本放置方式（列标题/行标题是否在 cell 内展示），提升可读性与适配不同布局。
- `activeColorMode`：控制颜色映射策略的选择（例如纯色 vs 彩色）。
- `overridesBySkillId`：避免为不同技能复制多份模板，通过覆盖层实现差异化显示。

## 5. 数据库设计：t_card_template_skill_usage（技能使用日志）

### 5.1 设计目标

该表用于记录“某一次查询/请求（query）”在某个技能下使用了某个模板的事实，并记录最后使用时间。

核心口径：

- 不记录 `user_uuid`
- 使用自增 `id` 作为主键
- `query_uuid / template_uuid / skill_id` 仅作为普通字段
- 不记录 `use_count`
- 不记录 `first_used_at` 与 `total_use_duration_ms`
- `used_at` 存储带时区的 timestamp
- 为 `query_uuid/template_uuid/skill_id` 分别建立单列索引

### 5.2 表字段定义

表名：`t_card_template_skill_usage`

- `id`：INTEGER PRIMARY KEY AUTOINCREMENT
  - 作用：日志记录唯一标识
- `created_at`：DATETIME NOT NULL
  - 作用：记录创建时间（写入日志时生成）
- `last_updated_at`：DATETIME NOT NULL
  - 作用：记录最近更新时间（可等同 created_at；若后续允许更新同一条记录则刷新）
- `deleted_at`：DATETIME NULL
  - 作用：软删除标记，便于清理与一致性（可选，但建议与项目表风格一致）
- `query_uuid`：TEXT NOT NULL
  - 作用：关联某次查询/请求（建议对应 `t_divinations.uuid`）
- `template_uuid`：TEXT NOT NULL
  - 作用：关联被使用的模板（建议对应 `t_layout_templates.uuid`）
- `skill_id`：INTEGER NOT NULL
  - 作用：关联技能（对应 `t_skills.id`）
- `used_at`：TEXT NOT NULL
  - 作用：存储带时区的 timestamp（ISO8601/RFC3339，包含 offset）
  - 示例：`2026-01-08T10:30:00+08:00`

### 5.3 索引定义

- `INDEX(query_uuid)`
  - 作用：按查询/请求快速过滤日志
- `INDEX(template_uuid)`
  - 作用：按模板快速过滤日志
- `INDEX(skill_id)`
  - 作用：按技能快速过滤日志

说明：上述索引不作为复合 id、也不作为唯一约束，仅用于查询性能。

### 5.4 数据语义与查询方式

由于不设置唯一约束，该表是“事件日志表”：

- 每次使用模板时插入一条新记录
- 需要“最后一次使用时间”时，应通过查询聚合或排序得到

推荐查询示例（语义级）：

- 获取某 query 下某 skill 最近一次使用的模板：按 `query_uuid + skill_id` 过滤，按 `used_at` 倒序取第一条
- 获取某 template 在某段时间内被使用的记录：按 `template_uuid` 过滤，再按 `used_at` 范围筛选

### 5.5 used_at 存储口径

- 存储格式：ISO8601/RFC3339 文本，必须包含时区偏移（offset）
- 目的：保留“用户发生使用事件的本地时间语义”，避免仅存 UTC 导致审计展示需要额外还原逻辑

## 6. 验收标准（Success Criteria）

- 数据分层清晰：模板本体（CardTemplate）与设置/元信息/日志不混存。
- `t_card_template_skill_usage` 满足以下检查：
  - 主键为自增 `id`
  - `query_uuid/template_uuid/skill_id/used_at` 均存在且可写入
  - 存在 3 个单列索引：`query_uuid/template_uuid/skill_id`
  - 不存在 `use_count/first_used_at/total_use_duration_ms/user_uuid` 字段
  - `used_at` 可存储并读取带时区偏移的 timestamp

## 7. 开放问题（Open Questions）

- `query_uuid` 的来源是否统一使用 `t_divinations.uuid`（占卜记录/请求 uuid）？如未来存在独立“query”实体，是否需要改为关联新表？
- `CardTemplateMeta` 与 `CardTemplateSetting` 的持久化载体：
  - 是否以 Drift 表单独落库（推荐），还是暂时内嵌进 `template_json`？
- `deleted_at` 是否在日志表中启用：若不需要软删除，是否允许去掉以减少写入成本？
