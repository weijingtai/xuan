import 'package:flutter/material.dart';
import 'package:common/enums.dart';
import 'package:common/features/datetime_details/input_info_params.dart';

import '../themes/ink_theme.dart';

enum GanZhiLineColorMode { fixed, naYin }

class YunLiuHelper {
  static GanZhiLineColorMode ganZhiLineColorMode =
      GanZhiLineColorMode.fixed;

  static Color getGanZhiLineColor({
    required GanZhiLineColorMode mode,
    required TianGan? gan,
    required DiZhi? zhi,
    required Color fixedColor,
    required bool isDashed,
    required bool isDark,
  }) {
    if (mode == GanZhiLineColorMode.fixed || gan == null || zhi == null) {
      return fixedColor;
    }
    final jiaZi = JiaZi.getFromGanZhiValue('${gan.value}${zhi.value}');
    if (jiaZi == null) {
      return fixedColor;
    }
    final base = _fiveXingLineColor(jiaZi.naYin.fiveXing);
    if (isDashed) {
      return base.withOpacity(isDark ? 0.55 : 0.7);
    }
    return base;
  }

  static Color _fiveXingLineColor(FiveXing fiveXing) {
    switch (fiveXing) {
      case FiveXing.MU:
        return InkTheme.elementWood;
      case FiveXing.HUO:
        return InkTheme.seal;
      case FiveXing.TU:
        return InkTheme.elementEarth;
      case FiveXing.JIN:
        return InkTheme.elementMetal;
      case FiveXing.SHUI:
        return InkTheme.elementWater;
    }
  }

  /// Shared months data for all YunLiu components
  static const List<String> months = [
    '正月',
    '二月',
    '三月',
    '四月',
    '五月',
    '六月',
    '七月',
    '八月',
    '九月',
    '十月',
    '冬月',
    '腊月',
  ];

  static Color getStrategyColor(ZiShiStrategy strategy, {bool isWash = false}) {
    switch (strategy) {
      case ZiShiStrategy.noDistinguishAt23:
      case ZiShiStrategy.startFrom23:
        return isWash
            ? InkTheme.strategyBlueGrey.withOpacity(0.15)
            : InkTheme.strategyBlueGrey;
      case ZiShiStrategy.distinguishAt0FiveMouse:
      case ZiShiStrategy.startFrom0:
      case ZiShiStrategy.splitedZi:
      case ZiShiStrategy.bandsStartAt0:
        return isWash ? InkTheme.sealWash(40) : InkTheme.seal;
      case ZiShiStrategy.distinguishAt0Fixed:
        return isWash
            ? InkTheme.strategyGreen.withOpacity(0.15)
            : InkTheme.strategyGreen;
    }
  }

  static const int yearCount = 10;
  static const int yearStartBase = 2024;

  static List<({TianGan gan, EnumTenGods hiddenGods})> hiddenGansForSeed(
    int seed,
  ) {
    final stems = TianGan.listAll;
    final gods = EnumTenGods.values;

    return <({TianGan gan, EnumTenGods hiddenGods})>[
      (
        gan: stems[seed % stems.length],
        hiddenGods: gods[(seed + 1) % gods.length],
      ),
      (
        gan: stems[(seed + 3) % stems.length],
        hiddenGods: gods[(seed + 2) % gods.length],
      ),
      (
        gan: stems[(seed + 6) % stems.length],
        hiddenGods: gods[(seed + 3) % gods.length],
      ),
    ];
  }

  static List<({TianGan gan, EnumTenGods tenGod})> tenGodDetailsForSeed(
    int seed,
  ) {
    final stems = TianGan.listAll;
    final gods = EnumTenGods.values;

    return <({TianGan gan, EnumTenGods tenGod})>[
      (gan: stems[seed % stems.length], tenGod: gods[(seed + 1) % gods.length]),
      (
        gan: stems[(seed + 2) % stems.length],
        tenGod: gods[(seed + 2) % gods.length],
      ),
      (
        gan: stems[(seed + 4) % stems.length],
        tenGod: gods[(seed + 3) % gods.length],
      ),
    ];
  }

  static int yearAt(int daYunIndex, int yearIndex) {
    return yearStartBase + (daYunIndex * yearCount) + yearIndex;
  }

  static String calendarId(int daYunIndex, int monthIndex, int yearIndex) {
    return '$daYunIndex-$monthIndex-$yearIndex';
  }

  static int calendarRows({required int year, required int month}) {
    final first = DateTime(year, month, 1);
    final next = DateTime(year, month + 1, 1);
    final days = next.subtract(const Duration(days: 1)).day;
    final leading = (first.weekday - DateTime.monday) % 7;
    final total = leading + days;
    return ((total + 6) ~/ 7).clamp(4, 6);
  }

  static double calendarPanelWidth({
    required double yearsWidth,
    required bool isPhone,
  }) {
    final maxW = isPhone ? 460.0 : 640.0;
    return yearsWidth.clamp(300.0, maxW).toDouble();
  }

  static double calendarRowHeight({
    required double availableWidth,
    required bool isPhone,
  }) {
    final cellW = availableWidth / 7;
    return cellW.toDouble();
  }

  static double calendarExpandedRowHeight({
    required double yearsWidth,
    required bool isPhone,
    required int year,
    required int month,
    required bool showDetail,
  }) {
    final outerTop = 10.0;
    final outerBottom = 14.0;
    final outerLR = isPhone ? 10.0 : 14.0;

    final innerPad = isPhone ? 12.0 : 16.0;

    final panelW = calendarPanelWidth(yearsWidth: yearsWidth, isPhone: isPhone);
    final availableWidth = (panelW - (outerLR * 2) - (innerPad * 2))
        .clamp(140.0, double.infinity)
        .toDouble();
    final rows = calendarRows(year: year, month: month);
    final rowH = calendarRowHeight(
      availableWidth: availableWidth,
      isPhone: isPhone,
    );

    final headerH = isPhone ? 30.0 : 32.0;
    const weekH = 20.0;
    final topGap = isPhone ? 10.0 : 12.0;
    const midGap = 6.0;

    const gridCrossSpacing = 6.0;
    const gridMainSpacing = 6.0;
    const gridCrossAxisCount = 6;
    const cellAspectRatio = 1.28;

    final detailGap = showDetail ? 8.0 : 0.0;
    final shiChenH = showDetail
        ? () {
            final outerPad = isPhone ? 3.0 : 4.0;
            final innerPad = isPhone ? 10.0 : 12.0;

            final topBarH = isPhone ? 34.0 : 36.0;
            final bottomBarH = isPhone ? 30.0 : 32.0;
            final gapTop = isPhone ? 8.0 : 10.0;
            final gapBottom = isPhone ? 6.0 : 8.0;

            final panelW = (availableWidth - (outerPad * 2)).clamp(
              0.0,
              double.infinity,
            );
            final gridW = (panelW - (innerPad * 2)).clamp(0.0, double.infinity);
            final cellW =
                (gridW - (gridCrossSpacing * (gridCrossAxisCount - 1))) /
                gridCrossAxisCount;
            final cellH = (cellW / cellAspectRatio).clamp(0.0, double.infinity);
            final gridH = (cellH * 2) + gridMainSpacing;

            final total =
                (innerPad * 2) +
                topBarH +
                gapTop +
                gridH +
                gapBottom +
                bottomBarH;
            return total + (isPhone ? 22 : 24);
          }()
        : 0.0;

    final calendarH =
        headerH +
        topGap +
        weekH +
        midGap +
        (rows * rowH) +
        detailGap +
        shiChenH;

    return outerTop + outerBottom + (innerPad * 2) + calendarH + 6;
  }
}
