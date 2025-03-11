import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'qi_yi_ru_gong.g.dart';

@JsonSerializable()
class QiYiRuGong {
  // 三奇六仪 入宫

  HouTianGua gong;
  TianGan qiYi;
  String geJuName;
  String description;
  JiXiongEnum geJuJiXiong;
  QiYiRuGong({
    required this.gong,
    required this.qiYi,
    required this.geJuName,
    required this.description,
    required this.geJuJiXiong,
  });

  factory QiYiRuGong.fromJson(Map<String, dynamic> json) =>
      _$QiYiRuGongFromJson(json);
  Map<String, dynamic> toJson() => _$QiYiRuGongToJson(this);
}
