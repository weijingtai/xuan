import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import '../enums/enum_settle_life_body.dart';

part 'body_life_model.g.dart';

@JsonSerializable()
class BodyAndLife {
  // 身命
  // final DiZhi sunEnteredGong;
  // final double sunEnteredGongDegree;

  /// 命宫
  final EnumSettleLifeType settleLife;
  final EnumTwelveGong lifeGong;
  final double lifeGongDegree;

  /// 命度
  final TwentyEightStarInn lifeStarInn;
  final double lifeStarInnDegree;

  /// 身宫
  ///
  final EnumSettleBodyType settleBody;
  final EnumTwelveGong bodyGong;
  final double bodyGongDegree;

  final TwentyEightStarInn bodyStarInn;
  final double bodyStarInnDegree;

  BodyAndLife({
    required this.lifeGong,
    required this.lifeGongDegree,
    required this.lifeStarInn,
    required this.lifeStarInnDegree,
    required this.bodyGong,
    required this.bodyGongDegree,
    required this.bodyStarInn,
    required this.bodyStarInnDegree,
    required this.settleBody,
    required this.settleLife,
  });
}
