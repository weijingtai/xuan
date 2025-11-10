# 阶段1：Align（需求对齐）

## 原始需求
- 在卡片样式编辑页面中，侧边栏（Sidebar）编辑内容后无法改变 EditorWorkspace 内的 V3 卡片显示效果。

## 项目与任务特性规范
- 技术栈：Flutter（Web/Desktop/Mobile），状态管理使用 Provider。
- 相关模块：
  - `common/lib/pages/four_zhu_edit_page.dart`（编辑页装配，Sidebar 与 Workspace 并排）。
  - `common/lib/widgets/editor_sidebar_v2.dart`（侧边栏，连接 `FourZhuEditorViewModel`）。
  - `common/lib/widgets/style_editor/theme_edit_preview_sidebar.dart`（侧栏主题编辑器，已将排版相关更新写入 ViewModel）。
  - `common/lib/viewmodels/four_zhu_editor_view_model.dart`（模板与样式状态源）。
  - `common/lib/widgets/four_zhu_card_editor_page/editor_workspace.dart`（工作区，承载 `EditableFourZhuCardV3`）。
  - `common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart`（V3 卡片组件）。

## 需求理解
- 侧栏通过 `FourZhuEditorViewModel` 更新排版（全局字体家族/字号/颜色）与行配置（可见性、标题可见性）。
- `EditorWorkspace` 当前仅使用本地 `ValueNotifier` 与默认行，不读取 `FourZhuEditorViewModel`，因此侧栏编辑不会影响工作区的 V3 卡片。
- 目标是让 `EditorWorkspace` 订阅 ViewModel，并将其变更映射到 `EditableFourZhuCardV3`。

## 边界确认（任务范围）
- 本次联动仅实现：
  - 将 ViewModel 的全局排版（字体家族、字号、颜色）传入 V3 卡片；
  - 将 ViewModel 的 `rowConfigs` 映射为工作区的行列表（含标题隐藏处理）。
- 不涉及：
  - 复杂主题（卡片圆角、阴影、背景、柱边距等）的完整同步；
  - 数据持久化层改动；
  - 新增行类型的算法实现。

## 疑问澄清
1. 是否需要把卡片的装饰（背景色、边框、圆角）也完全跟随侧栏主题？当前侧栏仅同步了排版，若需要请进一步确认。
2. `rowConfigs` 中的行类型覆盖是否与 V3 卡片完全一致？如存在暂不支持的行类型，将保持向后兼容并忽略。

## 智能决策
- 依据现有代码结构，采用最小改动策略：在 `EditorWorkspace` 中订阅 ViewModel 并更新传入 V3 的属性与行列表。
- 通过 `ValueNotifier.value = ...` 在构建过程中刷新 V3 卡片，避免重构更大的数据流。

## 验收草案
- 在侧栏调整全局字体家族/字号/颜色后，工作区 V3 卡片即时更新对应文本样式。
- 在侧栏切换行的可见性或标题可见性后，工作区 V3 卡片的对应行显示/隐藏、标题显示/隐藏正确。