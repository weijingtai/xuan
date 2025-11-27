## 现状梳理
- 底部 Tag：在页面 `four_zhu_edit_page.dart:146–175` 使用 `PillarTagBar` 作为可拖拽入口；Demo 中还有更丰富的 `FourZhuAddPalette`（lib/widgets/four_zhu_add_palette.dart）。
- 柱样式编辑面板：`four_zhu_pillar_style_editor_panel.dart` 已具备柱的 margin/padding/border/background/shadow 的编辑能力，并能通过 Demo VM 进行主题更新（117 行）。
- V3 卡片拖拽接入点：`editable_fourzhu_card_impl.dart:900–980` 已支持列/行层面的 DragTarget，能够接收外部拖拽添加列与行。

## 目标
- 在 EditorWorkspace 下方打造一个统一的“柱工具栏 Dock”，融合：
  - 左侧：可拖拽插入 Tag（年/月/日/时/分隔符/大运柱、行分隔/空亡行等）
  - 右侧：柱样式编辑面板的精简版（或折叠抽屉）
- 交互需美观、紧凑与高效：芯片式标签 + 分组面板，Material3 风格，保持页面一致性。

## 设计与布局
- 组件：新增 `EditorWorkspaceBottomDock`（内部横向 Row，左拖拽区 + 右编辑区）。
- 左拖拽区：
  - 统一使用 `FourZhuAddPalette` 的 Chip 组；并补充四个柱标签（年/月/日/时）以支持直接拖拽添加对应数据柱。
  - 样式：`surfaceContainerHigh` 背景、8px 圆角、细分隔线、Wrap 布局；Tag 内含 `drag_indicator` 图标。
- 右编辑区：
  - 嵌入 `FourZhuPillarStyleEditorPanel` 的精简版：只保留默认 margin/padding、边框宽度/颜色/圆角、背景色、阴影开关与核心参数；其余高级参数可折叠。
  - 以 `ExpansionTile` 或自定义折叠面板承载；窄宽度适配 320px，保证不拥挤。

## 数据与状态流
- 拖拽：
  - Tag 侧 `Draggable<PillarType | RowType | Payload>` → V3 卡 DragTarget 接收并计算插入索引（editable_fourzhu_card_impl.dart:935 起）；插入逻辑沿用现有。
- 样式：
  - 右侧面板使用 `Consumer<FourZhuEditorViewModel>` 读取并更新柱样式（沿用 `EditableFourZhuThemeController` 的解析规则），将默认柱样式映射到 V3 的 `pillarMargin/padding/borderWidth/color/radius/bg/shadow`。
  - 为 EditorWorkspace 增加一层适配：把面板变更转成 ViewModel 的接口调用，或直接沿用现有 Demo VM 的主题控制器方案，再由工作区统一绑定（目前 EditorWorkspace 已绑定 `themeController.resolve*` 用于 Card 装饰）。

## 接入点与代码变更
- EditorWorkspace：
  - 在卡片下方新增 `EditorWorkspaceBottomDock`；通过 Provider 取所需 VM。
  - 将 `FourZhuAddPalette` 作为左侧拖拽入口；如需补充年/月/日/时 Tag，可在 `FourZhuAddPalette` 增加四个 Chip 的 Draggable（数据为对应 `PillarPayload`）。
- four_zhu_pillar_style_editor_panel.dart：
  - 增加 `onChanged` 回调（已注释 23 行），并在内部统一通过该回调或 ViewModel 的方法进行主题更新（现有 `_emit(...)` 已写 Demo VM，可抽象成可配置回调）。
  - 提供一个 `compact` 构造参数，以精简显示（隐藏次要控件、折叠高级组）。
- 统一样式：
  - Dock 外层容器：`surfaceContainerHighest` 背景 + 8px 圆角 + 内部 12px padding，保持与 Sidebar 面板一致的视觉。

## 美化细节
- Tag 芯片：
  - icon+文本、强调色区分（分隔符用红/橙；行操作用蓝）、悬停与拖拽态透明度变化。
- 面板：
  - 分组标题统一 `titleMedium`，控件之间 8px/12px 的垂直间距；滑块右侧显示当前值；颜色选择器使用固定 22px 预览方块。

## 验收项
- 拖拽：从 Dock 左侧将 Tag 拖拽到卡片，列/行正确插入，卡尺寸与布局随之更新。
- 编辑：在右侧面板调整默认柱样式，V3 卡柱的 margin/padding/border/background/shadow 等即时生效。
- 视觉：布局紧凑、边距合理、颜色与圆角与整页风格一致。

## 风险与回滚
- 风险：两套 VM（Demo 与 Editor）的主题控制器并存；建议统一走 `FourZhuEditorViewModel` 的样式接口，避免混用。
- 回滚：若集成面板产生冲突，可退回到仅左侧拖拽 Dock 的版本，样式仍由 Sidebar 或 Demo 页控制。

## 里程碑
1. 新增 Dock 组件与布局接入到 EditorWorkspace
2. 扩展 `FourZhuAddPalette` 增加四柱 Tag（或在 Dock 内补齐）
3. 将 `four_zhu_pillar_style_editor_panel.dart` 以紧凑模式嵌入 Dock，打通 `onChanged`
4. 统一样式主题与 Provider 数据源
5. 验证拖拽与样式更新，微调 UI 细节