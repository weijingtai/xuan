import 'package:common/enums.dart';
import 'package:common/enums/enum_di_zhi.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Year-end boundaries', () {
    test('noDistinguishAt23: 23:30 behaves as next day; month/year stable', () {
      final tPrev = DateTime(2025, 12, 31, 22, 30);
      final tBoundary = DateTime(2025, 12, 31, 23, 30);
      final tNext = DateTime(2026, 1, 1, 0, 30);

      final bPrev = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tPrev, ZiShiStrategy.noDistinguishAt23);
      final bBoundary = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tBoundary, ZiShiStrategy.noDistinguishAt23);
      final bNext = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tNext, ZiShiStrategy.noDistinguishAt23);

      // 23:30 和 次日 0:30 的日柱一致（均按次日），且与 22:30 不同
      expect(bBoundary.eightChars.day, equals(bNext.eightChars.day));
      expect(bPrev.eightChars.day, isNot(equals(bBoundary.eightChars.day)));

      // 跨公历年末一小时，通常不跨节气，月/年柱应保持一致
      expect(bBoundary.eightChars.month, equals(bNext.eightChars.month));
      expect(bBoundary.eightChars.year, equals(bNext.eightChars.year));
    });

    test('distinguishAt0FiveMouse: 0:30 changes day; month/year stable', () {
      final tLate = DateTime(2025, 12, 31, 23, 30); // 当日
      final tEarly = DateTime(2026, 1, 1, 0, 30); // 次日

      final bLate = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tLate, ZiShiStrategy.distinguishAt0FiveMouse);
      final bEarly = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tEarly, ZiShiStrategy.distinguishAt0FiveMouse);

      // 0:30 换日
      expect(bLate.eightChars.day, isNot(equals(bEarly.eightChars.day)));
      // 月/年通常稳定（不在节气边界）
      expect(bLate.eightChars.month, equals(bEarly.eightChars.month));
      expect(bLate.eightChars.year, equals(bEarly.eightChars.year));
    });
  });

  group('Month-end boundaries', () {
    test('noDistinguishAt23 across 04-30 → 05-01', () {
      final tPrev = DateTime(2025, 4, 30, 22, 30);
      final tBoundary = DateTime(2025, 4, 30, 23, 30);
      final tNext = DateTime(2025, 5, 1, 0, 30);

      final bPrev = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tPrev, ZiShiStrategy.noDistinguishAt23);
      final bBoundary = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tBoundary, ZiShiStrategy.noDistinguishAt23);
      final bNext = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tNext, ZiShiStrategy.noDistinguishAt23);

      expect(bBoundary.eightChars.day, equals(bNext.eightChars.day));
      expect(bPrev.eightChars.day, isNot(equals(bBoundary.eightChars.day)));
      expect(bBoundary.eightChars.month, equals(bNext.eightChars.month));
      expect(bBoundary.eightChars.year, equals(bNext.eightChars.year));
    });

    test('distinguishAt0FiveMouse across 04-30 → 05-01', () {
      final tLate = DateTime(2025, 4, 30, 23, 30);
      final tEarly = DateTime(2025, 5, 1, 0, 30);

      final bLate = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tLate, ZiShiStrategy.distinguishAt0FiveMouse);
      final bEarly = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tEarly, ZiShiStrategy.distinguishAt0FiveMouse);

      expect(bLate.eightChars.day, isNot(equals(bEarly.eightChars.day)));
      expect(bLate.eightChars.month, equals(bEarly.eightChars.month));
      expect(bLate.eightChars.year, equals(bEarly.eightChars.year));
    });
  });

  group('BandsStartAt0 hour mapping sanity', () {
    test('0:30 = 子, 2:30 = 丑, 22:30 = 亥', () {
      final tZi = DateTime(2025, 5, 1, 0, 30);
      final tChou = DateTime(2025, 5, 1, 2, 30);
      final tHai = DateTime(2025, 5, 1, 22, 30);

      final bZi = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tZi, ZiShiStrategy.bandsStartAt0);
      final bChou = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tChou, ZiShiStrategy.bandsStartAt0);
      final bHai = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tHai, ZiShiStrategy.bandsStartAt0);

      expect(bZi.eightChars.time.diZhi, equals(DiZhi.ZI));
      expect(bChou.eightChars.time.diZhi, equals(DiZhi.CHOU));
      expect(bHai.eightChars.time.diZhi, equals(DiZhi.HAI));
    });
  });

  group('Exact boundary minutes', () {
    test('noDistinguishAt23 at exact 23:00 and 0:00', () {
      final t23 = DateTime(2025, 12, 31, 23, 0);
      final t00 = DateTime(2026, 1, 1, 0, 0);

      final b23 = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          t23, ZiShiStrategy.noDistinguishAt23);
      final b00 = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          t00, ZiShiStrategy.noDistinguishAt23);

      // 23:00 直接视为次日（统一次日）
      expect(b23.eightChars.day, equals(b00.eightChars.day));
      expect(b23.eightChars.time.diZhi, equals(b00.eightChars.time.diZhi));
    });

    test('distinguishAt0FiveMouse at exact boundaries', () {
      final tLate = DateTime(2025, 12, 31, 23, 59);
      final tEarly = DateTime(2026, 1, 1, 0, 0);

      final bLate = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tLate, ZiShiStrategy.distinguishAt0FiveMouse);
      final bEarly = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tEarly, ZiShiStrategy.distinguishAt0FiveMouse);

      // 0:00 换日；晚子时与早子时的日柱不同
      expect(bLate.eightChars.day, isNot(equals(bEarly.eightChars.day)));
    });
  });

  group('Leap-year and February end', () {
    test('2024-02-29 23:55 → 2024-03-01 00:05 (noDistinguishAt23)', () {
      final tPrev = DateTime(2024, 2, 29, 23, 55);
      final tNext = DateTime(2024, 3, 1, 0, 5);

      final bPrev = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tPrev, ZiShiStrategy.noDistinguishAt23);
      final bNext = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tNext, ZiShiStrategy.noDistinguishAt23);

      // 按统一次日，跨午夜时日柱一致，月/年应通常稳定（非节气边界）
      expect(bPrev.eightChars.day, equals(bNext.eightChars.day));
      expect(bPrev.eightChars.month, equals(bNext.eightChars.month));
      expect(bPrev.eightChars.year, equals(bNext.eightChars.year));
    });

    test('2025-02-28 23:55 → 2025-03-01 00:05 (distinguishAt0FiveMouse)', () {
      final tLate = DateTime(2025, 2, 28, 23, 55);
      final tEarly = DateTime(2025, 3, 1, 0, 5);

      final bLate = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tLate, ZiShiStrategy.distinguishAt0FiveMouse);
      final bEarly = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tEarly, ZiShiStrategy.distinguishAt0FiveMouse);

      // 0:00 换日；月/年通常稳定
      expect(bLate.eightChars.day, isNot(equals(bEarly.eightChars.day)));
      expect(bLate.eightChars.month, equals(bEarly.eightChars.month));
      expect(bLate.eightChars.year, equals(bEarly.eightChars.year));
    });
  });

  group('Fixed Zi strategy across midnight', () {
    test('distinguishAt0Fixed: late Zi (23:30) vs early Zi (0:30)', () {
      final tLate = DateTime(2025, 12, 31, 23, 30);
      final tEarly = DateTime(2026, 1, 1, 0, 30);

      final bLate = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tLate, ZiShiStrategy.distinguishAt0Fixed);
      final bEarly = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tEarly, ZiShiStrategy.distinguishAt0Fixed);

      // 时支固定：晚子时=子，早子时=丑；日柱在 0:30 换日
      expect(bLate.eightChars.time.diZhi, equals(DiZhi.ZI));
      expect(bEarly.eightChars.time.diZhi, equals(DiZhi.CHOU));
      expect(bLate.eightChars.day, isNot(equals(bEarly.eightChars.day)));
    });
  });
}
