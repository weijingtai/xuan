// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'algorithm_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlgorithmConfig _$AlgorithmConfigFromJson(Map<String, dynamic> json) =>
    AlgorithmConfig(
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => ExecutionStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      ruleSets:
          (json['ruleSets'] as List<dynamic>?)
              ?.map((e) => RuleSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      globalConfig: json['globalConfig'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AlgorithmConfigToJson(AlgorithmConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'description': instance.description,
      'steps': instance.steps.map((e) => e.toJson()).toList(),
      'globalConfig': instance.globalConfig,
      'ruleSets': instance.ruleSets.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
