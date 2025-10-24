import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:lunar/lunar.dart';

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

    // 2) 基于锚点调用 Lunar 计算年/月/日柱
    final lunar = Lunar.fromDate(anchor.effectiveDateTime);
    final parts = lunar.getBaZi(); // [年, 月, 日, 时] 干支字符串

    final year = JiaZi.getFromGanZhiValue(parts[0])!;
    final month = JiaZi.getFromGanZhiValue(parts[1])!;
    final day = JiaZi.getFromGanZhiValue(parts[2])!;

    // 3) 采用“生效日干”决定时柱：五鼠遁或固定
    // 3.1 计算“用于时柱推算”的日柱
    JiaZi dayForHour = day;
    final inChildHour = (dt.hour == 23 || dt.hour == 0);
    if (distinguishChildHour && inChildHour) {
      if (hourStrategy is HourFiveMouseDunStrategy) {
        // 五鼠遁：晚/早子时均按“次日”日干
        final DateTime nextRef = dt.add(const Duration(hours: 1));
        final nextParts = Lunar.fromDate(nextRef).getBaZi();
        dayForHour = JiaZi.getFromGanZhiValue(nextParts[2])!;
      } else if (hourStrategy is HourFixedZiPingStrategy) {
        // 固定子平：23 点用当日日干；0 点用前一小时（晚子时）当日日干
        if (dt.hour == 0) {
          final prevRef = dt.subtract(const Duration(hours: 1));
          final prevParts = Lunar.fromDate(prevRef).getBaZi();
          dayForHour = JiaZi.getFromGanZhiValue(prevParts[2])!;
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
