import 'package:common/models/pillar_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'pillar_group.g.dart';

@JsonSerializable(explicitToJson: true)
class PillarGroup {
  final String id;
  final String title;
  final List<PillarData> pillars;
  final bool isBenMing;
  final List<String> rowOrder;
  final List<String> pillarOrder;

  PillarGroup({
    String? id,
    required this.title,
    required this.pillars,
    this.isBenMing = false,
    List<String>? rowOrder,
    List<String>? pillarOrder,
  }) : id = id ?? const Uuid().v4(),
       rowOrder = rowOrder ?? ['pillarHeader', 'tianGan', 'diZhi'],
       pillarOrder = pillarOrder ?? pillars.map((p) => p.label).toList();

  factory PillarGroup.fromJson(Map<String, dynamic> json) => _$PillarGroupFromJson(json);

  Map<String, dynamic> toJson() => _$PillarGroupToJson(this);

  PillarGroup copyWith({
    String? id,
    String? title,
    List<PillarData>? pillars,
    bool? isBenMing,
    List<String>? rowOrder,
    List<String>? pillarOrder,
  }) {
    return PillarGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      pillars: pillars ?? this.pillars,
      isBenMing: isBenMing ?? this.isBenMing,
      rowOrder: rowOrder ?? this.rowOrder,
      pillarOrder: pillarOrder ?? this.pillarOrder,
    );
  }
}
