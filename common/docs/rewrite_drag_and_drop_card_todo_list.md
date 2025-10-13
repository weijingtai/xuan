# EightCharsCard 重写计划 - 任务清单

本文档用于追踪使用 `ReorderableListView` 重写 `EightCharsCard` 拖拽功能的实现过程。

## 任务分解

- [x] **1. 重写 `EightCharsCard` 的 `build` 方法:**
  - [x] 移除 `drag_and_drop_lists` 的 `import`。
  - [x] 在 `build` 方法中，用 `ReorderableListView` 替换 `Flexible` 和 `DragAndDropLists` 组件。
  - [x] 为 `ReorderableListView` 设置 `shrinkWrap: true` 和 `physics: const NeverScrollableScrollPhysics()`。
  - [x] 将 `rowOrder` 列表映射为 `ReorderableListView` 的 `children`，并确保每个子组件都有唯一的 `ValueKey`。
  - [x] 连接 `onReorder` 回调函数。

- [x] **2. 验证 `InteractiveFourZhuCard`:**
  - [x] 确认父组件 `InteractiveFourZhuCard` 无需修改，其现有的状态管理逻辑能与新的 `EightCharsCard` 无缝对接。

- [x] **3. 最终清理:**
  - [x] 移除 `eight_chars_card.dart` 中用于调试的背景色。
  - [x] **提醒用户**: 从 `pubspec.yaml` 中移除 `drag_and_drop_lists` 依赖。
  - [x] 对代码进行最终审查，确保整洁、无误。
