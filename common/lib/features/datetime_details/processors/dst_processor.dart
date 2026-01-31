import 'package:timezone/timezone.dart' as tz;
import '../../../models/chinese_date_info.dart';
import '../../../helpers/solar_lunar_datetime_helper.dart';
import '../input_info_params.dart';

class DSTProcessor {
  static Future<DSTProcessResult> process({
    required DateTime standardDateTime,
    required String timezoneStr,
    required ZiShiStrategy ziStrategy,
  }) async {
    final location = tz.getLocation(timezoneStr);
    final tzDateTime = tz.TZDateTime.from(standardDateTime, location);

    // 检查是否处于夏令时
    final isDST = tzDateTime.timeZone.isDst;

    DateTime? removeDSTDatetime;
    ChineseDateInfo? removeDSTChineseInfo;
    DSTTransitionInfo? transitionInfo;

    if (isDST) {
      // 获取标准偏移量（查询同一年非夏令时期间的偏移量）
      final standardOffset =
          _getStandardOffset(location, standardDateTime.year);

      // 精确计算夏令时偏移量
      final dstOffset =
          tzDateTime.timeZone.offset - standardOffset;
      removeDSTDatetime =
          standardDateTime.subtract(dstOffset);

      // 计算移除夏令时后的中国日期信息
      removeDSTChineseInfo = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
        removeDSTDatetime,
        ziStrategy,
      );

      // 获取夏令时转换信息
      transitionInfo = _getDSTTransitionInfo(location, standardDateTime);
    }

    return DSTProcessResult(
      isDST: isDST,
      removeDSTDatetime: removeDSTDatetime,
      removeDSTChineseInfo: removeDSTChineseInfo,
      dstOffset:
          isDST ? _calculateDSTOffset(location, standardDateTime) : Duration.zero,
      transitionInfo: transitionInfo,
    );
  }

  /// 获取标准偏移量（查询同一年非夏令时期间的偏移量）
  static Duration _getStandardOffset(tz.Location location, int year) {
    // 尝试1月1日（通常不是夏令时）
    var testDate = DateTime(year, 1, 1);
    var tzTestDate = tz.TZDateTime.from(testDate, location);

    if (!tzTestDate.timeZone.isDst) {
      return tzTestDate.timeZone.offset;
    }

    // 如果1月1日是夏令时，尝试7月1日
    testDate = DateTime(year, 7, 1);
    tzTestDate = tz.TZDateTime.from(testDate, location);

    if (!tzTestDate.timeZone.isDst) {
      return tzTestDate.timeZone.offset;
    }

    // 如果两个日期都是夏令时，遍历每个月的1号找到非夏令时
    for (int month = 1; month <= 12; month++) {
      testDate = DateTime(year, month, 1);
      tzTestDate = tz.TZDateTime.from(testDate, location);

      if (!tzTestDate.timeZone.isDst) {
        return tzTestDate.timeZone.offset;
      }
    }

    // 如果整年都是夏令时（极少见情况），返回当前偏移量减去1小时作为估算
    final currentDate = DateTime(year, 6, 1);
    final currentTzDate = tz.TZDateTime.from(currentDate, location);
    return currentTzDate.timeZone.offset - const Duration(hours: 1);
  }

  /// 计算夏令时偏移量
  static Duration _calculateDSTOffset(tz.Location location, DateTime dateTime) {
    final tzDateTime = tz.TZDateTime.from(dateTime, location);
    if (!tzDateTime.timeZone.isDst) {
      return Duration.zero;
    }

    final standardOffset = _getStandardOffset(location, dateTime.year);
    final dstOffset = tzDateTime.timeZone.offset - standardOffset;
    return dstOffset;
  }

  /// 获取夏令时转换信息
  static DSTTransitionInfo? _getDSTTransitionInfo(
      tz.Location location, DateTime dateTime) {
    try {
      final year = dateTime.year;

      // 查找该年的夏令时开始和结束时间
      DateTime? dstStart;
      DateTime? dstEnd;

      // 遍历该年的时区转换点
      for (int month = 1; month <= 12; month++) {
        final testDate = DateTime(year, month, 1);
        final tzTestDate = tz.TZDateTime.from(testDate, location);

        if (tzTestDate.timeZone.isDst && dstStart == null) {
          dstStart = _findExactTransition(location, year, month, true);
        } else if (!tzTestDate.timeZone.isDst &&
            dstStart != null &&
            dstEnd == null) {
          dstEnd = _findExactTransition(location, year, month, false);
          break;
        }
      }

      return DSTTransitionInfo(
        dstStart: dstStart,
        dstEnd: dstEnd,
        year: year,
      );
    } catch (e) {
      return null;
    }
  }

  /// 精确查找夏令时转换时间点
  static DateTime? _findExactTransition(
      tz.Location location, int year, int month, bool isDSTStart) {
    // 简化实现，实际可以使用二分查找获得精确时间
    for (int day = 1; day <= 31; day++) {
      try {
        final testDate = DateTime(year, month, day);
        final tzTestDate = tz.TZDateTime.from(testDate, location);

        if (isDSTStart && tzTestDate.timeZone.isDst) {
          return testDate;
        } else if (!isDSTStart && !tzTestDate.timeZone.isDst) {
          return testDate;
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }
}

class DSTProcessResult {
  final bool isDST;
  final DateTime? removeDSTDatetime;
  final ChineseDateInfo? removeDSTChineseInfo;
  final Duration dstOffset;
  final DSTTransitionInfo? transitionInfo;

  DSTProcessResult({
    required this.isDST,
    this.removeDSTDatetime,
    this.removeDSTChineseInfo,
    required this.dstOffset,
    this.transitionInfo,
  });

  /// 获取夏令时偏移小时数
  double get dstOffsetHours => dstOffset.inMilliseconds / (1000 * 60 * 60);

  /// 获取处理摘要
  Map<String, dynamic> getSummary() {
    return {
      'isDST': isDST,
      'offsetHours': dstOffsetHours,
      'hasTransitionInfo': transitionInfo != null,
      'removeDSTTime': removeDSTDatetime?.toIso8601String(),
    };
  }
}

class DSTTransitionInfo {
  final DateTime? dstStart;
  final DateTime? dstEnd;
  final int year;

  DSTTransitionInfo({
    this.dstStart,
    this.dstEnd,
    required this.year,
  });
}
