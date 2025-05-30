import 'dart:math' as math;

import 'package:flutter/material.dart';

class SectorPainterV2 extends CustomPainter {
  final double startAngle; // 扇环绘制的起始角度（相对于其自身坐标系）
  final double sweepRadian;
  final Color color;
  final double outerRadius;
  final double innerRadius;
  final Color borderColor; // 新增边框颜色参数
  final double borderWidth; // 新增边框宽度参数

  Text? singleText;

  SectorPainterV2({
    required this.startAngle,
    required this.sweepRadian,
    required this.color,
    required this.outerRadius,
    required this.innerRadius,
    this.borderColor = Colors.black12, // 默认边框颜色
    this.borderWidth = 1.0, // 默认边框宽度
    this.singleText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final Rect innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    // 绘制填充扇形
    final Paint fillPaint = Paint()..color = color;
    final Path fillPath = Path()
      ..moveTo(center.dx + innerRadius * math.cos(startAngle),
          center.dy + innerRadius * math.sin(startAngle))
      ..arcTo(outerRect, startAngle, sweepRadian, false)
      ..arcTo(innerRect, startAngle + sweepRadian, -sweepRadian, false)
      ..close();
    canvas.drawPath(fillPath, fillPaint);

    // 绘制扇形边框
    if (borderWidth > 0) {
      final Paint borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      // 绘制外弧线
      canvas.drawArc(outerRect, startAngle, sweepRadian, false, borderPaint);
      // 绘制内弧线
      canvas.drawArc(innerRect, startAngle, sweepRadian, false, borderPaint);

      // 绘制两条径向边线
      canvas.drawLine(
        Offset(center.dx + innerRadius * math.cos(startAngle),
            center.dy + innerRadius * math.sin(startAngle)),
        Offset(center.dx + outerRadius * math.cos(startAngle),
            center.dy + outerRadius * math.sin(startAngle)),
        borderPaint,
      );
      canvas.drawLine(
        Offset(center.dx + innerRadius * math.cos(startAngle + sweepRadian),
            center.dy + innerRadius * math.sin(startAngle + sweepRadian)),
        Offset(center.dx + outerRadius * math.cos(startAngle + sweepRadian),
            center.dy + outerRadius * math.sin(startAngle + sweepRadian)),
        borderPaint,
      );
    }

    // 绘制扇环的中心点
    final double middleRadius = (innerRadius + outerRadius) / 2;
    final double sectorCenterAngle = startAngle + sweepRadian / 2;
    final Offset sectorCenter = Offset(
      center.dx + middleRadius * math.cos(sectorCenterAngle),
      center.dy + middleRadius * math.sin(sectorCenterAngle),
    );
    // final Paint centerDotPaint = Paint()..color = Colors.red;
    // canvas.drawCircle(sectorCenter, 2, centerDotPaint);

    // 绘制文字
    if (singleText != null) {
      // 保存canvas状态
      canvas.save();

      // 将canvas原点移动到扇环中心点
      canvas.translate(sectorCenter.dx, sectorCenter.dy);

      // 旋转canvas使文字方向正确
      canvas.rotate(sectorCenterAngle - startAngle);

      // 绘制文字，计算文字所在位置，
      // 要求文字的中心必须与扇环的中心点重合
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: "1",
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final Offset textOffset =
          Offset(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, textOffset);

      // 恢复canvas状态
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SectorPainterV2 oldDelegate) {
    return oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepRadian != sweepRadian ||
        oldDelegate.color != color ||
        oldDelegate.outerRadius != outerRadius ||
        oldDelegate.innerRadius != innerRadius ||
        oldDelegate.borderColor != borderColor || // 检查边框颜色是否变化
        oldDelegate.borderWidth != borderWidth; // 检查边框宽度是否变化
  }
}
