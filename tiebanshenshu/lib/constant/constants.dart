import 'dart:core';

import 'package:common/enums.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/features/six_yao_gua/enum_6_shou.dart';

import '../features/six_yao_gua/enum_8_gong_gua.dart';

Map<TianGan, Map<EnumYaoOrder, Enum6Shou>> ganSixShouMapper = {
  TianGan.JIA: {
    EnumYaoOrder.init: Enum6Shou.qingLong,
    EnumYaoOrder.second: Enum6Shou.zhuQue,
    EnumYaoOrder.third: Enum6Shou.gouChen,
    EnumYaoOrder.fourth: Enum6Shou.tengShe,
    EnumYaoOrder.fifth: Enum6Shou.baiHu,
    EnumYaoOrder.top: Enum6Shou.xuanWu,
  },
  TianGan.YI: {
    EnumYaoOrder.init: Enum6Shou.qingLong,
    EnumYaoOrder.second: Enum6Shou.zhuQue,
    EnumYaoOrder.third: Enum6Shou.gouChen,
    EnumYaoOrder.fourth: Enum6Shou.tengShe,
    EnumYaoOrder.fifth: Enum6Shou.baiHu,
    EnumYaoOrder.top: Enum6Shou.xuanWu,
  },
  TianGan.BING: {
    EnumYaoOrder.init: Enum6Shou.zhuQue,
    EnumYaoOrder.second: Enum6Shou.gouChen,
    EnumYaoOrder.third: Enum6Shou.tengShe,
    EnumYaoOrder.fourth: Enum6Shou.baiHu,
    EnumYaoOrder.fifth: Enum6Shou.xuanWu,
    EnumYaoOrder.top: Enum6Shou.qingLong,
  },
  TianGan.DING: {
    EnumYaoOrder.init: Enum6Shou.zhuQue,
    EnumYaoOrder.second: Enum6Shou.gouChen,
    EnumYaoOrder.third: Enum6Shou.tengShe,
    EnumYaoOrder.fourth: Enum6Shou.baiHu,
    EnumYaoOrder.fifth: Enum6Shou.xuanWu,
    EnumYaoOrder.top: Enum6Shou.qingLong,
  },
  TianGan.WU: {
    EnumYaoOrder.init: Enum6Shou.gouChen,
    EnumYaoOrder.second: Enum6Shou.tengShe,
    EnumYaoOrder.third: Enum6Shou.baiHu,
    EnumYaoOrder.fourth: Enum6Shou.xuanWu,
    EnumYaoOrder.fifth: Enum6Shou.qingLong,
    EnumYaoOrder.top: Enum6Shou.zhuQue,
  },
  TianGan.JI: {
    EnumYaoOrder.init: Enum6Shou.tengShe,
    EnumYaoOrder.second: Enum6Shou.baiHu,
    EnumYaoOrder.third: Enum6Shou.xuanWu,
    EnumYaoOrder.fourth: Enum6Shou.qingLong,
    EnumYaoOrder.fifth: Enum6Shou.zhuQue,
    EnumYaoOrder.top: Enum6Shou.gouChen,
  },
  TianGan.GENG: {
    EnumYaoOrder.init: Enum6Shou.baiHu,
    EnumYaoOrder.second: Enum6Shou.xuanWu,
    EnumYaoOrder.third: Enum6Shou.qingLong,
    EnumYaoOrder.fourth: Enum6Shou.zhuQue,
    EnumYaoOrder.fifth: Enum6Shou.gouChen,
    EnumYaoOrder.top: Enum6Shou.tengShe,
  },

  TianGan.XIN: {
    EnumYaoOrder.init: Enum6Shou.baiHu,
    EnumYaoOrder.second: Enum6Shou.xuanWu,
    EnumYaoOrder.third: Enum6Shou.qingLong,
    EnumYaoOrder.fourth: Enum6Shou.zhuQue,
    EnumYaoOrder.fifth: Enum6Shou.gouChen,
    EnumYaoOrder.top: Enum6Shou.tengShe,
  },
  TianGan.REN: {
    EnumYaoOrder.init: Enum6Shou.xuanWu,
    EnumYaoOrder.second: Enum6Shou.qingLong,
    EnumYaoOrder.third: Enum6Shou.zhuQue,
    EnumYaoOrder.fourth: Enum6Shou.gouChen,
    EnumYaoOrder.fifth: Enum6Shou.tengShe,
    EnumYaoOrder.top: Enum6Shou.baiHu,
  },
  TianGan.GUI: {
    EnumYaoOrder.init: Enum6Shou.xuanWu,
    EnumYaoOrder.second: Enum6Shou.qingLong,
    EnumYaoOrder.third: Enum6Shou.zhuQue,
    EnumYaoOrder.fourth: Enum6Shou.gouChen,
    EnumYaoOrder.fifth: Enum6Shou.tengShe,
    EnumYaoOrder.top: Enum6Shou.baiHu,
  },
};

// 二进制str转八经卦
const Map<String, String> binaryStrGuaMapper = {
  "111": "乾",
  "000": "坤",
  "100": "艮",
  "110": "巽",
  "001": "震",
  "011": "兑",
  "101": "离",
  "010": "坎",
};

// 世爻 (从下往上, 0为上爻，5为初爻 [上，初，二，三，四，五，四，三])
const List<int> shiYao = [0, 5, 4, 3, 2, 1, 2, 3];

// 应爻 (从下往上, 0为上爻，5为初爻 [三，四，五，上，初，二，初，上])
const List<int> yiYao = [2, 3, 4, 0, 5, 4, 5, 0];

// 宫卦顺序名称
const List<String> gongGuaName = [
  "本卦",
  "一世",
  "二世",
  "三世",
  "四世",
  "五世",
  "游魂",
  "归魂",
];
const List<Enum8GongGuaName> gongGuaNameList = [
  Enum8GongGuaName.BenGua,
  Enum8GongGuaName.YiShi,
  Enum8GongGuaName.ErShi,
  Enum8GongGuaName.SanShi,
  Enum8GongGuaName.WuShi,
  Enum8GongGuaName.YouHun,
  Enum8GongGuaName.GuiHun,
];

const Map<Enum8Gua, List<Enum64Gua>> eightGongGuaListMapper = {
  Enum8Gua.Qian: [
    Enum64Gua.qian_wei_tian,
    Enum64Gua.tian_feng_gou,
    Enum64Gua.tian_shan_dun,
    Enum64Gua.tian_di_pi,
    Enum64Gua.feng_di_guan,
    Enum64Gua.shan_di_bo,
    Enum64Gua.huo_di_jin,
    Enum64Gua.huo_tian_da_you,
  ],
  Enum8Gua.Zhen: [
    Enum64Gua.zhen_wei_lei,
    Enum64Gua.lei_di_yu,
    Enum64Gua.lei_shui_jie,
    Enum64Gua.lei_feng_heng,
    Enum64Gua.di_feng_sheng,
    Enum64Gua.shui_feng_jing,
    Enum64Gua.ze_feng_da_guo,
    Enum64Gua.ze_lei_sui,
  ],
  Enum8Gua.Kan: [
    Enum64Gua.kan_wei_shui,
    Enum64Gua.shui_ze_jie,
    Enum64Gua.shui_lei_tun,
    Enum64Gua.shui_huo_ji_ji,
    Enum64Gua.ze_huo_ge,
    Enum64Gua.lei_huo_feng,
    Enum64Gua.di_huo_ming_yi,
    Enum64Gua.di_shui_shi,
  ],
  Enum8Gua.Gen: [
    Enum64Gua.gen_wei_shan,
    Enum64Gua.shan_huo_bi,
    Enum64Gua.shan_tian_da_xu,
    Enum64Gua.shan_ze_sun,
    Enum64Gua.huo_ze_kui,
    Enum64Gua.tian_ze_lv,
    Enum64Gua.feng_ze_zhong_fu,
    Enum64Gua.feng_shan_jian,
  ],
  Enum8Gua.Kun: [
    Enum64Gua.kun_wei_di,
    Enum64Gua.di_lei_fu,
    Enum64Gua.di_ze_lin,
    Enum64Gua.di_tian_tai,
    Enum64Gua.lei_tian_da_zhuang,
    Enum64Gua.ze_tian_guai,
    Enum64Gua.shui_tian_xu,
    Enum64Gua.shui_di_bi,
  ],
  Enum8Gua.Xun: [
    Enum64Gua.xun_wei_feng,
    Enum64Gua.feng_tian_xiao_xu,
    Enum64Gua.feng_huo_jia_ren,
    Enum64Gua.feng_lei_yi,
    Enum64Gua.tian_lei_wu_wang,
    Enum64Gua.huo_lei_shi_he,
    Enum64Gua.shan_lei_yi,
    Enum64Gua.shan_feng_gu,
  ],
  Enum8Gua.Li: [
    Enum64Gua.li_wei_huo,
    Enum64Gua.huo_shan_lv,
    Enum64Gua.huo_feng_ding,
    Enum64Gua.huo_shui_wei_ji,
    Enum64Gua.shan_shui_meng,
    Enum64Gua.feng_shui_huan,
    Enum64Gua.tian_shui_song,
    Enum64Gua.tian_huo_tong_ren,
  ],
  Enum8Gua.Dui: [
    Enum64Gua.dui_wei_ze,
    Enum64Gua.ze_shui_kun,
    Enum64Gua.ze_di_cui,
    Enum64Gua.ze_shan_xian,
    Enum64Gua.shui_shan_jian,
    Enum64Gua.di_shan_qian,
    Enum64Gua.lei_shan_xiao_gu,
    Enum64Gua.lei_ze_gui_mei,
  ],
};

const Map<FiveXing, Map<FiveXing, LiuQin>> fiveXingSixQingMapper = {
  FiveXing.JIN: {
    FiveXing.JIN: LiuQin.XIONG_DI,
    FiveXing.MU: LiuQin.QI_CAI,
    FiveXing.SHUI: LiuQin.ZI_SUN,
    FiveXing.HUO: LiuQin.GUAN_GUI,
    FiveXing.TU: LiuQin.FU_MU,
  },
  FiveXing.MU: {
    FiveXing.MU: LiuQin.XIONG_DI,
    FiveXing.TU: LiuQin.QI_CAI,
    FiveXing.HUO: LiuQin.ZI_SUN,
    FiveXing.JIN: LiuQin.GUAN_GUI,
    FiveXing.SHUI: LiuQin.FU_MU,
  },
  FiveXing.SHUI: {
    FiveXing.SHUI: LiuQin.XIONG_DI,
    FiveXing.HUO: LiuQin.QI_CAI,
    FiveXing.MU: LiuQin.ZI_SUN,
    FiveXing.TU: LiuQin.GUAN_GUI,
    FiveXing.JIN: LiuQin.FU_MU,
  },
  FiveXing.HUO: {
    FiveXing.HUO: LiuQin.XIONG_DI,
    FiveXing.JIN: LiuQin.QI_CAI,
    FiveXing.TU: LiuQin.ZI_SUN,
    FiveXing.SHUI: LiuQin.GUAN_GUI,
    FiveXing.MU: LiuQin.FU_MU,
  },
  FiveXing.TU: {
    FiveXing.TU: LiuQin.XIONG_DI,
    FiveXing.SHUI: LiuQin.QI_CAI,
    FiveXing.JIN: LiuQin.ZI_SUN,
    FiveXing.MU: LiuQin.GUAN_GUI,
    FiveXing.HUO: LiuQin.FU_MU,
  },
};

const Map<String, List<String>> guaNameEightGongMapper = {
  "乾": ["乾", "姤", "遁", "否", "观", "剥", "晋", "大有"],
  "震": ["震", "豫", "解", "恒", "升", "井", "大过", "随"],
  "坎": ["坎", "节", "屯", "既济", "革", "丰", "明夷", "师"],
  "艮": ["艮", "贲", "大畜", "损", "睽", "履", "中孚", "渐"],
  "坤": ["坤", "复", "临", "泰", "大壮", "夬", "需", "比"],
  "巽": ["巽", "小畜", "家人", "益", "无妄", "噬嗑", "颐", "蛊"],
  "离": ["离", "旅", "鼎", "未济", "蒙", "涣", "讼", "同人"],
  "兑": ["兑", "困", "萃", "咸", "蹇", "谦", "小过", "归妹"],
};

const Map<String, bool> tianGanYinYangMapper = {
  '甲': true,
  '壬': true,
  "乙": false,
  "癸": false,
  "丙": true,
  "丁": false,
  "戊": true,
  "己": false,
  "庚": true,
  "辛": false,
};

const Map<String, Map<String, String>> fivexingLiuqingMapper = {
  "金": {"金": "兄弟", "木": "妻财", "水": "子孙", "火": "官鬼", "土": "父母"},
  "木": {"木": "兄弟", "土": "妻财", "火": "子孙", "金": "官鬼", "水": "父母"},
  "水": {"水": "兄弟", "火": "妻财", "木": "子孙", "土": "官鬼", "金": "父母"},
  "火": {"火": "兄弟", "金": "妻财", "土": "子孙", "水": "官鬼", "木": "父母"},
  "土": {"土": "兄弟", "水": "妻财", "金": "子孙", "木": "官鬼", "火": "父母"},
};

const Map<String, String> guaFivexingMapper = {
  "坎": "水",
  "坤": "土",
  "震": "木",
  "巽": "木",
  "乾": "金",
  "兑": "金",
  "艮": "土",
  "离": "火",
};

const Map<String, String> dizhiFivexingMapper = {
  "子": "水",
  "亥": "水",
  "丑": "土",
  "寅": "木",
  "卯": "木",
  "辰": "土",
  "巳": "火",
  "午": "火",
  "未": "土",
  "申": "金",
  "酉": "金",
  "戌": "土",
};

Map<DiZhi, Enum8Gua> diZhiGuaMapper = {
  DiZhi.getFromValue("子")!: Enum8Gua.fromValue("坎")!,
  DiZhi.getFromValue("亥")!: Enum8Gua.fromValue("坎")!,
  DiZhi.getFromValue("丑")!: Enum8Gua.fromValue("坤")!,
  DiZhi.getFromValue("寅")!: Enum8Gua.fromValue("震")!,
  DiZhi.getFromValue("卯")!: Enum8Gua.fromValue("乾")!,
  DiZhi.getFromValue("辰")!: Enum8Gua.fromValue("兑")!,
  DiZhi.getFromValue("巳")!: Enum8Gua.fromValue("离")!,
  DiZhi.getFromValue("午")!: Enum8Gua.fromValue("离")!,
  DiZhi.getFromValue("未")!: Enum8Gua.fromValue("艮")!,
  DiZhi.getFromValue("申")!: Enum8Gua.fromValue("乾")!,
  DiZhi.getFromValue("酉")!: Enum8Gua.fromValue("乾")!,
  DiZhi.getFromValue("戌")!: Enum8Gua.fromValue("巽")!,
};
Map<TianGan, Enum8Gua> tianGanGuaMapper = {
  TianGan.getFromValue('甲')!: Enum8Gua.fromValue("乾")!,
  TianGan.getFromValue('壬')!: Enum8Gua.fromValue("乾")!,
  TianGan.getFromValue("乙")!: Enum8Gua.fromValue("坤")!,
  TianGan.getFromValue("癸")!: Enum8Gua.fromValue("坤")!,
  TianGan.getFromValue("丙")!: Enum8Gua.fromValue("艮")!,
  TianGan.getFromValue("丁")!: Enum8Gua.fromValue("兑")!,
  TianGan.getFromValue("戊")!: Enum8Gua.fromValue("坎")!,
  TianGan.getFromValue("己")!: Enum8Gua.fromValue("离")!,
  TianGan.getFromValue("庚")!: Enum8Gua.fromValue("震")!,
  TianGan.getFromValue("辛")!: Enum8Gua.fromValue("巽")!,
};
const Map<TianGan, int> fourZhuTianGanNumberMapper = {
  TianGan.JIA: 1,
  TianGan.YI: 6,
  TianGan.BING: 2,
  TianGan.DING: 7,
  TianGan.WU: 3,
  TianGan.JI: 8,
  TianGan.GENG: 4,
  TianGan.XIN: 9,
  TianGan.REN: 5,
  TianGan.GUI: 0,
};

const Map<String, String> dizhiGuaMapper = {
  "子": "坎",
  "亥": "坎",
  "丑": "坤",
  "寅": "震",
  "卯": "乾",
  "辰": "兑",
  "巳": "离",
  "午": "离",
  "未": "艮",
  "申": "乾",
  "酉": "乾",
  "戌": "巽",
};

const Map<String, List<String>> guaDizhiMapper = {
  "坎": ["子", "亥"],
  "坤": ["丑"],
  "震": ["寅", "卯"],
  "兑": ["辰"],
  "离": ["巳", "午"],
  "艮": ["未"],
  "乾": ["申", "酉"],
  "巽": ["戌"],
};

const Map<String, String> tianganGuaMapper = {
  '甲': "乾",
  '壬': "乾",
  "乙": "坤",
  "癸": "坤",
  "丙": "艮",
  "丁": "兑",
  "戊": "坎",
  "己": "离",
  "庚": "震",
  "辛": "巽",
};

const Map<String, List<String>> guaTianganMapper = {
  "乾": ["甲", "壬"],
  "坤": ["乙", "癸"],
  "艮": ["丙"],
  "兑": ["丁"],
  "坎": ["戊"],
  "离": ["己"],
  "震": ["庚"],
  "巽": ["辛"],
};

const Set<String> yangGua = {"乾", "震", "坎", "艮"};
const Set<String> yinGua = {"坤", "巽", "离", "兑"};
const List<String> yangZhi = ["子", "寅", "辰", "午", "申", "戌"];
const List<String> yinZhi = ["丑", "卯", "巳", "未", "酉", "亥"];

const Map<String, int> dizhiNumberMapper = {
  "子": 30,
  "丑": 30,
  "寅": 60,
  "卯": 60,
  "辰": 90,
  "巳": 90,
  "午": 120,
  "未": 120,
  "申": 150,
  "酉": 150,
  "戌": 180,
  "亥": 180,
};
Map<DiZhi, int> yaoDiZhiNumberMapper = {
  DiZhi.getFromValue("子")!: 30,
  DiZhi.getFromValue("丑")!: 30,
  DiZhi.getFromValue("寅")!: 60,
  DiZhi.getFromValue("卯")!: 60,
  DiZhi.getFromValue("辰")!: 90,
  DiZhi.getFromValue("巳")!: 90,
  DiZhi.getFromValue("午")!: 120,
  DiZhi.getFromValue("未")!: 120,
  DiZhi.getFromValue("申")!: 150,
  DiZhi.getFromValue("酉")!: 150,
  DiZhi.getFromValue("戌")!: 180,
  DiZhi.getFromValue("亥")!: 180,
};

Map<int, Enum8Gua> yuanTangHuaTianNumberGuaMapper = {
  1: Enum8Gua.fromValue("坎")!,
  2: Enum8Gua.fromValue("坤")!,
  3: Enum8Gua.fromValue("震")!,
  4: Enum8Gua.fromValue("巽")!,
  6: Enum8Gua.fromValue("乾")!,
  7: Enum8Gua.fromValue("兑")!,
  8: Enum8Gua.fromValue("艮")!,
  9: Enum8Gua.fromValue("离")!,
};
const Map<int, String> yuantangHuaTianNumberGuaMapper = {
  1: "坎",
  2: "坤",
  3: "震",
  4: "巽",
  6: "乾",
  7: "兑",
  8: "艮",
  9: "离",
};
const Map<int, String> houTianNumberGuaMapper = {
  0: "坤",
  1: "坎",
  2: "坤",
  3: "震",
  4: "巽",
  5: "艮",
  6: "乾",
  7: "兑",
  8: "艮",
  9: "离",
};

const Map<int, Enum8Gua> numberHouGuaMapper = {
  1: Enum8Gua.Kan,
  2: Enum8Gua.Kun,
  3: Enum8Gua.Zhen,
  4: Enum8Gua.Xun,
  6: Enum8Gua.Qian,
  7: Enum8Gua.Dui,
  8: Enum8Gua.Gen,
  9: Enum8Gua.Li,
};

const Map<int, Enum8Gua> numberXianGuaMapper = {
  1: Enum8Gua.Qian,
  2: Enum8Gua.Dui,
  3: Enum8Gua.Li,
  4: Enum8Gua.Zhen,
  5: Enum8Gua.Xun,
  6: Enum8Gua.Kan,
  7: Enum8Gua.Gen,
  8: Enum8Gua.Kun,
};

const Map<int, String> xianTianNumberGuaMapper = {
  1: "乾",
  2: "兑",
  3: "离",
  4: "震",
  5: "巽",
  6: "坎",
  7: "艮",
  8: "坤",
};

// 先天八卦位置，对照洛书，戴九履一
const Map<String, int> xiantianGuaLuoshuNumberMapper = {
  "乾": 9,
  "兑": 4,
  "离": 3,
  "震": 8,
  "巽": 2,
  "坎": 7,
  "艮": 6,
  "坤": 1,
};

// 后天八卦位置，对照洛书，戴九履一
const Map<String, int> houtianGuaLuoshuNumberMapper = {
  "坎": 1,
  "坤": 2,
  "震": 3,
  "巽": 4,
  "乾": 6,
  "兑": 7,
  "艮": 8,
  "离": 9,
};

const Map<String, int> xianTianGuaNumberMapper = {
  "乾": 1,
  "兑": 2,
  "离": 3,
  "震": 4,
  "巽": 5,
  "坎": 6,
  "艮": 7,
  "坤": 8,
};

const Map<String, int> houTianGuaNumberMapper = {
  "坎": 1,
  "坤": 2,
  "震": 3,
  "巽": 4,
  "乾": 6,
  "兑": 7,
  "艮": 8,
  "离": 9,
};

Map<Enum8Gua, int> xianGuaNumberMapper = {
  Enum8Gua.Qian: 1,
  Enum8Gua.Dui: 2,
  Enum8Gua.Li: 3,
  Enum8Gua.Zhen: 4,
  Enum8Gua.Xun: 5,
  Enum8Gua.Kan: 6,
  Enum8Gua.Gen: 7,
  Enum8Gua.Kun: 8,
};

Map<Enum8Gua, int> houGuaNumberMapper = {
  Enum8Gua.Kan: 1,
  Enum8Gua.Kun: 2,
  Enum8Gua.Zhen: 3,
  Enum8Gua.Xun: 4,
  Enum8Gua.Qian: 6,
  Enum8Gua.Dui: 7,
  Enum8Gua.Gen: 8,
  Enum8Gua.Li: 9,
};

const Map<String, List<int>> guaBinaryMapper = {
  "乾": [1, 1, 1],
  "兑": [0, 1, 1],
  "离": [1, 0, 1],
  "震": [0, 0, 1],
  "巽": [1, 1, 0],
  "坎": [0, 1, 0],
  "艮": [1, 0, 0],
  "坤": [0, 0, 0],
};

// 根据给上下卦”号称“找到对应卦 如：”水天“->"需"
const Map<String, String> objectName2GuaNameMapper = {
  "天天": "乾",
  "天风": "姤",
  "天山": "遁",
  "天地": "否",
  "风地": "观",
  "山地": "剥",
  "火地": "晋",
  "火天": "大有",
  "雷雷": "震",
  "雷地": "豫",
  "雷水": "解",
  "雷风": "恒",
  "地风": "升",
  "水风": "井",
  "泽风": "大过",
  "泽雷": "随",
  "水水": "坎",
  "水泽": "节",
  "水雷": "屯",
  "水火": "既济",
  "泽火": "革",
  "雷火": "丰",
  "地火": "明夷",
  "地水": "师",
  "山山": "艮",
  "山火": "贲",
  "山天": "大畜",
  "山泽": "损",
  "火泽": "睽",
  "天泽": "履",
  "风泽": "中孚",
  "风山": "渐",
  "地地": "坤",
  "地雷": "复",
  "地泽": "临",
  "地天": "泰",
  "雷天": "大壮",
  "泽天": "夬",
  "水天": "需",
  "水地": "比",
  "风风": "巽",
  "风天": "小畜",
  "风火": "家人",
  "风雷": "益",
  "天雷": "无妄",
  "火雷": "噬嗑",
  "山雷": "颐",
  "山风": "蛊",
  "火火": "离",
  "火山": "旅",
  "火风": "鼎",
  "火水": "未济",
  "山水": "蒙",
  "风水": "涣",
  "天水": "讼",
  "天火": "同人",
  "泽泽": "兑",
  "泽水": "困",
  "泽地": "萃",
  "泽山": "咸",
  "水山": "蹇",
  "地山": "谦",
  "雷山": "小过",
  "雷泽": "归妹",
};

const Map<String, String> guaName2ObjectName = {
  "乾": "天",
  "兑": "泽",
  "离": "火",
  "震": "雷",
  "巽": "风",
  "坎": "水",
  "艮": "山",
  "坤": "地",
};

const String yangYao = "🟥🟥🟥🟥🟥🟥🟥🟥";
const String yinYao = "🟥🟥🟥    🟥🟥🟥";

// 斗甲乙宫数
const Map<String, List<int>> doujiayiMapper = {
  "子": [4192, 4382, 7400, 7353, 7112],
  "午": [4262, 7298, 7749, 7531, 4491],
  "卯": [7228, 4636, 7851, 4754, 4885],
  "酉": [7131, 4892, 4414, 7664, 4876],
  "辰": [7614, 8312, 8153, 5654, 8193],
  "戌": [5734, 2176, 5639, 8764, 8133],
  "丑": [5986, 8169, 8491, 5958, 8394],
  "未": [8416, 5889, 8877, 8532, 8487],
  "寅": [1545, 2524, 3936, 2016, 8555],
  "申": [3168, 1053, 2461, 1599, 5839],
  "巳": [5339, 6041, 6773, 7366, 7659],
  "亥": [2456, 3289, 4409, 5346, 6474],
};

// 八刻数表
const Map<String, List<int>> eightKeNumberMapper = {
  "子": [3543, 9585, 7545, 3675, 7656, 1907, 7086, 1008],
  "丑": [5365, 4003, 5993, 6374, 6777, 6981, 9665, 7068],
  "寅": [6349, 6576, 5303, 4867, 3336, 5004, 3652, 4638],
  "卯": [2172, 2375, 3877, 6505, 6758, 3768, 3568, 2506],
  "辰": [3798, 7937, 1005, 6707, 7056, 7556, 9565, 3666],
  "巳": [4435, 7467, 6186, 1857, 6981, 3076, 2167, 9205],
  "午": [3073, 5206, 7060, 5760, 3897, 1007, 1069, 9706],
  "未": [6887, 4778, 5367, 5378, 5378, 3006, 1167, 7786],
  "申": [3920, 6587, 3786, 4547, 7106, 6387, 3866, 6578],
  "酉": [1676, 6705, 7056, 5624, 6797, 3333, 4768, 7777],
  "戌": [1667, 1112, 9675, 6006, 9568, 2165, 3000, 5657],
  "亥": [2167, 5057, 2305, 4657, 3867, 3930, 6068, 7608],
};

const List<String> keNameList = [
  "一刻",
  "二刻",
  "三刻",
  "四刻",
  "五刻",
  "六刻",
  "七刻",
  "八刻",
];

// 乾宫甲流度
const Map<String, int> qianGongJiaLiuDuMapper = {
  "子": 9003,
  "午": 9303,
  "丑": 9053,
  "未": 9353,
  "寅": 9103,
  "申": 9403,
  "卯": 9153,
  "酉": 9453,
  "辰": 9203,
  "戌": 9503,
  "巳": 9253,
  "亥": 9553,
};

// 坤宫甲流度
const Map<String, int> kunGongJiaLiuDuMapper = {
  "子": 9605,
  "午": 9905,
  "丑": 9655,
  "未": 9955,
  "寅": 9705,
  "申": 10005,
  "卯": 9755,
  "酉": 10055,
  "辰": 9805,
  "戌": 10105,
  "巳": 9855,
  "亥": 10155,
};
const Map<TianGan, int> ganNumberMapper = {
  TianGan.JIA: 6,
  TianGan.YI: 2,
  TianGan.BING: 8,
  TianGan.DING: 7,
  TianGan.WU: 1,
  TianGan.JI: 9,
  TianGan.GENG: 3,
  TianGan.XIN: 4,
  TianGan.REN: 6,
  TianGan.GUI: 2,
};
const Map<DiZhi, List<int>> zhiNumberMapper = {
  DiZhi.ZI: [1, 6],
  DiZhi.CHOU: [5, 10],
  DiZhi.YIN: [3, 8],
  DiZhi.MAO: [3, 8],
  DiZhi.CHEN: [5, 10],
  DiZhi.SI: [7, 2],
  DiZhi.WU: [7, 2],
  DiZhi.WEI: [5, 10],
  DiZhi.SHEN: [9, 4],
  DiZhi.YOU: [9, 4],
  DiZhi.XU: [5, 10],
  DiZhi.HAI: [1, 6],
};

const Map<String, int> tianGanNumberMapper = {
  "甲": 6,
  "乙": 2,
  "丙": 8,
  "丁": 7,
  "戊": 1,
  "己": 9,
  "庚": 3,
  "辛": 4,
  "壬": 6,
  "癸": 2,
};

// 确保 [i]为”奇数“ [i]为”偶数“ 便于后续计算
const Map<String, List<int>> diZhiNumberMapper = {
  "子": [1, 6],
  "丑": [5, 10],
  "寅": [3, 8],
  "卯": [3, 8],
  "辰": [5, 10],
  "巳": [7, 2],
  "午": [7, 2],
  "未": [5, 10],
  "申": [9, 4],
  "酉": [9, 4],
  "戌": [5, 10],
  "亥": [1, 6],
};

const Map<String, int> diZhiFlatedNumberMapper = {
  "子": 6,
  "丑": 10,
  "寅": 3,
  "卯": 8,
  "辰": 5,
  "巳": 2,
  "午": 7,
  "未": 10,
  "申": 4,
  "酉": 9,
  "戌": 5,
  "亥": 1,
};

const Map<String, int> taixuanGanNumberMapper = {
  "甲": 9,
  "己": 9,
  "乙": 8,
  "庚": 8,
  "丙": 7,
  "辛": 7,
  "丁": 6,
  "壬": 6,
  "戊": 5,
  "癸": 5,
};
const Map<TianGan, int> taiXuanGanNumberMapper = {
  TianGan.JIA: 9,
  TianGan.JI: 9,
  TianGan.YI: 8,
  TianGan.GENG: 8,
  TianGan.BING: 7,
  TianGan.XIN: 7,
  TianGan.DING: 6,
  TianGan.REN: 6,
  TianGan.WU: 5,
  TianGan.GUI: 5,
};
const Map<DiZhi, int> taiXuanZhiNumberMapper = {
  DiZhi.ZI: 9,
  DiZhi.CHOU: 8,
  DiZhi.YIN: 7,
  DiZhi.MAO: 6,
  DiZhi.CHEN: 5,
  DiZhi.SI: 4,
  DiZhi.WU: 9,
  DiZhi.WEI: 8,
  DiZhi.SHEN: 7,
  DiZhi.YOU: 6,
  DiZhi.XU: 5,
  DiZhi.HAI: 4,
};
const Map<String, int> taixuanZhiNumberMapper = {
  "子": 9,
  "丑": 8,
  "寅": 7,
  "卯": 6,
  "辰": 5,
  "巳": 4,
  "午": 9,
  "未": 8,
  "申": 7,
  "酉": 6,
  "戌": 5,
  "亥": 4,
};

// Python:
// class EnumGanZhiNumberStrategy(Enum):
//     gan_zhi = 1
//     tai_xuan = 2
//     flated_gan_zhi = 3
enum EnumGanZhiNumberStrategy {
  // 对应原Python值 1
  ganZhi,
  // 对应原Python值 2
  taiXuan,
  // 对应原Python值 3
  flatedGanZhi,
}

// 八经卦对应的数相加就是 “《六十四卦基本数序表》” guaBasicNumberUponMapper + guaBasicNumberUponMapper
const Map<String, int> guaBasicNumberUponMapper = {
  "乾": 180,
  "兑": 720,
  "离": 1260,
  "震": 1800,
  "巽": 2340,
  "坎": 2880,
  "艮": 3420,
  "坤": 3960,
};

const Map<String, int> guaBasicNumberUnderMapper = {
  "乾": 450,
  "兑": 990,
  "离": 1530,
  "震": 2070,
  "巽": 2610,
  "坎": 3150,
  "艮": 3690,
  "坤": 4230,
};
const Map<Enum8Gua, List<DiZhi>> outerGuaYaoDiZhi = {
  Enum8Gua.Qian: [DiZhi.WU, DiZhi.SHEN, DiZhi.XU],
  Enum8Gua.Kun: [DiZhi.CHOU, DiZhi.HAI, DiZhi.YOU],
  Enum8Gua.Zhen: [DiZhi.WU, DiZhi.SHEN, DiZhi.XU],
  Enum8Gua.Xun: [DiZhi.WEI, DiZhi.SI, DiZhi.MAO],
  Enum8Gua.Kan: [DiZhi.SHEN, DiZhi.XU, DiZhi.ZI],
  Enum8Gua.Li: [DiZhi.YOU, DiZhi.WEI, DiZhi.SI],
  Enum8Gua.Gen: [DiZhi.XU, DiZhi.ZI, DiZhi.YIN],
  Enum8Gua.Dui: [DiZhi.HAI, DiZhi.YOU, DiZhi.WEI],
};

///  下->上 爻
const Map<Enum8Gua, List<DiZhi>> innerGuaYaoDiZhi = {
  Enum8Gua.Qian: [DiZhi.ZI, DiZhi.YIN, DiZhi.CHEN],
  Enum8Gua.Kun: [DiZhi.WEI, DiZhi.SI, DiZhi.MAO],
  Enum8Gua.Zhen: [DiZhi.ZI, DiZhi.YIN, DiZhi.CHEN],
  Enum8Gua.Xun: [DiZhi.CHOU, DiZhi.HAI, DiZhi.YOU],
  Enum8Gua.Kan: [DiZhi.YIN, DiZhi.CHEN, DiZhi.WU],
  Enum8Gua.Li: [DiZhi.MAO, DiZhi.CHOU, DiZhi.HAI],
  Enum8Gua.Gen: [DiZhi.CHEN, DiZhi.WU, DiZhi.SHEN],
  Enum8Gua.Dui: [DiZhi.SI, DiZhi.MAO, DiZhi.CHOU],
};

const Map<Enum8Gua, List<TianGan>> innerGuaYaoTianGan = {
  Enum8Gua.Qian: [TianGan.JIA, TianGan.JIA, TianGan.JIA],
  Enum8Gua.Dui: [TianGan.DING, TianGan.DING, TianGan.DING],
  Enum8Gua.Li: [TianGan.JI, TianGan.JI, TianGan.JI],
  Enum8Gua.Zhen: [TianGan.GENG, TianGan.GENG, TianGan.GENG],
  Enum8Gua.Xun: [TianGan.XIN, TianGan.XIN, TianGan.XIN],
  Enum8Gua.Kan: [TianGan.WU, TianGan.WU, TianGan.WU],
  Enum8Gua.Gen: [TianGan.BING, TianGan.BING, TianGan.BING],
  Enum8Gua.Kun: [TianGan.YI, TianGan.YI, TianGan.YI],
};
const Map<Enum8Gua, List<TianGan>> yinGuaYaoTianGan = {
  Enum8Gua.Qian: [TianGan.JIA, TianGan.JIA, TianGan.JIA],
  Enum8Gua.Dui: [TianGan.DING, TianGan.DING, TianGan.DING],
  Enum8Gua.Li: [TianGan.JI, TianGan.JI, TianGan.JI],
  Enum8Gua.Zhen: [TianGan.GENG, TianGan.GENG, TianGan.GENG],
  Enum8Gua.Xun: [TianGan.XIN, TianGan.XIN, TianGan.XIN],
  Enum8Gua.Kan: [TianGan.WU, TianGan.WU, TianGan.WU],
  Enum8Gua.Gen: [TianGan.BING, TianGan.BING, TianGan.BING],
  Enum8Gua.Kun: [TianGan.YI, TianGan.YI, TianGan.YI],
};

const Map<Enum8Gua, List<TianGan>> outerGuaYaoTianGan = {
  Enum8Gua.Qian: [TianGan.REN, TianGan.REN, TianGan.REN],
  Enum8Gua.Dui: [TianGan.DING, TianGan.DING, TianGan.DING],
  Enum8Gua.Li: [TianGan.JI, TianGan.JI, TianGan.JI],
  Enum8Gua.Zhen: [TianGan.GENG, TianGan.GENG, TianGan.GENG],
  Enum8Gua.Xun: [TianGan.XIN, TianGan.XIN, TianGan.XIN],
  Enum8Gua.Kan: [TianGan.WU, TianGan.WU, TianGan.WU],
  Enum8Gua.Gen: [TianGan.BING, TianGan.BING, TianGan.BING],
  Enum8Gua.Kun: [TianGan.GUI, TianGan.GUI, TianGan.GUI],
};

const Map<Enum8Gua, List<TianGan>> yangGuaYaoTianGan = {
  Enum8Gua.Qian: [TianGan.REN, TianGan.REN, TianGan.REN],
  Enum8Gua.Dui: [TianGan.DING, TianGan.DING, TianGan.DING],
  Enum8Gua.Li: [TianGan.JI, TianGan.JI, TianGan.JI],
  Enum8Gua.Zhen: [TianGan.GENG, TianGan.GENG, TianGan.GENG],
  Enum8Gua.Xun: [TianGan.XIN, TianGan.XIN, TianGan.XIN],
  Enum8Gua.Kan: [TianGan.WU, TianGan.WU, TianGan.WU],
  Enum8Gua.Gen: [TianGan.BING, TianGan.BING, TianGan.BING],
  Enum8Gua.Kun: [TianGan.GUI, TianGan.GUI, TianGan.GUI],
};
