import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/themes/gan_zhi_gua_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/widgets/card_row.dart';

// This class is not a widget. It's a collection of static methods for building the UI parts of the card.
// This ensures that all card variations use the exact same rendering logic for consistency.
class EightCharsCardViewBuilder {
  // --- Style Getters ---
  static TextStyle get _tianGanTextStyle => GoogleFonts.zhiMangXing(
        fontWeight: FontWeight.w200,
        fontSize: 28,
        height: 1,
      );

  static TextStyle get _diZhiTextStyle => GoogleFonts.longCang(
        fontSize: 28,
        height: 1,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get _labelTextStyle => GoogleFonts.zhiMangXing(
        fontSize: 14,
        height: 1.0,
      );

  // --- Row Builders ---
  static Widget buildPillarHeaderRow(BuildContext context, {
    required List<String> rowOrder,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;
    return Row(
      children: [
        SizedBox(
            width: 40,
            child: Text('四柱',
                style: _labelTextStyle.copyWith(
                    color: labelColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center)),
        Expanded(
          child: SizedBox(
            height: 22,
            child: LayoutBuilder(builder: (context, constraints) {
              final double pillarWidth = (pillars.length > 0)
                  ? (constraints.maxWidth / pillars.length).floor().toDouble()
                  : 0.0;
              return Stack(
                children:
                    pillarOrder.asMap().entries.map((indexedEntry) {
                  int index = indexedEntry.key;
                  String name = pillarOrder[index];
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: index * pillarWidth,
                    width: pillarWidth,
                    top: 0,
                    bottom: 0,
                    child: Text(name,
                        style: _labelTextStyle.copyWith(
                            color: labelColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center),
                  );
                }).toList(),
              );
            }),
          ),
        ),
      ],
    );
  }

  static Widget buildTianGanRow(BuildContext context, {
    required List<String> rowOrder,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;
    return Row(
      children: [
        SizedBox(
            width: 40,
            child: Text('天干',
                style: _labelTextStyle.copyWith(
                    color: labelColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center)),
        Expanded(
          child: SizedBox(
            height: 28,
            child: LayoutBuilder(builder: (context, constraints) {
              final double pillarWidth = (pillars.length > 0)
                  ? (constraints.maxWidth / pillars.length).floor().toDouble()
                  : 0.0;
              return Stack(
                children: pillarOrder.asMap().entries.map((indexedEntry) {
                  int index = indexedEntry.key;
                  JiaZi jiaZi = pillars[pillarOrder[index]]!;
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: index * pillarWidth,
                    width: pillarWidth,
                    top: 0,
                    bottom: 0,
                    child: Text(
                      jiaZi.tianGan.value,
                      style: _tianGanTextStyle.copyWith(
                          color: AppColors.zodiacGanColors[jiaZi.tianGan]),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              );
            }),
          ),
        ),
      ],
    );
  }

  static Widget buildDiZhiRow(BuildContext context, {
    required List<String> rowOrder,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;
    return Row(
      children: [
        SizedBox(
            width: 40,
            child: Text('地支',
                style: _labelTextStyle.copyWith(
                    color: labelColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center)),
        Expanded(
          child: SizedBox(
            height: 28,
            child: LayoutBuilder(builder: (context, constraints) {
              final double pillarWidth = (pillars.length > 0)
                  ? (constraints.maxWidth / pillars.length).floor().toDouble()
                  : 0.0;
              return Stack(
                children: pillarOrder.asMap().entries.map((indexedEntry) {
                  int index = indexedEntry.key;
                  JiaZi jiaZi = pillars[pillarOrder[index]]!;
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: index * pillarWidth,
                    width: pillarWidth,
                    top: 0,
                    bottom: 0,
                    child: Text(
                      jiaZi.diZhi.value,
                      style: _diZhiTextStyle.copyWith(
                          color: AppColors.zodiacZhiColors[jiaZi.diZhi]),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              );
            }),
          ),
        ),
      ],
    );
  }

  static Widget buildInfoRow(BuildContext context, {
    required String label,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
    required String Function(JiaZi) extractor,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label,
                style: _labelTextStyle.copyWith(
                    color: labelColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: SizedBox(
              height: 20,
              child: LayoutBuilder(builder: (context, constraints) {
                final double pillarWidth = (pillars.length > 0)
                    ? (constraints.maxWidth / pillars.length).floor().toDouble()
                    : 0.0;
                return Stack(
                  children: pillarOrder.asMap().entries.map((indexedEntry) {
                    int index = indexedEntry.key;
                    JiaZi jiaZi = pillars[pillarOrder[index]]!;
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: index * pillarWidth,
                      width: pillarWidth,
                      top: 0,
                      bottom: 0,
                      child: Text(
                        extractor(jiaZi),
                        style: _labelTextStyle.copyWith(color: labelColor),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildPillarColumn(BuildContext context, {
    required String pillarKey,
    required List<String> rowOrder,
    required Map<String, JiaZi> pillars,
  }) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;
    final jiaZi = pillars[pillarKey]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      width: 60, // Fixed width for a column
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header
          Text(pillarKey,
              style: _labelTextStyle.copyWith(
                  color: labelColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          // Tian Gan
          Text(
            jiaZi.tianGan.value,
            style: _tianGanTextStyle.copyWith(
                color: AppColors.zodiacGanColors[jiaZi.tianGan]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Di Zhi
          Text(
            jiaZi.diZhi.value,
            style: _diZhiTextStyle.copyWith(
                color: AppColors.zodiacZhiColors[jiaZi.diZhi]),
            textAlign: TextAlign.center,
          ),
          const Divider(),
          if (rowOrder.contains(CardRow.xunShou))
            Text(jiaZi.getXunHeader().ganZhiStr, style: _labelTextStyle.copyWith(color: labelColor)),
          if (rowOrder.contains(CardRow.naYin))
            Text(jiaZi.naYin.name, style: _labelTextStyle.copyWith(color: labelColor)),
          if (rowOrder.contains(CardRow.kongWang))
            Text('${jiaZi.getKongWang().item1.value}${jiaZi.getKongWang().item2.value}', style: _labelTextStyle.copyWith(color: labelColor)),
        ],
      ),
    );
  }

  static Widget buildRow(BuildContext context, {
    required String rowType,
    required List<String> rowOrder,
    required List<String> pillarOrder,
    required Map<String, JiaZi> pillars,
  }) {
    switch (rowType) {
      case CardRow.pillarHeader:
        return buildPillarHeaderRow(context, rowOrder: rowOrder, pillarOrder: pillarOrder, pillars: pillars);
      case CardRow.tianGan:
        return buildTianGanRow(context, rowOrder: rowOrder, pillarOrder: pillarOrder, pillars: pillars);
      case CardRow.diZhi:
        return buildDiZhiRow(context, rowOrder: rowOrder, pillarOrder: pillarOrder, pillars: pillars);
      case CardRow.xunShou:
        return buildInfoRow(context, label: '旬首', pillarOrder: pillarOrder, pillars: pillars,
            extractor: (jiazi) => jiazi.getXunHeader().ganZhiStr);
      case CardRow.naYin:
        return buildInfoRow(context, label: '纳音', pillarOrder: pillarOrder, pillars: pillars, 
            extractor: (jiazi) => jiazi.naYin.name);
      case CardRow.kongWang:
        return buildInfoRow(context, label: '空亡', pillarOrder: pillarOrder, pillars: pillars, 
          extractor: (jiazi) {
            final kongWang = jiazi.getKongWang();
            return '${kongWang.item1.value}${kongWang.item2.value}';
          });
      default:
        return const SizedBox.shrink();
    }
  }
}
