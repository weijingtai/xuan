/// 皇极取数法计算结果
///
/// 封装皇极取数法计算的完整结果信息
library;

import '../../service/strategy/base_calculation_strategy.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';

/// 皇极取数法计算结果
///
/// 包含初刻数、次条文数、基础数和最终条文数列表
class HuangJiCalculationResult extends BaseCalculationResult {
  /// 初刻数（规则1-4计算得出）
  final int initialNumber;

  /// 次条文数（规则5的候选数）
  final int secondaryNumber;

  /// 基础数（用户确认的数值）
  final int baseNumber;

  /// 最终条文数列表（12种计算结果）
  final List<int> finalNumbers;

  /// 条文数据列表（从repository获取的条文实体）
  final List<TiaoWenDataModel>? tiaoWenDataList;

  /// 计算步骤详情
  final Map<String, dynamic> calculationSteps;

  /// 构造函数
  ///
  /// [initialNumber] 初刻数
  /// [secondaryNumber] 次条文数
  /// [baseNumber] 基础数
  /// [finalNumbers] 最终条文数列表
  /// [tiaoWenDataList] 条文数据列表（可选）
  /// [calculationSteps] 计算步骤详情
  HuangJiCalculationResult({
    required this.initialNumber,
    required this.secondaryNumber,
    required this.baseNumber,
    required this.finalNumbers,
    this.tiaoWenDataList,
    required this.calculationSteps,
  });

  @override
  List<Object?> get props => [
    initialNumber,
    secondaryNumber,
    baseNumber,
    finalNumbers,
    tiaoWenDataList,
    calculationSteps,
  ];

  @override
  String toString() {
    return 'HuangJiCalculationResult('
        'initialNumber: $initialNumber, '
        'secondaryNumber: $secondaryNumber, '
        'baseNumber: $baseNumber, '
        'finalNumbers: $finalNumbers, '
        'tiaoWenDataList: ${tiaoWenDataList?.length ?? 0} items, '
        'calculationSteps: $calculationSteps)';
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'initialNumber': initialNumber,
      'secondaryNumber': secondaryNumber,
      'baseNumber': baseNumber,
      'finalNumbers': finalNumbers,
      'tiaoWenDataList': tiaoWenDataList?.map((e) => e.toJson()).toList(),
      'calculationSteps': calculationSteps,
    };
  }

  /// 从JSON创建实例
  factory HuangJiCalculationResult.fromJson(Map<String, dynamic> json) {
    return HuangJiCalculationResult(
      initialNumber: json['initialNumber'] as int,
      secondaryNumber: json['secondaryNumber'] as int,
      baseNumber: json['baseNumber'] as int,
      finalNumbers: List<int>.from(json['finalNumbers'] as List),
      tiaoWenDataList: json['tiaoWenDataList'] != null
          ? (json['tiaoWenDataList'] as List)
                .map(
                  (e) => TiaoWenDataModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      calculationSteps: Map<String, dynamic>.from(
        json['calculationSteps'] as Map,
      ),
    );
  }

  /// 创建成功结果
  factory HuangJiCalculationResult.success({
    required int initialNumber,
    required int secondaryNumber,
    required int baseNumber,
    required List<int> finalNumbers,
    List<TiaoWenDataModel>? tiaoWenDataList,
    required Map<String, dynamic> calculationSteps,
  }) {
    return HuangJiCalculationResult(
      initialNumber: initialNumber,
      secondaryNumber: secondaryNumber,
      baseNumber: baseNumber,
      finalNumbers: finalNumbers,
      tiaoWenDataList: tiaoWenDataList,
      calculationSteps: calculationSteps,
    );
  }
}
