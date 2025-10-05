import 'package:json_annotation/json_annotation.dart';

import 'package:common/enums.dart';

part 'jie_qi_info.g.dart';

@JsonSerializable()
class JieQiInfo {
  TwentyFourJieQi get prevJieQi => jieQi.previous;
  TwentyFourJieQi get nextJieQi => jieQi.next;
  TwentyFourJieQi jieQi;
  DateTime startAt;
  DateTime endAt;
  JieQiInfo({
    required this.jieQi,
    required this.startAt,
    required this.endAt,
  });

  factory JieQiInfo.fromJson(Map<String, dynamic> json) =>
      _$JieQiInfoFromJson(json);

  Map<String, dynamic> toJson() => _$JieQiInfoToJson(this);
}
