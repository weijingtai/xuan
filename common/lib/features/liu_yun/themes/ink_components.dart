import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'ink_theme.dart';

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

class DashedLinePainter extends CustomPainter {
  final Axis axis;
  final Color color;
  final double dashLength;
  final double gapLength;
  final double strokeWidth;

  const DashedLinePainter({
    required this.axis,
    required this.color,
    required this.dashLength,
    required this.gapLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double start = 0;
    final max = axis == Axis.vertical ? size.height : size.width;

    while (start < max) {
      final end = (start + dashLength).clamp(0.0, max);
      if (axis == Axis.vertical) {
        canvas.drawLine(
          Offset(size.width / 2, start),
          Offset(size.width / 2, end),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(start, size.height / 2),
          Offset(end, size.height / 2),
          paint,
        );
      }
      start = end + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) {
    return oldDelegate.axis != axis ||
        oldDelegate.color != color ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength ||
        oldDelegate.strokeWidth != strokeWidth;
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

class MinuteRulerPainter extends CustomPainter {
  final int? selectedMinute;

  const MinuteRulerPainter({required this.selectedMinute});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = InkTheme.line(90)
      ..strokeWidth = 1;

    final w = size.width;
    final h = size.height;

    for (var m = 0; m <= 60; m += 5) {
      final x = w * (m / 60.0);
      final isQuarter = (m % 15 == 0);
      final len = isQuarter ? h * 0.8 : h * 0.45;
      canvas.drawLine(Offset(x, h), Offset(x, h - len), p);
    }

    final sel = selectedMinute;
    if (sel != null) {
      final x = w * (sel / 60.0);
      final marker = Paint()
        ..color = InkTheme.seal.withAlpha(180)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      final fill = Paint()
        ..color = InkTheme.sealWash(48)
        ..style = PaintingStyle.fill;

      final center = Offset(x, h * 0.35);
      canvas.drawCircle(center, 6.0, fill);
      canvas.drawCircle(center, 6.0, marker);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
