import 'dart:convert';

import 'package:common/model/enum_di_zhi.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_twenty_eight_xing_xiu.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_stars.dart';


class StarWalkingInfo{
  EnumStars star;
  FiveStarWalkingType walkingType;
  double speed;
  double angle;
  DateTime walkingTypeStartAt;
  StarWalkingInfo({
    required this.star,
    required this.walkingType,
    required this.walkingTypeStartAt,
    required this.speed,
    required this.angle,
  });

  // toJson
  Map<String, dynamic> toJson() => {
    "star":star.name,
    "walkingType":walkingType.name,
    "walkingTypeStartAt":walkingTypeStartAt.toString(),
    "speed":speed,
    "angle":angle,
  };
  // toString print json
  @override
  String toString() => jsonEncode(toJson());

}
class FiveStarWalkingInfo {
  EnumStars star;
  double angle;
  FiveStarWalkingType walkingType;
  DateTime walkingTypeStartAt;
  DateTime walkingTypeEndAt;


  String speedThresholdName;  // 阈值使用的参数  单前多为moira
  double maxSpeed;
  double retrogradeMaxSpeed;

  double staySpeedThresholdAt; // 留行开始阈值
  double reversedSpeedThresholdAt; // 逆行开始阈值

  double? fastSpeedThresholdAt; // 疾行开始阈值
  double? lowSpeedThresholdAt; // 迟行开始阈值

  bool isHidden; // 伏
  DateTime? hiddenStartAt;
  DateTime? hiddenEndAt;

  List<StarWalkingInfo> nextSeq;
  List<StarWalkingInfo> prevSeq;
  FiveStarWalkingInfo({
    required this.star,
    required this.angle,
    required this.walkingType,
    required this.walkingTypeStartAt,
    required this.walkingTypeEndAt,
    required this.speedThresholdName,
    required this.maxSpeed,
    required this.retrogradeMaxSpeed,
    required this.staySpeedThresholdAt,
    required this.reversedSpeedThresholdAt,
    required this.nextSeq,
    required this.prevSeq,
    this.fastSpeedThresholdAt,
    this.lowSpeedThresholdAt,
    this.isHidden = false,
    this.hiddenStartAt,
    this.hiddenEndAt,
  });

}



