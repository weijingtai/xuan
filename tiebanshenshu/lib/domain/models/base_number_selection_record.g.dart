// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_number_selection_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandidateGenerationConfig _$CandidateGenerationConfigFromJson(
  Map<String, dynamic> json,
) => CandidateGenerationConfig(
  initialNumber: (json['initialNumber'] as num).toInt(),
  offset: (json['offset'] as num?)?.toInt() ?? 30,
  count: (json['count'] as num?)?.toInt() ?? 10,
  minValue: (json['minValue'] as num?)?.toInt() ?? 1000,
  maxValue: (json['maxValue'] as num?)?.toInt() ?? 13000,
);

Map<String, dynamic> _$CandidateGenerationConfigToJson(
  CandidateGenerationConfig instance,
) => <String, dynamic>{
  'initialNumber': instance.initialNumber,
  'offset': instance.offset,
  'count': instance.count,
  'minValue': instance.minValue,
  'maxValue': instance.maxValue,
};

BaseNumberCandidate _$BaseNumberCandidateFromJson(Map<String, dynamic> json) =>
    BaseNumberCandidate(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      offsetFromInitial: (json['offsetFromInitial'] as num).toInt(),
      tiaoWenContent: json['tiaoWenContent'] as String? ?? '',
      isInitial: json['isInitial'] as bool? ?? false,
    );

Map<String, dynamic> _$BaseNumberCandidateToJson(
  BaseNumberCandidate instance,
) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'offsetFromInitial': instance.offsetFromInitial,
  'tiaoWenContent': instance.tiaoWenContent,
  'isInitial': instance.isInitial,
};

DerivationStep _$DerivationStepFromJson(Map<String, dynamic> json) =>
    DerivationStep(
      operation: json['operation'] as String,
      value: (json['value'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$DerivationStepToJson(DerivationStep instance) =>
    <String, dynamic>{
      'operation': instance.operation,
      'value': instance.value,
      'description': instance.description,
    };

BaseNumberDerivationChain _$BaseNumberDerivationChainFromJson(
  Map<String, dynamic> json,
) => BaseNumberDerivationChain(
  source: BaseNumberDerivationChain._sourceFromJson(
    json['source'] as Map<String, dynamic>,
  ),
  derivationSteps: BaseNumberDerivationChain._derivationStepsFromJson(
    json['derivationSteps'] as List,
  ),
  finalDefinition: DataBaseNumberDefinitionConverter.fromJsonConvertor(
    json['finalDefinition'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$BaseNumberDerivationChainToJson(
  BaseNumberDerivationChain instance,
) => <String, dynamic>{
  'source': BaseNumberDerivationChain._sourceToJson(instance.source),
  'derivationSteps': BaseNumberDerivationChain._derivationStepsToJson(
    instance.derivationSteps,
  ),
  'finalDefinition': DataBaseNumberDefinitionConverter.toJsonConvertor(
    instance.finalDefinition,
  ),
};

BaseNumberSelectionRecord _$BaseNumberSelectionRecordFromJson(
  Map<String, dynamic> json,
) => BaseNumberSelectionRecord(
  baseNumberDefinitionId: json['baseNumberDefinitionId'] as String,
  name: json['name'] as String,
  derivationChain: BaseNumberSelectionRecord._derivationChainFromJson(
    json['derivationChain'] as Map<String, dynamic>,
  ),
  candidateConfig: BaseNumberSelectionRecord._candidateConfigFromJson(
    json['candidateConfig'] as Map<String, dynamic>,
  ),
  candidates: BaseNumberSelectionRecord._candidatesFromJson(
    json['candidates'] as List,
  ),
  selectedCandidate: BaseNumberSelectionRecord._selectedCandidateFromJson(
    json['selectedCandidate'] as Map<String, dynamic>?,
  ),
  status:
      $enumDecodeNullable(_$SelectionStatusEnumMap, json['status']) ??
      SelectionStatus.pending,
  relatedGroupIds: (json['relatedGroupIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$BaseNumberSelectionRecordToJson(
  BaseNumberSelectionRecord instance,
) => <String, dynamic>{
  'baseNumberDefinitionId': instance.baseNumberDefinitionId,
  'name': instance.name,
  'derivationChain': BaseNumberSelectionRecord._derivationChainToJson(
    instance.derivationChain,
  ),
  'candidateConfig': BaseNumberSelectionRecord._candidateConfigToJson(
    instance.candidateConfig,
  ),
  'candidates': BaseNumberSelectionRecord._candidatesToJson(
    instance.candidates,
  ),
  'selectedCandidate': BaseNumberSelectionRecord._selectedCandidateToJson(
    instance.selectedCandidate,
  ),
  'status': _$SelectionStatusEnumMap[instance.status]!,
  'relatedGroupIds': instance.relatedGroupIds,
};

const _$SelectionStatusEnumMap = {
  SelectionStatus.pending: 'pending',
  SelectionStatus.inProgress: 'inProgress',
  SelectionStatus.completed: 'completed',
  SelectionStatus.cancelled: 'cancelled',
};
