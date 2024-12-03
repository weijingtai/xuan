import 'package:json_annotation/json_annotation.dart';

part 'ten_gan_ke_ying_zhu.g.dart';

@JsonSerializable()
class TenGanKeYingZhu {
  String? author;
  String content;

  TenGanKeYingZhu({
    this.author,
    required this.content,
  });

  factory TenGanKeYingZhu.fromJson(Map<String, dynamic> json) => _$TenGanKeYingZhuFromJson(json);
  Map<String, dynamic> toJson() => _$TenGanKeYingZhuToJson(this);
}