import 'package:tuple/tuple.dart';

import '../enums/enum_twelve_gong.dart';
import '../enums/enum_twenty_eight_xing_xiu.dart';
import '../qi_zheng_si_yu_constant_resources.dart';

class StarXiuType{
  // 星宿类型， 古制、今制 之类

  final StarPanelType starType;
  final TwentyEightStarInn starXiu;
  final double degreeStartAt;
  final Tuple2<EnumTwelveGong,double> insideGongStartAtDegree;
  final Tuple2<EnumTwelveGong,double> insideGongEndAtDegree;
  final double totalDegree;
  StarXiuType({
    required this.starType,
    required this.starXiu,
    required this.degreeStartAt,
    required this.totalDegree,
    required this.insideGongStartAtDegree,
    required this.insideGongEndAtDegree,
  });

  // StarXiuType(starType:"黄道古制",starXiu:TwentyEightXingXiu.Lou_Jin_Gou, degreeStartAt: 015.9, insideGongStartAtDegree: Tuple2<EnumTwelveGong,double>(EnumTwelveGong.Xu,15.9), insideGongEndAtDegree: Tuple2<EnumTwelveGong,double>(EnumTwelveGong.Xu,26.3), totalDegree:10.4),
}