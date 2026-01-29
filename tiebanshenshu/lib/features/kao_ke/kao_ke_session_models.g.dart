// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kao_ke_session_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeSelectionRecord _$KeSelectionRecordFromJson(Map<String, dynamic> json) =>
    KeSelectionRecord(
      shiChen: $enumDecode(_$DiZhiEnumMap, json['shiChen']),
      ke: $enumDecode(_$EigthKeEnumMap, json['ke']),
      tiaoWenNumber: (json['tiaoWenNumber'] as num).toInt(),
      cipherText: json['cipherText'] as String,
      originalText: json['originalText'] as String,
      selectedAt: DateTime.parse(json['selectedAt'] as String),
    );

Map<String, dynamic> _$KeSelectionRecordToJson(KeSelectionRecord instance) =>
    <String, dynamic>{
      'shiChen': _$DiZhiEnumMap[instance.shiChen]!,
      'ke': _$EigthKeEnumMap[instance.ke]!,
      'tiaoWenNumber': instance.tiaoWenNumber,
      'cipherText': instance.cipherText,
      'originalText': instance.originalText,
      'selectedAt': instance.selectedAt.toIso8601String(),
    };

const _$DiZhiEnumMap = {
  DiZhi.ZI: '子',
  DiZhi.CHOU: '丑',
  DiZhi.YIN: '寅',
  DiZhi.MAO: '卯',
  DiZhi.CHEN: '辰',
  DiZhi.SI: '巳',
  DiZhi.WU: '午',
  DiZhi.WEI: '未',
  DiZhi.SHEN: '申',
  DiZhi.YOU: '酉',
  DiZhi.XU: '戌',
  DiZhi.HAI: '亥',
};

const _$EigthKeEnumMap = {
  EigthKe.first: 1,
  EigthKe.second: 2,
  EigthKe.third: 3,
  EigthKe.fourth: 4,
  EigthKe.fifth: 5,
  EigthKe.sixth: 6,
  EigthKe.seventh: 7,
  EigthKe.eighth: 8,
};

GuaCalculationResult _$GuaCalculationResultFromJson(
  Map<String, dynamic> json,
) => GuaCalculationResult(
  shangGuaNumber: (json['shangGuaNumber'] as num).toInt(),
  xiaGuaNumber: (json['xiaGuaNumber'] as num).toInt(),
  shangGuaName: json['shangGuaName'] as String,
  xiaGuaName: json['xiaGuaName'] as String,
  fullGuaName: json['fullGuaName'] as String,
  calculationDetail: json['calculationDetail'] as String,
);

Map<String, dynamic> _$GuaCalculationResultToJson(
  GuaCalculationResult instance,
) => <String, dynamic>{
  'shangGuaNumber': instance.shangGuaNumber,
  'xiaGuaNumber': instance.xiaGuaNumber,
  'shangGuaName': instance.shangGuaName,
  'xiaGuaName': instance.xiaGuaName,
  'fullGuaName': instance.fullGuaName,
  'calculationDetail': instance.calculationDetail,
};

KaoKeSessionSnapshot _$KaoKeSessionSnapshotFromJson(
  Map<String, dynamic> json,
) => KaoKeSessionSnapshot(
  snapshotId: json['snapshotId'] as String,
  phase: $enumDecode(_$KaoKeSessionPhaseEnumMap, json['phase']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  state: json['state'] as Map<String, dynamic>,
);

Map<String, dynamic> _$KaoKeSessionSnapshotToJson(
  KaoKeSessionSnapshot instance,
) => <String, dynamic>{
  'snapshotId': instance.snapshotId,
  'phase': _$KaoKeSessionPhaseEnumMap[instance.phase]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'state': instance.state,
};

const _$KaoKeSessionPhaseEnumMap = {
  KaoKeSessionPhase.initialized: 'initialized',
  KaoKeSessionPhase.keSelectionReady: 'keSelectionReady',
  KaoKeSessionPhase.keSelected: 'keSelected',
  KaoKeSessionPhase.baseNumberCalculated: 'baseNumberCalculated',
  KaoKeSessionPhase.finalCalculationComplete: 'finalCalculationComplete',
};

KaoKeSession _$KaoKeSessionFromJson(Map<String, dynamic> json) => KaoKeSession(
  sessionId: json['sessionId'] as String,
  sessionName: json['sessionName'] as String,
  eightChars: EightChars.fromJson(json['eightChars'] as Map<String, dynamic>),
  keSelection: KaoKeSession._keSelectionFromJson(
    json['keSelection'] as Map<String, dynamic>?,
  ),
  guaResult: KaoKeSession._guaResultFromJson(
    json['guaResult'] as Map<String, dynamic>?,
  ),
  selectedMethods: json['selectedMethods'] == null
      ? const {
          KaoKeCalculationMethod.baGuaJiaZe,
          KaoKeCalculationMethod.liuYaoGanZhiHe,
        }
      : KaoKeSession._selectedMethodsFromJson(json['selectedMethods'] as List),
  finalResults: KaoKeSession._finalResultsFromJson(
    json['finalResults'] as Map<String, dynamic>?,
  ),
  currentPhase:
      $enumDecodeNullable(_$KaoKeSessionPhaseEnumMap, json['currentPhase']) ??
      KaoKeSessionPhase.initialized,
  phaseHistory: json['phaseHistory'] == null
      ? const []
      : KaoKeSession._snapshotsFromJson(json['phaseHistory'] as List),
  status:
      $enumDecodeNullable(_$KaoKeSessionStatusEnumMap, json['status']) ??
      KaoKeSessionStatus.notStarted,
  startTime: DateTime.parse(json['startTime'] as String),
  lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$KaoKeSessionToJson(KaoKeSession instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'sessionName': instance.sessionName,
      'eightChars': instance.eightChars,
      'keSelection': KaoKeSession._keSelectionToJson(instance.keSelection),
      'guaResult': KaoKeSession._guaResultToJson(instance.guaResult),
      'selectedMethods': KaoKeSession._selectedMethodsToJson(
        instance.selectedMethods,
      ),
      'finalResults': KaoKeSession._finalResultsToJson(instance.finalResults),
      'currentPhase': _$KaoKeSessionPhaseEnumMap[instance.currentPhase]!,
      'phaseHistory': KaoKeSession._snapshotsToJson(instance.phaseHistory),
      'status': _$KaoKeSessionStatusEnumMap[instance.status]!,
      'startTime': instance.startTime.toIso8601String(),
      'lastActivityAt': instance.lastActivityAt.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };

const _$KaoKeSessionStatusEnumMap = {
  KaoKeSessionStatus.notStarted: 'notStarted',
  KaoKeSessionStatus.inProgress: 'inProgress',
  KaoKeSessionStatus.waitingForSelection: 'waitingForSelection',
  KaoKeSessionStatus.completed: 'completed',
  KaoKeSessionStatus.cancelled: 'cancelled',
  KaoKeSessionStatus.error: 'error',
};
