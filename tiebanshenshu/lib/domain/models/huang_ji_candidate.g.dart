// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'huang_ji_candidate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HuangJiCandidate _$HuangJiCandidateFromJson(Map<String, dynamic> json) =>
    HuangJiCandidate(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$TiaoWenCandidateTypeEnumMap, json['type']),
      value: json['value'],
      number: (json['number'] as num).toInt(),
      offset: (json['offset'] as num).toInt(),
      stepCount: (json['stepCount'] as num).toInt(),
      isBase: json['isBase'] as bool,
      isInitialSecondary: json['isInitialSecondary'] as bool,
      adjustmentDirection: (json['adjustmentDirection'] as num).toInt(),
      adjustmentCount: (json['adjustmentCount'] as num).toInt(),
      isDefault: json['isDefault'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$HuangJiCandidateToJson(HuangJiCandidate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'type': _$TiaoWenCandidateTypeEnumMap[instance.type]!,
      'value': instance.value,
      'isDefault': instance.isDefault,
      'isEnabled': instance.isEnabled,
      'metadata': instance.metadata,
      'isInitialSecondary': instance.isInitialSecondary,
      'adjustmentDirection': instance.adjustmentDirection,
      'adjustmentCount': instance.adjustmentCount,
      'number': instance.number,
      'offset': instance.offset,
      'stepCount': instance.stepCount,
      'isBase': instance.isBase,
      'description': instance.description,
    };

const _$TiaoWenCandidateTypeEnumMap = {
  TiaoWenCandidateType.baseNumber: 'baseNumber',
  TiaoWenCandidateType.gua: 'gua',
  TiaoWenCandidateType.ganzhi: 'ganzhi',
  TiaoWenCandidateType.fourZhu: 'fourZhu',
  TiaoWenCandidateType.guaMapping: 'guaMapping',
  TiaoWenCandidateType.confirmation: 'confirmation',
  TiaoWenCandidateType.calculationMethod: 'calculationMethod',
  TiaoWenCandidateType.custom: 'custom',
};
