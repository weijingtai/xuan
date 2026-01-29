/// 基础数模型结果
///
/// Strategy层返回的结果，包含一个或多个BaseNumberModel
/// 这是Strategy计算的直接输出，不包含条文列表等后续计算结果
library;

import '../../service/strategy/base_calculation_strategy.dart';
import 'base_number_model.dart';

/// 基础数模型结果
///
/// 包含Strategy计算得出的基础数模型列表
/// 继承自BaseCalculationResult以符合现有Strategy架构
class BaseNumberModelResult extends BaseCalculationResult {
  /// 算法名称
  final String algorithmName;

  /// 算法描述
  final String algorithmDescription;

  /// 计算参数描述
  final String calculationParams;

  /// 基础数模型列表
  final List<BaseNumberModel> baseNumbers;

  /// 计算时间戳
  final DateTime calculationTime;

  /// 源数据，用于调试和追踪
  final Map<String, dynamic> sourceData;

  /// 错误消息（如果有错误）
  final String? errorMessage;

  /// 是否有错误
  bool get hasError => errorMessage != null;

  BaseNumberModelResult({
    required this.algorithmName,
    required this.algorithmDescription,
    required this.calculationParams,
    required this.baseNumbers,
    required this.calculationTime,
    required this.sourceData,
    this.errorMessage,
  });

  /// 创建成功结果的工厂方法
  factory BaseNumberModelResult.success({
    required String algorithmName,
    required String algorithmDescription,
    required String calculationParams,
    required List<BaseNumberModel> baseNumbers,
    required Map<String, dynamic> sourceData,
  }) {
    return BaseNumberModelResult(
      algorithmName: algorithmName,
      algorithmDescription: algorithmDescription,
      calculationParams: calculationParams,
      baseNumbers: baseNumbers,
      calculationTime: DateTime.now(),
      sourceData: sourceData,
    );
  }

  /// 创建错误结果的工厂方法
  factory BaseNumberModelResult.error({
    required String algorithmName,
    required String algorithmDescription,
    required String calculationParams,
    required String errorMessage,
    Map<String, dynamic>? sourceData,
  }) {
    return BaseNumberModelResult(
      algorithmName: algorithmName,
      algorithmDescription: algorithmDescription,
      calculationParams: calculationParams,
      baseNumbers: [],
      calculationTime: DateTime.now(),
      sourceData: sourceData ?? {},
      errorMessage: errorMessage,
    );
  }

  /// 获取所有基础数值
  List<int> get baseNumberValues {
    return baseNumbers.map((bn) => bn.baseNumber).toList();
  }

  /// 转换为Map格式
  Map<String, dynamic> toMap() {
    return {
      'algorithmName': algorithmName,
      'algorithmDescription': algorithmDescription,
      'calculationParams': calculationParams,
      'baseNumbers': baseNumbers.map((bn) => bn.toMap()).toList(),
      'calculationTime': calculationTime.toIso8601String(),
      'sourceData': sourceData,
      'errorMessage': errorMessage,
      'hasError': hasError,
    };
  }

  /// 转换为字符串
  @override
  String toString() {
    return 'BaseNumberModelResult('
        'algorithmName: $algorithmName, '
        'baseNumbers: ${baseNumbers.length}, '
        'hasError: $hasError'
        ')';
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseNumberModelResult &&
        other.algorithmName == algorithmName &&
        other.algorithmDescription == algorithmDescription &&
        other.calculationParams == calculationParams &&
        other.baseNumbers.length == baseNumbers.length &&
        other.errorMessage == errorMessage;
  }

  /// 哈希码
  @override
  int get hashCode {
    return algorithmName.hashCode ^
        algorithmDescription.hashCode ^
        calculationParams.hashCode ^
        baseNumbers.length.hashCode ^
        (errorMessage?.hashCode ?? 0);
  }

  /// 复制并修改部分属性
  BaseNumberModelResult copyWith({
    String? algorithmName,
    String? algorithmDescription,
    String? calculationParams,
    List<BaseNumberModel>? baseNumbers,
    DateTime? calculationTime,
    Map<String, dynamic>? sourceData,
    String? errorMessage,
  }) {
    return BaseNumberModelResult(
      algorithmName: algorithmName ?? this.algorithmName,
      algorithmDescription: algorithmDescription ?? this.algorithmDescription,
      calculationParams: calculationParams ?? this.calculationParams,
      baseNumbers: baseNumbers ?? this.baseNumbers,
      calculationTime: calculationTime ?? this.calculationTime,
      sourceData: sourceData ?? this.sourceData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
