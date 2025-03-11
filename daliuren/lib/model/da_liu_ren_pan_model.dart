import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/da_liu_ren_panel.dart';
import 'package:daliuren/model/three_chuan.dart';
import 'package:json_annotation/json_annotation.dart';

import 'four_class.dart';
part 'da_liu_ren_pan_model.g.dart';

@JsonSerializable()
class DaLiuRenPanModel extends DaLiuRenPanel {
  late JiaZi dayJiaZi;
  late DiZhi shiChen;
  late String juNumberName;
  late FourClass fourClass;
  late ThreeChuan threeChuan;
  late Map<DiZhi, DaLiuRenGong> gongMapper;
  DaLiuRenPanModel(
      {required this.dayJiaZi,
      required this.shiChen,
      required this.juNumberName,
      required this.fourClass,
      required this.threeChuan,
      required this.gongMapper});

  factory DaLiuRenPanModel.fromJson(Map<String, dynamic> json) =>
      _$DaLiuRenPanModelFromJson(json);
  Map<String, dynamic> toJson() => _$DaLiuRenPanModelToJson(this);

  @override
  JiaZi getDayJiaZi() {
    return dayJiaZi;
  }

  @override
  FourClass getFourClass() {
    return fourClass;
  }

  @override
  Map<DiZhi, DaLiuRenGong> getGongMapper() {
    return gongMapper;
  }

  @override
  ThreeChuan getThreeChuan() {
    return threeChuan;
  }
}
