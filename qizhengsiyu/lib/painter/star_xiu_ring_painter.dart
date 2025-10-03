import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'dart:math' as math;

import '../domain/entities/models/naming_degree_pair.dart';
import '../domain/entities/models/zhou_tian_model.dart';
import '../domain/entities/models/star_inn_gong_degree.dart';


class StarXiuRingPainter extends CustomPainter {
  double outerSize;
  double innerSize;
  final ZhouTianModel zhouTianModel;
  final List<ConstellationPosition> constellationPositions;
  final Map<EnumStars, Color> sevenZhengColorMapper;

  double tickLength;
  double longTickLength;
  double get ringWidth => (outerSize - innerSize) * .5;

  StarXiuRingPainter(
      {
      required this.outerSize,
      required this.innerSize,
      required this.zhouTianModel,
      required this.constellationPositions,
      required this.sevenZhengColorMapper,
      this.tickLength = 5,
      this.longTickLength = 10});
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final Offset canvasCenter = Offset(centerX, centerY);

    final double outerRadius = size.width / 2;
    final double innerRadius = outerRadius - ringWidth;

    final Paint ringPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = .5
      ..style = PaintingStyle.stroke;

    // Draw outer ring
    canvas.drawCircle(canvasCenter, outerRadius, ringPaint);

    // Draw inner ring
    canvas.drawCircle(canvasCenter, innerRadius, ringPaint);

    final Paint scalePaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = .5
      ..style = PaintingStyle.stroke;

    final rectCircle = Rect.fromCircle(
        center: canvasCenter, radius: innerRadius + (ringWidth * .5));

    for (ConstellationPosition starXiuType in constellationPositions) {
      final double angle = (zhouTianModel.totalDegree - starXiuType.startAtDegree) * math.pi / 180;
      final double sweepAngle = -starXiuType.degree * math.pi / 180;

      final path = Path()..addArc(rectCircle, angle, sweepAngle);
      final paint = Paint()
        ..color = sevenZhengColorMapper[starXiuType.constellation.sevenZheng]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth - 10; // 调整线宽
      canvas.drawPath(path, paint);
    }
    for (ConstellationPosition starXiuType in constellationPositions) {
      // double lineLength = ringWidth;
      drawXingXiuName(
          canvas, starXiuType, canvasCenter, outerRadius, ringWidth);
    }
    drawScale(canvas, canvasCenter, outerRadius, innerRadius);
  }

  void drawScale(
      Canvas canvas, Offset center, double outerRadius, double innerRadius) {
    Paint scalePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = .5
      ..style = PaintingStyle.stroke;

    final double centerX = center.dx;
    final double centerY = center.dy;
    for (int i = 0; i < 360; i++) {
      final double angle = i * math.pi / 180;
      double cosAngle = math.cos(angle);
      double sinAngle = math.sin(angle);
      double length = tickLength;
      if (i % 15 == 0) {
        length = tickLength * 2;
      } else if (i % 5 == 0) {
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
  }

  void drawXingXiuName(Canvas canvas, ConstellationPosition starXiuType,
      Offset canvasCenter, double outerRadius, double lineLength) {
    double angle =
        (zhouTianModel.totalDegree - (starXiuType.startAtDegree + starXiuType.degree * .5)) *
            math.pi /
            180;
    final double cosAngle = math.cos(angle);
    final double sinAngle = math.sin(angle);
    final double outerX = canvasCenter.dx + outerRadius * cosAngle;
    final double outerY = canvasCenter.dy + outerRadius * sinAngle;
    final double innerX =
        canvasCenter.dx + (outerRadius - lineLength) * cosAngle;
    final double innerY =
        canvasCenter.dy + (outerRadius - lineLength) * sinAngle;
    Offset xingXiuArcRingCenter =
        Offset((outerX + innerX) * .5, (outerY + innerY) * .5);

    final textPainter = TextPainter(
      text: TextSpan(
          text: starXiuType.constellation.starName,
          style: GoogleFonts.maShanZheng(
              fontSize: 16.0,
              height: 1,
              color: const Color.fromRGBO(55, 53, 52, 1),
              shadows: [
                BoxShadow(
                  color: Colors.black38.withOpacity(.1),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(1, 1), // changes position of shadow
                )
              ])
          // style: TextStyle(fontSize: 16.0,height: 1)
          ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final offset = Offset(-textPainter.width / 2, -textPainter.height / 2);
    canvas.save();
    canvas.translate(xingXiuArcRingCenter.dx, xingXiuArcRingCenter.dy);
    canvas.rotate(-30 * math.pi / 180);
    textPainter.paint(canvas, offset);
    canvas.restore();
  }





  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
