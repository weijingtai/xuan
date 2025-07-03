import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

import 'da_liu_ren_gong_data_model.dart'; // Updated import
import 'package:daliuren/domain/enums/nine_zong_men.dart'; // Updated import
import 'four_class_data_model.dart'; // Updated import
import 'three_chuan_data_model.dart'; // Updated import

part 'da_liu_ren_pan_data_model.g.dart';

@JsonSerializable()
class DaLiuRenPanDataModel {
  @JsonKey(toJson: _jiaZiToJson, fromJson: _jiaZiFromJson)
  final JiaZi dayJiaZi;

  @JsonKey(toJson: _diZhiToJson, fromJson: _diZhiFromJson)
  final DiZhi shiChen;

  final String juNumberName; // e.g., "一局", "二局"

  // Assuming DaLiuRenGongDataModel.fromJson/toJson handles its enums correctly
  final Map<String, DaLiuRenGongDataModel> heavenPlate;
  final Map<String, DaLiuRenGongDataModel> earthPlate;

  final FourClassDataModel fourClass;
  final ThreeChuanDataModel threeChuan;

  // NineZongMen from domain/enums has @JsonValue
  final NineZongMen nineZongMenName;

  // Added yinYangDun to match PresetPans table structure and source JSON context
  @JsonKey(toJson: _yinYangToJson, fromJson: _yinYangFromJson)
  final YinYang yinYangDun;

  DaLiuRenPanDataModel({
    required this.dayJiaZi,
    required this.shiChen,
    required this.yinYangDun, // Added to constructor
    required this.juNumberName,
    required this.heavenPlate,
    required this.earthPlate,
    required this.fourClass,
    required this.threeChuan,
    required this.nineZongMenName,
  });

  factory DaLiuRenPanDataModel.fromJson(Map<String, dynamic> json) {
    // If 'yinYangDun' is not in the JSON, it needs a default or error handling.
    // Assuming it will be populated by the UseCase before .fromJson is called on combined data,
    // or the JSON itself (if we were to modify it) would contain it.
    // For direct parsing of 甲午庚牛羊_阳.json, this field won't exist.
    // The UseCase creating this model from those files is responsible for setting it.
    return _$DaLiuRenPanDataModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DaLiuRenPanDataModelToJson(this);

  static String _jiaZiToJson(JiaZi jiaZi) => jiaZi.name;
  static JiaZi _jiaZiFromJson(String name) => JiaZi.values.firstWhere((e) => e.name == name);

  static String _diZhiToJson(DiZhi diZhi) => diZhi.name;
  static DiZhi _diZhiFromJson(String name) => DiZhi.values.firstWhere((e) => e.name == name);

  static String _yinYangToJson(YinYang yy) => yy.name; // Assuming YinYang enum has .name
  static YinYang _yinYangFromJson(String name) => YinYang.values.firstWhere((e) => e.name == name);
}
