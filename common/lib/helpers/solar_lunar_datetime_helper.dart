import 'dart:math';

import 'package:common/datamodel/basic_person_info.dart' as my;
import 'package:common/helpers/solar_time_calculator.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/models/chinese_date_info.dart';
import 'package:common/models/jie_qi_info.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:common/models/seventy_two_phenology.dart';
import 'package:common/enums.dart';
import 'package:intl/intl.dart';
import 'package:tyme/tyme.dart' hide Phenology;
import 'package:sweph/sweph.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:common/features/four_zhu/four_zhu_engine.dart';
import 'package:common/features/four_zhu/strategies/impl/day_23_boundary_strategy.dart';
import 'package:common/features/four_zhu/strategies/impl/day_0_boundary_strategy.dart';
import 'package:common/features/four_zhu/strategies/impl/hour_five_mouse_dun_strategy.dart';
import 'package:common/features/four_zhu/strategies/impl/hour_fixed_zi_ping_strategy.dart';
import '../datamodel/location.dart' as my;
import '../datamodel/location.dart';
import '../features/datetime_details/input_info_params.dart';
import 'package:common/features/datetime_details/zi_strategy_store.dart';
import 'package:common/features/datetime_details/jieqi_phenology_store.dart';
import 'package:common/features/datetime_details/jieqi_entry_strategy_store.dart';

class SolarLunarDateTimeHelper {
  static DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  static final Map<int, DateTime> _chunFenCache = {};

  static DateTime _chunFenForYear(int year) {
    final cached = _chunFenCache[year];
    if (cached != null) return cached;

    final targetName = TwentyFourJieQi.CHUN_FEN.name;
    final df = dateFormat;

    // Use tyme to find Chun Fen (Spring Equinox) - index 0 is Xiao Han, Chun Fen is index 6
    try {
      final solarTerm = SolarTerm.fromIndex(year, 6); // 春分 is at index 6
      final jd = solarTerm.getJulianDay();
      final solarTime = jd.getSolarTime();
      final found = DateTime(
        solarTime.getYear(),
        solarTime.getMonth(),
        solarTime.getDay(),
        solarTime.getHour(),
        solarTime.getMinute(),
        solarTime.getSecond(),
      );
      _chunFenCache[year] = found;
      return found;
    } catch (e) {
      final fallback = DateTime(year, 3, 20, 0, 0, 0);
      _chunFenCache[year] = fallback;
      return fallback;
    }
  }

  static DateTime _chunFenForCycle(DateTime time) {
    final cfThisYear = _chunFenForYear(time.year);
    return time.isBefore(cfThisYear)
        ? _chunFenForYear(time.year - 1)
        : cfThisYear;
  }

  bool checkIsSummerTime(DateTime datetime, String timezone) {
    final tzLocation = tz.getLocation(timezone);
    // 创建时区时间对象（2023-07-01 12:00）
    final tzDatetime = tz.TZDateTime.from(datetime, tzLocation);
    // tzDatetime.timeZone.
    final offset = tzDatetime.timeZoneOffset;
    final standardOffset = tzLocation.currentTimeZone.offset;
    final isDST = offset != standardOffset;
    return isDST;
  }

  static ChineseDateInfo cacluateChineseDateInfo(
      DateTime time, ZiShiStrategy strategy) {
    // 1) 将配置映射为引擎组合
    final (ZiBoundary boundary, ChildHourMode mode) = _mapZiStrategy(strategy);
    final engine =
        FourZhuEngine.create(boundary: boundary, childHourMode: mode);

    // 2) 以“日柱策略锚点”作为四柱的参考时间
    final dayStrategy = switch (boundary) {
      ZiBoundary.at23 => const Day23BoundaryStrategy(),
      ZiBoundary.at0 => const Day0BoundaryStrategy(),
    };
    final anchor = dayStrategy.decideDayAnchor(time);
    final solarDay = SolarDay.fromYmd(time.year, time.month, time.day);
    final lunarDay = solarDay.getLunarDay();
    final lunarMonth = lunarDay.getLunarMonth();
    final lunarYear = lunarMonth.getLunarYear();

    // 3) 计算四柱（八字）
    final ec = engine.calculate(time).eightChars;

    final eightChars = ec;

    // 节气与物候计算策略
    final JieQiType jqType = JieQiPhenologyStore.jieQiType;
    final PhenologyStrategy phStrategy = JieQiPhenologyStore.phenologyStrategy;

    // 计算稳定（定气法）节气边界：使用tyme的SolarTerm
    (String name, DateTime at) _prevJieQiBoundary(DateTime t) {
      final sd = SolarDay.fromYmd(t.year, t.month, t.day);
      final term = sd.getTerm();
      final termJd = term.getJulianDay();
      final termTime = termJd.getSolarTime();
      final termAt = DateTime(
        termTime.getYear(),
        termTime.getMonth(),
        termTime.getDay(),
        termTime.getHour(),
        termTime.getMinute(),
        termTime.getSecond(),
      );

      if (termAt.isAfter(t)) {
        // Current term hasn't started yet, get previous
        final prevTerm = term.next(-1);
        final prevJd = prevTerm.getJulianDay();
        final prevTime = prevJd.getSolarTime();
        return (
          prevTerm.getName(),
          DateTime(
            prevTime.getYear(),
            prevTime.getMonth(),
            prevTime.getDay(),
            prevTime.getHour(),
            prevTime.getMinute(),
            prevTime.getSecond(),
          )
        );
      }
      return (term.getName(), termAt);
    }

    (String name, DateTime at) _nextJieQiBoundary(DateTime t) {
      final sd = SolarDay.fromYmd(t.year, t.month, t.day);
      final term = sd.getTerm();
      final termJd = term.getJulianDay();
      final termTime = termJd.getSolarTime();
      final termAt = DateTime(
        termTime.getYear(),
        termTime.getMonth(),
        termTime.getDay(),
        termTime.getHour(),
        termTime.getMinute(),
        termTime.getSecond(),
      );

      if (!termAt.isAfter(t)) {
        // Current term already passed, get next
        final nextTerm = term.next(1);
        final nextJd = nextTerm.getJulianDay();
        final nextTime = nextJd.getSolarTime();
        return (
          nextTerm.getName(),
          DateTime(
            nextTime.getYear(),
            nextTime.getMonth(),
            nextTime.getDay(),
            nextTime.getHour(),
            nextTime.getMinute(),
            nextTime.getSecond(),
          )
        );
      }
      return (term.getName(), termAt);
    }

    var (baseJieQiName, stabilizingStart) = _prevJieQiBoundary(time);
    final (String nextJieQiName, DateTime stabilizingEnd) =
        _nextJieQiBoundary(time);

    // 平气法：固定间隔（回归年/24）约 15.2184 天
    const double tropicalYearDays = 365.2422;
    final Duration levelingInterval = Duration(
        milliseconds: (tropicalYearDays / 24 * 24 * 60 * 60 * 1000).round());
    DateTime jieQiStartAt = stabilizingStart;
    DateTime jieQiEndAt = stabilizingEnd;

    // 交节精度：若时刻与"交节边界"处于同一桶（时辰/小时/分钟），则视为已进入下一节气
    DateTime _nextStabilizingEndAfter(DateTime start) {
      final sd = SolarDay.fromYmd(start.year, start.month, start.day).next(2);
      final term = sd.getTerm();
      final nextTerm = term.next(1);
      final nextJd = nextTerm.getJulianDay();
      final nextTime = nextJd.getSolarTime();
      return DateTime(
        nextTime.getYear(),
        nextTime.getMonth(),
        nextTime.getDay(),
        nextTime.getHour(),
        nextTime.getMinute(),
        nextTime.getSecond(),
      );
    }

    bool _sameBucket(DateTime a, DateTime b) {
      final p = JieQiEntryStrategyStore.current;
      switch (p) {
        case JieQiEntryPrecision.second:
          return false; // 精确到秒，不做同桶提前进入
        case JieQiEntryPrecision.minute:
          return a.year == b.year &&
              a.month == b.month &&
              a.day == b.day &&
              a.hour == b.hour &&
              a.minute == b.minute;
        case JieQiEntryPrecision.hour:
          return a.year == b.year &&
              a.month == b.month &&
              a.day == b.day &&
              a.hour == b.hour;
        case JieQiEntryPrecision.shichen:
          final (ZiBoundary boundary, ChildHourMode mode) =
              _mapZiStrategy(strategy);
          int shichenLabel(DateTime t) {
            final h = t.hour;
            return boundary == ZiBoundary.at0
                ? h ~/ 2
                : (h >= 23 || h == 0)
                    ? 0
                    : ((h + 1) ~/ 2);
          }
          return shichenLabel(a) == shichenLabel(b);
      }
    }

    bool _entered(DateTime anchorTime, DateTime boundaryTime) {
      final p = JieQiEntryStrategyStore.current;
      if (p == JieQiEntryPrecision.second) {
        return anchorTime.isAfter(boundaryTime) ||
            anchorTime.isAtSameMomentAs(boundaryTime);
      }
      return _sameBucket(anchorTime, boundaryTime) ||
          anchorTime.isAfter(boundaryTime) ||
          anchorTime.isAtSameMomentAs(boundaryTime);
    }

    bool _enteredStrict(DateTime anchorTime, DateTime boundaryTime) {
      return anchorTime.isAfter(boundaryTime) ||
          anchorTime.isAtSameMomentAs(boundaryTime);
    }

    if (jqType == JieQiType.stabilizing) {
      if (!_enteredStrict(time, stabilizingEnd) &&
          _sameBucket(time, stabilizingEnd)) {
        jieQiStartAt = stabilizingEnd;
        jieQiEndAt = _nextStabilizingEndAfter(stabilizingEnd);
        baseJieQiName = nextJieQiName;
      }
    } else {
      final cf = _chunFenForCycle(time);
      final ms = levelingInterval.inMilliseconds;

      var chosen = TwentyFourJieQi.fromName(baseJieQiName);
      final delta = (chosen.order - TwentyFourJieQi.CHUN_FEN.order) % 24;
      DateTime start = cf.add(Duration(milliseconds: ms * delta));
      DateTime end = start.add(levelingInterval);

      while (time.isBefore(start)) {
        chosen = chosen.previous;
        end = start;
        start = start.subtract(levelingInterval);
      }
      while (!time.isBefore(end)) {
        chosen = chosen.next;
        start = end;
        end = start.add(levelingInterval);
      }

      if (!_enteredStrict(time, end) && _sameBucket(time, end)) {
        chosen = chosen.next;
        start = end;
        end = start.add(levelingInterval);
      }

      baseJieQiName = chosen.name;
      jieQiStartAt = start;
      jieQiEndAt = end;
    }

    // 物候计算：基于所选策略（定气或平气）将交节时刻 + n*5 天，并根据 anchor 所在区间选取初/二/三候
    final DateTime phenologyBaseStart = switch (phStrategy) {
      PhenologyStrategy.stabilizingBased =>
        jqType == JieQiType.stabilizing ? jieQiStartAt : stabilizingStart,
      PhenologyStrategy.levelingBased => jieQiStartAt,
    };
    final chosenJieQi = TwentyFourJieQi.fromName(baseJieQiName);
    final List<Phenology> candidates =
        Phenology.phenologyList.where((p) => p.jieqi == chosenJieQi).toList();
    // 物候边界应用交节精度（同桶进入）
    final DateTime b1 = phenologyBaseStart.add(const Duration(days: 5));
    final DateTime b2 = phenologyBaseStart.add(const Duration(days: 10));
    int idx = 0;
    if (_entered(time, b2)) {
      idx = 2;
    } else if (_entered(time, b1)) {
      idx = 1;
    } else {
      idx = 0;
    }
    final Phenology wuHou = candidates.isNotEmpty
        ? candidates[idx]
        : Phenology.phenologyList[WU_HOU.indexOf(solarDay.getPhenologyDay().getPhenology().getName())];
    var threeYuanNineYun = calculateThreeYuanNineYun(lunarYear.getYear());
    return ChineseDateInfo(
        threeYuan: threeYuanNineYun.item1,
        nineYun: threeYuanNineYun.item2,
        eightChars: eightChars,
        phenology: wuHou,
        lunarMonth: lunarMonth.isLeap() ? -lunarMonth.getMonthWithLeap() : lunarMonth.getMonthWithLeap(),
        lunarDay: lunarDay.getDay(),
        isLeapMonth: lunarMonth.isLeap(),
        jieQiInfo: JieQiInfo(
          jieQi: chosenJieQi,
          startAt: jieQiStartAt,
          endAt: jieQiEndAt,
        ));
  }

  static (ZiBoundary, ChildHourMode) _mapZiStrategy(ZiShiStrategy s) {
    switch (s) {
      case ZiShiStrategy.noDistinguishAt23:
      case ZiShiStrategy.startFrom23:
        return (ZiBoundary.at23, ChildHourMode.noDistinguish);
      case ZiShiStrategy.distinguishAt0FiveMouse:
      case ZiShiStrategy.startFrom0:
      case ZiShiStrategy.splitedZi:
        return (ZiBoundary.at0, ChildHourMode.distinguishFiveMouse);
      case ZiShiStrategy.distinguishAt0Fixed:
        return (ZiBoundary.at0, ChildHourMode.distinguishFixed);
      case ZiShiStrategy.bandsStartAt0:
        return (ZiBoundary.at0, ChildHourMode.bandsStart0);
    }
  }

  /// 根据年份计算三元九运
  static Tuple2<YuanYunOrder, NineYun> calculateThreeYuanNineYun(int year) {
    // 以1864年为基准点，每运20年，每元60年，每个大三元180年
    int yearOffset = year - 1864;

    // 使用数学取模运算确保结果在0-179范围内
    int yearInCycle = yearOffset % 180;
    if (yearInCycle < 0) {
      yearInCycle += 180;
    }

    // 计算是第几运（0-8，对应一运到九运）
    int yunIndex = yearInCycle ~/ 20;
    yunIndex = yunIndex.clamp(0, 8);

    // 计算三元
    YuanYunOrder yuanName;
    if (yunIndex < 3) {
      yuanName = YuanYunOrder.upper; // 上元：一、二、三运
    } else if (yunIndex < 6) {
      yuanName = YuanYunOrder.middle; // 中元：四、五、六运
    } else {
      yuanName = YuanYunOrder.lower; // 下元：七、八、九运
    }

    // 计算九运
    NineYun nineYun = NineYun.values[yunIndex];

    return Tuple2(yuanName, nineYun);
  }

  // item1 八字
  // item2 月份
  // item3 日期
  static Tuple4<EightChars, LunarDay, Phenology, JieQiInfo> getEighthChars(
      DateTime time) {
    // 使用全局子时策略映射到引擎和日界
    final (ZiBoundary boundary, ChildHourMode mode) =
        _mapZiStrategy(ZiStrategyStore.current);
    final engine =
        FourZhuEngine.create(boundary: boundary, childHourMode: mode);

    final dayStrategy = switch (boundary) {
      ZiBoundary.at23 => const Day23BoundaryStrategy(),
      ZiBoundary.at0 => const Day0BoundaryStrategy(),
    };
    final anchor = dayStrategy.decideDayAnchor(time);

    // 获取 LunarDay 对应信息（用于月相、节气等）
    final solarDay = SolarDay.fromYmd(anchor.effectiveDateTime.year,
        anchor.effectiveDateTime.month, anchor.effectiveDateTime.day);
    final lunarDay = solarDay.getLunarDay();
    final lunarMonth = lunarDay.getLunarMonth();

    // 通过引擎计算四柱
    final ec = engine.calculate(time).eightChars;

    // 节气与物候策略
    final JieQiType jqType = JieQiPhenologyStore.jieQiType;
    final PhenologyStrategy phStrategy = JieQiPhenologyStore.phenologyStrategy;

    // 稳定（定气）节气起止
    String baseJieQiName;
    DateTime stabilizingStart;
    DateTime stabilizingEnd;

    final term = solarDay.getTerm();
    final termJd = term.getJulianDay();
    final termTime = termJd.getSolarTime();
    final termAt = DateTime(
      termTime.getYear(),
      termTime.getMonth(),
      termTime.getDay(),
      termTime.getHour(),
      termTime.getMinute(),
      termTime.getSecond(),
    );

    final nextTerm = term.next(1);
    final nextJd = nextTerm.getJulianDay();
    final nextTime = nextJd.getSolarTime();
    final nextAt = DateTime(
      nextTime.getYear(),
      nextTime.getMonth(),
      nextTime.getDay(),
      nextTime.getHour(),
      nextTime.getMinute(),
      nextTime.getSecond(),
    );

    if (termAt.isAfter(time)) {
      // Term hasn't started yet
      final prevTerm = term.next(-1);
      final prevJd = prevTerm.getJulianDay();
      final prevTime = prevJd.getSolarTime();
      baseJieQiName = prevTerm.getName();
      stabilizingStart = DateTime(
        prevTime.getYear(),
        prevTime.getMonth(),
        prevTime.getDay(),
        prevTime.getHour(),
        prevTime.getMinute(),
        prevTime.getSecond(),
      );
      stabilizingEnd = termAt;
    } else {
      baseJieQiName = term.getName();
      stabilizingStart = termAt;
      stabilizingEnd = nextAt;
    }

    // 平气法：固定间隔（回归年/24）约 15.2184 天
    const double tropicalYearDays = 365.2422;
    final Duration levelingInterval = Duration(
        milliseconds: (tropicalYearDays / 24 * 24 * 60 * 60 * 1000).round());

    // Get previous term for leveling calculation
    final prevTerm = term.next(-1);
    final prevJd = prevTerm.getJulianDay();
    final prevTime = prevJd.getSolarTime();
    final DateTime prevStabilizingStart = DateTime(
      prevTime.getYear(),
      prevTime.getMonth(),
      prevTime.getDay(),
      prevTime.getHour(),
      prevTime.getMinute(),
      prevTime.getSecond(),
    );
    final DateTime levelingStart = prevStabilizingStart.add(levelingInterval);
    final DateTime levelingEnd = levelingStart.add(levelingInterval);

    DateTime jieQiStartAt =
        jqType == JieQiType.stabilizing ? stabilizingStart : levelingStart;
    DateTime jieQiEndAt =
        jqType == JieQiType.stabilizing ? stabilizingEnd : levelingEnd;

    (DateTime nextStabilizingStart, String nextStabilizingName)
        _nextStabilizing(SolarDay sd) {
      final t = sd.getTerm();
      final nt = t.next(1);
      final ntJd = nt.getJulianDay();
      final ntTime = ntJd.getSolarTime();
      return (
        DateTime(
          ntTime.getYear(),
          ntTime.getMonth(),
          ntTime.getDay(),
          ntTime.getHour(),
          ntTime.getMinute(),
          ntTime.getSecond(),
        ),
        nt.getName()
      );
    }

    DateTime nextLevelingStart = levelingStart.add(levelingInterval);
    bool _sameBucket(DateTime a, DateTime b) {
      final p = JieQiEntryStrategyStore.current;
      switch (p) {
        case JieQiEntryPrecision.second:
          return false;
        case JieQiEntryPrecision.minute:
          return a.year == b.year &&
              a.month == b.month &&
              a.day == b.day &&
              a.hour == b.hour &&
              a.minute == b.minute;
        case JieQiEntryPrecision.hour:
          return a.year == b.year &&
              a.month == b.month &&
              a.day == b.day &&
              a.hour == b.hour;
        case JieQiEntryPrecision.shichen:
          final (ZiBoundary boundary, ChildHourMode mode) =
              _mapZiStrategy(ZiStrategyStore.current);
          int shichenLabel(DateTime t) {
            final h = t.hour;
            return boundary == ZiBoundary.at0
                ? h ~/ 2
                : (h >= 23 || h == 0)
                    ? 0
                    : ((h + 1) ~/ 2);
          }
          return shichenLabel(a) == shichenLabel(b);
      }
    }

    bool _entered(DateTime anchorTime, DateTime boundaryTime) {
      final p = JieQiEntryStrategyStore.current;
      if (p == JieQiEntryPrecision.second) {
        return anchorTime.isAfter(boundaryTime) ||
            anchorTime.isAtSameMomentAs(boundaryTime);
      }
      return _sameBucket(anchorTime, boundaryTime) ||
          anchorTime.isAfter(boundaryTime) ||
          anchorTime.isAtSameMomentAs(boundaryTime);
    }

    if (jqType == JieQiType.stabilizing) {
      final (DateTime nextStart, String nextName) = _nextStabilizing(solarDay);
      if (!_entered(anchor.effectiveDateTime, stabilizingStart) &&
          _sameBucket(anchor.effectiveDateTime, stabilizingStart)) {
        jieQiStartAt = nextStart;
        // Get term after next
        final nt = term.next(2);
        final ntJd = nt.getJulianDay();
        final ntTime = ntJd.getSolarTime();
        jieQiEndAt = DateTime(
          ntTime.getYear(),
          ntTime.getMonth(),
          ntTime.getDay(),
          ntTime.getHour(),
          ntTime.getMinute(),
          ntTime.getSecond(),
        );
        baseJieQiName = nextName;
      }
    } else {
      if (!_entered(anchor.effectiveDateTime, levelingStart) &&
          _sameBucket(anchor.effectiveDateTime, levelingStart)) {
        jieQiStartAt = nextLevelingStart;
        jieQiEndAt = nextLevelingStart.add(levelingInterval);
        baseJieQiName = TwentyFourJieQi.fromName(baseJieQiName).next.name;
      }
    }

    // 物候 - 根据策略确定基准
    final DateTime phenologyBaseStart =
        phStrategy == PhenologyStrategy.stabilizingBased
            ? stabilizingStart
            : levelingStart;
    final chosenJieQi = TwentyFourJieQi.fromName(baseJieQiName);
    final List<Phenology> candidates =
        Phenology.phenologyList.where((p) => p.jieqi == chosenJieQi).toList();
    final DateTime b1 = phenologyBaseStart.add(const Duration(days: 5));
    final DateTime b2 = phenologyBaseStart.add(const Duration(days: 10));
    int idx = 0;
    if (_entered(anchor.effectiveDateTime, b2)) {
      idx = 2;
    } else if (_entered(anchor.effectiveDateTime, b1)) {
      idx = 1;
    } else {
      idx = 0;
    }
    final Phenology wuHou = candidates.isNotEmpty
        ? candidates[idx]
        : Phenology.phenologyList[WU_HOU.indexOf(solarDay.getPhenologyDay().getPhenology().getName())];

    return Tuple4(
      ec,
      lunarDay,
      wuHou,
      JieQiInfo(
        jieQi: chosenJieQi,
        startAt: jieQiStartAt,
        endAt: jieQiEndAt,
      ),
    );
  }

  static DivinationDatetimeModel calculateNormalQueryDateTimeInfo(
      {required String queryUuid,
      required DateTime dateTime,
      required String timezoneStr,
      required Location? location,
      required bool isDST,
      required bool isSeersLocation}) {
    final Tuple4<EightChars, LunarDay, Phenology, JieQiInfo> chineseDateInfo =
        getEighthChars(dateTime);

    final LunarDay lunarDay = chineseDateInfo.item2;
    final lunarMonth = lunarDay.getLunarMonth();
    bool isLeapMonth = lunarMonth.isLeap();
    final monthValue = lunarMonth.getMonthWithLeap();
    final result = DivinationDatetimeModel.standard(
      uuid: Uuid().v4(),
      queryUuid: queryUuid,
      datetime: dateTime,
      timezoneStr: timezoneStr,
      bazi: chineseDateInfo.item1,
      lunarMonth: monthValue,
      lunarDay: lunarDay.getDay(),
      isLeapMonth: isLeapMonth,
      isSeersLocation: isSeersLocation,
      jieQiInfo: chineseDateInfo.item4,
      isDst: isDST,
      location: location,
    );

    return result;
  }

  // @params : dateTime 需要时校正后的时间
  static DivinationDatetimeModel calculateRemoveDSTQueryDateTimeInfo(
      {required String queryUuid,
      required DateTime dateTime,
      required String timezoneStr,
      required int hourAdjusted,
      required Location? location,
      required bool isSeersLocation}) {
    final chineseDateInfo = getEighthChars(dateTime);
    final LunarDay lunarDay = chineseDateInfo.item2;
    final lunarMonth = lunarDay.getLunarMonth();
    bool isLeapMonth = lunarMonth.isLeap();
    final monthValue = lunarMonth.getMonthWithLeap();
    return DivinationDatetimeModel.removeDST(
        uuid: Uuid().v4(),
        queryUuid: queryUuid,
        hourAdjusted: hourAdjusted,
        datetime: dateTime,
        timezoneStr: timezoneStr,
        bazi: chineseDateInfo.item1,
        lunarMonth: monthValue,
        lunarDay: lunarDay.getDay(),
        isLeapMonth: isLeapMonth,
        isSeersLocation: isSeersLocation,
        jieQiInfo: chineseDateInfo.item4,
        location: location);
  }

  static DivinationDatetimeModel calculateMeanSolarQueryDateTimeInfo(
      String queryUuid,
      tz.TZDateTime tzDateTime,
      my.Address address,
      bool isSeersLocation) {
    final meanDateTime = calculateMeanSolarTimeUtc(
        tzDateTime,
        address.city?.coordinates.longitude ??
            address.province.coordinates.longitude);

    final chineseDateInfo = getEighthChars(meanDateTime);
    final LunarDay lunarDay = chineseDateInfo.item2;
    final lunarMonth = lunarDay.getLunarMonth();
    bool isLeapMonth = lunarMonth.isLeap();
    final monthValue = lunarMonth.getMonthWithLeap();

    return DivinationDatetimeModel.meanSolar(
        uuid: Uuid().v4(),
        queryUuid: queryUuid,
        datetime: meanDateTime,
        timezoneStr: tzDateTime.timeZoneName,
        bazi: chineseDateInfo.item1,
        lunarMonth: monthValue,
        lunarDay: lunarDay.getDay(),
        isLeapMonth: isLeapMonth,
        isSeersLocation: isSeersLocation,
        address: address,
        jieQiInfo: chineseDateInfo.item4);
  }

  /// 方法将会自动处理夏令时，即，将时间调整到夏令时前的时间
  @Deprecated("")
  static tz.TZDateTime calculateMeanSolarTZDateTime(
      tz.TZDateTime tzDatetime, double longtitude) {
    if (tzDatetime.timeZone.isDst) {
      tzDatetime = tzDatetime.subtract(Duration(hours: 1));
    }
    final dateTime = tzDatetime.toUtc().toDateTime();
    final longitudeHour = longtitude / 15.0;
    return tz.TZDateTime.from(
        dateTime.add(Duration(minutes: (longitudeHour * 60).toInt())),
        tzDatetime.location);
  }

  static DateTime calculateMeanSolarTimeUtc(
      tz.TZDateTime tzDatetime, double longitude) {
    // 1. 获取原始时间点对应的UTC时间 (这已正确处理了原始时区的DST和标准偏移)
    final DateTime utcInstant = tzDatetime.toUtc();

    // 2. 计算经度带来的时差 (小时)
    //    东经为正，西经为负 (或者根据你的经度约定调整)
    final double longitudeOffsetHours = longitude / 15.0;

    // 3. 将时差转换为Duration，保持精度
    //    1 hour = 3,600,000,000 microseconds
    final double offsetMicroseconds = longitudeOffsetHours * 3600 * 1000000;
    final Duration meanTimeOffset =
        Duration(microseconds: offsetMicroseconds.round());

    // 4. 将时差应用于UTC时间点
    final DateTime meanSolarUtc = utcInstant.add(meanTimeOffset);

    return meanSolarUtc;
  }

  DateTime calculateMeanSolarTime(tz.TZDateTime datetime, double longitude) {
    final utcNow = DateTime.now().toUtc();
    // 计算经度时间偏移（东经为正，西经为负）
    final hoursOffset = longitude / 15;
    final totalSeconds = (hoursOffset * 3600).round();
    return utcNow.add(Duration(seconds: totalSeconds));
  }

  static DivinationDatetimeModel calculateTrueSolarQueryDateTimeInfo(
      String queryUuid,
      DateTime localDatetime,
      String timezoneStr,
      my.Coordinates coordinates,
      bool isSeersLocation) {
    DateTime trueSolarTime = calculateTrueSolarTimeFromLocalClockTime(
        localDatetime, coordinates.longitude, timezoneStr);
    final chineseDateInfo = getEighthChars(trueSolarTime);
    final LunarDay lunarDay = chineseDateInfo.item2;
    final lunarMonth = lunarDay.getLunarMonth();
    bool isLeapMonth = lunarMonth.isLeap();
    final monthValue = lunarMonth.getMonthWithLeap();
    return DivinationDatetimeModel.trueSolar(
      uuid: Uuid().v4(),
      queryUuid: queryUuid,
      datetime: trueSolarTime,
      timezoneStr: timezoneStr,
      bazi: chineseDateInfo.item1,
      lunarMonth: monthValue,
      lunarDay: lunarDay.getDay(),
      isLeapMonth: isLeapMonth,
      isSeersLocation: isSeersLocation,
      coordinates: coordinates,
      jieQiInfo: chineseDateInfo.item4,
    );
  }

  // 这个函数将接收一个“本地钟表时间”，并正确的计算真太阳时
  static DateTime calculateTrueSolarTimeFromLocalClockTime(
      DateTime localClockTime, double longitude, String timezoneId) {
    // 1. 初始化时区数据 (如果尚未初始化)
    // tzdata.initializeTimeZones();
    final location = tz.getLocation(timezoneId);

    // 2. 将传入的本地钟表时间转换为该时区对应的 TZDateTime
    // 这是关键一步，确保我们正确地处理了本地时间的时区和夏令时偏移
    final zonedDateTime = tz.TZDateTime(
        location,
        localClockTime.year,
        localClockTime.month,
        localClockTime.day,
        localClockTime.hour,
        localClockTime.minute,
        localClockTime.second,
        localClockTime.millisecond,
        localClockTime.microsecond);

    // 3. 获取该 TZDateTime 对应的 UTC 时间，这是 Sweph.swe_utc_to_jd 所需的
    final utcTime = zonedDateTime.toUtc();

    // 4. 计算 UTC 时间的儒略日 (JD UT1)
    final List<double> jdResult = Sweph.swe_utc_to_jd(
        utcTime.year,
        utcTime.month,
        utcTime.day,
        utcTime.hour,
        utcTime.minute,
        utcTime.second.toDouble() +
            (utcTime.millisecond.toDouble() / 1000.0) +
            (utcTime.microsecond.toDouble() / 1000000.0), // 包含毫秒和微秒以提高精度
        CalendarType.SE_GREG_CAL);

    final double jdUt1 = jdResult[1]; // JD UT1 for time calculations

    // 5. 计算时差 (Equation of Time - EoT)
    final double eotMinutes = Sweph.swe_time_equ(jdUt1); // 方程时，单位：分钟

    // 6. 将 EoT 转换为 Duration
    final int eotMicroseconds = (eotMinutes * 60 * 1000000).round();
    final Duration eotDuration = Duration(microseconds: eotMicroseconds);

    // 7. 计算地方平太阳时 (Local Mean Solar Time - LMST)
    // LMST = UTC + 经度 / 15 (小时)
    // 或者更准确地说，从 UTC 加上一个经度相关的偏移来得到 LMST
    // 15度经度 = 1小时
    // 1度经度 = 4分钟 (1/15 小时 * 60 分钟)
    final double longitudeOffsetMinutes = longitude * 4.0; // 经度偏移，单位：分钟
    final Duration longitudeOffsetDuration =
        Duration(microseconds: (longitudeOffsetMinutes * 60 * 1000000).round());

    // 地方平太阳时 (LMST) 是基于 UTC，再根据经度调整的时间。
    // 这不是一个简单的 `add` 操作，因为 `utcTime` 已经是 UTC。
    // `utcTime` 加上 `longitudeOffsetDuration` 得到的是 **相对于格林威治子午线的平太阳时**
    // (Local Mean Time at your Longitude).
    // 如果 meanSolarTime 被假定为 LMST，那么它应该已经包含了经度偏移。

    // **这里是修正的核心：**
    // 你的原始代码 `meanSolarTime.add(Duration(microseconds: eotMicroseconds))`
    // 假设 `meanSolarTime` 就是 LMST。
    // 但如果 `meanSolarTime` 是本地钟表时间 (LCT)，那么需要：
    // LCT -> UTC (已做) -> LMST -> LAT

    // 正确的逻辑应该是：
    // 我们传入的 `localClockTime` 是地方钟表时间。
    // 我们想得到的是该地方的真太阳时。
    // `真太阳时 (LAT) = 地方平太阳时 (LMST) + EoT`
    // `LMST = UTC + (经度 / 15)`
    // 所以，`LAT = UTC + (经度 / 15) + EoT`

    // `utcTime` 我们已经有了。
    // 经度偏移 Duration：
    final Duration longitudeOffset =
        Duration(seconds: (longitude / 15.0 * 3600).round());

    // 将 UTC 时间转换为对应经度的平太阳时，然后加上 EoT
    final DateTime trueSolarTimeUtc =
        utcTime.add(longitudeOffset).add(eotDuration);

    // 最终返回的时间最好是转换为用户指定时区的 TZDateTime，或者直接返回 UTC
    // 如果要返回一个表示“真太阳时”的 DateTime 对象，它本质上是一个与当地天文事件同步的时间。
    // 通常，这个结果仍然以某种 UTC 或地方平太阳时为基准。
    // 为了方便用户理解，我们可以将其转换回与原始 `localClockTime` 相同的时区，
    // 但其内部时间轴已经是真太阳时。
    // 返回这个时间，但它的 `DateTime` 对象本身是 UTC 形式，方便后续处理
    // 如果你想得到一个“在当地时间”的真太阳时，你需要重新应用时区偏移。
    // 但是，真太阳时本身就是“地方”概念，最好是UTC或LMST表示。

    // 为了避免进一步混淆，我们返回一个 TZDateTime，它基于真太阳时的时间点，
    // 并放置在用户提供的 `timezoneId` 所代表的时区中。
    // 但请注意，这个 TZDateTime 的“墙上时间”可能不再与你的系统钟表时间规则对应。
    // 它代表的是天文学上的“地方真太阳时”。
    // 这通常会返回一个 UTC 时间，因为这是天文计算的基准。
    return trueSolarTimeUtc; // 返回UTC时间，因为这是最精确的表示。
  }

  static DateTime calculateTrueSolarTimeByMeanSolarTimeV2(
      DateTime meanSolarTime, double longitude) {
    // 返回结果“1”为TT时间（地球时间），“2”为UT1(世界时间)的儒略历
    final List<double> jdResult = Sweph.swe_utc_to_jd(
        meanSolarTime.year,
        meanSolarTime.month,
        meanSolarTime.day,
        meanSolarTime.hour,
        meanSolarTime.minute,
        meanSolarTime.second.toDouble() +
            (meanSolarTime.millisecond.toDouble() / 1000.0), // 包含毫秒以提高精度
        CalendarType.SE_GREG_CAL);

    // TT 时间用于天体计算，UT时间用于修正本地,
    // 计算真太阳时使用 UT (更准确地说是从UT1派生的儒略日)
    final double jd =
        jdResult[1]; // jdResult[0] is JD ET (TT), jdResult[1] is JD UT1
    final double eotMinutes = Sweph.swe_time_equ(jd); // 方程时，单位：分钟

    // 假设: 输入的 meanSolarTime 已经是“地方平太阳时”(Local Mean Solar Time - LMST)的钟面读数。
    // 真太阳时 (Local Apparent Time - LAT) = 地方平太阳时 (LMST) + 时差 (EoT)
    // Swiss Ephemeris swe_time_equ 定义: EoT = apparent_time - mean_time
    // 所以: apparent_time = mean_time + EoT

    // 将以分钟为单位的 EoT 转换为 Duration，保持精度
    // 1 分钟 = 60 秒 = 60 * 1000 * 1000 微秒
    final int eotMicroseconds = (eotMinutes * 60 * 1000000).round();

    return meanSolarTime.add(Duration(microseconds: eotMicroseconds));
  }

  @Deprecated(" using calculateTrueSolarTimeByMeanSolarTimeV2")
  static DateTime calculateTrueSolarTimeByMeanSolarTime(
      DateTime meanSolarTime, double longitude) {
    // 返回结果“1”为TT时间（地球时间），“2”为UT1(世界时间)的儒略历
    final List<double> jdResult = Sweph.swe_utc_to_jd(
        meanSolarTime.year,
        meanSolarTime.month,
        meanSolarTime.day,
        meanSolarTime.hour,
        meanSolarTime.minute,
        meanSolarTime.second.toDouble(),
        CalendarType.SE_GREG_CAL);

    // TT 时间用于天体计算，UT时间用于修正本地,
    // 计算真太阳时使用 UT
    final double jd = jdResult[1];
    final double eotMinutes = Sweph.swe_time_equ(jd);

    // 4. 计算地方平太阳时（LMST）[[7]]
    // 5. 真太阳时 = LMST + EoT
    return meanSolarTime.add(Duration(minutes: eotMinutes.toInt()));
  }

  static const List<String> WU_HOU = [
    '蚯蚓结',
    '麋角解',
    '水泉动',
    '雁北乡',
    '鹊始巢',
    '雉始雊',
    '鸡始乳',
    '征鸟厉疾',
    '水泽腹坚',
    '东风解冻',
    '蛰虫始振',
    '鱼陟负冰',
    '獭祭鱼',
    '候雁北',
    '草木萌动',
    '桃始华',
    '仓庚鸣',
    '鹰化为鸠',
    '玄鸟至',
    '雷乃发声',
    '始电',
    '桐始华',
    '田鼠化为鴽',
    '虹始见',
    '萍始生',
    '鸣鸠拂奇羽',
    '戴胜降于桑',
    '蝼蝈鸣',
    '蚯蚓出',
    '王瓜生',
    '苦菜秀',
    '靡草死',
    '麦秋至',
    '螳螂生',
    '鵙始鸣',
    '反舌无声',
    '鹿角解',
    '蜩始鸣',
    '半夏生',
    '温风至',
    '蟋蟀居壁',
    '鹰始挚',
    '腐草为萤',
    '土润溽暑',
    '大雨行时',
    '凉风至',
    '白露降',
    '寒蝉鸣',
    '鹰乃祭鸟',
    '天地始肃',
    '禾乃登',
    '鸿雁来',
    '玄鸟归',
    '群鸟养羞',
    '雷始收声',
    '蛰虫坯户',
    '水始涸',
    '鸿雁来宾',
    '雀入大水为蛤',
    '菊有黄花',
    '豺乃祭兽',
    '草木黄落',
    '蛰虫咸俯',
    '水始冰',
    '地始冻',
    '雉入大水为蜃',
    '虹藏不见',
    '天气上升地气下降',
    '闭塞而成冬',
    '鹖鴠不鸣',
    '虎始交',
    '荔挺出'
  ];

  static const intMonth2ChineseMap = {
    1: '正',
    2: '二',
    3: '三',
    4: '四',
    5: '五',
    6: '六',
    7: '七',
    8: '八',
    9: '九',
    10: '十',
    11: '十一',
    12: '腊',
  };
  static const intMonthTo4SeasonsMap = {
    1: '孟春',
    2: '仲春',
    3: '季春',
    4: '孟夏',
    5: '仲夏',
    6: '季夏',
    7: '孟秋',
    8: '仲秋',
    9: '季秋',
    10: '孟冬',
    11: '仲冬',
    12: '季冬',
  };
  static const intDay2ChineseMap = {
    1: '初一',
    2: '初二',
    3: '初三',
    4: '初四',
    5: '初五',
    6: '初六',
    7: '初七',
    8: '初八',
    9: '初九',
    10: '初十',
    11: '十一',
    12: '十二',
    13: '十三',
    14: '十四',
    15: '十五',
    16: '十六',
    17: '十七',
    18: '十八',
    19: '十九',
    20: '二十',
    21: '廿一',
    22: '廿二',
    23: '廿三',
    24: '廿四',
    25: '廿五',
    26: '廿六',
    27: '廿七',
    28: '廿八',
    29: '廿九',
    30: '三十',
    31: '卅一'
  };
  // 月份映射表：将中文月份转换为数字（1-12）
  static const monthMap = {
    '正月': 1,
    '一月': 1,
    '二月': 2,
    '三月': 3,
    '四月': 4,
    '五月': 5,
    '六月': 6,
    '七月': 7,
    '八月': 8,
    '九月': 9,
    '十月': 10,
    '十一月': 11,
    '十二月': 12,
    '一': 1,
    '二': 2,
    '三': 3,
    '四': 4,
    '五': 5,
    '六': 6,
    '七': 7,
    '八': 8,
    '九': 9,
    '十': 10,
    '十一': 11,
    '十二': 12,
    "腊月": 12,
  };
  static const dayMap = {
    '一': 1,
    '初一': 1,
    '二': 2,
    '初二': 2,
    '三': 3,
    '初三': 3,
    '四': 4,
    '初四': 4,
    '五': 5,
    '初五': 5,
    '六': 6,
    '初六': 6,
    '七': 7,
    '初七': 7,
    '八': 8,
    '初八': 8,
    '九': 9,
    '初九': 9,
    '十': 10,
    '初十': 10,
    '十一': 11,
    '十二': 12,
    '十三': 13,
    '十四': 14,
    '十五': 15,
    '十六': 16,
    '十七': 17,
    '十八': 18,
    '十九': 19,
    '二十': 20,
    '二十一': 21,
    '廿一': 21,
    '二十二': 22,
    '廿二': 22,
    '二十三': 23,
    '廿三': 23,
    '二十四': 24,
    '廿四': 24,
    '二十五': 25,
    '廿五': 25,
    '二十六': 26,
    '廿六': 26,
    '二十七': 27,
    '廿七': 27,
    '二十八': 28,
    '廿八': 28,
    '二十九': 29,
    '廿九': 29,
    '三十': 30,
    '三十一': 31,
    '卅一': 31,
  };

  static List<DateTime> eightChars2DateTime(EightChars eightChars) {
    // Use tyme's EightChar to find matching dates
    final ec = EightChar.fromName(
      eightChars.year.name,
      eightChars.month.name,
      eightChars.day.name,
      eightChars.time.name,
    );
    // Search within a reasonable range (1900-2100)
    final solarTimes = ec.getSolarTimes(1900, 2100);
    return solarTimes.map((st) => DateTime(
      st.getYear(),
      st.getMonth(),
      st.getDay(),
      st.getHour(),
      st.getMinute(),
      st.getSecond(),
    )).toList();
  }

  static List<tz.TZDateTime> eightChars2TZDateTime(
      EightChars eightChars, String utcTimezone) {
    final ec = EightChar.fromName(
      eightChars.year.name,
      eightChars.month.name,
      eightChars.day.name,
      eightChars.time.name,
    );
    final solarTimes = ec.getSolarTimes(1900, 2100);
    return solarTimes.map((st) {
      final dt = DateTime(
        st.getYear(),
        st.getMonth(),
        st.getDay(),
        st.getHour(),
        st.getMinute(),
        st.getSecond(),
      );
      return tz.TZDateTime.from(dt, tz.getLocation(utcTimezone));
    }).toList();
  }

  static DateTime solarTimeToDateTime(SolarTime solarTime) {
    return DateTime(
      solarTime.getYear(),
      solarTime.getMonth(),
      solarTime.getDay(),
      solarTime.getHour(),
      solarTime.getMinute(),
      solarTime.getSecond(),
    );
  }

  static tz.TZDateTime solarTimeToTZDateTime(SolarTime solarTime, String utcTimezone) {
    final datetime = DateTime(
      solarTime.getYear(),
      solarTime.getMonth(),
      solarTime.getDay(),
      solarTime.getHour(),
      solarTime.getMinute(),
      solarTime.getSecond(),
    );
    return tz.TZDateTime.from(datetime, tz.getLocation(utcTimezone));
  }
}

extension TZDateTimeExt on tz.TZDateTime {
  static final df = DateFormat("yyyy-MM-dd HH:mm:ss");
  DateTime toDateTime() {
    return df.parse(df.format(this));
  }
}
