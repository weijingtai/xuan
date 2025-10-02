import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

import 'enum_gui_ren.dart';
part 'each_chuan.g.dart';

@JsonSerializable()
class EachChuan {
  int order;
  DiZhi diZhi;
  TianGan? tianGan;
  GuiRen guiRen;
  LiuQin liuQin;
  EachChuan({
    required this.order,
    required this.guiRen,
    required this.liuQin,
    required this.diZhi,
    this.tianGan,
  });

  factory EachChuan.fromJson(Map<String, dynamic> json) =>
      _$EachChuanFromJson(json);
  Map<String, dynamic> toJson() => _$EachChuanToJson(this);
}
