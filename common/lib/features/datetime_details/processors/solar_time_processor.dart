import 'dart:math' as math;
import 'package:common/datamodel/location.dart' as my;
import 'package:sweph/sweph.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../models/chinese_date_info.dart';
import '../../../helpers/solar_lunar_datetime_helper.dart';
import '../input_info_params.dart';

class SolarTimeProcessor {
  static Future<SolarTimeProcessResult> process({
    required DateTime standardDateTime,
    required String timezoneStr,
    my.Location? location,
    my.Coordinates? coordinates,
    required ZiShiStrategy ziStrategy,
    required bool calculateTrueSolarTime,
    required bool calculateMeanSolarTime,
  }) async {
    DateTime? meanSolarDatetime;
    ChineseDateInfo? meanSolarChineseInfo;
    DateTime? trueSolarDatetime;
    ChineseDateInfo? trueSolarChineseInfo;

    // 平太阳时计算 - 使用专业算法
    if (location != null) {
      meanSolarDatetime = _calculateMeanSolarTimeAdvanced(
        standardDateTime,
        location.address!.coordinates.longitude,
        timezoneStr,
      );

      meanSolarChineseInfo = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
        meanSolarDatetime,
        ziStrategy,
      );
    }

    // 真太阳时计算 - 使用 Swiss Ephemeris
    if (coordinates != null) {
      trueSolarDatetime = await _calculateTrueSolarTimeAdvanced(
        standardDateTime,
        coordinates.longitude,
        timezoneStr,
      );

      trueSolarChineseInfo = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
        trueSolarDatetime,
        ziStrategy,
      );
    }

    return SolarTimeProcessResult(
      meanSolarDatetime: meanSolarDatetime,
      meanSolarChineseInfo: meanSolarChineseInfo,
      trueSolarDatetime: trueSolarDatetime,
      trueSolarChineseInfo: trueSolarChineseInfo,
    );
  }

  /// 计算平太阳时 - 专业版本
  /// 考虑时区和夏令时的精确计算
  static DateTime _calculateMeanSolarTimeAdvanced(
    DateTime standardDateTime,
    double longitude,
    String timezoneStr,
  ) {
    // 获取时区信息
    final location = tz.getLocation(timezoneStr);
    final zonedDateTime = tz.TZDateTime.from(standardDateTime, location);

    // 转换为 UTC 时间
    final utcTime = zonedDateTime.toUtc();

    // 计算经度时间偏移
    // 15度经度 = 1小时，1度经度 = 4分钟
    final double longitudeOffsetHours = longitude / 15.0;
    final Duration longitudeOffset = Duration(
      seconds: (longitudeOffsetHours * 3600).round(),
    );

    // 应用经度偏移得到地方平太阳时
    return utcTime.add(longitudeOffset);
  }

  /// 计算真太阳时 - 使用 Swiss Ephemeris 专业算法
  /// 这是从 Helpers 中移植的专业实现
  static Future<DateTime> _calculateTrueSolarTimeAdvanced(
    DateTime standardDateTime,
    double longitude,
    String timezoneStr,
  ) async {
    // 获取时区信息
    final location = tz.getLocation(timezoneStr);

    // 将标准时间转换为该时区对应的 TZDateTime
    final zonedDateTime = tz.TZDateTime(
      location,
      standardDateTime.year,
      standardDateTime.month,
      standardDateTime.day,
      standardDateTime.hour,
      standardDateTime.minute,
      standardDateTime.second,
      standardDateTime.millisecond,
      standardDateTime.microsecond,
    );

    // 获取 UTC 时间
    final utcTime = zonedDateTime.toUtc();

    // 计算 UTC 时间的儒略日 (JD UT1)
    final List<double> jdResult = Sweph.swe_utc_to_jd(
      utcTime.year,
      utcTime.month,
      utcTime.day,
      utcTime.hour,
      utcTime.minute,
      utcTime.second.toDouble() +
          (utcTime.millisecond.toDouble() / 1000.0) +
          (utcTime.microsecond.toDouble() / 1000000.0),
      CalendarType.SE_GREG_CAL,
    );

    final double jdUt1 = jdResult[1]; // JD UT1 for time calculations

    // 计算时差方程 (Equation of Time - EoT)
    final double eotMinutes = Sweph.swe_time_equ(jdUt1);

    // 将 EoT 转换为 Duration
    final int eotMicroseconds = (eotMinutes * 60 * 1000000).round();
    final Duration eotDuration = Duration(microseconds: eotMicroseconds);

    // 计算经度偏移
    final Duration longitudeOffset = Duration(
      seconds: (longitude / 15.0 * 3600).round(),
    );

    // 计算真太阳时：UTC + 经度偏移 + 时差方程
    final DateTime trueSolarTimeUtc =
        utcTime.add(longitudeOffset).add(eotDuration);

    return trueSolarTimeUtc;
  }

  /// 计算时差方程 - 备用简化版本
  /// 当 Swiss Ephemeris 不可用时使用
  static double _calculateEquationOfTimeSimplified(DateTime dateTime) {
    final dayOfYear = dateTime.difference(DateTime(dateTime.year, 1, 1)).inDays;
    final double b = 2 * math.pi * (dayOfYear - 81) / 365;

    // 时差方程的近似公式（单位：分钟）
    final double equationMinutes =
        9.87 * math.sin(2 * b) - 7.53 * math.cos(b) - 1.5 * math.sin(b);

    return equationMinutes * 60; // 转换为秒
  }

  /// 验证计算结果的合理性
  static bool _validateSolarTimeResult(DateTime input, DateTime output) {
    final difference = output.difference(input).inHours.abs();
    // 真太阳时与标准时间的差异通常不超过 24 小时
    return difference <= 24;
  }
}

class SolarTimeProcessResult {
  final DateTime? meanSolarDatetime;
  final ChineseDateInfo? meanSolarChineseInfo;
  final DateTime? trueSolarDatetime;
  final ChineseDateInfo? trueSolarChineseInfo;

  SolarTimeProcessResult({
    this.meanSolarDatetime,
    this.meanSolarChineseInfo,
    this.trueSolarDatetime,
    this.trueSolarChineseInfo,
  });

  /// 获取计算摘要信息
  Map<String, dynamic> getSummary() {
    return {
      'hasMeanSolar': meanSolarDatetime != null,
      'hasTrueSolar': trueSolarDatetime != null,
      'meanSolarTime': meanSolarDatetime?.toIso8601String(),
      'trueSolarTime': trueSolarDatetime?.toIso8601String(),
    };
  }
}
