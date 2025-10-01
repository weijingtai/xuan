// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_base_number_selection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseNumberSelection _$BaseNumberSelectionFromJson(Map<String, dynamic> json) =>
    BaseNumberSelection(
      type: $enumDecode(_$BaseNumberSelectionTypeEnumMap, json['type']),
      selectedNumber: json['selectedNumber'] == null
          ? null
          : HuangJiBaseNumber.fromJson(
              json['selectedNumber'] as Map<String, dynamic>,
            ),
      candidates: (json['candidates'] as List<dynamic>)
          .map((e) => TiaoWenCandidate.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecode(_$BaseNumberSelectionStatusEnumMap, json['status']),
      isRequired: json['isRequired'] as bool,
      order: (json['order'] as num).toInt(),
      dependsOn: $enumDecodeNullable(
        _$BaseNumberSelectionTypeEnumMap,
        json['dependsOn'],
      ),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$BaseNumberSelectionToJson(
  BaseNumberSelection instance,
) => <String, dynamic>{
  'type': _$BaseNumberSelectionTypeEnumMap[instance.type]!,
  'selectedNumber': instance.selectedNumber,
  'candidates': instance.candidates,
  'status': _$BaseNumberSelectionStatusEnumMap[instance.status]!,
  'isRequired': instance.isRequired,
  'order': instance.order,
  'dependsOn': _$BaseNumberSelectionTypeEnumMap[instance.dependsOn],
  'errorMessage': instance.errorMessage,
};

const _$BaseNumberSelectionTypeEnumMap = {
  BaseNumberSelectionType.yuanHui: 'yuan_hui',
  BaseNumberSelectionType.yunShi: 'yun_shi',
  BaseNumberSelectionType.yuanHuiOne: 'yuan_hui_one',
  BaseNumberSelectionType.yunShiOne: 'yun_shi_one',
  BaseNumberSelectionType.yuanHuiTwo: 'yuan_hui_two',
  BaseNumberSelectionType.yunShiTwo: 'yun_shi_two',
};

const _$BaseNumberSelectionStatusEnumMap = {
  BaseNumberSelectionStatus.pending: 'pending',
  BaseNumberSelectionStatus.waitingForDependency: 'waiting_for_dependency',
  BaseNumberSelectionStatus.ready: 'ready',
  BaseNumberSelectionStatus.loading: 'loading',
  BaseNumberSelectionStatus.completed: 'completed',
  BaseNumberSelectionStatus.error: 'error',
};

MultiBaseNumberSelectionManager _$MultiBaseNumberSelectionManagerFromJson(
  Map<String, dynamic> json,
) => MultiBaseNumberSelectionManager(
  selections: (json['selections'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      $enumDecode(_$BaseNumberSelectionTypeEnumMap, k),
      BaseNumberSelection.fromJson(e as Map<String, dynamic>),
    ),
  ),
  currentActiveType: $enumDecodeNullable(
    _$BaseNumberSelectionTypeEnumMap,
    json['currentActiveType'],
  ),
  overallStatus: $enumDecode(
    _$MultiSelectionStatusEnumMap,
    json['overallStatus'],
  ),
  currentPhase: $enumDecode(_$SelectionPhaseEnumMap, json['currentPhase']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
);

Map<String, dynamic> _$MultiBaseNumberSelectionManagerToJson(
  MultiBaseNumberSelectionManager instance,
) => <String, dynamic>{
  'selections': instance.selections.map(
    (k, e) => MapEntry(_$BaseNumberSelectionTypeEnumMap[k]!, e),
  ),
  'currentActiveType':
      _$BaseNumberSelectionTypeEnumMap[instance.currentActiveType],
  'overallStatus': _$MultiSelectionStatusEnumMap[instance.overallStatus]!,
  'currentPhase': _$SelectionPhaseEnumMap[instance.currentPhase]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastUpdatedAt': instance.lastUpdatedAt.toIso8601String(),
};

const _$MultiSelectionStatusEnumMap = {
  MultiSelectionStatus.inProgress: 'in_progress',
  MultiSelectionStatus.completed: 'completed',
  MultiSelectionStatus.cancelled: 'cancelled',
  MultiSelectionStatus.error: 'error',
};

const _$SelectionPhaseEnumMap = {
  SelectionPhase.primaryNumbers: 'primary_numbers',
  SelectionPhase.derivedNumbers: 'derived_numbers',
  SelectionPhase.completed: 'completed',
};
