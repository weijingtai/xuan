/// 儒略日转换工具类
class JulianDayConverter {
  /// 将DateTime转换为儒略日
  ///
  /// [dateTime] 要转换的日期时间
  ///
  /// 返回儒略日（Julian Day）
  static double dateTimeToJulianDay(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month;
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final second = dateTime.second;
    final millisecond = dateTime.millisecond;

    // 计算日期部分
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;

    // 计算儒略日
    var jd = day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;

    // 计算时间部分（转换为小数天）
    final timeFraction =
        (hour + minute / 60.0 + second / 3600.0 + millisecond / 3600000.0) /
            24.0;

    // 儒略日从中午开始，所以需要减去0.5天
    return jd + timeFraction - 0.5;
  }

  /// 将儒略日转换为DateTime
  ///
  /// [julianDay] 儒略日
  ///
  /// 返回DateTime对象
  static DateTime julianDayToDateTime(double julianDay) {
    // 儒略日从中午开始，所以需要加上0.5天
    final jd = julianDay + 0.5;
    final z = jd.floor();
    final f = jd - z;

    var a = z;
    if (z >= 2299161) {
      final alpha = ((z - 1867216.25) / 36524.25).floor();
      a = z + 1 + alpha - (alpha ~/ 4);
    }

    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final e = ((b - d) / 30.6001).floor();

    final day = b - d - (30.6001 * e).floor();
    final month = e < 14 ? e - 1 : e - 13;
    final year = month > 2 ? c - 4716 : c - 4715;

    // 计算时间部分
    final timeFraction = f * 24;
    final hour = timeFraction.floor();
    final minuteFraction = (timeFraction - hour) * 60;
    final minute = minuteFraction.floor();
    final secondFraction = (minuteFraction - minute) * 60;
    final second = secondFraction.floor();
    final millisecond = ((secondFraction - second) * 1000).round();

    return DateTime(year, month, day, hour, minute, second, millisecond);
  }
}
