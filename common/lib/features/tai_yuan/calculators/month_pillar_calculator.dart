import 'package:common/enums.dart';

import '../../../datamodel/datetime_divination_datamodel.dart';
import '../enum_calculate_strategy.dart';
import '../tai_yuan_calculator.dart';
import '../tai_yuan_model.dart';

/// 月柱推算法计算器
class MonthPillarCalculator extends TaiYuanCalculator {
  @override
  TaiYuanCalculateStrategy get strategy =>
      TaiYuanCalculateStrategy.monthPillarMethod;

  @override
  TaiYuanModel calculate(DatatimeDivinationDetailsDataModel birthInfo,
      {DateTime? conceptionDate,
      required bool withAdjust,
      bool isTestTubeBaby = false,
      int actualMatureMonths = 10}) {
    final monthGanZhi = birthInfo.monthGanZhi;

    // 天干向前顺推一位
    final taiYuanTianGan = _getNextTianGan(monthGanZhi.tianGan);

    // 地支向前顺推三位
    final taiYuanDiZhi = _getNextDiZhi(monthGanZhi.diZhi, 3);

    // 组合成胎元干支
    var taiYuanGanZhi = JiaZi.getFromGanZhiEnum(taiYuanTianGan, taiYuanDiZhi);

    // 处理早产/晚产修正
    JiaZi finalTaiYuan = taiYuanGanZhi;
    bool needsCorrection = false;
    String? correctionNote;

    final taiYuanModel = TaiYuanModel(
      taiYuanGanZhi: taiYuanGanZhi,
      taiYuanBeforeMonth: TaiYuanModel.calculateBeforeMonth(
          taiYuanGanZhi, birthInfo.monthGanZhi),
      calculateStrategy: strategy,
      isTestTubeBaby: isTestTubeBaby,
      totalMatureMonth: actualMatureMonths.toDouble(),
    );
    if (withAdjust) {
      TaiYuanModel? adjustedTaiYuanModel;
      if (actualMatureMonths < 10) {
        adjustedTaiYuanModel =
            adjustForPrematureOrPostmature(taiYuanModel, birthInfo);
      }
      return adjustedTaiYuanModel ?? taiYuanModel;
    }
    return taiYuanModel;
  }

  TianGan _getNextTianGan(TianGan current) {
    final values = TianGan.values;
    final currentIndex = values.indexOf(current);
    return values[(currentIndex + 1) % values.length];
  }

  DiZhi _getNextDiZhi(DiZhi current, int steps) {
    final values = DiZhi.values;
    final currentIndex = values.indexOf(current);
    return values[(currentIndex + steps) % values.length];
  }

  DiZhi _getPreviousDiZhi(DiZhi current, int steps) {
    final values = DiZhi.values;
    final currentIndex = values.indexOf(current);
    return values[(currentIndex - steps + values.length) % values.length];
  }
}
