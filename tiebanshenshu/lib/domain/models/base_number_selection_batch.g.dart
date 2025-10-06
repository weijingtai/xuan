// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_number_selection_batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseNumberSelectionItem _$BaseNumberSelectionItemFromJson(
  Map<String, dynamic> json,
) => BaseNumberSelectionItem(
  definitionId: json['definitionId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  derivationChain: BaseNumberSelectionItem._derivationChainFromJson(
    json['derivationChain'] as Map<String, dynamic>,
  ),
  candidates: BaseNumberSelectionItem._candidatesFromJson(
    json['candidates'] as List,
  ),
  relatedGroupIds: (json['relatedGroupIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$BaseNumberSelectionItemToJson(
  BaseNumberSelectionItem instance,
) => <String, dynamic>{
  'definitionId': instance.definitionId,
  'name': instance.name,
  'description': instance.description,
  'derivationChain': BaseNumberSelectionItem._derivationChainToJson(
    instance.derivationChain,
  ),
  'candidates': BaseNumberSelectionItem._candidatesToJson(instance.candidates),
  'relatedGroupIds': instance.relatedGroupIds,
};

BaseNumberSelectionBatch _$BaseNumberSelectionBatchFromJson(
  Map<String, dynamic> json,
) => BaseNumberSelectionBatch(
  items: BaseNumberSelectionBatch._itemsFromJson(json['items'] as List),
  definitionToGroupsMap: (json['definitionToGroupsMap'] as Map<String, dynamic>)
      .map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
);

Map<String, dynamic> _$BaseNumberSelectionBatchToJson(
  BaseNumberSelectionBatch instance,
) => <String, dynamic>{
  'items': BaseNumberSelectionBatch._itemsToJson(instance.items),
  'definitionToGroupsMap': instance.definitionToGroupsMap,
};
