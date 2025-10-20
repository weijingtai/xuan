import 'package:common/enums.dart';
import 'package:common/models/shen_sha.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_twelve_gong.dart';
import '../domain/entities/models/star_angle_speed.dart'; // 使用domain层的模型
import '../domain/entities/models/star_enter_info.dart'; // 使用domain层的模型
import '../domain/entities/models/stars_angle.dart'; // 使用domain层的模型
import 'hua_yao.dart';

part 'da_xian_panel_model.g.dart';

@JsonSerializable()
class DaXianPanelModel {
  // 1. 星体原始信息
  final Map<EnumStars, StarAngleSpeed> starAngleMapper;
  // 2. 计算星体进入宫位信息
  final Map<EnumStars, EnteredInfo> enteredGongMapper;
  // 3. 计算五星运行状态
  final Map<EnumStars, BaseFiveStarWalkingInfo> fiveStarWalkingTypeMapper;

  // 6. 计算神煞位置
  final Map<EnumTwelveGong, List<ShenSha>> shenShaMapper;

  // 7. 计算化曜
  // final Map<HuaYao, EnumStars> huaYaoMapper;
  final List<HuaYaoStarPair> huaYaoStarPairList;

  // 8. 计算十二长生
  final Map<EnumTwelveGong, TwelveZhangSheng> twelveZhangShengGongMapper;

  DaXianPanelModel({
    required this.starAngleMapper,
    required this.enteredGongMapper,
    required this.fiveStarWalkingTypeMapper,
    required this.shenShaMapper,
    required this.huaYaoStarPairList,
    required this.twelveZhangShengGongMapper,
  });

  factory DaXianPanelModel.fromJson(Map<String, dynamic> json) =>
      _$DaXianPanelModelFromJson(json);

  Map<String, dynamic> toJson() => _$DaXianPanelModelToJson(this);

  DaXianPanelModel copyWith({
    Map<EnumStars, StarAngleSpeed>? starAngleMapper,
    Map<EnumStars, EnteredInfo>? enteredGongMapper,
    Map<EnumStars, BaseFiveStarWalkingInfo>? fiveStarWalkingTypeMapper,
    Map<EnumTwelveGong, EnumDestinyTwelveGong>? twelveGongMapper,
    Map<EnumTwelveGong, List<ShenSha>>? shenShaMapper,
    List<HuaYaoStarPair>? huaYaoStarPairList,
    Map<EnumTwelveGong, TwelveZhangSheng>? twelveZhangShengGongMapper,
  }) {
    return DaXianPanelModel(
      starAngleMapper: starAngleMapper ?? this.starAngleMapper,
      enteredGongMapper: enteredGongMapper ?? this.enteredGongMapper,
      fiveStarWalkingTypeMapper:
          fiveStarWalkingTypeMapper ?? this.fiveStarWalkingTypeMapper,
      shenShaMapper: shenShaMapper ?? this.shenShaMapper,
      huaYaoStarPairList: huaYaoStarPairList ?? this.huaYaoStarPairList,
      twelveZhangShengGongMapper:
          twelveZhangShengGongMapper ?? this.twelveZhangShengGongMapper,
    );
  }
}
