import 'package:common/model/enum_di_zhi.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_twenty_eight_xing_xiu.dart';
import 'package:tuple/tuple.dart';
class BodyAndLife{
  // 身命
  // final DiZhi sunEnteredGong;
  // final double sunEnteredGongDegree;
  final EnumTwelveGong lifeGong;
  final double lifeGongDegree;
  final TwentyEightStarInn lifeStarInn;
  final double lifeStarInnDegree;

  final EnumTwelveGong bodyGong;
  final double bodyGongDegree;
  final TwentyEightStarInn bodyStarInn;
  final double bodyStarInnDegree;
  final bool lunarLocationIsBody;

  BodyAndLife({
    // required this.sunEnteredGong,
    // required this.sunEnteredGongDegree,

    required this.lifeGong,
    required this.lifeGongDegree,
    required this.lifeStarInn,
    required this.lifeStarInnDegree,

    required this.bodyGong,
    required this.bodyGongDegree,
    required this.bodyStarInn,
    required this.bodyStarInnDegree,

    required this.lunarLocationIsBody

  });
}
