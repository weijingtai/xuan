import 'package:common/model/enum_di_zhi.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/enums/enum_twenty_eight_xing_xiu.dart';

import 'package:qizhengsiyu/enums/enum_moon_phases.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_stars.dart';
class ElevenStarsInfo{
  final EnumStars star;
  final double angle;
  final EnumTwelveGong enteredGong;
  final double enteredGongDegree;
  final TwentyEightStarInn enteredStarInn;
  final double enteredStarInnDegree;
  ElevenStarsInfo({
    required this.star,
    required this.angle,
    required this.enteredGong,
    required this.enteredGongDegree,
    required this.enteredStarInn,
    required this.enteredStarInnDegree,
  });
}
class FiveStarsInfo extends ElevenStarsInfo{

  FiveStarWalkingType fiveStarWalkingType;
  double walkingSpeed;
  bool isHidden;// 是否为伏
  FiveStarsInfo({
    required EnumStars star,
    required double angle,
    required EnumTwelveGong enteredGong,
    required double enteredGongDegree,
    required TwentyEightStarInn enteredStarInn,
    required double enteredStarInnDegree,
    required this.fiveStarWalkingType,
    required this.walkingSpeed,
    this.isHidden = false
  }):super(
    star:star,
    angle:angle,
    enteredGong:enteredGong,
    enteredGongDegree:enteredGongDegree,
    enteredStarInn:enteredStarInn,
    enteredStarInnDegree:enteredStarInnDegree,
  );

  // copy method
  FiveStarsInfo copyWith({
    EnumStars? star,
    double? angle,
    EnumTwelveGong? enteredGong,
    double? enteredGongDegree,
    TwentyEightStarInn? enteredStarInn,
    double? enteredStarInnDegree,
    FiveStarWalkingType? fiveStarWalkingType,
    double? walkingSpeed,
    bool? isHidden,
  }) => FiveStarsInfo(
    star: star ?? this.star,
    angle: angle ?? this.angle,
    enteredGong: enteredGong ?? this.enteredGong,
    enteredGongDegree: enteredGongDegree ?? this.enteredGongDegree,
    enteredStarInn: enteredStarInn ?? this.enteredStarInn,
    enteredStarInnDegree: enteredStarInnDegree ?? this.enteredStarInnDegree,
    fiveStarWalkingType: fiveStarWalkingType ?? this.fiveStarWalkingType,
    walkingSpeed: walkingSpeed ?? this.walkingSpeed,
    isHidden: isHidden ?? this.isHidden,

  );
}
class MoonInfo extends ElevenStarsInfo{

  EnumMoonPhases moonPhase;
  MoonInfo({
    required double angle,
    required EnumTwelveGong enteredGong,
    required double enteredGongDegree,
    required TwentyEightStarInn enteredStarInn,
    required double enteredStarInnDegree,
    required this.moonPhase,
  }):super(
    star:EnumStars.Moon,
    angle:angle,
    enteredGong:enteredGong,
    enteredGongDegree:enteredGongDegree,
    enteredStarInn:enteredStarInn,
    enteredStarInnDegree:0.0,
  );
}
class LouJiStarsInfo extends ElevenStarsInfo{

  bool isRoundSun;
  double roundDegreeRange;
  bool isRoundMoon;
  bool get isLuo => star == EnumStars.Luo;
  bool get isJi=> star == EnumStars.Ji;
  LouJiStarsInfo({
    required EnumStars star,
    required double angle,
    required EnumTwelveGong enteredGong,
    required double enteredGongDegree,
    required TwentyEightStarInn enteredStarInn,
    required double enteredStarInnDegree,
    required this.isRoundMoon,
    required this.isRoundSun,
    required this.roundDegreeRange
  }):super(
    star:star,
    angle:angle,
    enteredGong:enteredGong,
    enteredGongDegree:enteredGongDegree,
    enteredStarInn:enteredStarInn,
    enteredStarInnDegree:enteredStarInnDegree,
  );
}
