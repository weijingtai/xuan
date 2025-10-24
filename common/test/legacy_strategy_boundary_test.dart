import 'package:common/enums/enum_di_zhi.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Legacy strategy aliases behave like modern ones - Year end', () {
    test('startFrom23 behaves like noDistinguishAt23 across year end', () {
      final tBoundary = DateTime(2025, 12, 31, 23, 30);
      final tNext = DateTime(2026, 1, 1, 0, 30);

      final bLegacy = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tBoundary, ZiShiStrategy.startFrom23);
      final bModern = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tNext, ZiShiStrategy.noDistinguishAt23);

      expect(bLegacy.eightChars.day, equals(bModern.eightChars.day));
      expect(bLegacy.eightChars.month, equals(bModern.eightChars.month));
      expect(bLegacy.eightChars.year, equals(bModern.eightChars.year));
      expect(bLegacy.eightChars.time.diZhi, equals(DiZhi.ZI));
      expect(bModern.eightChars.time.diZhi, equals(DiZhi.ZI));
    });

    test('startFrom0 behaves like distinguishAt0FiveMouse across year end', () {
      final tLate = DateTime(2025, 12, 31, 23, 30);
      final tEarly = DateTime(2026, 1, 1, 0, 30);

      final bLegacyLate = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tLate, ZiShiStrategy.startFrom0);
      final bLegacyEarly = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tEarly, ZiShiStrategy.startFrom0);

      // Day pillar changes at 0:00; hour is Zi for both (five-mouse)
      expect(bLegacyLate.eightChars.day, isNot(equals(bLegacyEarly.eightChars.day)));
      expect(bLegacyLate.eightChars.time.diZhi, equals(DiZhi.ZI));
      expect(bLegacyEarly.eightChars.time.diZhi, equals(DiZhi.ZI));
      // Month/year typically stable across calendar midnight
      expect(bLegacyLate.eightChars.month, equals(bLegacyEarly.eightChars.month));
      expect(bLegacyLate.eightChars.year, equals(bLegacyEarly.eightChars.year));
    });

    test('splitedZi behaves like distinguishAt0FiveMouse across year end', () {
      final tLate = DateTime(2025, 12, 31, 23, 30);
      final tEarly = DateTime(2026, 1, 1, 0, 30);

      final bLegacyLate = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tLate, ZiShiStrategy.splitedZi);
      final bLegacyEarly = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tEarly, ZiShiStrategy.splitedZi);

      expect(bLegacyLate.eightChars.day, isNot(equals(bLegacyEarly.eightChars.day)));
      expect(bLegacyLate.eightChars.time.diZhi, equals(DiZhi.ZI));
      expect(bLegacyEarly.eightChars.time.diZhi, equals(DiZhi.ZI));
      expect(bLegacyLate.eightChars.month, equals(bLegacyEarly.eightChars.month));
      expect(bLegacyLate.eightChars.year, equals(bLegacyEarly.eightChars.year));
    });
  });

  group('Legacy strategy aliases - Month end', () {
    test('startFrom23 behaves like noDistinguishAt23 across month end', () {
      final tBoundary = DateTime(2025, 4, 30, 23, 30);
      final tNext = DateTime(2025, 5, 1, 0, 30);

      final bLegacy = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tBoundary, ZiShiStrategy.startFrom23);
      final bModern = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tNext, ZiShiStrategy.noDistinguishAt23);

      expect(bLegacy.eightChars.day, equals(bModern.eightChars.day));
      expect(bLegacy.eightChars.month, equals(bModern.eightChars.month));
      expect(bLegacy.eightChars.year, equals(bModern.eightChars.year));
    });

    test('startFrom0 behaves like distinguishAt0FiveMouse across month end', () {
      final tLate = DateTime(2025, 4, 30, 23, 30);
      final tEarly = DateTime(2025, 5, 1, 0, 30);

      final bLegacyLate = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tLate, ZiShiStrategy.startFrom0);
      final bLegacyEarly = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tEarly, ZiShiStrategy.startFrom0);

      expect(bLegacyLate.eightChars.day, isNot(equals(bLegacyEarly.eightChars.day)));
      expect(bLegacyLate.eightChars.month, equals(bLegacyEarly.eightChars.month));
      expect(bLegacyLate.eightChars.year, equals(bLegacyEarly.eightChars.year));
    });

    test('splitedZi behaves like distinguishAt0FiveMouse across month end', () {
      final tLate = DateTime(2025, 4, 30, 23, 30);
      final tEarly = DateTime(2025, 5, 1, 0, 30);

      final bLegacyLate = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tLate, ZiShiStrategy.splitedZi);
      final bLegacyEarly = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tEarly, ZiShiStrategy.splitedZi);

      expect(bLegacyLate.eightChars.day, isNot(equals(bLegacyEarly.eightChars.day)));
      expect(bLegacyLate.eightChars.month, equals(bLegacyEarly.eightChars.month));
      expect(bLegacyLate.eightChars.year, equals(bLegacyEarly.eightChars.year));
    });
  });

  group('Legacy exact boundary minutes', () {
    test('startFrom23 at exact 23:00 equals 0:00 (next day unified)', () {
      final t23 = DateTime(2025, 12, 31, 23, 0);
      final t00 = DateTime(2026, 1, 1, 0, 0);

      final b23 = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          t23, ZiShiStrategy.startFrom23);
      final b00 = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          t00, ZiShiStrategy.startFrom23);

      expect(b23.eightChars.day, equals(b00.eightChars.day));
      expect(b23.eightChars.time.diZhi, equals(DiZhi.ZI));
      expect(b00.eightChars.time.diZhi, equals(DiZhi.ZI));
    });

    test('startFrom0 at exact boundaries 23:59 vs 0:00 day change', () {
      final tLate = DateTime(2025, 12, 31, 23, 59);
      final tEarly = DateTime(2026, 1, 1, 0, 0);

      final bLate = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tLate, ZiShiStrategy.startFrom0);
      final bEarly = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tEarly, ZiShiStrategy.startFrom0);

      expect(bLate.eightChars.day, isNot(equals(bEarly.eightChars.day)));
    });
  });
}

