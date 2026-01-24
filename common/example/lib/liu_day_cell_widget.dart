import 'package:flutter/material.dart';
import 'yun_liu_table_common.dart';
import 'yun_liu_table_common.dart';

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

  const LiuDayCellWidget({
    super.key,
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
  });

  Widget _vertical(String text, TextStyle style) {
    final chars = text.split('');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [for (final c in chars) Text(c, style: style)],
    );
  }

  @override
  Widget build(BuildContext context) {
    const paper = Color(0xFFFCFAF2);
    const ink = Color(0xFF1A1A1A);
    const sealRed = Color(0xFFB22222);

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
                  color: ink.withAlpha(100),
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final heavenGodStyle = TextStyle(
                  fontSize: 18.0 * s,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  color: sealRed,
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final pairCharStyle = TextStyle(
                  fontSize: 18.0 * s,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  color: ink,
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final pairGodStyle = TextStyle(
                  fontSize: 18.0 * s,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  color: sealRed,
                  fontFamilyFallback: const ['Noto Serif SC', 'serif'],
                );

                final ganColW = 18.0 * s;

                final footerStyle = TextStyle(
                  fontSize: 14.0 * s,
                  height: 1.0,
                  color: const Color(0xFF666666),
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
                                  color: ink.withOpacity(0.55),
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
                                  color: Colors.black.withOpacity(0.10),
                                  width: 1.0 * s,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.only(left: 10.0 * s),
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 18.0 * s,
                                          height: 18.0 * s,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.10,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4.0 * s,
                                            ),
                                          ),
                                          child: Text(
                                            '干',
                                            style: pairCharStyle.copyWith(
                                              color: sealRed,
                                              fontSize: 12.0 * s,
                                              height: 1.0,
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 4.0 * s),
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
                                    SizedBox(height: 4.0 * s),
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
                                            SizedBox(width: 4.0 * s),
                                            Container(
                                              width: 1.0 * s,
                                              height: 18.0 * s,
                                              color: Colors.black.withOpacity(
                                                0.10,
                                              ),
                                            ),
                                            SizedBox(width: 6.0 * s),
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
                    color: Colors.black.withOpacity(0.03),
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withOpacity(0.05),
                        width: 1.0 * s,
                      ),
                    ),
                  ),
                  child: Text(
                    lunarText,
                    style: footerStyle,
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
                                ? const Color(0xFFF2EFE5)
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
