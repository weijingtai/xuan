import 'package:flutter/material.dart';
import 'text_groups.dart';

/// ColorPalette
/// Provides light/dark token color mappings for specific text groups
/// (e.g., 天干/地支). Supports resolving per-token color by brightness.
///
/// Parameters:
/// - [light]: Map of `TextGroup -> (tokenId -> Color)` for light mode.
/// - [dark]: Map of `TextGroup -> (tokenId -> Color)` for dark mode.
///
/// Returns: A container object with helper methods to resolve colors.
class ColorPalette {
  final Map<TextGroup, Map<String, Color>> light;
  final Map<TextGroup, Map<String, Color>> dark;

  const ColorPalette({required this.light, required this.dark});

  /// getTokenColor
  /// Resolves the token color by `group`, `tokenId`, and `brightness`.
  ///
  /// Parameters:
  /// - [group]: The `TextGroup` (e.g., tianGan, diZhi).
  /// - [tokenId]: The token identifier (e.g., single Chinese char name).
  /// - [brightness]: Current UI brightness to decide light/dark mapping.
  ///
  /// Returns: `Color?` if found, otherwise `null`.
  Color? getTokenColor(TextGroup group, String tokenId, Brightness brightness) {
    final source = brightness == Brightness.dark ? dark : light;
    final groupMap = source[group];
    if (groupMap == null) return null;
    return groupMap[tokenId];
  }
}

/// defaultGanZhiPalette
/// Builds a default light/dark palette for TianGan (十天干) and DiZhi (十二地支).
/// Token IDs are expected to be the exact displayed names (single-char Chinese).
///
/// Returns: A `ColorPalette` with curated colors for both schemes.
ColorPalette defaultGanZhiPalette() {
  // Light scheme: vivid but readable on light backgrounds
  final tianGanLight = <String, Color>{
    '甲': const Color(0xFF1E88E5), // blue
    '乙': const Color(0xFF43A047), // green
    '丙': const Color(0xFFE53935), // red
    '丁': const Color(0xFF8E24AA), // purple
    '戊': const Color(0xFFFDD835), // yellow
    '己': const Color(0xFF6D4C41), // brown
    '庚': const Color(0xFF3949AB), // indigo
    '辛': const Color(0xFF00897B), // teal
    '壬': const Color(0xFF00ACC1), // cyan
    '癸': const Color(0xFF5E35B1), // deep purple
  };
  final diZhiLight = <String, Color>{
    '子': const Color(0xFF1E88E5),
    '丑': const Color(0xFF6D4C41),
    '寅': const Color(0xFF43A047),
    '卯': const Color(0xFF00897B),
    '辰': const Color(0xFF3949AB),
    '巳': const Color(0xFFE53935),
    '午': const Color(0xFFFDD835),
    '未': const Color(0xFF8D6E63),
    '申': const Color(0xFF5E35B1),
    '酉': const Color(0xFF00ACC1),
    '戌': const Color(0xFF8E24AA),
    '亥': const Color(0xFF00796B),
  };

  // Dark scheme: brighter hues with higher contrast on dark backgrounds
  final tianGanDark = <String, Color>{
    '甲': const Color(0xFF64B5F6), // lighter blue
    '乙': const Color(0xFF81C784), // lighter green
    '丙': const Color(0xFFEF5350), // lighter red
    '丁': const Color(0xFFBA68C8), // lighter purple
    '戊': const Color(0xFFFFEE58), // vivid yellow
    '己': const Color(0xFFA1887F), // lighter brown
    '庚': const Color(0xFF7986CB), // lighter indigo
    '辛': const Color(0xFF4DB6AC), // lighter teal
    '壬': const Color(0xFF4DD0E1), // lighter cyan
    '癸': const Color(0xFF9575CD), // lighter deep purple
  };
  final diZhiDark = <String, Color>{
    '子': const Color(0xFF64B5F6),
    '丑': const Color(0xFFA1887F),
    '寅': const Color(0xFF81C784),
    '卯': const Color(0xFF4DB6AC),
    '辰': const Color(0xFF7986CB),
    '巳': const Color(0xFFEF5350),
    '午': const Color(0xFFFFEE58),
    '未': const Color(0xFFBCAAA4),
    '申': const Color(0xFF9575CD),
    '酉': const Color(0xFF4DD0E1),
    '戌': const Color(0xFFBA68C8),
    '亥': const Color(0xFF80CBC4),
  };

  return ColorPalette(
    light: {
      TextGroup.tianGan: tianGanLight,
      TextGroup.diZhi: diZhiLight,
    },
    dark: {
      TextGroup.tianGan: tianGanDark,
      TextGroup.diZhi: diZhiDark,
    },
  );
}