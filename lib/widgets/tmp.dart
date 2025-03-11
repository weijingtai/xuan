import 'dart:math';
import 'package:flutter/material.dart';

// 柳枝随风飘动
class WillowBranchPainter extends CustomPainter {
  final List<Offset> controlPoints;
  final double windStrength;

  WillowBranchPainter(this.controlPoints, this.windStrength);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    Path path = Path()..moveTo(controlPoints[0].dx, controlPoints[0].dy);

    for (int i = 1; i < controlPoints.length - 1; i += 2) {
      path.quadraticBezierTo(
        controlPoints[i].dx + windStrength,
        controlPoints[i].dy,
        controlPoints[i + 1].dx + windStrength,
        controlPoints[i + 1].dy,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class WillowBranchAnimation extends StatefulWidget {
  const WillowBranchAnimation({super.key});

  @override
  _WillowBranchAnimationState createState() => _WillowBranchAnimationState();
}

class _WillowBranchAnimationState extends State<WillowBranchAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> controlPoints;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    controlPoints = [
      Offset(200, 100),
      Offset(210, 150),
      Offset(220, 200),
      Offset(230, 250),
      Offset(240, 300),
      Offset(250, 350),
    ];

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double windStrength = sin(_controller.value * 2 * pi) * 20;

    return CustomPaint(
      painter: WillowBranchPainter(controlPoints, windStrength),
      child: Container(),
    );
  }
}
