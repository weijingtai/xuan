# 四柱列排序功能 - 任务清单

本文档用于追踪实现“四柱”列（Pillars）水平拖拽排序功能的开发过程。

## 任务分解

- [x] **1. 在 `InteractiveFourZhuCard` 中更新状态管理:**
  - [x] 在 `_InteractiveFourZhuCardState` 中，添加 `_benMingPillarOrder` 和 `_liuYunPillarOrder` 两个 `List<String>` 状态变量。
  - [x] 添加一个 `_savePillarOrder()` 的空方法作为持久化接口占位符。
  - [x] 在 `initState` 方法中，用默认顺序 (`['年', '月', '日', '时']`) 初始化这两个列表。
  - [x] 在 `build` 方法中，根据新的 `pillarOrder` 列表来构建 `pillars` 和 `yunPillars` 这两个 `Map`，以确保其键的顺序是正确的。

- [x] **2. 更新 `EightCharsCard` 的公共API:**
  - [x] 在其构造函数中，添加 `required final List<String> pillarOrder` 参数。
  - [x] 在其构造函数中，添加 `required final Function(int oldIndex, int newIndex) onPillarReorder` 回调参数。

- [x] **3. 重构 `EightCharsCard` 中的 `_buildPillarHeaderRow` 方法:**
  - [x] 完全重写此方法，使其不再使用 `Stack` 和 `AnimatedPositioned`。
  - [x] 新方法将构建一个 `Row` 组件。
  - [x] `Row` 的子组件将通过遍历 `pillarOrder` 列表来动态生成。
  - [x] 每一个子组件都是一个 `DragTarget`，其内部包裹着一个 `LongPressDraggable`。
  - [x] `LongPressDraggable` 内部是显示“年”、“月”等文本的 `Text` 组件。
  - [x] 在 `DragTarget` 的 `onAccept` 回调中，计算出拖拽项的原始位置和目标位置，然后调用 `onPillarReorder` 回调函数通知父组件。

- [x] **4. 连接父子组件:**
  - [x] 在 `InteractiveFourZhuCard` 的 `build` 方法中，将 `pillarOrder` 列表和 `onPillarReorder` 回调函数传递给两个 `EightCharsCard` 实例。
  - [x] `onPillarReorder` 回调函数需要调用 `setState`，更新对应的 `pillarOrder` 列表状态，并调用 `_savePillarOrder()`。

- [x] **5. 最终审查:**
  - [x] 确保拖拽排序功能符合预期。
  - [x] 检查并移除所有不再使用的代码。
