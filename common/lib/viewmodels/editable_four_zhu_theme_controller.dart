import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';
import '../models/layout_template.dart';
import '../themes/editable_four_zhu_card_theme.dart';

/// EditableFourZhuThemeController
/// 主题解析控制器：将 `EditableFourZhuCardTheme` 解析为具体可用的样式与参数。
///
/// 职责与约束：
/// - 字体回退顺序：`Row` 局部 → `theme.global` → `theme.preferred` → 系统默认；
/// - 柱外边距差异化仅限 `{year, month, day, hour, luckCycle}` 范围；
/// - 所有数值参数需为非负数，构造时会进行主题校验。
class EditableFourZhuThemeController {
  /// 构造主题解析控制器。
  ///
  /// 参数：
  /// - [theme]：用于解析的 `EditableFourZhuCardTheme` 主题对象。
  ///
  /// 行为：构造时调用 `ensureValidOrThrow()` 进行主题校验，若存在不合法参数将抛出
  /// `ArgumentError` 异常。
  EditableFourZhuThemeController(this.theme) {
    theme.ensureValidOrThrow();
  }

  /// 主题源对象。用于解析的只读引用。
  final EditableFourZhuCardTheme theme;

  /// 解析并返回有效的 `CardStyle`。
  ///
  /// 功能：在 `base` 的基础上应用 `theme.typography` 的默认值，包括字体家族、字号与颜色，
  /// 遵循统一的字体回退策略。
  ///
  /// 参数：
  /// - [base]：来自布局模板的基础 `CardStyle`。
  ///
  /// 返回：
  /// - `CardStyle`：合并后的样式副本（已应用字体家族/字号/颜色的回退策略）。
  CardStyle resolveCardStyle(CardStyle base) {
    final t = theme.typography;
    final family = _fontFallback(
      rowFamily: null,
      themeFamily: t?.globalFontFamily,
      preferredFamilies: t?.preferredFamilies,
    );
    final size = t?.globalFontSize ?? base.globalFontSize;
    final colorHex = (t?.globalFontColor?.value != null)
        ? _intColorToHex(t!.globalFontColor!.value)
        : base.globalFontColorHex;

    return base.copyWith(
      globalFontFamily: family ?? base.globalFontFamily,
      globalFontSize: size,
      globalFontColorHex: colorHex,
    );
  }

  /// 解析行文本样式参数（字体家族/字号/颜色）。
  ///
  /// 功能：根据 `RowConfig` 与主题排版设置，返回该行的有效文本样式参数。
  ///
  /// 参数：
  /// - [row]：当前布局中的可选 `RowConfig`。
  ///
  /// 返回：
  /// - `(String?, double?, String?)`：依次为 `(fontFamily, fontSize, colorHex)`，
  ///   任意字段为 `null` 表示使用默认值。
  (String?, double?, String?) resolveRowText(RowConfig? row) {
    final t = theme.typography;
    final family = _fontFallback(
      rowFamily: row?.fontFamily,
      themeFamily: t?.globalFontFamily,
      preferredFamilies: t?.preferredFamilies,
    );
    final size = row?.fontSize ?? t?.globalFontSize;
    final colorHex = row?.textColorHex ??
        (t?.globalFontColor?.value != null
            ? _intColorToHex(t!.globalFontColor!.value)
            : null);
    return (family, size, colorHex);
  }

  /// 解析给定 `PillarType` 的柱外边距。
  ///
  /// 功能：返回柱的差异化外边距（若存在），否则返回默认外边距。
  ///
  /// 参数：
  /// - [pillarType]：查询的柱类型。
  ///
  /// 返回：
  /// - `EdgeInsets?`：优先返回差异化配置，其次返回默认值；未配置时返回 `null`。
  EdgeInsets? resolvePillarMargin(PillarType pillarType) {
    final p = theme.pillar;
    if (p == null) return null;
    final specific = p.perPillarMargin?[pillarType];
    return specific ?? p.defaultMargin;
  }

  /// 解析柱内边距。
  ///
  /// 返回：
  /// - `EdgeInsets?`：默认柱内边距；未配置时返回 `null`。
  EdgeInsets? resolvePillarPadding() => theme.pillar?.defaultPadding;

  /// 解析柱边框宽度。
  ///
  /// 返回：
  /// - `double?`：已配置的边框宽度；未设置时返回 `null`。
  double? resolvePillarBorderWidth() => theme.pillar?.borderWidth;

  /// 解析柱边框颜色。
  ///
  /// 返回：
  /// - `Color?`：已配置的边框颜色；未设置时返回 `null`。
  Color? resolvePillarBorderColor() => theme.pillar?.borderColor;

  /// 解析柱圆角半径。
  ///
  /// 返回：
  /// - `double?`：已配置的圆角半径；未设置时返回 `null`。
  double? resolvePillarCornerRadius() => theme.pillar?.cornerRadius;

  /// 解析柱背景颜色。
  ///
  /// 返回：
  /// - `Color?`：已配置的背景颜色；未设置时返回 `null`。
  Color? resolvePillarBackgroundColor() => theme.pillar?.backgroundColor;

  /// 解析卡片级别内边距覆盖值。
  ///
  /// 返回：
  /// - `EdgeInsets?`：卡片级别的内边距覆盖；无覆盖返回 `null`。
  EdgeInsets? resolveCardPadding() => theme.card?.padding;

  /// 解析卡片级别外边距覆盖值。
  ///
  /// 返回：
  /// - `EdgeInsets?`：卡片级别的外边距覆盖；无覆盖返回 `null`。
  EdgeInsets? resolveCardMargin() => theme.card?.margin;

  /// 解析卡片级别圆角半径覆盖值。
  ///
  /// 返回：
  /// - `double?`：圆角半径覆盖；无覆盖返回 `null`。
  double? resolveCardCornerRadius() => theme.card?.cornerRadius;

  /// 解析卡片级别阴影高度覆盖值。
  ///
  /// 返回：
  /// - `double?`：阴影高度覆盖；无覆盖返回 `null`。
  double? resolveCardElevation() => theme.card?.elevation;

  /// 解析卡片级别背景颜色覆盖值。
  ///
  /// 返回：
  /// - `Color?`：背景颜色覆盖；无覆盖返回 `null`。
  Color? resolveCardBackgroundColor() => theme.card?.backgroundColor;

  /// 解析卡片级别边框宽度。
  ///
  /// 返回：
  /// - `double?`：已配置的边框宽度；未设置时返回 `null`。
  double? resolveCardBorderWidth() => theme.card?.borderWidth;

  /// 解析卡片级别边框颜色。
  ///
  /// 返回：
  /// - `Color?`：已配置的边框颜色；未设置时返回 `null`。
  Color? resolveCardBorderColor() => theme.card?.borderColor;

  /// 解析卡片级别阴影配置。
  ///
  /// 功能：当 `shadowColor` 有值时返回包含一个 `BoxShadow` 的列表，否则返回 `null`。
  ///
  /// 返回：
  /// - `List<BoxShadow>?`：已解析的阴影列表或 `null`。
  List<BoxShadow>? resolveCardBoxShadow() {
    final c = theme.card;
    if (c == null) return null;
    final Color? color = (c.shadowColorFollowsBackground == true)
        ? c.backgroundColor
        : c.shadowColor;
    if (color == null) return null;
    final dx = c.shadowOffsetX ?? 0;
    final dy = c.shadowOffsetY ?? 0;
    final blur = c.shadowBlurRadius ?? 0;
    return [BoxShadow(color: color, offset: Offset(dx, dy), blurRadius: blur)];
  }

  /// 解析柱级别阴影配置。
  ///
  /// 功能：当 `shadowColor` 有值时返回包含一个 `BoxShadow` 的列表，否则返回 `null`。
  ///
  /// 返回：
  /// - `List<BoxShadow>?`：已解析的阴影列表或 `null`。
  List<BoxShadow>? resolvePillarBoxShadow() {
    final p = theme.pillar;
    if (p == null) return null;
    final Color? color = (p.shadowColorFollowsBackground == true)
        ? p.backgroundColor
        : p.shadowColor;
    if (color == null) return null;
    final dx = p.shadowOffsetX ?? 0;
    final dy = p.shadowOffsetY ?? 0;
    final blur = p.shadowBlurRadius ?? 0;
    return [BoxShadow(color: color, offset: Offset(dx, dy), blurRadius: blur)];
  }

  /// 字体家族回退策略的应用方法。
  ///
  /// 功能：按照优先级（行局部 → 主题默认 → 主题偏好列表）选择最合适的字体家族。
  ///
  /// 参数：
  /// - [rowFamily]：行局部的字体家族（最高优先级）。
  /// - [themeFamily]：主题级默认字体家族。
  /// - [preferredFamilies]：有序的备选字体列表。
  ///
  /// 返回：
  /// - `String?`：选定的字体家族；若无可用值则返回 `null`（表示使用系统默认）。
  String? _fontFallback({
    String? rowFamily,
    String? themeFamily,
    List<String>? preferredFamilies,
  }) {
    if (rowFamily != null && rowFamily.trim().isNotEmpty) return rowFamily;
    if (themeFamily != null && themeFamily.trim().isNotEmpty)
      return themeFamily;
    final list = preferredFamilies ?? const [];
    for (final f in list) {
      if (f.trim().isNotEmpty) return f;
    }
    return null; // System default
  }

  /// 将 32 位 ARGB 整型颜色值转换为 `#AARRGGBB` 十六进制字符串。
  ///
  /// 参数：
  /// - [value]：ARGB 格式的整型颜色值。
  ///
  /// 返回：
  /// - `String`：格式化为大写的 `#AARRGGBB` 字符串。
  String _intColorToHex(int value) {
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
