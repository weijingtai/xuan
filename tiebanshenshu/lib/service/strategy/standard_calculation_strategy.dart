/// 常规计算策略接口
///
/// 定义无需用户交互的一次性计算策略
library;

import 'base_calculation_strategy.dart';

/// 常规计算策略抽象类
///
/// 所有常规（非交互式）计算策略的基类
abstract class StandardCalculationStrategy<
  P extends BaseCalculationParams,
  R extends BaseCalculationResult
>
    extends BaseCalculationStrategy<P, R> {
  @override
  StrategyCategory get category => StrategyCategory.standard;

  /// 计算方法
  ///
  /// 执行计算并返回结果
  ///
  /// [params] 计算参数
  /// 返回计算结果
  R calculate(P params);
}
