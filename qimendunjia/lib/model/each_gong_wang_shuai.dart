import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';

import '../enums/enum_fu_fan_yin.dart';

class EachGongWangShuai {
  static const int MAX_WANG_SHUAI_COUNTER = 7;
  int gongNumber;

  FuFanYinEnum starFuFanYin;
  // NineStarsEnum star;
  NineStarStatusEnum starMonthWangShuai; // 使用月令
  MonthTokenTypeEnum starMonthTokenType; // 仅使用主气五行或主气天干纳卦

  NineStarStatusEnum starGongWangShuai;
  GongTypeEnum starFourWeiGongType;

  FuFanYinEnum doorFuFanYin;
  // EightDoorEnum door;
  FiveEnergyStatus doorMonthWangShuai; // 固定使用月令主气五行
  FiveEnergyStatus doorGongWangShuai; // 有不同的方式进行
  GongTypeEnum doorFourWeiGongType;
  GongAndDoorRelationship? doorGongRelationship;
  bool isDoorRuMu;

  // 八神只用宫卦判断旺衰就行
  // EightGodsEnum god;
  FiveEnergyStatus godGongWangShuai;
  GodWithGongTypeEnum godWithGongType;

  FiveXingRelationship tianDiPanGanRelationship; // 天盘 与 地盘关系

  TwelveZhangSheng? diPanJiGanMonthZhangSheng;
  TwelveZhangSheng? diPanJiGanGongZhangSheng;
  bool?
      diPanJiGanGongIsMuOrKu; // 天盘干在当前宫位是“入墓”还是“入库”， null 为什么也不是，true 是入墓，false 是入库

  // 地盘天干论十二长生
  TwelveZhangSheng diPanMonthZhangSheng;
  TwelveZhangSheng diPanGongZhangSheng;
  bool?
      diPanGongIsMuOrKu; // 天盘干在当前宫位是“入墓”还是“入库”， null 为什么也不是，true 是入墓，false 是入库

  // TianGan tianPan;
  // 天盘天干论十二长生
  TwelveZhangSheng tianPanMonthZhangSheng;
  TwelveZhangSheng tianPanGongZhangSheng;
  bool?
      tianPanGongIsMuOrKu; // 天盘干在当前宫位是“入墓”还是“入库”， null 为什么也不是，true 是入墓，false 是入库

  TwelveZhangSheng? tianPanJiGanMonthZhangSheng;
  TwelveZhangSheng? tianPanJiGanGongZhangSheng;
  bool?
      tianPanJiGanGongIsMuOrKu; // 天盘干在当前宫位是“入墓”还是“入库”， null 为什么也不是，true 是入墓，false 是入库

  TwelveZhangSheng tianPanAnGanMonthZhangSheng;
  TwelveZhangSheng tianPanAnGanGongZhangSheng;
  bool?
      tianPanAnGanIsMuOrKu; // 天盘干在当前宫位是“入墓”还是“入库”， null 为什么也不是，true 是入墓，false 是入库

  TwelveZhangSheng renPanAnGanMonthZhangSheng;
  TwelveZhangSheng renPanAnGanGongZhangSheng;
  bool?
      renPanAnGanIsMuOrKu; // 天盘干在当前宫位是“入墓”还是“入库”， null 为什么也不是，true 是入墓，false 是入库

  TwelveZhangSheng yinGanMonthZhangSheng;
  TwelveZhangSheng yinGanGongZhangSheng;
  bool?
      yinPanAnGanIsMuOrKu; // 天盘干在当前宫位是“入墓”还是“入库”， null 为什么也不是，true 是入墓，false 是入库

  late final int gongWangShuaiCounter;

  // TianGan? diPanJiGan; // 地盘中宫寄干
  // TianGan? tianPanJiGan; // 天盘中宫寄干
  EachGongWangShuai(
      {required this.gongNumber,
      required this.starFuFanYin,
      required this.starMonthWangShuai,
      required this.starMonthTokenType,
      required this.starGongWangShuai,
      required this.starFourWeiGongType,
      required this.doorFuFanYin,
      required this.doorMonthWangShuai, // 固定使用月令主气五行
      required this.doorGongWangShuai, // 仅用宫卦判断旺衰
      required this.doorFourWeiGongType,
      required this.doorGongRelationship,
      required this.isDoorRuMu,
      required this.godGongWangShuai,
      required this.godWithGongType,
      required this.tianDiPanGanRelationship, // 地盘干与天盘干

      required this.tianPanMonthZhangSheng,
      required this.tianPanAnGanMonthZhangSheng,
      required this.yinGanMonthZhangSheng,
      required this.tianPanJiGanMonthZhangSheng,
      required this.diPanJiGanMonthZhangSheng,
      required this.renPanAnGanMonthZhangSheng,
      required this.diPanMonthZhangSheng,
      required this.tianPanGongZhangSheng,
      required this.tianPanAnGanGongZhangSheng,
      required this.diPanGongZhangSheng,
      required this.renPanAnGanGongZhangSheng,
      required this.yinGanGongZhangSheng,
      required this.tianPanJiGanGongZhangSheng,
      required this.diPanJiGanGongZhangSheng,
      this.diPanJiGanGongIsMuOrKu,
      this.diPanGongIsMuOrKu,
      this.tianPanGongIsMuOrKu,
      this.tianPanJiGanGongIsMuOrKu,
      this.tianPanAnGanIsMuOrKu,
      this.renPanAnGanIsMuOrKu,
      this.yinPanAnGanIsMuOrKu}) {
    gongWangShuaiCounter = countingStrongCounter(
        starMonthWangShuai,
        starGongWangShuai,
        doorMonthWangShuai,
        doorGongWangShuai,
        tianPanMonthZhangSheng,
        tianDiPanGanRelationship,
        godGongWangShuai);
  }

  GongWangShuaiType get strongOrWeak =>
      calculateGongWangShuai(gongWangShuaiCounter);

  static bool isStarStrongWithMonth(NineStarStatusEnum nineStartStatus) {
    return [NineStarStatusEnum.WANG, NineStarStatusEnum.XIANG]
        .contains(nineStartStatus);
  }

  static bool isStarStrongWithGong(NineStarStatusEnum nineStartStatus) {
    return [NineStarStatusEnum.WANG, NineStarStatusEnum.XIANG]
        .contains(nineStartStatus);
  }

  static bool isDoorStrongWithMonth(FiveEnergyStatus fiveXingWangShuai) {
    return [FiveEnergyStatus.WANG, FiveEnergyStatus.XIANG]
        .contains(fiveXingWangShuai);
  }

  static bool isDoorStrongWithGong(FiveEnergyStatus fiveXingWangShuai) {
    return [FiveEnergyStatus.WANG, FiveEnergyStatus.XIANG]
        .contains(fiveXingWangShuai);
  }

  static bool isGodStrongWithGong(FiveEnergyStatus fiveXingWangShuai) {
    return [FiveEnergyStatus.WANG, FiveEnergyStatus.XIANG]
        .contains(fiveXingWangShuai);
  }

  static GongWangShuaiType calculateGongWangShuai(int counter) {
    // 判断宫的旺衰，根据 7分 法
    // 星门干 各2分，神1分。
    // 旺、相 为 1分， 休囚死、休囚废不算肥
    // 十二长生中 “长生”、“沐浴”、“临官”、“帝旺” 为旺，其余为衰

    // 1.1. 星，月令
    // 1.2. 星，落宫

    // 2.1 门，月令
    // 2.2 门，落宫

    // 3.1. 干，月令
    // 3.2. 干，落宫

    // 4. 星
    if (MAX_WANG_SHUAI_COUNTER == counter) {
      return GongWangShuaiType.CongQiang;
    } else if (counter >= 4) {
      return GongWangShuaiType.Qiang;
    } else if (counter >= 1) {
      return GongWangShuaiType.Ruo;
    } else {
      return GongWangShuaiType.CongRuo;
    }

    // 计算宫的分数， 四分及以上为强宫，七分为从强宫，零分为从弱，1~3分为弱宫
  }

  static int countingStrongCounter(
      NineStarStatusEnum starAtMonth,
      NineStarStatusEnum starAtGong,
      FiveEnergyStatus doorAtMonth,
      FiveEnergyStatus doorAtGong,
      TwelveZhangSheng tianPanGanZhangSheng,
      FiveXingRelationship tianDiPanGanRelationship,
      FiveEnergyStatus godAtGong) {
    // 判断宫的旺衰，根据 7分 法
    // 星门干 各2分，神1分。
    // 旺、相 为 1分， 休囚死、休囚废不算肥
    // 十二长生中 “长生”、“沐浴”、“临官”、“帝旺” 为旺，其余为衰

    int counter = 0;
    // 1.1. 星，月令
    if (starAtMonth.isStrong) {
      counter += 1;
    }
    // 1.2. 星，落宫
    if (starAtGong.isStrong) {
      counter += 1;
    }

    // 2.1 门，月令
    if (doorAtMonth.isStrong) {
      counter += 1;
    }
    // 2.2 门，落宫
    if (doorAtGong.isStrong) {
      counter += 1;
    }

    // 3.1. 干，月令
    if (tianPanGanZhangSheng.isStrong) {
      counter += 1;
    }
    // 3.2. 干，落宫
    if ([FiveXingRelationship.SHENG, FiveXingRelationship.TONG]
        .contains(tianDiPanGanRelationship)) {
      counter += 1;
    }

    // 4. 神
    if (godAtGong.isStrong) {
      counter += 1;
    }
    return counter;
  }
}

enum GongWangShuaiType {
  CongQiang("从强"),
  Qiang("强"),
  Ruo("弱"),
  CongRuo("从弱");

  final String name;
  const GongWangShuaiType(this.name);
}

enum FanFuYinType {
  FAN_YIN("反吟"),
  FU_YIN("伏吟"),
  NOT("无");

  final String name;
  const FanFuYinType(this.name);
}
