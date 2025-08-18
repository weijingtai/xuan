// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleSet _$RuleSetFromJson(Map<String, dynamic> json) => RuleSet(
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  rules: (json['rules'] as List<dynamic>)
      .map((e) => Rule.fromJson(e as Map<String, dynamic>))
      .toList(),
  type:
      $enumDecodeNullable(_$RuleSetTypeEnumMap, json['type']) ??
      RuleSetType.standard,
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  enabled: json['enabled'] as bool? ?? true,
);

Map<String, dynamic> _$RuleSetToJson(RuleSet instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'rules': instance.rules,
  'type': _$RuleSetTypeEnumMap[instance.type]!,
  'priority': instance.priority,
  'enabled': instance.enabled,
};

const _$RuleSetTypeEnumMap = {
  RuleSetType.standard: 'standard',
  RuleSetType.conditional: 'conditional',
  RuleSetType.validation: 'validation',
  RuleSetType.transformation: 'transformation',
  RuleSetType.custom: 'custom',
};

Rule _$RuleFromJson(Map<String, dynamic> json) => Rule(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  condition: json['condition'] as String,
  action: json['action'] as Map<String, dynamic>,
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  enabled: json['enabled'] as bool? ?? true,
  parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$RuleToJson(Rule instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'condition': instance.condition,
  'action': instance.action,
  'priority': instance.priority,
  'enabled': instance.enabled,
  'parameters': instance.parameters,
};
