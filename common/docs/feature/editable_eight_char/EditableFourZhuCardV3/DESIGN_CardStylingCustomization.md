# DESIGN_CardStylingCustomization（EditableFourZhuCardV3 样式编辑与主题架构设计）

- 创建时间：2025/11/05 14:35
- 面向对象：EditableFourZhuCardV3 的样式编辑组件与主题注入（Card/Pillar/Cell/Typography）
- 依据文档：ALIGNMENT_CardStylingCustomization.md、CONSENSUS_CardStylingCustomization.md

## 1. 设计目标
- 提供可视化样式编辑器（含拖拽 Slider、颜色选择、字体选择、阴影列表编辑），实时驱动 EditableFourZhuCardV3 的主题与局部刷新。
- 支持卡片（Card）、柱（Pillar）、单元格（Cell）、字体（Typography）的配置修改。
- 保证性能（局部刷新）与稳定测量（拖拽过程中尺寸稳定），并对外边距等参数进行约束校验（不允许负值）。

## 2. 整体架构图
```mermaid
graph TD
  A[StyleEditorPanel<br/>(Card/Pillar/Cell/Typography Tabs)] --> B[ThemeController]
  B --> C[ThemeResolver]
  C --> D[EditableFourZhuCardV3]
  D --> E[CardLayoutModel & Measurement]
  D --> F[Render Widgets<br/>(PillarWidget/CellWidget)]
  A --> G[LivePreviewPane]
  B --> H[PresetManager JSON I/O]
  C --> I[FontAliasMapper]
```

## 3. 分层与核心组件

### 3.1 编辑面板（StyleEditorPanel）
- EditableFourZhuStyleEditorPanel（整体容器，Tab 切换：Card / Pillar / Cell / Typography）
  - CardStyleEditorSection：
    - Padding 编辑：四向拖拽 Slider（或统一值 + 锁定联动），数值输入框；单位为像素，非负约束。
    - 边框编辑：
      - 颜色选择器（ColorPicker）
      - 宽度 Slider（非负）
      - 圆角 Slider（非负）
    - 背景颜色编辑：纯色 ColorPicker
    - 阴影列表编辑：ShadowListEditor（可添加/删除/排序）。每项包含：
      - 颜色 ColorPicker
      - 偏移 X/Y（Slider）
      - 模糊半径（blurRadius Slider）
      - 扩散（spreadRadius Slider）
  - PillarStyleEditorSection：
    - Margin 编辑：非负 EdgeInsets（四向 Slider + 数值输入）。
    - PerPillarMarginEditor（差异化开关与覆盖）：支持 Year/Month/Day/Hour/DaYun 五类 PillarType；
      - 每类单独的 Margin 编辑器（非负约束）。
      - 未设置时使用全局 margin。
    - 默认字体样式编辑：TextStyleEditor（字体大小、颜色、粗细、阴影）。
    - Header 字体样式编辑：TextStyleEditor。
  - CellStyleEditorSection：
    - 单元格通用装饰：边框宽度/颜色、圆角、内边距（非负）。
    - RowType 字体样式：为 Header / HeavenlyStem / EarthlyBranch / Normal 信息行设置 TextStyle。
    - 分隔行样式：dividerStyle（颜色/厚度），不参与装饰测量。
  - TypographyEditorSection：
    - 全局字体：TextStyleEditor（fontFamily、fontFamilyFallback、size、color、weight、shadows）。
    - perRowType：选择 RowType 后编辑 TextStyle。
    - perPillarType：选择 PillarType 后编辑 TextStyle。
    - perToken：
      - 十天干：以网格 Grid 展示，逐字编辑 TextStyle（不仅颜色）。
      - 十二地支：同上。
    - FontFamilySelector：列出项目内置与系统内置字体，并提供别名映射；支持回退链编辑（拖拽排序）。

### 3.2 控制器与解析
- ThemeController：集中处理来自编辑器的变更、进行约束校验、生成主题更新（ValueNotifier）。
- ThemeResolver：将多层样式合并为最终 TextStyle/BoxDecoration，缓存合成结果以提升性能。
- FontAliasMapper：统一不同平台字体名称的别名映射（如 "PingFang SC" ↔ "SF Pro" 回退链组合）。
- PresetManager：主题的 JSON 导入/导出与版本化。

### 3.3 预览与刷新
- LivePreviewPane：绑定 EditableFourZhuCardV3 并在主题变更时局部刷新。
- 拖拽中尺寸稳定策略：
  - 对分隔行/列：装饰不参与测量（固定窄宽/窄高）。
  - 对普通行/列：样式变更触发重测，但拖拽过程冻结当前尺寸或节流重算，避免抖动。

## 4. 接口契约（Dart 伪代码示意，含函数注释）

```dart
/// 样式编辑器面板入口，负责渲染各编辑分区并与控制器交互。
/// 参数：
/// - controller: 样式主题控制器，提供当前主题与更新方法
/// 返回：
/// - Widget: 可嵌入的编辑器面板
Widget buildStyleEditorPanel({required EditableFourZhuThemeController controller});

/// 卡片样式编辑分区（padding、border、radius、background、shadows）。
/// 参数：
/// - controller: 主题控制器
/// - initial: 当前 CardStyleConfig
/// 返回：
/// - Widget: 卡片样式编辑区域
Widget buildCardStyleEditorSection({
  required EditableFourZhuThemeController controller,
  required CardStyleConfig initial,
});

/// 柱样式编辑分区（margin 与差异化 perPillarMargin、默认/表头字体）。
/// 参数：
/// - controller: 主题控制器
/// - initial: 当前 PillarStyleConfig
/// 返回：
/// - Widget: 柱样式编辑区域
Widget buildPillarStyleEditorSection({
  required EditableFourZhuThemeController controller,
  required PillarStyleConfig initial,
});

/// 单元格样式编辑分区（边框、圆角、padding、RowType 字体、分隔行样式）。
/// 参数：
/// - controller: 主题控制器
/// - initial: 当前 CellStyleConfig
/// 返回：
/// - Widget: 单元格样式编辑区域
Widget buildCellStyleEditorSection({
  required EditableFourZhuThemeController controller,
  required CellStyleConfig initial,
});

/// 字体编辑分区（全局、perRowType/perPillarType、perToken）。
/// 参数：
/// - controller: 主题控制器
/// - initial: 当前 TypographyConfig
/// 返回：
/// - Widget: 字体样式编辑区域
Widget buildTypographyEditorSection({
  required EditableFourZhuThemeController controller,
  required TypographyConfig initial,
});

/// 控制器：接收编辑器事件、执行约束校验（如 margin 非负）、更新主题并通知预览刷新。
/// 参数：
/// - theme: 当前主题对象
/// 返回：
/// - EditableFourZhuThemeController: 可供编辑器与预览使用的控制器
class EditableFourZhuThemeController {
  /// 当前主题（包含 card/pillar/cell/typography）。
  EditableFourZhuCardTheme theme;

  /// 更新卡片内边距（四向），单位像素，必须非负。
  /// 参数：
  /// - left/right/top/bottom: 对应方向的像素值
  /// 返回：
  /// - void
  void updateCardPadding({
    required double left,
    required double right,
    required double top,
    required double bottom,
  });

  /// 更新柱的全局外边距，EdgeInsets 各分量必须 >= 0。
  void updatePillarMargin(EdgeInsets margin);

  /// 针对指定 PillarType 更新差异化外边距，必须非负。
  void updatePerPillarMargin({
    required PillarType type,
    required EdgeInsets margin,
  });

  /// 更新阴影列表（卡片或柱），包括增删改与排序。
  void updateShadows(List<BoxShadow> shadows);

  /// 更新字体家族与回退链（兼容项目内置与系统内置），别名映射由 FontAliasMapper 统一处理。
  void updateFontFamily({
    required String fontFamily,
    List<String>? fontFamilyFallback,
  });
}

/// 解析器：处理不同层级样式的合并与缓存，提升性能。
class EditableFourZhuThemeResolver {
  /// 根据优先级合并 TextStyle（perToken > perRowType/perPillarType > Cell/Pillar 默认 > Card 默认 > App 主题）。
  TextStyle resolveTextStyle(/* params */);

  /// 合成 BoxDecoration（含颜色、圆角、边框、阴影），并缓存常用组合。
  BoxDecoration resolveDecoration(/* params */);
}
```

## 5. 数据流与测量策略
- 编辑器事件 → ThemeController 校验/更新 → ThemeResolver 合成 → EditableFourZhuCardV3 局部刷新 → 预览更新。
- 测量：
  - Card 尺寸 = 内容 + 内边距 + 边框；外边距由父布局决定。
  - Pillar 宽度 = 内容宽度聚合 + 内边距 + 边框；外边距决定列间距（不改变内容聚合）。
  - Cell 尺寸 = 内容 + 内边距 + 边框；分隔行/列装饰不参与测量（保持窄宽/窄高）。
  - 非负约束：margin/padding/borderWidth/radius 统一校验。
  - 拖拽中的尺寸稳定：开始拖拽时冻结尺寸或节流重算，避免抖动。

## 6. 异常与回退
- 外边距负值：拒绝配置并抛出解释性错误（UI Toast + Log）。
- 字体不可用：通过 fontFamilyFallback 回退，并在日志中提示；必要时显示默认字体。
- 不支持的 PillarType 差异化键：拒绝并提示，仅 Year/Month/Day/Hour/DaYun 生效（当前迭代）。

## 7. 预置与导入导出
- StylePresetBar：支持保存当前主题为预置，快速切换；
- JSON I/O：主题 toJson/fromJson，含版本号与兼容策略；
- 预览：切换预置时局部刷新，确保性能稳定。

## 8. 测试策略
- 单元测试：
  - 约束校验（非负 margin/padding/borderWidth/radius）
  - 优先级解析（perToken > perRowType/perPillarType > 默认）
  - 字体回退链解析与别名映射
  - 分隔行/列装饰不参与测量的稳定性
- 金丝雀快照：典型主题（浅色/深色、厚边框、复杂阴影）渲染快照对比
- 交互测试：拖拽 Slider 改变 padding/margin 时，预览局部刷新且无抖动

## 9. 验收标准
- 编辑器组件完整：Card/Pillar/Cell/Typography 四分区均可编辑对应属性；
- 非负约束生效：负值被拒绝并有明确提示；
- 差异化外边距可用：Year/Month/Day/Hour/DaYun 有效，其余待后续扩展；
- 局部刷新顺畅：典型编辑操作无明显卡顿；
- 持久化可用：主题可保存/加载；
- 与 CONSENSUS 对齐：测量与优先级一致。

## 10. 风险与缓解
- 复杂阴影导致性能波动：合成缓存与重绘区域控制；
- 字体跨平台不一致：别名映射与回退链；
- 多重覆盖导致认知负担：UI 中高亮当前生效来源（小标签显示来源层级）。

## 11. 后续扩展
- RowType 独立背景/边框（按需）
- 背景渐变/纹理图片支持
- 更丰富的字体管理（本地导入、在线下载）