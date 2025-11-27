## 问题诊断
- 出现两排柱标签（年柱/月柱/日柱/时柱），以及黄色斜纹“BOTTOM OVERFLOW”警告，说明当前页面垂直空间超出约束。
- 造成原因：
  - 在 `FourZhuEditPage` 已有一条 `PillarTagBar`（146 行附近），我又在 `EditorWorkspace` 内新增了一条，导致重复与垂直空间叠加。
  - `EditorWorkspace` 内的底部 Dock 使用 `Row + SizedBox(width: 320)` 固定宽度，未做纵向滚动与收缩处理，易在窄视口或内容较多时溢出。

## 调整目标
- 保留页面底部唯一的拖拽标签栏；将样式面板与标签栏有机结合，避免重复。
- 保证在不同窗口高度下无溢出：支持可滚动、合理的高度分割与伸缩布局。
- 提升观感：一致的 Material3 视觉、合理留白与分组标题对齐。

## 实施方案
1. 移除 `EditorWorkspace` 内的 `PillarTagBar`，仅保留 `FourZhuEditPage` 的底部标签栏（避免重复）。
2. 将“柱样式编辑面板”移出 `EditorWorkspace`，嵌入 `FourZhuEditPage` 的底部区域，与现有按钮区并列：
   - 在底部容器内使用 `Row`，左侧为 `PillarTagBar`（扩展为横向滚动 `SingleChildScrollView` + `Wrap`），右侧为 `FourZhuPillarStyleEditorPanel`（限制宽度为 320px，内部再用 `SingleChildScrollView` 纵向滚动）。
   - 外层容器采用 `surfaceContainerHighest` 背景 + 8px 圆角 + 12px 内边距 + 细边框。
3. 为样式面板增加 `compact` 构造参数（默认 true），隐藏次要控件，仅保留：
   - 默认外边距（水平/垂直）与内边距（水平/垂直）
   - 边框（无边框开关、粗细、颜色、圆角）
   - 背景色
   - 阴影（启用开关、颜色、偏移、模糊、扩散、透明度）
   面板内部使用 `ListView(shrinkWrap: true)` 或 `SingleChildScrollView`，并在卡片背景上做统一间距。
4. 卡片区域与底部 Dock 的关系：
   - 上方使用 `Expanded` 挂载 V3 卡片，确保卡片区占满剩余空间。
   - 下方 Dock 使用自然高度（不 Expanded），在视口变小时面板自动出现滚动条，以避免溢出。
5. 统一 Provider 数据源：
   - Dock 中的面板仍使用 Demo VM 的 `themeController` 做解析（当前页面联动已打通），后续可迁移到 `FourZhuEditorViewModel`。

## 验收标准
- 页面底部仅出现一条柱标签栏；无黄色溢出警告。
- 调整柱样式参数时，V3 卡柱的样式即时联动；拖拽柱标签插入列/行正常。
- 在窄视口或较多内容下，底部 Dock 与面板可滚动，整体布局保持美观。

## 里程碑
- Phase 1：移除 `EditorWorkspace` 的标签栏，面板迁移至 `FourZhuEditPage` 底部区域。
- Phase 2：加入 `compact` 面板模式与滚动布局；美化容器样式与间距。
- Phase 3：联动验证与视觉微调。