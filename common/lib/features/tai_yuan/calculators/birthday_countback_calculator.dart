import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tyme/tyme.dart' hide Phenology;
import 'package:tuple/tuple.dart';
import '../../../datamodel/datetime_divination_datamodel.dart';
import '../../../models/jie_qi_info.dart';
import '../../../models/seventy_two_phenology.dart';
import '../tai_yuan_by_days_model.dart';
import '../tai_yuan_calculator.dart';
import '../tai_yuan_model.dart';
import '../enum_calculate_strategy.dart';

/// 生日倒推法计算器
class BirthdayCountbackCalculator extends TaiYuanCalculator {
  @override
  TaiYuanCalculateStrategy get strategy =>
      TaiYuanCalculateStrategy.birthdayCountbackMethod;

  @override
  TaiYuanModel calculate(DatatimeDivinationDetailsDataModel birthInfo,
      {DateTime? conceptionDate,
      bool isTestTubeBaby = false,
      required bool withAdjust,
      int actualMatureMonths = 10}) {
    final taiYuanModel = calculateByDays(birthInfo,
        conceptionDate: conceptionDate,
        isTestTubeBaby: isTestTubeBaby,
        actualMatureDays: 300);
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

  /// 根据给定早产天数计算胎元
  /// [birthInfo] 出生信息
  /// [prematureDays] 早产天数（正数表示早产，负数表示晚产）
  /// [isTestTubeBaby] 是否试管婴儿
  /// 注意：当前函数功能并未得到应用层的"验证"，所以在调用前请自行确保参数的合理性
  TaiYuanByDaysModel calculateByDays(
      DatatimeDivinationDetailsDataModel birthInfo,
      {DateTime? conceptionDate,
      bool isTestTubeBaby = false,
      int actualMatureDays = 300}) {
    // 从出生日向前推算300天
    final conceptionDate =
        birthInfo.datetime.subtract(Duration(days: actualMatureDays));

    Tuple4<EightChars, LunarDay, Phenology, JieQiInfo> tuple4 =
        SolarLunarDateTimeHelper.getEighthChars(conceptionDate);
    // item1 为 干支
    // item2 为 农历 日期
    // item3 为 农历 节气
    // item4 为 农历 节气信息

    final lunarDay = tuple4.item2;
    final lunarMonth = lunarDay.getLunarMonth();

    final taiYuanModel = TaiYuanByDaysModel(
      conceptionDateTime: conceptionDate,
      ganZhi: tuple4.item1,
      lunarMonth: lunarMonth.getMonthWithLeap(),
      lunarDay: lunarDay.getDay(),
      jieQiInfo: tuple4.item4,
      calculateStrategy: strategy,
      isTestTubeBaby: isTestTubeBaby,
      totalMatureMonth: (actualMatureDays / 30),
      taiYuanGanZhi: tuple4.item1.month,
      taiYuanBeforeMonth: TaiYuanModel.calculateBeforeMonth(
          tuple4.item1.month, birthInfo.monthGanZhi),
      actualMatureDays: actualMatureDays,
    );
    return taiYuanModel;
  }
}
