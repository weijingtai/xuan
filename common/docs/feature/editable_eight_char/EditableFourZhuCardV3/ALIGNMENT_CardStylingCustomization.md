# ALIGNMENT_CardStylingCustomization（EditableFourZhuCardV3 样式自定义）

- 创建时间：2025/11/05 13:16
- 关联分支：refactor/common/card-stage-6（建议）
- 任务目标：为 EditableFourZhuCardV3 设计“卡片/柱/单元格样式 + 字体家族/大小/颜色/阴影 + 每个字独立颜色”的可配置能力，形成对齐规范与问题清单。

## 1. 项目上下文与现状

- 现状：V3 已有统一的尺寸管理（MeasurementContext/CardLayoutModel），并以内部常量控制装饰（_pillarDecorationWidth/Height 等）。当前样式能力主要固定在 impl 中，缺少外部可配置的“Card/Pillar/Cell/Font”样式注入。
- 目标范围：
  - Card（卡片）：边框颜色/圆角/边框宽度、背景（色/渐变）、阴影、内边距。
  - PillarWidget（列展示单元）：支持边框、背景、阴影、内边距与外边距的配置，以及默认字体样式。
  - CellWidget（格子单元）：支持边框、背景、阴影、内边距与字体样式的配置，支持不同 RowType 的风格（表头/天干/地支/信息/分隔）。
  - 字体：字体家族、大小、颜色、阴影等；并允许对“十天干的每一个字”与“十二地支的每一个字”进行独立的颜色/样式定义。

## 2. 建议的样式模型与分层

- 卡片样式（CardStyleConfig）
  - borderColor、borderWidth、borderRadius
  - background：Color 或 Gradient
  - shadows：List<BoxShadow>
  - padding：EdgeInsets

- 柱样式（PillarStyleConfig）
  - decoration：背景/边框/圆角/阴影/内边距/外边距
  - defaultTextStyle：列内默认字体样式（非表头）
  - headerTextStyle：列标题文字样式（如 ColumnHeaderRow 的列标题部分）

- 单元格样式（CellStyleConfig）
  - normalTextStyle：普通信息行默认字体
  - heavenlyStemTextStyle：天干行默认字体
  - earthlyBranchTextStyle：地支行默认字体
  - headerTextStyle：表头行默认字体
  - dividerStyle：分隔行/列的绘制风格（含颜色与厚度）

- 字体样式集合（TypographyConfig）
  - globalTextStyle：全局默认字体（家族/大小/颜色/阴影）
  - perRowTypeStyles：Map<RowType, TextStyle>（如特化天干/地支/表头）
  - perPillarTypeStyles：Map<PillarType, TextStyle>（如特化大运/年月日时）
  - perTokenStyles：
    - Map<TianGan, TextStyle>（十天干逐一覆盖）
    - Map<DiZhi, TextStyle>（十二地支逐一覆盖）
    - 可选 Map<String, TextStyle>（以具体字或 tokenId 进行覆盖）

- 主题注入与优先级（EditableFourZhuCardTheme）
  - 引入 InheritedTheme：将上述 Config 注入到 PillarWidget/CellWidget。
  - 优先级（从高到低）：perToken > perRowType/perPillarType > Cell/Pillar 默认 > Card 默认 > App 主题。

## 3. API 设计建议

- EditableFourZhuCardV3 新增构造参数：
  - cardStyle：CardStyleConfig
  - pillarStyle：PillarStyleConfig
  - cellStyle：CellStyleConfig
  - typography：TypographyConfig
  - 或：theme：EditableFourZhuCardTheme（包含上述集合），支持 ValueListenable 以便动态更新。

- 数据约束：
  - 所有样式对象不可变（@immutable）并支持 copyWith。
  - 提供 toJson/fromJson 以便持久化，颜色使用 ARGB 十六进制；阴影包含 offset/blur/spread；字体包含 family/size/weight/style/shadows。
  - 对齐 MeasurementContext：样式修改默认不影响“逻辑尺寸计算”（column/row 的内容宽高），仅 Card padding 会影响有效布局区域；装饰不应改变测量（避免抖动）。

## 4. 渲染与性能建议

- 缓存与重用：
  - TextStyle/BoxDecoration 的解析与合成使用 StyleResolver，并缓存按 key（RowType/PillarType/Token）结果，减少重复计算。
  - 使用 ValueListenableBuilder 或 InheritedTheme + dependOnInheritedWidgetOfExactType 精准刷新，避免全卡重建。

- 回退与可访问性：
  - 当特定 token 未设置样式时，回退至 RowType 或全局默认样式。
  - 字体大小与颜色需保证对比度（至少 WCAG AA 级，建议配置检查），并支持系统字体缩放（MediaQuery.textScaleFactor）。
  - 最小/最大字体大小边界，避免破版。

## 5. 兼容与持久化

- 兼容策略：
  - 旧项目未传样式参数时，保持现状视觉与尺寸；新增样式不改变逻辑测量，只影响绘制。

- 持久化建议：
  - 将 TypographyConfig 的 perToken 映射（十天干/十二地支）以 enum 映射方式持久化；同时允许用户导入/导出 JSON 主题。
  - 多主题支持：提供主题 ID 与描述，允许在 Demo 中切换。

## 6. 可测性与验收建议

- 单元测试：
  - 解析优先级测试（确保 perToken > perRowType 等）。
  - 样式序列化/反序列化一致性。
  - 渲染不影响测量：变更装饰不改变 ColumnDimension/RowDimension 的 measure 结果。

- 金丝雀/快照测试：
  - 典型主题的黄金图快照（Card、Pillar、Cell 与天干/地支逐字样式）。

## 7. 澄清问题（待确认）

1) 背景是否需要支持渐变与图片纹理（Card/Pillar/Cell）？若支持，首版是否仅限纯色与线性渐变？
2) 阴影参数范围：是否提供简单开关与预设（none/small/medium/large），还是完全自定义列表？
3) 字体家族来源：是否允许自定义字体文件（assets/fonts），或仅限系统/项目内置？需要回退设置。
4) 十天干/十二地支样式：是否仅颜色可独立，还是允许完整 TextStyle（大小/粗细/阴影）都可独立？建议支持完整 TextStyle。
5) 不同 RowType 的 Cell 背景与边框：是否允许独立配置（如表头行有不同底色）？建议允许。
6) Dark/Light 模式：是否需要一套主题中同时提供两个模式并自动切换？
7) 性能上限：每次样式更新是否允许全卡重绘？建议限制为局部刷新（InheritedTheme/ValueListenable），并缓存样式解析。
8) 度量与装饰关系：是否确认“装饰仅影响绘制，不参与 measure”，避免列宽/行高抖动？

## 8. 初步结论与建议

- 采用 EditableFourZhuCardTheme（包含 Card/Pillar/Cell/Typography）进行主题化注入；提供 toJson/fromJson 便于持久化。
- 优先级清晰：perToken > perRowType/perPillarType > Cell/Pillar 默认 > Card 默认 > App 主题。
- 装饰不参与测量，仅 Card padding 影响有效布局区域；避免幅度变化导致交互阈值混乱。
- 提供 Demo 切换主题与示例（十天干/十二地支每个字独立 TextStyle，不仅颜色），满足“每个字独立样式”的需求。