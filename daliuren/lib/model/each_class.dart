import 'package:common/enums.dart';
import 'package:daliuren/model/zei_key_type.dart';
import 'package:json_annotation/json_annotation.dart';

import 'enum_gui_ren.dart';

part 'each_class.g.dart';

// 十干寄宫
Map<TianGan, DiZhi> tenGanJiGongMapper = {
  TianGan.JIA: DiZhi.YIN,
  TianGan.YI: DiZhi.CHEN,
  TianGan.BING: DiZhi.SI,
  TianGan.DING: DiZhi.WEI,
  TianGan.WU: DiZhi.SI,
  TianGan.JI: DiZhi.WEI,
  TianGan.GENG: DiZhi.SHEN,
  TianGan.XIN: DiZhi.XU,
  TianGan.REN: DiZhi.HAI,
  TianGan.GUI: DiZhi.CHOU
  // "甲":"寅",
  // "乙":"辰",
  // "丙":"巳",
  // "丁":"未",
  // "戊":"巳",
  // "己":"未",
  // "庚":"申",
  // "辛":"戌",
  // "壬":"亥",
  // "癸":"丑"
};

@JsonSerializable()
class EachClass {
  final int order;
  DiZhi sky;
  DiZhi ground;
  bool isFirstClass;
  GuiRen guiRen;
  int? sheHaiTimes;

  List<int>? otherSameSkyGroundIndexList;

  bool get isBieZeClass => otherSameSkyGroundIndexList != null;

  EachClassZeiKeType? zeiKeType; //  当为 "null"时标识没有“贼克”关系

  bool?
      isSkyKeDayGan; // 上神是否是克“日干”的 上神克日干时为“true”, 上神受日干克为“false”，上神与日干无关系时为“null”
  bool isSkySameYinYangWithDayGan = false; // 上神和日干是否是同阴阳的
  // int? sheHaiShenQianTimes; // 涉害深浅次数，当为“null”时，表示没有涉害
  EachClass({
    required this.order,
    required this.sky,
    required this.ground,
    required this.guiRen,
    this.isSkyKeDayGan = false,
    this.isSkySameYinYangWithDayGan = false,
    this.isFirstClass = false,
  }) {
    // 当前为“贼” -- “下克上”
    bool isZei =
        FiveXingRelationship.checkRelationship(sky.fiveXing, ground.fiveXing) ==
            FiveXingRelationship.KE;
    if (isZei) {
      zeiKeType = EachClassZeiKeType.ZEI;
    }
    // 当前为“克” -- “上克下”
    bool isKe =
        FiveXingRelationship.checkRelationship(ground.fiveXing, sky.fiveXing) ==
            FiveXingRelationship.KE;
    if (isKe) {
      zeiKeType = EachClassZeiKeType.KE;
    }
  }
  factory EachClass.fromJson(Map<String, dynamic> json) =>
      _$EachClassFromJson(json);
  Map<String, dynamic> toJson() => _$EachClassToJson(this);
}
