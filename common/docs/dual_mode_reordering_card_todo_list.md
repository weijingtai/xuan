# 双模式排序卡片 - 任务清单

本文档用于追踪实现“行/列”双模式拖拽排序功能的开发过程。

## 任务分解

- [x] **1. 在 `InteractiveFourZhuCard` 中引入“模式切换”管理:**
  - [x] 在 `_InteractiveFourZhuCardState` 中，添加一个新的布尔值状态变量 `bool _isColumnMode = false;`。
  - [x] 在UI上（例如，在底部的选项区域旁边），添加一个 `IconButton` 或类似的可点击组件，用于切换 `_isColumnMode` 的状态。

- [x] **2. 重命名现有的 `EightCharsCard`:**
  - [x] 为了更清晰地区分功能，将现有的 `eight_chars_card.dart` 文件重命名为 `row_reorderable_card.dart`。(注意: 旧文件 `eight_chars_card.dart` 需要手动删除)
  - [x] 将文件内的 `EightCharsCard` 类名同步修改为 `RowReorderableCard`。
  - [x] 更新 `interactive_four_zhu_card.dart` 中对它的引用。

- [x] **3. 创建全新的“列排序”卡片 (`ColumnReorderableCard`):**
  - [x] 创建一个新文件 `lib/widgets/column_reorderable_card.dart`。
  - [x] 在新文件中，创建一个名为 `ColumnReorderableCard` 的无状态组件 (`StatelessWidget`)。
  - [x] 为其定义所需参数：`title`, `pillars` (Map), `pillarOrder` (List), 和 `onPillarReorder` 回调函数。
  - [x] 其 `build` 方法的核心将是一个**水平方向**的 `ReorderableListView`。
  - [x] `ReorderableListView` 的 `children` 将是代表每一“柱”的 `Column` 组件。
  - [x] 创建一个辅助方法 `_buildPillarColumn`，该方法接收一个“柱”的标识符（如“年”），并返回一个包含该柱所有信息（干、支、纳音等）的 `Column` Widget。

- [x] **4. 在 `InteractiveFourZhuCard` 中实现 `Stack` 叠加布局:**
  - [x] 在其 `build` 方法中，将原有的 `Row` 布局修改为 `Row` of `Stack`s。即，“本命”和“流运”区域现在各是一个 `Stack`。
  - [x] 在每个 `Stack` 中，同时放入一个 `RowReorderableCard` 和一个 `ColumnReorderableCard`。
  - [x] 使用 `Visibility` 或 `IgnorePointer` 组件，根据 `_isColumnMode` 标志的状态，来精确控制哪个卡片可见、哪个卡片隐藏并忽略交互。

- [x] **5. 连接状态与属性:**
  - [x] 确保在 `build` 方法中，根据当前的排序模式，将正确的状态（`_rowOrder` 或 `_pillarOrder`）和回调函数传递给对应的卡片（`RowReorderableCard` 或 `ColumnReorderableCard`）。

- [x] **6. 最终审查与清理:**
  - [x] 全面审查所有修改过的文件，确保两种模式的拖拽功能都符合预期。
  - [x] 移除所有不再需要的代码、变量或导入。
