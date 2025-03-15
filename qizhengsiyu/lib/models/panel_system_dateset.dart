import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/models/star_enter_info.dart';

import '../enums/enum_panel_system_type.dart';
import 'star_inn_gong_degree.dart';

part 'panel_system_dateset.g.dart';

@JsonSerializable()
class PanelSystemDataSet {
  /// 汉书律历志 角宿：起始于角宿一（室女座α），赤道经度为12度。
  String name;
  String calenderName;
  String features;
  CoordinateSystem coordinateSystem; // 黄道制、赤道制之分
  StarInnSystem starInnSystem; // 星宿系统 恒星制与回归制
  StarInnType starInnType; // 古宿、古宿修正、今宿

  EnteredInfo originPoint;
  // EnumTwelveGong originPointGong; // 星盘0度点宫位
  // double originPointAtGongDegree; // 0度点虽在星宿的角度
  // TwentyEightStarInn originPointStarInn; //  零度点所在星宿
  // double originPointAtStarInnDegree; // 0度点虽在星宿的角度
  TwentyFourJieQi originPointJieQi; // 0度点所在节气
  List<String> descriptionList;
  Map<TwentyEightStarInn, StarInnGongDegreeInfo> starInnGongDegreeMap = {};

  PanelSystemDataSet({
    required this.name,
    required this.calenderName,
    required this.features,
    required this.coordinateSystem,
    required this.starInnSystem,
    required this.starInnType,
    required this.originPoint,
    required this.originPointJieQi,
    required this.descriptionList,
  });
  factory PanelSystemDataSet.fromJson(Map<String, dynamic> json) =>
      _$PanelSystemDataSetFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PanelSystemDataSetToJson(this);
}
