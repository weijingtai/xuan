import 'package:flutter/material.dart';
import 'text_groups.dart';
import 'color_palette.dart';

/// ColorfulCellWidget
/// Renders a single token with either uniform style or per-token palette color
/// based on the `colorful` flag and current brightness.
///
/// Parameters:
/// - [group]: Text group (e.g., tianGan/diZhi) for palette lookup.
/// - [text]: Display text content.
/// - [tokenId]: Token identifier used for palette and per-token overrides.
/// - [uniformStyle]: Base text style (font family/size/weight/color).
/// - [colorful]: Whether to use per-token color from palette.
/// - [palette]: Optional palette; falls back to `defaultGanZhiPalette`.
/// - [brightness]: Optional brightness; defaults to `Theme.of(context).brightness`.
/// - [perTokenColor]: Optional explicit per-token color override.
/// - [perTokenStyle]: Optional full per-token `TextStyle` override.
///
/// Returns: A `Text` widget with resolved style.
class ColorfulCellWidget extends StatelessWidget {
  final TextGroup group;
  final String text;
  final String tokenId;
  final TextStyle uniformStyle;
  final bool colorful;
  final ColorPalette? palette;
  final Brightness? brightness;
  final Color? perTokenColor;
  final TextStyle? perTokenStyle;

  const ColorfulCellWidget({
    super.key,
    required this.group,
    required this.text,
    required this.tokenId,
    required this.uniformStyle,
    required this.colorful,
    this.palette,
    this.brightness,
    this.perTokenColor,
    this.perTokenStyle,
  });

  @override
  Widget build(BuildContext context) {
    final Brightness b = brightness ?? Theme.of(context).brightness;
    final ColorPalette pal = palette ?? defaultGanZhiPalette();

    // Highest priority: explicit per-token full style
    if (perTokenStyle != null) {
      return Text(text, style: perTokenStyle);
    }

    // Next priority: explicit per-token color, overriding uniformStyle.color
    if (perTokenColor != null) {
      return Text(text, style: uniformStyle.copyWith(color: perTokenColor));
    }

    // Colorful mode: resolve palette color by group/tokenId/brightness
    if (colorful) {
      final Color? resolved = pal.getTokenColor(group, tokenId, b);
      if (resolved != null) {
        return Text(text, style: uniformStyle.copyWith(color: resolved));
      }
    }

    // Fallback: uniform style
    return Text(text, style: uniformStyle);
  }
}