import 'package:json_annotation/json_annotation.dart';

import 'huang_ji_formula_v2.dart';
import '../../domain/models/huang_ji_number.dart';

part 'huang_ji_formula_data_v2.g.dart';

class DataBaseNumberDefinitionConverter
    implements JsonConverter<DataBaseNumberDefinition, Map<String, dynamic>> {
  const DataBaseNumberDefinitionConverter();

  @override
  DataBaseNumberDefinition fromJson(Map<String, dynamic> json) {
    return fromJsonConvertor(json);
  }

  @override
  Map<String, dynamic> toJson(DataBaseNumberDefinition object) {
    return toJsonConvertor(object);
  }

  static DataBaseNumberDefinition fromJsonConvertor(Map<String, dynamic> json) {
    final type = BaseNumberDefinitionType.fromValue(json['type'] as String);
    switch (type) {
      case BaseNumberDefinitionType.selectable:
        return DataSelectableBaseNumber.fromJson(json);
      case BaseNumberDefinitionType.derived:
        return DataDerivedBaseNumber.fromJson(json);
      case BaseNumberDefinitionType.predefined:
        return DataPredefinedBaseNumber.fromJson(json);
    }
  }

  static Map<String, dynamic> toJsonConvertor(DataBaseNumberDefinition object) {
    final json = <String, dynamic>{};
    if (object is DataSelectableBaseNumber) {
      json.addAll(object.toJson());
    } else if (object is DataDerivedBaseNumber) {
      json.addAll(object.toJson());
    } else if (object is DataPredefinedBaseNumber) {
      json.addAll(object.toJson());
    }
    json['type'] = object.type.value;
    return json;
  }
}

/// DataCalculationPart 的多态 JSON 转换器
class DataCalculationPartConverter
    implements JsonConverter<DataCalculationPart, Map<String, dynamic>> {
  const DataCalculationPartConverter();

  @override
  DataCalculationPart fromJson(Map<String, dynamic> json) {
    final type = CalculationPartType.fromValue(json['type'] as String);
    switch (type) {
      case CalculationPartType.singleNumber:
        return DataSingleNumberPart.fromJson(json);
      case CalculationPartType.compositeNumber:
        return DataCompositeNumberPart.fromJson(json);
    }
  }

  @override
  Map<String, dynamic> toJson(DataCalculationPart object) {
    final json = <String, dynamic>{};
    if (object is DataSingleNumberPart) {
      json.addAll(object.toJson());
    } else if (object is DataCompositeNumberPart) {
      json.addAll(object.toJson());
    }
    json['type'] = object.type.value;
    return json;
  }
}

@JsonSerializable()
class DataCalculationGroup {
  final String groupId; // 唯一标识符, 如 "base_one", "base_two"
  final String description; // 例如: "围绕基础数一的计算"

  /// 本组所使用的"基础数"是如何定义的。
  @JsonKey(
    fromJson: DataBaseNumberDefinitionConverter.fromJsonConvertor,
    toJson: DataBaseNumberDefinitionConverter.toJsonConvertor,
  )
  final DataBaseNumberDefinition baseNumberDefinition;

  int get rawNumber => baseNumberDefinition.number;
  int get number => baseNumberDefinition.number;

  /// 使用上述"基础数"进行的一系列条文计算公式。
  @JsonKey(fromJson: _dataFormulasFromJson, toJson: _dataFormulasToJson)
  final List<TiaoWenFormulaData> dataFormulas;

  DataCalculationGroup({
    required this.groupId,
    required this.description,
    required this.baseNumberDefinition,
    required this.dataFormulas,
  });
  factory DataCalculationGroup.fromJson(Map<String, dynamic> json) =>
      _$DataCalculationGroupFromJson(json);
  Map<String, dynamic> toJson() => _$DataCalculationGroupToJson(this);

  // 静态辅助方法用于序列化 dataFormulas
  static List<TiaoWenFormulaData> _dataFormulasFromJson(List<dynamic> json) {
    return json
        .map((e) => TiaoWenFormulaData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _dataFormulasToJson(
    List<TiaoWenFormulaData> dataFormulas,
  ) {
    return dataFormulas.map((e) => e.toJson()).toList();
  }
}

@JsonSerializable()
class HuangJiDataCalculationFormula {
  final int id;
  final String name; // 例如："皇极取数法三"

  @JsonKey(fromJson: _groupsFromJson, toJson: _groupsToJson)
  final List<DataCalculationGroup> groups; // 按顺序包含所有计算组

  HuangJiDataCalculationFormula({
    required this.id,
    required this.name,
    required this.groups,
  });
  factory HuangJiDataCalculationFormula.fromJson(Map<String, dynamic> json) =>
      _$HuangJiDataCalculationFormulaFromJson(json);
  Map<String, dynamic> toJson() => _$HuangJiDataCalculationFormulaToJson(this);

  // 静态辅助方法用于序列化 groups
  static List<DataCalculationGroup> _groupsFromJson(List<dynamic> json) {
    return json
        .map((e) => DataCalculationGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _groupsToJson(
    List<DataCalculationGroup> groups,
  ) {
    return groups.map((e) => e.toJson()).toList();
  }
}

/// 基础数定义的基类 (抽象类)
abstract class DataBaseNumberDefinition {
  String name;
  String description;
  int rawNumber; // 存储原始数字结果
  final BaseNumberDefinitionType type;

  bool isSelectable;

  DataBaseNumberDefinition({
    required this.rawNumber,
    required this.name,
    required this.description,
    required this.type,
    required this.isSelectable,
  });

  /// 获取处理后的数字，确保始终 ≤ 13000
  /// 如果 rawNumber > 13000 则返回 rawNumber - 12000
  int get number {
    if (rawNumber > 13000) {
      return rawNumber - 12000;
    }
    return rawNumber;
  }

  Map<String, dynamic> toJson();
}

/// 计算部分的数据类：包含实际的计算值
abstract class DataCalculationPart {
  final String name;
  final String description;
  final int rawNumber; // 实际计算出的数值
  int get number => HuangJiBaseNumber.checkToTiaoWenNumber(rawNumber);

  final CalculationPartType type;

  DataCalculationPart({
    required this.name,
    required this.description,
    required this.rawNumber,
    required this.type,
  });

  Map<String, dynamic> toJson();
}

@JsonSerializable()
class DataSingleNumberPart extends DataCalculationPart {
  int raw;
  final FourZhuGanZhiType fourZhuGanZhiType;
  final FourZhuName fourZhuName;
  final EnumNumberPlace numberPlace;
  DataSingleNumberPart({
    required super.name,
    required super.description,
    required this.fourZhuGanZhiType,
    required this.fourZhuName,
    required this.numberPlace,
    required this.raw,
    super.type = CalculationPartType.singleNumber,
  }) : super(rawNumber: raw * numberPlace.factor);
  factory DataSingleNumberPart.fromJson(Map<String, dynamic> json) =>
      _$DataSingleNumberPartFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final json = _$DataSingleNumberPartToJson(this);
    json['number'] = rawNumber; // 确保包含计算出的 number 字段
    return json;
  }
}

/// 组合数字零件
/// 例如：“日干支合数(干为十位+支为个位)”
@JsonSerializable()
class DataCompositeNumberPart extends DataCalculationPart {
  /// 构成这个组合数的"单一零件"列表。
  @JsonKey(fromJson: _dataComponentsFromJson, toJson: _dataComponentsToJson)
  final List<DataCalculationPart> dataComponents;

  DataCompositeNumberPart({
    required super.name,
    required super.description,
    required this.dataComponents,
    super.type = CalculationPartType.compositeNumber,
  }) : super(
         rawNumber: dataComponents.fold(
           0,
           (prev, component) => prev + component.rawNumber,
         ),
       );
  factory DataCompositeNumberPart.fromJson(Map<String, dynamic> json) =>
      _$DataCompositeNumberPartFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final json = _$DataCompositeNumberPartToJson(this);
    json['number'] = rawNumber; // 确保包含计算出的 number 字段
    return json;
  }

  // 静态辅助方法用于序列化 dataComponents
  static List<DataCalculationPart> _dataComponentsFromJson(List<dynamic> json) {
    const converter = DataCalculationPartConverter();
    return json
        .map((e) => converter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _dataComponentsToJson(
    List<DataCalculationPart> dataComponents,
  ) {
    const converter = DataCalculationPartConverter();
    return dataComponents.map((e) => converter.toJson(e)).toList();
  }
}

@JsonSerializable()
class TiaoWenFormulaData {
  final String name;
  @JsonKey(fromJson: _partsFromJson, toJson: _partsToJson)
  final List<DataCalculationPart> parts;
  final String description;
  int get rawNumber =>
      parts.fold(0, (prev, component) => prev + component.rawNumber);
  int get number => HuangJiBaseNumber.checkToTiaoWenNumber(rawNumber);

  TiaoWenFormulaData({
    required this.name,
    required this.parts,
    required this.description,
  });
  factory TiaoWenFormulaData.fromJson(Map<String, dynamic> json) =>
      _$TiaoWenFormulaDataFromJson(json);
  Map<String, dynamic> toJson() => _$TiaoWenFormulaDataToJson(this);

  // 静态辅助方法用于序列化 parts
  static List<DataCalculationPart> _partsFromJson(List<dynamic> json) {
    const converter = DataCalculationPartConverter();
    return json
        .map((e) => converter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _partsToJson(
    List<DataCalculationPart> parts,
  ) {
    const converter = DataCalculationPartConverter();
    return parts.map((e) => converter.toJson(e)).toList();
  }
}

/// 预定义基础数的数据类：包含实际计算出的数值
@JsonSerializable()
class DataPredefinedBaseNumber extends DataBaseNumberDefinition {
  final NumberSource source; // yuanHui 或 yunShi
  // final int sourceValue; // 原始的元会或运世数值

  DataPredefinedBaseNumber({
    required super.rawNumber,
    required super.name,
    required super.description,
    required this.source,
    super.type = BaseNumberDefinitionType.predefined,
    super.isSelectable = false,
    // required this.sourceValue,
  });

  factory DataPredefinedBaseNumber.fromJson(Map<String, dynamic> json) =>
      _$DataPredefinedBaseNumberFromJson(json);
  Map<String, dynamic> toJson() => _$DataPredefinedBaseNumberToJson(this);
}

/// 派生基础数的数据类：包含实际计算出的数值和计算过程
@JsonSerializable()
class DataDerivedBaseNumber extends DataBaseNumberDefinition {
  final String parentGroupId; // 派生来源的计算组ID
  // final int parentBaseNumber; // 父基础数的实际值
  @JsonKey(fromJson: _calculationPartsFromJson, toJson: _calculationPartsToJson)
  final List<DataCalculationPart> calculationParts; // 实际的计算部分数据
  // final List<String> calculationSteps; // 计算步骤记录
  @JsonKey(
    fromJson: DataBaseNumberDefinitionConverter.fromJsonConvertor,
    toJson: DataBaseNumberDefinitionConverter.toJsonConvertor,
  )
  final DataBaseNumberDefinition baseNumberDefinition;

  @override
  int get rawNumber {
    return calculationParts.fold(
      baseNumberDefinition.number,
      (prev, component) => prev + component.rawNumber,
    );
  }

  DataDerivedBaseNumber({
    required super.rawNumber,
    required super.name,
    required super.description,
    required this.parentGroupId,
    required this.calculationParts,
    required this.baseNumberDefinition,
    super.type = BaseNumberDefinitionType.derived,
    super.isSelectable = false,
    // this.calculationSteps = const [],
  });

  factory DataDerivedBaseNumber.fromJson(Map<String, dynamic> json) =>
      _$DataDerivedBaseNumberFromJson(json);
  Map<String, dynamic> toJson() => _$DataDerivedBaseNumberToJson(this);

  // 静态辅助方法用于序列化 calculationParts
  static List<DataCalculationPart> _calculationPartsFromJson(
    List<dynamic> json,
  ) {
    const converter = DataCalculationPartConverter();
    return json
        .map((e) => converter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _calculationPartsToJson(
    List<DataCalculationPart> calculationParts,
  ) {
    const converter = DataCalculationPartConverter();
    return calculationParts.map((e) => converter.toJson(e)).toList();
  }
}

/// 选择式基础数的数据类：包含初刻数和最终选择的数值
@JsonSerializable()
class DataSelectableBaseNumber extends DataBaseNumberDefinition {
  @JsonKey(
    fromJson: DataBaseNumberDefinitionConverter.fromJsonConvertor,
    toJson: DataBaseNumberDefinitionConverter.toJsonConvertor,
  )
  final DataBaseNumberDefinition initialCandidate; // 初刻数的实际计算结果
  final int? candidateValue; // 候选值（初刻数）
  bool get isCompleted => candidateValue != null; // 是否被选中

  @override
  int get number {
    final rawValue = candidateValue ?? initialCandidate.number;
    // 应用与父类相同的逻辑：如果 > 13000 则减去 12000
    if (rawValue > 13000) {
      return rawValue - 12000;
    }
    return rawValue;
  }

  DataSelectableBaseNumber({
    required super.rawNumber,
    required super.name,
    required super.description,
    required this.initialCandidate,
    this.candidateValue,
    super.type = BaseNumberDefinitionType.selectable,
    super.isSelectable = false,
  });

  factory DataSelectableBaseNumber.fromJson(Map<String, dynamic> json) =>
      _$DataSelectableBaseNumberFromJson(json);
  Map<String, dynamic> toJson() => _$DataSelectableBaseNumberToJson(this);
}
