# Eight Chars Template PRD

## Background
Bazi 卡牌编辑器是天机阁核心体验，允许用户以模块化方式定制排盘卡片。现阶段需提供结构化模板编辑能力，并在开发阶段通过 SharedPreferences 持久化，后续将迁移至 Drift。

## Objectives
- 让编辑界面基于 MVVM 流程加载、保存、删除布局模板。
- 保持 Domain 层与数据实现解耦，确保未来可替换为 Drift 或远端数据源。
- 在开发阶段提供稳定的 SharedPreferences 适配层，保证多次会话模板状态一致。

## Scope
- 定义 `LayoutTemplateRepository` 接口及相关模型 DTO/mapper。
- 交付 SharedPreferences 版 `LocalLayoutTemplateDataSource` 与 Repository 装饰器。
- 更新 `CardEditorViewModel` 以接入 Use Case 流程，并暴露分隔线、柱位、行配置等编辑方法。
- 不包含 Drift schema、同步功能、多用户协作或版本对比。

## Architecture Notes
- 模型层以不可变对象实现：`LayoutTemplate`、`ChartGroup`、`CardStyle`、`RowConfig`。
- Repository 仅依赖抽象 datasource；Use Case（`GetAllTemplatesUseCase`、`SaveTemplateUseCase`、`DeleteTemplateUseCase`）负责业务校验（如名称非空）。
- ViewModel 继承 `ChangeNotifier`，通过 `copyWith` 写入新状态并触发 `notifyListeners()`；UI 使用 `Selector`/`context.select` 减少重绘。

## Data & Persistence
- SharedPreferences 键命名：`layout_templates:<collectionId>`；值为 JSON 数组。
- DTO 层维护 `version` 与 `updatedAt` 字段，便于未来 Drift 迁移与冲突检测。
- 保存流程需乐观验证（例如比较 `hasUnsavedChanges` 或本地版本号），避免并发覆盖。

## Success Metrics
- 模板在冷启动后加载成功率 100%。
- UI 操作（排序、可见性切换、保存/加载/删除）响应 < 200 ms。
- 单元测试覆盖 encode/decode、Use Case 校验及 ViewModel 关键分支。

## 实施记录（2025-10-17）
- SharedPreferences 仍作为过渡存储，`LayoutTemplateLocalDataSource` 使用键 `layout_templates:<collectionId>` 序列化模板 JSON，Repository 在保存时自动递增 `version` 并刷新 `updatedAt`。
- 新增单元测试：`test/datasource/layout_template_local_data_source_test.dart` 验证加载、持久化与清除逻辑，`test/viewmodels/four_zhu_editor_view_model_test.dart` 覆盖初始化、编辑保存、复制、删除及行显隐流程。
- 迁移 Drift 前需保持 DTO 中 `version`、`updatedAt` 字段同步；迁移时先导入 SharedPreferences 现有 JSON，再执行版本比对以避免覆盖用户模板。

