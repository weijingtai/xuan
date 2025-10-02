import 'package:common/enums.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_eight_door.dart';
import '../enums/enum_nine_stars.dart';
import '../model/ConstantQiMenNineGongDataClass.dart';
import '../model/shi_jia_qi_men.dart';

class ConstantResourcesOfQiMen {
  static final Map<HouTianGua, ConstantQiMenNineGongDataClass>
      defaultGongMapper = {
    HouTianGua.Qian: ConstantQiMenNineGongDataClass(
        NineStarsEnum.XIN,
        EightDoorEnum.KAI,
        const Tuple3("立冬", "小雪", "大雪"),
        "乾",
        "陆",
        const Tuple2("戌", "亥"),
        tianMenDiHu: "天门"),
    HouTianGua.Kan: ConstantQiMenNineGongDataClass(
        NineStarsEnum.PENG,
        EightDoorEnum.XIU,
        const Tuple3("冬至", "小寒", "大寒"),
        "坎",
        "壹",
        const Tuple2("子", null)),
    HouTianGua.Gen: ConstantQiMenNineGongDataClass(
        NineStarsEnum.REN,
        EightDoorEnum.SHENG,
        const Tuple3("立春", "雨水", "惊蛰"),
        "艮",
        "捌",
        const Tuple2("丑", "寅"),
        tianMenDiHu: "鬼方"),
    HouTianGua.Dui: ConstantQiMenNineGongDataClass(
        NineStarsEnum.ZHU,
        EightDoorEnum.JING_W,
        const Tuple3("秋分", "寒露", "霜降"),
        "兑",
        "柒",
        const Tuple2("酉", null)),
    HouTianGua.Xun: ConstantQiMenNineGongDataClass(
        NineStarsEnum.FU,
        EightDoorEnum.DU,
        const Tuple3("立夏", "小满", "芒种"),
        "巽",
        "肆",
        const Tuple2("辰", "巳"),
        tianMenDiHu: "地户"),
    HouTianGua.Li: ConstantQiMenNineGongDataClass(
        NineStarsEnum.YING,
        EightDoorEnum.JING_S,
        const Tuple3("夏至", "小暑", "大暑"),
        "离",
        "玖",
        const Tuple2("午", null)),
    HouTianGua.Kun: ConstantQiMenNineGongDataClass(
        NineStarsEnum.RUI,
        EightDoorEnum.SI,
        const Tuple3("立秋", "处暑", "白露"),
        "坤",
        "贰",
        const Tuple2("未", "申"),
        tianMenDiHu: "人路"),
    HouTianGua.Zhen: ConstantQiMenNineGongDataClass(
        NineStarsEnum.CHONG,
        EightDoorEnum.SHANG,
        const Tuple3("春分", "清明", "谷雨"),
        "震",
        "叁",
        const Tuple2("卯", null)),
  };

  static final Map<CenterGongJiGongType, String> hitCenterGongJiGongMapper = {
    CenterGongJiGongType.ONLY_KUN_GONG: "只在坤宫",
    CenterGongJiGongType.KUN_GEN_GONG: "阴遁坤二宫，阳遁艮八宫",
    CenterGongJiGongType.FOUR_WEI_GONG: "四季寄四维宫",
    CenterGongJiGongType.EIGTH_GONG: "八节寄八宫"
    // CenterGongJiGong.FOUR_WEI_GONG:"立春艮宫，立夏巽宫，立秋坤宫，立冬乾宫",
    // CenterGongJiGong.EIGTH_GONG:"立春艮，春分震，立夏巽，夏至离，立秋坤，秋分兑，立冬乾，冬至坎"
    // 春分、清明、谷雨（震三宫），
    // 立夏、小满、芒种（巽四宫），
    // 夏至、小暑、大暑（离九宫），
    // 立秋、处暑、白露（坤二宫），
    // 秋分、寒露、霜降（兑七宫），
    // 立冬、小雪、大雪（乾六宫），
    // 冬至、小寒、大寒（坎一宫）
  };

  static final Map<MonthTokenTypeEnum, String> monthTokenHintMapper = {
    MonthTokenTypeEnum.ZHU_QI: "月令天干",
    MonthTokenTypeEnum.ZHU_QI_NA_GUA: "月令主气天干的纳卦"
  };
  static final Map<GodWithGongTypeEnum, String> godWithGongTypeMapper = {
    GodWithGongTypeEnum.GONG_GUA_ONLY: "与八宫卦论生克旺衰",
    GodWithGongTypeEnum.DI_PAN_GAN_NA_GUA: "与地盘干的纳卦论生克旺衰"
  };

  static final Map<GongTypeEnum, String> gongTypeMapper = {
    GongTypeEnum.GONG_GUA: "与八宫卦论生克旺衰",
    GongTypeEnum.YIN_YANG_DUN: "四维宫：阳遁，艮寅巽巳，坤未乾戌；阴遁，艮丑巽辰，坤申乾亥。",
    GongTypeEnum.SHI_GAN_YIN_YANG: "四维宫：阳时干，取阳支；阴时干，取阴支"
  };

  static final Map<GanGongTypeEnum, String> ganGongTypeMapper = {
    // GanGongTypeEnum.ONLY_MU: "四维宫论墓：丙乾丁艮乙乾坤，戊六己庚八，辛壬四癸二",
    GanGongTypeEnum.WANG_MU: "有旺先论旺，有墓先论墓",
    GanGongTypeEnum.YIN_YANG_DUN: "四维宫：阳遁，艮寅巽巳，坤未乾戌；阴遁，艮丑巽辰，坤申乾亥。",
    GanGongTypeEnum.SHI_GAN_YIN_YANG: "四维宫：阳时干，取阳支；阴时干，取阴支"
  };
}
