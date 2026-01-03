import 'package:common/models/text_style_config.dart';
import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';
import '../models/layout_template.dart';
import '../themes/editable_four_zhu_card_theme.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/models/card_style_config.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/models/pillar_style_config.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/models/base_style_config.dart';

/// EditableFourZhuThemeController
/// Provides read-only resolution helpers that translate EditableFourZhuCardTheme
/// into concrete values used by widgets and resolvers, obeying constraints:
/// - Font fallback order: row → theme.global → theme.preferred → system
/// - Pillar margin differentiation limited to {year, month, day, hour, luckCycle}
/// - Non-negative numeric values are enforced via theme validation
class EditableFourZhuThemeController {
  /// Creates a controller from a theme.
  ///
  /// Parameters:
  /// - [theme]: The `EditableFourZhuCardTheme` to be used for resolution.
  ///
  /// Behavior: Validates the theme on construction and throws `ArgumentError`
  /// if any violation exists.
  EditableFourZhuThemeController(this.theme) {
    theme.ensureValidOrThrow();
  }

  /// The source theme. Immutable reference for resolution.
  final EditableFourZhuCardTheme theme;

  /// Resolves the effective `CardStyle` by merging defaults from `theme.typography`.
  ///
  /// Parameters:
  /// - [base]: The base `CardStyle` sourced from layout template.
  ///
  /// Returns: A `CardStyle` copy with font family/size/color following the
  /// fallback policy.
  CardStyle resolveCardStyle(CardStyle base) {
    final t = theme.typography;
    final family = _fontFallback(
      rowFamily: null,
      themeFamily: t?.globalFontFamily,
      // preferredFamilies: t?.preferredFamilies,
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

  /// Resolves effective row text style parameters (family/size/color) given `RowConfig`.
  ///
  /// Parameters:
  /// - [row]: Optional `RowConfig` from the current layout.
  ///
  /// Returns: A triple `(String?, double?, String?)` representing
  /// `(fontFamily, fontSize, colorHex)`. Any field may be null indicating default usage.
  (String?, double?, String?) resolveRowText(RowConfig? row) {
    final t = theme.typography;
    final family = _fontFallback(
      rowFamily: row?.textStyleConfig.fontStyleDataModel.fontFamily,
      themeFamily: t.globalFontFamily,
    );
    final size =
        row?.textStyleConfig.fontStyleDataModel.fontSize ?? t.globalFontSize;
    return (family, size, null);
  }

  /// Resolves pillar outer margin for the given `PillarType`, applying
  /// differentiation when present.
  ///
  /// Parameters:
  /// - [pillarType]: The pillar type for which margin is queried.
  ///
  /// Returns: The specific margin when provided, else the default margin,
  /// or `null` when not configured.
  EdgeInsets? resolvePillarMargin(PillarType pillarType) {
    final p = theme.pillar;
    if (p == null) return null;
    final specific = p.getBy(pillarType);
    return specific?.margin ?? p.defaultMargin;
  }

  /// Resolves pillar inner padding.
  ///
  /// Returns: The default pillar padding or `null` when not configured.
  EdgeInsets? resolvePillarPadding() => theme.pillar?.defaultPadding;

  /// Resolves pillar border width.
  ///
  /// Returns: The configured border width or `null` when not set.
  double? resolvePillarBorderWidth() => theme.pillar?.borderWidth;

  /// Resolves pillar border color.
  ///
  /// Returns: The configured border color or `null` when not set.
  Color? resolvePillarBorderColor() => theme.pillar?.borderColor;

  /// Resolves pillar corner radius.
  ///
  /// Returns: The configured corner radius or `null` when not set.
  double? resolvePillarCornerRadius() => theme.pillar?.cornerRadius;

  /// Resolves pillar background color.
  ///
  /// Returns: The configured background color or `null` when not set.
  Color? resolvePillarBackgroundColor() => theme.pillar?.backgroundColor;

  PillarStyleConfig? resolvePillarStyleFor(PillarType type) {
    return theme.pillar.getBy(type);
  }

  /// 解析并聚合为全局柱样式配置对象。
  ///
  /// 功能描述：
  /// - 将主题中的柱相关字段（margin/padding/border/background/shadow/cornerRadius）转换为 `PillarStyleConfig`；
  /// - 用于在工作区与 V3 之间进行对象化传参，减少分散参数数量；
  /// 参数说明：无。
  /// 返回值：`PillarStyleConfig`（字段可能为 null 以保持兼容）。
  PillarStyleConfig resolveGlobalPillarStyle() {
    return theme.pillar.global;
    // final p = theme.pillar;
    // final EdgeInsets? margin = p?.defaultMargin;
    // final double bw =
    //     (p?.borderWidth ?? 0).clamp(0.0, double.infinity).toDouble();
    // final BoxBorderStyle? borderny = (bw > 0)
    //     ? BoxBorderStyle(
    //         enabled: true,
    //         width: bw,
    //         lightColor: p?.borderColor ?? Colors.transparent,
    //         darkColor: p?.borderColor ?? Colors.transparent,
    //         radius:
    //             (p?.cornerRadius ?? 0).clamp(0.0, double.infinity).toDouble(),
    //       )
    //     : BoxBorderStyle(
    //         enabled: false,
    //         width: 0,
    //         lightColor: Colors.transparent,
    //         darkColor: Colors.transparent,
    //         radius:
    //             (p?.cornerRadius ?? 0).clamp(0.0, double.infinity).toDouble(),
    //       );
    // final PillarStyleConfig base = PillarStyleConfig(
    //   border: border,
    //   lightBackgroundColor: p?.backgroundColor,
    //   darkBackgroundColor: p?.backgroundColor,
    //   padding: p?.defaultPadding ?? EdgeInsets.zero,
    //   shadow: null,
    // );

    // final List<BoxShadow>? shadows = resolvePillarBoxShadow();
    // return base;
  }

  /// Resolves card-level padding override.
  ///
  /// Returns: The card-level padding override or `null`.
  EdgeInsets? resolveCardPadding() => theme.card?.padding;

  /// Resolves card-level margin override.
  ///
  /// Returns: The card-level margin override or `null`.
  // EdgeInsets? resolveCardMargin() => theme.card?.;

  /// Resolves card-level corner radius override.
  ///
  /// Returns: The corner radius override or `null`.
  double? resolveCardCornerRadius() => theme.card?.border?.radius ?? 0;

  /// Resolves card-level elevation override.
  ///
  /// Returns: The elevation override or `null`.
  // double? resolveCardElevation() => theme.card?.elevation;

  /// Resolves card-level background color override.
  ///
  /// Returns: The background color override or `null`.
  Color? resolveCardBackgroundColor() => theme.card?.lightBackgroundColor;

  Color? resolveCardBackgroundColorBy(Brightness brightness) =>
      theme.card?.resolveBackgroundColor(brightness);

  /// Resolves card-level border width.
  ///
  /// Returns: The configured card border width or `null` when not set.
  double? resolveCardBorderWidth() => theme.card?.border?.width ?? 0;
  double? resolveCardEffectiveBorderWidth() {
    final b = theme.card?.border;
    if (b == null) return 0;
    if (b.enabled != true) return 0;
    return b.width;
  }

  /// Resolves card-level border color.
  ///
  /// Returns: The configured card border color or `null` when not set.
  Color? resolveCardBorderColor() => theme.card?.border?.lightColor;

  Color? resolveCardBorderColorBy(Brightness brightness) =>
      theme.card?.border?.resolveColor(brightness);

  /// Resolves card-level box shadow from theme.
  ///
  /// Returns: A list with a single `BoxShadow` when `shadowColor` is set,
  /// otherwise `null`.
  List<BoxShadow>? resolveCardBoxShadow({
    Brightness? brightness = Brightness.light,
    ColorPreviewMode? colorMode,
  }) {
    final c = theme.card;
    if (c == null) return null;
    if (c.shadow.withShadow != true) return null;

    final resolvedBrightness = brightness ?? Brightness.light;
    final Color? baseColor = c.shadow.followCardBackgroundColor
        ? c.resolveBackgroundColor(resolvedBrightness)
        : c.shadow.resolveColor(resolvedBrightness);
    if (baseColor == null) return null;

    final configuredShadowColor = c.shadow.resolveColor(resolvedBrightness);
    final color = c.shadow.followCardBackgroundColor
        ? baseColor.withAlpha(configuredShadowColor.alpha)
        : configuredShadowColor;
    final dx = c.shadow.offset.dx;
    final dy = c.shadow.offset.dy;
    final blur = c.shadow.blurRadius;
    final spread = c.shadow.spreadRadius;
    return [
      BoxShadow(
        color: color,
        offset: Offset(dx, dy),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }

  /// Resolves pillar-level box shadow from theme.
  ///
  /// Returns: A list with a single `BoxShadow` when `shadowColor` is set,
  /// otherwise `null`.
  List<BoxShadow>? resolvePillarBoxShadow() {
    final p = theme.pillar;
    if (p == null) return null;
    // 开关优先：未启用则不渲染阴影
    if (p.withShadow == false) return null;
    final Color? baseColor = (p.shadowColorFollowsBackground == true)
        ? p.backgroundColor
        : p.shadowColor;
    if (baseColor == null) {
      // 若未提供颜色，但显式启用且要求跟随背景色时，没有背景色则不生效
      if (p.withShadow == true && p.shadowColorFollowsBackground == true) {
        return null;
      }
      return null;
    }
    // 透明度
    final double op = (p.shadowOpacity ?? 0.35).clamp(0.0, 1.0);
    final Color color = baseColor.withOpacity(op);
    final dx = p.shadowOffsetX ?? 0;
    final dy = p.shadowOffsetY ?? 0;
    final blur = p.shadowBlurRadius ?? 0;
    final spread = p.shadowSpreadRadius ?? 0;
    return [
      BoxShadow(
        color: color,
        offset: Offset(dx, dy),
        blurRadius: blur,
        spreadRadius: spread,
      )
    ];
  }

  /// Applies fallback policy to determine the best font family to use.
  ///
  /// Parameters:
  /// - [rowFamily]: The row-specific font family, highest priority when present.
  /// - [themeFamily]: The theme-level default font family.
  /// - [preferredFamilies]: An ordered list of preferred fallback families.
  ///
  /// Returns: A font family string or `null` to indicate system default should be used.
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

  /// Converts a 32-bit ARGB integer color value into a `#AARRGGBB` hex string.
  ///
  /// Parameters:
  /// - [value]: A color integer in ARGB format.
  ///
  /// Returns: A string formatted as `#AARRGGBB` in uppercase.
  String _intColorToHex(int value) {
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
