// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditional_branch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConditionalBranch _$ConditionalBranchFromJson(Map<String, dynamic> json) =>
    ConditionalBranch(
      condition: json['condition'] as String,
      description: json['description'] as String? ?? '',
      trueSteps: (json['trueSteps'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      falseSteps: (json['falseSteps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      type:
          $enumDecodeNullable(_$ConditionTypeEnumMap, json['type']) ??
          ConditionType.expression,
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ConditionalBranchToJson(ConditionalBranch instance) =>
    <String, dynamic>{
      'condition': instance.condition,
      'description': instance.description,
      'trueSteps': instance.trueSteps,
      'falseSteps': instance.falseSteps,
      'type': _$ConditionTypeEnumMap[instance.type]!,
      'parameters': instance.parameters,
    };

const _$ConditionTypeEnumMap = {
  ConditionType.expression: 'expression',
  ConditionType.numeric: 'numeric',
  ConditionType.string: 'string',
  ConditionType.boolean: 'boolean',
  ConditionType.custom: 'custom',
};
