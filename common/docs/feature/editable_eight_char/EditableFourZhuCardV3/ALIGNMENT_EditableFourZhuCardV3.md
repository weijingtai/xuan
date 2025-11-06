# ALIGNMENT_EditableFourZhuCardV3

- 创建时间：2025/11/05 13:10
- 关联分支：refactor/common/card-stage-6
- 任务目标：请先阅读 EditableFourZhuCardV3_README.md 以及 EditableFourZhuCardV3 代码并对齐，输出一致性检查与澄清问题清单。

## 1. 项目上下文分析

- 技术栈：Flutter（Draggable/DragTarget 双轴拖拽）、ValueNotifier 数据源、不可变尺寸模型（MeasurementContext、CardLayoutModel、ColumnDimension、RowDimension）。
- 组件位置：common/lib/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart
- 相关模型：
  - 尺寸管理：common/lib/widgets/editable_fourzhu_card/dimension_models.dart
  - 拖拽载荷：common/lib/models/drag_payloads.dart（PillarPayload、RowInfoPayload 及其特化）
  - 幽灵占位：common/lib/widgets/editable_fourzhu_card/widgets/ghost_pillar_widget.dart
- Demo 使用：common/lib/pages/editable_four_zhu_card_demo_page.dart（展示独立抓手版 V3，首行/首列通过抓手排序，标题不可拖拽）。
- 核心特性概览（源代码与 README 一致）：
  - 单视图、双轴拖拽（行/列重排与插入）。
  - 独立抓手行/列，避免误拖拽标题。
  - 统一尺寸管理与分隔行/列的窄宽/窄高策略。
  - 支持外部拖拽载荷插入扩展列/信息行。
  - 可自定义拖拽反馈与插入装饰；可开启调试覆盖层。

## 2. 需求理解与范围边界

- 需求理解：对齐 README 与实现，确保文档描述与代码行为一致，补充必要的规范说明与关键参数定义。
- 范围边界：
  - 本次仅对齐文档与现有实现，不做 UI 改动（如需变更 UI，需走 Architect/Atomize 流程）。
  - 不扩展新业务类型与策略；仅描述并确认现有行为与参数。

## 3. 一致性核对（代码 vs README）

已核对的关键点：
- 分隔列/分隔行：
  - 列：ColumnDimension.measure 在 PillarType.separator 时使用 ctx.colDividerWidthEffective；源码中 _isSeparatorColumnIndex 同时兼容旧别名（分隔符/列分隔符/"|").
  - 行：RowDimension.measure 通过 payload.resolveHeight 使用 ctx.rowDividerHeightEffective；源码 _isSeparatorRowLabel 统一识别多别名（分割线/行分割线/行分割符/行分隔符）。
- 行标题列（RowTitleColumnPayload）：
  - 优先使用 payload.columnWidth，否则使用 ctx.rowTitleWidth；源码中对行标题列做了特殊宽度分支。
- 表头行（ColumnHeaderRowPayload）：
  - 行高由 payload.resolveHeight 选择 headerHeight；左上角性别展示与 README 描述一致。
- 列宽与装饰：
  - 源码中可见统一柱宽 pillarWidth，并对内容宽度叠加装饰总宽 _pillarDecorationWidth；分隔列不叠加装饰。README 需明确“columnWidth 属于内容宽度，最终布局宽度 = 内容宽度 + 装饰”。
- 宽高覆盖优先级：
  - 列：widthOverride > separator 固定窄宽 > rowTitleColumn 固定/覆盖宽 > payload.resolveWidth。
  - 行：heightOverride > payload.resolveHeight（含干支、表头、分隔、其他）。
- 尺寸上下文：
  - MeasurementContext.fromStateConfig 与 README 中的尺寸参数一致（min/max 列宽、默认列宽、干支行高、普通行高、分隔有效尺寸等）。
- 外部拖拽：
  - Demo 展示了 TestPillarDraggable/TestRowInfoDraggable 等外部源，组件使用 Draggable/DragTarget 处理插入与重排，与 README 描述一致。
- ID 分配：
  - 源码提供 _allocatePillarId，按 <type>#<序号> 在当前卡片内生成；README 需强调“卡内唯一、非全局唯一”。

初步结论：README 与代码主体逻辑一致；需在 README 中补充“内容宽 vs 布局宽”的明确说明、分隔别名列表、以及覆盖键的持久化策略建议。

## 4. 开放问题与澄清项（按优先级）

1) 列宽定义口径（高优先级）
   - 代码在布局时使用 内容宽 + 装饰宽；payload.columnWidth 与 widthOverride 表示“内容宽”还是“含装饰宽”？建议统一为“内容宽”，并在 README 明确口径。

2) 覆盖持久化键（高优先级）
   - 目前源码存在基于索引的覆盖 Map<int,double>（列/行），而尺寸模型（CardLayoutModel）支持不可变维度对象。是否需要将覆盖绑定到 pillarContent.id / 行唯一键，以保证重排后仍正确对应？

3) 分隔别名列表（中优先级）
   - 代码已支持列（分隔符/列分隔符/"|")与行（分割线/行分割线/行分割符/行分隔符）的多别名识别。是否需要在 README 中约束合法别名集合并建议使用统一枚举/常量以避免歧义？

4) 删除行为与触发（中优先级）
   - README 提到可删除列/行，但当前实现更多集中在插入与重排。是否存在“删除目标区/按键操作”？若需要删除，建议定义明确的交互与 DragTarget 区域。

5) 调试覆盖层阈值参数化（中优先级）
   - debugHysteresisOverlay 目前为 bool 开关；是否需要将阈值（如插入边界的触发距离）参数化暴露给外层以便调试？

6) 标题互换规则（中优先级）
   - README 中指出 RowTitleColumn 与 ColumnHeaderRow 可与普通列/行互换位置；Demo 强调 V3 的“标题不可直接拖拽，仅用抓手排序”。请确认：是否仅通过抓手实现互换，禁止直接拖拽标题？

7) 多个“大运”列的 id 分配（低优先级）
   - _allocatePillarId 按类型计数分配；请确认 ID 唯一性需求为“卡内唯一”，并明确是否需要跨卡全局唯一（通常不需要）。

8) GhostPillarWidget 风格（低优先级）
   - README 约定列幽灵为蓝色、行幽灵为绿色（半透明）。请确认色值与透明度是否需要支持主题覆盖或配置项。

## 5. 初步决策（基于现有实现与行业常识）

- 列/行的 widthOverride/rowHeight 与 payload 的 columnWidth/rowHeight 统一本质为“内容尺寸”，布局最终宽高在绘制时加上装饰。
- 分隔列/行严格使用 MeasurementContext 的有效尺寸，不参与装饰叠加，确保视觉稳定。
- ID 分配仅保证“卡内唯一”，不做全局唯一；跨卡交互使用载荷内数据而非 ID 进行匹配。
- 标题互换通过独立抓手完成，保持标题不可直接拖拽，减少误操作风险。
- 分隔别名在 README 中补充统一表，仅建议使用枚举/常量源生成，减少手写字符串。

待用户确认后，将据此更新 README 口径与生成 CONSENSUS 文档。

## 6. 验收标准（Align 阶段）

- 文档与实现对齐项全部核对无歧义（尺寸口径、分隔识别、ID 策略、拖拽交互）。
- 关键开放问题获得确认并形成明确结论。
- 输出 CONSENSUS_EditableFourZhuCardV3.md，明确验收标准与技术约束。

## 7. 下一步

- 待您答复上述澄清问题后：
  - 更新本 ALIGNMENT 文档的“初步决策”为“最终决策”；
  - 生成 CONSENSUS 文档并进入 Architect/Atomize 阶段。