import 'package:flutter/material.dart';

/// 幽灵柱/行占位 Widget
///
/// 用于拖拽时显示插入位置的占位符，支持列幽灵（蓝色）和行幽灵（绿色）。
///
/// 特性:
/// - 半透明背景
/// - 边框样式
/// - 可配置颜色（蓝色用于列，绿色用于行）
/// - 圆角边框
class GhostPillarWidget extends StatelessWidget {
  /// 幽灵柱/行的宽度
  final double width;

  /// 幽灵柱/行的高度
  final double height;

  /// 边框颜色 (默认蓝色用于列幽灵)
  final Color? borderColor;

  /// 背景色 (默认半透明蓝色)
  final Color? backgroundColor;

  /// 边框宽度 (默认 1.5)
  final double borderWidth;

  /// 圆角半径 (默认 0，无圆角)
  final double borderRadius;

  /// 构造函数
  const GhostPillarWidget({
    Key? key,
    required this.width,
    required this.height,
    this.borderColor,
    this.backgroundColor,
    this.borderWidth = 1.5,
    this.borderRadius = 0,
  }) : super(key: key);

  /// 工厂方法：列幽灵 (蓝色)
  factory GhostPillarWidget.column({
    required double width,
    required double height,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1.5,
    double borderRadius = 0,
  }) {
    return GhostPillarWidget(
      width: width,
      height: height,
      backgroundColor: backgroundColor ?? Colors.blue.withAlpha(20),
      borderColor: borderColor ?? Colors.blue.withAlpha(128),
      borderWidth: borderWidth,
      borderRadius: borderRadius,
    );
  }

  /// 工厂方法：行幽灵 (绿色)
  factory GhostPillarWidget.row({
    required double width,
    required double height,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1.5,
    double borderRadius = 0,
  }) {
    return GhostPillarWidget(
      width: width,
      height: height,
      backgroundColor: backgroundColor ?? Colors.green.withAlpha(20),
      borderColor: borderColor ?? Colors.green.withAlpha(128),
      borderWidth: borderWidth,
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? Colors.blue.withAlpha(20);
    final effectiveBorderColor = borderColor ?? Colors.blue.withAlpha(128);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
          style: BorderStyle.solid,
        ),
        borderRadius: borderRadius > 0
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
    );
  }
}
