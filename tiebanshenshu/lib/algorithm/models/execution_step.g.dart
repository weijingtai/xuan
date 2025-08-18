// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'execution_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExecutionStep _$ExecutionStepFromJson(Map<String, dynamic> json) =>
    ExecutionStep(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      operationId: json['operationId'] as String,
      config: json['config'] as Map<String, dynamic>? ?? const {},
      inputs:
          (json['inputs'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      outputs:
          (json['outputs'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      conditionalBranches: (json['conditionalBranches'] as List<dynamic>?)
          ?.map((e) => ConditionalBranch.fromJson(e as Map<String, dynamic>))
          .toList(),
      required: json['required'] as bool? ?? true,
      timeoutMs: (json['timeoutMs'] as num?)?.toInt(),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      dependencies:
          (json['dependencies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isOptional: json['isOptional'] as bool? ?? false,
    );

Map<String, dynamic> _$ExecutionStepToJson(ExecutionStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'operationId': instance.operationId,
      'config': instance.config,
      'inputs': instance.inputs,
      'outputs': instance.outputs,
      'conditionalBranches': instance.conditionalBranches,
      'required': instance.required,
      'timeoutMs': instance.timeoutMs,
      'retryCount': instance.retryCount,
      'dependencies': instance.dependencies,
      'isOptional': instance.isOptional,
    };
