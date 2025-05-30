import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'dev_demo2.dart';
import 'sector_painter.dart';
import 'shen_sha_item.dart';

class ShenShaRing extends StatelessWidget {
  final List<String> shenShaList;
  final List<String> innerShenShaList;
  final double outerRadius; // 整个圆环的外半径
  final double innerRadius; // 整个圆环的内半径
  final double offsetAngle;
  final List<double>? startAngles; // 新增：每个扇环的起始角度（可选）
  final List<double>? sweepRadians; // 新增：每个扇环的扫描角度（可选）

  final double gongOffset;

  const ShenShaRing({
    super.key,
    required this.shenShaList,
    required this.innerShenShaList,
    required this.outerRadius,
    required this.innerRadius,
    required this.offsetAngle,
    required this.gongOffset, // 新增：宫偏移角度，用于调整宫的位置，
    this.startAngles,
    this.sweepRadians,
  }) : assert(outerRadius > innerRadius && innerRadius >= 0);

  @override
  Widget build(BuildContext context) {
    final double itemSize = outerRadius * 2; // 每个item占据的空间是外半径的两倍

    // print(startAngles);
    // print(sweepRadians);
    double _sweepRadians = offsetAngle * math.pi / 180;
    return SizedBox(
      width: itemSize, // 整个控件的宽度等于外直径
      height: itemSize, // 整个控件的高度等于外直径
      child: CustomMultiChildLayout(
        delegate: _ShenShaLayoutDelegate(
          itemCount: shenShaList.length,
          radius: 0, // 所有子项都从中心开始布局
          itemSize: itemSize,
        ),
        children: [
          for (int i = 0; i < shenShaList.length; i++)
            buildEachShenSha(0, i, _sweepRadians, itemSize),
        ],
      ),
    );
  }

  Widget buildEachShenSha(
      int gongIndex, int shenShaIndex, double _sweepRadians, double itemSize) {
    return LayoutId(
      id: shenShaIndex,
      child: _ShenShaItem(
        name: shenShaList[shenShaIndex],
        index: shenShaIndex < 10 ? shenShaIndex : shenShaIndex - 10,
        offsetAngle: offsetAngle,
        totalCount: shenShaList.length,
        outerRadius:
            shenShaIndex > 9 ? outerRadius - 40 : outerRadius, // 传递给item
        innerRadius:
            shenShaIndex > 9 ? innerRadius : innerRadius + 40, // 传递给item
        itemSize: itemSize,
        shaTextDirection: ShenShaTextDirection.gravity,
        startAngle: gongOffset + startAngles![shenShaIndex], // 传递自定义起始角度
        sweepRadian: _sweepRadians, // 传递自定义扫描角度
        gongOffset: gongOffset,
      ),
    );
  }
}

class _ShenShaItem extends StatelessWidget {
  final String name;
  final int index;
  final int totalCount;
  final double outerRadius;
  final double innerRadius;
  final double itemSize;
  final ShenShaTextDirection shaTextDirection;
  final double? startAngle; // 新增：自定义起始角度（可选）
  final double? sweepRadian; // 新增：自定义扫描角度（可选）
  final double offsetAngle;

  final double gongOffset;

  const _ShenShaItem({
    required this.name,
    required this.index,
    required this.totalCount,
    required this.outerRadius,
    required this.innerRadius,
    required this.itemSize,
    required this.shaTextDirection,
    required this.offsetAngle, // 新增：偏移角度，用于调整文字的位置
    required this.gongOffset, // 新增：宫偏移角度，用于调整宫的位置，
    this.startAngle,
    this.sweepRadian,
  });

  TextStyle getTextStyle() {
    return TextStyle(
      fontSize: 13,
      height: 1.1,
      color: Colors.black87,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool toCenter = false;
    // 使用自定义扫描角度，如果没有提供则使用默认计算方式
    final double actualsweepRadian = sweepRadian ?? (2 * math.pi / totalCount);
    final textStyle = getTextStyle();
    // 使用TextPainter来准确测量文字宽度和高度
    final textPainter = TextPainter(
      text: TextSpan(text: name, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final double textBlockWidth = textPainter.width; // 文字横向排列的实际宽度
    final double textBlockHeight = textPainter.height; // 文字横向排列的实际高度

    final double ringThickness = outerRadius - innerRadius;

    // --- 修改：让文字位于扇区中心 ---

    // 1. 文字容器的定位：
    // 我们希望文字位于扇区的中心位置
    // 计算扇区的中心角度
    final double sectorCenterAngle = actualsweepRadian / 2;

    // 文字中心点到圆心的径向距离，取内外半径的中间
    final double radialPosition = innerRadius + ringThickness / 2;

    // 计算文字在扇区中心的位置
    // 由于我们在Transform.rotate中已经旋转了整个扇区，所以这里的角度是相对于旋转后的坐标系
    // 在旋转后的坐标系中，扇区中心角度是 sweepRadian/2
    final double offsetX =
        radialPosition * math.cos(sectorCenterAngle); // 文字块的中心 X 坐标
    final double offsetY =
        radialPosition * math.sin(sectorCenterAngle); // 文字块的中心 Y 坐标

    // 2. 扇区的整体旋转
    // 使用自定义起始角度，如果没有提供则使用默认计算方式
    final double baseItemRotation =
        startAngle ?? (2 * math.pi * index / totalCount);

    // 3. 文字自身的旋转
    // 我们希望文字垂直于径向方向，这样更容易阅读
    final double textOrientationRotation = 0; // 文字朝向外侧

    final double finalAngleForText =
        -baseItemRotation + textOrientationRotation;
    // --- 修改结束 ---

    return SizedBox(
      width: itemSize,
      height: itemSize,
      child: Transform.rotate(
        angle: baseItemRotation, // 每个扇环的整体旋转
        child: CustomPaint(
            size: Size(itemSize, itemSize),
            painter: SectorPainter(
                startAngle: 0,
                sweepRadian: actualsweepRadian,
                color: Colors.blue[500]!.withAlpha(20 * index),
                outerRadius: outerRadius,
                innerRadius: innerRadius,
                borderColor: Colors.transparent),
            child: eachShenSha(offsetX, offsetY, textStyle)),
      ),
    );
  }

  Widget eachShenSha(double offsetX, double offsetY, TextStyle textStyle) {
    return Transform.translate(
      offset: Offset(offsetX, offsetY), // 定位文字容器的中心
      child: Transform.rotate(
          // 文字容器旋转，使其垂直于径向方向
          angle: math.pi / 2 + math.atan2(offsetY, offsetX),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    colors: [
                      Colors.redAccent.withOpacity(0.6),
                      Colors.redAccent.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 28,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4), // 文字背景圆角
                  // border: BoxBorder.fromLTRB(
                  // bottom: BorderSide(color: Colors.black54, width: 1.0))
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: name
                        .split("")
                        .map((t) => Transform.rotate(
                              angle: getTextRotationAngle(shaTextDirection),
                              child: Text(
                                t,
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ))
                        .toList()),
              ),
            ],
          )),
    );
  }

  double getTextRotationAngle(ShenShaTextDirection direction) {
    // 计算文字的旋转角度，使其始终垂直于半径
    // 这里我们假设文字是横向的 Text('神煞')，并且我们希望它垂直于半径。
    // 如果文字是纵向的 Text('神\n煞')，则需要调整角度。
    // 这里我们简单地返回0度，即不旋转。
    switch (direction) {
      case ShenShaTextDirection.center:
        return 0; // 文字指向圆环中心
      case ShenShaTextDirection.outer:
        return math.pi; // 文字指向圆环外侧
      case ShenShaTextDirection.gravity:
        // return -(index * offsetAngle + 90) * (math.pi / 180); // 文字垂直于半径，旋转180度
        return -(index * offsetAngle + 90) * (math.pi / 180) -
            gongOffset; // 文字垂直于半径，旋转180度
    }
  }
}

class _ShenShaLayoutDelegate extends MultiChildLayoutDelegate {
  final int itemCount;
  final double radius; // 布局半径，这里会是0
  final double itemSize;

  _ShenShaLayoutDelegate({
    required this.itemCount,
    required this.radius, // 将会是0
    required this.itemSize,
  });

  @override
  void performLayout(Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < itemCount; i++) {
      if (!hasChild(i)) continue;

      final childSize =
          layoutChild(i, BoxConstraints.tight(Size(itemSize, itemSize)));
      // 所有子项都放置在中心点
      positionChild(
          i,
          Offset(center.dx - childSize.width / 2,
              center.dy - childSize.height / 2));
    }
  }

  @override
  bool shouldRelayout(covariant _ShenShaLayoutDelegate oldDelegate) =>
      oldDelegate.itemCount != itemCount ||
      oldDelegate.radius != radius ||
      oldDelegate.itemSize != itemSize;
}
