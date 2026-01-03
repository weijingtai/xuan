# Code Review: Editable Eight Char Page (`FourZhuEditPage`)

## 0. 迁移执行进度 (Migration Progress)
本文件已从“仅评审”更新为“迁移执行中的评审 + 进度记录”，用于跟踪 `refactor_dir_arch.md` 目录重构计划的落地情况。

### 0.1 已完成
*   **已清理 `.bak/.bakv1` import 依赖**：
    *   `EditorSidebarV2` 不再 import `theme_edit_preview_sidebar.dart.bak`
    *   `GroupTextStyleEditorPanel` 不再 import `colorful_text_style_editor_widget.dart.bakv1`
*   **已补齐正式文件替代备份文件**：新增 `common/lib/widgets/style_editor/theme_edit_preview_sidebar.dart`，承接原 `.bak` 文件中的 `ThemeEditPreviewSidebar`。
*   **已建立 features/shared 目录骨架（不迁移源码，仅提供兼容导出）**：
    *   `common/lib/features/four_zhu_card/four_zhu_card.dart`
    *   `common/lib/features/four_zhu_card_style_editor/four_zhu_card_style_editor.dart`
    *   `common/lib/shared/four_zhu_card/four_zhu_card_shared.dart`
*   **已完成 EditableFourZhuCard 目录迁移（阶段 3）**：
    *   `common/lib/widgets/editable_fourzhu_card/**` → `common/lib/features/four_zhu_card/widgets/editable_fourzhu_card/**`
    *   保留 `common/lib/widgets/editable_fourzhu_card.dart` 作为兼容层（re-export 到新路径）
    *   为测试与历史引用补齐 `common/lib/widgets/editable_fourzhu_card/**` 兼容导出（旧 import 仍可用）
*   **已建立回归基线（common 子项目）**：
    *   `flutter test`：通过（All tests passed）
    *   `flutter analyze`：存在大量历史告警/提示（当前统计 1893 issues），本轮迁移不在范围内做全量清理

### 0.2 待执行
*   迁移 `editable_four_zhu_card_theme.dart` 到 `features/four_zhu_card/themes/` 并更新引用。
*   迁移 `widgets/style_editor/**` 到 `features/four_zhu_card_style_editor/widgets/style_editor/**` 并更新引用。
*   迁移 `FourZhuEditPage/EditorWorkspace/EditorSidebarV2` 等到 `features/four_zhu_card_style_editor/`。
*   抽取 `shared/four_zhu_card/*`（drag_payloads/row_strategy/layout_template_enums/TextStyleConfig 统一来源）。
*   扫尾：全局替换旧路径引用并删除已迁移旧文件。

## 1. 概述 (Overview)
本次 Code Review 针对 `FourZhuEditPage` 及其相关组件（`EditorWorkspace`, `SidebarExplorer`, `FourZhuEditorViewModel`）进行。该模块主要功能为四柱卡片样式的可视化编辑，支持模板管理、撤销/重做、样式实时预览等功能。

总体而言，代码结构清晰，采用了 MVVM 架构，利用 Provider 进行状态管理，逻辑分层较为合理。但在 ViewModel 的依赖管理、状态同步以及部分 UI 组件的解耦上存在改进空间。

## 2. 架构与设计 (Architecture & Design)

### 2.1 优点
*   **状态管理 (State Management)**: 使用 `ChangeNotifierProvider` 在页面层级注入 `FourZhuEditorViewModel`，实现了 ViewModel 的生命周期与页面绑定，避免了全局污染。
*   **命令模式 (Command Pattern)**: `FourZhuEditorViewModel` 内部实现了 `CommandHistory`，为撤销/重做（Undo/Redo）功能提供了坚实的基础。
*   **组件化 (Componentization)**: 页面拆分为 `SidebarExplorer` (控制区) 和 `EditorWorkspace` (工作区)，职责分离清晰。
*   **主题隔离**: `EditorWorkspace` 内部通过 `Theme` 组件实现了编辑器内部主题与全局主题的隔离，支持独立预览 Light/Dark 模式。

### 2.2 关键架构问题 (Critical Architectural Issues)

#### ✅ 已解决：编辑页对 `FourZhuCardDemoViewModel` 的依赖
当前 `common/lib` 下，`FourZhuCardDemoViewModel` 的引用仅出现在演示入口（例如 Demo Page / main），`FourZhuEditPage` 及其编辑链路（Workspace/Sidebar）已不再依赖 Demo ViewModel，编辑器模块的“自包含性”显著提升。

## 3. 代码质量与细节 (Code Quality & Details)

### 3.1 `FourZhuEditPage.dart`
*   **资源释放**: `_templateNameController` 在 `dispose` 中正确释放，好评。
*   **UI 反馈**: `_saveWithFeedback` 中保存后使用 `SnackBar` 反馈，但未处理 `saveCurrentTemplate` 可能抛出的异常。建议添加 try-catch 块。
*   **硬编码字符串**: 界面中存在大量硬编码中文字符串（如 "卡片样式编辑", "保存更改"），建议提取到 l10n 国际化文件中。

### 3.2 `EditorWorkspace.dart`
*   **死代码/注释代码**:
    ```dart
    // _applyViewModelToNotifiers(viewModel);
    ```
    `build` 方法中注释掉了状态同步逻辑，这可能导致从 ViewModel 加载的模板数据无法正确应用到视图上。需要确认数据流向。
*   **混合模式**: 同时使用了 `ValueNotifier` (内部状态) 和 `Provider` (外部状态)。`_rowListNotifier` 似乎被设计为接收 ViewModel 数据，但目前逻辑被切断。

### 3.3 `SidebarExplorer.dart`
*   **结构清晰**: 使用 `ExpansionTile` 对样式编辑器进行分类，易于扩展。
*   **直接依赖**: 直接在 UI 构建中实例化 `EditableFourZhuStyleEditorPanel` 等面板。如果这些面板需要特定的 ViewModel 数据，建议通过参数传递或在面板内部通过 Selector 获取，减少不必要的全量重绘。

## 4. 改进建议 (Action Plan)

### 4.1 优先级：高 (High Priority)
1.  **统一 ViewModel**:
    *   **方案 A**: 让 `FourZhuEditorViewModel` 包含样式状态（`themeNotifier`, `cardPayloadNotifier` 等），彻底移除编辑器内对 `FourZhuCardDemoViewModel` 的依赖。
    *   **方案 B**: 如果必须复用，在 `FourZhuEditPage` 的 Provider 树中同时提供 `FourZhuCardDemoViewModel`，并确保其状态与 `FourZhuEditorViewModel` 同步（例如加载模板时更新 DemoVM）。
    *   **建议**: 采用方案 A。将 `EditableFourZhuCardTheme` 的管理逻辑迁移到 `FourZhuEditorViewModel` 中，使其成为真正的单一数据源。

2.  **修复数据流断裂**:
    *   启用或重构 `EditorWorkspace` 中的 `_applyViewModelToNotifiers` 逻辑，确保“加载模板” -> “ViewModel 更新” -> “UI 刷新” 链路畅通。

### 4.2 优先级：中 (Medium Priority)
1.  **异常处理**:
    *   完善 `saveCurrentTemplate`、`deleteCurrentTemplate` 的错误捕获与用户提示。
2.  **性能优化**:
    *   `EditorWorkspace` 的 `build` 方法较长，且包含多个 `Switch` 组件。建议将顶部工具栏（主题切换等）提取为独立 Widget (`WorkspaceToolbar`)，避免整个 Workspace 重绘。
3.  **代码清理**:
    *   移除 `EditorWorkspace` 中被注释的 `_pillarsNotifier` 和相关无用代码。

### 4.3 优先级：低 (Low Priority)
1.  **国际化**: 提取字符串资源。
2.  **UI 细节**: `EditorWorkspace` 右侧的 `Switch` 使用了系统默认样式，建议封装统一的 `LabelledSwitch` 组件以保持风格一致。

## 5. 总结
`FourZhuEditPage` 的编辑链路目前已完成“编辑器自包含”的关键整改，并已进入目录迁移（高内聚/低耦合）的执行阶段。下一步的核心风险在于“移动文件导致大范围 import 变更”和“shared 类型抽取引发的同名类型冲突”，需要用分阶段迁移 + 兼容 re-export + 回归门禁来控制。

---
*Reviewer: AI Assistant*
*Date: 2026-01-03*
