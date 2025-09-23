import 'tiao_wen_list_state.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';

/// 条文列表计算结果
///
/// 包含条文列表计算的完整结果信息，包括条文编号列表、状态、计算方法等
class TiaoWenListResult {
  /// 条文编号列表
  final List<int> tiaoWenNumbers;

  /// 条文实体列表
  final List<TiaoWenDataModel> tiaoWenEntities;

  /// 计算状态
  final TiaoWenListState state;

  /// 计算方法名称
  final String calculationMethod;

  /// 源数据，用于调试和追踪
  final Map<String, dynamic> sourceData;

  /// 错误消息（当状态为error时）
  final String? errorMessage;

  const TiaoWenListResult({
    required this.tiaoWenNumbers,
    required this.tiaoWenEntities,
    required this.state,
    required this.calculationMethod,
    required this.sourceData,
    this.errorMessage,
  });

  /// 是否计算成功
  bool get isSuccess => state.isSuccess;

  /// 是否有错误
  bool get hasError => state.isError;

  /// 是否正在加载
  bool get isLoading => state.isLoading;

  /// 是否为初始状态
  bool get isInitial => state.isInitial;

  /// 条文数量
  int get tiaoWenCount => tiaoWenNumbers.length;

  /// 创建成功结果
  factory TiaoWenListResult.success({
    required List<int> tiaoWenNumbers,
    required List<TiaoWenDataModel> tiaoWenEntities,
    required String calculationMethod,
    required Map<String, dynamic> sourceData,
  }) {
    return TiaoWenListResult(
      tiaoWenNumbers: tiaoWenNumbers,
      tiaoWenEntities: tiaoWenEntities,
      state: TiaoWenListState.success,
      calculationMethod: calculationMethod,
      sourceData: sourceData,
    );
  }

  /// 创建错误结果
  factory TiaoWenListResult.error({
    required String calculationMethod,
    required String errorMessage,
    required Map<String, dynamic> sourceData,
  }) {
    return TiaoWenListResult(
      tiaoWenNumbers: [],
      tiaoWenEntities: [],
      state: TiaoWenListState.error,
      calculationMethod: calculationMethod,
      sourceData: sourceData,
      errorMessage: errorMessage,
    );
  }

  /// 创建加载中结果
  factory TiaoWenListResult.loading({
    required String calculationMethod,
    Map<String, dynamic> sourceData = const {},
  }) {
    return TiaoWenListResult(
      tiaoWenNumbers: [],
      tiaoWenEntities: [],
      state: TiaoWenListState.loading,
      calculationMethod: calculationMethod,
      sourceData: sourceData,
    );
  }

  @override
  String toString() {
    return 'TiaoWenListResult('
        'tiaoWenNumbers: $tiaoWenNumbers, '
        'state: $state, '
        'calculationMethod: $calculationMethod, '
        'sourceData: $sourceData, '
        'errorMessage: $errorMessage'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TiaoWenListResult &&
        _listEquals(other.tiaoWenNumbers, tiaoWenNumbers) &&
        other.state == state &&
        other.calculationMethod == calculationMethod &&
        _mapEquals(other.sourceData, sourceData) &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      tiaoWenNumbers,
      state,
      calculationMethod,
      sourceData,
      errorMessage,
    );
  }

  /// 辅助方法：比较两个列表是否相等
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  /// 辅助方法：比较两个Map是否相等
  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final K key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }
}
