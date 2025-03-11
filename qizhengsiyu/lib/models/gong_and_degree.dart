import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

part 'gong_and_degree.g.dart';

@JsonSerializable()
class GongAndDegree {
  final EnumTwelveGong gong;
  final double degree;
  const GongAndDegree(this.gong, this.degree);

  factory GongAndDegree.fromJson(Map<String, dynamic> json) =>
      _$GongAndDegreeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GongAndDegreeToJson(this);
}
