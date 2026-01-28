// test/bazi_calculator_test.dart

import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // --- 基准信息 ---
  // 2025年 年柱: 乙巳
  // 2025年8月 月柱: 甲申
  // 2025-08-11 日柱: 壬子
  // 2025-08-12 日柱: 癸丑

  group('BaziCalculator with splitedZi Strategy (Default)', () {
    test('should use current day pillar for Early Rat Hour (23:00-23:59)', () {
      final time = DateTime(2025, 8, 11, 23, 30);
      const expectedBazi = '乙巳 甲申 壬子 壬子'; // 日柱是11日的“甲辰”

      final actualBazi = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          time, ZiShiStrategy.splitedZi);

      expect(actualBazi.eightChars.toStr(), expectedBazi);
    });

    test('should use next day pillar for Late Rat Hour (00:00-00:59)', () {
      final time = DateTime(2025, 8, 12, 0, 30);
      const expectedBazi = '乙巳 甲申 癸丑 壬子'; // 日柱切换为12日的“癸丑”

      final actualBazi = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          time, ZiShiStrategy.splitedZi);

      expect(actualBazi.eightChars.toStr(), expectedBazi);
    });
  });

  group('BaziCalculator with startFrom23 Strategy', () {
    test('should change day pillar at 23:00', () {
      final time = DateTime(2025, 8, 11, 23, 30);
      // 日柱在23点就应切换为12日的“癸丑”
      const expectedBazi = '乙巳 甲申 癸丑 壬子';

      final actualBazi = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          time, ZiShiStrategy.startFrom23);

      expect(actualBazi.eightChars.toStr(), expectedBazi);
    });
    test('should change day pillar before 23:00', () {
      final time = DateTime(2025, 8, 11, 22, 30);
      // 日柱在23点之前以及为当日干支 “壬子”
      const expectedBazi = '乙巳 甲申 壬子 辛亥';

      final actualBazi = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          time, ZiShiStrategy.startFrom23);

      expect(actualBazi.eightChars.toStr(), expectedBazi);
    });
  });

  group('BaziCalculator with startFrom0 Strategy (Flawed Implementation)', () {
    test('should correctly handle hour before midnight (22:00-23:59)', () {
      final time = DateTime(2025, 8, 11, 23, 30);
      // 期望23:30被视为11日的亥时
      const expectedBazi = '乙巳 甲申 壬子 辛亥';

      final actualBazi = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          time, ZiShiStrategy.startFrom0);

      expect(actualBazi.eightChars.toStr(), expectedBazi);
    });

    test('should FAIL to change day pillar at midnight (00:00-01:59 --- 0:30)',
        () {
      final time = DateTime(2025, 8, 12, 0, 30);

      // 这是我们“期望”的正确结果，即0点成功换日
      const desiredBazi = '乙巳 甲申 癸丑 壬子';

      final actualBazi = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          time, ZiShiStrategy.startFrom0);

      // 1. 断言实际结果是正确的
      expect(actualBazi.eightChars.toStr(), desiredBazi);
    });
    test('should FAIL to change day pillar at midnight (00:00-01:59 --- 1:30)',
        () {
      final time = DateTime(2025, 8, 12, 0, 30);

      // 这是我们“期望”的正确结果，即0点成功换日
      const desiredBazi = '乙巳 甲申 癸丑 壬子';

      final actualBazi = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          time, ZiShiStrategy.startFrom0);

      // 1. 断言实际结果是正确的
      expect(actualBazi.eightChars.toStr(), desiredBazi);
      expect(actualBazi.eightChars.toStr(), isNot('乙巳 甲申 癸丑 癸丑'));
    });
  });
}
