import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircleLayoutDemo extends StatelessWidget {
  final List<String> shenShaList = [
    "长生",
    "沐浴",
    "绝",
    "临官",
    "帝旺",
    "衰",
    "病",
    "死",
    "墓",
    "冠带"
        "胎",
    "养"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          height: 400,
          child: CustomMultiChildLayout(
            delegate: CircleLayoutDelegate(childCount: shenShaList.length),
            children: [
              for (int i = 0; i < shenShaList.length; i++)
                LayoutId(
                  id: i,
                  child: _buildShenShaItem(shenShaList[i], i),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建单个神煞项组件
  Widget _buildShenShaItem(String text, int index) {
    return Transform.rotate(
      angle: (math.pi / 6) * index, // 每个项旋转30度对齐扇形
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.amber[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Transform.rotate(
          angle: -(math.pi / 6) * index, // 反向旋转保持文字正向
          child:
              Text(text, style: TextStyle(fontSize: 14, color: Colors.black87)),
        ),
      ),
    );
  }
}

// 自定义布局代理类
class CircleLayoutDelegate extends MultiChildLayoutDelegate {
  final int childCount;

  CircleLayoutDelegate({required this.childCount});

  @override
  void performLayout(Size size) {
    final double radius = size.width / 2 * 0.8; // 半径取容器宽度的80%
    final Offset center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < childCount; i++) {
      if (!hasChild(i)) continue;

      // 1. 计算极坐标角度 (每30度一个间隔)
      final double angle = 2 * math.pi * i / childCount;

      // 2. 布局子组件
      final Size childSize =
          layoutChild(i, BoxConstraints.loose(Size(60, 60)) // 限制最大尺寸
              );

      // 3. 计算最终位置（极坐标转笛卡尔坐标）
      final double x =
          center.dx + radius * math.cos(angle) - childSize.width / 2;
      final double y =
          center.dy + radius * math.sin(angle) - childSize.height / 2;
      positionChild(i, Offset(x, y));
    }
  }

  @override
  bool shouldRelayout(CircleLayoutDelegate oldDelegate) {
    return oldDelegate.childCount != childCount;
  }
}
