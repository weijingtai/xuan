import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:common/enums.dart';

class InkTheme {
  static const paper = Color(0xFFF7F2E8);
  static const paperHi = Color(0xFFFFFBF2);
  static const ink = Color(0xFF2D2D2D);
  static const seal = Color(0xFFB23A2B);

  static Color line([int a = 70]) => ink.withAlpha(a);
  static Color wash([int a = 18]) => ink.withAlpha(a);
  static Color washHi([int a = 10]) => ink.withAlpha(a);
  static Color sealWash([int a = 44]) => seal.withAlpha(a);
}

class DayCellDashedLinePainter extends CustomPainter {
  final Color color;

  const DayCellDashedLinePainter({required this.color});

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
  bool shouldRepaint(covariant DayCellDashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class InkHoverRegion extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;

  const InkHoverRegion({super.key, required this.builder});

  @override
  State<InkHoverRegion> createState() => _InkHoverRegionState();
}

class _InkHoverRegionState extends State<InkHoverRegion> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: widget.builder(context, _isHovered),
    );
  }
}

class PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    const step = 18.0;

    for (var y = 0.0; y < size.height; y += step) {
      for (var x = 0.0; x < size.width; x += step) {
        final xi = x.toInt();
        final yi = y.toInt();
        final n = (xi * 37 + yi * 17) % 19;
        final a = 6 + (n % 9);
        p.color = InkTheme.ink.withAlpha(a);
        final r = (n % 3 == 0) ? 0.7 : 0.5;
        final dx = ((n % 5) - 2) * 0.6;
        final dy = (((n * 3) % 5) - 2) * 0.6;
        canvas.drawCircle(Offset(x + dx, y + dy), r, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class YunLiuHelper {
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

  static const int yearCount = 10;
  static const int yearStartBase = 2024;

  static List<({TianGan gan, EnumTenGods hiddenGods})> hiddenGansForSeed(int seed) {
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

  static List<({TianGan gan, EnumTenGods tenGod})> tenGodDetailsForSeed(int seed) {
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

class StampIndicator extends Decoration {
  final double stampWidth;
  final double stampHeight;
  final double rotation;

  const StampIndicator({
    required this.stampWidth,
    required this.stampHeight,
    required this.rotation,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _StampIndicatorPainter(
      stampWidth: stampWidth,
      stampHeight: stampHeight,
      rotation: rotation,
    );
  }
}

class _StampIndicatorPainter extends BoxPainter {
  final double stampWidth;
  final double stampHeight;
  final double rotation;

  _StampIndicatorPainter({
    required this.stampWidth,
    required this.stampHeight,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;

    final tabRect = offset & size;
    final center = Offset(
      tabRect.center.dx,
      tabRect.bottom - (stampHeight / 2) - 4,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: stampWidth.clamp(0.0, tabRect.width),
      height: stampHeight,
    );

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));

    final shadow = Paint()..color = InkTheme.ink.withAlpha(18);
    canvas.drawRRect(rrect.shift(const Offset(0.6, 1.1)), shadow);

    final fill = Paint()..color = InkTheme.seal.withAlpha(76);
    final stroke = Paint()
      ..color = InkTheme.seal.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, stroke);

    final dot = Paint()..color = InkTheme.seal.withAlpha(95);
    for (var i = -2; i <= 2; i++) {
      final x = rect.left + (rect.width / 5) * (i + 2.5);
      canvas.drawCircle(Offset(x, rect.top + 1.3), 0.7, dot);
      canvas.drawCircle(Offset(x, rect.bottom - 1.3), 0.7, dot);
    }
    canvas.restore();
  }
}

class InkScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

class DoubleInkBorder extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const DoubleInkBorder({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: InkTheme.line(70), width: 0.6),
        borderRadius: borderRadius,
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: InkTheme.line(55), width: 0.6),
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

class InkIconButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onTap;
  final IconData icon;

  const InkIconButton({
    super.key,
    required this.tooltip,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: radius,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return InkTheme.wash(24);
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withAlpha(90);
          }
          return null;
        }),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: InkTheme.line(60), width: 0.6),
              color: Colors.white.withAlpha(160),
              borderRadius: radius,
            ),
            child: Icon(icon, size: 18, color: InkTheme.ink.withAlpha(190)),
          ),
        ),
      ),
    );
  }
}

class Corner extends StatelessWidget {
  final bool flipX;
  final bool flipY;

  const Corner({super.key, this.flipX = false, this.flipY = false});

  @override
  Widget build(BuildContext context) {
    final base = SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: CornerPainter()),
    );

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(
        flipX ? -1.0 : 1.0,
        flipY ? -1.0 : 1.0,
        1.0,
      ),
      child: base,
    );
  }
}

class CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = InkTheme.line(90)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    canvas.drawLine(const Offset(0, 0), Offset(w, 0), p);
    canvas.drawLine(const Offset(0, 0), Offset(0, h), p);
    canvas.drawLine(Offset(0, h * 0.55), Offset(w * 0.55, h), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
