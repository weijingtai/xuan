// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'huang_ji_formula_data_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataCalculationGroup _$DataCalculationGroupFromJson(
  Map<String, dynamic> json,
) => DataCalculationGroup(
  groupId: json['groupId'] as String,
  description: json['description'] as String,
  baseNumberDefinition: DataBaseNumberDefinitionConverter.fromJsonConvertor(
    json['baseNumberDefinition'] as Map<String, dynamic>,
  ),
  dataFormulas: DataCalculationGroup._dataFormulasFromJson(
    json['dataFormulas'] as List,
  ),
);

Map<String, dynamic> _$DataCalculationGroupToJson(
  DataCalculationGroup instance,
) => <String, dynamic>{
  'groupId': instance.groupId,
  'description': instance.description,
  'baseNumberDefinition': DataBaseNumberDefinitionConverter.toJsonConvertor(
    instance.baseNumberDefinition,
  ),
  'dataFormulas': DataCalculationGroup._dataFormulasToJson(
    instance.dataFormulas,
  ),
};

HuangJiDataCalculationFormula _$HuangJiDataCalculationFormulaFromJson(
  Map<String, dynamic> json,
) => HuangJiDataCalculationFormula(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  groups: HuangJiDataCalculationFormula._groupsFromJson(json['groups'] as List),
);

Map<String, dynamic> _$HuangJiDataCalculationFormulaToJson(
  HuangJiDataCalculationFormula instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'groups': HuangJiDataCalculationFormula._groupsToJson(instance.groups),
};

DataSingleNumberPart _$DataSingleNumberPartFromJson(
  Map<String, dynamic> json,
) => DataSingleNumberPart(
  name: json['name'] as String,
  description: json['description'] as String,
  fourZhuGanZhiType: $enumDecode(
    _$FourZhuGanZhiTypeEnumMap,
    json['fourZhuGanZhiType'],
  ),
  fourZhuName: $enumDecode(_$FourZhuNameEnumMap, json['fourZhuName']),
  numberPlace: $enumDecode(_$EnumNumberPlaceEnumMap, json['numberPlace']),
  raw: (json['raw'] as num).toInt(),
  type:
      $enumDecodeNullable(_$CalculationPartTypeEnumMap, json['type']) ??
      CalculationPartType.singleNumber,
);

Map<String, dynamic> _$DataSingleNumberPartToJson(
  DataSingleNumberPart instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'type': _$CalculationPartTypeEnumMap[instance.type]!,
  'raw': instance.raw,
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

DataCompositeNumberPart _$DataCompositeNumberPartFromJson(
  Map<String, dynamic> json,
) => DataCompositeNumberPart(
  name: json['name'] as String,
  description: json['description'] as String,
  dataComponents: DataCompositeNumberPart._dataComponentsFromJson(
    json['dataComponents'] as List,
  ),
  type:
      $enumDecodeNullable(_$CalculationPartTypeEnumMap, json['type']) ??
      CalculationPartType.compositeNumber,
);

Map<String, dynamic> _$DataCompositeNumberPartToJson(
  DataCompositeNumberPart instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'type': _$CalculationPartTypeEnumMap[instance.type]!,
  'dataComponents': DataCompositeNumberPart._dataComponentsToJson(
    instance.dataComponents,
  ),
};

TiaoWenFormulaData _$TiaoWenFormulaDataFromJson(Map<String, dynamic> json) =>
    TiaoWenFormulaData(
      name: json['name'] as String,
      parts: TiaoWenFormulaData._partsFromJson(json['parts'] as List),
      description: json['description'] as String,
    );

Map<String, dynamic> _$TiaoWenFormulaDataToJson(TiaoWenFormulaData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'parts': TiaoWenFormulaData._partsToJson(instance.parts),
      'description': instance.description,
    };

DataPredefinedBaseNumber _$DataPredefinedBaseNumberFromJson(
  Map<String, dynamic> json,
) => DataPredefinedBaseNumber(
  rawNumber: (json['rawNumber'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  source: $enumDecode(_$NumberSourceEnumMap, json['source']),
  type:
      $enumDecodeNullable(_$BaseNumberDefinitionTypeEnumMap, json['type']) ??
      BaseNumberDefinitionType.predefined,
  isSelectable: json['isSelectable'] as bool? ?? false,
);

Map<String, dynamic> _$DataPredefinedBaseNumberToJson(
  DataPredefinedBaseNumber instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'rawNumber': instance.rawNumber,
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

DataDerivedBaseNumber _$DataDerivedBaseNumberFromJson(
  Map<String, dynamic> json,
) => DataDerivedBaseNumber(
  rawNumber: (json['rawNumber'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  parentGroupId: json['parentGroupId'] as String,
  calculationParts: DataDerivedBaseNumber._calculationPartsFromJson(
    json['calculationParts'] as List,
  ),
  baseNumberDefinition: DataBaseNumberDefinitionConverter.fromJsonConvertor(
    json['baseNumberDefinition'] as Map<String, dynamic>,
  ),
  type:
      $enumDecodeNullable(_$BaseNumberDefinitionTypeEnumMap, json['type']) ??
      BaseNumberDefinitionType.derived,
  isSelectable: json['isSelectable'] as bool? ?? false,
);

Map<String, dynamic> _$DataDerivedBaseNumberToJson(
  DataDerivedBaseNumber instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'type': _$BaseNumberDefinitionTypeEnumMap[instance.type]!,
  'isSelectable': instance.isSelectable,
  'parentGroupId': instance.parentGroupId,
  'calculationParts': DataDerivedBaseNumber._calculationPartsToJson(
    instance.calculationParts,
  ),
  'baseNumberDefinition': DataBaseNumberDefinitionConverter.toJsonConvertor(
    instance.baseNumberDefinition,
  ),
  'rawNumber': instance.rawNumber,
};

DataSelectableBaseNumber _$DataSelectableBaseNumberFromJson(
  Map<String, dynamic> json,
) => DataSelectableBaseNumber(
  rawNumber: (json['rawNumber'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  initialCandidate: DataBaseNumberDefinitionConverter.fromJsonConvertor(
    json['initialCandidate'] as Map<String, dynamic>,
  ),
  candidateValue: (json['candidateValue'] as num?)?.toInt(),
  type:
      $enumDecodeNullable(_$BaseNumberDefinitionTypeEnumMap, json['type']) ??
      BaseNumberDefinitionType.selectable,
  isSelectable: json['isSelectable'] as bool? ?? false,
);

Map<String, dynamic> _$DataSelectableBaseNumberToJson(
  DataSelectableBaseNumber instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'rawNumber': instance.rawNumber,
  'type': _$BaseNumberDefinitionTypeEnumMap[instance.type]!,
  'isSelectable': instance.isSelectable,
  'initialCandidate': DataBaseNumberDefinitionConverter.toJsonConvertor(
    instance.initialCandidate,
  ),
  'candidateValue': instance.candidateValue,
};
