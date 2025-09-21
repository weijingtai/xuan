/// 铁板神数计算策略基础接口
///
/// 定义所有计算策略的基础抽象类
/// 支持常规计算和交互式计算两种模式
library;

/// 策略分类枚举
///
/// 用于区分不同类型的计算策略
enum StrategyCategory {
  /// 常规策略 - 无需用户交互的一次性计算
  standard,

  /// 交互式策略 - 需要用户交互确认的计算
  interactive,
}

/// 所有计算策略的基础抽象类
///
/// 定义了计算策略的基本接口
/// 所有具体的计算策略都应该继承此类
abstract class BaseCalculationStrategy<P, R> {
  /// 策略名称
  String get name;

  /// 策略描述
  String get description;

  /// 策略详细步骤
  List<String> get detailSteps;

  /// 所属流派
  String get school;

  /// 策略分类标识
  StrategyCategory get category;

  /// 是否为交互式策略
  bool get isInteractive => category == StrategyCategory.interactive;
}

/// 所有算法参数的基础抽象类
abstract class BaseCalculationParams {
  /// 参数描述
  String get description;
}

/// 所有算法结果的基础抽象类
abstract class BaseCalculationResult {
  /// 结果摘要
  int get baseNumber;
}
