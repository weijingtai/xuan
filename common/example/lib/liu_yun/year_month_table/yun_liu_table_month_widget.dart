import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'yun_liu_table_common.dart';
import '../themes/ink_components.dart';
import '../themes/ink_theme.dart';

class YunLiuTableMonthWidget extends StatelessWidget {
  final TianGan tianGan;
  final DiZhi diZhi;
  final EnumTenGods tenGod;
  final List<({TianGan gan, EnumTenGods tenGod})> tenGodDetails;
  final Color? backgroundColor;

  const YunLiuTableMonthWidget({
    super.key,
    required this.tianGan,
    required this.diZhi,
    required this.tenGod,
    required this.tenGodDetails,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ganZhiLineColor = YunLiuHelper.getGanZhiLineColor(
      mode: YunLiuHelper.ganZhiLineColorMode,
      gan: tianGan,
      zhi: diZhi,
      fixedColor: InkTheme.accentGreen.withAlpha(153),
      isDashed: false,
      isDark: isDark,
    );

    final ganZhiDashColor = YunLiuHelper.getGanZhiLineColor(
      mode: YunLiuHelper.ganZhiLineColorMode,
      gan: tianGan,
      zhi: diZhi,
      fixedColor: isDark ? InkTheme.inkDashDark : InkTheme.inkDashLight,
      isDashed: true,
      isDark: isDark,
    );

    final textInk = isDark ? InkTheme.inkSoft : InkTheme.inkDeep;
    final borderColor =
        isDark ? InkTheme.inkBorderDark : InkTheme.borderLight;
    final primaryText = isDark ? InkTheme.primaryLight : InkTheme.primary;

    final backgroundTo = isDark
        ? Colors.white.withAlpha(13)
        : InkTheme.paperBackground.withAlpha(128);

    final ganZhiStyle = TextStyle(
      fontSize: 20,
      height: 1.0,
      fontWeight: FontWeight.w800,
      color: textInk,
      fontFamilyFallback: const ['ZCOOL XiaoWei', 'Noto Serif SC', 'serif'],
    );

    final tenGodStyle = TextStyle(
      fontSize: 12,
      height: 1.0,
      fontWeight: FontWeight.w600,
      color: primaryText,
      fontFamilyFallback: const ['ZCOOL XiaoWei', 'Noto Serif SC', 'serif'],
    );

    final detailStyle = TextStyle(
      fontSize: 10,
      height: 1.15,
      color: InkTheme.textMuted,
      fontFamilyFallback: const ['Noto Serif SC', 'serif'],
    );

    return SizedBox(
      height: 96,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(right: BorderSide(color: borderColor, width: 1)),
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [Colors.transparent, backgroundTo],
          // ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children: [
                  Container(
                    width: 2,
                    height: 48,
                    decoration: BoxDecoration(
                      color: ganZhiLineColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(tianGan.name, style: ganZhiStyle),
                      Text(diZhi.name, style: ganZhiStyle),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 1,
              height: 64,
              child: CustomPaint(
                painter: DayCellDashedLinePainter(
                  color: ganZhiDashColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tenGod.name, style: tenGodStyle),
                    Opacity(
                      opacity: 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final item in tenGodDetails)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(item.gan.name, style: detailStyle),
                                  const SizedBox(width: 4),
                                  Text(item.tenGod.name, style: detailStyle),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
