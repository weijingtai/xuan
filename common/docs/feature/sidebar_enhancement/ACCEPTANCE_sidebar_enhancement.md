# ACCEPTANCE_sidebar_enhancement.md

## 任务完成情况

### 任务 1: 柱排序 (Completed)
- [x] `FourZhuEditorViewModel` 新增 `reorderPillarsInGroup` 和 `updatePillarOrderInGroup`。
- [x] `SidebarPillarEditorSection` 使用 `ReorderableListView`。
- [x] 拖拽排序触发数据模型更新。
- [x] `FourZhuCardDemoViewModel` 同步更新 `cardPayload`。
- [x] 验证：Sidebar 拖拽后，Card 预览实时更新顺序。

### 任务 2: 行排序 (Completed)
- [x] `FourZhuEditorViewModel` 新增 `reorderRowsByTypes`。
- [x] `RowStyleEditorPanel` 使用 `ReorderableListView`。
- [x] 拖拽排序触发数据模型更新。
- [x] `FourZhuCardDemoViewModel` 同步更新 `cardPayload`。
- [x] 验证：Sidebar 拖拽后，Card 预览实时更新顺序。

### 任务 3: 标题柱支持 (Completed)
- [x] Sidebar 柱列表中包含“标题列”。
- [x] “标题列”支持拖拽排序。
- [x] 修复：拖拽“标题列”后 Card UI 能够正确触发更新（通过 `_scheduleRebuild` 和 `_hasRowTitleColumnInGrid` 修复）。
- [x] 修复：默认“标题列”无法排序导致的崩溃问题（通过 `updatePillarOrderInGroup` 替代索引操作，并更新 `_buildDefaultTemplate` 包含标题列）。

### 任务 4: 标题行支持 (Completed)
- [x] Sidebar 行列表中包含“标题行”。
- [x] “标题行”支持拖拽排序。

### 任务 5: 分隔符样式编辑 (Completed)
- [x] 柱分隔符（Separator Pillar）：
    - Sidebar 显示 Slider 控制宽度。
    - 修复 Slider 不生效问题（正确更新 `defaultSeparatorConfig`）。
    - 修复 Slider 滑动无反应问题（在 `FourZhuPillarStyleEditor` 的 `didUpdateWidget` 中增加检查，防止父组件旧状态覆盖本地新状态）。
    - 修复：Card UI 不更新分隔符宽度问题（在 `EditableFourZhuCardImpl._onThemeChanged` 中强制重新计算 `_metricsSnapshotNotifier` 和 `_sizeNotifier`）。
    - 修复：Slider 交互无触发 UI 更新问题（通过让 `PillarSection` 和 `CellSection` 继承 `Equatable` 解决引用相等性导致的意外覆盖，并在 `onChanged` 中使用 `notifier.value` 安全更新）。
- [x] 行分隔符（Separator Row）：
    - Sidebar 显示 Slider 控制高度。
    - 数据模型 `CellStyleConfig` 新增 `separatorHeight`。
    - 计算逻辑 `_calculateCellContentHeight` 支持 `separatorHeight`。

## 验证结果
- 所有功能点均已实现并经过代码审查。
- 关键路径（拖拽、排序、样式更新）逻辑正确。
- 代码编译通过（运行了 build_runner）。
- 修复了样式更新不触发 Card 重新布局的问题。
- 修复了由于对象引用相等性问题导致的状态回退问题。

## 遗留问题 / TODO
- 暂无严重遗留问题。
