import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/helpers/solar_time_calculator.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/utils.dart';
import 'package:common/widgets/eight_chars_input_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:lunar/calendar/Solar.dart';
import 'package:lunar/lunar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  final dateFormat = DateFormat("yyyy-MM-dd HH:mm");

  group("夏令时", () {
    test("是夏令时 1989-7-1 14:00 'Asia/Shanghai'", () {
      final datetime = dateFormat.parse("1989-7-1 14:00");
      final isDST = SolarTimeCalculator.checkIsDST(datetime, "Asia/Shanghai");

      expect(isDST, isTrue);
    });
    test("不是是夏令时  2000-7-1 14:00 'Asia/Shanghai'", () {
      final datetime = dateFormat.parse("2000-7-1 14:00");
      final isDST = SolarTimeCalculator.checkIsDST(datetime, "Asia/Shanghai");

      expect(isDST, isFalse);
    });

    test("北美 是夏令时  2000-7-1 14:00 'America/Los_Angeles'", () {
      final datetime = dateFormat.parse("2000-7-1 14:00");
      final isDST =
          SolarTimeCalculator.checkIsDST(datetime, "America/Los_Angeles");

      expect(isDST, isTrue);
    });
    test("北美 是夏令时  1989-7-1 14:00 'America/Los_Angeles'", () {
      final datetime = dateFormat.parse("1989-7-1 14:00");
      final isDST =
          SolarTimeCalculator.checkIsDST(datetime, "America/Los_Angeles");

      expect(isDST, isTrue);
    });
  });
  group('solar & lunar 转换', () {
    test('', () {
      final t = tz.getLocation("Asia/Shanghai");
      final s = tz.TZDateTime.now(t);
      print(s.toIso8601String());
      print(DateTime.parse(s.toIso8601String()));
      print(tz.TZDateTime.from(DateTime.parse(s.toIso8601String()), t));
      final lunar = Lunar.fromDate(DateTime.now());
      print(lunar);
      print(lunar.getMonth());
      print(lunar.getDay());
    });
    test("子时确定", () {
      final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime today = dateFormat.parse("2025-03-11 23:05:00");
      DateTime tomorrow = dateFormat.parse("2025-03-12 00:05:00");
      var todayLunar = SolarLunarDateTimeHelper.getEighthChars(today);
      var tomorrowLunar = SolarLunarDateTimeHelper.getEighthChars(tomorrow);

      print(todayLunar);
      print(tomorrowLunar);
      expect(tomorrowLunar == todayLunar, isTrue);
      // expect(tomorrowLunar.getBaZi()[2], equals(todayLunar.getBaZi()[2]));
    });
    test('转换为utc', () {
      // SolarLunarDateTimeHelper.fromEightChars(EightChars(
      //     year: JiaZi.YI_SI,
      //     month: JiaZi.JI_MAO,
      //     day: JiaZi.JI_MAO,
      //     hour: JiaZi.GUI_YOU));

      // final shanghai = tz.getLocation('Asia/Shanghai');

      const timezoneString = 'America/Los_Angeles';
      final lasVegas = tz.getLocation(timezoneString);
      final tzNow = tz.TZDateTime.now(lasVegas);
      print("tz: $tzNow");

      final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      var now = DateTime.now();
      print("datetime: $now");
      // now = now.toUtc();
      // print("utc $now");
      var solar = Solar.fromDate(now);
      print(
          "solar $solar ${solar.getHour()}:${solar.getMinute()}:${solar.getSecond()}");
      var result = SolarLunarDateTimeHelper.solarToDateTime(solar);

      expect(dateFormat.format(result), equals(dateFormat.format(now)));
    });
  });
}
