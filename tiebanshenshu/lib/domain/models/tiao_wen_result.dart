import 'package:json_annotation/json_annotation.dart';

part 'tiao_wen_result.g.dart';

/// 条文计算结果
@JsonSerializable()
class TiaoWenResult {
  /// 所属计算组 ID
  final String groupId;

  /// 公式名称
  final String formulaName;

  /// 使用的基础数
  final int baseNumber;

  /// 计算得到的条文数
  final int tiaoWenNumber;

  /// 条文内容
  final String tiaoWenContent;

  /// 计算详情 (用于展示计算过程)
  final String calculationDetail;

  const TiaoWenResult({
    required this.groupId,
    required this.formulaName,
    required this.baseNumber,
    required this.tiaoWenNumber,
    required this.tiaoWenContent,
    required this.calculationDetail,
  });

  factory TiaoWenResult.fromJson(Map<String, dynamic> json) =>
      _$TiaoWenResultFromJson(json);

  Map<String, dynamic> toJson() => _$TiaoWenResultToJson(this);

  @override
  String toString() {
    return 'TiaoWenResult(groupId: $groupId, formula: $formulaName, baseNumber: $baseNumber, tiaoWenNumber: $tiaoWenNumber)';
  }
}
