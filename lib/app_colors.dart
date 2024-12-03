import 'package:common/model/enum_di_zhi.dart';
import 'package:common/model/enum_tian_gan.dart';
import 'package:flutter/material.dart';

class AppColors{
  static const Map<TianGan, Color> zodiacGanColors = {
    TianGan.JIA: Color.fromRGBO(90,164,174, 1), // 天水碧
    TianGan.YI: Color.fromRGBO(90,164,174, 1), // 天水碧
    TianGan.BING: Color.fromRGBO(233,84, 100, 1),  // 西瓜红
    TianGan.DING: Color.fromRGBO(233,84, 100, 1), // 西瓜红
    TianGan.WU: Color.fromRGBO(114,105,62, 1),  // 金沙
    TianGan.JI: Color.fromRGBO(114,105,62, 1),  // 金沙
    TianGan.GENG: Color.fromRGBO(240,167,46, 1),    // 黄金叶
    TianGan.XIN: Color.fromRGBO(238, 166, 61, 1),  // 黄金叶
    TianGan.REN: Color.fromRGBO(39,117,182, 1), //  景泰蓝
    TianGan.GUI: Color.fromRGBO(39,117,182, 1),   // 景泰蓝
  };
  static const Map<DiZhi, Color> zodiacZhiColors = {
    // 亥
    DiZhi.HAI: Color.fromRGBO(61, 89, 171, 1), // 子水（鼠）- 天青色
    // '丑'
    DiZhi.CHOU: Color.fromRGBO(210, 180, 140, 1), // 丑土（牛）- 茶色
    // '寅'
    DiZhi.YIN: Color.fromRGBO(89,195,194, 1),  // 寅木（虎）- 竹青
    // '卯'
    DiZhi.MAO: Color.fromRGBO(120, 146, 98, 1), // 卯木（兔）- 豆绿
    // '辰'
    DiZhi.CHEN: Color.fromRGBO(225, 169, 95, 1),  // 辰土（龙）- 麦秸黄
    // '巳'
    DiZhi.SI: Color.fromRGBO(255, 69, 0, 1),    // 巳火（蛇）- 朱红
    // '午'
    DiZhi.WU : Color.fromRGBO(205, 92, 92, 1),    // 午火（马）- 丹橙
    // '未'
    DiZhi.WEI : Color.fromRGBO(244, 164, 96, 1),  // 未土（羊）- 沙棕
    // '申'
    DiZhi.SHEN: Color.fromRGBO(228,158,0, 1), // 申金（猴）- 银白色
    // '酉'
    DiZhi.YOU: Color.fromRGBO(237, 145, 33, 1),   // 酉金（鸡）- 金色
    // '戌'
    DiZhi.XU: Color.fromRGBO(160, 82, 45, 1),   // 戌土（狗）- 赭色
    // '子'
    DiZhi.ZI: Color.fromRGBO(75, 0, 130, 1),    // 亥水（猪）- 靛青
  };
}