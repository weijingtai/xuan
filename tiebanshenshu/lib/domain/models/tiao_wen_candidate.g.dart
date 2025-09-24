// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tiao_wen_candidate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TiaoWenCandidate _$TiaoWenCandidateFromJson(Map<String, dynamic> json) =>
    TiaoWenCandidate(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$TiaoWenCandidateTypeEnumMap, json['type']),
      value: json['value'],
      isDefault: json['isDefault'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TiaoWenCandidateToJson(TiaoWenCandidate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'description': instance.description,
      'type': _$TiaoWenCandidateTypeEnumMap[instance.type]!,
      'value': instance.value,
      'isDefault': instance.isDefault,
      'isEnabled': instance.isEnabled,
      'metadata': instance.metadata,
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
