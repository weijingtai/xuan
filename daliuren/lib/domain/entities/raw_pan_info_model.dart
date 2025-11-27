import 'package:common/enums.dart';
import 'package:daliuren/domain/enums/gui_ren.dart';
import 'package:daliuren/domain/services/calculate_month_general_service.dart';
import 'package:json_annotation/json_annotation.dart';
part 'raw_pan_info_model.g.dart';

@JsonSerializable()
class RawPan {
  JiaZi dayGanZhi;
  DiZhi uponGan;
  GuiRenType guiRenType;
  List<RawEachClass> fourClass;
  List<RawEachChuan> threeChuan;
  Map<DiZhi, RawEachGong> gongMapper;

  RawPan({
    required this.dayGanZhi,
    required this.uponGan,
    required this.guiRenType,
    required this.fourClass,
    required this.threeChuan,
    required this.gongMapper,
  });
  factory RawPan.fromJson(Map<String, dynamic> json) => _$RawPanFromJson(json);
  Map<String, dynamic> toJson() => _$RawPanToJson(this);
}

@JsonSerializable()
class RawEachClass {
  int order;
  DiZhi sky;
  DiZhi ground;
  GuiRen guiRen;

  RawEachClass({
    required this.order,
    required this.sky,
    required this.ground,
    required this.guiRen,
  });

  factory RawEachClass.fromJson(Map<String, dynamic> json) =>
      _$RawEachClassFromJson(json);
  Map<String, dynamic> toJson() => _$RawEachClassToJson(this);
}

@JsonSerializable()
class RawFirstClass extends RawEachClass {
  TianGan tianGan;
  RawFirstClass({
    required super.sky,
    required super.ground,
    required super.guiRen,
    required this.tianGan,
    super.order = 1,
  });
  factory RawFirstClass.fromJson(Map<String, dynamic> json) =>
      _$RawFirstClassFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RawFirstClassToJson(this);
}

@JsonSerializable()
class RawEachChuan {
  int order;
  DiZhi diZhi;
  GuiRen guiRen;
  LiuQin liuQin;
  bool get isFirst => order == 1;
  bool get isSecond => order == 2;
  bool get isThird => order == 3;

  RawEachChuan({
    required this.order,
    required this.diZhi,
    required this.guiRen,
    required this.liuQin,
  });
  factory RawEachChuan.fromJson(Map<String, dynamic> json) =>
      _$RawEachChuanFromJson(json);
  Map<String, dynamic> toJson() => _$RawEachChuanToJson(this);
}

@JsonSerializable()
class RawEachGong {
  DiZhi groundPanDiZhi;
  GuiRen guiRen;
  DiZhi skyPanDiZhi;

  RawEachGong({
    required this.groundPanDiZhi,
    required this.guiRen,
    required this.skyPanDiZhi,
  });

  factory RawEachGong.fromJson(Map<String, dynamic> json) =>
      _$RawEachGongFromJson(json);
  Map<String, dynamic> toJson() => _$RawEachGongToJson(this);
}
