import 'dart:math';

import 'package:flutter/material.dart';

class LinePainterWidget extends StatefulWidget {
  const LinePainterWidget({super.key});

  @override
  _LinePainterWidgetState createState() => _LinePainterWidgetState();
}

class _LinePainterWidgetState extends State<LinePainterWidget>
    with TickerProviderStateMixin {
  late AnimationController _redDotPointerController;
  late Animation<double> _redDotPointerAnimation;

  late AnimationController _greenDotPointController;
  late Animation<double> _greenAnimation;

  final GlobalKey redStarKey = GlobalKey();
  final GlobalKey redDotPointerKey = GlobalKey();

  final GlobalKey greenStarKey = GlobalKey();
  final GlobalKey greenDotPointerKey = GlobalKey();

  final GlobalKey appBarKey = GlobalKey();
  Offset start = const Offset(0, 0);
  Offset end = const Offset(0, 0);
  Offset redDotCenter = const Offset(0, 0);
  @override
  void initState() {
    super.initState();

    _redDotPointerController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
    _redDotPointerAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_redDotPointerController);

    _greenDotPointController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _greenAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_greenDotPointController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        start = _getCenter(redStarKey);
        end = _getCenter(redDotPointerKey);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _redDotPointerController.dispose();
    _greenDotPointController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            key: appBarKey, title: const Text('Draw Line Between Boxes')),
        body: Column(
          children: [
            Container(
                width: 1000,
                height: 1000,
                color: Colors.grey.withValues(alpha: .1),
                child: SizedBox(
                  width: 810,
                  height: 810,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 800,
                        height: 800,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: .1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(800)),
                        ),
                      ),
                      // if (start != null && end != null)
                      //   Positioned(
                      //       top: 0,
                      //       left: 0,
                      //       child: CustomPaint(
                      //         painter: MyPainter(start, end),
                      //       )
                      //   ),

                      // Positioned(
                      //     top: (1000 - 810) / 2,
                      //     child: Container(
                      //       key: key2,
                      //       width: 10,
                      //       height: 10,
                      //       decoration: BoxDecoration(
                      //         color: Colors.red.withValues(alpha: .1),
                      //         borderRadius: BorderRadius.all(Radius.circular(10)),
                      //       ),
                      //     )
                      // ),

                      // Positioned(
                      //     top: (1000 - 810) / 2 + 100,
                      //     right: (1000 - 810) / 2 + 240,
                      //     child: Container(
                      //       key: greenKey,
                      //       width: 20,
                      //       height: 20,
                      //       decoration: BoxDecoration(
                      //         color: Colors.green,
                      //         borderRadius: BorderRadius.all(
                      //             Radius.circular(4)),
                      //       ),
                      //     )
                      // ),
                      AnimatedBuilder(
                        animation: _redDotPointerAnimation,
                        builder: (context, child) {
                          double angle = _redDotPointerAnimation.value;
                          double radius = 400;
                          double x = radius * cos(angle);
                          double y = radius * sin(angle);

                          double radius2 = 360;
                          double x2 = radius2 * cos(angle);
                          double y2 = radius2 * sin(angle);

                          var end = Offset(500 + x, 500 + y);
                          var start = Offset(500 + x2, 500 + y2);
                          return Positioned(
                              // top: 500 + y - 10,
                              // left: 500 + x - 10,
                              top: 0,
                              left: 0,
                              child: CustomPaint(
                                painter: MyPainter(start, end, Colors.red),
                              ));
                        },
                      ),
                      // red dot
                      AnimatedBuilder(
                        animation: _redDotPointerAnimation,
                        builder: (context, child) {
                          double angle = _redDotPointerAnimation.value;
                          double radius = 400;
                          double x = radius * cos(angle);
                          double y = radius * sin(angle);
                          return Positioned(
                            // left: 100 + x - 10,
                            // top: 100 + y - 10,
                            top: 500 + y - 2,
                            left: 500 + x - 2,
                            child: Container(
                              key: redDotPointerKey,
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _redDotPointerAnimation,
                        builder: (context, child) {
                          double angle = _redDotPointerAnimation.value;
                          double radius = 360;
                          double x = radius * cos(angle);
                          double y = radius * sin(angle);
                          return Positioned(
                              top: 500 + y - 12,
                              left: 500 + x - 12,
                              child: Container(
                                key: redStarKey,
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: .1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                ),
                                child: const Text(
                                  "火",
                                  style: TextStyle(fontSize: 16, height: 1),
                                ),
                              ));
                          return Positioned(
                            // left: 100 + x - 10,
                            // top: 100 + y - 10,
                            top: 500 + y - 10,
                            left: 500 + x - 10,
                            child: Container(
                              key: redDotPointerKey,
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),

                      AnimatedBuilder(
                        animation: _greenAnimation,
                        builder: (context, child) {
                          double angle = _greenAnimation.value;
                          double radius = 400;
                          double x = radius * cos(angle);
                          double y = radius * sin(angle);

                          double radius2 = 360;
                          double x2 = radius2 * cos(angle);
                          double y2 = radius2 * sin(angle);

                          var end = Offset(500 + x, 500 + y);
                          var start = Offset(500 + x2, 500 + y2);
                          return Positioned(
                              // top: 500 + y - 10,
                              // left: 500 + x - 10,
                              top: 0,
                              left: 0,
                              child: CustomPaint(
                                painter: MyPainter(start, end, Colors.green),
                              ));
                        },
                      ),
                      // red dot
                      AnimatedBuilder(
                        animation: _greenAnimation,
                        builder: (context, child) {
                          double angle = _greenAnimation.value;
                          double radius = 400;
                          double x = radius * cos(angle);
                          double y = radius * sin(angle);
                          return Positioned(
                            // left: 100 + x - 10,
                            // top: 100 + y - 10,
                            top: 500 + y - 2,
                            left: 500 + x - 2,
                            child: Container(
                              // key: redDotPointerKey,
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _greenAnimation,
                        builder: (context, child) {
                          double angle = _greenAnimation.value;
                          double radius = 360;
                          double x = radius * cos(angle);
                          double y = radius * sin(angle);
                          return Positioned(
                              top: 500 + y - 12,
                              left: 500 + x - 12,
                              child: Container(
                                // key: redStarKey,
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: .1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                ),
                                child: const Text(
                                  "木",
                                  style: TextStyle(fontSize: 16, height: 1),
                                ),
                              ));
                        },
                      ),
                    ],
                  ),
                ))
          ],
        ));
  }

  Widget body1() {
    return Container(
      alignment: Alignment.center,
      width: 1000,
      height: 1000,
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: .1)),
      child: SizedBox(
        width: 1000,
        height: 1000,
        child: Stack(
          // alignment: Alignment.center,
          children: [
            Positioned(
              left: 50,
              top: 50,
              child: Container(
                key: redStarKey,
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            Positioned(
              left: 200,
              top: 300,
              child: Container(
                key: redDotPointerKey,
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            CustomPaint(
              painter: MyPainter(start, end, Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Offset _getCenter(GlobalKey key) {
    // final RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    // final position = box.localToGlobal(Offset.zero);
    // return position.translate(box.size.width / 2, box.size.height /2);
    final RenderBox renderBoxRed =
        key.currentContext!.findRenderObject() as RenderBox;
    final sizeRed = renderBoxRed.size;
    double appBarHeight =
        (appBarKey.currentContext!.findRenderObject() as RenderBox).size.height;

    final positionRed = renderBoxRed.localToGlobal(Offset(0, -appBarHeight));
    return positionRed + Offset(sizeRed.width / 2, sizeRed.height / 2);
  }
}

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  LinePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MyPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  MyPainter(this.start, this.end, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
