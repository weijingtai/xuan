import 'dart:convert';

import 'package:tuple/tuple.dart';

import '../enums/enum_stars.dart';
import 'eleven_stars_info.dart';

class PanelStarsInfo{
  final ElevenStarsInfo sun;
  final MoonInfo moon;

  final FiveStarsInfo golden;
  final FiveStarsInfo wood;
  final FiveStarsInfo fire;
  final FiveStarsInfo soil;
  final FiveStarsInfo water;

  final LouJiStarsInfo ji;
  final LouJiStarsInfo luo;
  final ElevenStarsInfo bei;
  final ElevenStarsInfo qi;
  final bool isSunLunarTouch; // 是否为日月合
  final bool isLunarEclipse;
  final bool isSunEclipse;


  PanelStarsInfo({
    required this.sun,
    required this.moon,
    required this.golden,
    required this.wood,
    required this.fire,
    required this.soil,
    required this.water,
    required this.ji,
    required this.luo,
    required this.bei,
    required this.qi,
    required this.isSunLunarTouch,
    required this.isLunarEclipse,
    required this.isSunEclipse,

  });

  ElevenStarsInfo getByStar(EnumStars star){
    switch(star){
      case EnumStars.Moon:
        return moon;
      case EnumStars.Sun:
        return sun;
      case EnumStars.Golden:
        return golden;
      case EnumStars.Water:
        return water;
      case EnumStars.Wood:
        return wood;
      case EnumStars.Fire:
        return fire;
      case EnumStars.Soil:
        return soil;
      case EnumStars.Qi:
        return qi;
      case EnumStars.Bei:
        return bei;
      case EnumStars.Ji:
        return ji;
      case EnumStars.Luo:
        return luo;
    }
  }


}


class StarsAngle{
  final double sun;
  final double moon;

  final double golden;
  final double goldenSpeed;
  final double wood;
  final double woodSpeed;
  final double fire;
  final double fireSpeed;
  final double soil;
  final double soilSpeed;
  final double water;
  final double waterSpeed;

  final double southNode;
  final double northNode;
  final double lilith;
  final double qi;


  StarsAngle({
    required this.sun,
    required this.moon,
    required this.golden,
    required this.goldenSpeed,
    required this.wood,
    required this.woodSpeed,
    required this.fire,
    required this.fireSpeed,
    required this.soil,
    required this.soilSpeed,
    required this.water,
    required this.waterSpeed,
    required this.southNode,
    required this.northNode,
    required this.lilith,
    required this.qi,
  });

  double getByStar(EnumStars star){
    double starAngle = 0;
    switch(star){
      case EnumStars.Moon:
        starAngle = moon;
        break;
      case EnumStars.Sun:
        starAngle = sun;
        break;
      case EnumStars.Golden:
        starAngle = golden;
        break;
      case EnumStars.Water:
        starAngle = water;
        break;
      case EnumStars.Wood:
        starAngle = wood;
        break;
      case EnumStars.Fire:
        starAngle = fire;
        break;
      case EnumStars.Soil:
        starAngle = soil;
        break;
      case EnumStars.Qi:
        starAngle = qi;
        break;
      case EnumStars.Bei:
        starAngle = lilith;
        break;
      case EnumStars.Ji:
        starAngle = northNode;
        break;
      case EnumStars.Luo:
        starAngle = southNode;
        break;
    }
    return starAngle;
  }

  // to json
  Map<String, dynamic> toJson() => {
    'sun': sun,
    'lunar': moon,
    'golden': golden,
    'wood': wood,
    'fire': fire,
    'soil': soil,
    'water': water,
    'southNode': southNode,
    'northNode': northNode,
    'lilith': lilith,
    'qi': qi,
  };
  // toString print json
  @override
  String toString() => jsonEncode(toJson());



  // # moira 中
  // #   火星迟行 速度节点为“0.409” 大于时为正常速度，小于时为迟行
  // #   火星疾行 速度节点为“0.706” 大于时为疾行速度，小于时为正常
  // #   火星留行 速度节点为“0.074” 小于时开始成为“留行”
  // #  火星逆行节点 -0.077°
  // #   火星最快 0.778°/天  最慢 -0.386°/天
  //
  // #   金星疾行 没有疾行
  // #   金星迟行、常速 速度节点为“0.709” 大于时为正常速度，小于时为迟行
  // #   --金星留行 速度节点为“0.731” 小于时开始成为“留行”-- 有误
  // #   金星迟、留行节点 0.103°/天
  // #  金星逆行节点 -0.115°/天
  // #   金星最快 1.238°/天  最慢-0.613°/天
  //
  // #   木星迟行 速度节点为“0.048” 大于时为正常速度，小于时为迟行
  // #   木星疾行 0.23°/天 大于时为疾行速度，小于时为正常
  // #   木星留行 速度节点为“0.011” 小于时开始成为“留行”
  // # 木星逆行节点 -0.022°/天
  // #   木星最快  0.236°/天  最慢-0.134°/天
  //
  // # 水星 最快  2.2°/天   最慢 -1.348°/天【常】
  // #   水星迟行 速度节点为“0.868” 大于时为正常速度，小于时为迟行
  // #   水星疾行 速度节点"1.499",大于时为疾行速度，小于时为正常
  // #   水星留行 速度节点"0.129",大 小于时开始成为“留行”
  // # 水星逆行 -0.089°/天
  //
  // # 土星 最快  0.122°/天  最慢 -0.075°/天
  // #  土星没有迟与疾
  // #   土星留行 速度节点"0.019",大 小于时开始成为“留行”
  // #   土星逆行 节点-0.012°/天



  // tuple6.item1 最快速度，item2 逆行最快，item3 逆行，item4 留行，item5疾行，item6 迟行
  static Map<EnumStars,Tuple6<double,double,double,double,double?,double?>> moirasFiveStartsMapper ={
    EnumStars.Fire: Tuple6(0.778, -0.386, -0.077, 0.074, 0.706, 0.409),
    EnumStars.Golden: Tuple6(1.238, -0.613, -0.115, 0.103, null, 0.709),
    EnumStars.Wood: Tuple6(0.236, -0.134, 0.022, 0.011, 0.23, 0.048),
    EnumStars.Water: Tuple6(2.2, -1.348, -0.089, 0.129, 1.499, 0.868),
    EnumStars.Soil: Tuple6(0.122, -0.075, -0.012, 0.019, null, null),
  };
}

class UIStarsAngle{
  final double sun;
  final double uiSunAngle;

  final double moon;
  final double uiMoonAngle;

  final double golden;
  final double goldenSpeed;
  final double uiGoldenAngle;


  final double wood;
  final double uiWoodAngle;
  final double woodSpeed;

  final double fire;
  final double uiFireAngle;
  final double fireSpeed;

  final double soil;
  final double uiSoilAngle;
  final double soilSpeed;

  final double water;
  final double uiWaterAngle;
  final double waterSpeed;

  final double southNode;
  final double uiSouthNodeAngle;

  final double northNode;
  final double uiNorthNodeAngle;

  final double lilith;
  final double uiBeiAngle;

  final double qi;
  final double uiQiAngle;


  UIStarsAngle(
      {
    required this.sun,
    required this.moon,
    required this.golden,
    required this.goldenSpeed,
    required this.wood,
    required this.woodSpeed,
    required this.fire,
    required this.fireSpeed,
    required this.soil,
    required this.soilSpeed,
    required this.water,
    required this.waterSpeed,
    required this.southNode,
    required this.northNode,
    required this.lilith,
    required this.qi,
    required this.uiSunAngle,
    required this.uiMoonAngle,
    required this.uiGoldenAngle,
    required this.uiWoodAngle,
    required this.uiFireAngle,
    required this.uiSoilAngle,
    required this.uiWaterAngle,
    required this.uiSouthNodeAngle,
    required this.uiNorthNodeAngle,
    required this.uiBeiAngle,
    required this.uiQiAngle,
      });

  UIStarsAngle.from(StarsAngle starsAngle,{
    required double? uiSunAngle,
    required double? uiMoonAngle,
    required double? uiGoldenAngle,
    required double? uiWoodAngle,
    required double? uiFireAngle,
    required double? uiSoilAngle,
    required double? uiWaterAngle,
    required double? uiSouthNodeAngle,
    required double? uiNorthNodeAngle,
    required double? uiBeiNodeAngle,
    required double? uiQiAngle,
  }):this(
    sun: starsAngle.sun,
    moon: starsAngle.moon,
    golden: starsAngle.golden,
    goldenSpeed: starsAngle.goldenSpeed,
    wood: starsAngle.wood,
    woodSpeed: starsAngle.woodSpeed,
    fire: starsAngle.fire,
    fireSpeed: starsAngle.fireSpeed,
    soil: starsAngle.soil,
    soilSpeed: starsAngle.soilSpeed,
    water: starsAngle.water,
    waterSpeed: starsAngle.waterSpeed,
    southNode: starsAngle.southNode,
    northNode: starsAngle.northNode,
    lilith: starsAngle.lilith,
    qi: starsAngle.qi,
    uiSunAngle: uiSunAngle??starsAngle.sun,
    uiMoonAngle: uiMoonAngle??starsAngle.moon,
    uiGoldenAngle: uiGoldenAngle??starsAngle.golden,
    uiWoodAngle: uiWoodAngle??starsAngle.wood,
  uiFireAngle: uiFireAngle??starsAngle.fire,
  uiSoilAngle: uiSoilAngle??starsAngle.soil,
  uiWaterAngle: uiWaterAngle??starsAngle.water,
  uiSouthNodeAngle: uiSouthNodeAngle??starsAngle.southNode,
  uiNorthNodeAngle: uiNorthNodeAngle??starsAngle.northNode,
  uiBeiAngle: uiBeiNodeAngle??starsAngle.lilith,
  uiQiAngle: uiQiAngle??starsAngle.qi,
  );

  double getByStar(EnumStars star){
    double starAngle = 0;
    switch(star){
      case EnumStars.Moon:
        starAngle = moon;
        break;
      case EnumStars.Sun:
        starAngle = sun;
        break;
      case EnumStars.Golden:
        starAngle = golden;
        break;
      case EnumStars.Water:
        starAngle = water;
        break;
      case EnumStars.Wood:
        starAngle = wood;
        break;
      case EnumStars.Fire:
        starAngle = fire;
        break;
      case EnumStars.Soil:
        starAngle = soil;
        break;
      case EnumStars.Qi:
        starAngle = qi;
        break;
      case EnumStars.Bei:
        starAngle = lilith;
        break;
      case EnumStars.Ji:
        starAngle = northNode;
        break;
      case EnumStars.Luo:
        starAngle = southNode;
        break;
    }
    return starAngle;
  }
  double getUIAngleByStar(EnumStars star){
    double starAngle = 0;
    switch(star){
      case EnumStars.Moon:
        starAngle = uiMoonAngle;
        break;
      case EnumStars.Sun:
        starAngle = uiSunAngle;
        break;
      case EnumStars.Golden:
        starAngle = uiGoldenAngle;
        break;
      case EnumStars.Water:
        starAngle = uiWaterAngle;
        break;
      case EnumStars.Wood:
        starAngle = uiWoodAngle;
        break;
      case EnumStars.Fire:
        starAngle = uiFireAngle;
        break;
      case EnumStars.Soil:
        starAngle = uiSoilAngle;
        break;
      case EnumStars.Qi:
        starAngle = uiQiAngle;
        break;
      case EnumStars.Bei:
        starAngle = uiBeiAngle;
        break;
      case EnumStars.Ji:
        starAngle = uiNorthNodeAngle;
        break;
      case EnumStars.Luo:
        starAngle = uiSoilAngle;
        break;
    }
    return starAngle;
  }


  // to json
  Map<String, dynamic> toJson() => {
    'sun': sun,
    'lunar': moon,
    'golden': golden,
    'wood': wood,
    'fire': fire,
    'soil': soil,
    'water': water,
    'southNode': southNode,
    'northNode': northNode,
    'lilith': lilith,
    'qi': qi,
  };
  // toString print json
  @override
  String toString() => jsonEncode(toJson());



  // # moira 中
  // #   火星迟行 速度节点为“0.409” 大于时为正常速度，小于时为迟行
  // #   火星疾行 速度节点为“0.706” 大于时为疾行速度，小于时为正常
  // #   火星留行 速度节点为“0.074” 小于时开始成为“留行”
  // #  火星逆行节点 -0.077°
  // #   火星最快 0.778°/天  最慢 -0.386°/天
  //
  // #   金星疾行 没有疾行
  // #   金星迟行、常速 速度节点为“0.709” 大于时为正常速度，小于时为迟行
  // #   --金星留行 速度节点为“0.731” 小于时开始成为“留行”-- 有误
  // #   金星迟、留行节点 0.103°/天
  // #  金星逆行节点 -0.115°/天
  // #   金星最快 1.238°/天  最慢-0.613°/天
  //
  // #   木星迟行 速度节点为“0.048” 大于时为正常速度，小于时为迟行
  // #   木星疾行 0.23°/天 大于时为疾行速度，小于时为正常
  // #   木星留行 速度节点为“0.011” 小于时开始成为“留行”
  // # 木星逆行节点 -0.022°/天
  // #   木星最快  0.236°/天  最慢-0.134°/天
  //
  // # 水星 最快  2.2°/天   最慢 -1.348°/天【常】
  // #   水星迟行 速度节点为“0.868” 大于时为正常速度，小于时为迟行
  // #   水星疾行 速度节点"1.499",大于时为疾行速度，小于时为正常
  // #   水星留行 速度节点"0.129",大 小于时开始成为“留行”
  // # 水星逆行 -0.089°/天
  //
  // # 土星 最快  0.122°/天  最慢 -0.075°/天
  // #  土星没有迟与疾
  // #   土星留行 速度节点"0.019",大 小于时开始成为“留行”
  // #   土星逆行 节点-0.012°/天

}
