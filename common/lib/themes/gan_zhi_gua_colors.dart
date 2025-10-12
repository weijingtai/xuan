import 'package:flutter/material.dart';

import '../enums/enum_di_zhi.dart';
import '../enums/enum_hou_tian_gua.dart';
import '../enums/enum_tian_gan.dart';

// AppColors (应用主颜色定义)
// 这是一个静态类，用于存放您项目的所有颜色常量
// -----------------------------------------------------------------------------

class AppColors {

  // ===========================================================================
  // 核心语义色 (Core Semantic Colors) - 您提供的原色
  // ===========================================================================

  static final Map<TianGan, Color> zodiacGanColors = {
    TianGan.JIA: Color.fromRGBO(84, 150, 136, 1), // 铜绿
    TianGan.YI: Color.fromRGBO(84, 150, 136, 1), // 铜绿
    TianGan.BING: Color.fromRGBO(233, 84, 100, 1), // 西瓜红
    TianGan.DING: Color.fromRGBO(233, 84, 100, 1), // 西瓜红
    TianGan.WU: Color.fromRGBO(168, 132, 98, 1), // 驼色
    TianGan.JI: Color.fromRGBO(168, 132, 98, 1), // 驼色
    TianGan.GENG: Color.fromRGBO(240, 167, 46, 1), // 黄金叶
    TianGan.XIN: Color.fromRGBO(238, 166, 61, 1), // 黄金叶
    TianGan.REN: Color.fromRGBO(39, 117, 182, 1), // 景泰蓝
    TianGan.GUI: Color.fromRGBO(39, 117, 182, 1), // 景泰蓝
  };

  static final Map<DiZhi, Color> zodiacZhiColors = {
    DiZhi.HAI: Color.fromRGBO(61, 89, 171, 1), // 天青色
    DiZhi.CHOU: Color.fromRGBO(210, 180, 140, 1), // 茶色
    DiZhi.YIN: Color.fromRGBO(120, 146, 98, 1), // 豆绿
    DiZhi.MAO: Color.fromRGBO(120, 146, 98, 1), // 豆绿
    DiZhi.CHEN: Color.fromRGBO(225, 169, 95, 1), // 麦秸黄
    DiZhi.SI: Color.fromRGBO(205, 92, 92, 1), // 丹橙
    DiZhi.WU: Color.fromRGBO(205, 92, 92, 1), // 丹橙
    DiZhi.WEI: Color.fromRGBO(244, 164, 96, 1), // 沙棕
    DiZhi.SHEN: Color.fromRGBO(242, 190, 69, 1), // 赤金
    DiZhi.YOU: Color.fromRGBO(234, 205, 118, 1), // 金色
    DiZhi.XU: Color.fromRGBO(160, 82, 45, 1), // 赭色
    DiZhi.ZI: Color.fromRGBO(61, 89, 171, 1), // 天青色
  };

  static final Map<HouTianGua, Color> zodiacGuaColors = {
    HouTianGua.Kun: const Color.fromRGBO(61, 89, 171, 1), // 天青色
    HouTianGua.Gen: const Color.fromRGBO(210, 180, 140, 1), // 茶色
    HouTianGua.Kun: const Color.fromRGBO(210, 180, 140, 1), // 茶色
    HouTianGua.Zhen: const Color.fromRGBO(120, 146, 98, 1), // 豆绿
    HouTianGua.Xun: const Color.fromRGBO(120, 146, 98, 1), // 豆绿
    HouTianGua.Li: const Color.fromRGBO(205, 92, 92, 1), // 丹橙
    HouTianGua.Qian: const Color.fromRGBO(228, 158, 0, 1), // 银白色
    HouTianGua.Dui: const Color.fromRGBO(228, 158, 0, 1), // 银白色
  };
}

// ===========================================================================
// Light Theme (素雅宣纸)
// ===========================================================================
abstract class Light {
  /// 杏仁白 (背景色) - #F9F6EE
  static const Color background = Color.fromRGBO(249, 246, 238, 1);
  /// 月白 (卡片/表面色) - #FFFFFF
  static const Color surface = Color.fromRGBO(255, 255, 255, 1);
  /// 墨黑 (主要文字) - #333333
  static const Color primaryText = Color.fromRGBO(51, 51, 51, 1);
  /// 烟灰 (次要文字) - #888888
  static const Color secondaryText = Color.fromRGBO(136, 136, 136, 1);
  /// 绢白 (分割线/边框) - #EEEEEE
  static const Color divider = Color.fromRGBO(238, 238, 238, 1);
  }

// ===========================================================================
// Dark Theme (静谧黛蓝)
// ===========================================================================
abstract class Dark {
  /// 黛蓝 (背景色) - #14181F
  static const Color background = Color.fromRGBO(20, 24, 31, 1);
  /// 玄青 (卡片/表面色) - #232933
  static const Color surface = Color.fromRGBO(35, 41, 51, 1);
  /// 银白 (主要文字) - #DEDEDE
  static const Color primaryText = Color.fromRGBO(222, 222, 222, 1);
  /// 月灰 (次要文字) - #9E9E9E
  static const Color secondaryText = Color.fromRGBO(158, 158, 158, 1);
  /// 青冥 (分割线/边框) - #3C4452
  static const Color divider = Color.fromRGBO(60, 68, 82, 1);
}