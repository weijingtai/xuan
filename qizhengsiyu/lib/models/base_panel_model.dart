import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_twelve_gong.dart';
import 'body_life_model.dart';
import 'hua_yao.dart';
import 'star_angle_speed.dart';
import 'star_enter_info.dart';
import 'stars_angle.dart';

part 'base_panel_model.g.dart';

@JsonSerializable()
class BasePanelModel {
  // 1. 星体原始信息
  final Map<EnumStars, StarAngleSpeed> starAngleMapper;
  // 2. 计算星体进入宫位信息
  final Map<EnumStars, EnteredInfo> enteredGongMapper;
  // 3. 计算五星运行状态
  final Map<EnumStars, BaseFiveStarWalkingInfo> fiveStarWalkingTypeMapper;

  // 4. 计算四主（命宫主、身宫主、命度主、身度主）
  final BodyLifeModel bodyLifeModel;

  // 5. 计算命理十二宫
  final Map<EnumTwelveGong, EnumDestinyTwelveGong> twelveGongMapper;
  // 6. 计算神煞位置
  final Map<EnumTwelveGong, List<ShenSha>> shenShaMapper;

  // 7. 计算化曜
  // final Map<HuaYao, EnumStars> huaYaoMapper;
  final List<HuaYaoStarPair> huaYaoStarPairList;

  // 8. 计算十二长生
  final Map<EnumTwelveGong, TwelveZhangSheng> twelveZhangShengGongMapper;

  BasePanelModel({
    required this.starAngleMapper,
    required this.enteredGongMapper,
    required this.fiveStarWalkingTypeMapper,
    required this.bodyLifeModel,
    required this.twelveGongMapper,
    required this.shenShaMapper,
    required this.huaYaoStarPairList,
    required this.twelveZhangShengGongMapper,
  });

  factory BasePanelModel.fromJson(Map<String, dynamic> json) =>
      _$BasePanelModelFromJson(json);

  Map<String, dynamic> toJson() => _$BasePanelModelToJson(this);

  BasePanelModel copyWith({
    Map<EnumStars, StarAngleSpeed>? starAngleMapper,
    Map<EnumStars, EnteredInfo>? enteredGongMapper,
    Map<EnumStars, BaseFiveStarWalkingInfo>? fiveStarWalkingTypeMapper,
    BodyLifeModel? bodyLifeModel,
    Map<EnumTwelveGong, EnumDestinyTwelveGong>? twelveGongMapper,
    Map<EnumTwelveGong, List<ShenSha>>? shenShaMapper,
    List<HuaYaoStarPair>? huaYaoStarPairList,
    Map<EnumTwelveGong, TwelveZhangSheng>? twelveZhangShengGongMapper,
  }) {
    return BasePanelModel(
      starAngleMapper: starAngleMapper ?? this.starAngleMapper,
      enteredGongMapper: enteredGongMapper ?? this.enteredGongMapper,
      fiveStarWalkingTypeMapper:
          fiveStarWalkingTypeMapper ?? this.fiveStarWalkingTypeMapper,
      bodyLifeModel: bodyLifeModel ?? this.bodyLifeModel,
      twelveGongMapper: twelveGongMapper ?? this.twelveGongMapper,
      shenShaMapper: shenShaMapper ?? this.shenShaMapper,
      huaYaoStarPairList: huaYaoStarPairList ?? this.huaYaoStarPairList,
      twelveZhangShengGongMapper:
          twelveZhangShengGongMapper ?? this.twelveZhangShengGongMapper,
    );
  }
}
