import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'enums/enum_twelve_gong.dart';

class DaXianRaingPainter extends CustomPainter {
  final double startAngle; // 扇环绘制的起始角度（相对于其自身坐标系）
  final double sweepRadian;
  final double baseRadian;
  final Color color;
  final double outerRadius;
  final double innerRadius;
  final Color borderColor; // 新增边框颜色参数
  final double borderWidth; // 新增边框宽度参数

  Map<EnumTwelveGong, double> gongYearsMapper;
  List<EnumTwelveGong> gongOrderedSeq;

  final TextStyle textStyle;

  DaXianRaingPainter({
    required this.startAngle,
    required this.sweepRadian,
    required this.color,
    required this.outerRadius,
    required this.innerRadius,
    required this.gongYearsMapper,
    this.borderColor = Colors.black12, // 默认边框颜色
    this.borderWidth = 1.0, // 默认边框宽度
    required this.textStyle,
    required this.gongOrderedSeq,
  }) : baseRadian = startAngle * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final Rect innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    // 绘制扇环的中心点
    // final double middleRadius = (innerRadius + outerRadius) / 2;
    // final double sectorCenterAngle = startAngle + sweepRadian / 2;
    // final Offset sectorCenter = Offset(
    //   center.dx + middleRadius * math.cos(sectorCenterAngle),
    //   center.dy + middleRadius * math.sin(sectorCenterAngle),
    // );
    // final Paint centerDotPaint = Paint()..color = Colors.red;
    // canvas.drawCircle(sectorCenter, 2, centerDotPaint);

    double eachGongAngle = 360 / gongYearsMapper.length;
    double prevBaseYear = 0;
    for (var i = 0; i < gongOrderedSeq.length; i++) {
      double gongYears = gongYearsMapper[gongOrderedSeq[i]]!;
      double gongStartAngle = startAngle + eachGongAngle * i;
      double gongEndAngle = startAngle + eachGongAngle * (i + 1);
      printEachGong(canvas, center, outerRect, innerRect,
          gongIndex: i,
          totalSlot: gongYears,
          starAngle: gongStartAngle,
          endAngle: gongEndAngle,
          baseYear: prevBaseYear);
      prevBaseYear += gongYears;
    }
    // printEachYearSlot(canvas, sectorCenter, sectorCenterAngle);
  }

  _drawBackground(Canvas canvas,
      {required Offset center,
      required Rect outerRect,
      required Rect innerRect,
      required double startRadians,
      required double sweepRadians,
      required double radius,
      required int index}) {
    final Paint fillPaint = Paint()..color = color.withAlpha(index * 10);
    final Path fillPath = Path()
      ..moveTo(center.dx + innerRadius * math.cos(startRadians),
          center.dy + innerRadius * math.sin(startRadians))
      ..arcTo(outerRect, startRadians, sweepRadians, false)
      ..arcTo(innerRect, startRadians + sweepRadians, -sweepRadians, false)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
  }

  _drawBorder(Canvas canvas,
      {required Offset center,
      required Rect outerRect,
      required Rect innerRect,
      required double startRadians,
      required double sweepRadians,
      required double innerRadius,
      required double outerRadius,
      required int index}) {
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // 绘制外弧线
    canvas.drawArc(outerRect, startRadians, sweepRadians, false, borderPaint);
    // 绘制内弧线
    canvas.drawArc(innerRect, startRadians, sweepRadians, false, borderPaint);

    // 绘制两条径向边线
    canvas.drawLine(
      Offset(center.dx + innerRadius * math.cos(startRadians),
          center.dy + innerRadius * math.sin(startRadians)),
      Offset(center.dx + outerRadius * math.cos(startRadians),
          center.dy + outerRadius * math.sin(startRadians)),
      borderPaint,
    );
    canvas.drawLine(
      Offset(center.dx + innerRadius * math.cos(startRadians + sweepRadians),
          center.dy + innerRadius * math.sin(startRadians + sweepRadians)),
      Offset(center.dx + outerRadius * math.cos(startRadians + sweepRadians),
          center.dy + outerRadius * math.sin(startRadians + sweepRadians)),
      borderPaint,
    );
  }

  void printEachGong(
      Canvas canvas, Offset center, Rect outerRect, Rect innerRect,
      {required int gongIndex,
      required double totalSlot,
      required double starAngle,
      required double endAngle,
      required double baseYear}) {
    double gongAngle = endAngle - starAngle;
    // print("slotAngle: $slotAngle");
    double sweepRadians = gongAngle * math.pi / 180;
    double startRadians = starAngle * math.pi / 180;
    // 绘制填充扇形
    _drawBackground(canvas,
        center: center,
        outerRect: outerRect,
        innerRect: innerRect,
        startRadians: startRadians,
        sweepRadians: sweepRadians,
        radius: innerRadius,
        index: gongIndex);

    // 绘制扇形边框
    if (borderWidth > 0) {
      _drawBorder(canvas,
          center: center,
          outerRect: outerRect,
          innerRect: innerRect,
          startRadians: startRadians,
          sweepRadians: sweepRadians,
          innerRadius: innerRadius,
          outerRadius: outerRadius,
          index: gongIndex);
    }

    // 判断totalSlot是否为整数
    bool isInteger = totalSlot == totalSlot.toInt();
    if (isInteger) {
      // double eachSlotSweepRadians = (30 / totalSlot) * math.pi / 180;
      double eachSlotAngle = gongAngle / totalSlot;

      double _prevEndAngle = starAngle;
      for (var i = 0; i < totalSlot; i++) {
        printEachYearSlotV2(canvas, center, outerRect, innerRect,
            index: i,
            starAngle: _prevEndAngle,
            endAngle: _prevEndAngle + eachSlotAngle,
            baseYear: baseYear);
        _prevEndAngle += eachSlotAngle;
      }
    } else {
      // 绘制非整数的扇形
      // 以0.25 为 1季 (3个月) 为一个单位，
      // 假设slot为4.5，那么 4.5 * 12 = 54个月，绘制 18个slot，一个slot为1季（3个月）
      // 每4个slot绘制一次（1年）
      // print("第一年 ${baseYear + 1}");
      // print(totalSlot * 12);
      // print((totalSlot * 12) / 3);
      int totalSlots = ((totalSlot * 12) / 3).toInt(); // 4.5 时 为18
      bool isEven = totalSlots % 2 == 0;
      if (isEven) {
        totalSlots = totalSlots ~/ 2; // 4.5时 为9
      }
      double totalJiNumber = gongAngle / totalSlots;

      double _prevEndAngle = starAngle;
      for (var i = 0; i < totalSlots; i++) {
        if (i == totalSlots - 1) {
          // 最后一个 1.5 岁
          printEachYearSlotV2(canvas, center, outerRect, innerRect,
              index: i ~/ 2,
              starAngle: _prevEndAngle,
              endAngle: endAngle, // 宫位的结束角度
              baseYear: baseYear);
        } else {
          if (i % 2 == 0) {
            // 每4个slot绘制一次（1年）
            printEachYearSlotV2(canvas, center, outerRect, innerRect,
                index: i ~/ 2,
                starAngle: _prevEndAngle,
                endAngle: _prevEndAngle + totalJiNumber * 2,
                baseYear: baseYear);
            _prevEndAngle += totalJiNumber * 2;
          }
        }
      }
      int leftSlot = 18 - totalSlot.toInt() * 4;
    }
  }

  void printEachYearSlotV2(
      Canvas canvas, Offset center, Rect outerRect, Rect innerRect,
      {required int index,
      required double starAngle,
      required double endAngle,
      required double baseYear}) {
    double gongAngle = endAngle - starAngle;
    // print("slotAngle: $slotAngle");
    double sweepRadians = gongAngle * math.pi / 180;
    double startRadians = starAngle * math.pi / 180;

    // 绘制填充扇形
    _drawBackground(canvas,
        center: center,
        outerRect: outerRect,
        innerRect: innerRect,
        startRadians: startRadians,
        sweepRadians: sweepRadians,
        radius: innerRadius,
        index: index);

    // 绘制扇形边框
    if (borderWidth > 0) {
      _drawBorder(canvas,
          center: center,
          outerRect: outerRect,
          innerRect: innerRect,
          startRadians: startRadians,
          sweepRadians: sweepRadians,
          innerRadius: innerRadius,
          outerRadius: outerRadius,
          index: index);
    }

    // 计算扇形的角度中心（弧度）
    double sectorCenterAngle = startRadians + sweepRadians / 2;

    // 计算径向中心
    double middleRadius = (innerRadius + outerRadius) / 2;

    // 扇环的几何中心点
    final Offset sectorCenter = Offset(
      center.dx + middleRadius * math.cos(sectorCenterAngle),
      center.dy + middleRadius * math.sin(sectorCenterAngle),
    );
    // final Paint centerDotPaint = Paint()..color = Colors.black;
    // canvas.drawCircle(sectorCenter, 2, centerDotPaint);

    // 保存canvas状态
    canvas.save();
    // 将canvas原点移动到扇环中心点
    canvas.translate(sectorCenter.dx, sectorCenter.dy);
    // 不旋转，保持文字完全垂直
    // canvas.rotate(sectorCenterAngle); // 注释掉这行

    // 绘制文字，计算文字所在位置，
    // 要求文字的中心必须与扇环的中心点重合
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        // text: index.toString(),
        text: (index + baseYear).toString(),
        style: textStyle,
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

  void printEachYearSlot(Canvas canvas,
      {required Offset sectorCenter,
      required double outerRadius,
      required double innerRadius,
      required double startRadian,
      required double endRadian,
      required double sweepRadian,
      required Rect outerRect,
      required Rect innerRect,
      required int index,
      required double sectorCenterAngle}) {
    // 保存canvas状态
    canvas.save();

    // 将canvas原点移动到扇环中心点
    canvas.translate(sectorCenter.dx, sectorCenter.dy);

    // 不旋转，保持文字完全垂直
    canvas.rotate(sectorCenterAngle); // 注释掉这行

    // 绘制填充扇形
    // _drawBackground(canvas,
    //     center: sectorCenter,
    //     outerRect: outerRect,
    //     innerRect: innerRect,
    //     startRadians: startRadian,
    //     sweepRadians: sweepRadian,
    //     radius: innerRadius,
    //     index: index);

    // 绘制文字，计算文字所在位置，
    // 要求文字的中心必须与扇环的中心点重合
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        // text: index.toString(),
        text: "i",
        style: textStyle,
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

  @override
  bool shouldRepaint(covariant DaXianRaingPainter oldDelegate) {
    return oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepRadian != sweepRadian ||
        oldDelegate.color != color ||
        oldDelegate.outerRadius != outerRadius ||
        oldDelegate.innerRadius != innerRadius ||
        oldDelegate.borderColor != borderColor || // 检查边框颜色是否变化
        oldDelegate.borderWidth != borderWidth; // 检查边框宽度是否变化
  }
}
