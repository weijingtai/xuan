import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/models/gong_and_degree.dart';

import '../qi_zheng_si_yu_constant_resources.dart';

part 'star_inn_gong_degree.g.dart';

@JsonSerializable()
class StarInnGongDegreeInfo {
  // 例如(starType:"黄道古制",starXiu:TwentyEightXingXiu.Lou_Jin_Gou, degreeStartAt: 015.9, insideGongStartAtDegree: Tuple2<EnumTwelveGong,double>(EnumTwelveGong.Xu,15.9), insideGongEndAtDegree: Tuple2<EnumTwelveGong,double>(EnumTwelveGong.Xu,26.3), totalDegree:10.4),
  // 星宿类型
  final StarPanelType starType;

  // 二十八星宿
  final TwentyEightStarInn starXiu;
  // 星宿开始的度数
  final double degreeStartAt;

  // final Tuple2<EnumTwelveGong, double> insideGongStartAtDegree;
  // final Tuple2<EnumTwelveGong, double> insideGongEndAtDegree;
  final GongAndDegree startAtGongDegree;
  final GongAndDegree endAtGongDegree;
  // 星宿的总度数
  final double totalDegree;
  StarInnGongDegreeInfo({
    required this.starType,
    required this.starXiu,
    required this.degreeStartAt,
    required this.totalDegree,
    required this.startAtGongDegree,
    required this.endAtGongDegree,
  });

  factory StarInnGongDegreeInfo.fromJson(Map<String, dynamic> json) =>
      _$StarInnGongDegreeInfoFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StarInnGongDegreeInfoToJson(this);
}
