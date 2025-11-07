import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';
import '../models/layout_template.dart';
import '../themes/editable_four_zhu_card_theme.dart';

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
    final specific = p.perPillarMargin?[pillarType];
    return specific ?? p.defaultMargin;
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

  /// Resolves card-level padding override.
  ///
  /// Returns: The card-level padding override or `null`.
  EdgeInsets? resolveCardPadding() => theme.card?.padding;

  /// Resolves card-level margin override.
  ///
  /// Returns: The card-level margin override or `null`.
  EdgeInsets? resolveCardMargin() => theme.card?.margin;

  /// Resolves card-level corner radius override.
  ///
  /// Returns: The corner radius override or `null`.
  double? resolveCardCornerRadius() => theme.card?.cornerRadius;

  /// Resolves card-level elevation override.
  ///
  /// Returns: The elevation override or `null`.
  double? resolveCardElevation() => theme.card?.elevation;

  /// Resolves card-level background color override.
  ///
  /// Returns: The background color override or `null`.
  Color? resolveCardBackgroundColor() => theme.card?.backgroundColor;

  /// Resolves card-level border width.
  ///
  /// Returns: The configured card border width or `null` when not set.
  double? resolveCardBorderWidth() => theme.card?.borderWidth;

  /// Resolves card-level border color.
  ///
  /// Returns: The configured card border color or `null` when not set.
  Color? resolveCardBorderColor() => theme.card?.borderColor;

  /// Resolves card-level box shadow from theme.
  ///
  /// Returns: A list with a single `BoxShadow` when `shadowColor` is set,
  /// otherwise `null`.
  List<BoxShadow>? resolveCardBoxShadow() {
    final c = theme.card;
    if (c == null) return null;
    final color = c.shadowColor;
    if (color == null) return null;
    final dx = c.shadowOffsetX ?? 0;
    final dy = c.shadowOffsetY ?? 0;
    final blur = c.shadowBlurRadius ?? 0;
    return [BoxShadow(color: color, offset: Offset(dx, dy), blurRadius: blur)];
  }

  /// Resolves pillar-level box shadow from theme.
  ///
  /// Returns: A list with a single `BoxShadow` when `shadowColor` is set,
  /// otherwise `null`.
  List<BoxShadow>? resolvePillarBoxShadow() {
    final p = theme.pillar;
    if (p == null) return null;
    final color = p.shadowColor;
    if (color == null) return null;
    final dx = p.shadowOffsetX ?? 0;
    final dy = p.shadowOffsetY ?? 0;
    final blur = p.shadowBlurRadius ?? 0;
    return [BoxShadow(color: color, offset: Offset(dx, dy), blurRadius: blur)];
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
