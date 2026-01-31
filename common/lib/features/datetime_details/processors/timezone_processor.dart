import 'package:timezone/timezone.dart' as tz;
import '../../../models/chinese_date_info.dart';
import '../../../helpers/solar_lunar_datetime_helper.dart';
import '../input_info_params.dart';

class TimezoneProcessor {
  static Future<TimezoneProcessResult> process({
    required DateTime inputDateTime,
    required String timezoneStr,
    ZiShiStrategy ziStrategy = ZiShiStrategy.startFrom23,
  }) async {
    // 获取时区信息
    final location = tz.getLocation(timezoneStr);

    // 转换为指定时区的时间
    final standardDateTime = tz.TZDateTime.from(inputDateTime, location);

    // 转换为UTC时间
    final utcDateTime = standardDateTime.toUtc();

    // 获取时区详细信息
    final timezoneInfo = _getTimezoneInfo(location, standardDateTime);

    // 计算中国日期信息
    final chineseInfo = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
      standardDateTime,
      ziStrategy,
    );

    return TimezoneProcessResult(
      inputDateTime: inputDateTime,
      standardDateTime: standardDateTime,
      utcDateTime: utcDateTime,
      chineseInfo: chineseInfo,
      timezoneInfo: timezoneInfo,
    );
  }

  /// 获取详细的时区信息
  static TimezoneInfo _getTimezoneInfo(
      tz.Location location, tz.TZDateTime dateTime) {
    final timeZone = dateTime.timeZone;

    // 获取标准偏移量（非夏令时偏移量）
    Duration standardOffset;
    if (timeZone.isDst) {
      // 如果当前是夏令时，查找同一年1月份的偏移量作为标准偏移量
      final winterDate = tz.TZDateTime(location, dateTime.year, 1, 1);
      standardOffset = winterDate.timeZone.offset;
    } else {
      standardOffset = timeZone.offset;
    }

    return TimezoneInfo(
      name: location.name,
      abbreviation: timeZone.abbreviation,
      offset: timeZone.offset,
      standardOffset: standardOffset,
      isDST: timeZone.isDst,
      offsetHours: timeZone.offset.inMilliseconds / (1000 * 60 * 60),
      standardOffsetHours: standardOffset.inMilliseconds / (1000 * 60 * 60),
    );
  }

  /// 验证时区字符串的有效性
  static bool isValidTimezone(String timezoneStr) {
    try {
      tz.getLocation(timezoneStr);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取常用时区列表
  static List<String> getCommonTimezones() {
    return [
      'Asia/Shanghai',
      'Asia/Hong_Kong',
      'Asia/Taipei',
      'Asia/Tokyo',
      'America/New_York',
      'America/Los_Angeles',
      'Europe/London',
      'Europe/Paris',
      'UTC',
    ];
  }
}

class TimezoneProcessResult {
  final DateTime inputDateTime;
  final DateTime standardDateTime;
  final DateTime utcDateTime;
  final ChineseDateInfo chineseInfo;
  final TimezoneInfo timezoneInfo;

  TimezoneProcessResult({
    required this.inputDateTime,
    required this.standardDateTime,
    required this.utcDateTime,
    required this.chineseInfo,
    required this.timezoneInfo,
  });

  /// 获取时区处理摘要
  Map<String, dynamic> getSummary() {
    return {
      'timezone': timezoneInfo.name,
      'offsetHours': timezoneInfo.offsetHours,
      'isDST': timezoneInfo.isDST,
      'inputTime': inputDateTime.toIso8601String(),
      'standardTime': standardDateTime.toIso8601String(),
      'utcTime': utcDateTime.toIso8601String(),
    };
  }
}

class TimezoneInfo {
  final String name;
  final String abbreviation;
  final Duration offset;
  final Duration standardOffset;
  final bool isDST;
  final double offsetHours;
  final double standardOffsetHours;

  TimezoneInfo({
    required this.name,
    required this.abbreviation,
    required this.offset,
    required this.standardOffset,
    required this.isDST,
    required this.offsetHours,
    required this.standardOffsetHours,
  });

  /// 获取夏令时偏移
  double get dstOffsetHours => offsetHours - standardOffsetHours;
}
