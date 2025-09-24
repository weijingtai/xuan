/// 皇极取数法计算参数
///
/// 封装皇极取数法计算所需的输入参数
library;

import 'package:common/models/eight_chars.dart';

import '../four_zhu.dart';
import '../../service/strategy/base_calculation_strategy.dart';

/// 皇极取数法计算参数
///
/// 包含四柱信息和可选的交互配置
class HuangJiCalculationParams extends BaseCalculationParams {
  /// 四柱信息
  final EightChars eightChars;

  /// 构造函数
  ///
  /// [fourZhu] 四柱信息，不能为空
  HuangJiCalculationParams({required this.eightChars});

  @override
  List<Object?> get props => [eightChars];

  @override
  String toString() {
    return 'HuangJiCalculationParams(fourZhu: $eightChars)';
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {'eightChars': eightChars.toJson()};
  }

  /// 从JSON创建实例
  factory HuangJiCalculationParams.fromJson(Map<String, dynamic> json) {
    return HuangJiCalculationParams(
      eightChars: EightChars.fromJson(
        json['eightChars'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  // TODO: implement description
  String get description => "皇极取数法一";
}
