import 'package:flutter/material.dart';

/// 列滞回可视化绘制：显示列的中点线与滞回边界。
///
/// 参数：
/// - columns: 列数量。
/// - rowTitleWidth: 左侧标题列宽度，用于定位中点线起点。
/// - pillarWidth: 每列柱体宽度。
/// - margin: 滞回边界的水平偏移（像素）。
/// - color: 主色（用于中点与边界线）。
/// - strokeWidth: 中点线宽，默认 1.0。
/// - marginStrokeWidth: 边界线宽，默认 0.5。
/// 返回：
/// - `CustomPainter`：用于 `CustomPaint` 的绘制器。
class ColumnHysteresisPainter extends CustomPainter {
  final int columns;
  final double rowTitleWidth;
  final double pillarWidth;
  final double margin;
  final Color color;
  final double strokeWidth;
  final double marginStrokeWidth;

  const ColumnHysteresisPainter({
    required this.columns,
    required this.rowTitleWidth,
    required this.pillarWidth,
    required this.margin,
    required this.color,
    this.strokeWidth = 1.0,
    this.marginStrokeWidth = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final marginPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = marginStrokeWidth
      ..style = PaintingStyle.stroke;

    for (int k = 0; k < columns; k++) {
      final midX = rowTitleWidth + pillarWidth * (k + 0.5);
      canvas.drawLine(Offset(midX, 0), Offset(midX, size.height), midPaint);
      canvas.drawLine(
        Offset(midX - margin, 0),
        Offset(midX - margin, size.height),
        marginPaint,
      );
      canvas.drawLine(
        Offset(midX + margin, 0),
        Offset(midX + margin, size.height),
        marginPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ColumnHysteresisPainter oldDelegate) {
    return columns != oldDelegate.columns ||
        rowTitleWidth != oldDelegate.rowTitleWidth ||
        pillarWidth != oldDelegate.pillarWidth ||
        margin != oldDelegate.margin ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        marginStrokeWidth != oldDelegate.marginStrokeWidth;
  }
}

/// 行滞回可视化绘制：显示数据行的中点线与滞回边界（橙色虚线）。
///
/// 参数：
/// - midYs: 各数据行的垂直中点坐标（不含表头）。
/// - rowHeights: 对应数据行的高度集合。
/// - rowTitleWidth: 左侧标题列宽度，限定横向绘制范围。
/// - hysteresisFrac: 滞回比例（例如 0.15）。
/// - color: 中点线颜色。
/// - strokeWidth: 中点线宽，默认 1.0。
/// - marginStrokeWidth: 边界线宽，默认 0.5。
class RowHysteresisPainter extends CustomPainter {
  final List<double> midYs;
  final List<double> rowHeights;
  final double rowTitleWidth;
  final double hysteresisFrac;
  final Color color;
  final double strokeWidth;
  final double marginStrokeWidth;

  const RowHysteresisPainter({
    required this.midYs,
    required this.rowHeights,
    required this.rowTitleWidth,
    required this.hysteresisFrac,
    required this.color,
    this.strokeWidth = 1.0,
    this.marginStrokeWidth = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final marginPaint = Paint()
      ..color = Colors.orange.withOpacity(0.5)
      ..strokeWidth = marginStrokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < midYs.length; i++) {
      final midY = midYs[i];
      final rowHeight = rowHeights[i];
      final marginPx = rowHeight * hysteresisFrac;

      canvas.drawLine(Offset(0, midY), Offset(rowTitleWidth, midY), midPaint);
      _drawDashedLine(canvas, Offset(0, midY - marginPx),
          Offset(rowTitleWidth, midY - marginPx), marginPaint);
      _drawDashedLine(canvas, Offset(0, midY + marginPx),
          Offset(rowTitleWidth, midY + marginPx), marginPaint);
    }
  }

  /// 绘制虚线辅助方法。
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final distance = (p2 - p1).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final t1 = i * (dashWidth + dashSpace) / distance;
      final t2 = (i * (dashWidth + dashSpace) + dashWidth) / distance;
      canvas.drawLine(
        Offset.lerp(p1, p2, t1)!,
        Offset.lerp(p1, p2, t2)!,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RowHysteresisPainter oldDelegate) {
    return midYs != oldDelegate.midYs ||
        rowHeights != oldDelegate.rowHeights ||
        rowTitleWidth != oldDelegate.rowTitleWidth ||
        hysteresisFrac != oldDelegate.hysteresisFrac ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        marginStrokeWidth != oldDelegate.marginStrokeWidth;
  }
}

/// 行边界可视化绘制：显示包括表头在内的所有行的中点线与滞回边界。
///
/// 参数：
/// - midYs: 所有行的中点坐标（含表头）。
/// - rowHeights: 所有行的高度集合（含表头）。
/// - cardWidth: 卡片总宽，用于绘制整宽边界。
/// - color: 中点线颜色。
/// - hysteresisFrac: 滞回比例（默认 0.15）。
/// - strokeWidth: 中点线宽，默认 1.0。
class RowBoundaryPainter extends CustomPainter {
  final List<double> midYs;
  final List<double> rowHeights;
  final double cardWidth;
  final Color color;
  final double hysteresisFrac;
  final double strokeWidth;

  const RowBoundaryPainter({
    required this.midYs,
    required this.rowHeights,
    required this.cardWidth,
    required this.color,
    this.hysteresisFrac = 0.15,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final marginPaint = Paint()
      ..color = Colors.orange.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < midYs.length; i++) {
      final midY = midYs[i];
      final rowHeight = rowHeights[i];
      final margin = rowHeight * hysteresisFrac;

      canvas.drawLine(Offset(0, midY), Offset(cardWidth, midY), midPaint);
      _drawDashedLine(canvas, Offset(0, midY - margin),
          Offset(cardWidth, midY - margin), marginPaint);
      _drawDashedLine(canvas, Offset(0, midY + margin),
          Offset(cardWidth, midY + margin), marginPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final distance = (p2 - p1).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final t1 = i * (dashWidth + dashSpace) / distance;
      final t2 = (i * (dashWidth + dashSpace) + dashWidth) / distance;
      canvas.drawLine(
        Offset.lerp(p1, p2, t1)!,
        Offset.lerp(p1, p2, t2)!,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RowBoundaryPainter oldDelegate) {
    return midYs != oldDelegate.midYs ||
        rowHeights != oldDelegate.rowHeights ||
        cardWidth != oldDelegate.cardWidth ||
        color != oldDelegate.color ||
        hysteresisFrac != oldDelegate.hysteresisFrac ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}