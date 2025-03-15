import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/models/observer_position.dart';

part 'divination_model.g.dart';

@JsonSerializable()
class QiZhengSiYuDivination extends BasicDivination {
  // 求测人所在位置，可选
  Location? divinationPersonLocation;
  // 占卜师卜问时的位置
  final Location divinationLocation;
  QiZhengSiYuDivination({
    required this.divinationLocation,
    required String question,
    required DateTime divinationAt,
    String? details,
    DivinationPerson? divinationPerson,
    this.divinationPersonLocation,
  }) : super(
          question: question,
          divinationAt: divinationAt,
          details: details,
          divinationPerson: divinationPerson,
        );

  factory QiZhengSiYuDivination.fromJson(Map<String, dynamic> json) =>
      _$QiZhengSiYuDivinationFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$QiZhengSiYuDivinationToJson(this);
}
