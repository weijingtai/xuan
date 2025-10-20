# EightCharsCard 可拖拽排序功能 - 任务清单

本文档用于追踪 `EightCharsCard` 组件行拖拽排序功能的实现过程。

## 任务分解

- [x] **1. 创建 `_CardRow` 字符串常量:**
  - [x] 在 `eight_chars_card.dart` 文件中，创建一个 `_CardRow` 类，用于存放代表每一行类型的 `String` 常量 (例如 `pillarHeader`, `tianGan` 等)。

- [x] **2. 将 `EightCharsCard` 重构为无状态组件 (`StatelessWidget`):**
  - [x] 将 `EightCharsCard` 的继承从 `StatefulWidget` 改为 `StatelessWidget`。
  - [x] 移除其内部的 `State` 类。
  - [x] 在其构造函数中，添加 `required final List<String> rowOrder` 参数。
  - [x] 在其构造函数中，添加 `required final Function(int oldIndex, int newIndex) onReorder` 回调参数。
  - [x] 移除原有的 `showXunShou`, `showNaYin`, `showKongWang` 等布尔值参数。

- [x] **3. 在 `EightCharsCard` 中实现行构建逻辑:**
  - [x] 将原有的行构建逻辑（目前在 `build` 方法内）提取到 `EightCharsCard` 的私有方法中 (例如 `_buildPillarHeaderRow`, `_buildTianGanRow`)。
  - [x] 创建一个调度方法 `_buildRow(BuildContext context, String rowType)`，它能根据传入的字符串类型返回正确的行 Widget。

- [x] **4. 实现 `EightCharsCard` 的 `build()` 方法:**
  - [x] 使用 `DragAndDropLists` 组件来展示从 `rowOrder` 属性传入的行列表。
  - [x] 在 `DragAndDropLists` 的 `onItemReorder` 回调中，调用 `onReorder` 属性，将事件通知给父组件。
  - [x] 配置 `DragAndDropLists` 的样式，使其与卡片设计无缝集成。

- [x] **5. 在 `InteractiveFourZhuCard` 中管理状态:**
  - [x] 在 `_InteractiveFourZhuCardState` 中，添加 `late List<String> _benMingRowOrder;` 和 `late List<String> _liuYunRowOrder;` 状态变量。
  - [x] 在 `initState` 方法中，为这两个列表设置默认的初始顺序。
  - [x] 添加 `_saveOrder()` 和 `_loadOrder()` 的空方法作为持久化接口的占位符。

- [x] **6. 更新 `InteractiveFourZhuCard` 中的逻辑:**
  - [x] 修改底部 `FilterChip` 选项的 `onSelected` 回调。当选项被切换时，在 `_benMingRowOrder` 列表中添加或移除对应的行标识符，并调用 `_saveOrder()`。

- [x] **7. 在 `InteractiveFourZhuCard` 的 `build()` 方法中连接父子组件:**
  - [x] 将 `_benMingRowOrder` 和 `_liuYunRowOrder` 分别传递给两个 `EightCharsCard` 实例的 `rowOrder` 参数。
  - [x] 为每个卡片提供 `onReorder` 回调。此回调需要调用 `setState`，更新正确的顺序列表 (`_benMingRowOrder` 或 `_liuYunRowOrder`)，并触发保存逻辑。

- [x] **8. 最终清理:**
  - [x] 检查 `eight_chars_card.dart` 和 `interactive_four_zhu_card.dart` 两个文件，移除所有未使用的变量、导入或方法。
  - [x] 确保最终实现的功能整洁、无误，并符合预期。
