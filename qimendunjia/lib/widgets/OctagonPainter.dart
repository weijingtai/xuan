import 'dart:math' as math;
import 'package:flutter/material.dart';

class OctagonPainter extends CustomPainter {
  final double radius;

  OctagonPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();
    const angle = (2 * math.pi) / 8;

    for (int i = 0; i < 8; i++) {
      final x = size.width / 2 + radius * math.cos(i * angle);
      final y = size.height / 2 + radius * math.sin(i * angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Octagon extends StatelessWidget {
  final double radius;

  const Octagon({super.key, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: OctagonPainter(radius: radius),
      child: Container(
        child: const Text("开"),
      ),
    );
  }
}
