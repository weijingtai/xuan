import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/themes/char_color_strategy.dart';

/// 验证 DefaultCharColorStrategy 在 Light 模式下生成包含天干与地支的颜色映射，且不存在无关字符键
void main() {
  test('Light 模式：包含天干/地支键，排除无关字符', () {
    const strategy = DefaultCharColorStrategy();
    final colors = strategy.buildPerCharColors(brightness: Brightness.light);

    final tianGan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    final diZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

    for (final tg in tianGan) {
      expect(colors.containsKey(tg), true, reason: '应包含天干：$tg');
      expect(colors[tg], isA<Color>());
    }
    for (final dz in diZhi) {
      expect(colors.containsKey(dz), true, reason: '应包含地支：$dz');
      expect(colors[dz], isA<Color>());
    }

    expect(colors.containsKey('X'), false, reason: '不应包含无关字符键');
  });

  /// 验证同一模式下，生成的映射稳定一致；不同明暗模式下，颜色值应存在差异
  test('稳定性与明暗差异', () {
    const strategy = DefaultCharColorStrategy();
    final lightA = strategy.buildPerCharColors(brightness: Brightness.light);
    final lightB = strategy.buildPerCharColors(brightness: Brightness.light);
    final dark = strategy.buildPerCharColors(brightness: Brightness.dark);

    // 同一模式下稳定
    expect(lightA, lightB);

    // 明暗模式至少有一个字符颜色不同（示例：甲）
    expect(lightA['甲'] != dark['甲'], true,
        reason: 'Light/Dark 模式下，颜色值应有差异');
  });
}