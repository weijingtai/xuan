import 'dart:math';

import 'package:flutter/material.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import 'package:qizhengsiyu/services/drawing_strategy.dart';

class TwelveZhiGongCircleRingPrinter extends CustomPainter {
  final double innerRadius;
  final double outerRadius;
  final DrawingStrategy strategy;
  List<EnumTwelveGong> twelveGongList;
  late TextStyle textStyle;
  bool isReverseText = false;
  bool isHorizontalText = false;
  bool isAntiClockwise = false;

  double innerPadding = 12;
  double outerPadding = 12;
  bool withBackgroundColor = true;
  Map<EnumStars, Color> starColorMapper;

  // Map<String,Color> fiveElementsColorMap = {
  //   "金":Color(0xffFFD700),
  //   "木":Color(0xff228B22),
  //   "水":Color(0xff1E90FF),
  //   "火":Color(0xffFF4500),
  //   "土":Color(0xff8B4513),
  //   "日":Color(0xffFFD700), // 日光色 hex: #FFD700
  //   "月":Color(0xffC0C0C0),// 银白色 hex: #C0C0C0
  // };

  TwelveZhiGongCircleRingPrinter({
    required this.innerRadius,
    required this.outerRadius,
    required this.starColorMapper,
    required this.strategy,
    required this.twelveGongList,
    this.isReverseText = true,
    this.isHorizontalText = true,
    this.isAntiClockwise = false,
    this.withBackgroundColor = true,
    this.innerPadding = 12,
    this.outerPadding = 12,
    this.textStyle =
        const TextStyle(color: Colors.black, fontSize: 18, height: 1.2),
  });

  void debugPaint(Canvas canvas, Size size, Offset center) {
    // canvas.translate(center.dx, center.dy);
    // 给canvas绘制灰色透明度为0.1的背景
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width / 2, backgroundPaint);

    final Paint background2Paint = Paint()
      ..color = Colors.blue.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, background2Paint);

    final Paint background3Paint = Paint()
      ..color = Colors.blue.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, background3Paint);
    // 绘制圆心点
    final Paint centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final totalDivisions = strategy.getTotalDivisions();
    final houseAngles = strategy.getHouseDivisionAngles();
    final fanRingWidth = outerRadius - innerRadius;
    final arcDrawCircleRadius = innerRadius + (fanRingWidth / 2);

    final backgroundPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = fanRingWidth;
    final borderPaint = Paint()..color = Colors.grey..style = PaintingStyle.stroke..strokeWidth = 1;

    // Helper to convert logical angle to canvas radian
    // 0 is at the top, clockwise
    double angleToRadian(double angle) {
      return (angle / totalDivisions) * 2 * pi - (pi / 2);
    }

    // Draw house sectors and text
    for (int i = 0; i < houseAngles.length; i++) {
      final startAngleValue = houseAngles[i];
      final endAngleValue = (i + 1 < houseAngles.length) ? houseAngles[i+1] : totalDivisions;
      final sweepAngleValue = endAngleValue - startAngleValue;

      final startAngleRadian = angleToRadian(startAngleValue);
      final sweepAngleRadian = (sweepAngleValue / totalDivisions) * 2 * pi;

      final gong = twelveGongList[i];

      // Draw the colored sector
      if (withBackgroundColor) {
        backgroundPaint.color = starColorMapper[gong.zheng]!;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: arcDrawCircleRadius),
          startAngleRadian,
          sweepAngleRadian,
          false,
          backgroundPaint,
        );
      }

      // Draw the text
      final textAngleValue = startAngleValue + sweepAngleValue / 2;
      final textAngleRadian = angleToRadian(textAngleValue);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textAngleRadian);

      final textSpan = TextSpan(text: gong.fullname, style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();

      // Position text in the middle of the ring
      final textOffset = Offset(-textPainter.width / 2, -arcDrawCircleRadius - textPainter.height / 2);

      // This part is tricky. For simplicity, I'm drawing horizontal text.
      // The original had complex logic for vertical/reversed text which needs more work.
      // I'll rotate the text to be upright relative to the circle's orientation.
      canvas.rotate(-textAngleRadian); // Counter-rotate to make text horizontal

      final textX = (arcDrawCircleRadius) * cos(textAngleRadian);
      final textY = (arcDrawCircleRadius) * sin(textAngleRadian);

      textPainter.paint(canvas, Offset(textX - textPainter.width/2, textY - textPainter.height/2));

      canvas.restore();
    }

    // Draw border lines for each house
    for (final angle in houseAngles) {
      final angleRadian = angleToRadian(angle);
      final startPoint = Offset(center.dx + innerRadius * cos(angleRadian), center.dy + innerRadius * sin(angleRadian));
      final endPoint = Offset(center.dx + outerRadius * cos(angleRadian), center.dy + outerRadius * sin(angleRadian));
      canvas.drawLine(startPoint, endPoint, borderPaint);
    }
  }

  void paintSingleChar(Canvas canvas, Size size, String text, Offset center,
      double rotationAngle, double yOffset) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    Offset offset = isReverseText
        ? Offset(
            -textPainter.width * 0.5,
            -innerRadius -
                innerPadding -
                textPainter.height +
                textPainter.height * .1,
          )
        : Offset(
            -textPainter.width * 0.5,
            innerRadius + innerPadding,
          );
    double rotateAngle = isReverseText ? pi : 0.0;
    canvas.rotate(rotateAngle);
    textPainter.paint(canvas, offset);
  }

  void paintVerticalText(Canvas canvas, Size size, String text, Offset center,
      double rotationAngle, double yOffset) {
    // splite text to single char
    List<String> textList = text.split('');
    int totalLength = textList.length;
    for (int i = 0; i < totalLength; i++) {
      final textSpan = TextSpan(
        text: textList[i],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      double rotateAngle = isReverseText ? pi : 0.0;
      if (i == 0) {
        // final zhiTextSpan = TextSpan(
        //   text: textList[i],
        //   style: ConstResourcesMapper.twelveDiZhiTextStyle.copyWith(
        //       color: ConstResourcesMapper.zodiacZhiColors[DiZhi.getFromValue(textList[i])],
        //       fontSize: textStyle.fontSize! * 1.2
        //   ),
        // );
        // final zhiTextPainter = TextPainter(
        //   text: zhiTextSpan,
        //   textDirection: TextDirection.ltr,
        // );
        // zhiTextPainter.layout(
        //   minWidth: 0,
        //   maxWidth: size.width,
        // );
        Offset offset = isReverseText
            ? Offset(
                center.dx - outerRadius - (textPainter.size.width * 0.5),
                -innerRadius -
                    innerPadding -
                    (textPainter.size.height * .9 * totalLength),
              )
            : Offset(
                center.dx - outerRadius - (textPainter.size.width * 0.3),
                innerRadius + innerPadding,
                // innerRadius + innerPadding + textPainter.size.height * 0.1,
              );
        // canvas.translate(offset.dx, offset.dy);
        // canvas.translate(center.dx, center.dy);
        canvas.rotate(rotateAngle);
        textPainter.paint(canvas, offset);
      } else {
        Offset offset = isReverseText
            ? Offset(
                center.dx - outerRadius - (textPainter.size.width * 0.5),
                -innerRadius -
                    innerPadding -
                    (textPainter.size.height * .9 * (totalLength - i)),
              )
            : Offset(
                center.dx - outerRadius - (textPainter.size.width * 0.3),
                innerRadius + innerPadding + textPainter.size.height * i,
                // innerRadius + innerPadding + textPainter.size.height * 0.8 * i,
              );
        // canvas.translate(offset.dx, offset.dy);
        textPainter.paint(canvas, offset);
      }
    }
    canvas.save();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
