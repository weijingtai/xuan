import 'package:flutter/foundation.dart';

/// 决定某时刻采用当日或次日作为“日柱”的锚点策略
class DayAnchor {
  final DateTime effectiveDateTime; // 用于进入 Lunar 计算的时间点
  final bool useNextDayPillar; // 是否使用次日日柱

  const DayAnchor({required this.effectiveDateTime, required this.useNextDayPillar});
}

abstract class DayPillarStrategy {
  /// 根据输入时间决定用于计算日柱的锚点
  DayAnchor decideDayAnchor(DateTime dt);
}

