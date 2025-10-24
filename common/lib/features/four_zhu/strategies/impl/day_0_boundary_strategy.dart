import 'package:common/features/four_zhu/strategies/day_pillar_strategy.dart';

/// 0:00 为换日界线（子正/子平传统派）
class Day0BoundaryStrategy implements DayPillarStrategy {
  const Day0BoundaryStrategy();

  @override
  DayAnchor decideDayAnchor(DateTime dt) {
    // 0:00 之后进入次日；23:00–0:00 仍为当日
    if (dt.hour == 0 && dt.minute >= 0) {
      return DayAnchor(effectiveDateTime: dt, useNextDayPillar: true);
    }
    return DayAnchor(effectiveDateTime: dt, useNextDayPillar: false);
  }
}

