# 柱分段（行分隔符上/下子柱）实现计划

## 背景与目标
- 背景：当前 `RowType.separator` 仅以水平线呈现，不能表达“将整列视觉上分为两个垂直子柱”的需求。
- 目标：当出现行分隔符时，每个柱按分隔符位置拆分为“上段/下段”两个垂直子柱，样式相同；支持多分隔符扩展为 N 段；保持现有拖拽与度量系统对齐。

## 设计原则
- 低侵入：优先在渲染层（`EditableFourZhuCardImpl`）分段渲染，尽量复用现有 `CardMetricsCalculator` 度量结果。
- 一致性：上下子柱复用同一套主题装饰（margin/padding/border），行单元格样式与测量不变。
- 兼容性：无分隔符场景退化为单段；多分隔符产生多段，顺序与行顺序一致。

## 技术方案
1. 分段解析
   - 遍历 `payload.rowOrderUuid`，以 `payload.rowMap[rowUuid].rowType == RowType.separator` 为分界，切分为 `List<List<String>>` 段集合。
   - 示例两段：`top = rows[0..sepIdx-1]`，`bottom = rows[sepIdx+1..end]`；允许多个分隔符形成 N 段。

2. 度量聚合（复用现有快照）
   - 每个柱、每个段：遍历段内 `rowUuid`，累加 `getCellFinalSize(rowUuid, pillarUuid).height` 得到段高；段宽=柱宽。
   - 段间插入“分隔器间隙”，厚度取 `_rowDividerHeightEffective` 或主题 `theme.cell.getBy(RowType.separator)`。

3. 渲染调整（列内分段）
   - 在 `_buildRealPillar(...)` 内，将原“整列逐行渲染”的逻辑替换为“按段渲染”：
     - `Widget _buildPillarSection(List<String> rowsInSection, pillarUuid)`：遍历段内行构建现有单元格组件（`_buildDataCell(...)`），用 `Column` 包裹。
     - 段与段之间插入一个 `SizedBox(height: _rowDividerHeightEffective)` 或轻量 `CustomPaint` 表现分隔效果。
   - 行标题列同理，`_buildRowTitleCell(...)` 在分段模式下为每段渲染标题文本；分隔符行本身不渲染内容。

4. 多分隔符扩展
   - 通用化 `splitRowsBySeparators()` 返回 `List<List<String>>`；渲染遍历所有段，段间插入统一分隔器。

5. 交互与拖拽
   - 保持绝对行索引（`absRowIdx`）用于命中测试与拖拽；分段仅影响视觉排列，不改变索引含义。
   - 行插入/删除后重新计算分段集合；拖拽预览仍按原索引工作。

## 代码影响面
- `common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart`
  - 新增：分段解析方法 `List<List<String>> _splitRowsBySeparators(List<String> rows)`。
  - 新增：段渲染方法 `_buildPillarSection(...)`。
  - 修改：`_buildRealPillar(...)` 将整列渲染改为“分段渲染 + 段间分隔器”。
  - 修改：行标题列 `_buildRowTitleCell(...)` 在分段模式下按段渲染（分隔符行继续返回空占位）。

- `common/lib/widgets/editable_fourzhu_card/size_calculator/calculator.dart`
  - 无需强制修改：复用 `getCellFinalSize(...)` 汇总段高；如需性能优化，可在快照中添加每柱段缓存（可选后续迭代）。

## 验收标准
- 无分隔符：渲染与现状一致。
- 单分隔符：每柱出现上/下两个子柱，段间间隙等于 `_rowDividerHeightEffective`；上下子柱样式一致。
- 多分隔符：产生 N 段，顺序与行顺序一致，段间间隙一致。
- 行标题列：表头与普通标题在各自段中正常展示；分隔符行不展示文本。
- 拖拽：行/列拖拽、插入、删除均正常；分段随行变化实时更新。

## 测试计划
- 单元测试：分段解析、段高聚合、分隔符行占位行为。
- 黄金图测试：新增包含 0/1/2 分隔符的卡片截图对比。
- 交互测试：行拖拽在分段上下边界的预览与结果验证。

## 风险与缓解
- 渲染复杂度增加：通过方法拆分与段缓存降低重建成本。
- 文本基线与行高：完全复用现有行高测量，避免偏差。
- 多分隔符场景：统一由解析方法生成 N 段，避免散落逻辑。

## 里程碑
1. 分段解析与段渲染骨架（基础通过）
2. 行标题列分段渲染
3. 黄金图与单元测试落地
4. 多分隔符扩展与性能检查

