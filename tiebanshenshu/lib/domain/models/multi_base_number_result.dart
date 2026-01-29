/// 多基础数算法结果模型
///
/// 用于表示包含多个基础数的算法计算结果
/// 每个基础数都可以生成对应的条文列表
library;

import '../../service/strategy/base_calculation_strategy.dart';
import 'base_number_model.dart';
import 'base_number_tiao_wen_list_model.dart';
import 'tiao_wen_list_state.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';

/// 多基础数算法结果
///
/// 包含算法名称、计算参数、多个基础数模型和整体状态
/// 继承自BaseCalculationResult以符合现有Strategy架构
class MultiBaseNumberResult extends BaseCalculationResult {
  /// 算法名称
  final String algorithmName;

  /// 算法描述
  final String algorithmDescription;

  /// 计算参数描述
  final String calculationParams;

  /// 基础数条文列表模型列表
  final List<BaseNumberTiaoWenListModel> baseNumberTiaoWenList;

  /// 计算状态
  final TiaoWenListState state;

  /// 错误消息（当状态为error时）
  final String? errorMessage;

  /// 计算时间戳
  final DateTime calculationTime;

  /// 源数据，用于调试和追踪
  final Map<String, dynamic> sourceData;

  /// 条文实体列表（UseCase层添加）
  final List<TiaoWenDataModel>? tiaoWenEntities;

  MultiBaseNumberResult({
    required this.algorithmName,
    required this.algorithmDescription,
    required this.calculationParams,
    required this.baseNumberTiaoWenList,
    required this.state,
    this.errorMessage,
    required this.calculationTime,
    required this.sourceData,
    this.tiaoWenEntities,
  });

  /// 创建成功结果
  factory MultiBaseNumberResult.success({
    required String algorithmName,
    required String algorithmDescription,
    required String calculationParams,
    required List<BaseNumberTiaoWenListModel> baseNumberTiaoWenList,
    required Map<String, dynamic> sourceData,
    List<TiaoWenDataModel>? tiaoWenEntities,
  }) {
    return MultiBaseNumberResult(
      algorithmName: algorithmName,
      algorithmDescription: algorithmDescription,
      calculationParams: calculationParams,
      baseNumberTiaoWenList: baseNumberTiaoWenList,
      state: TiaoWenListState.success,
      calculationTime: DateTime.now(),
      sourceData: sourceData,
      tiaoWenEntities: tiaoWenEntities,
    );
  }

  /// 创建错误结果
  factory MultiBaseNumberResult.error({
    required String algorithmName,
    required String algorithmDescription,
    required String calculationParams,
    required String errorMessage,
    Map<String, dynamic>? sourceData,
  }) {
    return MultiBaseNumberResult(
      algorithmName: algorithmName,
      algorithmDescription: algorithmDescription,
      calculationParams: calculationParams,
      baseNumberTiaoWenList: [],
      state: TiaoWenListState.error,
      errorMessage: errorMessage,
      calculationTime: DateTime.now(),
      sourceData: sourceData ?? {},
    );
  }

  /// 创建加载中结果
  factory MultiBaseNumberResult.loading({
    required String algorithmName,
    required String algorithmDescription,
    required String calculationParams,
  }) {
    return MultiBaseNumberResult(
      algorithmName: algorithmName,
      algorithmDescription: algorithmDescription,
      calculationParams: calculationParams,
      baseNumberTiaoWenList: [],
      state: TiaoWenListState.loading,
      calculationTime: DateTime.now(),
      sourceData: {},
    );
  }

  /// 是否计算成功
  bool get isSuccess => state.isSuccess;

  /// 是否有错误
  bool get hasError => state.isError;

  /// 是否正在加载
  bool get isLoading => state.isLoading;

  /// 是否为初始状态
  bool get isInitial => state.isInitial;

  /// 基础数数量
  int get baseNumberCount => baseNumberTiaoWenList.length;

  /// 总条文数量
  int get totalTiaoWenCount => baseNumberTiaoWenList.fold(
    0,
    (sum, baseNumber) => sum + baseNumber.tiaoWenCount,
  );

  /// 所有条文编号列表（去重）
  List<int> get allTiaoWenNumbers {
    final Set<int> allNumbers = {};
    for (final baseNumber in baseNumberTiaoWenList) {
      allNumbers.addAll(baseNumber.tiaoWenNumbers);
    }
    return allNumbers.toList()..sort();
  }

  /// 所有条文数据列表（去重）
  List<TiaoWenDataModel> get allTiaoWenDataList {
    if (tiaoWenEntities != null) {
      return tiaoWenEntities!;
    }
    // 向后兼容：如果没有tiaoWenEntities，从baseNumberTiaoWenList中获取
    final Map<int, TiaoWenDataModel> allDataMap = {};
    for (final baseNumber in baseNumberTiaoWenList) {
      for (final tiaoWen in baseNumber.tiaoWenDataList) {
        allDataMap[tiaoWen.id] = tiaoWen;
      }
    }
    return allDataMap.values.toList();
  }

  /// 是否有任何条文数据
  bool get hasAnyTiaoWenData =>
      tiaoWenEntities?.isNotEmpty == true ||
      baseNumberTiaoWenList.any((baseNumber) => baseNumber.hasTiaoWenData);

  /// 获取指定来源的基础数
  List<BaseNumberTiaoWenListModel> getBaseNumbersBySource(
    BaseNumberSource source,
  ) {
    return baseNumberTiaoWenList
        .where((baseNumber) => baseNumber.source == source)
        .toList();
  }

  /// 获取指定基础数值的模型
  BaseNumberTiaoWenListModel? getBaseNumberByValue(int value) {
    try {
      return baseNumberTiaoWenList.firstWhere(
        (baseNumber) => baseNumber.baseNumber == value,
      );
    } catch (e) {
      return null;
    }
  }

  /// 复制并更新基础数列表
  MultiBaseNumberResult copyWithBaseNumbers(
    List<BaseNumberTiaoWenListModel> newBaseNumbers,
  ) {
    return MultiBaseNumberResult(
      algorithmName: algorithmName,
      algorithmDescription: algorithmDescription,
      calculationParams: calculationParams,
      baseNumberTiaoWenList: newBaseNumbers,
      state: state,
      errorMessage: errorMessage,
      calculationTime: calculationTime,
      sourceData: sourceData,
    );
  }

  /// 复制并更新状态
  MultiBaseNumberResult copyWithState(
    TiaoWenListState newState, {
    String? newErrorMessage,
  }) {
    return MultiBaseNumberResult(
      algorithmName: algorithmName,
      algorithmDescription: algorithmDescription,
      calculationParams: calculationParams,
      baseNumberTiaoWenList: baseNumberTiaoWenList,
      state: newState,
      errorMessage: newErrorMessage ?? errorMessage,
      calculationTime: calculationTime,
      sourceData: sourceData,
    );
  }

  /// 转换为Map用于调试和序列化
  Map<String, dynamic> toMap() {
    return {
      'algorithmName': algorithmName,
      'algorithmDescription': algorithmDescription,
      'calculationParams': calculationParams,
      'state': state.name,
      'errorMessage': errorMessage,
      'calculationTime': calculationTime.toIso8601String(),
      'baseNumberCount': baseNumberCount,
      'totalTiaoWenCount': totalTiaoWenCount,
      'hasAnyTiaoWenData': hasAnyTiaoWenData,
      'baseNumberTiaoWenList': baseNumberTiaoWenList
          .map((baseNumber) => baseNumber.toMap())
          .toList(),
      'allTiaoWenNumbers': allTiaoWenNumbers,
      'sourceData': sourceData,
    };
  }

  @override
  String toString() {
    return 'MultiBaseNumberResult(algorithm: $algorithmName, baseNumberCount: $baseNumberCount, state: ${state.name}, totalTiaoWenCount: $totalTiaoWenCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MultiBaseNumberResult &&
        other.algorithmName == algorithmName &&
        other.calculationParams == calculationParams &&
        other.baseNumberTiaoWenList.length == baseNumberTiaoWenList.length;
  }

  @override
  int get hashCode {
    return algorithmName.hashCode ^
        calculationParams.hashCode ^
        baseNumberTiaoWenList.length.hashCode;
  }
}
