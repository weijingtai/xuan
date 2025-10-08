// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'huang_ji_formula_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HuangJiCalculationFormula _$HuangJiCalculationFormulaFromJson(
  Map<String, dynamic> json,
) => HuangJiCalculationFormula(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  groups: HuangJiCalculationFormula._groupsFromJson(json['groups'] as List),
);

Map<String, dynamic> _$HuangJiCalculationFormulaToJson(
  HuangJiCalculationFormula instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'groups': HuangJiCalculationFormula._groupsToJson(instance.groups),
};

CalculationGroup _$CalculationGroupFromJson(Map<String, dynamic> json) =>
    CalculationGroup(
      groupId: json['groupId'] as String,
      description: json['description'] as String,
      baseNumberDefinition: const BaseNumberDefinitionConverter().fromJson(
        json['baseNumberDefinition'] as Map<String, dynamic>,
      ),
      formulas: CalculationGroup._formulasFromJson(json['formulas'] as List),
    );

Map<String, dynamic> _$CalculationGroupToJson(CalculationGroup instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'description': instance.description,
      'baseNumberDefinition': const BaseNumberDefinitionConverter().toJson(
        instance.baseNumberDefinition,
      ),
      'formulas': CalculationGroup._formulasToJson(instance.formulas),
    };

PredefinedBaseNumber _$PredefinedBaseNumberFromJson(
  Map<String, dynamic> json,
) => PredefinedBaseNumber(
  name: json['name'] as String,
  description: json['description'] as String,
  source: $enumDecode(_$NumberSourceEnumMap, json['source']),
  type:
      $enumDecodeNullable(_$BaseNumberDefinitionTypeEnumMap, json['type']) ??
      BaseNumberDefinitionType.predefined,
  isSelectable: json['isSelectable'] as bool? ?? false,
);

Map<String, dynamic> _$PredefinedBaseNumberToJson(
  PredefinedBaseNumber instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'type': _$BaseNumberDefinitionTypeEnumMap[instance.type]!,
  'isSelectable': instance.isSelectable,
  'source': _$NumberSourceEnumMap[instance.source]!,
};

const _$NumberSourceEnumMap = {
  NumberSource.yuanHui: '元会',
  NumberSource.yunShi: '运世',
  NumberSource.sixQinCorrectKe: '六亲考刻',
};

const _$BaseNumberDefinitionTypeEnumMap = {
  BaseNumberDefinitionType.predefined: 'predefined',
  BaseNumberDefinitionType.derived: 'derived',
  BaseNumberDefinitionType.selectable: 'selectable',
};

DerivedBaseNumber _$DerivedBaseNumberFromJson(Map<String, dynamic> json) =>
    DerivedBaseNumber(
      name: json['name'] as String,
      description: json['description'] as String,
      baseNumberDefinition: const BaseNumberDefinitionConverter().fromJson(
        json['baseNumberDefinition'] as Map<String, dynamic>,
      ),
      parentGroupId: json['parentGroupId'] as String,
      parts: DerivedBaseNumber._partsFromJson(json['parts'] as List),
      type:
          $enumDecodeNullable(
            _$BaseNumberDefinitionTypeEnumMap,
            json['type'],
          ) ??
          BaseNumberDefinitionType.derived,
      isSelectable: json['isSelectable'] as bool? ?? false,
    );

Map<String, dynamic> _$DerivedBaseNumberToJson(DerivedBaseNumber instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'type': _$BaseNumberDefinitionTypeEnumMap[instance.type]!,
      'isSelectable': instance.isSelectable,
      'parentGroupId': instance.parentGroupId,
      'baseNumberDefinition': const BaseNumberDefinitionConverter().toJson(
        instance.baseNumberDefinition,
      ),
      'parts': DerivedBaseNumber._partsToJson(instance.parts),
    };

SelectableBaseNumber _$SelectableBaseNumberFromJson(
  Map<String, dynamic> json,
) => SelectableBaseNumber(
  name: json['name'] as String,
  description: json['description'] as String,
  initialCandidateFormula: const BaseNumberDefinitionConverter().fromJson(
    json['initialCandidateFormula'] as Map<String, dynamic>,
  ),
  type:
      $enumDecodeNullable(_$BaseNumberDefinitionTypeEnumMap, json['type']) ??
      BaseNumberDefinitionType.selectable,
  isSelectable: json['isSelectable'] as bool? ?? false,
);

Map<String, dynamic> _$SelectableBaseNumberToJson(
  SelectableBaseNumber instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'type': _$BaseNumberDefinitionTypeEnumMap[instance.type]!,
  'isSelectable': instance.isSelectable,
  'initialCandidateFormula': const BaseNumberDefinitionConverter().toJson(
    instance.initialCandidateFormula,
  ),
};

SingleNumberPart _$SingleNumberPartFromJson(Map<String, dynamic> json) =>
    SingleNumberPart(
      name: json['name'] as String,
      description: json['description'] as String,
      fourZhuGanZhiType: $enumDecode(
        _$FourZhuGanZhiTypeEnumMap,
        json['fourZhuGanZhiType'],
      ),
      fourZhuName: $enumDecode(_$FourZhuNameEnumMap, json['fourZhuName']),
      numberPlace: $enumDecode(_$EnumNumberPlaceEnumMap, json['numberPlace']),
      type:
          $enumDecodeNullable(_$CalculationPartTypeEnumMap, json['type']) ??
          CalculationPartType.singleNumber,
    );

Map<String, dynamic> _$SingleNumberPartToJson(
  SingleNumberPart instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'type': _$CalculationPartTypeEnumMap[instance.type]!,
  'fourZhuGanZhiType': _$FourZhuGanZhiTypeEnumMap[instance.fourZhuGanZhiType]!,
  'fourZhuName': _$FourZhuNameEnumMap[instance.fourZhuName]!,
  'numberPlace': _$EnumNumberPlaceEnumMap[instance.numberPlace]!,
};

const _$FourZhuGanZhiTypeEnumMap = {
  FourZhuGanZhiType.gan: '天干',
  FourZhuGanZhiType.zhi: '地支',
};

const _$FourZhuNameEnumMap = {
  FourZhuName.year: '年柱',
  FourZhuName.month: '月柱',
  FourZhuName.day: '日柱',
  FourZhuName.time: '时柱',
};

const _$EnumNumberPlaceEnumMap = {
  EnumNumberPlace.Units: '个',
  EnumNumberPlace.Tens: '十',
  EnumNumberPlace.Hundreds: '百',
  EnumNumberPlace.Thousands: '千',
};

const _$CalculationPartTypeEnumMap = {
  CalculationPartType.singleNumber: 'singleNumber',
  CalculationPartType.compositeNumber: 'compositeNumber',
};

CompositeNumberPart _$CompositeNumberPartFromJson(Map<String, dynamic> json) =>
    CompositeNumberPart(
      name: json['name'] as String,
      description: json['description'] as String,
      components: CompositeNumberPart._componentsFromJson(
        json['components'] as List,
      ),
      type:
          $enumDecodeNullable(_$CalculationPartTypeEnumMap, json['type']) ??
          CalculationPartType.compositeNumber,
    );

Map<String, dynamic> _$CompositeNumberPartToJson(
  CompositeNumberPart instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'type': _$CalculationPartTypeEnumMap[instance.type]!,
  'components': CompositeNumberPart._componentsToJson(instance.components),
};

TiaoWenFormula _$TiaoWenFormulaFromJson(Map<String, dynamic> json) =>
    TiaoWenFormula(
      name: json['name'] as String,
      description: json['description'] as String,
      parts: json['parts'] == null
          ? const []
          : TiaoWenFormula._partsFromJson(json['parts'] as List),
    );

Map<String, dynamic> _$TiaoWenFormulaToJson(TiaoWenFormula instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'parts': TiaoWenFormula._partsToJson(instance.parts),
    };
