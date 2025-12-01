# ALIGNMENT_sidebar_enhancement

## 1. 需求分析

### 1.1 原始需求
1.  **侧边栏样式编辑增强**：
    *   增加「柱分隔符 (Pillar Separator)」宽度编辑（Slider）。
    *   增加「行分隔符 (Row Separator)」高度编辑（Slider）。
2.  **行列拖拽排序**：
    *   侧边栏中的柱样式与行样式列表支持拖拽排序。
    *   初始顺序需与 Card 中的行列顺序一致。
    *   在侧边栏调整顺序后，Card 需实时更新排序。

### 1.2 现有架构分析
*   **ViewModel 分离**：
    *   `FourZhuEditorViewModel`：管理侧边栏状态（`CardStyle`, `RowConfig` 等）。
    *   `FourZhuCardDemoViewModel`：管理 `EditorWorkspace` 中的 Card 状态（`themeNotifier`, `cardPayloadNotifier`）。
    *   目前两者缺乏联动，导致侧边栏修改可能无法实时反映在 Card 上（需确认 `EditorWorkspace` 是否已部分实现联动）。
*   **主题配置**：
    *   `EditableFourZhuCardTheme`：
        *   柱分隔符宽度：`PillarSection.defaultSeparatorConfig.separatorWidth` (已存在)。
        *   行分隔符高度：目前由 `_rowDividerHeightEffective` 控制，需确保主题中有对应字段（如 `CellSection` 中新增或复用）。
*   **排序逻辑**：
    *   行顺序：由 `cardPayloadNotifier.value.rowOrderUuid` 控制。
    *   柱顺序：由 `cardPayloadNotifier.value.pillarOrderUuid` 控制。

## 2. 解决方案

### 2.1 数据模型升级
*   **CardStyle / Theme**：
    *   确保 `CardStyle` (ViewModel层) 有 `rowSeparatorHeight` 和 `pillarSeparatorWidth` 字段。
    *   确保 `EditableFourZhuCardTheme` (UI层) 能接收并应用这些值。
*   **ViewModel 联动**：
    *   `EditorWorkspace` 需监听 `FourZhuEditorViewModel` 的变化。
    *   当 `FourZhuEditorViewModel` 更新（样式或排序）时，`EditorWorkspace` 需同步更新 `EditableFourZhuCardV3` 的 `themeNotifier` 和 `cardPayloadNotifier`。

### 2.2 侧边栏 UI 改造 (`EditorSidebarV2`)
*   **分隔符样式**：
    *   在 `_DividerConfigSection` 中增加两个 Slider，分别控制 `pillarSeparatorWidth` 和 `rowSeparatorHeight`。
*   **排序交互**：
    *   使用 `ReorderableListView` 改造行配置列表 (`_RowConfigSection`)。
    *   新增或改造柱配置列表，支持拖拽排序。
    *   拖拽回调调用 ViewModel 的 `reorderRows` / `reorderPillars` 方法。

### 2.3 核心逻辑实现
1.  **ViewModel 更新**：
    *   `FourZhuEditorViewModel` 新增 `reorderRows(int oldIndex, int newIndex)` 和 `reorderPillars(...)`。
    *   更新 `cardStyle` 中的分隔符尺寸字段。
2.  **Workspace 同步**：
    *   `EditorWorkspace` 中的 `_applyViewModelToNotifiers` 方法需完善，确保：
        *   将 ViewModel 的 `rowConfigs` 顺序转换为 `TextRowPayload` 列表顺序。
        *   将 ViewModel 的分隔符设置转换为 `EditableFourZhuCardTheme`。

## 3. 疑问澄清
*   **Q1**: 行分隔符高度是否需要每个分隔符独立设置？
    *   **A**: 需求暗示为全局设置（"允许row separator设定高度"），故暂定为全局统一设置。
*   **Q2**: 柱排序是否包含“隐藏”的柱？
    *   **A**: 侧边栏应显示所有可用柱，拖拽改变的是显示顺序。

## 4. 执行计划
1.  **Model & ViewModel**: 添加字段与排序方法。
    *   修改 `CardStyle` 添加 `rowSeparatorHeight`。
    *   修改 `FourZhuEditorViewModel` 添加 `updateRowSeparatorHeight` 和排序逻辑。
2.  **Theme Sync**: 完善 `EditorWorkspace` 与 ViewModel 的同步逻辑。
    *   实现 `_applyViewModelToNotifiers`，确保样式和顺序实时生效。
3.  **Sidebar UI**: 实现 Slider 与 ReorderableListView。
    *   修改 `EditorSidebarV2`。
4.  **Verification**: 验证拖拽与样式调整的实时性。
