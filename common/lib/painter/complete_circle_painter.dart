import 'package:common/painter/draw_circle_painter.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
class CompleteCirclePainter extends CustomPainter {
  Color color;
  double degree;
  double height;
  List<String>? listContent;
  CompleteCirclePainter({
    this.height = 32,
    this.color = Colors.blue,
    this.degree = 30,
    this.listContent,
  });
  @override
  void paint(Canvas canvas, Size size) {
    // final double centerX = 300/ 2;
    // final double centerY = 300/ 2;


    // Paint paint = Paint()
    //   ..color = Colors.blue.withValues(alpha: .1)  // 设置背景颜色为蓝色
    //   ..style = PaintingStyle.fill;  // 设置绘图样式为填充
    //
    // // 创建一个与Canvas大小相同的矩形
    // Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 绘制矩形
    // canvas.drawRect(rect, paint);
    if (listContent != null) {
      // for each in listContent
      var total = listContent!.length;
      for (int i = 0; i < total; i++){
        canvas.save();
        canvas.translate(size.width / 2, size.height / 2);
        canvas.rotate(i * degree * math.pi / 180);
        canvas.translate(-size.width / 2, -size.height / 2);

        // 绘制矩形
        DrawCirclePainter(
          firstClockwiseVerticalBorderColor: Colors.black,
          firstClockwiseVerticalBorderWidth: 1,
          fanRingColor: color,
          height: height,
          degree: degree,
          text: listContent![i],
        ).paint(canvas, size);
        canvas.restore();
      }

    }
    else{
      var total = 360 / degree;
      for (int i = 0; i < total; i++){
        canvas.save();
        canvas.translate(size.width / 2, size.height / 2);
        canvas.rotate(i * degree * math.pi / 180);
        canvas.translate(-size.width / 2, -size.height / 2);

        // 绘制矩形
        DrawCirclePainter(
          firstClockwiseVerticalBorderColor: Colors.black,
          firstClockwiseVerticalBorderWidth: 1,
          fanRingColor: color,
          height: height,
          degree: degree,
        ).paint(canvas, size);
        canvas.restore();
      }
    }

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
