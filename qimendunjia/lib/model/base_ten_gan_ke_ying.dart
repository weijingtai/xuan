import 'package:json_annotation/json_annotation.dart';

part 'base_ten_gan_ke_ying.g.dart';
@JsonSerializable()
class BaseTenGanKeYing{
  String juName;
  String shortExplain;

  BaseTenGanKeYing({
    required this.juName,
    required this.shortExplain,
  });

  factory BaseTenGanKeYing.fromJson(Map<String, dynamic> json) => _$BaseTenGanKeYingFromJson(json);
  Map<String, dynamic> toJson() => _$BaseTenGanKeYingToJson(this);
}