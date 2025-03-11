import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

part 'star_enter_info.g.dart';

@JsonSerializable()
class EnteredInfo {
  EnumTwelveGong gong;
  double atGongDegree;
  TwentyEightStarInn inn;
  double atInnDegree;

  EnteredInfo({
    required this.gong,
    required this.atGongDegree,
    required this.inn,
    required this.atInnDegree,
  });

  factory EnteredInfo.fromJson(Map<String, dynamic> json) =>
      _$EnteredInfoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$EnteredInfoToJson(this);
}
