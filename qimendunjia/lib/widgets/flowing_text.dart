import 'package:flutter/material.dart';

class GradientFlowText extends StatefulWidget {
  const GradientFlowText({super.key});

  @override
  _GradientFlowTextState createState() => _GradientFlowTextState();
}

class _GradientFlowTextState extends State<GradientFlowText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0xFFB8860B), // 深金色
                Color(0xFFC0C0C0), // 银色
                Color(0xFFD4AF37), // 亮金色
                Color(0xFF8B008B), // 深紫色
                Color(0xFF6A5ACD), // 石板蓝
                Color(0xFF4B0082), // 靛蓝色
                Color(0xFF8A2BE2), // 蓝紫色
                Color(0xFFD4AF37), // 亮金色
                Color(0xFFC0C0C0), // 银色
                Color(0xFFB8860B), // 深金色
              ],
              stops: const [
                0.0,
                0.1,
                0.2,
                0.35,
                0.5,
                0.65,
                0.75,
                0.85,
                0.9,
                1.0
              ],
              begin: Alignment(-1.0 + _controller.value * 2, -1.0),
              end: Alignment(1.0 - _controller.value * 2, 1.0),
            ).createShader(bounds);
          },
          child: const Text(
            '紫金色效果',
            style: TextStyle(
              color: Colors.white,
              fontSize: 50,
              fontFamily: 'Roboto', // 使用专业字体
              fontWeight: FontWeight.w600, // 调整字体粗细
              shadows: [
                Shadow(
                  offset: Offset(2.0, 2.0),
                  blurRadius: 3.0,
                  color: Colors.black45, // 添加阴影
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
