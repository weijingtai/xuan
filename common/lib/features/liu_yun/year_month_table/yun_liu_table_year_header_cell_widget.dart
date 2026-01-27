import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'yun_liu_table_common.dart';
import '../themes/ink_theme.dart';

class YunLiuTableYearHeaderCellWidget extends StatelessWidget {
  const YunLiuTableYearHeaderCellWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkTheme.paperStone,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: const DaYunHeaderCell(
                year: 2024,
                age: 28,
                yearGanZhi: JiaZi.JIA_CHEN,
                ganGod: EnumTenGods.ZhenCai,
                hiddenGans: [
                  (gan: TianGan.WU, hiddenGods: EnumTenGods.ZhenCai),
                  (gan: TianGan.YI, hiddenGods: EnumTenGods.ZhengGuan),
                  (gan: TianGan.BING, hiddenGods: EnumTenGods.PanYin),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DaYunHeaderCell extends StatelessWidget {
  final JiaZi yearGanZhi;
  final EnumTenGods ganGod;
  final List<({TianGan gan, EnumTenGods hiddenGods})> hiddenGans;
  final Color? backgroundColor;

  // final String zodiacZn;

  final int age;
  final int year;

  const DaYunHeaderCell({
    super.key,
    required this.yearGanZhi,
    required this.ganGod,
    // required this.zodiacZn,
    required this.hiddenGans,
    required this.age,
    required this.year,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const paperBase = InkTheme.paperHeader;
    const headerInk = InkTheme.inkDeep;
    const ink = InkTheme.ink;
    const cinnabar = InkTheme.cinnabarDeep;
    const gold = InkTheme.goldBright;
    const borderColor = InkTheme.borderStone;

    final hidden = <({TianGan gan, EnumTenGods hiddenGods})>[...hiddenGans];
    while (hidden.length < 3) {
      hidden.add((gan: TianGan.JIA, hiddenGods: EnumTenGods.BiJian));
    }

    final pillarChars = yearGanZhi.name.split('');
    final leftChar = pillarChars.isNotEmpty ? pillarChars.first : '';
    final rightChar = pillarChars.length > 1 ? pillarChars[1] : '';
    final zodiacChar = yearGanZhi.chinese12Zodiac.name;

    return LayoutBuilder(
      builder: (context, c) {
        final sx = (c.maxWidth / 100.0).clamp(0.45, 2.4);
        final sy = (c.maxHeight / 112.0).clamp(0.45, 2.4);
        final s = sx < sy ? sx : sy;

        final ganZhiLineColor = YunLiuHelper.getGanZhiLineColor(
          mode: YunLiuHelper.ganZhiLineColorMode,
          gan: yearGanZhi.gan,
          zhi: yearGanZhi.zhi,
          fixedColor: cinnabar.withValues(alpha: 0.4),
          isDashed: false,
          isDark: isDark,
        );

        final radius = 8.0 * s;

        final headerYearStyle = TextStyle(
          fontSize: 10.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3 * s,
          color: paperBase,
          fontFamilyFallback: const [
            'Noto Serif SC',
            'STKaiti',
            'KaiTi',
            'serif',
          ],
        );

        final ageStyle = TextStyle(
          fontSize: 8.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w700,
          color: gold,
          fontFamilyFallback: const [
            'Noto Serif SC',
            'STKaiti',
            'KaiTi',
            'serif',
          ],
        );

        final pillarStyle = GoogleFonts.maShanZheng(
          fontSize: 24.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w700,
          color: ink,
        );

        final watermarkStyle = GoogleFonts.maShanZheng(
          fontSize: 60.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w700,
          color: ink.withValues(alpha: 0.15),
        );

        final syncTextStyle = TextStyle(
          fontSize: 11.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w700,
          fontFamilyFallback: const [
            'Noto Serif SC',
            'STKaiti',
            'KaiTi',
            'serif',
          ],
        );

        final cellPaper = backgroundColor ?? paperBase;

        final body = ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cellPaper,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: borderColor, width: 1.0 * s),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 12.0 * s,
                  offset: Offset(0, 6.0 * s),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 6.0 * s),
                  color: headerInk,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$year', style: headerYearStyle),
                      SizedBox(height: 3.0 * s),
                      Transform.scale(
                        scale: 0.9,
                        child: Text('$age岁', style: ageStyle),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(4.0 * s),
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                          left: 4.0 * s,
                          bottom: 4.0 * s,
                          child: IgnorePointer(
                            child: SizedBox(
                              width: 70.0 * s,
                              height: 70.0 * s,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Transform.rotate(
                                  angle: 0.26,
                                  child: Text(
                                    zodiacChar,
                                    style: watermarkStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 35,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(leftChar, style: pillarStyle),
                                  SizedBox(height: 10.0 * s),
                                  Text(rightChar, style: pillarStyle),
                                ],
                              ),
                            ),
                            Container(
                              width: 1.0 * s,
                              height: double.infinity,
                              color: ganZhiLineColor,
                            ),
                            Expanded(
                              flex: 65,
                              child: Padding(
                                padding: EdgeInsets.only(left: 6.0 * s),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 12.0 * s,
                                          height: 12.0 * s,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: cinnabar,
                                            borderRadius: BorderRadius.circular(
                                              2.0 * s,
                                            ),
                                          ),
                                          child: Text(
                                            '干',
                                            style: syncTextStyle.copyWith(
                                              fontSize: 11.0 * s,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 4.0 * s),
                                        Text(
                                          ganGod.name,
                                          style: syncTextStyle.copyWith(
                                            color: cinnabar,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6.0 * s),
                                    Column(
                                      children: [
                                        for (var i = 0; i < 3; i++)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              bottom: i == 2 ? 0 : 4.0 * s,
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 14.0 * s,
                                                  child: Text(
                                                    hidden[i].gan.name,
                                                    style: syncTextStyle
                                                        .copyWith(color: ink),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                SizedBox(width: 4.0 * s),
                                                Text(
                                                  hidden[i].hiddenGods.name,
                                                  style: syncTextStyle.copyWith(
                                                    color: cinnabar,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return SizedBox(width: c.maxWidth, height: c.maxHeight, child: body);
      },
    );
  }
}
