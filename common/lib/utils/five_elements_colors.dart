import 'package:flutter/material.dart';
import '../enums/enum_tian_gan.dart';
import '../enums/enum_di_zhi.dart';

/// 五行配色系统
///
/// 根据天干地支的五行属性返回对应颜色
/// 木 = 绿色、火 = 红色、土 = 黄色、金 = 白色、水 = 黑色

enum WuXing {
  wood,  // 木
  fire,  // 火
  earth, // 土
  metal, // 金
  water, // 水
}

class FiveElementsColors {
  FiveElementsColors._();

  /// 天干五行映射
  static const Map<TianGan, WuXing> _tianGanWuXing = {
    TianGan.JIA: WuXing.wood,
    TianGan.YI: WuXing.wood,
    TianGan.BING: WuXing.fire,
    TianGan.DING: WuXing.fire,
    TianGan.WU: WuXing.earth,
    TianGan.JI: WuXing.earth,
    TianGan.GENG: WuXing.metal,
    TianGan.XIN: WuXing.metal,
    TianGan.REN: WuXing.water,
    TianGan.GUI: WuXing.water,
  };

  /// 地支五行映射
  static const Map<DiZhi, WuXing> _diZhiWuXing = {
    DiZhi.ZI: WuXing.water,
    DiZhi.CHOU: WuXing.earth,
    DiZhi.YIN: WuXing.wood,
    DiZhi.MAO: WuXing.wood,
    DiZhi.CHEN: WuXing.earth,
    DiZhi.SI: WuXing.fire,
    DiZhi.WU: WuXing.fire,
    DiZhi.WEI: WuXing.earth,
    DiZhi.SHEN: WuXing.metal,
    DiZhi.YOU: WuXing.metal,
    DiZhi.XU: WuXing.earth,
    DiZhi.HAI: WuXing.water,
  };

  /// 五行配色方案（浅色模式）
  static const Map<WuXing, Color> _lightColors = {
    WuXing.wood: Color(0xFF10B981),  // 绿色 (emerald-500)
    WuXing.fire: Color(0xFFEF4444),  // 红色 (red-500)
    WuXing.earth: Color(0xFFF59E0B), // 黄色 (amber-500)
    WuXing.metal: Color(0xFF6B7280), // 灰白 (gray-500)
    WuXing.water: Color(0xFF3B82F6), // 蓝色 (blue-500)
  };

  /// 五行配色方案（深色模式）
  static const Map<WuXing, Color> _darkColors = {
    WuXing.wood: Color(0xFF34D399),  // 绿色 (emerald-400)
    WuXing.fire: Color(0xFFF87171),  // 红色 (red-400)
    WuXing.earth: Color(0xFFFBBF24), // 黄色 (amber-400)
    WuXing.metal: Color(0xFF9CA3AF), // 灰白 (gray-400)
    WuXing.water: Color(0xFF60A5FA), // 蓝色 (blue-400)
  };

  /// 获取天干对应的五行颜色
  static Color getTianGanColor(TianGan gan, {bool isDarkMode = false}) {
    final wuXing = _tianGanWuXing[gan] ?? WuXing.earth;
    return getWuXingColor(wuXing, isDarkMode: isDarkMode);
  }

  /// 获取地支对应的五行颜色
  static Color getDiZhiColor(DiZhi zhi, {bool isDarkMode = false}) {
    final wuXing = _diZhiWuXing[zhi] ?? WuXing.earth;
    return getWuXingColor(wuXing, isDarkMode: isDarkMode);
  }

  /// 获取五行对应的颜色
  static Color getWuXingColor(WuXing wuXing, {bool isDarkMode = false}) {
    final colorMap = isDarkMode ? _darkColors : _lightColors;
    return colorMap[wuXing] ?? const Color(0xFF6B7280);
  }

  /// 获取五行名称
  static String getWuXingName(WuXing wuXing) {
    switch (wuXing) {
      case WuXing.wood:
        return '木';
      case WuXing.fire:
        return '火';
      case WuXing.earth:
        return '土';
      case WuXing.metal:
        return '金';
      case WuXing.water:
        return '水';
    }
  }

  /// 从天干获取五行
  static WuXing? getTianGanWuXing(TianGan gan) {
    return _tianGanWuXing[gan];
  }

  /// 从地支获取五行
  static WuXing? getDiZhiWuXing(DiZhi zhi) {
    return _diZhiWuXing[zhi];
  }
}
