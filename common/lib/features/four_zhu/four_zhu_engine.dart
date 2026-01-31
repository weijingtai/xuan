import 'package:common/enums/enum_di_zhi.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/enums/enum_twenty_four_jie_qi.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:tyme/tyme.dart';
import 'package:tuple/tuple.dart';

import 'strategies/day_pillar_strategy.dart';
import 'strategies/hour_pillar_strategy.dart';
import 'strategies/impl/day_0_boundary_strategy.dart';
import 'strategies/impl/day_23_boundary_strategy.dart';
import 'strategies/impl/hour_five_mouse_dun_strategy.dart';
import 'strategies/impl/hour_fixed_zi_ping_strategy.dart';
import 'strategies/impl/hour_bands_start0_strategy.dart';

class EightCharsResult {
  final EightChars eightChars;
  final String explain;

  const EightCharsResult({required this.eightChars, required this.explain});
}

/// 组合日柱与时柱策略，产出四柱
class FourZhuEngine {
  final DayPillarStrategy dayStrategy;
  final HourPillarStrategy hourStrategy;

  /// 区分早晚子时：
  /// - true: 23:00–1:00 时柱按“次日”日干五鼠遁；日柱在 23:00–0:00 仍属当日，0:00–1:00 属次日。
  /// - false: 23:00–1:00 统一按次日（不区分早晚），日柱与时柱均属次日。
  final bool distinguishChildHour;

  const FourZhuEngine({
    required this.dayStrategy,
    required this.hourStrategy,
    this.distinguishChildHour = true,
  });

  /// 预设枚举：子时日界与早晚子时模式
  static FourZhuEngine create({
    required ZiBoundary boundary,
    required ChildHourMode childHourMode,
  }) {
    // 选择日柱策略
    final DayPillarStrategy day = switch (boundary) {
      ZiBoundary.at23 => Day23BoundaryStrategy(),
      ZiBoundary.at0 => Day0BoundaryStrategy(),
    };

    // 选择时柱策略与是否区分早晚
    final (HourPillarStrategy, bool) hourAndFlag = switch (childHourMode) {
      ChildHourMode.noDistinguish => (HourFiveMouseDunStrategy(), false),
      ChildHourMode.distinguishFiveMouse => (HourFiveMouseDunStrategy(), true),
      ChildHourMode.distinguishFixed => (HourFixedZiPingStrategy(), true),
      ChildHourMode.bandsStart0 => (HourBandsStart0Strategy(), false),
    };

    return FourZhuEngine(
      dayStrategy: day,
      hourStrategy: hourAndFlag.$1,
      distinguishChildHour: hourAndFlag.$2,
    );
  }

  EightCharsResult calculate(DateTime dt) {
    // 1) 决定用于计算日柱的时间锚点
    final anchor = dayStrategy.decideDayAnchor(dt);

    // 2) 基于锚点使用 tyme 计算年/月/日柱
    final anchorDt = anchor.effectiveDateTime;
    final solarTime = SolarTime.fromYmdHms(
      anchorDt.year,
      anchorDt.month,
      anchorDt.day,
      anchorDt.hour,
      anchorDt.minute,
      anchorDt.second,
    );
    final lunarHour = solarTime.getLunarHour();
    final eightChar = lunarHour.getEightChar();
    final parts = [
      eightChar.getYear().getName(),
      eightChar.getMonth().getName(),
      eightChar.getDay().getName(),
      eightChar.getHour().getName(),
    ];

    final year = JiaZi.getFromGanZhiValue(parts[0])!;
    final month = JiaZi.getFromGanZhiValue(parts[1])!;
    final day = JiaZi.getFromGanZhiValue(parts[2])!;

    // 3) 采用"生效日干"决定时柱：五鼠遁或固定
    // 3.1 计算"用于时柱推算"的日柱
    JiaZi dayForHour = day;
    final inChildHour = (dt.hour == 23 || dt.hour == 0);
    if (distinguishChildHour && inChildHour) {
      if (hourStrategy is HourFiveMouseDunStrategy) {
        // 五鼠遁：晚/早子时均按"次日"日干
        final DateTime nextRef = dt.add(const Duration(hours: 1));
        final nextSolarTime = SolarTime.fromYmdHms(
          nextRef.year,
          nextRef.month,
          nextRef.day,
          nextRef.hour,
          nextRef.minute,
          nextRef.second,
        );
        final nextEc = nextSolarTime.getLunarHour().getEightChar();
        dayForHour = JiaZi.getFromGanZhiValue(nextEc.getDay().getName())!;
      } else if (hourStrategy is HourFixedZiPingStrategy) {
        // 固定子平：23 点用当日日干；0 点用前一小时（晚子时）当日日干
        if (dt.hour == 0) {
          final prevRef = dt.subtract(const Duration(hours: 1));
          final prevSolarTime = SolarTime.fromYmdHms(
            prevRef.year,
            prevRef.month,
            prevRef.day,
            prevRef.hour,
            prevRef.minute,
            prevRef.second,
          );
          final prevEc = prevSolarTime.getLunarHour().getEightChar();
          dayForHour = JiaZi.getFromGanZhiValue(prevEc.getDay().getName())!;
        } else {
          dayForHour = day;
        }
      }
    }

    final JiaZi hourJz = hourStrategy.decideHourPillar(dt, dayForHour);

    final result = EightChars(year: year, month: month, day: day, time: hourJz);
    final explain =
        'distinguish=$distinguishChildHour dayNext=${anchor.useNextDayPillar} hour=${hourJz.name}';
    return EightCharsResult(eightChars: result, explain: explain);
  }
}

/// 子时日界：23 点或 0 点
enum ZiBoundary { at23, at0 }

/// 早晚子时模式
enum ChildHourMode {
  /// 不区分早晚：23:00–1:00 统一按次日（日柱与时柱均次日）
  noDistinguish,

  /// 区分早晚：晚子时日柱属当日、时柱按次日；早子时日柱与时柱均次日（时柱走五鼠遁）
  distinguishFiveMouse,

  /// 区分早晚：时柱固定壬子/癸丑（非五鼠遁）
  distinguishFixed,
  /// 以 0:00 开始的两小时一支全天分段（子0:00–1:59）
  bandsStart0,
}

class LifeBodyHouseCalculator {
  static Tuple2<TianGan, DiZhi> calculateLifeHouse({
    required DateTime birthDateTime,
    required EightChars eightChars,
  }) {
    return _calculateHouse(
      birthDateTime: birthDateTime,
      eightChars: eightChars,
      isLifeHouse: true,
    );
  }

  static Tuple2<TianGan, DiZhi> calculateBodyHouse({
    required DateTime birthDateTime,
    required EightChars eightChars,
  }) {
    return _calculateHouse(
      birthDateTime: birthDateTime,
      eightChars: eightChars,
      isLifeHouse: false,
    );
  }
}

Tuple2<TianGan, DiZhi> _calculateHouse({
  required DateTime birthDateTime,
  required EightChars eightChars,
  required bool isLifeHouse,
}) {
  final monthZhi = eightChars.monthDiZhi;
  final hourZhi = eightChars.hourDiZhi;

  final m = _monthOrderForHouse(
    birthDateTime: birthDateTime,
    baziMonthZhi: monthZhi,
  );
  final h = _diZhiToHouseOrder(hourZhi);

  final sum = m + h;
  final raw = isLifeHouse ? (14 - sum) : sum;
  final palaceOrder = _normalizeHouseOrder(raw);
  final palaceZhi = _houseOrderToDiZhi(palaceOrder);

  final startGanAtYin = eightChars.yearTianGan.getFiveTiger();
  final palaceGan = _shiftTianGan(
    start: startGanAtYin,
    offset: palaceOrder - 1,
  );

  final monthKongWang = eightChars.month.getKongWang();
  final isKongWang =
      palaceZhi == monthKongWang.item1 || palaceZhi == monthKongWang.item2;

  return Tuple2(isKongWang ? TianGan.KONG_WANG : palaceGan, palaceZhi);
}

int _monthOrderForHouse({
  required DateTime birthDateTime,
  required DiZhi baziMonthZhi,
}) {
  final zhongQi = _zhongQiForMonthZhi(baziMonthZhi);
  final zhongQiAt = _findJieQiTimeNear(
    around: birthDateTime,
    target: zhongQi,
  );

  if (birthDateTime.isBefore(zhongQiAt)) {
    return _diZhiToHouseOrder(baziMonthZhi);
  }

  return _diZhiToHouseOrder(_nextHouseMonthZhi(baziMonthZhi));
}

TwentyFourJieQi _zhongQiForMonthZhi(DiZhi monthZhi) {
  switch (monthZhi) {
    case DiZhi.YIN:
      return TwentyFourJieQi.YU_SHUI;
    case DiZhi.MAO:
      return TwentyFourJieQi.CHUN_FEN;
    case DiZhi.CHEN:
      return TwentyFourJieQi.GU_YU;
    case DiZhi.SI:
      return TwentyFourJieQi.XIAO_MAN;
    case DiZhi.WU:
      return TwentyFourJieQi.XIA_ZHI;
    case DiZhi.WEI:
      return TwentyFourJieQi.DA_SHU;
    case DiZhi.SHEN:
      return TwentyFourJieQi.CHU_SHU;
    case DiZhi.YOU:
      return TwentyFourJieQi.QIU_FEN;
    case DiZhi.XU:
      return TwentyFourJieQi.SHUANG_JIANG;
    case DiZhi.HAI:
      return TwentyFourJieQi.XIAO_XUE;
    case DiZhi.ZI:
      return TwentyFourJieQi.DONG_ZHI;
    case DiZhi.CHOU:
      return TwentyFourJieQi.DA_HAN;
  }
}

DiZhi _nextHouseMonthZhi(DiZhi zhi) {
  const seq = <DiZhi>[
    DiZhi.YIN,
    DiZhi.MAO,
    DiZhi.CHEN,
    DiZhi.SI,
    DiZhi.WU,
    DiZhi.WEI,
    DiZhi.SHEN,
    DiZhi.YOU,
    DiZhi.XU,
    DiZhi.HAI,
    DiZhi.ZI,
    DiZhi.CHOU,
  ];

  final idx = seq.indexOf(zhi);
  if (idx < 0) return zhi;

  return seq[(idx + 1) % seq.length];
}

DateTime _findJieQiTimeNear({
  required DateTime around,
  required TwentyFourJieQi target,
}) {
  // Map TwentyFourJieQi to tyme SolarTerm index
  // In tyme, index 0 is 小寒, 1 is 大寒, ..., 23 is 冬至
  final termIndexMap = {
    TwentyFourJieQi.XIAO_HAN: 0,
    TwentyFourJieQi.DA_HAN: 1,
    TwentyFourJieQi.LI_CHUN: 2,
    TwentyFourJieQi.YU_SHUI: 3,
    TwentyFourJieQi.JING_ZHE: 4,
    TwentyFourJieQi.CHUN_FEN: 5,
    TwentyFourJieQi.QING_MING: 6,
    TwentyFourJieQi.GU_YU: 7,
    TwentyFourJieQi.LI_XIA: 8,
    TwentyFourJieQi.XIAO_MAN: 9,
    TwentyFourJieQi.MANG_ZHONG: 10,
    TwentyFourJieQi.XIA_ZHI: 11,
    TwentyFourJieQi.XIAO_SHU: 12,
    TwentyFourJieQi.DA_SHU: 13,
    TwentyFourJieQi.LI_QIU: 14,
    TwentyFourJieQi.CHU_SHU: 15,
    TwentyFourJieQi.BAI_LU: 16,
    TwentyFourJieQi.QIU_FEN: 17,
    TwentyFourJieQi.HAN_LU: 18,
    TwentyFourJieQi.SHUANG_JIANG: 19,
    TwentyFourJieQi.LI_DONG: 20,
    TwentyFourJieQi.XIAO_XUE: 21,
    TwentyFourJieQi.DA_XUE: 22,
    TwentyFourJieQi.DONG_ZHI: 23,
  };

  final targetIndex = termIndexMap[target];
  if (targetIndex == null) return around;

  final matches = <DateTime>[];

  // Search in current year and adjacent years
  for (int yearOffset = -1; yearOffset <= 1; yearOffset++) {
    final year = around.year + yearOffset;
    try {
      final term = SolarTerm.fromIndex(year, targetIndex);
      final jd = term.getJulianDay();
      final st = jd.getSolarTime();
      final at = DateTime(
        st.getYear(),
        st.getMonth(),
        st.getDay(),
        st.getHour(),
        st.getMinute(),
        st.getSecond(),
      );
      matches.add(at);
    } catch (e) {
      // Skip if term cannot be found for this year
    }
  }

  if (matches.isEmpty) return around;

  // Find the closest match
  matches.sort((a, b) {
    final da = a.difference(around).inMilliseconds.abs();
    final db = b.difference(around).inMilliseconds.abs();
    return da.compareTo(db);
  });
  return matches.first;
}

int _diZhiToHouseOrder(DiZhi zhi) {
  switch (zhi) {
    case DiZhi.YIN:
      return 1;
    case DiZhi.MAO:
      return 2;
    case DiZhi.CHEN:
      return 3;
    case DiZhi.SI:
      return 4;
    case DiZhi.WU:
      return 5;
    case DiZhi.WEI:
      return 6;
    case DiZhi.SHEN:
      return 7;
    case DiZhi.YOU:
      return 8;
    case DiZhi.XU:
      return 9;
    case DiZhi.HAI:
      return 10;
    case DiZhi.ZI:
      return 11;
    case DiZhi.CHOU:
      return 12;
  }
}

DiZhi _houseOrderToDiZhi(int order) {
  switch (order) {
    case 1:
      return DiZhi.YIN;
    case 2:
      return DiZhi.MAO;
    case 3:
      return DiZhi.CHEN;
    case 4:
      return DiZhi.SI;
    case 5:
      return DiZhi.WU;
    case 6:
      return DiZhi.WEI;
    case 7:
      return DiZhi.SHEN;
    case 8:
      return DiZhi.YOU;
    case 9:
      return DiZhi.XU;
    case 10:
      return DiZhi.HAI;
    case 11:
      return DiZhi.ZI;
    case 12:
      return DiZhi.CHOU;
  }

  return DiZhi.CHOU;
}

int _normalizeHouseOrder(int raw) {
  int out = raw;
  while (out <= 0) {
    out += 12;
  }
  while (out > 12) {
    out -= 12;
  }
  return out;
}

TianGan _shiftTianGan({
  required TianGan start,
  required int offset,
}) {
  const seq = <TianGan>[
    TianGan.JIA,
    TianGan.YI,
    TianGan.BING,
    TianGan.DING,
    TianGan.WU,
    TianGan.JI,
    TianGan.GENG,
    TianGan.XIN,
    TianGan.REN,
    TianGan.GUI,
  ];

  final idx = seq.indexOf(start);
  if (idx < 0) return start;

  return seq[(idx + offset) % seq.length];
}
