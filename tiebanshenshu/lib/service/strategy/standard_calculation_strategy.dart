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

  /// 获取默认的条文计算配置
  ///
  /// 标准策略的默认实现，子类应该重写以提供特定的配置
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return GenericTiaoWenCalculationConfig.customList(
      name: "标准策略默认配置",
      description: "基础数±100：±100",
      customList: [0, 100],
      withSub: true,
    );
  }

  /// 计算条文列表（使用指定配置）
  ///
  /// 标准策略的默认实现，子类可以重写
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber, 
    P params, 
    TiaoWenCalculationConfig config,
  ) {
    final context = <String, dynamic>{
      'baseNumber': baseNumber,
      'params': params,
    };
    
    return config.calculateTiaoWenList(baseNumber, context);
  }

  /// 获取支持的条文计算配置选项
  ///
  /// 标准策略的默认实现，子类应该重写以提供特定的配置选项
  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [defaultTiaoWenCalculationConfig];
  }

  @override
  String get tiaoWenCalculationDescription => defaultTiaoWenCalculationConfig.description;

  /// 计算方法
  ///
  /// 执行计算并返回结果
  ///
  /// [params] 计算参数
  /// 返回计算结果
  R calculate(P params);
}
