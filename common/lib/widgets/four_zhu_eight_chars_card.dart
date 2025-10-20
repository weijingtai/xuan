
import 'package:common/features/tai_yuan/tai_yuan_model.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/themes/gan_zhi_gua_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_di_zhi.dart';
import '../enums/enum_jia_zi.dart';
import '../enums/enum_tian_gan.dart';

class FourZhuEightCharsCard extends StatelessWidget {
  final EightChars eightChars;
  final TaiYuanModel taiYuan;
  JiaZi? keZhu;
  // final DateTime dateTime;
  final bool showTaiYuan;
  final bool showXunShou;
  final bool showNaYin;
  final bool showKongWang;
  final bool showKe;

  FourZhuEightCharsCard({
    Key? key,
    required this.eightChars,
    required this.taiYuan,
    this.keZhu,
    // required this.dateTime,
    this.showTaiYuan = false,
    this.showXunShou = false,
    this.showNaYin = false,
    this.showKongWang = false,
    this.showKe = false,
  }) : super(key: key);

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

  // String _calculateKe(DateTime dt) {
  //   const minutesPerKe = 15; // 一个时辰8刻，每刻15分钟
  //   final hourDiZhiIndex = DiZhi.listAll.indexOf(eightChars.time.diZhi);
  //   final startOfHour = hourDiZhiIndex * 2;
  //   int minuteFromStartOfHour = (dt.hour - startOfHour) * 60 + dt.minute;
  //   if(minuteFromStartOfHour < 0) minuteFromStartOfHour += 1440; // Handle cross-day
  //
  //   final keInHour = (minuteFromStartOfHour / minutesPerKe).floor();
  //
  //   const keNames = ['初刻', '一刻', '二刻', '三刻', '四刻', '五刻', '六刻', '七刻'];
  //   return keNames[keInHour.clamp(0, 7)];
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pillars = {
      '年': eightChars.year,
      '月': eightChars.month,
      '日': eightChars.day,
      '时': eightChars.time,
    };

    if (showTaiYuan) {
      pillars['胎元'] = taiYuan.taiYuanGanZhi;
    }
    if (showKe && keZhu != null){
      pillars['刻'] = keZhu!;
    }

    final showBottomLabels = showXunShou || showNaYin || showKongWang || showKe;
    final labelColor = theme.textTheme.titleMedium?.color;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 240, maxWidth: 420),
        child: Container(
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
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Pillar Headers
              Row(
                children: [
                  if (showBottomLabels) SizedBox(width: 40, child: Text('四柱', style: _labelTextStyle.copyWith(color: labelColor, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: pillars.keys.map((name) => SizedBox(
                        width: 40,
                        child: Text(name, style: _labelTextStyle.copyWith(color: labelColor, fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                      )).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Tian Gan
              Row(
                children: [
                  if (showBottomLabels) SizedBox(width: 40, child: Text('天干', style: _labelTextStyle.copyWith(color: labelColor, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: pillars.values.map((jiaZi) => SizedBox(
                        width: 40,
                        child: Text(
                          jiaZi.tianGan.value,
                          style: _tianGanTextStyle.copyWith(color: AppColors.zodiacGanColors[jiaZi.tianGan]),
                          textAlign: TextAlign.center,
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Di Zhi
              Row(
                children: [
                  if (showBottomLabels) SizedBox(width: 40, child: Text('地支', style: _labelTextStyle.copyWith(color: labelColor, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: pillars.values.map((jiaZi) => SizedBox(
                        width: 40,
                        child: Text(
                          jiaZi.diZhi.value,
                          style: _diZhiTextStyle.copyWith(color: AppColors.zodiacZhiColors[jiaZi.diZhi]),
                          textAlign: TextAlign.center,
                        ),
                      )).toList(),
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
                _buildInfoRow(context, '旬首', pillars, (jiazi) => jiazi.getXunHeader().ganZhiStr),
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
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, Map<String, JiaZi> pillars, String Function(JiaZi) extractor) {
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.titleMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label, style: _labelTextStyle.copyWith(color: labelColor, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: pillars.entries.map((entry) {
                return SizedBox(
                  width: 40,
                  child: Text(
                    extractor(entry.value),
                    style: _labelTextStyle.copyWith(color: labelColor),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
