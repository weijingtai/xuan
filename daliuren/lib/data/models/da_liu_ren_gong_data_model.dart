import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:daliuren/domain/enums/gui_ren.dart'; // Updated import path for GuiRen

part 'da_liu_ren_gong_data_model.g.dart'; // Updated part directive

@JsonSerializable()
class DaLiuRenGongDataModel {
  @JsonKey(toJson: _diZhiToJson, fromJson: _diZhiFromJson)
  final DiZhi groundPanDiZhi;

  // GuiRen enum now includes @JsonValue, so direct serialization should work.
  // If not, add @JsonKey(toJson: _guiRenToJson, fromJson: _guiRenFromJson)
  final GuiRen guiRen;

  @JsonKey(toJson: _diZhiToJson, fromJson: _diZhiFromJson)
  final DiZhi skyPanDiZhi;

  @JsonKey(toJson: _tianGanToJsonNullable, fromJson: _tianGanFromJsonNullable)
  final TianGan? tianGan;

  @JsonKey(toJson: _jiaZiToJsonNullable, fromJson: _jiaZiFromJsonNullable)
  final JiaZi? jiaZi;

  DaLiuRenGongDataModel({
    required this.skyPanDiZhi,
    required this.groundPanDiZhi,
    required this.guiRen,
    this.jiaZi,
    this.tianGan,
  });

  factory DaLiuRenGongDataModel.fromJson(Map<String, dynamic> json) =>
      _$DaLiuRenGongDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$DaLiuRenGongDataModelToJson(this);

  // Converters for enums from 'common' package (if they don't use @JsonValue or for explicitness)
  static String _diZhiToJson(DiZhi diZhi) => diZhi.name;
  static DiZhi _diZhiFromJson(String name) => DiZhi.values.firstWhere((e) => e.name == name);

  static String? _tianGanToJsonNullable(TianGan? gan) => gan?.name;
  static TianGan? _tianGanFromJsonNullable(String? name) => name == null ? null : TianGan.values.firstWhere((e) => e.name == name);

  static String? _jiaZiToJsonNullable(JiaZi? jiaZi) => jiaZi?.name;
  static JiaZi? _jiaZiFromJsonNullable(String? name) => name == null ? null : JiaZi.values.firstWhere((e) => e.name == name);

  // Converters for local GuiRen enum (if it didn't have @JsonValue)
  // static String _guiRenToJson(GuiRen guiRen) => guiRen.name;
  // static GuiRen _guiRenFromJson(String name) => GuiRen.values.firstWhere((e) => e.name == name);
}
