# Size Calculator 原子化待办事项

## 范围
- 仅依赖 `EditableFourZhuCardTheme` 与 `CardPayload`
- 所有改动在 `common` 子模块下完成
- 代码位置集中：`common/lib/widgets/editable_fourzhu_card/size_calculator`
- 交付数据模型与计算器，不含 UI 改动

## 待办清单

数据模型
- [x] 在 `size_calculator/metrics.dart` 定义 `CardMetricsSnapshot`
- [x] 在 `size_calculator/metrics.dart` 定义 `PillarMetrics`
- [x] 在 `size_calculator/metrics.dart` 定义 `RowMetrics`
- [x] 在 `size_calculator/metrics.dart` 定义 `CellMetrics`
- [x] 在 `size_calculator/metrics.dart` 定义 `CardTotals`

计算器实现
- [x] 在 `size_calculator/calculator.dart` 创建 `CardMetricsCalculator`（仅接收 `theme` 与 `payload`）
- [x] 在 `size_calculator/calculator.dart` 实现 `compute()` 构建完整 `CardMetricsSnapshot`
- [x] 在 `size_calculator/calculator.dart` 计算 `CellMetrics`（行高/边距/边框合成）
- [x] 在 `size_calculator/calculator.dart` 计算 `PillarMetrics`（宽/高/装饰合成）
- [x] 在 `size_calculator/calculator.dart` 计算 `CardTotals`（总宽合计/总高取列垂直装饰最大值）

查询接口
- [x] 在 `size_calculator/calculator.dart` 提供 `getCell(rowUuid, pillarUuid)`
- [x] 在 `size_calculator/calculator.dart` 提供 `getPillar(pillarUuid)`
- [x] 在 `size_calculator/calculator.dart` 提供 `getTotals()`

鲁棒性与兜底
- [x] 归一化负值/NaN/Infinity（设置安全默认值）
- [ ] `rowMap` 缺失时使用固定行类型序列并记录开放问题
- [ ] 保证类型安全与空安全（null/缺失字段处理）

测试
- [ ] 单元测试：正常规模输入与基本查询接口
- [ ] 单元测试：超大字号导致行高变化
- [ ] 单元测试：空行/空列/缺失 `rowMap` 情况
- [ ] 单元测试：无列宽时的默认宽度兜底
- [ ] 基准测试：全量计算性能采样
- [ ] 基准测试：增量重算性能采样

文档与规范
- [ ] 补充计算规则与边界行为说明（更新 PRD）
- [ ] 记录开放问题与后续扩展点（更新 PRD）