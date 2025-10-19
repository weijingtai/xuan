# [已过时] 统一卡片架构 - 任务清单

**注意：此文档描述的是一个早期的重构计划，现已被 `eight_char_card_todo_list.md` 中描述的 MVVM 架构所取代。**

---

# 统一卡片架构 - 任务清单

本文档用于追踪实现“统一外观、无感切换”的最终卡片架构。

## 任务分解

- [x] **1. 创建共享视图构建器 `EightCharsCardViewBuilder`:**
  - [x] 创建新文件 `lib/widgets/eight_chars_card_builder.dart`。
  - [x] 在文件中创建一个名为 `EightCharsCardViewBuilder` 的普通Dart类。
  - [x] 将所有用于构建“行”UI的辅助方法（如 `buildPillarHeaderRow`, `buildTianGanRow` 等）从旧的卡片组件中迁移到这个类里，并改为 `static` 方法。
  - [x] 确保这些方法是公开的，并接收所有必要的参数（`BuildContext`, `pillars`, `pillarOrder` 等）。

- [x] **2. 创建“外壳”组件 `EightCharsCard`:**
  - [x] 创建或重命名文件为 `lib/widgets/eight_chars_card.dart`。
  - [x] 创建一个名为 `EightCharsCard` 的无状态组件 (`StatelessWidget`)。
  - [x] 它将只包含 `title` 和 `child` 两个属性。
  - [x] 其 `build` 方法只负责渲染卡片的通用“外壳”（背景、边框、阴影、标题），然后将 `child` 渲染在其中。

- [x] **3. 重构 `EightCharsCardV3` 为“状态控制器”:**
  - [x] 将 `interactive_four_zhu_card.dart` 文件重命名为 `eight_chars_card_v3.dart`。(注意: 旧文件 `interactive_four_zhu_card.dart` 需要手动删除)
  - [x] 将其内部的 `InteractiveFourZhuCard` 类重命名为 `EightCharsCardV3`。
  - [x] 这个组件将成为唯一的、对外暴露的`StatefulWidget`，负责管理所有状态（`isEditMode`, `rowOrder`, `pillarOrder` 等）和业务逻辑（`_saveOrder`, `onReorder` 回调处理等）。

- [x] **4. 实现 `EightCharsCardV3` 的 `build` 方法:**
  - [x] 此方法将成为“总指挥”，其根组件将是 `EightCharsCard`（“外壳”）。
  - [x] 根据 `_isEditMode` 的状态来构建不同的 `child` 传递给“外壳”。
  - [x] **Normal 模式 (`!_isEditMode`):**
    - [x] 构建一个静态的 `Column`，其子项通过调用 `EightCharsCardViewBuilder` 中的方法生成。
  - [x] **Edit 模式 (`_isEditMode`):**
    - [x] 构建包含“行/列”模式切换按钮的UI。
    - [x] 根据“行/列”模式，构建对应的 `ReorderableListView`（垂直或水平），其列表项的内容同样调用 `EightCharsCardViewBuilder` 来生成。

- [x] **5. 清理项目:**
  - [x] **提醒用户**: 手动删除所有废弃的旧文件，包括 `row_reorderable_card.dart`, `column_reorderable_card.dart`, 以及旧的 `eight_chars_card_v3.dart`（如果存在）。
  - [x] 最终审查代码，确保新架构清晰、功能正确。
