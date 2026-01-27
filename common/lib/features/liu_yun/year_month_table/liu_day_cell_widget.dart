import 'package:flutter/material.dart';
import 'package:common/enums.dart';
import 'yun_liu_table_common.dart';
import '../themes/ink_components.dart';
import '../themes/ink_theme.dart';

class LiuDayCellWidget extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  final String ganText;
  final String zhiText;
  final String tenGodName;
  final List<({String gan, String tenGod})> hidden;
  final String jieQi;
  final String zodiac;
  final String lunarText;
  final bool isLunarHighlight;

  const LiuDayCellWidget({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
    required this.ganText,
    required this.zhiText,
    required this.tenGodName,
    required this.hidden,
    required this.jieQi,
    required this.zodiac,
    required this.lunarText,
    this.isLunarHighlight = false,
  });

  Widget _vertical(String text, TextStyle style) {
    final chars = text.split('');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(chars.first, style: style),
        SizedBox(height: 8.0),
        Text(chars.last, style: style),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paper = InkTheme.paperCell;
    final ink = InkTheme.inkDeep;
    final sealRed = InkTheme.cinnabar;
    final tianGan = TianGan.getFromValue(ganText);
    final diZhi = DiZhi.getFromValue(zhiText);
    final ganZhiLineColor = YunLiuHelper.getGanZhiLineColor(
      mode: YunLiuHelper.ganZhiLineColorMode,
      gan: tianGan,
      zhi: diZhi,
      fixedColor: sealRed,
      isDashed: false,
      isDark: isDark,
    );

    return InkHoverRegion(
      builder: (context, isHovered) {
        const designSize = 180.0;
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: designSize,
            height: designSize,
            child: LayoutBuilder(
              builder: (context, c) {
                final s =
                    ((c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight) /
                            designSize)
                        .clamp(0.35, 2.0);

                final radius = 12.0 * s;
                final borderW = 2.0 * s;

                final dateStyle = TextStyle(
                  fontSize: 32.0 * s,
                  height: 0.8,
                  fontWeight: FontWeight.w900,
                  color: ink.withAlpha(100),
                  fontFamilyFallback: const [
                    'ZCOOL XiaoWei',
                    'Noto Serif SC',
                    'serif',
                  ],
                );

                final pillarStyle = TextStyle(
                  fontSize: 38.0 * s,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  color: ink,
                  letterSpacing: -2.0 * s,
                  fontFamilyFallback: const [
                    'ZCOOL XiaoWei',
                    'Noto Serif SC',
                    'serif',
                  ],
                );

                final jieQiStyle = TextStyle(
                  fontSize: 18.0 * s,
                  height: .8,
                  fontWeight: FontWeight.w800,
                  color: sealRed.withAlpha(210),
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final heavenGodStyle = TextStyle(
                  fontSize: 19.0 * s,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  color: sealRed,
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final pairCharStyle = TextStyle(
                  fontSize: 19.0 * s,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  color: ink,
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final pairGodStyle = TextStyle(
                  fontSize: 19.0 * s,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  color: sealRed,
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final ganColW = 20.0 * s;

                final footerStyle = TextStyle(
                  fontSize: 14.0 * s,
                  height: 1.0,
                  color: InkTheme.inkMuted,
                  fontWeight: FontWeight.w700,
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final header = Padding(
                  padding: EdgeInsets.fromLTRB(8.0 * s, 8.0 * s, 8.0 * s, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${date.day}', style: dateStyle),
                          if (isToday) ...[
                            SizedBox(width: 6.0 * s),
                            Container(
                              width: 6.0 * s,
                              height: 6.0 * s,
                              margin: EdgeInsets.only(top: 4.0 * s),
                              decoration: BoxDecoration(
                                color: sealRed,
                                borderRadius: BorderRadius.circular(2.0 * s),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (jieQi.trim().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 6.0 * s),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 8.0 * s,
                                height: 8.0 * s,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: sealRed.withAlpha(190),
                                    // border: Border.all(
                                    //   color: ink.withOpacity(0.55),
                                    //   width: 1.2 * s,
                                    // ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.0 * s),
                              Text(
                                jieQi,
                                style: jieQiStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );

                final main = Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      10.0 * s,
                      5.0 * s,
                      10.0 * s,
                      5.0 * s,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 10,
                          child: Center(
                            child: Transform.translate(
                              offset: Offset(4.0 * s, -4.0 * s),
                              child: _vertical('$ganText$zhiText', pillarStyle),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  // color: Colors.black.withOpacity(0.10),
                                  color: ganZhiLineColor,
                                  width: 1.0 * s,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.only(left: 10.0 * s),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: ganColW,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: ganColW,
                                          height: ganColW,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: sealRed,
                                            // color: Colors.black.withOpacity(
                                            //   0.10,
                                            // ),
                                            borderRadius: BorderRadius.circular(
                                              6.0 * s,
                                            ),
                                          ),
                                          child: Text(
                                            '干',
                                            style: pairCharStyle.copyWith(
                                              color: Colors.white,
                                              height: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.0 * s),
                                    Flexible(
                                      child: Text(
                                        tenGodName,
                                        style: heavenGodStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0 * s),
                                for (final it in hidden)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4.0 * s),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: ganColW,
                                          child: Text(
                                            it.gan,
                                            style: pairCharStyle,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 12.0 * s),
                                        Flexible(
                                          child: Text(
                                            it.tenGod,
                                            style: pairGodStyle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                final footer = Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 32.0 * s),
                  padding: EdgeInsets.symmetric(vertical: 7.0 * s),
                  decoration: BoxDecoration(
                    color: isLunarHighlight
                        ? sealRed.withOpacity(0.08)
                        : Colors.black.withOpacity(0.03),
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withOpacity(0.05),
                        width: 1.0 * s,
                      ),
                    ),
                  ),
                  child: Text(
                    lunarText,
                    style: footerStyle.copyWith(
                      color: isLunarHighlight ? sealRed : null,
                      fontWeight: isLunarHighlight ? FontWeight.w900 : null,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );

                final card = DecoratedBox(
                  decoration: BoxDecoration(
                    color: paper,
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(color: ink, width: borderW),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        offset: Offset(4.0 * s, 4.0 * s),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(children: [header, main, footer]),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: isSelected ? 1.0 : 0.0,
                            child: Container(
                              width: 6.0 * s,
                              height: 6.0 * s,
                              decoration: BoxDecoration(
                                color: sealRed,
                                borderRadius: BorderRadius.circular(2.0 * s),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.noScaling),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(radius),
                      overlayColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return InkTheme.sealWash(26);
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.white.withAlpha(50);
                        }
                        return null;
                      }),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(radius),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: isHovered
                                ? InkTheme.paperHighlight
                                : Colors.transparent,
                          ),
                          child: card,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
