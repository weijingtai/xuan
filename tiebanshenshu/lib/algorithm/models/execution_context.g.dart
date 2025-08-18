// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'execution_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExecutionRecord _$ExecutionRecordFromJson(Map<String, dynamic> json) =>
    ExecutionRecord(
      stepId: json['stepId'] as String,
      stepName: json['stepName'] as String,
      operationId: json['operationId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      status: $enumDecode(_$ExecutionStatusEnumMap, json['status']),
      inputs: json['inputs'] as Map<String, dynamic>,
      outputs: json['outputs'] as Map<String, dynamic>,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$ExecutionRecordToJson(ExecutionRecord instance) =>
    <String, dynamic>{
      'stepId': instance.stepId,
      'stepName': instance.stepName,
      'operationId': instance.operationId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'status': _$ExecutionStatusEnumMap[instance.status]!,
      'inputs': instance.inputs,
      'outputs': instance.outputs,
      'errorMessage': instance.errorMessage,
    };

const _$ExecutionStatusEnumMap = {
  ExecutionStatus.pending: 'pending',
  ExecutionStatus.running: 'running',
  ExecutionStatus.success: 'success',
  ExecutionStatus.failed: 'failed',
  ExecutionStatus.skipped: 'skipped',
};

ExecutionError _$ExecutionErrorFromJson(Map<String, dynamic> json) =>
    ExecutionError(
      code: json['code'] as String,
      message: json['message'] as String,
      stepId: json['stepId'] as String?,
      operationId: json['operationId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as Map<String, dynamic>? ?? const {},
      originalException: json['originalException'],
      errorType: $enumDecode(_$ErrorTypeEnumMap, json['errorType']),
    );

Map<String, dynamic> _$ExecutionErrorToJson(ExecutionError instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'stepId': instance.stepId,
      'operationId': instance.operationId,
      'timestamp': instance.timestamp.toIso8601String(),
      'details': instance.details,
      'originalException': instance.originalException,
      'errorType': _$ErrorTypeEnumMap[instance.errorType]!,
    };

const _$ErrorTypeEnumMap = {
  ErrorType.warning: 'warning',
  ErrorType.error: 'error',
  ErrorType.fatal: 'fatal',
};
