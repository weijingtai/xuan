import 'package:flutter/material.dart';

/// CharColorStrategy
/// 提供按字符生成 `perCharColors` 映射的策略接口。
/// 功能：根据主题明暗（`Brightness`）生成稳定的颜色映射；
/// 参数：
/// - [brightness]：当前主题明暗，用于生成不同的调色盘；
/// 返回：
/// - `Map<String, Color>`：键为单个字符（如“甲”“子”），值为对应颜色。
abstract class CharColorStrategy {
  Map<String, Color> buildPerCharColors({required Brightness brightness});
}

/// DefaultCharColorStrategy
/// 默认的字符颜色映射策略：覆盖天干与地支基础集合，其余字符不着色。
/// - 明亮模式使用更鲜明的色相；暗色模式使用降低亮度与饱和度的色相。
class DefaultCharColorStrategy implements CharColorStrategy {
  const DefaultCharColorStrategy();

  @override
  Map<String, Color> buildPerCharColors({required Brightness brightness}) {
    final light = brightness == Brightness.light;

    // 天干 10 个
    final tianGan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    // 地支 12 个
    final diZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

    // 选择基色盘（明/暗）
    final paletteLight = [
      const Color(0xFFEF4444), // 红
      const Color(0xFFF59E0B), // 橙
      const Color(0xFF10B981), // 绿
      const Color(0xFF3B82F6), // 蓝
      const Color(0xFF8B5CF6), // 紫
      const Color(0xFF06B6D4), // 青
      const Color(0xFF84CC16), // 黄绿
      const Color(0xFFEC4899), // 粉
      const Color(0xFF14B8A6), // 松绿
      const Color(0xFFFB7185), // 玫红
      const Color(0xFF6366F1), // 靛蓝
      const Color(0xFFA855F7), // 紫罗兰
    ];

    // 暗色模式降低亮度并提升对比度，避免过亮
    final paletteDark = paletteLight
        .map((c) => Color.alphaBlend(const Color(0x33000000), c))
        .toList();

    final tgColors = _assignColors(tianGan, light ? paletteLight : paletteDark);
    final dzColors = _assignColors(diZhi, light ? paletteLight : paletteDark);

    return {
      ...tgColors,
      ...dzColors,
    };
  }

  /// _assignColors
  /// 将给定字符序列依次映射到调色盘，循环使用色值。
  /// 参数：
  /// - [chars]：需要着色的字符列表；
  /// - [palette]：可用颜色列表；
  /// 返回：字符到颜色的映射。
  Map<String, Color> _assignColors(List<String> chars, List<Color> palette) {
    final out = <String, Color>{};
    for (var i = 0; i < chars.length; i++) {
      out[chars[i]] = palette[i % palette.length];
    }
    return out;
  }
}