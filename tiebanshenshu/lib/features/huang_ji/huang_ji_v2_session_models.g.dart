// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'huang_ji_v2_session_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionSnapshot _$SessionSnapshotFromJson(Map<String, dynamic> json) =>
    SessionSnapshot(
      snapshotId: json['snapshotId'] as String,
      phase: $enumDecode(_$SessionPhaseEnumMap, json['phase']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      state: json['state'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SessionSnapshotToJson(SessionSnapshot instance) =>
    <String, dynamic>{
      'snapshotId': instance.snapshotId,
      'phase': _$SessionPhaseEnumMap[instance.phase]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'state': instance.state,
    };

const _$SessionPhaseEnumMap = {
  SessionPhase.initialized: 'initialized',
  SessionPhase.yuanHuiYunShiCalculated: 'yuanHuiYunShiCalculated',
  SessionPhase.baseNumberSelectionReady: 'baseNumberSelectionReady',
  SessionPhase.baseNumberSelected: 'baseNumberSelected',
  SessionPhase.finalCalculationComplete: 'finalCalculationComplete',
};

HuangJiSession _$HuangJiSessionFromJson(Map<String, dynamic> json) =>
    HuangJiSession(
      sessionId: json['sessionId'] as String,
      sessionName: json['sessionName'] as String,
      eightChars: EightChars.fromJson(
        json['eightChars'] as Map<String, dynamic>,
      ),
      yuanHuiYunShi: HuangJiSession._yuanHuiYunShiFromJson(
        json['yuanHuiYunShi'] as Map<String, dynamic>?,
      ),
      formulas: HuangJiSession._formulasFromJson(json['formulas'] as List),
      baseNumberSelections: json['baseNumberSelections'] == null
          ? const {}
          : HuangJiSession._selectionsFromJson(
              json['baseNumberSelections'] as Map<String, dynamic>,
            ),
      finalTiaoWenList: HuangJiSession._resultsFromJson(
        json['finalTiaoWenList'] as List?,
      ),
      currentPhase:
          $enumDecodeNullable(_$SessionPhaseEnumMap, json['currentPhase']) ??
          SessionPhase.initialized,
      phaseHistory: json['phaseHistory'] == null
          ? const []
          : HuangJiSession._snapshotsFromJson(json['phaseHistory'] as List),
      status:
          $enumDecodeNullable(_$HuangJiSessionStatusEnumMap, json['status']) ??
          HuangJiSessionStatus.notStarted,
      startTime: DateTime.parse(json['startTime'] as String),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$HuangJiSessionToJson(
  HuangJiSession instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'sessionName': instance.sessionName,
  'eightChars': instance.eightChars,
  'yuanHuiYunShi': HuangJiSession._yuanHuiYunShiToJson(instance.yuanHuiYunShi),
  'formulas': HuangJiSession._formulasToJson(instance.formulas),
  'baseNumberSelections': HuangJiSession._selectionsToJson(
    instance.baseNumberSelections,
  ),
  'finalTiaoWenList': HuangJiSession._resultsToJson(instance.finalTiaoWenList),
  'currentPhase': _$SessionPhaseEnumMap[instance.currentPhase]!,
  'phaseHistory': HuangJiSession._snapshotsToJson(instance.phaseHistory),
  'status': _$HuangJiSessionStatusEnumMap[instance.status]!,
  'startTime': instance.startTime.toIso8601String(),
  'lastActivityAt': instance.lastActivityAt.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'errorMessage': instance.errorMessage,
};

const _$HuangJiSessionStatusEnumMap = {
  HuangJiSessionStatus.notStarted: 'notStarted',
  HuangJiSessionStatus.inProgress: 'inProgress',
  HuangJiSessionStatus.waitingForSelection: 'waitingForSelection',
  HuangJiSessionStatus.paused: 'paused',
  HuangJiSessionStatus.completed: 'completed',
  HuangJiSessionStatus.cancelled: 'cancelled',
  HuangJiSessionStatus.error: 'error',
};
