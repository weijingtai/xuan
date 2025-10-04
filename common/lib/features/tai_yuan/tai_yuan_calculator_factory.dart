import 'package:common/datamodel/datetime_divination_datamodel.dart';
import 'package:common/features/tai_yuan/tai_yuan_model.dart';

import 'tai_yuan_calculator.dart';
import 'enum_calculate_strategy.dart';
import 'calculators/direct_conception_calculator.dart';
import 'calculators/month_pillar_calculator.dart';
import 'calculators/birthday_countback_calculator.dart';
import 'calculators/day_master_yinyang_calculator.dart';

/// 胎元计算器工厂
class TaiYuanCalculatorFactory {
  static final Map<TaiYuanCalculateStrategy, TaiYuanCalculator> _calculators = {
    TaiYuanCalculateStrategy.directConceptionDate: DirectConceptionCalculator(),
    TaiYuanCalculateStrategy.monthPillarMethod: MonthPillarCalculator(),
    TaiYuanCalculateStrategy.birthdayCountbackMethod:
        BirthdayCountbackCalculator(),
    TaiYuanCalculateStrategy.dayMasterYinYangMethod:
        DayMasterYinYangCalculator(),
  };
  static TaiYuanModel calculate(DatatimeDivinationDetailsDataModel birthInfo,
      TaiYuanCalculateStrategy strategy,
      {DateTime? conceptionDate,
      bool isTestTubeBaby = false,
      required bool withAdjust,
      int actualMatureMonths = 10}) {
    return getCalculator(strategy).calculate(birthInfo,
        withAdjust: withAdjust,
        conceptionDate: conceptionDate,
        isTestTubeBaby: isTestTubeBaby,
        actualMatureMonths: actualMatureMonths);
  }

  /// 根据策略获取计算器
  static TaiYuanCalculator getCalculator(TaiYuanCalculateStrategy strategy) {
    final calculator = _calculators[strategy];
    if (calculator == null) {
      throw ArgumentError('不支持的胎元计算策略: ${strategy.name}');
    }
    return calculator;
  }

  /// 获取所有可用的计算器
  static List<TaiYuanCalculator> getAllCalculators() {
    return _calculators.values.toList();
  }
}
