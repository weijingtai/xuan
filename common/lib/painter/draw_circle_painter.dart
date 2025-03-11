import 'package:flutter/material.dart';
import 'dart:math' as math;

class DrawCirclePainter extends CustomPainter {
  double height;
  double degree;
  Color fanRingColor;

  double innerBorderWidth;
  Color innerBorderColor;
  double outerBorderWidth;
  Color outerBorderColor;
  double firstClockwiseVerticalBorderWidth;
  Color firstClockwiseVerticalBorderColor;
  double secondClockwiseVerticalBorderWidth;
  Color secondClockwiseVerticalBorderColor;
  TextStyle textStyle;
  String? text;
  DrawCirclePainter({
    this.text,
    required this.height,
    this.degree = 30,
    this.fanRingColor = Colors.blue,
    this.innerBorderWidth = 0,
    this.innerBorderColor = Colors.black,
    this.outerBorderWidth = 0,
    this.outerBorderColor = Colors.black,
    this.firstClockwiseVerticalBorderWidth = 0,
    this.firstClockwiseVerticalBorderColor = Colors.black,
    this.secondClockwiseVerticalBorderWidth = 0,
    this.secondClockwiseVerticalBorderColor = Colors.black,
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 16,
    ),
  });
  void _paintInnerBorder(
      Canvas canvas, double center, double radius, double radian) {
    if (innerBorderWidth <= 0) {
      return;
    }
    final Paint borderPaint = Paint()
      ..color = innerBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerBorderWidth;
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(center, center),
          radius: radius - height / 2 + innerBorderWidth / 2),
      0,
      radian,
      false,
      borderPaint,
    );
  }

  void _paintOuterBorder(
      Canvas canvas, double center, double radius, double radian) {
    if (outerBorderWidth <= 0) {
      return;
    }
    final Paint borderPaint = Paint()
      ..color = outerBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerBorderWidth;
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(center, center),
          radius: radius - height / 2 + outerBorderWidth / 2),
      0,
      radian,
      false,
      borderPaint,
    );
  }

  // 根据顺时针方向，第二个扇环的垂直边
  void _paintSecondClockwiseVerticalBorder(
      Canvas canvas, double center, double radius, double radian) {
    if (secondClockwiseVerticalBorderWidth <= 0) {
      return;
    }
    final Paint borderPaint = Paint()
      ..color = secondClockwiseVerticalBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = secondClockwiseVerticalBorderWidth;
    final Offset innerStart1 = Offset(
      center + (radius - height / 2) * math.cos(0),
      center + (radius - height / 2) * math.sin(0),
    );
    final Offset innerEnd1 = Offset(
      center + (radius + height / 2) * math.cos(0),
      center + (radius + height / 2) * math.sin(0),
    );
    canvas.drawLine(innerStart1, innerEnd1, borderPaint);
  }

  // 根据顺时针方向，第二个扇环的垂直边
  void _paintFirstClockwiseVerticalBorder(
      Canvas canvas, double center, double radius, double radian) {
    if (firstClockwiseVerticalBorderWidth <= 0) {
      return;
    }
    final Paint borderPaint = Paint()
      ..color = firstClockwiseVerticalBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = firstClockwiseVerticalBorderWidth;
    final Offset innerStart2 = Offset(
      center + (radius - height / 2) * math.cos(radian),
      center + (radius - height / 2) * math.sin(radian),
    );
    final Offset innerEnd2 = Offset(
      center + (radius + height / 2) * math.cos(radian),
      center + (radius + height / 2) * math.sin(radian),
    );
    canvas.drawLine(innerStart2, innerEnd2, borderPaint);
  }

  void paintFanRing(Canvas canvas, Size size) {
    double radian = degree * math.pi / 180;
    final Paint ringPaint = Paint()
      ..color = fanRingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = height;

    final double center = size.width / 2;
    // final double radius = center - height / 2;
    final double radius = size.height / 2;

    // canvas.translate(size.width, size.width);
    canvas.drawCircle(Offset(center, center), 4, Paint()..color = Colors.red);
    //

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center, center), radius: radius),
      0,
      radian,
      false,
      ringPaint,
    );

    // Draw the radius borders
    // Draw the vertical borders

    // Draw the inner border
    if (innerBorderWidth > 0) {
      _paintInnerBorder(canvas, center, radius, radian);
    }
    // Draw the outer border
    if (outerBorderWidth > 0) {
      _paintOuterBorder(canvas, center, radius, radian);
    }
    if (firstClockwiseVerticalBorderWidth > 0) {
      _paintFirstClockwiseVerticalBorder(canvas, center, radius, radian);
    }
    if (secondClockwiseVerticalBorderWidth > 0) {
      _paintSecondClockwiseVerticalBorder(canvas, center, radius, radian);
    }
    // Draw text
    if (text != null) {
      // final double textCenter = size.width / 2;
      // final double textRadius = textCenter - height / 2;
      final double textCenter = size.width / 2;
      final double textRadius = textCenter + 24 / 2;
      // final double angle = radian / 2;
      final double angle = (radian) * math.pi / 180;
      // final double angle = radian +( degree / 2) * math.pi / 180;
      // debugPrint('radian: $radian angle: $angle');
      // final double textX = textCenter + (textRadius + height / 2) * math.cos(angle) - 25;
      // final double textY = textCenter + (textRadius + height / 2) * math.sin(angle) - 10;
      // final double textX = textCenter + (textRadius + height / 2) * math.cos(angle) - 15;
      // final double textY = textCenter + (textRadius + height / 2) * math.sin(angle) - 15;
      // drawText(canvas, size, text!, Offset(textX, textY),angle);
      drawText(canvas, size, text!, const Offset(10, -3), 1 + angle);
    }
  }

  void drawText(Canvas canvas, Size size, String text, Offset offset,
      double rotationAngle) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      strutStyle: StrutStyle(
        fontWeight: textStyle.fontWeight,
      ),
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(rotationAngle);
    // final double textX = (size.width - textPainter.width) / 2;
    // final double textY = (height - textPainter.height) / 2;
    final double textX = -textPainter.width / 2;
    final double textY = -(textPainter.height + textStyle.fontSize!) / 2;
    textPainter.paint(canvas, Offset(textX, textY));
    canvas.restore();
  }

  void paintFanArc(Canvas canvas, Size size) {
    double sweepAngle = 30 * math.pi / 180;
    // 十二星座环外径
    double ringRadius = size.width / 2;

    Offset center = Offset(ringRadius, ringRadius);

// 十二星座边长
    double starSize = ringRadius / 5;

    for (int i = 0; i < 12; i++) {
      // 计算扇弧的起始角度
      double startAngle = i * sweepAngle;

      // 绘制扇弧
      canvas.drawArc(Rect.fromCircle(center: center, radius: ringRadius),
          startAngle, sweepAngle, false, Paint()..color = Colors.blue);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // this.paintFanArc(canvas, size);
    paintFanRing(canvas, size);
    return;
// 十二星座环外径
    double ringRadius = size.width / 2;

// 十二星座边长
    double starSize = ringRadius / 5;

// 绘制十二星座
    for (int i = 0; i < 12; i++) {
      // 计算每个星座的位置
      double x = ringRadius * math.cos(i * 30 * math.pi / 180) + ringRadius;
      double y = ringRadius * math.sin(i * 30 * math.pi / 180) + ringRadius;

      // 绘制星座图形
      canvas.drawRect(
          Rect.fromLTWH(x - starSize / 2, y - starSize / 2, starSize, starSize),
          Paint()..color = Colors.white);
    }

    Offset center = Offset(ringRadius, ringRadius);
// 绘制连接线
    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

//...
}
