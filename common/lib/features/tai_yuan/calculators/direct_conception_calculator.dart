import 'package:common/enums.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tyme/tyme.dart' hide Phenology;
import 'package:tuple/tuple.dart';
import '../../../datamodel/datetime_divination_datamodel.dart';
import '../../../models/jie_qi_info.dart';
import '../../../models/seventy_two_phenology.dart';
import '../enum_calculate_strategy.dart';
import '../tai_yuan_calculator.dart';
import '../tai_yuan_model.dart';

/// 受孕时间法计算器
class DirectConceptionCalculator extends TaiYuanCalculator {
  @override
  TaiYuanCalculateStrategy get strategy =>
      TaiYuanCalculateStrategy.directConceptionDate;

  @override
  String get dataRequirements => '需要准确的受孕时间（年月日时）';

  @override
  bool canCalculate(DateTime? birthInfo) {
    return birthInfo != null;
  }

  @override
  TaiYuanModel calculate(DatatimeDivinationDetailsDataModel birthInfo,
      {DateTime? conceptionDate,
      required bool withAdjust,
      bool isTestTubeBaby = false,
      int actualMatureMonths = 10}) {
    if (!canCalculate(conceptionDate)) {
      throw ArgumentError('缺少受孕时间，无法使用受孕时间法计算胎元');
    }

    Tuple4<EightChars, LunarDay, Phenology, JieQiInfo> tuple4 =
        SolarLunarDateTimeHelper.getEighthChars(conceptionDate!);
    JiaZi taiYuanGanZhi = tuple4.item1.month;

    final lunarDay = tuple4.item2;
    final lunarMonth = lunarDay.getLunarMonth();

    final taiYuanModel = TaiYuanModel(
      conceptionDateTime: conceptionDate,
      ganZhi: tuple4.item1,
      lunarMonth: lunarMonth.getMonthWithLeap(),
      lunarDay: lunarDay.getDay(),
      jieQiInfo: tuple4.item4,
      calculateStrategy: strategy,
      isTestTubeBaby: isTestTubeBaby,
      totalMatureMonth: actualMatureMonths.toDouble(),
      taiYuanGanZhi: tuple4.item1.month,
      taiYuanBeforeMonth: TaiYuanModel.calculateBeforeMonth(
          tuple4.item1.month, birthInfo.monthGanZhi),
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
}
