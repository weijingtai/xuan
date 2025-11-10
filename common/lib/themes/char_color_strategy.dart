import 'package:flutter/material.dart';

/// CharColorStrategy
/// 定义“按字符上色”的策略接口，按当前主题明暗生成稳定的字符→颜色映射。
///
/// 函数说明：
/// - buildPerCharColors(brightness): 根据传入的 `Brightness` 返回包含天干/地支字符键的颜色映射；
///   键均为单字字符串（如 '甲'、'子'），便于与历史代码兼容。
abstract class CharColorStrategy {
  /// 构建按字符上色的颜色映射。
  ///
  /// 参数：
  /// - [brightness]：当前主题明暗，用于选择 Light/Dark 调色盘。
  /// 返回：
  /// - `Map<String, Color>`：包含天干与地支全部字符键的颜色映射。
  Map<String, Color> buildPerCharColors({required Brightness brightness});
}

/// DefaultCharColorStrategy
/// 默认实现：提供 Light/Dark 两套调色盘，覆盖天干/地支全部字符。
///
/// 设计要点：
/// - 保证同一明暗模式下生成的映射稳定一致；
/// - Light/Dark 两套盘至少在若干字符上存在明显差异（例如 '甲'），满足测试断言。
class DefaultCharColorStrategy implements CharColorStrategy {
  const DefaultCharColorStrategy();

  // 天干与地支字符集合
  static const List<String> _tianGan = [
    '甲',
    '乙',
    '丙',
    '丁',
    '戊',
    '己',
    '庚',
    '辛',
    '壬',
    '癸'
  ];
  static const List<String> _diZhi = [
    '子',
    '丑',
    '寅',
    '卯',
    '辰',
    '巳',
    '午',
    '未',
    '申',
    '酉',
    '戌',
    '亥'
  ];

  // Light 调色盘：鲜明、对比度更高
  static const List<Color> _lightGanColors = [
    Color(0xFF1565C0), // 甲 - Blue 800
    Color(0xFF2E7D32), // 乙 - Green 800
    Color(0xFFC62828), // 丙 - Red 800
    Color(0xFFAD1457), // 丁 - Pink 800
    Color(0xFF6D4C41), // 戊 - Brown 700
    Color(0xFF00838F), // 己 - Teal 800
    Color(0xFF283593), // 庚 - Indigo 800
    Color(0xFFEF6C00), // 辛 - Orange 800
    Color(0xFF5D4037), // 壬 - Brown 800
    Color(0xFF7B1FA2), // 癸 - Purple 700
  ];
  static const List<Color> _lightZhiColors = [
    Color(0xFF1E88E5), // 子
    Color(0xFF43A047), // 丑
    Color(0xFFE53935), // 寅
    Color(0xFF8E24AA), // 卯
    Color(0xFF6D4C41), // 辰
    Color(0xFF00ACC1), // 巳
    Color(0xFF3949AB), // 午
    Color(0xFFFF8F00), // 未
    Color(0xFF5D4037), // 申
    Color(0xFF8D6E63), // 酉
    Color(0xFF7CB342), // 戌
    Color(0xFF546E7A), // 亥
  ];

  // Dark 调色盘：更克制、提高暗色背景上的可读性
  static const List<Color> _darkGanColors = [
    Color(0xFF90CAF9), // 甲 - Blue 200 (与 Light 不同，满足测试)
    Color(0xFFA5D6A7), // 乙
    Color(0xFFEF9A9A), // 丙
    Color(0xFFF48FB1), // 丁
    Color(0xFFBCAAA4), // 戊
    Color(0xFF80CBC4), // 己
    Color(0xFF9FA8DA), // 庚
    Color(0xFFFFCC80), // 辛
    Color(0xFFBCAAA4), // 壬
    Color(0xFFCE93D8), // 癸
  ];
  static const List<Color> _darkZhiColors = [
    Color(0xFF64B5F6), // 子
    Color(0xFF81C784), // 丑
    Color(0xFFE57373), // 寅
    Color(0xFFBA68C8), // 卯
    Color(0xFFA1887F), // 辰
    Color(0xFF4DB6AC), // 巳
    Color(0xFF7986CB), // 午
    Color(0xFFFFB74D), // 未
    Color(0xFFA1887F), // 申
    Color(0xFFD7CCC8), // 酉
    Color(0xFFAED581), // 戌
    Color(0xFFB0BEC5), // 亥
  ];

  /// 构建 Light/Dark 下的完整字符颜色映射。
  /// 参数：brightness 当前主题明暗。
  /// 返回：包含天干与地支全部字符键的颜色映射。
  @override
  Map<String, Color> buildPerCharColors({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final ganColors = isDark ? _darkGanColors : _lightGanColors;
    final zhiColors = isDark ? _darkZhiColors : _lightZhiColors;

    final map = <String, Color>{};
    for (int i = 0; i < _tianGan.length; i++) {
      map[_tianGan[i]] = ganColors[i % ganColors.length];
    }
    for (int i = 0; i < _diZhi.length; i++) {
      map[_diZhi[i]] = zhiColors[i % zhiColors.length];
    }
    return map;
  }
}
