# ALIGNMENT_重构四柱卡片样式编辑器

## 原始需求
将 `editable_four_zhu_style_editor_panel.dart` 从 `setState` 模式迁移到 `ValueListenableBuilder` + 数据类架构

## 边界确认
- ✅ 只重构 UI 更新逻辑，不改变功能
- ✅ 使用现有的 `CardShadow`、`CardBorder`、`CardStyleConfig` 数据类
- ✅ 保持与父组件的回调接口不变
- ✅ 确保性能提升和代码可维护性

## 需求理解
### 当前问题分析
1. **性能问题**: 每次 `setState` 都会重建整个 UI
2. **代码重复**: 多个 `_emit` 调用和状态同步逻辑
3. **耦合度高**: UI 控件与状态管理紧密耦合

### 技术约束
- 必须使用现有的数据类结构
- 必须保持与 `EditableFourZhuCardTheme` 的兼容性
- 必须支持实时回调到父组件

## 疑问澄清
1. **转换方法需求**: 需要创建 `EditableFourZhuCardTheme` ↔ `CardStyleConfig` 的转换方法
2. **字段映射确认**: 需要验证所有样式字段的完整映射
3. **回调机制**: 确保新的架构仍能正确触发 `onStyleChanged` 回调

## 现有项目分析
### 技术栈
- Flutter 框架
- 现有数据类: `CardShadow`, `CardBorder`, `CardStyleConfig`
- 状态管理: 计划迁移到 `ValueNotifier` + `ValueListenableBuilder`

### 架构模式
从 MVC 的 setState 模式迁移到响应式数据流架构

## 验收标准
1. ✅ 功能完整性: 所有编辑功能正常工作
2. ✅ 性能提升: 实现细粒度 UI 重建
3. ✅ 代码质量: 减少重复代码，提高可维护性
4. ✅ 兼容性: 与现有父组件接口完全兼容