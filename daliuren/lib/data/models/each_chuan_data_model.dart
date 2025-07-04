import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:daliuren/domain/enums/gui_ren.dart'; // Updated import

part 'each_chuan_data_model.g.dart';

@JsonSerializable()
class EachChuanDataModel {
  @JsonKey(toJson: _diZhiToJson, fromJson: _diZhiFromJson)
  final DiZhi diZhi;

  @JsonKey(toJson: _tianGanToJsonNullable, fromJson: _tianGanFromJsonNullable)
  final TianGan? tianGan; // 天干藏元

  // GuiRen enum from domain/enums now has @JsonValue
  final GuiRen guiRen;

  @JsonKey(toJson: _liuQinToJson, fromJson: _liuQinFromJson)
  final LiuQin liuQin; // 六亲关系

  EachChuanDataModel({
    required this.diZhi,
    this.tianGan,
    required this.guiRen,
    required this.liuQin,
  });

  factory EachChuanDataModel.fromJson(Map<String, dynamic> json) =>
      _$EachChuanDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$EachChuanDataModelToJson(this);

  static String _diZhiToJson(DiZhi diZhi) => diZhi.name;
  static DiZhi _diZhiFromJson(String name) =>
      DiZhi.values.firstWhere((e) => e.name == name);

  static String? _tianGanToJsonNullable(TianGan? gan) => gan?.name;
  static TianGan? _tianGanFromJsonNullable(String? name) =>
      name == null ? null : TianGan.values.firstWhere((e) => e.name == name);

  static String _liuQinToJson(LiuQin liuQin) => liuQin.name;
  static LiuQin _liuQinFromJson(String name) =>
      LiuQin.values.firstWhere((e) => e.name == name);
}
