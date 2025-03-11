import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

import 'enum_fu_fan_yin.dart';

enum NineStarsEnum {
  @JsonValue("天蓬")
  PENG(1, "天蓬", "蓬", FiveXing.SHUI, YinYang.YANG, HouTianGua.Kan),
  @JsonValue("天任")
  REN(8, "天任", "任", FiveXing.TU, YinYang.YANG, HouTianGua.Gen),
  @JsonValue("天冲")
  CHONG(3, "天冲", "冲", FiveXing.MU, YinYang.YANG, HouTianGua.Zhen),
  @JsonValue("天辅")
  FU(4, "天辅", "辅", FiveXing.MU, YinYang.YIN, HouTianGua.Xun),
  @JsonValue("天英")
  YING(9, "天英", "英", FiveXing.HUO, YinYang.YIN, HouTianGua.Li), // 南方 用South
  @JsonValue("天芮")
  RUI(2, "天芮", "芮", FiveXing.TU, YinYang.YIN, HouTianGua.Kun),
  @JsonValue("天柱")
  ZHU(7, "天柱", "柱", FiveXing.JIN, YinYang.YIN, HouTianGua.Dui), // 西方，用West
  @JsonValue("天心")
  XIN(6, "天心", "心", FiveXing.JIN, YinYang.YANG, HouTianGua.Qian),
  @JsonValue("天禽")
  QIN(5, "天禽", "禽", FiveXing.TU, YinYang.YIN,
      HouTianGua.Kun); // 没有阴阳是 天芮星与天任星合体，相较于其他九星 属阴

  final String name;
  final int number;
  final String singleCharName;
  final FiveXing fiveXing;
  final YinYang yinyang;
  final HouTianGua originalGong;
  const NineStarsEnum(this.number, this.name, this.singleCharName,
      this.fiveXing, this.yinyang, this.originalGong);

  static NineStarsEnum fromNumber(int number) =>
      values.firstWhere((e) => e.number == number);
  static NineStarsEnum fromName(String name) =>
      values.firstWhere((e) => e.name == name);
  static NineStarsEnum fromSingleCharName(String name) =>
      values.firstWhere((e) => e.name.startsWith(name));

  // 1.蓬，2. 芮，3.冲，4.辅，5.禽，6.心，7.柱，8.任，9.英
  static List<NineStarsEnum> get listFeiPanOrderedByGongNumber =>
      [PENG, RUI, CHONG, FU, QIN, XIN, ZHU, REN, YING];
  // 按照顺时针顺序，返回‘蓬任冲辅英芮柱心’ 不包含‘天禽星’
  static List<NineStarsEnum> get listOrderedByClockwiseWithoutYing =>
      [PENG, REN, CHONG, FU, YING, RUI, ZHU, XIN];
  static Map<int, NineStarsEnum> get mapNumberToEnum =>
      Map.fromEntries(values.map((e) => MapEntry(e.number, e)));

  /// 使用宫内地支主气，四维宫阴阳遁取不同地支
  NineStarStatusEnum checkWithGongGua(HouTianGua gong) {
    return checkWithFiveXing(gong.fiveXing);
  }

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
      default:
        break;
    }

    return isFanYin ? FuFanYinEnum.Fan_Yin : FuFanYinEnum.Not;
  }

  /// 使用宫卦五行
  NineStarStatusEnum checkWithGongNeiDiZhi(
      HouTianGua gong, YinYang yinYangDun, JiaZi shiJiaZi, GongTypeEnum type) {
    if (gong.isZheng) {
      return checkWithFiveXing(gong.diZhi1.fiveXing);
    } else {
      switch (type) {
        case GongTypeEnum.YIN_YANG_DUN:
          return checkWithGongDiZhiByYinYangDun(gong, yinYangDun);
        case GongTypeEnum.SHI_GAN_YIN_YANG:
          return checkWithGongDiZhiByShiZhi(shiJiaZi, gong);
        case GongTypeEnum.GONG_GUA:
          return checkWithFiveXing(gong.fiveXing);
        default:
          throw ArgumentError("当前只支持 阴阳遁 与 时干阴阳 以及宫卦五行");
      }
    }
  }

  /// 根据阴阳遁分阴阳宫，取宫主事地支
  NineStarStatusEnum checkWithGongDiZhiByYinYangDun(
      HouTianGua gong, YinYang yinYangDun) {
    // 主事地支，分阴阳遁 以及 阴阳宫，如：
    // 1.阳遁时：
    //    a. 阳宫，艮宫主事为“寅”，巽宫主事为“巳”
    //    b. 阴宫，坤宫主事为“未”，乾宫主事为“戌”
    // 2.阴遁时：正与阳遁相反
    //    a. 阳宫，艮宫主事为“丑”，巽宫主事为“辰”
    //    b. 阴宫，坤宫主事为“申”，乾宫主事为“亥”
    if (yinYangDun.isYang) {
      if (gong == HouTianGua.Gen) {
        return checkWithFiveXing(DiZhi.YIN.fiveXing);
      } else if (gong == HouTianGua.Xun) {
        return checkWithFiveXing(DiZhi.SI.fiveXing);
      } else if (gong == HouTianGua.Kun) {
        return checkWithFiveXing(DiZhi.WEI.fiveXing);
      } else if (gong == HouTianGua.Qian) {
        return checkWithFiveXing(DiZhi.XU.fiveXing);
      }
    } else {
      if (gong == HouTianGua.Gen) {
        return checkWithFiveXing(DiZhi.CHOU.fiveXing);
      } else if (gong == HouTianGua.Xun) {
        return checkWithFiveXing(DiZhi.CHEN.fiveXing);
      } else if (gong == HouTianGua.Kun) {
        return checkWithFiveXing(DiZhi.SHEN.fiveXing);
      } else if (gong == HouTianGua.Qian) {
        return checkWithFiveXing(DiZhi.HAI.fiveXing);
      }
    }
    return NineStarStatusEnum.FEI;
  }

  /// 四维宫旺衰判断二 时干为阳只论奇仪在阳支的状态；时干为阴时，只论阴支的状态
  NineStarStatusEnum checkWithGongDiZhiByShiZhi(
      JiaZi shiJiaZi, HouTianGua gong) {
    if (shiJiaZi.tianGan.isYang) {
      DiZhi yangZhi = {gong.diZhi1, gong.diZhi2!}.firstWhere((d) => d.isYang);
      return checkWithFiveXing(yangZhi.fiveXing);
    } else {
      DiZhi yangZhi = {gong.diZhi1, gong.diZhi2!}.firstWhere((d) => d.isYin);
      return checkWithFiveXing(yangZhi.fiveXing);
    }
  }

  /// 使用月令地支
  NineStarStatusEnum checkWithMonthToken(MonthToken token) {
    // 《烟波掉搜歌》
    return checkWithFiveXing(token.diZhi.fiveXing);
  }

  /// 根据月令 主气去天干 纳卦五行
  NineStarStatusEnum checkWithMonthTokenNaGua(MonthToken token) {
    return checkWithFiveXing(
        HouTianGua.getGuaByName(token.majorQi.naJiaGua).fiveXing);
  }

  NineStarStatusEnum checkWithFiveXing(FiveXing guaFiveXing) {
    // 《烟波掉搜歌》
    // 与我同行即为相，我生之月诚为旺，废于父母休于财，囚于鬼兮真不妄。
    FiveXingRelationship relationship =
        FiveXingRelationship.checkRelationship(fiveXing, guaFiveXing)!;
    if (relationship == FiveXingRelationship.XIE) {
      return NineStarStatusEnum.WANG;
    } else if (relationship == FiveXingRelationship.SHENG) {
      return NineStarStatusEnum.FEI;
    } else if (relationship == FiveXingRelationship.HAO) {
      return NineStarStatusEnum.XIU;
    } else if (relationship == FiveXingRelationship.KE) {
      return NineStarStatusEnum.QIU;
    } else {
      return NineStarStatusEnum.XIANG;
    }
  }
}

enum NineStarStatusEnum {
  // 九星是天上的星体，没有“死”，但有废
  WANG("旺"), // 旺
  XIANG("相"), // 相
  FEI("废"), // 废，
  XIU("休"), // 休
  QIU("囚"); // 囚

  final String name;
  const NineStarStatusEnum(this.name);

  bool get isStrong => checkStrong(this);
  bool get isWeak => checkWeak(this);

  static bool checkWeak(NineStarStatusEnum wangShuai) {
    return [
      NineStarStatusEnum.XIU,
      NineStarStatusEnum.QIU,
      NineStarStatusEnum.FEI
    ].contains(wangShuai);
  }

  static bool checkStrong(NineStarStatusEnum wangShuai) {
    return [NineStarStatusEnum.WANG, NineStarStatusEnum.XIANG]
        .contains(wangShuai);
  }
}

enum GongTypeEnum {
  // 取宫内地支的方法
  GONG_GUA("宫卦"),
  YIN_YANG_DUN("阴阳遁"),
  SHI_GAN_YIN_YANG("时干");

  final String name;
  const GongTypeEnum(this.name);
}

enum GanGongTypeEnum {
  // ONLY_MU("只论墓"),  // 四维宫只论墓
  WANG_MU("旺墓"), // 有旺则论旺，有墓则论墓
  YIN_YANG_DUN("阴阳遁"), // 根据阴阳遁，确定四维宫
  SHI_GAN_YIN_YANG("时干"); // 根据时干阴阳，确定四维宫

  final String name;
  const GanGongTypeEnum(this.name);
}

enum MonthTokenTypeEnum {
  ZHU_QI("月令主气"), // 主气
  ZHU_QI_NA_GUA("主气纳卦"); // 主气纳卦

  final String name;
  const MonthTokenTypeEnum(this.name);
}

enum GodWithGongTypeEnum {
  GONG_GUA_ONLY("八宫卦"), // 八神与宫卦论旺衰
  DI_PAN_GAN_NA_GUA("地盘纳卦"); // 八神与地盘干的纳卦论生克旺衰

  final String name;
  const GodWithGongTypeEnum(this.name);
}
