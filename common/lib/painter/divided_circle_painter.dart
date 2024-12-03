import 'package:flutter/material.dart';
import 'dart:math' as math;
class DividedCirclePainter extends CustomPainter {
  final int divisions;

  DividedCirclePainter({required this.divisions});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    final double center = size.width / 2;
    final double radius = center - paint.strokeWidth / 2;

    for (int i = 0; i < divisions; i++) {
      final double startAngle = (i * (2 * math.pi / divisions));
      final double sweepAngle = (2 * math.pi / divisions);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(center, center), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
