import '../../../datamodel/datetime_divination_datamodel.dart';
import '../../../enums/enum_di_zhi.dart';
import '../../../enums/enum_jia_zi.dart';
import '../../../enums/enum_tian_gan.dart';
import '../../../enums/enum_yin_yang.dart';
import '../enum_calculate_strategy.dart';
import '../tai_yuan_calculator.dart';
import '../tai_yuan_model.dart';

class DayMasterYinYangCalculator extends TaiYuanCalculator {
  @override
  TaiYuanCalculateStrategy get strategy =>
      TaiYuanCalculateStrategy.dayMasterYinYangMethod;

  @override
  TaiYuanModel calculate(DatatimeDivinationDetailsDataModel birthInfo,
      {DateTime? conceptionDate,
      required bool withAdjust,
      bool isTestTubeBaby = false,
      int actualMatureMonths = 10}) {
    final dayMaster = birthInfo.dayGanZhi.diZhi;
    final dayMasterYinYang = dayMaster.yinYang;

    TianGan taiYuanTianGan;

    if (dayMasterYinYang == YinYang.YANG) {
      // 阳干日主：取出生月地支的藏干
      final monthDiZhi = birthInfo.monthGanZhi.diZhi;
      taiYuanTianGan = _getZangGan(monthDiZhi);
    } else {
      // 阴干日主：取出生时地支的藏干
      final timeDiZhi = birthInfo.timeGanZhi.diZhi;
      taiYuanTianGan = _getZangGan(timeDiZhi);
    }

    // 简化处理：这里需要根据具体的地支藏干理论来确定地支
    // 暂时使用月支作为胎元地支
    final taiYuanDiZhi = birthInfo.monthGanZhi.diZhi;

    final taiYuanGanZhi =
        JiaZi.getFromGanZhiEnum(taiYuanTianGan, taiYuanDiZhi)!;

    return TaiYuanModel(
      calculateStrategy: strategy,
      taiYuanGanZhi: taiYuanGanZhi,
      taiYuanBeforeMonth: TaiYuanModel.calculateBeforeMonth(
          taiYuanGanZhi, birthInfo.monthGanZhi),
      isTestTubeBaby: isTestTubeBaby,
    );
  }

  /// 获取地支藏干（简化版本，实际应该根据完整的藏干理论）
  TianGan _getZangGan(DiZhi diZhi) {
    // 这里是简化的藏干映射，实际应该更复杂
    const Map<DiZhi, TianGan> zangGanMap = {
      DiZhi.ZI: TianGan.GUI,
      DiZhi.CHOU: TianGan.JI,
      DiZhi.YIN: TianGan.JIA,
      DiZhi.MAO: TianGan.YI,
      DiZhi.CHEN: TianGan.WU,
      DiZhi.SI: TianGan.BING,
      DiZhi.WU: TianGan.DING,
      DiZhi.WEI: TianGan.JI,
      DiZhi.SHEN: TianGan.GENG,
      DiZhi.YOU: TianGan.XIN,
      DiZhi.XU: TianGan.WU,
      DiZhi.HAI: TianGan.REN,
    };

    return zangGanMap[diZhi] ?? TianGan.JIA;
  }
}
