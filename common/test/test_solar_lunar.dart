import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/helpers/solar_time_calculator.dart';
import 'package:common/adapters/lunar_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:tyme/tyme.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  final dateFormat = DateFormat("yyyy-MM-dd HH:mm");

  group("mean solar datetime", skip: true, () {
    final now = DateTime.now();
    test("时间", () {
      tz.TZDateTime tzDate = tz.TZDateTime.now(tz.getLocation("Asia/Shanghai"));
      print(tzDate.timeZoneOffset);
      tz.TZDateTime tzDate2 =
          tz.TZDateTime.now(tz.getLocation("America/Los_Angeles"));
      print(tzDate2.timeZoneOffset);
      expect(tzDate2.timeZone.isDst, true);
      int inHours = tzDate2.timeZoneOffset.inHours;
      if (tzDate2.timeZone.isDst) {
        if (inHours > 0) {
          inHours += 1;
        } else {
          inHours -= 1;
        }
      }
      print(inHours);
      int timezonelat = 15 * inHours;
      print(timezonelat);
      expect(tzDate.difference(tzDate.toUtc()).inHours, 8);
    });

    test("tzDateTime to DateTime", () {
      DateTime now = DateTime.now();
      tz.TZDateTime shanghaiNow =
          tz.TZDateTime.from(now, tz.getLocation("Asia/Shanghai"));
      // DateTime convetedNow = DateTime.parse(shanghaiNow.);
      DateTime converted = DateTime(
          shanghaiNow.year,
          shanghaiNow.month,
          shanghaiNow.day,
          shanghaiNow.hour,
          shanghaiNow.minute,
          shanghaiNow.second,
          shanghaiNow.millisecond);
      final df = DateFormat("yyyy-MM-dd HH:mm:ss");
      df.format(shanghaiNow);
      converted = df.parse(df.format(shanghaiNow));

      // expect(shanghaiNow.toIso8601String(),now.toIso8601String());
      print(now);
      print(converted);
      expect(converted == now, isTrue);
    });
  });
  group("夏令时", skip: true, () {
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
  group('solar & lunar 转换', skip: true, () {
    test('', () {
      final t = tz.getLocation("Asia/Shanghai");
      final s = tz.TZDateTime.now(t);
      print(s.toIso8601String());
      print(DateTime.parse(s.toIso8601String()));
      print(tz.TZDateTime.from(DateTime.parse(s.toIso8601String()), t));
      final lunar = LunarAdapter.fromDate(DateTime.now());
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
      const timezoneString = 'America/Los_Angeles';
      final lasVegas = tz.getLocation(timezoneString);
      final tzNow = tz.TZDateTime.now(lasVegas);
      print("tz: $tzNow");

      final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      var now = DateTime.now();
      print("datetime: $now");
      // Using tyme SolarDay instead of lunar Solar
      var solarDay = SolarDay.fromYmd(now.year, now.month, now.day);
      print("solar $solarDay");
      var result = DateTime(solarDay.getYear(), solarDay.getMonth(), solarDay.getDay(), now.hour, now.minute, now.second);

      expect(dateFormat.format(result), equals(dateFormat.format(now)));
    });
  });

  group('子时', () {
    test("子时", () {
      // Using tyme: Lunar.fromYmdHms(lunarYear, lunarMonth, lunarDay, hour, min, sec)
      // First create LunarDay from lunar date, then get solar date, then add time
      LunarDay lunarDay1 = LunarDay.fromYmd(2025, 8, 11);
      SolarDay solarDay1 = lunarDay1.getSolarDay();
      SolarTime solarTime1 = SolarTime.fromYmdHms(solarDay1.getYear(), solarDay1.getMonth(), solarDay1.getDay(), 23, 10, 30);
      EightChar ec1 = solarTime1.getLunarHour().getEightChar();
      print([ec1.getYear().getName(), ec1.getMonth().getName(), ec1.getDay().getName(), ec1.getHour().getName()]); // [乙巳, 乙酉, 甲辰, 丙子]

      LunarDay lunarDay2 = LunarDay.fromYmd(2025, 8, 12);
      SolarDay solarDay2 = lunarDay2.getSolarDay();
      SolarTime solarTime2 = SolarTime.fromYmdHms(solarDay2.getYear(), solarDay2.getMonth(), solarDay2.getDay(), 0, 10, 30);
      EightChar ec2 = solarTime2.getLunarHour().getEightChar();
      print([ec2.getYear().getName(), ec2.getMonth().getName(), ec2.getDay().getName(), ec2.getHour().getName()]); // [乙巳, 乙酉, 乙巳, 丙子]
    });
  });
}
