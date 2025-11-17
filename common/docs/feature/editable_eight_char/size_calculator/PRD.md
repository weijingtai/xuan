# Editable Eight Char — Size Calculator PRD

## 概览
- 目的：统一生成并存储 V3 卡片中所有可能的尺寸数据（行/列/单元格/卡片），以 `EditableFourZhuCardTheme` 与 `CardPayload` 为唯一输入，提供稳定、可序列化、可查询的尺寸快照
- 范围：仅计算几何与装饰相关数据（宽/高、padding/margin/border），不涉及颜色、阴影渲染逻辑
- 输出：尺寸快照数据模型与计算器，支持按 `rowUuid + pillarUuid` 查询 cell 尺寸、按 `pillarUuid` 查询列尺寸，以及总宽/总高等汇总

## 目标
- 单一事实源：仅依赖 `theme` 与 `payload`，不引入其他上下文对象
- 精确可测：字号驱动行高，列装饰与卡片装饰合成规则明确且可单测
- 高性能：典型规模（4–6 列、6–10 行）全量计算小于 2ms；支持按脏位增量重算
- 可序列化：所有模型支持 JSON 序列化以便持久化与调试

## 角色与用户
- 前端开发：在布局与交互中查询 cell/pillar/totals 数据，进行渲染与命中测试
- 设计/产品：验证样式更改对尺寸的影响，评估排版与装饰策略
- 测试工程师：通过快照比对确认不同输入下的尺寸稳定性

## 用户故事
- 作为开发者，我希望根据 `rowUuid + pillarUuid` 获取该单元格的 `Size + margin + borderWidth`，以便正确布局与占位
- 作为开发者，我希望根据 `pillarUuid` 获取该列的 `totalWidth/verticalDecorationHeight/margin/borderWidth`
- 作为开发者，我希望直接获得卡片的 `totalWidth/totalHeight`，用于容器尺寸约束与滚动区域计算

## 功能需求
- 输入
  - `EditableFourZhuCardTheme theme`：含 `PillarSection/CellSection/TypographySection/CardStyle`
  - `CardPayload payload`：含 `pillarOrderUuid/rowOrderUuid/pillarMap/gender`
- 输出
  - `CardMetricsSnapshot`（尺寸快照）：含 `pillarsByUuid/rowsByUuid/cellsByRowAndPillarUuid/totals`
  - 查询接口：`getCell(rowUuid, pillarUuid)`、`getPillar(pillarUuid)`、`getTotals()`
- 计算规则
  - 字体驱动行高：`fontSize * lineHeightFactor`（向上取整），来源于 `TypographySection.globalFontSize`，若后续扩展行分组字体则优先分组值
  - 行装饰：来自 `CellSection.getBy(rowType)` 的 `padding/margin/borderWidth`
  - 列装饰：来自 `PillarSection.getDecorationWidthBy/HeightBy(pillarType)` 的水平/垂直装饰
  - 单元格尺寸：`contentSize = Size(pillarBaseWidth, rowContentHeight)`；`decoratedSize.height = contentHeight + cellPadding*2 + border*2`
  - 卡片总宽：所有列 `totalWidth` 之和 + 卡片 `padding.horizontal + cardBorderHorizontal`
  - 卡片总高：所有行 `totalHeight` 之和 + “最大列垂直装饰高度” + 卡片 `padding.vertical + cardBorderVertical`
- 查询场景
  - 单格：`rowUuid + pillarUuid` → `CellMetrics`
  - 单列：`pillarUuid` → `PillarMetrics`
  - 汇总：`CardTotals`

## 非功能需求
- 性能：全量计算 < 2ms；增量重算（单行/单列）< 0.5ms
- 可靠性：输入不合法时提供安全兜底（如 NaN/负值归零），保证计算不抛异常
- 可测试性：边界输入（空行/分隔列/超大字号）均有单测覆盖；快照稳定比对
- 可维护性：数据模型 `Equatable + copyWith + json`，便于调试与持久化

## 设计与数据模型
- `CardMetricsSnapshot`
  - `pillarsByUuid: Map<String, PillarMetrics>`
  - `rowsByUuid: Map<String, RowMetrics>`
  - `cellsByRowAndPillarUuid: Map<String, CellMetrics>`（键：`"rowUuid#pillarUuid"`）
  - `totals: CardTotals`
- `PillarMetrics`
  - 标识：`pillarUuid, pillarType`
  - 尺寸：`contentWidth, decorationWidth, verticalDecorationHeight, totalWidth, totalHeight`
  - 装饰：`margin, padding, borderWidth`
- `RowMetrics`
  - 标识：`rowUuid, rowType`
  - 尺寸：`contentHeight, decorationHeight, totalHeight`
  - 装饰：`margin, padding, borderWidth`
- `CellMetrics`
  - 标识：`rowUuid, pillarUuid, rowType, pillarType`
  - 尺寸：`contentSize, decoratedSize`
  - 装饰：`margin, padding, borderWidth`
- `CardTotals`
  - `totalWidth, totalHeight`
  - `contentGridWidth, contentGridHeight`
  - `maxPillarVerticalDecoration, sumPillarDecorationWidth`
  - `cardPadding, cardBorderWidth`

## 计算类
- `CardMetricsCalculator`
  - 构造：`CardMetricsCalculator({required EditableFourZhuCardTheme theme, required CardPayload payload, double lineHeightFactor = 1.4, double defaultPillarWidth = 64})`
  - 方法：
    - `CardMetricsSnapshot compute()`：全量生成尺寸快照
    - `CellMetrics getCell(String rowUuid, String pillarUuid)`
    - `PillarMetrics getPillar(String pillarUuid)`
    - `CardTotals getTotals()`
  - 策略：
    - 行内容高：通过 `TypographySection.globalFontSize` 与 `lineHeightFactor` 推导；如缺省则使用 14 与 1.4
    - 列基础宽：优先 `payload.pillarMap[uuid].resolveWidth()`，否则 `defaultPillarWidth`
    - 行类型/列类型：来源于 `payload`（见下方“约束与假设”）

## 成功指标
- 单元测试通过率 100%，覆盖正常/边界/异常输入
- 典型规模全量计算耗时 < 2ms；增量重算（单列/单行）< 0.5ms
- 在 V3 卡片中替换现有尺寸计算后，视觉结果一致或更准确（修正列垂直装饰累加为最大值）

## 约束与假设
- 当前 `CardPayload` 需提供行类型映射（`rowMap: Map<String, RowType>`或等价载荷）以计算 `RowMetrics`；若缺失，将假设行顺序与固定枚举（如：表头、天干、地支、纳音…），并在“开放问题”中提出增强方案
- 分隔列（`PillarType.separator`）仅参与列间分隔，不参与内容宽度与单元格渲染；其装饰逻辑需明确
- 字体按全局字号驱动行高；分组字体支持为未来扩展，不影响当前设计

## 开放问题
- `CardPayload` 是否需要增加 `rowMap: Map<String, RowType>` 以避免对行类型的假设？若保持仅 `rowOrderUuid`，计算器无法准确识别行类型
- 行级 `padding/margin` 是否来自 `CellSection.getBy(rowType)` 的全局定义，是否需要行级覆盖（后续需求）？
- 分隔列的垂直装饰是否参与卡片总高（建议不参与）？
- `lineHeightFactor` 是否统一固定为 1.33–1.4，是否允许主题自定义？

## 里程碑
- M1：定义数据模型与计算器原型，完成全量计算与查询接口
- M2：接入 V3 卡片，替换 `_computeSizeWithDecorationsV2()` 并通过视觉对比
- M3：增量重算与缓存优化，完成性能基准测试
- M4：扩展行分组字体与行级覆盖策略（如有需要）