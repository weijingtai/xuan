import 'package:common/features/four_zhu/strategies/day_pillar_strategy.dart';

/// 23:00 为换日界线（子初/子平新派）
class Day23BoundaryStrategy implements DayPillarStrategy {
  const Day23BoundaryStrategy();

  @override
  DayAnchor decideDayAnchor(DateTime dt) {
    if (dt.hour >= 23) {
      // 进入次日
      final next = dt.add(const Duration(hours: 1));
      return DayAnchor(effectiveDateTime: next, useNextDayPillar: true);
    }
    return DayAnchor(effectiveDateTime: dt, useNextDayPillar: false);
  }
}

