import 'dart:math' as math;
import 'dart:math';
import 'package:common/module.dart';
import 'package:flutter/material.dart';

class OneYearCircle extends StatefulWidget {
  const OneYearCircle({super.key});

  @override
  State<OneYearCircle> createState() => _OneYearCircleState();
}

class _OneYearCircleState extends State<OneYearCircle> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width  = MediaQuery.of(context).size.width;
    double minSize = height > width ? width : height;
    double size = minSize * 0.86;
    return Scaffold(
      body: Container(
        width: 1000,
        height: 1000,
        alignment: Alignment.center,
        color: Colors.red.withOpacity(.1),
        child:  Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.2),
                borderRadius: BorderRadius.circular(100/2),
              ),
            ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.2),
                borderRadius: BorderRadius.circular(100/2),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 1000,
                height: 1000,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.2),
                  // borderRadius: BorderRadius.circular(480),
                ),
                child:  Transform.rotate(
                  // angle: 60 * math.pi / 180,
                  angle: 0,
                  // origin: Offset.zero,
                  origin: Offset(500,500),
                  child: CustomPaint(
                    size: Size(1000, 1000),
                    painter: CircleRingPainter(
                        innerRadius: 476 - 6,
                        outerRadius: 500,
                        eachAngleDegree: 30,
                        innerPadding: 4,
                        outerPadding: 2,
                        isReverseText: false,
                        // textList: ['甲子金', '乙丑金', '甲寅金', '甲卯金', '甲辰金', '甲巳金', '甲午金', '甲未金', '甲申金', '甲酉金', '甲戌金', '甲亥金'],
                        // textList: ['甲子', '乙丑', '甲寅', '甲卯', '甲辰', '甲巳', '甲午', '甲未', '甲申', '甲酉', '甲戌', '甲亥'],
                        // textList: ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'],
                        textList: [
                          "甲甲","乙丑","丙寅","丁卯",
                          "戊辰","己巳","庚午","辛未",
                          "壬申","癸酉","甲戌","乙亥",
                          "丙子","丁丑","戊寅","己卯",
                          "庚辰","辛巳","壬午","癸未",
                          "甲申","乙酉","丙戌","丁亥",
                          "戊子","己丑","庚寅","辛卯",
                          "壬辰","癸巳","甲午","乙未",
                          "丙申","丁酉","戊戌","己亥",
                          "庚子","辛丑","壬寅","癸卯",
                          "甲辰","乙巳","丙午","丁未",
                          "戊申","己酉","庚戌","辛亥",
                          "壬子","癸丑","甲寅","乙卯",
                          "丙辰","丁巳","戊午","己未",
                          "庚申","辛酉","壬戌","癸亥"
                        ]
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 940, //
                height: 940,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(.4),width: 1),
                  borderRadius: BorderRadius.circular(940/2),
                ),
                child:  Transform.rotate(
                  // angle: 60 * math.pi / 180,
                  angle: 0,
                  // origin: Offset.zero,
                  origin: Offset(470,470),
                  child: CustomPaint(
                    size: Size(940, 940),
                    painter: CircleRingPainter(
                      // innerRadius: 452,
                      // outerRadius: 476,
                      innerRadius: 440,
                      outerRadius: 470,
                      innerPadding: 4,
                      outerPadding: 2,
                      eachAngleDegree: 12.8,
                      isReverseText: true,
                      isHorizontalText: true,
                      // textList: ['甲子金', '乙丑金', '甲寅金', '甲卯金', '甲辰金', '甲巳金', '甲午金', '甲未金', '甲申金', '甲酉金', '甲戌金', '甲亥金'],
                      // textList: ['甲子', '乙丑', '甲寅', '甲卯', '甲辰', '甲巳', '甲午', '甲未', '甲申', '甲酉', '甲戌', '甲亥'],
                      // textList: ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'],
                      textList: ['斗',"牛","女","虚","危","室","壁","奎","娄","胃","昴","毕","觜","参","井","鬼","柳","星","张","翼","轸","角","亢","氐","房","心","尾","箕"],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 880, //
                height: 880,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(.4),width: 1),
                  borderRadius: BorderRadius.circular(940/2),
                ),
                child:  Transform.rotate(
                  // angle: 60 * math.pi / 180,
                  angle: 0,
                  // origin: Offset.zero,
                  origin: Offset(440,440),
                  child: CustomPaint(
                    size: Size(880, 880),
                    painter: CircleRingPainter(
                        innerRadius: 410,
                        outerRadius: 440,
                        innerPadding: 4,
                        outerPadding: 2,
                        eachAngleDegree: 5,
                        isReverseText: true,
                        isHorizontalText: true,
                        textList: [
                          "立春", "雨水", "惊蛰", "春分", "清明", "谷雨",
                          "立夏", "小满", "芒种", "夏至", "小暑", "大暑",
                          "立秋", "处暑", "白露", "秋分", "寒露", "霜降",
                          "立冬", "小雪", "大雪", "冬至", "小寒", "大寒",
                        ]
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 820, //
                height: 820,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(.4),width: 1),
                  borderRadius: BorderRadius.circular(820/2),
                ),
                child:  Transform.rotate(
                  // angle: 60 * math.pi / 180,
                  angle: 0,
                  // origin: Offset.zero,
                  origin: Offset(410,410),
                  child: CustomPaint(
                    size: Size(820, 820),
                    painter: CircleRingPainter(
                        innerRadius: 380,
                        outerRadius: 410,
                        innerPadding: 4,
                        outerPadding: 2,
                        eachAngleDegree: 30,
                        isReverseText: true,
                        isHorizontalText: true,
                        textList: [
                          "正月", "二月", "三月", "四月", "五月", "六月",
                          "七月", "八月", "九月", "十月", "冬月", "腊月",
                        ]
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 760, //
                height: 760,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(.4),width: 1),
                  borderRadius: BorderRadius.circular(760/2),
                ),
                child:  Transform.rotate(
                  // angle: 60 * math.pi / 180,
                  angle: 0,
                  // origin: Offset.zero,
                  origin: Offset(380,380),
                  child: CustomPaint(
                    size: Size(760, 760),
                    painter: CircleRingPainter(
                        innerRadius: 350,
                        outerRadius: 380,
                        innerPadding: 4,
                        outerPadding: 2,
                        eachAngleDegree: 30,
                        isReverseText: true,
                        isHorizontalText: true,
                        textList: [
                          "泰","大壮","夬","乾","姤","遁","否","观","剥","坤","复","临",
                        ]
                    ),
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: Container(
                width: 476*2,
                height: 476*2,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // color: Colors.grey.withOpacity(.2),
                  // borderRadius: BorderRadius.circular(480),
                ),
                child:  Transform.rotate(
                  // angle: 60 * math.pi / 180,
                  angle: 0,
                  // origin: Offset.zero,
                  origin: Offset(476,476),
                  child: CustomPaint(
                    size: Size(476*2, 476*2),
                    painter: CircleRingPainter(
                      // innerRadius: 452,
                      // outerRadius: 476,
                        innerRadius: 120,
                        outerRadius: 144 + 6,
                        innerPadding: 4,
                        outerPadding: 2,
                        eachAngleDegree: 30,
                        isReverseText: true,
                        isHorizontalText: true,
                        // textList: ['甲子金', '乙丑金', '甲寅金', '甲卯金', '甲辰金', '甲巳金', '甲午金', '甲未金', '甲申金', '甲酉金', '甲戌金', '甲亥金'],
                        textList: ['甲子', '乙丑', '甲寅', '甲卯', '甲辰', '甲巳', '甲午', '甲未', '甲申', '甲酉', '甲戌', '甲亥'],
                        // textList: ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'],
                    ),
                  ),
                ),
              ),
            ),

          ],
        )

      ),
    );
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 480,
              height: 480,
              alignment: Alignment.center,
              child: CustomPaint(
                painter: CircleRingPainter(
                    innerRadius: 460,
                    outerRadius: 480,
                    eachAngleDegree: 30,
                    // textList: ['甲子金', '乙丑金', '甲寅金', '甲卯金', '甲辰金', '甲巳金', '甲午金', '甲未金', '甲申金', '甲酉金', '甲戌金', '甲亥金'],
                    // textList: ['甲子', '乙丑', '甲寅', '甲卯', '甲辰', '甲巳', '甲午', '甲未', '甲申', '甲酉', '甲戌', '甲亥'],
                    // textList: ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'],
                    textList: [
                      "甲甲","乙丑","丙寅","丁卯",
                      "戊辰","己巳","庚午","辛未",
                      "壬申","癸酉","甲戌","乙亥",
                      "丙子","丁丑","戊寅","己卯",
                      "庚辰","辛巳","壬午","癸未",
                      "甲申","乙酉","丙戌","丁亥",
                      "戊子","己丑","庚寅","辛卯",
                      "壬辰","癸巳","甲午","乙未",
                      "丙申","丁酉","戊戌","己亥",
                      "庚子","辛丑","壬寅","癸卯",
                      "甲辰","乙巳","丙午","丁未",
                      "戊申","己酉","庚戌","辛亥",
                      "壬子","癸丑","甲寅","乙卯",
                      "丙辰","丁巳","戊午","己未",
                      "庚申","辛酉","壬戌","癸亥"
                    ]
                ),
              ),
            ),

            Container(
              width: 500,
              height: 500,
              child: CustomPaint(
                painter: CircleRingPainter(
                    innerRadius: 480,
                    outerRadius: 500,
                    eachAngleDegree: 30,
                    // textList: ['甲子金', '乙丑金', '甲寅金', '甲卯金', '甲辰金', '甲巳金', '甲午金', '甲未金', '甲申金', '甲酉金', '甲戌金', '甲亥金'],
                    // textList: ['甲子', '乙丑', '甲寅', '甲卯', '甲辰', '甲巳', '甲午', '甲未', '甲申', '甲酉', '甲戌', '甲亥'],
                    // textList: ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'],
                    textList: [
                      "甲子","乙丑","丙寅","丁卯",
                      "戊辰","己巳","庚午","辛未",
                      "壬申","癸酉","甲戌","乙亥",
                      "丙子","丁丑","戊寅","己卯",
                      "庚辰","辛巳","壬午","癸未",
                      "甲申","乙酉","丙戌","丁亥",
                      "戊子","己丑","庚寅","辛卯",
                      "壬辰","癸巳","甲午","乙未",
                      "丙申","丁酉","戊戌","己亥",
                      "庚子","辛丑","壬寅","癸卯",
                      "甲辰","乙巳","丙午","丁未",
                      "戊申","己酉","庚戌","辛亥",
                      "壬子","癸丑","甲寅","乙卯",
                      "丙辰","丁巳","戊午","己未",
                      "庚申","辛酉","壬戌","癸亥"
                    ]
                ),
              ),
            ),


          ],
        )
      ),
    );
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: const Text('一年'),
      // ),
      body: Container(
          alignment: Alignment.center,
          color: Colors.grey.withOpacity(.1),
          child: Center(
            child: Container(
              height: size,
              width: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.2),
                borderRadius: BorderRadius.circular(size/2),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(size, size),
                      painter: CompleteCirclePainter(color: Colors.blue),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: size - 64,
                      width: size - 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.2),
                        borderRadius: BorderRadius.circular((size - 64)/2),
                      ),
                      child: Transform.rotate(
                        angle: 45 * math.pi / 180,
                        origin: Offset.zero,
                        child:CustomPaint(
                          size: Size(size - 64 , size - 64),
                          painter: CompleteCirclePainter(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: size - 128,
                      width: size - 128,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.2),
                        borderRadius: BorderRadius.circular((size - 128)/2),
                      ),
                      child: Transform.rotate(
                        angle: 60 * math.pi / 180,
                        origin: Offset.zero,
                        child:CustomPaint(
                          size: Size(size - 64 , size - 64),
                          painter: CompleteCirclePainter(
                            color: Colors.brown,
                            degree: 6,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: size - 128 - 64,
                      width: size - 128 -64,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.2),
                        borderRadius: BorderRadius.circular((size - 128)/2),
                      ),
                      child: Transform.rotate(
                        angle: 60 * math.pi / 180,
                        origin: Offset.zero,
                        child:CustomPaint(
                          size: Size(size - 128-64,size - 128-64),
                          painter: RingScalePainter(
                            ringWidth: 48,
                            tickLength: 8,
                            longTickLength: 16,
                            longTickAngles: [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300],
                          ),
                        ),
                      ),
                    ),
                    // Container(
                    //   alignment: Alignment.center,
                    //   height: 56 + 96,
                    //   width: 56 + 96,
                    //   decoration: BoxDecoration(
                    //     color: Colors.blue.withOpacity(.6),
                    //     borderRadius: BorderRadius.circular((56 + 96)/2),
                    //   ),
                    //   child: Transform.rotate(
                    //     angle: 60 * math.pi / 180,
                    //     origin: Offset.zero,
                    //     child:CustomPaint(
                    //       size: Size(56 + 96 , 56 + 96),
                    //       painter: CompleteCirclePainter(
                    //         color: Colors.brown,
                    //         degree: 360 / 4,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Container(
                      alignment: Alignment.center,
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular((56)/2),
                      ),
                      child: Transform.rotate(
                        angle: 45 * math.pi / 180,
                        origin: Offset.zero,
                        child:CustomPaint(
                          size: Size(56,56),
                          painter: CompleteCirclePainter(
                            height: 72,
                            color: Colors.white,
                            listContent: ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'],
                          ),
                        ),
                      ),
                    ),
                    // 中心
                    Container(
                      alignment: Alignment.center,
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.2),
                        borderRadius: BorderRadius.circular((size - 128)/2),
                      ),
                    )

                  ],
                ),
              ),
            ),
          )

      ),
    );
  }
}
// v1 没有文字
// class MyPainter extends CustomPainter {
//   final double innerRadius;
//   final double outerRadius;
//   final double sweepAngleDegree;
//
//   MyPainter({required this.innerRadius, required this.outerRadius, required this.sweepAngleDegree});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Offset center = Offset(size.width / 2, size.height / 2);
//     final double startAngle = -math.pi / 2;
//     final double sweepAngle = sweepAngleDegree * math.pi / 180;
//     final Paint paint = Paint()
//       ..color = Colors.orange
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = outerRadius - innerRadius;
//
//     canvas.drawArc(Rect.fromCircle(center: center, radius: outerRadius), startAngle, sweepAngle, false, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter old) {
//     return false;
//   }
// }


class CircleRingPainter extends CustomPainter {
  final double innerRadius;
  final double outerRadius;
  late final double sweepAngleDegree;
  final String? text;
  List<String>? textList;
  late TextStyle textStyle;
  bool isReverseText = false;
  bool isHorizontalText = false;
  bool isReverseOrderSequence = false;

  double innerPadding = 12;
  double outerPadding = 12;


  CircleRingPainter({
    required this.innerRadius,
    required this.outerRadius,
    double? eachAngleDegree,
    this.text,
    this.textList,
    this.isReverseText = true,
    this.isHorizontalText = true,
    this.isReverseOrderSequence = false,
    this.innerPadding = 12,
    this.outerPadding = 12,
    this.textStyle = const TextStyle(color: Colors.black, fontSize: 18,height: 1.2),}){
    if (textList != null && textList!.isNotEmpty){
      sweepAngleDegree = 360 / textList!.length;
    }else{
      sweepAngleDegree = eachAngleDegree ?? 360;
    }
  }

  void debugPaint(Canvas canvas, Size size, Offset center){
    // canvas.translate(center.dx, center.dy);
    // 给canvas绘制灰色透明度为0.1的背景
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width/2, backgroundPaint);

    final Paint background2Paint = Paint()
      ..color = Colors.blue.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, background2Paint);

    final Paint background3Paint = Paint()
      ..color = Colors.blue.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, background3Paint);
    // 绘制圆心点
    final Paint centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);


  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // canvas.save();

    canvas.translate(size.width / 2, size.height / 2);
    // canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 4);


    final res = sweepAngleDegree *0.5 * math.pi / 180;
    final double startAngle = math.pi / 2 - res;
    final double sweepAngle = sweepAngleDegree * math.pi / 180;
    final fanRingWidth = outerRadius - innerRadius;

    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = fanRingWidth;

    // canvas.translate(center.dx, center.dy);
    // 计算每个扇环的中心角度
    // double angle = startAngle;
    double arcDrawCircleRadius = innerRadius + (fanRingWidth * 0.5);
    double textRotationAngle =startAngle + sweepAngle / 2;
    int total = 360 ~/ sweepAngleDegree;
    if (textList != null && textList!.isNotEmpty) {
      total = textList!.length;
    }
    // 12点方向为起始点
    canvas.rotate(pi - pi/4);
    // 9点方向为起始点 -- not work
    // canvas.rotate(pi/4);
    // 6点方向为起始点 -- not work
    // canvas.rotate(-pi/4);
    // 3点方向为起始点 -- not work
    // canvas.rotate(pi + pi/4);


    for (int i = 0; i < total; i++) {
      // 绘制扇环
      Path path = Path()..addArc(Rect.fromCircle(center: Offset.zero, radius: arcDrawCircleRadius), startAngle, sweepAngle,);
      // canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: arcDrawCircleRadius), startAngle, sweepAngle, false, paint);
      canvas.drawPath(path,paint);
      // canvas.drawShadow(path, Colors.blue.withOpacity(0.4), 5, false);

      if (text != null){
        if (text!.length == 1){
          // 绘制文字
          paintSingleChar(
              canvas, size, text!, center, textRotationAngle, fanRingWidth);
        }else{
          if (isHorizontalText) {
            // 绘制文字
            paintSingleChar(
                canvas, size, text!, center, textRotationAngle, fanRingWidth);
          }else{
            // 绘制文字
            paintVerticalText(
                canvas, size, text!, center, textRotationAngle, fanRingWidth);
          }
        }
      }
      else{
        if (textList != null && textList!.isNotEmpty) {
          var text = textList![i];
          if (text.length == 1) {
            // 绘制文字
            paintSingleChar(
                canvas, size, text, center, textRotationAngle, fanRingWidth);
          }else{
            if (isHorizontalText){
              // 绘制文字
              paintSingleChar(
                  canvas, size, text!, center, textRotationAngle, fanRingWidth);
            }else{
              // 绘制文字
              paintVerticalText(
                  canvas, size, text, center,textRotationAngle , fanRingWidth);
            }
          }
        }
      }
      canvas.rotate((pi * 2)/total);
    }
  }

  void paintSingleChar(Canvas canvas, Size size, String text, Offset center,double rotationAngle,double yOffset) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    Offset offset = isReverseText?Offset(
      -textPainter.width * 0.5,
      -innerRadius - innerPadding - textPainter.height +textPainter.height*.1,
    ):Offset(
      -textPainter.width * 0.5,
      innerRadius + innerPadding,
    );
    double rotateAngle = isReverseText?pi:0.0;
    canvas.rotate(rotateAngle);
    textPainter.paint(canvas, offset);

  }

  void paintVerticalText(Canvas canvas, Size size, String text, Offset center,double rotationAngle,double yOffset) {
    // splite text to single char
    List<String> textList = text.split('');
    int totalLength = textList.length;
    for (int i = 0; i < totalLength;i++){
      final textSpan = TextSpan(
        text: textList[i],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      double rotateAngle = isReverseText?pi:0.0;
      if (i == 0){
        Offset offset = isReverseText?Offset(
          center.dx - outerRadius - (textPainter.size.width *0.5),
          - innerRadius - (textPainter.size.height * .9 * totalLength),
        ):Offset(
          center.dx - outerRadius - (textPainter.size.width *0.5),
          innerRadius + textPainter.size.height * 0.1,
        );
        // canvas.translate(offset.dx, offset.dy);
        // canvas.translate(center.dx, center.dy);
        canvas.rotate(rotateAngle);
        textPainter.paint(canvas, offset);
      }else{
        Offset offset = isReverseText?Offset(
          center.dx - outerRadius - (textPainter.size.width *0.5),
          - innerRadius - (textPainter.size.height* .9 * (totalLength - i) ),
        ):Offset(
          center.dx - outerRadius - (textPainter.size.width *0.5),
          innerRadius + textPainter.size.height * 0.9 * i,
        );
        // canvas.translate(offset.dx, offset.dy);
        textPainter.paint(canvas, offset);
      }
    }
    canvas.save();
    canvas.restore();

  }

  void paintHorizontalText(Canvas canvas, Size size, String text, Offset center,double rotationAngle,double yOffset) {
    // splite text to single char
    List<String> textList = text.split('').reversed.toList();
    int totalLength = textList.length;
    canvas.save();
    // canvas.translate(-size.width,-size.height);
    // canvas.translate(0,0);
    if (totalLength.isEven){
      for (int i =0;i < totalLength;i++){
        final textSpan = TextSpan(
          text: textList[i],
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        Offset offset = isReverseText?Offset(
          -textPainter.width * 0.5,
          -innerRadius - textPainter.height * .5,
        ):Offset(
          -textPainter.width * 0.5,
          innerRadius + textPainter.height * .1,
        );
        double rotateAngle = isReverseText?pi:0.0;
        if (i == 0){
          offset = isReverseText?Offset(
            -textPainter.width * 0.5 * 2,
            -innerRadius - textPainter.height * .5,
          ):Offset(
            // -textPainter.width * 0.5,
            // textPainter.width * - .2,
            // -textPainter.width,
            -textPainter.width *0.6,
            innerRadius + textPainter.height * .04,
          );
          canvas.rotate(rotateAngle-pi * .04);
          // canvas.save();
          // canvas.restore();
        }else{
          offset = isReverseText?Offset(
            textPainter.width * 0.5 * 2,
            -innerRadius - textPainter.height * .5,
          ):Offset(
            -textPainter.width * 1.2,
            // 0,
            innerRadius + textPainter.height * .04,
          );
          // canvas.rotate(rotateAngle + pi * .02);
          canvas.rotate(rotateAngle + pi * .04);
        }
        textPainter.paint(canvas, offset);
      }

    }
    // canvas.save();
    canvas.restore();
  }



  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}

// class MyPainter extends CustomPainter {
//   final double innerRadius;
//   final double outerRadius;
//   final double sweepAngleDegree;
//   final String text;
//   late TextStyle textStyle;
//   bool reverseText = false;
//   MyPainter({
//     required this.innerRadius,
//     required this.outerRadius,
//     required this.sweepAngleDegree,
//     required this.text,
//     this.reverseText = false,
//     this.textStyle = const TextStyle(color: Colors.black, fontSize: 18,height: 1.2),});
//
//   // v1 complete with text
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Offset center = Offset(size.width / 2, size.height / 2);
//     final res = sweepAngleDegree *0.5 * math.pi / 180;
//     final double startAngle = math.pi / 2 - res;
//     final double sweepAngle = sweepAngleDegree * math.pi / 180;
//     final Paint paint = Paint()
//       ..color = Colors.orange
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = outerRadius - innerRadius;
//
//     canvas.drawArc(Rect.fromCircle(center: center, radius: outerRadius), startAngle, sweepAngle, false, paint);
//     canvas.save();
//     paintText(canvas, size, text, center, startAngle + sweepAngle / 2);
//
//   }
//   void paintText(Canvas canvas, Size size, String text, Offset center,double rotationAngle) {
//     // splite text to single char
//     List<String> textList = text.split('');
//
//     final textSpan = TextSpan(
//       text: text,
//       style: textStyle,
//     );
//     final textPainter = TextPainter(
//       text: textSpan,
//       textDirection: TextDirection.ltr,
//     );
//     textPainter.layout(
//       minWidth: 0,
//       maxWidth: size.width,
//     );
//     Offset offset = reverseText?Offset(
//       center.dx + (textPainter.size.width *0.5),
//       center.dy + (outerRadius + textPainter.size.height *0.45),
//     ):Offset(
//       center.dx - (textPainter.size.width *0.5),
//       center.dy + (outerRadius - textPainter.size.height *0.45),
//     );
//     double rotateAngle = reverseText?pi:0.0;
//     canvas.translate(offset.dx, offset.dy);
//     canvas.rotate(rotateAngle);
//     textPainter.paint(canvas, Offset.zero);
//     canvas.restore();
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter old) {
//     return false;
//   }
// }





