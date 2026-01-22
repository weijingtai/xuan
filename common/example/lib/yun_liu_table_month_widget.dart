import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class YunLiuTableMonthWidget extends StatelessWidget {
  final TianGan tianGan;
  final DiZhi diZhi;
  final EnumTenGods tenGod;
  final List<({TianGan gan, EnumTenGods tenGod})> tenGodDetails;

  const YunLiuTableMonthWidget({
    super.key,
    required this.tianGan,
    required this.diZhi,
    required this.tenGod,
    required this.tenGodDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const primary = Color(0xFF9E2A2B);
    const primaryLight = Color(0xFFD64545);
    const accentGreen = Color(0xFF4A7C59);

    const inkBlack = Color(0xFF1A1A1A);
    const inkLight = Color(0xFFE5E5E5);

    const mutedGray = Color(0xFF8C8C8C);
    const borderLight = Color(0xFFE3E0D8);
    const borderDark = Color(0xFF33302C);

    final textInk = isDark ? inkLight : inkBlack;
    final borderColor = isDark ? borderDark : borderLight;
    final primaryText = isDark ? primaryLight : primary;

    final backgroundTo = isDark
        ? Colors.white.withAlpha(13)
        : const Color(0xFFFAFAF9).withAlpha(128);

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
      color: mutedGray,
      fontFamilyFallback: const ['Noto Serif SC', 'serif'],
    );

    return SizedBox(
      height: 96,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
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
                      color: accentGreen.withAlpha(153),
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
                painter: _DashedLinePainter(
                  color: isDark
                      // ? const Color(0xFF57534E)
                      ? const Color(0xFF57534E)
                      : const Color(0xFFD6D3D1),
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

class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dash = 3.0;
    const gap = 2.5;

    var y = 0.0;
    while (y < size.height) {
      final y2 = (y + dash).clamp(0.0, size.height);
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y2),
        paint,
      );
      y = y2 + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
