import 'package:flutter/material.dart';

import 'dart:math' as math;

class MoonPage extends StatefulWidget {
  const MoonPage({Key? key}) : super(key: key);

  @override
  _MoonPageState createState() => _MoonPageState();
}

class _MoonPageState extends State<MoonPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller; // 动画 controller

  Animation<double>? _animation; // 动画

  double changeR = 100.0;

  bool bigToSmall = true;

  int times = 0;

  double _screenWidth = 0, _screenHeight = 0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: const Duration(seconds: 4), vsync: this);

    _animation = Tween(begin: 100.0, end: 0.0).animate(_controller!)
      ..addListener(() {
//times = 1; 月盈--月半 100->0

//times = 2; 月盈--满月 0->100

//times = 3; 月亏--月半 100->0

//times = 4; 月亏--无月 0->100

        if (_animation?.status == AnimationStatus.completed) {
          times = times + 1;
          _controller?.reverse();
        } else if (_animation?.status == AnimationStatus.dismissed) {
          times = times + 1;
          _controller?.forward();

          if (times == 4) {
            times = 0;
          }
        }

        if ((_animation?.value ?? 0.0) > changeR) {
          bigToSmall = false;
        } else {
          bigToSmall = true;
        }

        changeR = _animation?.value ?? 0.0;

        setState(() {});
      });

// 显示的时候动画就开始

    _controller?.forward();
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("月亮"),
      ),
      body: Container(
        color: Colors.black,
        width: _screenWidth,
        height: _screenHeight,
        child: Stack(children: [
          Offstage(
            offstage: !(times < 2),
            child: CustomPaint(
              painter: MoonFullShapedPainter(
                  _screenWidth, _screenWidth, changeR, bigToSmall),
              size: Size(_screenWidth, _screenWidth),
            ),
          ),
          Offstage(
            offstage: (times < 2),
            child: CustomPaint(
              painter: MoonLossShapedPainter(
                  _screenWidth, _screenWidth, changeR, bigToSmall),
              size: Size(_screenWidth, _screenWidth),
            ),
          ),
          const Positioned(
              top: 30,
              left: 20,
              child: Text(
                "人有悲欢离合，月有阴晴圆缺",
                style: TextStyle(color: Colors.yellow, fontSize: 18),
              ))
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _animation?.isDismissed;

    _controller?.dispose();

    super.dispose();
  }
}

class MoonFullShapedPainter extends CustomPainter {
  double width;

  double height;

  double changeR;

  bool bigToSmall;

  MoonFullShapedPainter(this.width, this.height, this.changeR, this.bigToSmall);

  final Paint _paint = Paint()..strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    double r = 100;

    double centerX = size.width / 2;

    double centerY = size.height / 2;

    Rect rect2 = Rect.fromCircle(center: Offset(centerX, centerY), radius: r);

// 还需要开始的弧度、结束的弧度(0-2*pi)、是否使用中心点绘制、以及paint弧度

    canvas.drawArc(
        rect2,
        math.pi * 3 / 2,
        math.pi,
        true,
        _paint
          ..color = Colors.yellow
          ..style = PaintingStyle.fill);

    /// 椭圆

//使用左上和右下角坐标来确定矩形的大小和位置,椭圆是在这个矩形之中内切的

    Rect rect1 = Rect.fromPoints(Offset(centerX - changeR, centerY - r),
        Offset(centerX + changeR, centerY + r));

    if (bigToSmall) {
//右边黄色半圆+白色椭圆100->0

      _paint.color = Colors.black;

      canvas.drawOval(rect1, _paint);
    } else {
//右边黄色半圆,黄色椭圆0->100

      _paint.color = Colors.yellow;

      canvas.drawOval(rect1, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MoonLossShapedPainter extends CustomPainter {
  double width;

  double height;

  double changeR;

  bool bigToSmall;

  MoonLossShapedPainter(this.width, this.height, this.changeR, this.bigToSmall);

  final Paint _paint = Paint()..strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    double r = 100;

    double centerX = size.width / 2;

    double centerY = size.height / 2;

    Rect rect2 = Rect.fromCircle(center: Offset(centerX, centerY), radius: r);

// 还需要开始的弧度、结束的弧度(0-2*pi)、是否使用中心点绘制、以及paint弧度

    canvas.drawArc(
        rect2,
        math.pi / 2,
        math.pi,
        true,
        _paint
          ..color = Colors.yellow
          ..style = PaintingStyle.fill);

    /// 椭圆

//使用左上和右下角坐标来确定矩形的大小和位置,椭圆是在这个矩形之中内切的

    Rect rect1 = Rect.fromPoints(Offset(centerX - changeR, centerY - r),
        Offset(centerX + changeR, centerY + r));

    if (bigToSmall) {
//左边边黄色半圆+白色椭圆100->0

      _paint.color = Colors.yellow;

      canvas.drawOval(rect1, _paint);
    } else {
//右边黄色半圆,黄色椭圆0->100

      _paint.color = Colors.black;

      canvas.drawOval(rect1, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
