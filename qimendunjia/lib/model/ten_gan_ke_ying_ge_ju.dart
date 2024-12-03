import 'package:common/model/enum_ji_xiong.dart';
import 'package:common/model/enum_tian_gan.dart';
import 'package:json_annotation/json_annotation.dart';
part 'ten_gan_ke_ying_ge_ju.g.dart';
@JsonSerializable()
class TenGanKeYingGeJu {

  TianGan tianPan;
  TianGan diPan;
  JiXiongEnum jiXiong;
  List<String> geJuNames;
  List<String> explains;


  TenGanKeYingGeJu({required this.tianPan,required this.diPan,required this.jiXiong,required this.geJuNames,required this.explains});

  factory TenGanKeYingGeJu.fromJson(Map<String, dynamic> json) => _$TenGanKeYingGeJuFromJson(json);
  Map<String, dynamic> toJson() => _$TenGanKeYingGeJuToJson(this);

}