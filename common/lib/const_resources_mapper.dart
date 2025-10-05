import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'enums/enum_di_zhi.dart';
import 'enums/enum_hou_tian_gua.dart';
import 'enums/enum_ji_xiong.dart';
import 'enums/enum_tian_gan.dart';

class ConstResourcesMapper {
  static const Map<TianGan, Color> zodiacGanColors = {
    TianGan.JIA: Color.fromRGBO(84, 150, 136, 1), // 铜绿
    TianGan.YI: Color.fromRGBO(84, 150, 136, 1), // 铜绿
    // TianGan.JIA: Color.fromRGBO(90,164,174, 1), // 天水碧
    // TianGan.YI: Color.fromRGBO(90,164,174, 1), // 天水碧
    TianGan.BING: Color.fromRGBO(233, 84, 100, 1), // 西瓜红
    TianGan.DING: Color.fromRGBO(233, 84, 100, 1), // 西瓜红
    // TianGan.WU: Color.fromRGBO(114,105,62, 1),  // 金沙
    // TianGan.JI: Color.fromRGBO(114,105,62, 1),  // 金沙
    TianGan.WU: Color.fromRGBO(168, 132, 98, 1), // 驼色
    TianGan.JI: Color.fromRGBO(168, 132, 98, 1), // 驼色
    TianGan.GENG: Color.fromRGBO(240, 167, 46, 1), // 黄金叶
    TianGan.XIN: Color.fromRGBO(238, 166, 61, 1), // 黄金叶
    TianGan.REN: Color.fromRGBO(39, 117, 182, 1), //  景泰蓝
    TianGan.GUI: Color.fromRGBO(39, 117, 182, 1), // 景泰蓝
  };
  static const Map<DiZhi, Color> zodiacZhiColors = {
    // 亥
    DiZhi.HAI: Color.fromRGBO(61, 89, 171, 1), // 子水（鼠）- 天青色
    // '丑'
    DiZhi.CHOU: Color.fromRGBO(210, 180, 140, 1), // 丑土（牛）- 茶色
    // '寅'
    // DiZhi.YIN: Color.fromRGBO(89,195,194, 1),  // 寅木（虎）- 竹青
    DiZhi.YIN: Color.fromRGBO(120, 146, 98, 1), // 卯木（兔）- 豆绿
    // '卯'
    DiZhi.MAO: Color.fromRGBO(120, 146, 98, 1), // 卯木（兔）- 豆绿
    // '辰'
    DiZhi.CHEN: Color.fromRGBO(225, 169, 95, 1), // 辰土（龙）- 麦秸黄
    // '巳'
    // DiZhi.SI: Color.fromRGBO(255, 69, 0, 1),    // 巳火（蛇）- 朱红
    DiZhi.SI: Color.fromRGBO(205, 92, 92, 1), // 午火（马）- 丹橙
    // '午'
    DiZhi.WU: Color.fromRGBO(205, 92, 92, 1), // 午火（马）- 丹橙
    // '未'
    DiZhi.WEI: Color.fromRGBO(244, 164, 96, 1), // 未土（羊）- 沙棕
    // '申'
    // DiZhi.SHEN: Color.fromRGBO(228,158,0, 1), // 申金（猴）- 银白色
    DiZhi.SHEN: Color.fromRGBO(242, 190, 69, 1), // 申金（猴）- 赤金
    // '酉'
    DiZhi.YOU: Color.fromRGBO(234, 205, 118, 1), // 酉金（鸡）- 金色
    // DiZhi.YOU: Color.fromRGBO(237, 145, 33, 1),   // 酉金（鸡）- 金色
    // '戌'
    DiZhi.XU: Color.fromRGBO(160, 82, 45, 1), // 戌土（狗）- 赭色
    // '子'
    // DiZhi.ZI: Color.fromRGBO(75, 0, 130, 1),    // 亥水（猪）- 靛青
    DiZhi.ZI: Color.fromRGBO(61, 89, 171, 1), // 子水（鼠）- 天青色
  };

  static const Map<HouTianGua, Color> zodiacGuaColors = {
    // 亥
    HouTianGua.Kan: Color.fromRGBO(61, 89, 171, 1), // 子水（鼠）- 天青色
    HouTianGua.Gen: Color.fromRGBO(210, 180, 140, 1), // 丑土（牛）- 茶色
    HouTianGua.Kun: Color.fromRGBO(210, 180, 140, 1), // 丑土（牛）- 茶色
    HouTianGua.Zhen: Color.fromRGBO(120, 146, 98, 1), // 卯木（兔）- 豆绿
    HouTianGua.Xun: Color.fromRGBO(120, 146, 98, 1), // 卯木（兔）- 豆绿
    // DiZhi.CHEN: Color.fromRGBO(225, 169, 95, 1),  // 辰土（龙）- 麦秸黄
    // '午'
    HouTianGua.Li: Color.fromRGBO(205, 92, 92, 1), // 午火（马）- 丹橙
    // '未'
    // DiZhi.WEI : Color.fromRGBO(244, 164, 96, 1),  // 未土（羊）- 沙棕
    // '申'
    HouTianGua.Qian: Color.fromRGBO(228, 158, 0, 1), // 申金（猴）- 银白色
    HouTianGua.Dui: Color.fromRGBO(228, 158, 0, 1), // 申金（猴）- 银白色
    // '戌'
    // DiZhi.XU: Color.fromRGBO(160, 82, 45, 1),   // 戌土（狗）- 赭色
  };

  static const Map<String, int> numberChineseMapper = {
    "一": 1,
    "二": 2,
    "三": 3,
    "四": 4,
    "五": 5,
    "六": 6,
    "七": 7,
    "八": 8,
    "九": 9,
    "十": 10,
    "十一": 11,
    "十二": 12,
  };
  static const Map<int, String> chineseNumberMapper = {
    1: "一",
    2: "二",
    3: "三",
    4: "四",
    5: "五",
    6: "六",
    7: "七",
    8: "八",
    9: "九",
    10: "十",
    11: "十一",
    12: "十二",
  };
  static const Map<String, String> eightGuaMapper = {
    "乾": "☰",
    "兑": "☱",
    "离": "☲",
    "震": "☳",
    "巽": "☴",
    "坎": "☵",
    "艮": "☶",
    "坤": "☷"
  };
  static const Map<String, Color> Seasons24ColorMapper = {
    "立春": Color.fromRGBO(89, 195, 194, 1),
    "雨水": Color.fromRGBO(138, 154, 91, 1),
    "惊蛰": Color.fromRGBO(128, 128, 0, 1),
    "春分": Color.fromRGBO(120, 146, 98, 1),
    "清明": Color.fromRGBO(141, 182, 0, 1),
    "谷雨": Color.fromRGBO(164, 198, 57, 1),
    "立夏": Color.fromRGBO(255, 69, 0, 1),
    "小满": Color.fromRGBO(255, 105, 97, 1),
    "芒种": Color.fromRGBO(255, 182, 193, 1),
    "夏至": Color.fromRGBO(205, 92, 92, 1),
    "小暑": Color.fromRGBO(178, 34, 34, 1),
    "大暑": Color.fromRGBO(139, 0, 0, 1),
    "立秋": Color.fromRGBO(228, 158, 0, 1),
    "处暑": Color.fromRGBO(255, 215, 0, 1),
    "白露": Color.fromRGBO(252, 211, 77, 1),
    "秋分": Color.fromRGBO(237, 145, 33, 1),
    "寒露": Color.fromRGBO(255, 193, 37, 1),
    "霜降": Color.fromRGBO(248, 197, 143, 1),
    "立冬": Color.fromRGBO(143, 178, 201, 1),
    "小雪": Color.fromRGBO(173, 216, 230, 1),
    "大雪": Color.fromRGBO(0, 191, 255, 1),
    "冬至": Color.fromRGBO(75, 0, 130, 1),
    "小寒": Color.fromRGBO(0, 0, 139, 1),
    "大寒": Color.fromRGBO(61, 89, 171, 1)
  };

  static const Map<JiXiongEnum, Color> jiXiongColorMapper = {
    JiXiongEnum.DA_JI: Color.fromRGBO(39, 98, 53, 1),
    JiXiongEnum.JI: Color.fromRGBO(40, 113, 62, 1),
    JiXiongEnum.XIAO_JI: Color.fromRGBO(40, 140, 62, 1),
    JiXiongEnum.PING: Colors.blueGrey,
    JiXiongEnum.XIAO_XIONG: Color.fromRGBO(120, 0, 36, 1),
    JiXiongEnum.XIONG: Color.fromRGBO(90, 0, 36, 1),
    JiXiongEnum.DA_XIONG: Color.fromRGBO(71, 0, 36, 1),
  };

  static final TextStyle twelveDiZhiTextStyle = GoogleFonts.longCang(
      color: Colors.grey,
      fontSize: 24,
      height: 1,
      // fontWeight: FontWeight.w500,
      shadows: [
        const Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 0))
      ]);
}
