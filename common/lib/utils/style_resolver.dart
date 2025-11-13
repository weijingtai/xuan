import 'package:flutter/material.dart';

import '../enums/enum_di_zhi.dart';
import '../enums/enum_tian_gan.dart';
import '../enums/layout_template_enums.dart';
import '../models/layout_template.dart';
import '../themes/gan_zhi_gua_colors.dart';

/// Resolves per-row and global styles into concrete Flutter TextStyles and layout values.
/// Implementations should avoid hardcoding; derive from CardStyle/RowConfig and Theme.
abstract class StyleResolver {
  const StyleResolver();

  /// 解析指定行的最终文本样式。
  ///
  /// 参数说明：
  /// - `context`：Flutter 上下文，用于访问主题与配色方案。
  /// - `rowType`：行类型语义键（如天干、地支、纳音等）。
  /// - `cardStyle`：卡片级别的全局样式（字体家族、字号、颜色等）。
  /// - `rowConfig`：当前行的样式配置，包含旧字段与新型 `TextStyleConfig`。
  /// - `overrideColor`：可选的强制颜色覆盖（优先级最高）。
  /// - `fontWeight`：可选的强制字重覆盖（优先级最高）。
  ///
  /// 行为说明：
  /// - 优先使用 `rowConfig.textStyleConfig` 的值（通过 `toTextStyle()`）进行覆盖；
  /// - 若 `textStyleConfig` 缺失，则回退到旧字段（`fontFamily`、`fontSize`、`textColorHex`）；
  /// - 若行与卡片均未提供值，则回退到主题的默认正文样式；
  /// - `overrideColor` 和 `fontWeight` 参数具有最高优先级，最后应用。
  TextStyle resolveTextStyle({
    required BuildContext context,
    required RowType rowType,
    required CardStyle? cardStyle,
    required RowConfig? rowConfig,
    Color? overrideColor,
    FontWeight? fontWeight,
  });

  EdgeInsets resolveRowPadding({
    required BuildContext context,
    required RowType rowType,
    required CardStyle? cardStyle,
    required RowConfig? rowConfig,
  });

  Divider resolveRowDivider({
    required BuildContext context,
    required CardStyle? cardStyle,
    required RowConfig? rowConfig,
  });
}

/// Maps TianGan/DiZhi to semantic colors. Default uses AppColors, but can be replaced.
abstract class ElementColorResolver {
  const ElementColorResolver();

  Color colorForGan(TianGan gan, BuildContext context);
  Color colorForZhi(DiZhi zhi, BuildContext context);
}

class DefaultElementColorResolver extends ElementColorResolver {
  const DefaultElementColorResolver();

  @override
  Color colorForGan(TianGan gan, BuildContext context) {
    return AppColors.zodiacGanColors[gan] ??
        Theme.of(context).colorScheme.primary;
  }

  @override
  Color colorForZhi(DiZhi zhi, BuildContext context) {
    return AppColors.zodiacZhiColors[zhi] ??
        Theme.of(context).colorScheme.secondary;
  }
}

/// Resolves layout metrics (sizes, paddings) to avoid hardcoded values.
abstract class LayoutMetricsResolver {
  const LayoutMetricsResolver();

  /// 计算卡片单元的目标宽度。
  double tileWidth(BuildContext context, {CardStyle? cardStyle});

  /// 计算列头高度，随全局字号缩放。
  double headerHeight(BuildContext context, {CardStyle? cardStyle});

  /// 计算行高：优先使用 `rowConfig.textStyleConfig.fontSize`，回退到旧字段与主题。
  double rowHeight(BuildContext context,
      {RowConfig? rowConfig, CardStyle? cardStyle});
  double slotWidth(BuildContext context);
  double cornerRadius(BuildContext context);
  EdgeInsets tilePadding(BuildContext context);
  EdgeInsets tileMargin(BuildContext context);
  Duration animationDuration(BuildContext context);
  double ghostFillAlpha(BuildContext context);
  double ghostBorderAlpha(BuildContext context);
}

class DefaultLayoutMetricsResolver extends LayoutMetricsResolver {
  const DefaultLayoutMetricsResolver();

  @override
  double tileWidth(BuildContext context, {CardStyle? cardStyle}) {
    // Base width scalable with global font size for accessibility
    final base = (cardStyle?.globalFontSize ??
            Theme.of(context).textTheme.bodyMedium?.fontSize ??
            14) *
        10;
    // Make pillars slightly narrower by lowering the minimum width bound.
    return base.clamp(120, 220);
  }

  @override
  double headerHeight(BuildContext context, {CardStyle? cardStyle}) {
    final fs = cardStyle?.globalFontSize ??
        Theme.of(context).textTheme.titleMedium?.fontSize ??
        16;
    return (fs * 2).clamp(28, 40);
  }

  @override
  double rowHeight(BuildContext context,
      {RowConfig? rowConfig, CardStyle? cardStyle}) {
    // 优先从 TextStyleConfig 读取字号，兼容旧字段并回退到主题
    final cfgFs = rowConfig?.textStyleConfig.fontStyleDataModel.fontSize;
    final fs = cfgFs ??
        rowConfig?.textStyleConfig.fontStyleDataModel.fontSize ??
        cardStyle?.globalFontSize ??
        Theme.of(context).textTheme.bodyMedium?.fontSize ??
        14;
    return (fs * 2).clamp(24, 36);
  }

  @override
  double slotWidth(BuildContext context) => 16.0;

  @override
  double cornerRadius(BuildContext context) => 8.0;

  @override
  EdgeInsets tilePadding(BuildContext context) =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

  @override
  EdgeInsets tileMargin(BuildContext context) =>
      const EdgeInsets.symmetric(horizontal: 6, vertical: 6);

  @override
  Duration animationDuration(BuildContext context) =>
      const Duration(milliseconds: 120);

  @override
  double ghostFillAlpha(BuildContext context) => 0.10;

  @override
  double ghostBorderAlpha(BuildContext context) => 0.35;
}

class DefaultStyleResolver extends StyleResolver {
  const DefaultStyleResolver();

  @override
  TextStyle resolveTextStyle({
    required BuildContext context,
    required RowType rowType,
    required CardStyle? cardStyle,
    required RowConfig? rowConfig,
    Color? overrideColor,
    FontWeight? fontWeight,
  }) {
    final theme = Theme.of(context);

    // 从 TextStyleConfig 派生基础样式（若存在）
    final fromCfg = rowConfig?.textStyleConfig.toTextStyle();

    // 计算最终各字段，优先级：override 参数 > TextStyleConfig > 旧字段 > cardStyle > theme
    final family = fromCfg?.fontFamily ??
        rowConfig?.textStyleConfig.fontStyleDataModel.fontFamily ??
        cardStyle?.globalFontFamily;
    final size = fromCfg?.fontSize ??
        rowConfig?.textStyleConfig.fontStyleDataModel.fontSize ??
        cardStyle?.globalFontSize ??
        theme.textTheme.bodyMedium?.fontSize ??
        14;
    // final parsedRowColor = _parseColor(rowConfig?.textColorHex);
    final parsedGlobalColor = _parseColor(cardStyle?.globalFontColorHex);
    final color = overrideColor ??
        fromCfg?.color ??
        // parsedRowColor ??
        parsedGlobalColor ??
        theme.textTheme.bodyMedium?.color ??
        Colors.black87;
    final weight = fontWeight ?? fromCfg?.fontWeight ?? FontWeight.w400;

    return TextStyle(
      fontFamily: family,
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: 1.0,
    );
  }

  @override
  EdgeInsets resolveRowPadding({
    required BuildContext context,
    required RowType rowType,
    required CardStyle? cardStyle,
    required RowConfig? rowConfig,
  }) {
    final p = rowConfig?.paddingVertical;
    final v = p ?? 4.0;
    return EdgeInsets.symmetric(vertical: v);
  }

  @override
  Divider resolveRowDivider({
    required BuildContext context,
    required CardStyle? cardStyle,
    required RowConfig? rowConfig,
  }) {
    final theme = Theme.of(context);
    final borderType =
        rowConfig?.borderType ?? cardStyle?.dividerType ?? BorderType.solid;
    final color =
        _parseColor(rowConfig?.borderColorHex ?? cardStyle?.dividerColorHex) ??
            theme.dividerColor;
    final thickness = cardStyle?.dividerThickness ?? 1.0;
    return Divider(
        color: color, thickness: borderType == BorderType.none ? 0 : thickness);
  }

  Color? _parseColor(String? hex) {
    if (hex == null) return null;
    final hexColor = hex.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16));
    } else if (hexColor.length == 8) {
      return Color(int.parse(hexColor, radix: 16));
    }
    return null;
  }
}

/// Optional label resolvers to avoid hardcoded text.
typedef RowLabelResolver = String Function(RowType type);
typedef PillarLabelResolver = String Function(PillarType type);
