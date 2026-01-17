# PRDs：Shared Card Template（主题市场 / 上传下载 / 二次创作）

## 1. 背景
当前本地已具备模板能力：
- 模板本体：LayoutTemplate 序列化 JSON，存于 `t_layout_templates.template_json`（可编辑）。
- 模板元信息：`t_card_template_meta`（createdAt/modifiedAt/authorUuid/createFromCardUuid/isCustomized）。
- 运行时设置覆盖：`t_card_template_setting`（不改模板本体，仅影响显示/颜色等）。
- 使用日志：`t_card_template_skill_usage`（按 query/skill 维度记录使用事件）。

希望新增“主题市场”：
- 用户可将本地模板发布到市场；
- 其他用户可浏览、下载到自己的数据空间并二次编辑后再发布；
- App 初期有系统默认主题，填补冷启动。

## 2. 目标（Goals）
G1. 市场分发：浏览/搜索/下载主题到本地（可编辑草稿）。
G2. 发布：用户可将本地模板发布到市场（生成版本化发布物）。
G3. 二次创作：用户从市场安装后进行二次设计，并可再次发布（fork/remix）。
G4. 冷启动：支持系统内置主题与市场主题并存，展示口径清晰。
G5. 不影响现有编辑器：EditableFourZhuCard 的编辑/渲染/保存链路不破坏，不修改模板 JSON schema。

## 3. 非目标（Out of Scope）
- 多设备同步的“复杂冲突解决/合并编辑体验”（当前以 LWW 为主，后续可增强冲突提示与回滚）。
- 付费、订阅、分账等商业化。
- 完整审核后台（先预留举报/下架能力）。

## 4. 术语定义
- 本地模板（Local Template）：用户数据空间内可编辑的 LayoutTemplate（`t_layout_templates`）。
- 市场条目（Market Template）：一个作品条目（标题、作者、封面、标签等）。
- 市场版本（Market Version）：一次发布产生的不可变版本快照，包含 template_json。
- 安装（Install）：从市场版本快照生成一个新的本地模板 + 记录来源映射。

## 5. 产品与用户故事
### 5.1 浏览与安装
- US1：用户进入“主题市场”，看到列表（官方/热门/最新，首版只做最新）。
- US2：用户进入详情页，预览主题，查看作者/描述/版本信息。
- US3：用户点击“下载到我的主题”，生成新的本地模板并可进入编辑器二次编辑。

### 5.2 二次创作与再次发布
- US4：用户编辑已安装模板并保存为本地模板。
- US5：用户在编辑器中点击“发布到市场”，填写标题/描述/标签/封面并发布。
- US6：非原作者发布视为派生作品（fork/remix），展示“派生自 X”。

### 5.3 冷启动与系统模板
- US7：应用预置系统主题（本地可用，也可在市场展示为官方主题）。
- US8：系统/用户自建/市场安装三者在“我的主题”中可区分（来源清晰）。

## 6. 数据与模型设计
### 6.1 本地数据库（增量扩展，不改现有表语义）
保持不变：
- `t_layout_templates`：本地模板本体（可编辑，编辑器唯一读写来源）。
- `t_card_template_meta`：本地审计与本地派生信息（只表达本地 lineage）。
- `t_card_template_setting`：运行时设置覆盖层。
- `t_card_template_skill_usage`：使用日志。

新增：
- `t_market_template_installs`
  - local_template_uuid TEXT PRIMARY KEY：对应 `t_layout_templates.uuid`
  - market_template_id TEXT NOT NULL
  - market_version_id TEXT NOT NULL
  - installed_at DATETIME NOT NULL
  - pinned_at DATETIME NULL：锁定版本，不提示更新
  - last_checked_at DATETIME NULL：用于更新提示
  - deleted_at DATETIME NULL：软删除（与项目现有表风格一致）
  - indexes：market_template_id、market_version_id

约束：
- 不允许市场 payload 直接覆盖本地模板 uuid：安装时必须生成新 uuid，避免冲突。

### 6.2 远端市场服务（服务端模型）
- market_templates（条目）
  - id, owner_user_id
  - title, description, cover_url
  - tags（或 tag 表）
  - status：published/hidden/takedown
  - derived_from_version_id（可空）
  - created_at, updated_at

- market_template_versions（版本发布物，不可变）
  - id, market_template_id
  - version（semver 或自增）
  - schema_version（对应 LayoutTemplate.version 或独立 schema）
  - template_json（快照）
  - published_at
  - （可选）hash_sha256、size_bytes（建议由服务端计算，App 首版不引入 crypto 依赖）

## 7. API（App ↔ Market Service）
### 7.1 列表/详情
- GET /market/templates?sort=new&cursor=...&limit=...
- GET /market/templates/{market_template_id}
- GET /market/templates/{market_template_id}/versions?limit=...

### 7.2 下载/安装
- GET /market/versions/{version_id}/payload
  - 返回：template_json、schema_version、published_at、author信息等

App 安装流程：
1) 拉取 version payload
2) 生成 new local_template_uuid
3) 写入 `t_layout_templates`（template_json）
4) 写入 `t_card_template_meta`（本地 created/modified；本地派生可选）
5) 写入 `t_market_template_installs`（market_template_id + version_id）
6) 入队 outbox（entityType=layout_template, opType=upsert, scopeUid=当前用户 uid），由 SyncRuntime 推送到远端

多端同步说明（用户数据空间）：
- 写入路径：`users/{scopeUid}/modules/common/layout_templates/{entityId}`（Realtime Database）
- 同步机制：本地落库后写入 outbox，SyncRuntime 自动 push；其他设备 pull 回填本地后，编辑器列表自动刷新
- 前置条件：用户已登录且同步运行时启用（未登录仅本地可用，待登录后再同步）

### 7.3 发布
- POST /market/templates（创建条目）
- POST /market/templates/{id}/versions（发布新版本）
  - 入参：title/description/tags/cover_url（可选）、template_json、schema_version
  - hash/size_bytes：首版由服务端计算并返回

权限：
- 仅 owner 可为同一 market_template 发布新版本；
- 非 owner 发布时：创建新条目，并记录 derived_from_version_id。

## 8. UI（最小可用）
- 主题市场列表页（最新）
- 主题详情页（版本、作者、描述、下载按钮、预览）
- 发布页（从编辑器入口进入）
- 我的主题列表增强：来源标签 + 已安装版本信息展示（可后置做更新提示）

## 9. 迁移与兼容
- Drift schemaVersion +1，仅新增表，不改原表字段，风险最小。
- 旧模板无 installs 记录则视为“用户/系统模板”。

## 10. 验收标准
- AC1：市场列表与详情页可拉取数据并展示。
- AC2：下载后本地新增模板，可在编辑器打开并保存，渲染无回归。
- AC3：发布成功后市场可见，可被其他账号下载并编辑。
- AC4：系统/用户/市场来源可区分展示（不依赖 isCustomized 三态）。
- AC5：EditableFourZhuCard 编辑/保存/setting overlay/使用日志功能无回归。
- AC6：用户下载/安装市场模板后，会同步写入用户远端数据；同一账号在另一设备 pull 后可看到该模板。
