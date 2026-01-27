import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'yun_liu_table_common.dart';
import '../themes/ink_theme.dart';

class LiuGanZhiMiniCell extends StatelessWidget {
  final String label;
  final String? timeRangeLabel;
  final Color? timeRangeColor;
  final String? jieQiLabel;
  final JiaZi jiaZi;
  final TianGan dayMaster;

  const LiuGanZhiMiniCell({
    required this.label,
    this.timeRangeLabel,
    this.timeRangeColor,
    this.jieQiLabel,
    required this.jiaZi,
    required this.dayMaster,
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
    const paper = InkTheme.paperSoft;
    const ink = InkTheme.inkDeep;
    const cinnabar = InkTheme.cinnabarAlt;
    const watermark = InkTheme.watermarkInk;
    const goldLine = InkTheme.goldLine;

    final range = (timeRangeLabel ?? '').trim();
    final jieQiText = (jieQiLabel ?? '').trim();

    const shichenAlias = {
      '子': '夜半',
      '丑': '鸡鸣',
      '寅': '平旦',
      '卯': '日出',
      '辰': '食时',
      '巳': '隅中',
      '午': '日中',
      '未': '日昳',
      '申': '晡时',
      '酉': '日入',
      '戌': '黄昏',
      '亥': '人定',
    };

    final heavenGod = jiaZi.tianGan.getTenGods(dayMaster).name;
    final hidden = jiaZi.diZhi.cangGan;

    return LayoutBuilder(
      builder: (context, c) {
        final s =
            ((c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight) / 160.0)
                .clamp(0.35, 2.0);

        final radius = 24.0 * s;

        final headerStyle = TextStyle(
          fontSize: 17.0 * s,
          height: 1.0,
          color: timeRangeColor ?? ink.withOpacity(0.6),
          fontWeight: FontWeight.w700,
          fontFamilyFallback: const ['Noto Serif SC', 'serif'],
        );

        final pillarStyle = TextStyle(
          fontSize: 36.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 4.0 * s,
          color: ink,
          fontFamilyFallback: const ['ZCOOL XiaoWei', 'Noto Serif SC', 'serif'],
        );

        final hGodStyle = TextStyle(
          fontSize: 20.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w900,
          color: cinnabar,
          fontFamilyFallback: const ['Noto Serif SC', 'serif'],
        );

        final rowStyle = TextStyle(
          fontSize: 17.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: ink,
          fontFamilyFallback: const ['Noto Serif SC', 'serif'],
        );

        final rowGodStyle = rowStyle.copyWith(
          color: cinnabar,
          fontWeight: FontWeight.w900,
        );

        final watermarkStyle = TextStyle(
          fontSize: 130.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w900,
          color: watermark,
          fontFamilyFallback: const ['Noto Serif SC', 'serif'],
        );

        final footerTextStyle = TextStyle(
          fontSize: 17.0 * s,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: ink.withOpacity(0.5),
          letterSpacing: 1.0 * s,
          fontFamilyFallback: const ['Noto Serif SC', 'serif'],
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: paper,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.black.withOpacity(0.05),
                width: 1.0 * s,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  right: -25.0 * s,
                  bottom: -40.0 * s,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -0.38,
                      child: Text(label, style: watermarkStyle),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0 * s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          range,
                          style: headerStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 6.0 * s),
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(width: 6.0 * s),
                            Expanded(
                              flex: 9,
                              child: Center(
                                child: _vertical(jiaZi.name, pillarStyle),
                              ),
                            ),
                            SizedBox(width: 10.0 * s),
                            Container(width: 1.5 * s, color: goldLine),
                            SizedBox(width: 8.0 * s),
                            Expanded(
                              flex: 13,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    heavenGod,
                                    style: hGodStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.0 * s),
                                  for (final g in hidden)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.0 * s),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 14.0 * s,
                                            child: Text(
                                              g.value,
                                              style: rowStyle,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          SizedBox(width: 4.0 * s),
                                          Flexible(
                                            child: Text(
                                              g.getTenGods(dayMaster).name,
                                              style: rowGodStyle,
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
                          ],
                        ),
                      ),
                      SizedBox(height: 6.0 * s),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: jieQiText.isNotEmpty
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.0 * s,
                                  vertical: 2.0 * s,
                                ),
                                decoration: BoxDecoration(
                                  color: cinnabar,
                                  borderRadius: BorderRadius.circular(10.0 * s),
                                ),
                                child: Text(
                                  jieQiText,
                                  style: footerTextStyle.copyWith(
                                    color: Colors.white.withOpacity(0.95),
                                    letterSpacing: 0,
                                  ),
                                ),
                              )
                            : Text(
                                '${label}时 · ${shichenAlias[label] ?? ''}',
                                style: footerTextStyle,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
