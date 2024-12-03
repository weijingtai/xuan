import 'package:flutter/material.dart';
import 'dart:math' as math;

class RingScalePainter extends CustomPainter {
  final double ringWidth;
  final double tickLength;
  final double longTickLength;
  final List<double> longTickAngles;

  RingScalePainter({
    required this.ringWidth,
    required this.tickLength,
    required this.longTickLength,
    required this.longTickAngles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = size.width / 2;
    final double innerRadius = outerRadius - ringWidth;
    final Paint ringPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = .5
      ..style = PaintingStyle.stroke;

    // Draw outer ring
    canvas.drawCircle(Offset(centerX, centerY), outerRadius, ringPaint);

    // Draw inner ring
    canvas.drawCircle(Offset(centerX, centerY), innerRadius, ringPaint);

    final Paint scalePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = .5
      ..style = PaintingStyle.stroke;

    // Draw regular tick marks
    for (int i = 0; i < 360; i++) {
      final double angle = i * math.pi / 180;
      double cosAngle = math.cos(angle);
      double sinAngle = math.sin(angle);
      double length = tickLength;
      if (i % 15 == 0){
        length = tickLength * 2;
      }else if (i % 5 == 0){
        length = tickLength * 1.5;
      }
      double outerXY = outerRadius - length;
      final double outerX = centerX + outerRadius * cosAngle;
      final double outerY = centerY + outerRadius * sinAngle;
      final double innerX = centerX + outerXY * cosAngle;
      final double innerY = centerY + outerXY * sinAngle;
      // Draw scale line near the outer ring
      canvas.drawLine(
        Offset(outerX, outerY),
        Offset(innerX, innerY),
        scalePaint,
      );
      double innerXY = innerRadius + length;
      final double innerTickStartX = centerX + innerRadius * cosAngle;
      final double innerTickStartY = centerY + innerRadius * sinAngle;
      final double innerTickEndX = centerX + innerXY * cosAngle;
      final double innerTickEndY = centerY + innerXY * sinAngle;

      // Draw scale line near the inner ring
      canvas.drawLine(
        Offset(innerTickStartX, innerTickStartY),
        Offset(innerTickEndX, innerTickEndY),
        scalePaint,
      );
    }
    // if (longTickAngles.isEmpty) {
    //   return ;
    // }
    // Draw longer tick marks based on the provided angles

    // double innerTickStartXY = (innerRadius - longTickLength);
    // double innerTickEndXY = innerTickStartXY;

    // for (double angleDegree in List.generate(12, (i)=>i*30)) {
    //
    //   final double angle = angleDegree * math.pi / 180;
    //   double cosAngle = math.cos(angle);
    //   double sinAngle = math.sin(angle);
    //   final double outerX = centerX + outerRadius * cosAngle;
    //   final double outerY = centerY + sinAngle;
    //   final double innerX = centerX + innerTickStartXY * cosAngle;
    //   final double innerY = centerY + innerTickStartXY * sinAngle;
    //
    //   // Draw longer scale line near the outer ring
    //   canvas.drawLine(
    //     Offset(outerX, outerY),
    //     Offset(innerX, innerY),
    //     scalePaint,
    //   );
    //   // Draw longer scale line near the inner ring
    //   final double innerTickStartX = centerX + innerRadius * cosAngle;
    //   final double innerTickStartY = centerY + innerRadius * sinAngle;
    //   final double innerTickEndX = centerX + innerTickEndXY * cosAngle;
    //   final double innerTickEndY = centerY + innerTickEndXY * sinAngle;
    //
    //   canvas.drawLine(
    //     Offset(innerTickStartX, innerTickStartY),
    //     Offset(innerTickEndX, innerTickEndY),
    //     scalePaint,
    //   );
    //
    // }

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
