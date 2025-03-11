import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

import 'enum_fu_fan_yin.dart';

enum EightDoorEnum {
  @JsonValue("休门")
  XIU(1, "休门", "休", FiveXing.SHUI, HouTianGua.Kan),
  @JsonValue("生门")
  SHENG(8, "生门", "生", FiveXing.TU, HouTianGua.Gen),
  @JsonValue("伤门")
  SHANG(3, "伤门", "伤", FiveXing.MU, HouTianGua.Zhen),
  @JsonValue("杜门")
  DU(4, "杜门", "杜", FiveXing.MU, HouTianGua.Xun),
  @JsonValue("景门")
  JING_S(9, "景门", "景", FiveXing.HUO, HouTianGua.Li), // 南方 用South
  @JsonValue("死门")
  SI(2, "死门", "死", FiveXing.TU, HouTianGua.Kun),
  @JsonValue("惊门")
  JING_W(7, "惊门", "惊", FiveXing.JIN, HouTianGua.Dui), // 西方，用West
  @JsonValue("开门")
  KAI(6, "开门", "开", FiveXing.JIN, HouTianGua.Qian),
  @JsonValue("中央")
  CENTER(5, "中央", "中", FiveXing.TU, HouTianGua.Kun);

  final String name;
  final int number;
  final String singleCharName;
  final FiveXing fiveXing;
  final HouTianGua originalGong;

  const EightDoorEnum(this.number, this.name, this.singleCharName,
      this.fiveXing, this.originalGong);

  static EightDoorEnum fromNumber(int number) =>
      values.firstWhere((element) => element.number == number);

  static EightDoorEnum fromName(String name) =>
      values.firstWhere((element) => element.name == name);

  static EightDoorEnum fromSingleCharName(String name) =>
      values.firstWhere((e) => e.name.startsWith(name));

  static List<EightDoorEnum> get listOrderedByGongNumber => [
        XIU,
        SI,
        SHANG,
        DU,
        CENTER,
        KAI,
        JING_W,
        SHENG,
        JING_S,
      ];

  // 从休门开始
  static List<EightDoorEnum> get listOrderedByClockedwiseWithoutCenter =>
      [XIU, SHENG, SHANG, DU, JING_S, SI, JING_W, KAI];

  static Map<int, EightDoorEnum> get mapNumberToEnum =>
      Map.fromEntries(values.map((e) => MapEntry(e.number, e)));
  FuFanYinEnum checkFuFanYinByGong(HouTianGua gongGua) {
    if (originalGong == gongGua) {
      return FuFanYinEnum.Fu_Yin;
    }
    bool isFanYin = false;
    switch (originalGong) {
      case HouTianGua.Kan:
        isFanYin = gongGua == HouTianGua.Li;
        break;
      case HouTianGua.Li:
        isFanYin = gongGua == HouTianGua.Kan;
        break;
      case HouTianGua.Zhen:
        isFanYin = gongGua == HouTianGua.Dui;
        break;
      case HouTianGua.Dui:
        isFanYin = gongGua == HouTianGua.Zhen;
        break;
      case HouTianGua.Gen:
        isFanYin = gongGua == HouTianGua.Kun;
        break;
      case HouTianGua.Kun:
        isFanYin = gongGua == HouTianGua.Gen;
        break;
      case HouTianGua.Xun:
        isFanYin = gongGua == HouTianGua.Qian;
        break;
      case HouTianGua.Qian:
        isFanYin = gongGua == HouTianGua.Xun;
        break;

      case HouTianGua.Center:
      default:
        break;
    }

    return isFanYin ? FuFanYinEnum.Fan_Yin : FuFanYinEnum.Not;
  }

  FiveEnergyStatus checkWithMonthToken(MonthToken token) {
    // 同我为旺，生我为相，我生为休、我克为死
    // FiveXingRelationship relationship = FiveXingRelationship.checkRelationship(
    //     fiveXing, token.diZhi.fiveXing)!;
    return checkWangShuai(token.diZhi.fiveXing);
  }

  FiveEnergyStatus checkWithGong(HouTianGua gong) {
    // 同我为旺，生我为相，我生为休、我克为死
    return checkWangShuai(gong.fiveXing);
  }

  FiveEnergyStatus checkWangShuai(FiveXing otherFiveXing) {
    // 同我为旺，生我为相，我生为休、我克为死
    // FiveXingRelationship relationship = FiveXingRelationship.checkRelationship(
    //     fiveXing,otherFiveXing)!;
    switch (FiveXingRelationship.checkRelationship(fiveXing, otherFiveXing)!) {
      case FiveXingRelationship.XIE:
        return FiveEnergyStatus.XIU;
      case FiveXingRelationship.SHENG:
        return FiveEnergyStatus.XIANG;
      case FiveXingRelationship.HAO:
        return FiveEnergyStatus.QIU;
      case FiveXingRelationship.KE:
        return FiveEnergyStatus.SI;
      default:
        return FiveEnergyStatus.WANG;
    }
  }
}

enum GongAndDoorRelationship {
  FU_YIN("伏吟", "伏"),
  FAN_YIN("反吟", "伏"),
  DA_JI("大吉", "吉"),
  XIAO_JI("小吉", "吉"),
  DA_XIONG("大凶", "凶"),
  XIAO_XIONG("小凶", "凶"),

  RU_MU("入墓", "墓"),
  MEN_PO("门迫", "迫"), // 门克宫 -- 迫
  SHOU_ZHI("受制", "制"), // 宫克门 -- 制
  SHOU_SHEN("受生", "义"), // 宫生门 -- 义
  SHENG_GONG("生宫", "和"), // 门生宫 -- 和
  SHENG_WANG("生旺", "旺"),
  XIE_QI("泄气", "泄"),
  BI_HE("比和", "比");

  final String name;
  final String singleCharName;
  const GongAndDoorRelationship(this.name, this.singleCharName);

  static Map<EightDoorEnum, List<String>> _mapper = {
    EightDoorEnum.KAI: ["伏吟", "小吉", "入墓", "门迫", "反吟", "受制", "大吉", "大吉"],
    EightDoorEnum.XIU: ["大吉", "伏吟", "受制", "小吉", "入墓", "反吟", "受制", "大吉"],
    EightDoorEnum.SHENG: ["小吉", "门迫", "伏吟", "受制", "入墓", "大吉", "反吟", "小吉"],
    EightDoorEnum.SHANG: ["受制", "大凶", "门迫", "伏吟", "小凶", "泄气", "入墓", "反吟"],
    EightDoorEnum.DU: ["反吟", "受生", "门迫", "比和", "伏吟", "泄气", "入墓", "受制"],
    EightDoorEnum.JING_S: ["入墓", "反吟", "生宫", "生旺", "生旺", "伏吟", "生宫", "门迫"],
    EightDoorEnum.SI: ["生宫", "门迫", "反吟", "受制", "入墓", "大凶", "伏吟", "生宫"],
    EightDoorEnum.JING_W: ["比和", "泄气", "入墓", "反吟", "门迫", "受制", "受生", "伏吟"],
  };

  static List<HouTianGua> _gongOrderedList = [
    HouTianGua.Qian,
    HouTianGua.Kan,
    HouTianGua.Gen,
    HouTianGua.Zhen,
    HouTianGua.Xun,
    HouTianGua.Li,
    HouTianGua.Kun,
    HouTianGua.Dui,
  ];

  // 根据name返回
  static GongAndDoorRelationship fromName(String name) =>
      values.firstWhere((e) => e.name == name);

  static GongAndDoorRelationship? getRelationship(
      EightDoorEnum door, HouTianGua gong) {
    return _mapper[door] == null || gong == HouTianGua.Center
        ? null
        : fromName(_mapper[door]![_gongOrderedList.indexOf(gong)]);
  }
}
