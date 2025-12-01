# TODO_sidebar_enhancement

## 待办事项 / 建议优化

虽然核心功能已完成，但以下项目可作为后续优化方向：

### 1. 代码清理与重构
- [ ] **`RowStyleEditorPanel.dart`**: 清理被注释掉的旧代码（如 `ensureRowConfig` 相关逻辑），保持代码整洁。
- [ ] **测试覆盖**: 为 `FourZhuEditorViewModel` 中的排序逻辑（`reorderPillarsInGroup`, `reorderRowsByTypes`）添加单元测试。

### 2. 性能优化
- [ ] **`ReorderableListView`**: 当前列表项较少，性能良好。若未来配置项增多（>50），可考虑优化构建逻辑或使用 `SliverReorderableList`。

### 3. 功能扩展
- [ ] **撤销/重做 (Undo/Redo)**: 当前排序操作直接生效。可以考虑结合 `Command` 模式支持排序操作的撤销。
- [ ] **多选操作**: 目前仅支持单项拖拽，未来可考虑支持多选批量设置样式。

### 4. 遗留配置检查
- [ ] 检查 `test/` 目录下的测试用例，适配最新的 API 变更（如 `CellStyleConfig` 新增字段导致的测试编译错误）。
