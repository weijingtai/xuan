import 'package:json_annotation/json_annotation.dart';
import 'base_number_selection_record.dart';

part 'base_number_selection_batch.g.dart';

/// 基础数选择项 (供 UI 展示)
@JsonSerializable()
class BaseNumberSelectionItem {
  /// 定义 ID (基于 name)
  final String definitionId;

  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 派生链路
  @JsonKey(
    fromJson: _derivationChainFromJson,
    toJson: _derivationChainToJson,
  )
  final BaseNumberDerivationChain derivationChain;

  /// 候选列表
  @JsonKey(fromJson: _candidatesFromJson, toJson: _candidatesToJson)
  final List<BaseNumberCandidate> candidates;

  /// 关联的 groupIds
  final List<String> relatedGroupIds;

  const BaseNumberSelectionItem({
    required this.definitionId,
    required this.name,
    required this.description,
    required this.derivationChain,
    required this.candidates,
    required this.relatedGroupIds,
  });

  factory BaseNumberSelectionItem.fromJson(Map<String, dynamic> json) =>
      _$BaseNumberSelectionItemFromJson(json);

  Map<String, dynamic> toJson() => _$BaseNumberSelectionItemToJson(this);

  // 辅助序列化方法
  static BaseNumberDerivationChain _derivationChainFromJson(
    Map<String, dynamic> json,
  ) {
    return BaseNumberDerivationChain.fromJson(json);
  }

  static Map<String, dynamic> _derivationChainToJson(
    BaseNumberDerivationChain chain,
  ) {
    return chain.toJson();
  }

  static List<BaseNumberCandidate> _candidatesFromJson(List<dynamic> json) {
    return json
        .map((e) => BaseNumberCandidate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _candidatesToJson(
    List<BaseNumberCandidate> candidates,
  ) {
    return candidates.map((e) => e.toJson()).toList();
  }
}

/// 基础数选择批次 (一次性展示给用户的所有选择项)
@JsonSerializable()
class BaseNumberSelectionBatch {
  /// 需要用户选择的基础数列表 (已去重)
  @JsonKey(fromJson: _itemsFromJson, toJson: _itemsToJson)
  final List<BaseNumberSelectionItem> items;

  /// 定义 ID 到 groupIds 的映射
  final Map<String, List<String>> definitionToGroupsMap;

  const BaseNumberSelectionBatch({
    required this.items,
    required this.definitionToGroupsMap,
  });

  factory BaseNumberSelectionBatch.fromJson(Map<String, dynamic> json) =>
      _$BaseNumberSelectionBatchFromJson(json);

  Map<String, dynamic> toJson() => _$BaseNumberSelectionBatchToJson(this);

  // 辅助序列化方法
  static List<BaseNumberSelectionItem> _itemsFromJson(List<dynamic> json) {
    return json
        .map((e) => BaseNumberSelectionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _itemsToJson(
    List<BaseNumberSelectionItem> items,
  ) {
    return items.map((e) => e.toJson()).toList();
  }
}
