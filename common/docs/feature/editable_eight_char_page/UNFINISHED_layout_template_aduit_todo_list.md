# TODO List：layout_template_aduit（原子化开发任务清单）

基于 [layout_template_aduit_PRDs.md](file:///Users/jingtaiwei/Git/codex/xuan/common/docs/feature/editable_eight_char_page/layout_template_aduit_PRDs.md) 的开发任务拆分。每个任务尽量原子化、可独立验收。

---

## A. 数据库：t_card_template_skill_usage（使用日志表）

### A1. 增加表定义（Drift Table）
- [x] A1.1 在 `common/lib/database/tables/tables.dart` 增加 `CardTemplateSkillUsages` 表
  - 输出：表名 `t_card_template_skill_usage`；字段包含 `id/created_at/last_updated_at/deleted_at/query_uuid/template_uuid/skill_id/used_at`
  - 验收：`build_runner` 生成无报错；表字段与 PRD 完全一致

### A2. 增加索引（单列索引）
- [x] A2.1 为 `query_uuid` 增加索引
  - 验收：生成后的 schema 含对应索引；查询按 `query_uuid` 过滤性能不退化
- [x] A2.2 为 `template_uuid` 增加索引
  - 验收：生成后的 schema 含对应索引
- [x] A2.3 为 `skill_id` 增加索引
  - 验收：生成后的 schema 含对应索引

### A3. 编写 DAO（写入与查询）
- [x] A3.1 新增 `CardTemplateSkillUsageDao.insertUsage(...)`
  - 输入：`queryUuid/templateUuid/skillId/usedAt`
  - 输出：插入一条日志记录（每次调用必插入，不做 upsert）
  - 验收：插入后可按条件查询到记录
- [x] A3.2 新增 `CardTemplateSkillUsageDao.findLatestByQueryAndSkill(...)`
  - 输出：按 `query_uuid + skill_id` 过滤，按 `used_at` 倒序取第一条
  - 验收：多条记录时返回最新一条
- [x] A3.3 新增 `CardTemplateSkillUsageDao.findByTemplate(...)`
  - 输出：按 `template_uuid` 过滤返回列表（可分页或 limit，按现有工程习惯）
  - 验收：能稳定返回、顺序明确（例如按 `used_at` desc）

### A4. used_at 写入口径（带时区 timestamp）
- [x] A4.1 统一 used_at 格式为 ISO8601/RFC3339（含 offset）
  - 输出：写入时使用 `DateTime` 的 `toIso8601String()`；读取时可 `DateTime.parse()`
  - 验收：存入 `2026-01-08T10:30:00+08:00` 这类字符串后能正确解析

### A5. 单元测试（数据库级）
- [x] A5.1 新增测试：`insertUsage` 会插入多条而非覆盖
  - 验收：同一组 `query_uuid/template_uuid/skill_id` 连续插入，记录数递增
- [x] A5.2 新增测试：`findLatestByQueryAndSkill` 返回 used_at 最新
  - 验收：构造不同 used_at 的记录，结果为最大时间那条

---

## B. 业务层：记录“模板在技能下被使用”的时机

### B1. 定义写入触发点
- [ ] B1.1 定义“何时算一次使用”的业务事件
  - 输出：明确触发点（例如：用户进入某技能的盘/卡片页面并选择模板后）
  - 验收：在代码中能找到唯一触发入口，不重复写入

### B2. 接入写入逻辑
- [ ] B2.1 在触发点调用 `insertUsage(queryUuid, templateUuid, skillId, usedAt)`
  - 验收：实际操作链路会产生写入记录

### B3. 验证与回归
- [ ] B3.1 在现有测试体系中添加集成测试或最小回归用例
  - 验收：写入不影响现有模板加载/保存/删除逻辑

---

## C. CardTemplateMeta（审计与来源追踪）

### C1. 落库方案选择并固化
- [x] C1.1 确定 Meta 的持久化载体
  - 选项：独立 Drift 表 / 写入 `template_json.meta`
  - 验收：方案落地为明确的表结构或 JSON schema，并可序列化

### C2. 若采用独立表：新增表与 DAO
- [x] C2.1 新增 `t_card_template_meta` 表（含 createdAt/modifiedAt/deletedAt/authorUuid/createFromCardUuid/isCustomized/templateUuid）
  - 验收：可按 `templateUuid` 查询到 meta；字段完整
- [x] C2.2 保存模板时同步更新 meta.modifiedAt
  - 验收：每次保存模板后 meta.modifiedAt 变更符合预期

---

## D. CardTemplateSetting（运行时覆盖层，不写回模板）

### D1. 落库方案选择并固化
- [x] D1.1 确定 Setting 的持久化载体
  - 选项：独立 Drift 表 / SharedPreferences / 写入 `editableTheme` / 写入新 JSON 字段
  - 验收：方案落地为明确的 schema，并可读写

### D2. Setting 数据模型与解析器
- [x] D2.1 定义 Setting Domain Model（含 createdAt/modifiedAt/deletedAt/showTitleColumn/showInCellTitleGlobal/showInCellTitleByRowType/activeColorMode/overridesBySkillId）
  - 验收：模型可序列化/反序列化；字段与 PRD 一致
- [x] D2.2 实现“模板合并解析器”（baseTemplate + setting.global + setting.bySkill）
  - 验收：相同模板在不同 skillId 下解析结果不同且稳定

### D3. 关键覆盖项实现（不改模板本体）
- [ ] D3.1 实现 showTitleColumn 覆盖（影响 `pillarOrder`）
  - 验收：关闭后不渲染标题列且不写回模板 JSON
- [x] D3.2 实现 showInCellTitle 覆盖（全局 + per RowType）
  - 验收：按 RowType 覆盖生效，未配置的行使用回退逻辑
- [x] D3.3 实现 activeColorMode 覆盖
  - 验收：颜色映射切换生效，不需要进入编辑页

### D4. 单元测试（解析优先级）
- [x] D4.1 添加测试：Setting.bySkill 覆盖优先于 Setting.global
  - 验收：同字段同时存在时，bySkill 生效
- [ ] D4.2 添加测试：Setting 缺省时解析结果等于原模板
  - 验收：无设置时 UI 表现不变

---

## E. 数据一致性与迁移

### E1. 数据迁移脚本/迁移策略（如需要）
- [ ] E1.1 如果新增表需要回填，定义从现有数据推导的回填规则
  - 验收：回填规则可执行且不会覆盖用户已有配置

### E2. 兼容性验证
- [ ] E2.1 旧模板数据加载与保存不受影响
  - 验收：现有 `LayoutTemplateLocalDataSource` 测试保持通过

---

## F. 交付检查清单

- [x] F1 新增/更新的数据库表与索引符合 PRD
- [x] F2 关键 DAO 与解析器都有单元测试覆盖
- [ ] F3 触发点写入日志后，核心链路无回归
- [x] F4 `used_at` 存储与解析保留时区偏移
