// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'atomic_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParameterDefinition _$ParameterDefinitionFromJson(Map<String, dynamic> json) =>
    ParameterDefinition(
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ParameterTypeEnumMap, json['type']),
      required: json['required'] as bool? ?? true,
      defaultValue: json['defaultValue'],
      validationRules:
          (json['validationRules'] as List<dynamic>?)
              ?.map((e) => ValidationRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      exampleValue: json['exampleValue'],
    );

Map<String, dynamic> _$ParameterDefinitionToJson(
  ParameterDefinition instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'type': _$ParameterTypeEnumMap[instance.type]!,
  'required': instance.required,
  'defaultValue': instance.defaultValue,
  'validationRules': instance.validationRules,
  'exampleValue': instance.exampleValue,
};

const _$ParameterTypeEnumMap = {
  ParameterType.str: 'str',
  ParameterType.intNum: 'intNum',
  ParameterType.doubleNum: 'doubleNum',
  ParameterType.boolean: 'boolean',
  ParameterType.array: 'array',
  ParameterType.dict: 'dict',
  ParameterType.any: 'any',
};
