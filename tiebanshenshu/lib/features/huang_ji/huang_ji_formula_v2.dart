import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiebanshenshu/domain/models/yuan_hui_yun_shi.dart';

import 'huang_ji_formula_data_v2.dart';
import '../../domain/models/huang_ji_number.dart';
part 'huang_ji_formula_v2.g.dart';

/// CalculationPart 的多态 JSON 转换器
class CalculationPartConverter
    implements JsonConverter<CalculationPart, Map<String, dynamic>> {
  const CalculationPartConverter();

  @override
  CalculationPart fromJson(Map<String, dynamic> json) {
    final type = CalculationPartType.fromValue(json['type'] as String);
    switch (type) {
      case CalculationPartType.singleNumber:
        return SingleNumberPart.fromJson(json);
      case CalculationPartType.compositeNumber:
        return CompositeNumberPart.fromJson(json);
    }
  }

  @override
  Map<String, dynamic> toJson(CalculationPart object) {
    final json = <String, dynamic>{};
    if (object is SingleNumberPart) {
      json.addAll(object.toJson());
    } else if (object is CompositeNumberPart) {
      json.addAll(object.toJson());
    }
    json['type'] = object.type.value;
    return json;
  }
}

class BaseNumberDefinitionConverter
    implements JsonConverter<BaseNumberDefinition, Map<String, dynamic>> {
  const BaseNumberDefinitionConverter();

  @override
  BaseNumberDefinition fromJson(Map<String, dynamic> json) {
    final type = BaseNumberDefinitionType.fromValue(json['type'] as String);
    switch (type) {
      case BaseNumberDefinitionType.predefined:
        return PredefinedBaseNumber.fromJson(json);
      case BaseNumberDefinitionType.derived:
        return DerivedBaseNumber.fromJson(json);
      case BaseNumberDefinitionType.selectable:
        return SelectableBaseNumber.fromJson(json);
    }
  }

  @override
  Map<String, dynamic> toJson(BaseNumberDefinition object) {
    final json = <String, dynamic>{};
    if (object is PredefinedBaseNumber) {
      json.addAll(object.toJson());
    } else if (object is DerivedBaseNumber) {
      json.addAll(object.toJson());
    } else if (object is SelectableBaseNumber) {
      json.addAll(object.toJson());
    }
    json['type'] = object.type.value;
    return json;
  }
}

/// 代表一整套完整的取数法，包含多个计算阶段/分组。
@JsonSerializable()
class HuangJiCalculationFormula {
  final int id;
  final String name; // 例如："皇极取数法三"
  final String description; // 例如："元会公式"
  @JsonKey(fromJson: _groupsFromJson, toJson: _groupsToJson)
  final List<CalculationGroup> groups; // 按顺序包含所有计算组

  HuangJiCalculationFormula({
    required this.id,
    required this.name,
    required this.description,
    required this.groups,
  });
  factory HuangJiCalculationFormula.fromJson(Map<String, dynamic> json) =>
      _$HuangJiCalculationFormulaFromJson(json);

  // 静态辅助方法用于 groups 字段的序列化
  static List<CalculationGroup> _groupsFromJson(List<dynamic> json) {
    return json
        .map((e) => CalculationGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _groupsToJson(
    List<CalculationGroup> groups,
  ) {
    return groups.map((e) => e.toJson()).toList();
  }

  Map<String, dynamic> toJson() => _$HuangJiCalculationFormulaToJson(this);

  HuangJiDataCalculationFormula toData(YuanHuiYunShi yhys) {
    var dataGroups = groups.map((e) => e.toData(yhys)).toList();
    return HuangJiDataCalculationFormula(
      id: id,
      name: name,
      groups: dataGroups,
    );
  }
}

/// 代表一个计算分组，它围绕一个特定的“基础数”展开。
@JsonSerializable()
class CalculationGroup {
  final String groupId; // 唯一标识符, 如 "base_one", "base_two"
  final String description; // 例如: "围绕基础数一的计算"

  /// 本组所使用的"基础数"是如何定义的。
  @BaseNumberDefinitionConverter()
  final BaseNumberDefinition baseNumberDefinition;

  /// 使用上述"基础数"进行的一系列条文计算公式。
  @JsonKey(fromJson: _formulasFromJson, toJson: _formulasToJson)
  final List<TiaoWenFormula> formulas;

  CalculationGroup({
    required this.groupId,
    required this.description,
    required this.baseNumberDefinition,
    required this.formulas,
  });
  factory CalculationGroup.fromJson(Map<String, dynamic> json) =>
      _$CalculationGroupFromJson(json);

  // 静态辅助方法用于 formulas 字段的序列化
  static List<TiaoWenFormula> _formulasFromJson(List<dynamic> json) {
    return json
        .map((e) => TiaoWenFormula.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _formulasToJson(
    List<TiaoWenFormula> formulas,
  ) {
    return formulas.map((e) => e.toJson()).toList();
  }

  Map<String, dynamic> toJson() => _$CalculationGroupToJson(this);

  DataCalculationGroup toData(YuanHuiYunShi yhys) {
    var dataFormulas = formulas.map((e) => e.toData(yhys)).toList();
    DataBaseNumberDefinition dataBaseNumberDefinition;
    if (baseNumberDefinition is PredefinedBaseNumber) {
      dataBaseNumberDefinition = (baseNumberDefinition as PredefinedBaseNumber)
          .toData(yhys);
    } else if (baseNumberDefinition is DerivedBaseNumber) {
      dataBaseNumberDefinition = (baseNumberDefinition as DerivedBaseNumber)
          .toData(yhys);
    } else if (baseNumberDefinition is SelectableBaseNumber) {
      dataBaseNumberDefinition = (baseNumberDefinition as SelectableBaseNumber)
          .toData(yhys);
    } else {
      throw UnimplementedError(
        'BaseNumberDefinition type ${baseNumberDefinition.runtimeType} is not supported',
      );
    }
    return DataCalculationGroup(
      groupId: groupId,
      description: description,
      baseNumberDefinition: dataBaseNumberDefinition,
      dataFormulas: dataFormulas,
    );
  }
}

/// 基础数定义的基类 (抽象类)
abstract class BaseNumberDefinition {
  String name;
  String description;
  final BaseNumberDefinitionType type;
  bool isSelectable;
  BaseNumberDefinition({
    required this.name,
    required this.description,
    required this.type,
    required this.isSelectable,
  });

  Map<String, dynamic> toJson();

  // // Custom JSON serialization for polymorphic types
  // factory BaseNumberDefinition.fromJson(Map<String, dynamic> json) {
  //   // Determine the concrete type based on the presence of specific fields
  //   switch (BaseNumberDefinitionType.fromValue(json['type'] as String)) {
  //     case BaseNumberDefinitionType.predefined:
  //       return PredefinedBaseNumber.fromJson({
  //         ...json,
  //         'type': BaseNumberDefinitionType.predefined.value,
  //       });
  //     case BaseNumberDefinitionType.derived:
  //       return DerivedBaseNumber.fromJson({
  //         ...json,
  //         'type': BaseNumberDefinitionType.derived.value,
  //       });
  //     case BaseNumberDefinitionType.selectable:
  //       return SelectableBaseNumber.fromJson({
  //         ...json,
  //         'type': BaseNumberDefinitionType.selectable.value,
  //       });
  //   }
  // }

  // Map<String, dynamic> toJson() {
  //   if (this is PredefinedBaseNumber) {
  //     return (this as PredefinedBaseNumber).toJson();
  //   } else if (this is DerivedBaseNumber) {
  //     return (this as DerivedBaseNumber).toJson();
  //   } else if (this is SelectableBaseNumber) {
  //     return (this as SelectableBaseNumber).toJson();
  //   } else {
  //     throw ArgumentError('Unknown BaseNumberDefinition type: ${runtimeType}');
  //   }
  // }

  /// 将当前基础数定义转换为数据模型。
  DataBaseNumberDefinition toData(YuanHuiYunShi yhys) {
    switch (type) {
      case BaseNumberDefinitionType.predefined:
        return (this as PredefinedBaseNumber).toData(yhys);
      case BaseNumberDefinitionType.derived:
        return (this as DerivedBaseNumber).toData(yhys);
      case BaseNumberDefinitionType.selectable:
        return (this as SelectableBaseNumber).toData(yhys);
    }
  }
}

enum BaseNumberDefinitionType {
  @JsonValue('predefined')
  predefined('predefined'),
  @JsonValue('derived')
  derived('derived'),
  @JsonValue('selectable')
  selectable('selectable');

  final String value;

  const BaseNumberDefinitionType(this.value);

  static BaseNumberDefinitionType fromValue(String value) {
    return BaseNumberDefinitionType.values.firstWhere(
      (element) => element.value == value,
      orElse: () =>
          throw ArgumentError('Unknown BaseNumberDefinitionType: $value'),
    );
  }
}

/// 来源一：来自预先算好的元会/运世基础数。
/// (这兼容了我们最初的设计)
@JsonSerializable()
class PredefinedBaseNumber extends BaseNumberDefinition {
  final NumberSource source; // yuanHui 或 yunShi

  PredefinedBaseNumber({
    required super.name,
    required super.description,
    required this.source,
    super.type = BaseNumberDefinitionType.predefined,
    super.isSelectable = false,
  });
  factory PredefinedBaseNumber.fromJson(Map<String, dynamic> json) =>
      _$PredefinedBaseNumberFromJson(json);
  Map<String, dynamic> toJson() => _$PredefinedBaseNumberToJson(this);

  DataSelectableBaseNumber toSelectableData(YuanHuiYunShi yhys) {
    return DataSelectableBaseNumber(
      name: name,
      description: description,
      initialCandidate: toData(yhys),
      rawNumber: -1,
    );
  }

  @override
  DataPredefinedBaseNumber toData(YuanHuiYunShi yhys) {
    int number = 0;
    if (source == NumberSource.yuanHui) {
      number = yhys.yuanHuiMergeNumber.number;
    } else if (source == NumberSource.yunShi) {
      number = yhys.yunShiMergeNumber.number;
    }
    return DataPredefinedBaseNumber(
      name: name,
      description: description,
      source: source,
      rawNumber: number,
      isSelectable: isSelectable,
    );
  }
}

/// 来源二：由另一个基础数派生而来。
/// (这是解决缺陷一的关键)
@JsonSerializable()
class DerivedBaseNumber extends BaseNumberDefinition {
  /// 派生的来源是哪个计算组的ID。
  final String parentGroupId;

  @BaseNumberDefinitionConverter()
  final BaseNumberDefinition baseNumberDefinition;

  /// 在父基础数之上，需要进行哪些运算来得到当前基础数。
  @JsonKey(fromJson: _partsFromJson, toJson: _partsToJson)
  final List<CalculationPart> parts;
  DerivedBaseNumber({
    required super.name,
    required super.description,
    required this.baseNumberDefinition,
    required this.parentGroupId,
    required this.parts,
    super.type = BaseNumberDefinitionType.derived,
    super.isSelectable = false,
  });
  factory DerivedBaseNumber.fromJson(Map<String, dynamic> json) =>
      _$DerivedBaseNumberFromJson(json);
  Map<String, dynamic> toJson() => _$DerivedBaseNumberToJson(this);

  // 静态辅助方法用于 parts 字段的序列化
  static List<CalculationPart> _partsFromJson(List<dynamic> json) {
    const converter = CalculationPartConverter();
    return json
        .map((e) => converter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _partsToJson(List<CalculationPart> parts) {
    const converter = CalculationPartConverter();
    return parts.map((e) => converter.toJson(e)).toList();
  }

  @optionalTypeArgs
  DataDerivedBaseNumber toData(YuanHuiYunShi yhys) {
    var dataParts = parts.map((e) => e.toData(yhys)).toList();
    return DataDerivedBaseNumber(
      name: name,
      description: description,
      parentGroupId: parentGroupId,
      rawNumber: dataParts.fold(0, (prev, e) => prev + e.rawNumber),
      calculationParts: dataParts,
      baseNumberDefinition: baseNumberDefinition.toData(yhys),
      isSelectable: isSelectable,
    );
  }
}

/// 选择式基础数：用于描述需要通过 “初刻数 +/- 30” 逻辑来确定的基础数。
@JsonSerializable()
class SelectableBaseNumber extends BaseNumberDefinition {
  /// “初刻数” (第一个候选值) 是如何计算的。
  /// 这通常是一个派生公式，例如：“元会基础数 + 年干太玄数(千位)”。
  @BaseNumberDefinitionConverter()
  final BaseNumberDefinition initialCandidateFormula;
  SelectableBaseNumber({
    required super.name,
    required super.description,
    required this.initialCandidateFormula,
    super.type = BaseNumberDefinitionType.selectable,
    super.isSelectable = false,
  });
  factory SelectableBaseNumber.fromJson(Map<String, dynamic> json) =>
      _$SelectableBaseNumberFromJson(json);
  @override
  Map<String, dynamic> toJson() {
    final json = _$SelectableBaseNumberToJson(this);
    json['type'] = type.value;
    return json;
  }

  @override
  DataSelectableBaseNumber toData(YuanHuiYunShi yhys) {
    return DataSelectableBaseNumber(
      name: name,
      description: description,
      initialCandidate: initialCandidateFormula.toData(yhys),
      rawNumber: -1,
      isSelectable: isSelectable,
    );
  }
}

enum CalculationPartType {
  @JsonValue('singleNumber')
  singleNumber('singleNumber'),
  @JsonValue('compositeNumber')
  compositeNumber('compositeNumber');

  final String value;

  const CalculationPartType(this.value);

  static CalculationPartType fromValue(String value) {
    return CalculationPartType.values.firstWhere(
      (element) => element.value == value,
      orElse: () => throw ArgumentError('Unknown CalculationPartType: $value'),
    );
  }
}

/// 计算零件的基类 (抽象类)
abstract class CalculationPart {
  final String name; // 例如："月干(百位数)"
  final String description; // 例如："月干(百位数) = 月干(gan) + 月支(zhi)"
  final CalculationPartType type;
  const CalculationPart({
    required this.name,
    required this.description,
    required this.type,
  });

  Map<String, dynamic> toJson();
  DataCalculationPart toData(YuanHuiYunShi yhys);
}

/// 单一数字零件 (之前的 HuangJiFormulaOtherSingleNumberPart)
/// 例如：“月干(百位数)”
@JsonSerializable()
class SingleNumberPart extends CalculationPart {
  final FourZhuGanZhiType fourZhuGanZhiType;
  final FourZhuName fourZhuName;
  final EnumNumberPlace numberPlace;

  SingleNumberPart({
    required super.name,
    required super.description,
    required this.fourZhuGanZhiType,
    required this.fourZhuName,
    required this.numberPlace,
    super.type = CalculationPartType.singleNumber,
  });

  factory SingleNumberPart.fromJson(Map<String, dynamic> json) =>
      _$SingleNumberPartFromJson(json);
  @override
  Map<String, dynamic> toJson() {
    final json = _$SingleNumberPartToJson(this);
    json['type'] = type.value;
    return json;
  }

  DataCalculationPart toData(YuanHuiYunShi yhys) {
    int raw = yhys.getTaiXuanNumberBy(
      ganZhiType: fourZhuGanZhiType,
      fourZhu: fourZhuName,
    );
    return DataSingleNumberPart(
      name: name,
      description: description,
      fourZhuGanZhiType: fourZhuGanZhiType,
      fourZhuName: fourZhuName,
      numberPlace: numberPlace,
      raw: raw,
    );
  }
}

/// 组合数字零件
/// 例如：“日干支合数(干为十位+支为个位)”
@JsonSerializable()
class CompositeNumberPart extends CalculationPart {
  /// 构成这个组合数的"单一零件"列表。
  ///
  @JsonKey(fromJson: _componentsFromJson, toJson: _componentsToJson)
  final List<SingleNumberPart> components;

  // /// 这些零件之间是如何运算的。
  // /// 对于“日干十位+日支个位”，operator应为 add。
  // final EnumHuangJiOperator operator;

  const CompositeNumberPart({
    required super.name,
    required super.description,
    required this.components,
    super.type = CalculationPartType.compositeNumber,
  });

  factory CompositeNumberPart.fromJson(Map<String, dynamic> json) =>
      _$CompositeNumberPartFromJson(json);

  // 静态辅助方法用于 components 字段的序列化
  static List<SingleNumberPart> _componentsFromJson(List<dynamic> json) {
    return json
        .map((e) => SingleNumberPart.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _componentsToJson(
    List<SingleNumberPart> components,
  ) {
    return components.map((e) => e.toJson()).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    final json = _$CompositeNumberPartToJson(this);
    json['type'] = type.value;
    return json;
  }

  DataCalculationPart toData(YuanHuiYunShi yhys) {
    var dataComp = components.map((e) => e.toData(yhys)).toList();
    return DataCompositeNumberPart(
      name: name,
      description: description,
      dataComponents: dataComp,
    );
  }
}

/// 最后，条文公式本身被简化了。
/// 它不再需要关心基础数是什么，只关心在基础数上加什么即可。
@JsonSerializable()
class TiaoWenFormula {
  final String name;
  final String description;
  @JsonKey(fromJson: _partsFromJson, toJson: _partsToJson)
  final List<CalculationPart> parts;

  TiaoWenFormula({
    required this.name,
    required this.description,
    this.parts = const [],
  });

  factory TiaoWenFormula.fromJson(Map<String, dynamic> json) =>
      _$TiaoWenFormulaFromJson(json);

  // 静态辅助方法用于 parts 字段的序列化
  static List<CalculationPart> _partsFromJson(List<dynamic> json) {
    const converter = CalculationPartConverter();
    return json
        .map((e) => converter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _partsToJson(List<CalculationPart> parts) {
    const converter = CalculationPartConverter();
    return parts.map((e) => converter.toJson(e)).toList();
  }

  Map<String, dynamic> toJson() => _$TiaoWenFormulaToJson(this);

  TiaoWenFormulaData toData(YuanHuiYunShi yhys) {
    var dataParts = parts.map((e) => e.toData(yhys)).toList();
    return TiaoWenFormulaData(
      name: name,
      parts: dataParts,
      description: description,
    );
  }
}
