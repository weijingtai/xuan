/// 基础数条文列表模型
///
/// 继承自BaseNumberModel，包含条文列表相关的所有信息
/// 用于表示包含条文列表的完整基础数模型
library;

import '../../repository/datamodels/tiao_wen_datamodel.dart';
import '../../service/strategy/tiao_wen_list_calculation.dart';
import 'base_number_model.dart';

/// 基础数条文列表模型类
///
/// 继承自BaseNumberModel，包含基础数的完整信息，包括
/// 可选的基础数条文、条文列表生成配置和生成的条文列表
class BaseNumberTiaoWenListModel extends BaseNumberModel {
  /// 基础数条文（可选）
  /// 当基础数本身就是一个条文编号时使用
  final TiaoWenDataModel? baseTiaoWen;

  /// 生成的条文编号列表
  final List<int> tiaoWenNumbers;

  /// 生成的条文数据列表
  final List<TiaoWenDataModel> tiaoWenDataList;

  const BaseNumberTiaoWenListModel({
    required super.baseNumber,
    required super.name,
    required super.description,
    required super.source,
    this.baseTiaoWen,
    required this.tiaoWenNumbers,
    required this.tiaoWenDataList,
  });

  /// 从BaseNumberModel创建BaseNumberTiaoWenListModel
  ///
  /// [baseModel] 基础数模型
  /// [calculationConfig] 条文列表生成配置
  /// [baseTiaoWen] 可选的基础数条文
  factory BaseNumberTiaoWenListModel.fromBaseModel({
    required BaseNumberModel baseModel,
    required TiaoWenListCalculationConfig calculationConfig,
    TiaoWenDataModel? baseTiaoWen,
  }) {
    // 使用配置计算条文编号列表
    final calculator = TiaoWenListCalculator(calculationConfig);
    final calculationResult = calculator.calculate(baseModel.baseNumber);

    return BaseNumberTiaoWenListModel(
      baseNumber: baseModel.baseNumber,
      name: baseModel.name,
      description: baseModel.description,
      source: baseModel.source,
      baseTiaoWen: baseTiaoWen,
      tiaoWenNumbers: calculationResult.tiaoWenNumbers,
      tiaoWenDataList: [], // 初始为空，需要通过Repository填充
    );
  }

  /// 创建基础数条文列表模型的工厂方法
  ///
  /// [baseNumber] 基础数值
  /// [name] 基础数名称
  /// [description] 基础数描述
  /// [source] 基础数来源
  /// [calculationConfig] 条文列表生成配置
  /// [baseTiaoWen] 可选的基础数条文
  factory BaseNumberTiaoWenListModel.create({
    required int baseNumber,
    required String name,
    required String description,
    required BaseNumberSource source,
    required TiaoWenListCalculationConfig calculationConfig,
    TiaoWenDataModel? baseTiaoWen,
  }) {
    // 使用配置计算条文编号列表
    final calculator = TiaoWenListCalculator(calculationConfig);
    final calculationResult = calculator.calculate(baseNumber);

    return BaseNumberTiaoWenListModel(
      baseNumber: baseNumber,
      name: name,
      description: description,
      source: source,
      baseTiaoWen: baseTiaoWen,
      tiaoWenNumbers: calculationResult.tiaoWenNumbers,
      tiaoWenDataList: [], // 初始为空，需要通过Repository填充
    );
  }

  /// 使用Repository数据创建完整的基础数条文列表模型
  ///
  /// [baseNumber] 基础数值
  /// [name] 基础数名称
  /// [description] 基础数描述
  /// [source] 基础数来源
  /// [calculationConfig] 条文列表生成配置
  /// [tiaoWenDataList] 条文数据列表
  /// [baseTiaoWen] 可选的基础数条文
  factory BaseNumberTiaoWenListModel.withData({
    required int baseNumber,
    required String name,
    required String description,
    required BaseNumberSource source,
    required TiaoWenListCalculationConfig calculationConfig,
    required List<TiaoWenDataModel> tiaoWenDataList,
    TiaoWenDataModel? baseTiaoWen,
  }) {
    // 使用配置计算条文编号列表
    final calculator = TiaoWenListCalculator(calculationConfig);
    final calculationResult = calculator.calculate(baseNumber);

    return BaseNumberTiaoWenListModel(
      baseNumber: baseNumber,
      name: name,
      description: description,
      source: source,
      baseTiaoWen: baseTiaoWen,
      tiaoWenNumbers: calculationResult.tiaoWenNumbers,
      tiaoWenDataList: tiaoWenDataList,
    );
  }

  /// 从BaseNumberModel和Repository数据创建完整的基础数条文列表模型
  ///
  /// [baseModel] 基础数模型
  /// [calculationConfig] 条文列表生成配置
  /// [tiaoWenDataList] 条文数据列表
  /// [baseTiaoWen] 可选的基础数条文
  factory BaseNumberTiaoWenListModel.fromBaseModelWithData({
    required BaseNumberModel baseModel,
    required TiaoWenListCalculationConfig calculationConfig,
    required List<TiaoWenDataModel> tiaoWenDataList,
    TiaoWenDataModel? baseTiaoWen,
  }) {
    // 使用配置计算条文编号列表
    final calculator = TiaoWenListCalculator(calculationConfig);
    final calculationResult = calculator.calculate(baseModel.baseNumber);

    return BaseNumberTiaoWenListModel(
      baseNumber: baseModel.baseNumber,
      name: baseModel.name,
      description: baseModel.description,
      source: baseModel.source,
      baseTiaoWen: baseTiaoWen,
      tiaoWenNumbers: calculationResult.tiaoWenNumbers,
      tiaoWenDataList: tiaoWenDataList,
    );
  }

  /// 条文数量
  int get tiaoWenCount => tiaoWenNumbers.length;

  /// 是否有基础条文
  bool get hasBaseTiaoWen => baseTiaoWen != null;

  /// 是否有条文数据
  bool get hasTiaoWenData => tiaoWenDataList.isNotEmpty;

  /// 复制并更新条文数据
  BaseNumberTiaoWenListModel copyWithTiaoWenData(
    List<TiaoWenDataModel> newTiaoWenDataList,
  ) {
    return BaseNumberTiaoWenListModel(
      baseNumber: baseNumber,
      name: name,
      description: description,
      source: source,
      baseTiaoWen: baseTiaoWen,
      tiaoWenNumbers: tiaoWenNumbers,
      tiaoWenDataList: newTiaoWenDataList,
    );
  }

  /// 复制并更新基础条文
  BaseNumberTiaoWenListModel copyWithBaseTiaoWen(
    TiaoWenDataModel? newBaseTiaoWen,
  ) {
    return BaseNumberTiaoWenListModel(
      baseNumber: baseNumber,
      name: name,
      description: description,
      source: source,
      baseTiaoWen: newBaseTiaoWen,
      tiaoWenNumbers: tiaoWenNumbers,
      tiaoWenDataList: tiaoWenDataList,
    );
  }

  /// 复制并更新基础数信息
  @override
  BaseNumberTiaoWenListModel copyWith({
    int? baseNumber,
    String? name,
    String? description,
    BaseNumberSource? source,
    TiaoWenDataModel? baseTiaoWen,
    List<int>? tiaoWenNumbers,
    List<TiaoWenDataModel>? tiaoWenDataList,
  }) {
    return BaseNumberTiaoWenListModel(
      baseNumber: baseNumber ?? this.baseNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      source: source ?? this.source,
      baseTiaoWen: baseTiaoWen ?? this.baseTiaoWen,
      tiaoWenNumbers: tiaoWenNumbers ?? this.tiaoWenNumbers,
      tiaoWenDataList: tiaoWenDataList ?? this.tiaoWenDataList,
    );
  }

  /// 转换为BaseNumberModel
  BaseNumberModel toBaseNumberModel() {
    return BaseNumberModel(
      baseNumber: baseNumber,
      name: name,
      description: description,
      source: source,
    );
  }

  /// 转换为Map用于调试和序列化
  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    return {
      ...baseMap,
      'hasBaseTiaoWen': hasBaseTiaoWen,
      'baseTiaoWenId': baseTiaoWen?.id,
      'tiaoWenNumbers': tiaoWenNumbers,
      'tiaoWenCount': tiaoWenCount,
      'hasTiaoWenData': hasTiaoWenData,
      'tiaoWenDataCount': tiaoWenDataList.length,
    };
  }

  @override
  String toString() {
    return 'BaseNumberTiaoWenListModel(baseNumber: $baseNumber, name: $name, source: ${source.name}, tiaoWenCount: $tiaoWenCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BaseNumberTiaoWenListModel &&
        other.baseNumber == baseNumber &&
        other.name == name &&
        other.source == source &&
        other.tiaoWenNumbers.length == tiaoWenNumbers.length;
  }

  @override
  int get hashCode {
    return baseNumber.hashCode ^
        name.hashCode ^
        source.hashCode ^
        tiaoWenNumbers.length.hashCode;
  }
}
