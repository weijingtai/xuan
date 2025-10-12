import 'package:common/enums/enum_di_zhi.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/themes/gan_zhi_gua_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EightCharsCard extends StatelessWidget {
  final String? title;
  final Map<String, JiaZi> pillars;
  final bool showXunShou;
  final bool showNaYin;
  final bool showKongWang;

  const EightCharsCard({
    Key? key,
    this.title,
    required this.pillars,
    this.showXunShou = false,
    this.showNaYin = false,
    this.showKongWang = false,
  }) : super(key: key);

  // --- UI HELPERS ---
  TextStyle get _tianGanTextStyle => GoogleFonts.zhiMangXing(
        fontWeight: FontWeight.w200,
        fontSize: 28,
        height: 1,
      );

  TextStyle get _diZhiTextStyle => GoogleFonts.longCang(
        fontSize: 28,
        height: 1,
        fontWeight: FontWeight.w500,
      );

  TextStyle get _labelTextStyle => GoogleFonts.zhiMangXing(
        fontSize: 14,
        height: 1.0,
      );

  Widget _buildInfoRow(BuildContext context, String label,
      Map<String, JiaZi> pillars, String Function(JiaZi) extractor) {
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
              height: 20, // Provide a fixed height for the row
              child: LayoutBuilder(builder: (context, constraints) {
                final double pillarWidth = (pillars.length > 0)
                    ? (constraints.maxWidth / pillars.length).floor().toDouble()
                    : 0.0;
                return Stack(
                  children: pillars.entries.toList().asMap().entries.map((indexedEntry) {
                    int index = indexedEntry.key;
                    var entry = indexedEntry.value;
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: index * pillarWidth,
                      width: pillarWidth,
                      top: 0,
                      bottom: 0,
                      child: Text(
                        extractor(entry.value),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;
    final bool showBottomLabels = showXunShou || showNaYin || showKongWang;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            // Pillar Headers
            Row(
              children: [
                if (showBottomLabels)
                  SizedBox(
                      width: 40,
                      child: Text('四柱',
                          style: _labelTextStyle.copyWith(
                              color: labelColor, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center)),
                Expanded(
                  child: SizedBox(
                    height: 22, // Provide a fixed height for the row
                    child: LayoutBuilder(builder: (context, constraints) {
                      final double pillarWidth = (pillars.length > 0)
                          ? (constraints.maxWidth / pillars.length).floor().toDouble()
                          : 0.0;
                      return Stack(
                        children: pillars.keys.toList().asMap().entries.map((indexedEntry) {
                          int index = indexedEntry.key;
                          String name = indexedEntry.value;
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
            ),
            const SizedBox(height: 8),

            // Tian Gan
            Row(
              children: [
                if (showBottomLabels)
                  SizedBox(
                      width: 40,
                      child: Text('天干',
                          style: _labelTextStyle.copyWith(
                              color: labelColor, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center)),
                Expanded(
                  child: SizedBox(
                    height: 28, // Provide a fixed height for the row
                    child: LayoutBuilder(builder: (context, constraints) {
                      final double pillarWidth = (pillars.length > 0)
                          ? (constraints.maxWidth / pillars.length).floor().toDouble()
                          : 0.0;
                      return Stack(
                        children: pillars.values.toList().asMap().entries.map((indexedEntry) {
                          int index = indexedEntry.key;
                          JiaZi jiaZi = indexedEntry.value;
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
                                  color:
                                      AppColors.zodiacGanColors[jiaZi.tianGan]),
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
            const SizedBox(height: 4),

            // Di Zhi
            Row(
              children: [
                if (showBottomLabels)
                  SizedBox(
                      width: 40,
                      child: Text('地支',
                          style: _labelTextStyle.copyWith(
                              color: labelColor, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center)),
                Expanded(
                  child: SizedBox(
                    height: 28, // Provide a fixed height for the row
                    child: LayoutBuilder(builder: (context, constraints) {
                      final double pillarWidth = (pillars.length > 0)
                          ? (constraints.maxWidth / pillars.length).floor().toDouble()
                          : 0.0;
                      return Stack(
                        children: pillars.values.toList().asMap().entries.map((indexedEntry) {
                          int index = indexedEntry.key;
                          JiaZi jiaZi = indexedEntry.value;
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
                                  color:
                                      AppColors.zodiacZhiColors[jiaZi.diZhi]),
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
            if (showBottomLabels)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),
            if (showXunShou)
              _buildInfoRow(context, '旬首', pillars,
                  (jiazi) => jiazi.getXunHeader().ganZhiStr),
            if (showNaYin)
              _buildInfoRow(context, '纳音', pillars, (jiazi) => jiazi.naYin.name),
            if (showKongWang)
              _buildInfoRow(context, '空亡', pillars, (jiazi) {
                final kongWang = jiazi.getKongWang();
                return '${kongWang.item1.value}${kongWang.item2.value}';
              }),
          ],
        ),
      ),
    );
  }
}

