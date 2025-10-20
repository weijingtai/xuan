import 'package:flutter/material.dart';

class GoldText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextStyle style;

  GoldText(
      {super.key, required this.text, this.fontSize = 24, required this.style});

  @override
  Widget build(BuildContext context) {
    return build_v2();
  }

  Widget build_v1() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          // Color(0xFFFFD700), // 金色
          // Color(0xFFFFA500), // 橙色
          // Color(0xFFFFD700), // 金色
          Color(0xFFFFD700), // 金色
          Color(0xFF8A2BE2), // 紫色
          Color(0xFFFFD700), // 金色
        ],
        tileMode: TileMode.mirror,
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  LinearGradient linearGradient = const LinearGradient(
    colors: [
      Color(0xFFDAA520), // 暗金色
      // Color(0xFF8A2BE2), // 紫色
      Color(0xFF4B0082), // 靛蓝色
      Color(0xFFDAA520), // 暗金色
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient linearGradient2 = const LinearGradient(
    colors: [
      Color(0xFFB8860B), // 深金色
      Color(0xFFD4AF37), // 亮金色
      Color(0xFF8B008B), // 深紫色
      Color(0xFF4B0082), // 靛蓝色
      Color(0xFFD4AF37), // 亮金色
      Color(0xFFB8860B), // 深金色
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.3, 0.5, 0.7, 0.9, 1.0],
  );

  LinearGradient linearGradient3 = const LinearGradient(
    colors: [
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
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    // stops: [0.0, 0.1, 0.2, 0.35, 0.5, 0.65, 0.75, 0.85, 0.9, 1.0],
    stops: [0.0, 0.1, 0.2, 0.4, 0.5, 0.60, 0.75, 0.85, 0.9, 1.0],
  );
  Widget build_v2() {
    return ShaderMask(
      shaderCallback: (bounds) => linearGradient2.createShader(bounds),
      child: Text(
        text,
        style: style,
        // style: TextStyle(
        //   color: Colors.white.withValues(alpha: .8),
        //   fontSize: fontSize,
        //   fontFamily: 'Roboto', // 使用专业字体
        //   fontWeight: FontWeight.w400, // 调整字体粗细
        //   shadows: [
        //     Shadow(
        //       offset: Offset(2.0, 2.0),
        //       blurRadius: 3.0,
        //       color: Colors.black45, // 添加阴影
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
