import 'package:flutter/material.dart';

/// 卡片网格画笔：在卡片内容之上/之下绘制列与行分隔线。
///
/// 用途：
/// - 统一集中管理竖向、横向分隔线绘制；
/// - 支持设置边距内缩与颜色/粗细；
/// - 便于后续扩展主题联动与动画。
class CardGridPainter extends CustomPainter {
  /// 竖向分隔线的 X 坐标集合（相对于画布）。
  final List<double> verticalXs;

  /// 横向分隔线的 Y 坐标集合（相对于画布）。
  final List<double> horizontalYs;

  /// 内容区域的上内边距（用于避让装饰）。
  final double topInset;

  /// 内容区域的左内边距。
  final double leftInset;

  /// 内容区域的右内边距。
  final double rightInset;

  /// 内容区域的下内边距。
  final double bottomInset;

  /// 列分隔线颜色。
  final Color columnColor;

  /// 列分隔线粗细。
  final double columnThickness;

  /// 行分隔线颜色。
  final Color rowColor;

  /// 行分隔线粗细。
  final double rowThickness;

  /// 构造函数。
  ///
  /// 参数：
  /// - [verticalXs] 竖向分隔线 X 坐标；
  /// - [horizontalYs] 横向分隔线 Y 坐标；
  /// - [topInset]/[leftInset]/[rightInset]/[bottomInset] 内容区域边距；
  /// - [columnColor]/[columnThickness] 列分隔线样式；
  /// - [rowColor]/[rowThickness] 行分隔线样式。
  CardGridPainter({
    required this.verticalXs,
    this.horizontalYs = const <double>[],
    this.topInset = 0,
    this.leftInset = 0,
    this.rightInset = 0,
    this.bottomInset = 0,
    this.columnColor = const Color(0x22000000),
    this.columnThickness = 1.0,
    this.rowColor = const Color(0x22000000),
    this.rowThickness = 1.0,
  });

  /// 绘制分隔线。
  ///
  /// 参数：
  /// - [canvas] 画布对象；
  /// - [size] 当前绘制区域尺寸。
  /// 返回：无；在画布上绘制网格分隔线。
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height - topInset - bottomInset;
    final width = size.width - leftInset - rightInset;

    if (height > 0) {
      final colPaint = Paint()
        ..color = columnColor
        ..strokeWidth = columnThickness
        ..style = PaintingStyle.stroke;
      for (final x in verticalXs) {
        final dx = x.clamp(0.0, size.width);
        canvas.drawLine(
          Offset(dx, topInset),
          Offset(dx, topInset + height),
          colPaint,
        );
      }
    }

    if (width > 0 && horizontalYs.isNotEmpty) {
      final rowPaint = Paint()
        ..color = rowColor
        ..strokeWidth = rowThickness
        ..style = PaintingStyle.stroke;
      for (final y in horizontalYs) {
        final dy = y.clamp(0.0, size.height);
        canvas.drawLine(
          Offset(leftInset, dy),
          Offset(leftInset + width, dy),
          rowPaint,
        );
      }
    }
  }

  /// 重绘判断：当坐标集合或样式发生变化时需要重绘。
  ///
  /// 参数：
  /// - [oldDelegate] 旧画笔实例。
  /// 返回：布尔值，指示是否需要触发重绘。
  @override
  bool shouldRepaint(covariant CardGridPainter oldDelegate) {
    return verticalXs != oldDelegate.verticalXs ||
        horizontalYs != oldDelegate.horizontalYs ||
        topInset != oldDelegate.topInset ||
        leftInset != oldDelegate.leftInset ||
        rightInset != oldDelegate.rightInset ||
        bottomInset != oldDelegate.bottomInset ||
        columnColor != oldDelegate.columnColor ||
        columnThickness != oldDelegate.columnThickness ||
        rowColor != oldDelegate.rowColor ||
        rowThickness != oldDelegate.rowThickness;
  }
}