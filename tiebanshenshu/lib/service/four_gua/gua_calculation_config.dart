import 'base_gua_calculator.dart';

/// 数字操作配置类
class NumberOperationConfig {
  /// 偶数数字操作策略
  final NumberOperationStrategy evenNumberOperationStrategy;

  /// 奇数数字操作策略
  final NumberOperationStrategy oddNumberOperationStrategy;

  /// 偶数操作因子（如8、9等）
  final int evenFactorNumber;

  /// 奇数操作因子（如8、9等）
  final int oddFactorNumber;

  /// 偶数相加是否需要再加偶数的个数
  final bool withEvenLength;

  /// 奇数相加是否需要再加奇数的个数
  final bool withOddLength;

  const NumberOperationConfig({
    required this.evenNumberOperationStrategy,
    required this.oddNumberOperationStrategy,
    required this.evenFactorNumber,
    required this.oddFactorNumber,
    this.withEvenLength = false,
    this.withOddLength = false,
  });
}

/// 卦象转换配置类
class GuaConversionConfig {
  /// 上卦数字转换为卦象的策略
  final NumberConversionGuaStrategy topGuaConversionStrategy;

  /// 下卦数字转换为卦象的策略
  final NumberConversionGuaStrategy bottomGuaConversionStrategy;

  /// 奇数是否为上卦
  final bool isOddAsTopGua;

  const GuaConversionConfig({
    required this.topGuaConversionStrategy,
    required this.bottomGuaConversionStrategy,
    this.isOddAsTopGua = true,
  });
}

/// 干支转数字配置类
class GanZhiConversionConfig {
  /// 天干转数字策略
  final GanZhiToNumberStrategy ganToNumberStrategy;

  /// 地支转数字策略
  final GanZhiToNumberStrategy zhiToNumberStrategy;

  const GanZhiConversionConfig({
    required this.ganToNumberStrategy,
    required this.zhiToNumberStrategy,
  });
}

/// 卦象计算综合配置类
class GuaCalculationConfig {
  /// 数字操作配置
  final NumberOperationConfig numberOperationConfig;

  /// 卦象转换配置
  final GuaConversionConfig guaConversionConfig;

  /// 干支转数字配置
  final GanZhiConversionConfig ganZhiConversionConfig;

  const GuaCalculationConfig({
    required this.numberOperationConfig,
    required this.guaConversionConfig,
    required this.ganZhiConversionConfig,
  });

  /// 四门法配置预设
  static const GuaCalculationConfig siMenFaConfig = GuaCalculationConfig(
    numberOperationConfig: NumberOperationConfig(
      evenNumberOperationStrategy: NumberOperationStrategy.mode,
      oddNumberOperationStrategy: NumberOperationStrategy.mode,
      evenFactorNumber: 8,
      oddFactorNumber: 8,
      withEvenLength: false,
      withOddLength: false,
    ),
    guaConversionConfig: GuaConversionConfig(
      topGuaConversionStrategy: NumberConversionGuaStrategy.toHouTian,
      bottomGuaConversionStrategy: NumberConversionGuaStrategy.toHouTian,
      isOddAsTopGua: true,
    ),
    ganZhiConversionConfig: GanZhiConversionConfig(
      ganToNumberStrategy: GanZhiToNumberStrategy.ganZhiNumber,
      zhiToNumberStrategy: GanZhiToNumberStrategy.ganZhiNumber,
    ),
  );

  /// 八卦滚法配置预设
  static const GuaCalculationConfig baGuaGunFaConfig = GuaCalculationConfig(
    numberOperationConfig: NumberOperationConfig(
      evenNumberOperationStrategy: NumberOperationStrategy.mode,
      oddNumberOperationStrategy: NumberOperationStrategy.mode,
      evenFactorNumber: 9,
      oddFactorNumber: 9,
      withEvenLength: true,
      withOddLength: true,
    ),
    guaConversionConfig: GuaConversionConfig(
      topGuaConversionStrategy: NumberConversionGuaStrategy.toXianTian,
      bottomGuaConversionStrategy: NumberConversionGuaStrategy.toXianTian,
      isOddAsTopGua: true,
    ),
    ganZhiConversionConfig: GanZhiConversionConfig(
      ganToNumberStrategy: GanZhiToNumberStrategy.taiXuanNumber,
      zhiToNumberStrategy: GanZhiToNumberStrategy.taiXuanNumber,
    ),
  );
}
