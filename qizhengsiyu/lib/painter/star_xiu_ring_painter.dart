import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'dart:math' as math;

import '../models/star_inn_gong_degree.dart';

import 'package:qizhengsiyu/services/drawing_strategy.dart';

class StarXiuRingPainter extends CustomPainter {
  double outerSize;
  double innerSize;
  final DrawingStrategy strategy;
  Map<TwentyEightStarInn, StarInnGongDegreeInfo> mapper;
  Map<EnumStars, Color> sevenZhengColorMapper;

  double tickLength;
  double longTickLength;
  double get ringWidth => (outerSize - innerSize) * .5;

  StarXiuRingPainter(
      {
      // required this.ringWidth,
      required this.outerSize,
      required this.innerSize,
      required this.strategy,
      required this.mapper,
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

    final rectCircle = Rect.fromCircle(center: canvasCenter, radius: innerRadius + (ringWidth * .5));

    final totalDivisions = strategy.getTotalDivisions();
    final scaleFactor = totalDivisions / 360.0;

    // Helper to convert logical angle to canvas radian
    double angleToRadian(double angle) {
      return (angle / totalDivisions) * 2 * math.pi;
    }

    for (StarInnGongDegreeInfo starXiuType in mapper.values) {
      final scaledStartAngle = starXiuType.degreeStartAt * scaleFactor;
      final scaledTotalDegree = starXiuType.totalDegree * scaleFactor;

      final double startAngle = angleToRadian(totalDivisions - scaledStartAngle);
      final double sweepAngle = -angleToRadian(scaledTotalDegree);

      final path = Path()..addArc(rectCircle, startAngle, sweepAngle);
      final paint = Paint()
        ..color = sevenZhengColorMapper[starXiuType.starXiu.sevenZheng]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth - 10; // 调整线宽
      canvas.drawPath(path, paint);
    }

    for (StarInnGongDegreeInfo starXiuType in mapper.values) {
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
    final totalDivisions = strategy.getTotalDivisions();

    for (int i = 0; i < totalDivisions; i++) {
      final double angle = (i / totalDivisions) * 2 * math.pi;
      double cosAngle = math.cos(angle);
      double sinAngle = math.sin(angle);
      double length = tickLength;

      // Keep the tick length logic based on degrees for consistency
      int degree = (i * 360 / totalDivisions).round();
      if (degree % 15 == 0) {
        length = tickLength * 2;
      } else if (degree % 5 == 0) {
        length = tickLength * 1.5;
      }

      double outerXY = outerRadius - length;
      final double outerX = centerX + outerRadius * cosAngle;
      final double outerY = centerY + outerRadius * sinAngle;
      final double innerX = centerX + outerXY * cosAngle;
      final double innerY = centerY + outerXY * sinAngle;

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

      canvas.drawLine(
        Offset(innerTickStartX, innerTickStartY),
        Offset(innerTickEndX, innerTickEndY),
        scalePaint,
      );
    }
  }

  void drawXingXiuName(Canvas canvas, StarInnGongDegreeInfo starXiuType,
      Offset canvasCenter, double outerRadius, double lineLength) {
    final totalDivisions = strategy.getTotalDivisions();
    final scaleFactor = totalDivisions / 360.0;

    final scaledStartAngle = starXiuType.degreeStartAt * scaleFactor;
    final scaledTotalDegree = starXiuType.totalDegree * scaleFactor;
    final centerAngle = scaledStartAngle + scaledTotalDegree / 2;

    double angle = (totalDivisions - centerAngle) / totalDivisions * 2 * math.pi;
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
          text: starXiuType.starXiu.starName,
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

  void paint_bak(Canvas canvas, Size size) {
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
      ..color = Colors.blueAccent
      ..strokeWidth = .5
      ..style = PaintingStyle.stroke;
    for (StarInnGongDegreeInfo starXiuType in mapper.values) {
      final double angle = (360 - starXiuType.degreeStartAt) * math.pi / 180;
      double lineLength = ringWidth;
      final double outerX = centerX + outerRadius * math.cos(angle);
      final double outerY = centerY + outerRadius * math.sin(angle);
      final double innerX =
          centerX + (outerRadius - lineLength) * math.cos(angle);
      final double innerY =
          centerY + (outerRadius - lineLength) * math.sin(angle);
      if (starXiuType.starXiu == TwentyEightStarInn.Lou_Jin_Gou) {
        canvas.drawLine(
          Offset(outerX, outerY),
          Offset(innerX, innerY),
          Paint()
            ..color = Colors.orange
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        );

        // double _angle = (360 - (15.9+5.2)) * math.pi / 180;
        double angle0 =
            (360 - (starXiuType.degreeStartAt + starXiuType.totalDegree * .5)) *
                math.pi /
                180;
        final double outerX0 = centerX + outerRadius * math.cos(angle0);
        final double outerY0 = centerY + outerRadius * math.sin(angle0);
        final double innerX0 =
            centerX + (outerRadius - lineLength) * math.cos(angle0);
        final double innerY0 =
            centerY + (outerRadius - lineLength) * math.sin(angle0);
        // canvas.drawLine(
        //   Offset(_outerX, _outerY),
        //   Offset(_innerX, _innerY),
        //   Paint()
        //     ..color = Colors.green
        //     ..strokeWidth = 1
        //     ..style = PaintingStyle.stroke,
        // );
        Offset xingXiuArcRingCenter =
            Offset((outerX0 + innerX0) * .5, (outerY0 + innerY0) * .5);
        // canvas.drawCircle(Offset((_outerX+_innerX) * .5, (_outerY+_innerY) * .5), 3,  Paint()..color = Colors.black87);
        final textPainter = TextPainter(
          text: TextSpan(
              text: starXiuType.starXiu.starName,
              style: const TextStyle(fontSize: 16.0, height: 1)),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        // textPainter.paint(canvas, xingXiuArcRingCenter + offset);

        // final center = Offset(size.width / 2, size.height / 2);
        final offset = Offset(-textPainter.width / 2, -textPainter.height / 2);
        canvas.save();
        canvas.translate(xingXiuArcRingCenter.dx, xingXiuArcRingCenter.dy);
        canvas.rotate(angle);
        textPainter.paint(canvas, offset);
        canvas.restore();
      } else if (starXiuType.starXiu == TwentyEightStarInn.Wei_Tu_Zhi) {
        canvas.drawLine(
          Offset(outerX, outerY),
          Offset(innerX, innerY),
          Paint()
            ..color = Colors.deepOrange
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke,
        );
      } else {
        canvas.drawLine(
          Offset(outerX, outerY),
          Offset(innerX, innerY),
          scalePaint,
        );
      }
    }

    final center = Offset(size.width / 2, size.height / 2);
    final averageRadius = (innerRadius + outerRadius) / 2;
    const arcRadians = (360 - 10.4 + 15.9) * (math.pi / 180);
    final centerPointAngle = arcRadians / 2;
    final centerPointX = center.dx + averageRadius * math.cos(centerPointAngle);
    final centerPointY = center.dy + averageRadius * math.sin(centerPointAngle);
    canvas.drawCircle(
        Offset(centerPointX, centerPointY), 2, Paint()..color = Colors.red);
  }

  void paint_helper_bak(
      double angle,
      double outerRadius,
      double innerRadius,
      double centerX,
      double centerY,
      StarInnGongDegreeInfo starXiuType,
      Canvas canvas) {
    final double cosAngle = math.cos(angle);
    final double sinAngle = math.sin(angle);

    // double lineLength = ringWidth;
    final double outerX = centerX + outerRadius * cosAngle;
    final double outerY = centerY + outerRadius * sinAngle;
    final double innerX = centerX + innerRadius * cosAngle;
    final double innerY = centerY + innerRadius * sinAngle;

    if (starXiuType.starXiu == TwentyEightStarInn.Lou_Jin_Gou) {
      // 可以用来绘制 “选择框”
      // canvas.drawArc(
      //     Rect.fromCircle(
      //         center: canvasCenter, radius: outerRadius),
      //     angle,
      //     sweepAngle,
      //     true,
      //     Paint()
      //       ..color = Colors.blueAccent
      //       ..strokeWidth = 2
      //       ..style = PaintingStyle.stroke);

      canvas.drawLine(
        Offset(outerX, outerY),
        Offset(innerX, innerY),
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
    } else if (starXiuType.starXiu == TwentyEightStarInn.Wei_Tu_Zhi) {
      canvas.drawLine(
        Offset(outerX, outerY),
        Offset(innerX, innerY),
        Paint()
          ..color = Colors.deepOrange
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
    } else {
      Paint scalePaint = Paint()
        ..color = Colors.black87
        ..strokeWidth = .5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(outerX, outerY),
        Offset(innerX, innerY),
        scalePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
