// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interactive_strategy_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InteractiveStrategyConfig _$InteractiveStrategyConfigFromJson(
  Map<String, dynamic> json,
) => InteractiveStrategyConfig(
  enableFourZhuConfirmation: json['enableFourZhuConfirmation'] as bool? ?? true,
  enableCalculationMethodSelection:
      json['enableCalculationMethodSelection'] as bool? ?? true,
  enableGuaMappingSelection:
      json['enableGuaMappingSelection'] as bool? ?? false,
  allowUndo: json['allowUndo'] as bool? ?? true,
  allowJump: json['allowJump'] as bool? ?? false,
  maxUndoSteps: (json['maxUndoSteps'] as num?)?.toInt() ?? 10,
  sessionTimeoutMinutes: (json['sessionTimeoutMinutes'] as num?)?.toInt() ?? 30,
  autoSaveSession: json['autoSaveSession'] as bool? ?? true,
  showDetailedProgress: json['showDetailedProgress'] as bool? ?? true,
  enableAnimations: json['enableAnimations'] as bool? ?? true,
  stepSize: (json['stepSize'] as num?)?.toInt() ?? 30,
  candidateCount: (json['candidateCount'] as num?)?.toInt() ?? 10,
  maxSteps: (json['maxSteps'] as num?)?.toInt() ?? 5,
);

Map<String, dynamic> _$InteractiveStrategyConfigToJson(
  InteractiveStrategyConfig instance,
) => <String, dynamic>{
  'enableFourZhuConfirmation': instance.enableFourZhuConfirmation,
  'enableCalculationMethodSelection': instance.enableCalculationMethodSelection,
  'enableGuaMappingSelection': instance.enableGuaMappingSelection,
  'allowUndo': instance.allowUndo,
  'allowJump': instance.allowJump,
  'maxUndoSteps': instance.maxUndoSteps,
  'sessionTimeoutMinutes': instance.sessionTimeoutMinutes,
  'autoSaveSession': instance.autoSaveSession,
  'showDetailedProgress': instance.showDetailedProgress,
  'enableAnimations': instance.enableAnimations,
  'stepSize': instance.stepSize,
  'candidateCount': instance.candidateCount,
  'maxSteps': instance.maxSteps,
};
