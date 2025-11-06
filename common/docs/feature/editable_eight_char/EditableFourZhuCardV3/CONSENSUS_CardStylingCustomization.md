# CONSENSUS_CardStylingCustomization（EditableFourZhuCardV3 样式自定义共识）

- 创建时间：2025/11/05 13:25
- 适用组件：EditableFourZhuCardV3（卡片/柱/单元格/字体）
- 结论来源：与用户澄清后的偏好与约束（见 ALIGNMENT_CardStylingCustomization.md）

## 1. 明确的需求与范围

### 1.1 功能需求
- 卡片样式：支持边框颜色、圆角、边框宽度、背景（当前仅纯色）、阴影（完全自定义）、内边距。
- 柱样式：同样支持边框/圆角/边框宽度/背景（纯色）/阴影（完全自定义）/内边距/外边距，及默认字体样式。
- 单元格样式：同样支持上述装饰与字体样式，区分不同 RowType（表头/天干/地支/普通信息/分隔）。
- 字体样式：支持字体家族（项目内置）、大小、颜色、阴影；支持“十天干每一个字”“十二地支每一个字”的独立完整 TextStyle 覆盖（不仅颜色）。
- 深浅色模式：需要（同一主题可包含 Light/Dark 两套配置并自动切换）。
- 性能策略：局部刷新（避免全卡重绘），支持样式变更时的精细化更新。

### 1.2 范围与口径
- 背景：当前仅支持纯色；后续可评估渐变/纹理图片。
- 阴影：完全自定义（List<BoxShadow>），不限制为预设档位。
- 字体家族：支持项目内置（common/fonts）与系统内置字体；允许配置回退链（用户指定 → 主题默认 → 系统默认）。
  - 系统字体白名单：暂缓指定，采用通用名称 + 别名映射，跨平台白名单将于后续阶段补充，不阻塞当前实现。
- perToken 范围：支持完整 TextStyle（大小/粗细/阴影/颜色等），不仅颜色。
- RowType 背景边框：本期不需要为不同 RowType 配独立背景与边框（可在后续评估扩展）。
- 度量关系：padding/margin/borderWidth 参与测量（即最终布局尺寸 = 内容尺寸 + padding + margin + 边框宽度）；分隔行/列的度量保持窄宽/窄高稳定（必要时忽略其装饰参与测量）。
- PillarType 外边距差异化：允许。默认使用全局 PillarStyleConfig.margin；如提供 perPillarMargin（按 PillarType 的外边距覆盖），则以覆盖值为准。
  - 当期覆盖范围：年柱、月柱、日柱、时柱、以及“大运”列作为全量支持对象；后续可逐步添加其他柱类型。
  - 外边距值约束：不允许负值（EdgeInsets 各分量必须 >= 0）；构造函数/主题注入/fromJson 时进行校验，若发现负值则拒绝配置并抛出解释性错误。

## 2. 技术方案与约束

### 2.1 样式模型
- CardStyleConfig（@immutable, copyWith, toJson/fromJson）
  - borderColor, borderWidth, borderRadius
  - backgroundColor
  - shadows: List<BoxShadow>
  - padding: EdgeInsets
- PillarStyleConfig（@immutable）
  - decoration（含背景/边框/圆角/阴影/内边距/外边距）
  - defaultTextStyle, headerTextStyle
  - margin: EdgeInsets
  - perPillarMargin: Map<PillarType, EdgeInsets>?（可选，按类型覆盖外边距）
  - perPillarMargin 的键覆盖：当前限定为 Year/Month/Day/Hour/DaYun，后续迭代可扩展。
- CellStyleConfig（@immutable）
  - normalTextStyle, heavenlyStemTextStyle, earthlyBranchTextStyle, headerTextStyle
  - dividerStyle（颜色/厚度）
- TypographyConfig（@immutable）
  - globalTextStyle
  - perRowType: Map<RowType, TextStyle>
  - perPillarType: Map<PillarType, TextStyle>
  - perToken:
    - Map<TianGan, TextStyle>
    - Map<DiZhi, TextStyle>
    - 可选 Map<String, TextStyle>

### 2.2 主题注入与优先级
- EditableFourZhuCardTheme 作为统一注入容器（InheritedTheme/InheritedWidget）。
- 优先级（高→低）：perToken > perRowType/perPillarType > Cell/Pillar 默认 > Card 默认 > App 主题。
 - 外边距解析优先级：perPillarMargin > PillarStyleConfig.margin > Card 默认。

### 2.3 与测量的关系（关键）
- 列宽计算：
  - baseContentWidth = payload.resolveWidth 或 widthOverride（clamp）
  - measuredWidth = baseContentWidth + paddingHorizontal + marginHorizontal + borderWidth * 2
  - 行标题列同口径；分隔列建议 measuredWidth = ctx.colDividerWidthEffective（忽略装饰参与测量，以保持稳定）。
- 行高计算：
  - baseContentHeight = payload.resolveHeight 或 heightOverride
  - measuredHeight = baseContentHeight + paddingVertical + marginVertical + borderWidth * 2
  - 分隔行 measuredHeight = ctx.rowDividerHeightEffective（忽略装饰参与测量）。
 - 约束校验：外边距不允许负值，统一在测量前完成校验；如外部传入非法值则阻断并提示。
- 注意：因装饰参与测量，需在拖拽交互中避免抖动：样式变更触发重新测量，但拖拽过程中冻结样式或在拖拽开始时拍板一次尺寸（以保证阈值稳定）。

### 2.4 性能与局部刷新
- 使用 InheritedTheme + dependOnInheritedWidgetOfExactType 精准刷新受影响的子树。
- StyleResolver 对 TextStyle/BoxDecoration 合成做缓存（按 RowType/PillarType/token key）。
- 对测量：样式参数变化触发 CardLayoutModel 的重新计算；对分隔行/列的测量保持装饰不参与，避免过窄/过宽。

### 2.5 深浅色模式
- EditableFourZhuCardTheme 包含 light 与 dark 两套配置；根据 MediaQuery.platformBrightness 或外部开关切换。

## 3. 接口契约（示意）

```dart
class EditableFourZhuCardV3 extends StatefulWidget {
  // ...现有参数...
  final EditableFourZhuCardTheme? theme; // 包含 card/pillar/cell/typography
}

@immutable
class EditableFourZhuCardTheme {
  final CardStyleConfig card;
  final PillarStyleConfig pillar;
  final CellStyleConfig cell;
  final TypographyConfig typography;
  final EditableFourZhuCardTheme? light;
  final EditableFourZhuCardTheme? dark;
}

@immutable
class TypographyConfig {
  final TextStyle globalTextStyle;
  final Map<RowType, TextStyle> perRowType;
  final Map<PillarType, TextStyle> perPillarType;
  final Map<TianGan, TextStyle> perTianGan;
  final Map<DiZhi, TextStyle> perDiZhi;
  final Map<String, TextStyle>? perToken;
}
```

序列化：所有配置提供 toJson/fromJson；颜色用 ARGB；阴影含 offset/blur/spread。

字体 API：使用 TextStyle.fontFamily 与 fontFamilyFallback 进行字体家族与回退链的指定；跨平台字体名称通过别名映射统一管理。

## 4. 验收标准（可测试）
- 样式配置能够：
  - 控制卡片的边框/圆角/边框宽度/背景（纯色）/阴影（完全自定义）/内边距；
  - 控制柱与单元格的装饰与默认字体；
  - 为天干/地支每一个字定义独立的完整 TextStyle；
  - 支持深浅色模式切换；
  - 样式变更引发局部刷新、无明显卡顿；
  - 装饰参与测量（除分隔行/列），测量结果与预期一致。
- 测试通过：
  - 优先级解析单测；
  - 持久化一致性单测；
  - 金丝雀快照对典型主题；
  - 拖拽过程尺寸冻结或稳定（无抖动）。
  - 约束校验：
    - 外边距（margin）负值用例应抛出解释性错误；
    - perPillarMargin 的键仅在 Year/Month/Day/Hour/DaYun 下生效，其它键将被拒绝并提示。

## 5. 集成方案与边界
- 集成：将 EditableFourZhuCardTheme 注入到 EditableFourZhuCardV3；PillarWidget/CellWidget 读取主题与 TypographyConfig。
- 边界：本期不支持背景渐变/纹理图片，不支持 RowType 独立背景/边框；若需扩展，进入后续迭代。

## 6. 风险与缓解
- 风险：装饰参与测量可能引发阈值变化导致交互抖动。
  - 缓解：拖拽期间冻结样式尺寸；分隔行/列测量忽略装饰；对样式变化设定节流与批量重算。
- 风险：字体不可用导致渲染异常。
  - 缓解：提供字体回退链与健壮的默认样式；日志提示。

## 7. 复用性设计
- 主题对象可移植：放置于 common/lib/themes 下，独立模块化，跨页面复用。
- Token 化：TianGan/DiZhi 与 RowType/PillarType 的样式映射采用枚举键，避免中文字符串兼容问题。
- 组合复用：EditableFourZhuCardTheme 支持 copyWith 与局部覆盖；可基于默认主题派生多个主题。
- 持久化复用：提供 JSON 导入/导出；同一主题可在不同项目或分支中复用。
- 接口稳定：面向未来扩展的字段预留（如 gradient/texture），避免破坏性修改。

## 8. 下一步
- Architect：输出 DESIGN_CardStylingCustomization.md（架构图、分层与数据流、异常与回退）。
- Atomize：输出 TASK_CardStylingCustomization.md（原子任务拆分、输入/输出契约与依赖图）。