import 'package:flutter/material.dart';

import '../enums/enum_tian_gan.dart' as tg;
import '../enums/enum_di_zhi.dart' as dz;
import '../themes/gan_zhi_gua_colors.dart';
import '../utils/style_resolver.dart';

/// CardPalette
/// Provides type-safe color mappings for TianGan and DiZhi using enum keys.
/// This avoids fragile string-based lookups and enables compile-time safety.
///
/// Parameters:
/// - [ganColors]: Mapping from `tg.TianGan` to `Color`.
/// - [zhiColors]: Mapping from `dz.DiZhi` to `Color`.
///
/// Returns: A palette container for use by resolvers and widgets.
class CardPalette {
  final Map<tg.TianGan, Color> ganColors;
  final Map<dz.DiZhi, Color> zhiColors;

  const CardPalette({
    required this.ganColors,
    required this.zhiColors,
  });

  /// default
  /// Builds a default palette from `AppColors` to preserve existing behavior.
  ///
  /// Returns: `CardPalette` backed by `AppColors.zodiacGanColors` and `AppColors.zodiacZhiColors`.
  factory CardPalette.defaultPalette() {
    return CardPalette(
      ganColors: AppColors.zodiacGanColors,
      zhiColors: AppColors.zodiacZhiColors,
    );
  }

  /// copyWith
  /// Returns a new `CardPalette` with selectively overridden color maps.
  ///
  /// Parameters:
  /// - [ganColors]: Optional override for `TianGan` color map.
  /// - [zhiColors]: Optional override for `DiZhi` color map.
  ///
  /// Returns: A new `CardPalette` instance with provided overrides applied.
  CardPalette copyWith({
    Map<tg.TianGan, Color>? ganColors,
    Map<dz.DiZhi, Color>? zhiColors,
  }) {
    return CardPalette(
      ganColors: ganColors ?? this.ganColors,
      zhiColors: zhiColors ?? this.zhiColors,
    );
  }

  /// forThemeMode
  /// Builds a palette tailored for a given `ThemeMode`.
  /// This is a placeholder for future theme-aware palettes; currently returns
  /// the default palette to preserve behavior.
  ///
  /// Parameters:
  /// - [mode]: The `ThemeMode` (system/light/dark) used to select palette.
  ///
  /// Returns: A `CardPalette` instance appropriate for the given theme mode.
  static CardPalette forThemeMode(ThemeMode mode) {
    // TODO: Extend with theme-specific mappings when available.
    return CardPalette.defaultPalette();
  }

  /// forLocale
  /// Builds a palette that can vary by `Locale` for internationalization.
  /// This is a placeholder for future locale-aware palettes; currently returns
  /// the default palette to preserve behavior.
  ///
  /// Parameters:
  /// - [locale]: The `Locale` that may influence palette choices.
  ///
  /// Returns: A `CardPalette` instance appropriate for the given locale.
  static CardPalette forLocale(Locale locale) {
    // TODO: Extend with locale-specific mappings when available.
    return CardPalette.defaultPalette();
  }
}

/// PaletteElementColorResolver
/// Resolves colors for TianGan/DiZhi using a type-safe `CardPalette`.
/// Falls back to theme colors when mappings are absent.
///
/// Parameters:
/// - [palette]: The `CardPalette` instance containing enum-keyed color maps.
/// - [ganFallback]: Optional fallback color for TianGan when not found.
/// - [zhiFallback]: Optional fallback color for DiZhi when not found.
///
/// Returns: Concrete colors for UI rendering via `ElementColorResolver` interface.
class PaletteElementColorResolver extends ElementColorResolver {
  final CardPalette palette;
  final Color? ganFallback;
  final Color? zhiFallback;

  const PaletteElementColorResolver(
    this.palette, {
    this.ganFallback,
    this.zhiFallback,
  });

  /// colorForGan
  /// Resolves color for the given `TianGan` using the palette.
  ///
  /// Parameters:
  /// - [gan]: Enum value of `tg.TianGan`.
  /// - [context]: Build context for theme fallback when not found.
  ///
  /// Returns: `Color` from palette or theme primary as fallback.
  @override
  Color colorForGan(tg.TianGan gan, BuildContext context) {
    return palette.ganColors[gan] ??
        ganFallback ??
        Theme.of(context).colorScheme.primary;
  }

  /// colorForZhi
  /// Resolves color for the given `DiZhi` using the palette.
  ///
  /// Parameters:
  /// - [zhi]: Enum value of `dz.DiZhi`.
  /// - [context]: Build context for theme fallback when not found.
  ///
  /// Returns: `Color` from palette or theme secondary as fallback.
  @override
  Color colorForZhi(dz.DiZhi zhi, BuildContext context) {
    return palette.zhiColors[zhi] ??
        zhiFallback ??
        Theme.of(context).colorScheme.secondary;
  }
}
