import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'enums/enum_twelve_gong.dart';

class DaXian106RingPainter extends CustomPainter {
  final double startAngle; // 扇环绘制的起始角度（相对于其自身坐标系）
  final double sweepRadian;
  final double baseRadian;
  final Color color;
  final double outerRadius;
  final double innerRadius;
  final Color eachSlotBorderColor; // 新增边框颜色参数
  final double eachSlotBorderWidth; // 新增边框宽度参数
  final Color gongBorderColors;
  final double gongBorderWidth;

  Map<EnumTwelveGong, double> gongYearsMapper;
  List<EnumTwelveGong> gongOrderedSeq;

  final TextStyle textStyle;
  final double starFromYear;

  DaXian106RingPainter({
    required this.startAngle,
    required this.sweepRadian,
    required this.color,
    required this.outerRadius,
    required this.innerRadius,
    required this.gongYearsMapper,
    this.eachSlotBorderColor = Colors.black12, // 默认边框颜色
    this.eachSlotBorderWidth = 1.0, // 默认边框宽度
    this.gongBorderColors = Colors.black87, // 默认边框颜色
    this.gongBorderWidth = 1.0, // 默认边框宽度
    required this.textStyle,
    required this.gongOrderedSeq,
    required this.starFromYear,
  }) : baseRadian = startAngle * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final Rect innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    double eachGongAngle = 360 / gongYearsMapper.length;
    double prevBaseYear = starFromYear - 1;
    for (var i = 0; i < gongOrderedSeq.length; i++) {
      double gongYears = gongYearsMapper[gongOrderedSeq[i]]!;
      double gongStartAngle = startAngle + eachGongAngle * i;
      double gongEndAngle = startAngle + eachGongAngle * (i + 1);
      prevBaseYear = printEachGong(canvas, center, outerRect, innerRect,
          gongIndex: i,
          totalSlot: gongYears,
          starAngle: gongStartAngle,
          endAngle: gongEndAngle,
          baseYear: prevBaseYear);
    }
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

  _drawBorder(
    Canvas canvas, {
    required Offset center,
    required Rect outerRect,
    required Rect innerRect,
    required double startRadians,
    required double sweepRadians,
    required double innerRadius,
    required double outerRadius,
    required Color borderColor, // 新增边框颜色参数
    required double borderWidth, // 新增边框宽度参数
    // required int index,
  }) {
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // 绘制外弧线
    canvas.drawArc(outerRect, startRadians, sweepRadians, false, borderPaint);
    // 绘制内弧线
    // canvas.drawArc(innerRect, startRadians, sweepRadians, false, borderPaint);

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

  // 重构后的 printEachGong 方法
  double printEachGong(
      Canvas canvas, Offset center, Rect outerRect, Rect innerRect,
      {required int gongIndex,
      required double totalSlot,
      required double starAngle,
      required double endAngle,
      required double baseYear}) {
    double gongAngle = endAngle - starAngle;
    double sweepRadians = gongAngle * math.pi / 180;
    double startRadians = starAngle * math.pi / 180;

    // 绘制背景和边框
    _drawGongBackground(canvas, center, outerRect, innerRect, startRadians,
        sweepRadians, gongIndex);

    // 根据 totalSlot 类型选择绘制策略
    if (_isInteger(totalSlot)) {
      return _drawIntegerSlots(canvas, center, outerRect, innerRect, totalSlot,
          gongAngle, starAngle, baseYear);
    } else {
      return _drawFractionalSlots(canvas, center, outerRect, innerRect,
          totalSlot, gongAngle, starAngle, endAngle, baseYear);
    }
  }

  // 辅助方法
  bool _isInteger(double value) => value == value.toInt();

  bool _isIntegerYear(double year) => year.toInt() == year;

  void _drawGongBackground(Canvas canvas, Offset center, Rect outerRect,
      Rect innerRect, double startRadians, double sweepRadians, int gongIndex) {
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
    if (gongBorderWidth > 0) {
      _drawBorder(canvas,
          center: center,
          outerRect: outerRect,
          innerRect: innerRect,
          startRadians: startRadians,
          sweepRadians: sweepRadians,
          innerRadius: innerRadius,
          outerRadius: outerRadius,
          borderColor: gongBorderColors,
          borderWidth: gongBorderWidth);
    }
  }

  // 处理整数槽位
  double _drawIntegerSlots(
      Canvas canvas,
      Offset center,
      Rect outerRect,
      Rect innerRect,
      double totalSlot,
      double gongAngle,
      double starAngle,
      double baseYear) {
    if (_isIntegerYear(baseYear)) {
      return _drawSimpleIntegerSlots(canvas, center, outerRect, innerRect,
          totalSlot, gongAngle, starAngle, baseYear);
    } else {
      return _drawComplexIntegerSlots(canvas, center, outerRect, innerRect,
          totalSlot, gongAngle, starAngle, baseYear);
    }
  }

  // 简单整数槽位绘制
  double _drawSimpleIntegerSlots(
      Canvas canvas,
      Offset center,
      Rect outerRect,
      Rect innerRect,
      double totalSlot,
      double gongAngle,
      double starAngle,
      double baseYear) {
    double eachSlotAngle = gongAngle / totalSlot;
    double currentAngle = starAngle;
    double currentYear = baseYear;

    for (var i = 0; i < totalSlot; i++) {
      currentYear = _drawYearSlot(canvas, center, outerRect, innerRect,
          starAngle: currentAngle,
          endAngle: currentAngle + eachSlotAngle,
          baseYear: currentYear,
          currentYear: 1);
      currentAngle += eachSlotAngle;
    }
    return currentYear;
  }

  // 复杂整数槽位绘制
  double _drawComplexIntegerSlots(
      Canvas canvas,
      Offset center,
      Rect outerRect,
      Rect innerRect,
      double totalSlot,
      double gongAngle,
      double starAngle,
      double baseYear) {
    SlotConfig config = _calculateSlotConfig(totalSlot, gongAngle);
    double currentAngle = starAngle;
    double currentYear = baseYear;

    // 绘制第一个特殊槽位
    currentYear = _drawYearSlot(canvas, center, outerRect, innerRect,
        starAngle: currentAngle,
        endAngle: currentAngle + config.eachSlotAngle,
        baseYear: currentYear,
        currentYear: 0);
    currentAngle += config.eachSlotAngle;
    currentYear += 0.5;

    // 绘制中间槽位
    for (var i = 0; i < config.totalSlots - 1; i++) {
      SlotDrawInfo drawInfo = _getSlotDrawInfo(i, config.totalSlots);
      if (drawInfo.shouldDraw) {
        currentYear = _drawYearSlot(canvas, center, outerRect, innerRect,
            starAngle: currentAngle,
            endAngle:
                currentAngle + config.eachSlotAngle * drawInfo.angleMultiplier,
            baseYear: currentYear,
            currentYear: drawInfo.currentYear);
        currentAngle += config.eachSlotAngle * drawInfo.angleMultiplier;
      }
    }
    return currentYear;
  }

  // 处理分数槽位
  double _drawFractionalSlots(
      Canvas canvas,
      Offset center,
      Rect outerRect,
      Rect innerRect,
      double totalSlot,
      double gongAngle,
      double starAngle,
      double endAngle,
      double baseYear) {
    SlotConfig config = _calculateSlotConfig(totalSlot, gongAngle);

    if (!_isIntegerYear(baseYear)) {
      return _drawFractionalSlotsWithNonIntegerBase(
          canvas, center, outerRect, innerRect, config, starAngle, baseYear);
    } else {
      return _drawFractionalSlotsWithIntegerBase(canvas, center, outerRect,
          innerRect, config, starAngle, endAngle, baseYear);
    }
  }

  // 非整数基准年的分数槽位绘制
  double _drawFractionalSlotsWithNonIntegerBase(
      Canvas canvas,
      Offset center,
      Rect outerRect,
      Rect innerRect,
      SlotConfig config,
      double startAngle,
      double baseYear) {
    double currentAngle = startAngle;
    double currentYear = baseYear;

    // 绘制第一个槽位
    currentYear = _drawYearSlot(canvas, center, outerRect, innerRect,
        starAngle: currentAngle,
        endAngle: currentAngle + config.eachSlotAngle,
        baseYear: currentYear,
        currentYear: 0);
    currentAngle += config.eachSlotAngle;
    currentYear += 0.5;

    // 绘制剩余槽位
    for (var i = 0; i < config.totalSlots - 1; i++) {
      SlotDrawInfo drawInfo = _getFractionalSlotDrawInfo(i, config.totalSlots);
      if (drawInfo.shouldDraw) {
        currentYear = _drawYearSlot(canvas, center, outerRect, innerRect,
            starAngle: currentAngle,
            endAngle:
                currentAngle + config.eachSlotAngle * drawInfo.angleMultiplier,
            baseYear: currentYear,
            currentYear: drawInfo.currentYear);
        currentAngle += config.eachSlotAngle * drawInfo.angleMultiplier;
      }
    }
    return currentYear;
  }

  // 整数基准年的分数槽位绘制
  double _drawFractionalSlotsWithIntegerBase(
      Canvas canvas,
      Offset center,
      Rect outerRect,
      Rect innerRect,
      SlotConfig config,
      double startAngle,
      double endAngle,
      double baseYear) {
    double currentAngle = startAngle;
    double currentYear = baseYear;

    for (var i = 0; i < config.totalSlots - 1; i++) {
      if (i % 2 == 0) {
        currentYear = _drawYearSlot(canvas, center, outerRect, innerRect,
            starAngle: currentAngle,
            endAngle: currentAngle + config.eachSlotAngle * 2,
            baseYear: currentYear,
            currentYear: 1);
        currentAngle += config.eachSlotAngle * 2;
      }
    }

    // 绘制最后一个槽位
    currentYear = _drawYearSlot(canvas, center, outerRect, innerRect,
        starAngle: currentAngle,
        endAngle: endAngle,
        baseYear: currentYear,
        currentYear: 1.5);

    return currentYear;
  }

  // 核心绘制方法 - 替代原来的 printEachYearSlotV3
  double _drawYearSlot(
      Canvas canvas, Offset center, Rect outerRect, Rect innerRect,
      {required double starAngle,
      required double endAngle,
      required double baseYear,
      required double currentYear}) {
    double gongAngle = endAngle - starAngle;
    double sweepRadians = gongAngle * math.pi / 180;
    double startRadians = starAngle * math.pi / 180;

    // 绘制扇形边框
    if (eachSlotBorderWidth > 0) {
      _drawBorder(
        canvas,
        center: center,
        outerRect: outerRect,
        innerRect: innerRect,
        startRadians: startRadians,
        sweepRadians: sweepRadians,
        innerRadius: innerRadius,
        outerRadius: outerRadius,
        borderColor: eachSlotBorderColor,
        borderWidth: eachSlotBorderWidth,
      );
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

    // 保存canvas状态
    canvas.save();
    // 将canvas原点移动到扇环中心点
    canvas.translate(sectorCenter.dx, sectorCenter.dy);

    // 绘制文字
    final _baseYear = baseYear + currentYear;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: _baseYear.toString(),
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
    return _baseYear;
  }

  // 计算槽位配置
  SlotConfig _calculateSlotConfig(double totalSlot, double gongAngle) {
    int totalSlots = ((totalSlot * 12) / 3).toInt();
    bool isEven = totalSlots % 2 == 0;
    if (isEven) {
      totalSlots = totalSlots ~/ 2;
    }
    double eachSlotAngle = gongAngle / totalSlots;

    return SlotConfig(
      totalSlots: totalSlots,
      eachSlotAngle: eachSlotAngle,
    );
  }

  // 获取槽位绘制信息
  SlotDrawInfo _getSlotDrawInfo(int index, int totalSlots) {
    if (index < 2) {
      return SlotDrawInfo(
        shouldDraw: index % 2 == 0,
        angleMultiplier: 2,
        currentYear: 0,
      );
    } else if (index == totalSlots - 2) {
      return SlotDrawInfo(
        shouldDraw: true,
        angleMultiplier: 1,
        currentYear: 1.5,
      );
    } else {
      return SlotDrawInfo(
        shouldDraw: index % 2 == 0,
        angleMultiplier: 2,
        currentYear: 1,
      );
    }
  }

  // 获取分数槽位绘制信息
  SlotDrawInfo _getFractionalSlotDrawInfo(int index, int totalSlots) {
    if (index < 2) {
      return SlotDrawInfo(
        shouldDraw: index % 2 == 0,
        angleMultiplier: 2,
        currentYear: 0,
      );
    } else {
      return SlotDrawInfo(
        shouldDraw: index % 2 == 0,
        angleMultiplier: 2,
        currentYear: 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DaXian106RingPainter oldDelegate) {
    return oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepRadian != sweepRadian ||
        oldDelegate.color != color ||
        oldDelegate.outerRadius != outerRadius ||
        oldDelegate.innerRadius != innerRadius ||
        oldDelegate.eachSlotBorderColor != eachSlotBorderColor || // 检查边框颜色是否变化
        oldDelegate.eachSlotBorderWidth != eachSlotBorderWidth; //
  }
}

// 辅助数据类
class SlotConfig {
  final int totalSlots;
  final double eachSlotAngle;

  SlotConfig({required this.totalSlots, required this.eachSlotAngle});
}

class SlotDrawInfo {
  final bool shouldDraw;
  final double angleMultiplier;
  final double currentYear;

  SlotDrawInfo({
    required this.shouldDraw,
    required this.angleMultiplier,
    required this.currentYear,
  });
}
