import 'package:json_annotation/json_annotation.dart';

import 'input_info_params.dart';

part 'calculation_strategy_config.g.dart';

/// 出生时间计算配置类
/// 封装了计算过程中使用的各种策略参数
@JsonSerializable()
class CalculationStrategyConfig {
  /// 子时策略
  final ZiShiStrategy ziStrategy; // 早晚子时、子时换日柱、每日零点换日柱与进入子时

  /// 节气类型
  final JieQiType jieQiType; // 平气法或定期气法

  /// 节气策略
  final JieQiStrategy jieQiStrategy; // 如何“交节” 按日，按时辰，按分钟

  const CalculationStrategyConfig({
    required this.ziStrategy,
    required this.jieQiType,
    required this.jieQiStrategy,
  });

  /// 默认配置
  static const CalculationStrategyConfig defaultConfig =
      CalculationStrategyConfig(
    ziStrategy: ZiShiStrategy.startFrom23,
    jieQiType: JieQiType.stabilizing,
    jieQiStrategy: JieQiStrategy.day,
  );

  /// 从JSON创建实例
  factory CalculationStrategyConfig.fromJson(Map<String, dynamic> json) =>
      _$CalculationStrategyConfigFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$CalculationStrategyConfigToJson(this);

  /// 复制并修改部分参数
  CalculationStrategyConfig copyWith({
    ZiShiStrategy? ziStrategy,
    JieQiType? jieQiType,
    JieQiStrategy? jieQiStrategy,
  }) {
    return CalculationStrategyConfig(
      ziStrategy: ziStrategy ?? this.ziStrategy,
      jieQiType: jieQiType ?? this.jieQiType,
      jieQiStrategy: jieQiStrategy ?? this.jieQiStrategy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalculationStrategyConfig &&
        other.ziStrategy == ziStrategy &&
        other.jieQiType == jieQiType &&
        other.jieQiStrategy == jieQiStrategy;
  }

  @override
  int get hashCode {
    return ziStrategy.hashCode ^ jieQiType.hashCode ^ jieQiStrategy.hashCode;
  }

  @override
  String toString() {
    return 'CalculationConfig(ziStrategy: $ziStrategy, jieQiType: $jieQiType, jieQiStrategy: $jieQiStrategy)';
  }
}
