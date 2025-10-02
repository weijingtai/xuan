import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

import 'enum_gui_ren.dart';

part 'da_liu_ren_gong.g.dart';

@JsonSerializable()
class DaLiuRenGong {
  // String diZhi;
  DiZhi groundPanDiZhi;
  GuiRen guiRen;
  // String? tianGan;
  // String jiaZi;
  DiZhi skyPanDiZhi;
  TianGan? tianGan;
  JiaZi? jiaZi;

  DaLiuRenGong({
    required this.skyPanDiZhi,
    required this.groundPanDiZhi,
    required this.guiRen,
    this.jiaZi,
    this.tianGan,
  });
  factory DaLiuRenGong.fromJson(Map<String, dynamic> json) =>
      _$DaLiuRenGongFromJson(json);
  Map<String, dynamic> toJson() => _$DaLiuRenGongToJson(this);
}
