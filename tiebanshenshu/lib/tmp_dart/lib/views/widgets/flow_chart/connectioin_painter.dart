import 'package:flutter/material.dart';
import '../../../models/atom_operation.dart';
import '../../../models/flow_node.dart';

class ConnectionPainter extends CustomPainter {
  final List<FlowNode> nodes;

  final List<NodeConnection> connections;
  final double zoomLevel;

  ConnectionPainter({
    required this.nodes,
    required this.connections,
    this.zoomLevel = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // 绘制连接线
    for (int i = 0; i < nodes.length; i++) {
      final fromNode = nodes[i];

      for (final connectionId in fromNode.connections) {
        final toNode = nodes.firstWhere(
          (node) => node.id == connectionId,
          orElse: () => FlowNode(
            id: '',
            operation: AtomOperation(
              id: '',
              name: '',
              description: '',
              category: AtomOperationCategory.time,
              input: '',
              output: '',
              type: '',
              icon: '',
            ),
            position: Offset.zero,
          ),
        );

        if (toNode.id.isNotEmpty) {
          _drawConnection(
            canvas,
            fromNode.position + const Offset(224, 40), // 从节点右侧中心
            toNode.position + const Offset(0, 40), // 到节点左侧中心
            i == 0 ? activePaint : paint, // 第一条连接线高亮
          );
        }
      }
    }

    // 绘制箭头
    _drawArrowHeads(canvas, paint);
  }

  void _drawConnection(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // 创建贝塞尔曲线连接
    final controlPoint1 = Offset(start.dx + 50, start.dy);
    final controlPoint2 = Offset(end.dx - 50, end.dy);

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      end.dx,
      end.dy,
    );

    canvas.drawPath(path, paint);
  }

  void _drawArrowHeads(Canvas canvas, Paint paint) {
    for (int i = 0; i < nodes.length; i++) {
      final fromNode = nodes[i];

      for (final connectionId in fromNode.connections) {
        final toNode = nodes.firstWhere(
          (node) => node.id == connectionId,
          orElse: () => FlowNode(
            id: '',
            operation: AtomOperation(
              id: '',
              name: '',
              description: '',
              category: AtomOperationCategory.time,
              input: '',
              output: '',
              type: '',
              icon: '',
            ),
            position: Offset.zero,
          ),
        );

        if (toNode.id.isNotEmpty) {
          final arrowEnd = toNode.position + const Offset(0, 40);
          _drawArrowHead(canvas, arrowEnd, paint);
        }
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset position, Paint paint) {
    final arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(position.dx, position.dy);
    path.lineTo(position.dx - 10, position.dy - 3.5);
    path.lineTo(position.dx - 10, position.dy + 3.5);
    path.close();

    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.zoomLevel != zoomLevel;
  }
}
