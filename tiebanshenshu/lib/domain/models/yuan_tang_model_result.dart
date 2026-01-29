/// 元堂卦模型结果
///
/// 专门用于元堂卦取数法的结果类型
/// 包含完整的YuanTangInfo信息，以便UI层访问所有卦象和流运数据
library;

import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info.dart';
import 'base_number_model.dart';
import 'base_number_model_result.dart';

/// 元堂卦模型结果
///
/// 在BaseNumberModelResult基础上添加YuanTangInfo
/// 使得整个调用链（Strategy -> UseCase -> ViewModel -> UI）都能访问完整的元堂卦信息
class YuanTangModelResult extends BaseNumberModelResult {
  /// 元堂卦完整信息（包含先天卦、后天卦、大运、流年、流月等所有数据）
  final YuanTangInfo yuanTangInfo;

  YuanTangModelResult({
    required super.algorithmName,
    required super.algorithmDescription,
    required super.calculationParams,
    required super.baseNumbers,
    required super.calculationTime,
    required super.sourceData,
    super.errorMessage,
    required this.yuanTangInfo,
  });

  /// 创建成功结果的工厂方法
  factory YuanTangModelResult.success({
    required String algorithmName,
    required String algorithmDescription,
    required String calculationParams,
    required List<BaseNumberModel> baseNumbers,
    required Map<String, dynamic> sourceData,
    required YuanTangInfo yuanTangInfo,
  }) {
    return YuanTangModelResult(
      algorithmName: algorithmName,
      algorithmDescription: algorithmDescription,
      calculationParams: calculationParams,
      baseNumbers: baseNumbers,
      calculationTime: DateTime.now(),
      sourceData: sourceData,
      yuanTangInfo: yuanTangInfo,
    );
  }

  /// 创建错误结果的工厂方法
  factory YuanTangModelResult.error({
    required String algorithmName,
    required String algorithmDescription,
    required String calculationParams,
    required String errorMessage,
    required YuanTangInfo yuanTangInfo,
    Map<String, dynamic>? sourceData,
  }) {
    return YuanTangModelResult(
      algorithmName: algorithmName,
      algorithmDescription: algorithmDescription,
      calculationParams: calculationParams,
      baseNumbers: [],
      calculationTime: DateTime.now(),
      sourceData: sourceData ?? {},
      errorMessage: errorMessage,
      yuanTangInfo: yuanTangInfo,
    );
  }

  /// 转换为Map格式
  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    return {
      ...baseMap,
      'yuanTangInfo': {
        'xiantianGua': yuanTangInfo.xianTanGua.gua.name,
        'houtianGua': yuanTangInfo.houTianGua.gua.name,
        'yuantangYaoIndex': yuanTangInfo.xianTanGua.yuanTangYao.indexAtYaoList,
        // 可以根据需要添加更多信息
      },
    };
  }

  /// 转换为字符串
  @override
  String toString() {
    return 'YuanTangModelResult('
        'algorithmName: $algorithmName, '
        'baseNumbers: ${baseNumbers.length}, '
        'xiantianGua: ${yuanTangInfo.xianTanGua.gua.name}, '
        'houtianGua: ${yuanTangInfo.houTianGua.gua.name}, '
        'hasError: $hasError'
        ')';
  }

  /// 复制并修改部分属性
  @override
  YuanTangModelResult copyWith({
    String? algorithmName,
    String? algorithmDescription,
    String? calculationParams,
    List<BaseNumberModel>? baseNumbers,
    DateTime? calculationTime,
    Map<String, dynamic>? sourceData,
    String? errorMessage,
    YuanTangInfo? yuanTangInfo,
  }) {
    return YuanTangModelResult(
      algorithmName: algorithmName ?? this.algorithmName,
      algorithmDescription: algorithmDescription ?? this.algorithmDescription,
      calculationParams: calculationParams ?? this.calculationParams,
      baseNumbers: baseNumbers ?? this.baseNumbers,
      calculationTime: calculationTime ?? this.calculationTime,
      sourceData: sourceData ?? this.sourceData,
      errorMessage: errorMessage ?? this.errorMessage,
      yuanTangInfo: yuanTangInfo ?? this.yuanTangInfo,
    );
  }
}
