## 布局风格
- 采用 VS Code 资源管理器样式的“分区+折叠”布局，而非 TabBar/TabView。
- 左侧 Sidebar 由四个可折叠分区组成：
  - 卡片样式
  - 行样式
  - 柱样式
  - 单元格样式
- 每个分区可独立展开/折叠；分区内容内部单独滚动，侧栏整体也可滚动，避免溢出。

## 组件结构
- 新建 `SidebarExplorer` 组件（容器）：
  - 使用 `ListView` + `ExpansionTile`（或 `ExpansionPanelList`）实现分区折叠。
  - 分区标题行左侧放置图标（如 `Icons.style`、`Icons.view_list`、`Icons.view_column`、`Icons.grid_on`），右侧放置“更多”菜单（`PopupMenuButton`）。
- 分区内容：
  - 卡片样式：复用 `EditableFourZhuStyleEditorPanel`
  - 行样式：新增 `RowStyleEditorPanel`（驱动 `FourZhuEditorViewModel.updateRowStyle/updateRowVisibility/updateRowTitleVisibility/reorderRowConfig`）
  - 柱样式：复用 `FourZhuPillarStyleEditorPanel`
  - 单元格样式：新增 `CellStyleEditorPanel`（当有选中单元格时显示编辑；无选中则显示提示）

## 状态与联动
- Provider 保持不变：
  - `FourZhuEditorViewModel` 用于行/单元格操作
  - `FourZhuCardDemoViewModel.themeController` 仍用于卡/柱装饰解析（已在 EditorWorkspace 绑定）
- 分区展开状态：
  - 本地 `ValueNotifier<Set<String>>` 保存展开的分区 id；可选持久化（`SharedPreferences`）
- 单元格选中：
  - 在 V3 卡中点击/双击时调用 `FourZhuEditorViewModel.selectCell(rowIndex, colIndex, type)`；面板读取 `selectedCell` 并显示样式编辑

## 视觉与细节
- 容器样式：`surfaceContainerHigh` 背景、8px 圆角、内边距 12px、分区间 `Divider`。
- 分区标题：`titleMedium`；图标 + 文本；右侧菜单支持“全部折叠/展开、重置样式”等。
- 可滚动策略：
  - 侧栏整体 `SingleChildScrollView`
  - 分区内容内部使用 `ListView(shrinkWrap: true)` 或 `Column` 包裹

## 接入位置
- 在 `common/lib/pages/four_zhu_edit_page.dart` 左侧 Sidebar 替换为 `SidebarExplorer`，保持现有容器与宽度约束。

## 原子待办
- 创建 `SidebarExplorer`（折叠分区容器）
- 接入 `EditableFourZhuStyleEditorPanel` 到“卡片样式”分区
- 新建 `RowStyleEditorPanel` 并接入 ViewModel 方法
- 接入 `FourZhuPillarStyleEditorPanel` 到“柱样式”分区
- 新建 `CellStyleEditorPanel` 并打通选中单元格状态
- 侧栏滚动与分区内部滚动处理
- 分区展开状态保存与恢复
- 左侧容器样式与分区标题的图标/菜单
- 验证与微调（无溢出、联动正常）

## 兼容性
- 不改动 V3 尺寸模型与监听链路（`CardLayoutModel.computeSize`、`_computeSizeWithDecorations`、各 Notifier）。
- 分区面板仅改变展现与交互组织方式，不改变现有编辑逻辑与 Provider 数据源。

## 交付与验证
- 完成侧栏替换后，验证四分区编辑对卡片的联动；在窄视口下，侧栏与分区内容出现滚动而不溢出；EditorWorkspace 与底部 Dock 保持现状。