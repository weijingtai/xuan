// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'huang_ji_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectionCandidate _$SelectionCandidateFromJson(Map<String, dynamic> json) =>
    SelectionCandidate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      selectableBaseNumber: DataSelectableBaseNumber.fromJson(
        json['selectableBaseNumber'] as Map<String, dynamic>,
      ),
      tiaoWenContent: json['tiaoWenContent'] as String?,
      baseNumberType: $enumDecodeNullable(
        _$BaseNumberDefinitionTypeEnumMap,
        json['baseNumberType'],
      ),
      numberSource: $enumDecodeNullable(
        _$NumberSourceEnumMap,
        json['numberSource'],
      ),
      offset: (json['offset'] as num?)?.toInt(),
      isDefault: json['isDefault'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SelectionCandidateToJson(
  SelectionCandidate instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'selectableBaseNumber': instance.selectableBaseNumber,
  'tiaoWenContent': instance.tiaoWenContent,
  'baseNumberType': _$BaseNumberDefinitionTypeEnumMap[instance.baseNumberType],
  'numberSource': _$NumberSourceEnumMap[instance.numberSource],
  'offset': instance.offset,
  'isDefault': instance.isDefault,
  'metadata': instance.metadata,
};

const _$BaseNumberDefinitionTypeEnumMap = {
  BaseNumberDefinitionType.predefined: 'predefined',
  BaseNumberDefinitionType.derived: 'derived',
  BaseNumberDefinitionType.selectable: 'selectable',
};

const _$NumberSourceEnumMap = {
  NumberSource.yuanHui: '元会',
  NumberSource.yunShi: '运世',
};

UserSelectionRecord _$UserSelectionRecordFromJson(Map<String, dynamic> json) =>
    UserSelectionRecord(
      selectionId: json['selectionId'] as String,
      selectionType: $enumDecode(_$SelectionTypeEnumMap, json['selectionType']),
      groupId: json['groupId'] as String,
      stepName: json['stepName'] as String,
      formulaName: json['formulaName'] as String,
      baseNumberDefinitionName: json['baseNumberDefinitionName'] as String?,
      tiaoWenFormulaName: json['tiaoWenFormulaName'] as String?,
      candidates: (json['candidates'] as List<dynamic>)
          .map((e) => SelectionCandidate.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedCandidate: json['selectedCandidate'] == null
          ? null
          : SelectionCandidate.fromJson(
              json['selectedCandidate'] as Map<String, dynamic>,
            ),
      selectionTime: DateTime.parse(json['selectionTime'] as String),
      selectionReason: json['selectionReason'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$UserSelectionRecordToJson(
  UserSelectionRecord instance,
) => <String, dynamic>{
  'selectionId': instance.selectionId,
  'selectionType': _$SelectionTypeEnumMap[instance.selectionType]!,
  'groupId': instance.groupId,
  'stepName': instance.stepName,
  'formulaName': instance.formulaName,
  'baseNumberDefinitionName': instance.baseNumberDefinitionName,
  'tiaoWenFormulaName': instance.tiaoWenFormulaName,
  'candidates': instance.candidates,
  'selectedCandidate': instance.selectedCandidate,
  'selectionTime': instance.selectionTime.toIso8601String(),
  'selectionReason': instance.selectionReason,
  'isCompleted': instance.isCompleted,
};

const _$SelectionTypeEnumMap = {
  SelectionType.predefinedBaseNumber: 'predefinedBaseNumber',
  SelectionType.derivedBaseNumber: 'derivedBaseNumber',
  SelectionType.selectableBaseNumber: 'selectableBaseNumber',
  SelectionType.tiaoWenContent: 'tiaoWenContent',
  SelectionType.custom: 'custom',
};

HuangJiCalculationStep _$HuangJiCalculationStepFromJson(
  Map<String, dynamic> json,
) => HuangJiCalculationStep(
  stepId: json['stepId'] as String,
  stepType: $enumDecode(_$HuangJiStepTypeEnumMap, json['stepType']),
  stepName: json['stepName'] as String,
  description: json['description'] as String,
  stepNumber: (json['stepNumber'] as num).toInt(),
  inputData: json['inputData'] as Map<String, dynamic>,
  outputData: json['outputData'] as Map<String, dynamic>,
  result: (json['result'] as num?)?.toInt(),
  rawResult: (json['rawResult'] as num?)?.toInt(),
  formula: json['formula'] as String?,
  groupId: json['groupId'] as String,
  baseNumberDefinitionName: json['baseNumberDefinitionName'] as String?,
  tiaoWenFormulaName: json['tiaoWenFormulaName'] as String?,
  dataGroup: json['dataGroup'] == null
      ? null
      : DataCalculationGroup.fromJson(
          json['dataGroup'] as Map<String, dynamic>,
        ),
  tiaoWenData: json['tiaoWenData'] == null
      ? null
      : TiaoWenFormulaData.fromJson(
          json['tiaoWenData'] as Map<String, dynamic>,
        ),
  candidates: (json['candidates'] as List<dynamic>?)
      ?.map((e) => TiaoWenCandidate.fromJson(e as Map<String, dynamic>))
      .toList(),
  selectedCandidateId: json['selectedCandidateId'] as String?,
  selectionRecord: json['selectionRecord'] == null
      ? null
      : UserSelectionRecord.fromJson(
          json['selectionRecord'] as Map<String, dynamic>,
        ),
  status:
      $enumDecodeNullable(_$HuangJiStepStatusEnumMap, json['status']) ??
      HuangJiStepStatus.notStarted,
  startTime: DateTime.parse(json['startTime'] as String),
  completedTime: json['completedTime'] == null
      ? null
      : DateTime.parse(json['completedTime'] as String),
  errorMessage: json['errorMessage'] as String?,
  requiresUserSelection: json['requiresUserSelection'] as bool? ?? false,
  selectionType: $enumDecodeNullable(
    _$SelectionTypeEnumMap,
    json['selectionType'],
  ),
);

Map<String, dynamic> _$HuangJiCalculationStepToJson(
  HuangJiCalculationStep instance,
) => <String, dynamic>{
  'stepId': instance.stepId,
  'stepType': _$HuangJiStepTypeEnumMap[instance.stepType]!,
  'stepName': instance.stepName,
  'description': instance.description,
  'stepNumber': instance.stepNumber,
  'inputData': instance.inputData,
  'outputData': instance.outputData,
  'result': instance.result,
  'rawResult': instance.rawResult,
  'formula': instance.formula,
  'groupId': instance.groupId,
  'baseNumberDefinitionName': instance.baseNumberDefinitionName,
  'tiaoWenFormulaName': instance.tiaoWenFormulaName,
  'dataGroup': instance.dataGroup,
  'tiaoWenData': instance.tiaoWenData,
  'candidates': instance.candidates,
  'selectedCandidateId': instance.selectedCandidateId,
  'selectionRecord': instance.selectionRecord,
  'status': _$HuangJiStepStatusEnumMap[instance.status]!,
  'startTime': instance.startTime.toIso8601String(),
  'completedTime': instance.completedTime?.toIso8601String(),
  'errorMessage': instance.errorMessage,
  'requiresUserSelection': instance.requiresUserSelection,
  'selectionType': _$SelectionTypeEnumMap[instance.selectionType],
};

const _$HuangJiStepTypeEnumMap = {
  HuangJiStepType.initializeFourZhu: 'initializeFourZhu',
  HuangJiStepType.calculateYuanHuiYunShi: 'calculateYuanHuiYunShi',
  HuangJiStepType.calculateInitialNumber: 'calculateInitialNumber',
  HuangJiStepType.calculateSecondaryNumber: 'calculateSecondaryNumber',
  HuangJiStepType.selectBaseNumber: 'selectBaseNumber',
  HuangJiStepType.calculateFinalNumbers: 'calculateFinalNumbers',
  HuangJiStepType.getTiaoWenContent: 'getTiaoWenContent',
  HuangJiStepType.userSelection: 'userSelection',
  HuangJiStepType.completed: 'completed',
};

const _$HuangJiStepStatusEnumMap = {
  HuangJiStepStatus.notStarted: 'notStarted',
  HuangJiStepStatus.inProgress: 'inProgress',
  HuangJiStepStatus.waitingForSelection: 'waitingForSelection',
  HuangJiStepStatus.completed: 'completed',
  HuangJiStepStatus.error: 'error',
};

FormulaInstance _$FormulaInstanceFromJson(Map<String, dynamic> json) =>
    FormulaInstance(
      instanceId: json['instanceId'] as String,
      formulaName: json['formulaName'] as String,
      formulaTemplate: HuangJiCalculationFormula.fromJson(
        json['formulaTemplate'] as Map<String, dynamic>,
      ),
      dataFormula: HuangJiDataCalculationFormula.fromJson(
        json['dataFormula'] as Map<String, dynamic>,
      ),
      calculationSteps: (json['calculationSteps'] as List<dynamic>)
          .map(
            (e) => HuangJiCalculationStep.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      selectionHistory: (json['selectionHistory'] as List<dynamic>)
          .map((e) => UserSelectionRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentStepIndex: (json['currentStepIndex'] as num).toInt(),
      status: $enumDecode(_$HuangJiSessionStatusEnumMap, json['status']),
      resultData: json['resultData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FormulaInstanceToJson(FormulaInstance instance) =>
    <String, dynamic>{
      'instanceId': instance.instanceId,
      'formulaName': instance.formulaName,
      'formulaTemplate': instance.formulaTemplate,
      'dataFormula': instance.dataFormula,
      'calculationSteps': instance.calculationSteps,
      'selectionHistory': instance.selectionHistory,
      'currentStepIndex': instance.currentStepIndex,
      'status': _$HuangJiSessionStatusEnumMap[instance.status]!,
      'resultData': instance.resultData,
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

HuangJiSession _$HuangJiSessionFromJson(Map<String, dynamic> json) =>
    HuangJiSession(
      sessionId: json['sessionId'] as String,
      sessionName: json['sessionName'] as String,
      eightChars: EightChars.fromJson(
        json['eightChars'] as Map<String, dynamic>,
      ),
      yuanHuiYunShi: YuanHuiYunShi.fromJson(
        json['yuanHuiYunShi'] as Map<String, dynamic>,
      ),
      formulaInstances: (json['formulaInstances'] as List<dynamic>)
          .map((e) => FormulaInstance.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentFormulaIndex: (json['currentFormulaIndex'] as num).toInt(),
      multiSelectionManager: json['multiSelectionManager'] == null
          ? null
          : MultiBaseNumberSelectionManager.fromJson(
              json['multiSelectionManager'] as Map<String, dynamic>,
            ),
      startTime: DateTime.parse(json['startTime'] as String),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      status: $enumDecode(_$HuangJiSessionStatusEnumMap, json['status']),
      resultData: json['resultData'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$HuangJiSessionToJson(HuangJiSession instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'sessionName': instance.sessionName,
      'eightChars': instance.eightChars,
      'yuanHuiYunShi': instance.yuanHuiYunShi,
      'formulaInstances': instance.formulaInstances,
      'currentFormulaIndex': instance.currentFormulaIndex,
      'multiSelectionManager': instance.multiSelectionManager,
      'startTime': instance.startTime.toIso8601String(),
      'lastActivityAt': instance.lastActivityAt.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'status': _$HuangJiSessionStatusEnumMap[instance.status]!,
      'resultData': instance.resultData,
      'metadata': instance.metadata,
    };
