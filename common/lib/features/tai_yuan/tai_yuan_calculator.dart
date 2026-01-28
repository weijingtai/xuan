import '../../enums.dart';
import '../../datamodel/datetime_divination_datamodel.dart';
import 'enum_calculate_strategy.dart';
import 'tai_yuan_model.dart';

/// 胎元计算结果
class TaiYuanResult {
  /// 计算得出的胎元干支
  final JiaZi taiYuan;

  /// 使用的计算策略
  final TaiYuanCalculateStrategy strategy;

  /// 计算过程说明
  final String calculationProcess;

  /// 是否需要修正（早产/晚产）
  final bool needsCorrection;

  /// 修正说明
  final String? correctionNote;

  const TaiYuanResult({
    required this.taiYuan,
    required this.strategy,
    required this.calculationProcess,
    this.needsCorrection = false,
    this.correctionNote,
  });

  @override
  String toString() {
    return 'TaiYuanResult{taiYuan: $taiYuan, strategy: ${strategy.name}, needsCorrection: $needsCorrection}';
  }
}

/// 胎元计算策略抽象接口
abstract class TaiYuanCalculator {
  /// 计算胎元
  TaiYuanModel calculate(DatatimeDivinationDetailsDataModel datetimeData,
      {DateTime? conceptionDate,
      required bool withAdjust,
      bool isTestTubeBaby = false,
      int actualMatureMonths = 10});

  /// 获取策略类型
  TaiYuanCalculateStrategy get strategy;

  /// 调整早产或晚产对胎元的影响
  /// [originalTaiYuan] 原始胎元model
  /// [standardMatureMonths] 标准怀孕月数（默认10个月）
  /// 返回调整后的胎元model
  TaiYuanModel? adjustForPrematureOrPostmature(TaiYuanModel originalTaiYuan,
      DatatimeDivinationDetailsDataModel birthInfo,
      {int standardMatureMonths = 10}) {
    JiaZi adjustedTaiYuan = originalTaiYuan.taiYuanGanZhi;
    int actualMatureMonths = originalTaiYuan.totalMatureMonth.toInt();
    if (actualMatureMonths < standardMatureMonths) {
      // final correctedDiZhi =
      for (int i = 0; i < standardMatureMonths - actualMatureMonths; i++) {
        adjustedTaiYuan = adjustedTaiYuan.getNext();
      }
    } else if (actualMatureMonths > standardMatureMonths) {
      for (int i = 0; i < actualMatureMonths - standardMatureMonths; i++) {
        adjustedTaiYuan = adjustedTaiYuan.getPrevious();
      }
    }
    if (adjustedTaiYuan == originalTaiYuan.taiYuanGanZhi) {
      return null;
    }
    return originalTaiYuan.copyWith(
      adjustedTaiYuan: adjustedTaiYuan,
      taiYuanBeforeMonth: TaiYuanModel.calculateBeforeMonth(
          adjustedTaiYuan, birthInfo.monthGanZhi),
    );
  }
}
