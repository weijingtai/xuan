import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qizhengsiyu/dev_demo2.dart';
import 'package:qizhengsiyu/dev_demo_v2.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/widgets/rings/da_xian_ring.dart';
import 'package:qizhengsiyu/widgets/rings/gong_12_dizhi_v2.dart';
import 'package:qizhengsiyu/sector_painter.dart';

import 'dev_demo.dart';
import 'gong_12_dizhi.dart';
import 'widgets/rings/gong_ming_li_ring.dart';
import 'navigator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // showSemanticsDebugger: false,
      // initialRoute: "/qizhengsiyu/panel",
      // onGenerateRoute: NavigatorGenerator.generateRoute,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          height: 1300,
          width: 1400,
          child: Row(
            children: [
              // 在 build 方法中
              Container(
                width: 480 * 2,
                height: 480 * 2,
                child: Stack(alignment: Alignment.center, children: [
                  Normal12GongRing(
                    outerRadius: 160,
                    innerRadius: 120,
                    baseGongOffsetAngle: 60,
                    // angleOffset: 3,
                    shenShaMapper: {
                      EnumTwelveGong.Chou: ["相貌"],
                      EnumTwelveGong.Zi: ["命宫"],
                      EnumTwelveGong.Yin: ["福德"],
                      EnumTwelveGong.Mao: ["官禄"],
                      EnumTwelveGong.Chen: ["迁移"],
                      EnumTwelveGong.Si: ["疾厄"],
                      EnumTwelveGong.Wu: ["夫妻"],
                      EnumTwelveGong.Wei: ["奴仆"],
                      EnumTwelveGong.Shen: ["男女"],
                      EnumTwelveGong.You: ["田宅"],
                      EnumTwelveGong.Xu: ["兄弟"],
                      EnumTwelveGong.Hai: ["财帛"],
                    },
                  ),
                  Normal12GongRing(
                    outerRadius: 120,
                    innerRadius: 100,
                    baseGongOffsetAngle: 60,
                    // angleOffset: 3,
                    shenShaMapper: {
                      EnumTwelveGong.Zi: ["水瓶"],
                      EnumTwelveGong.Chou: ["摩羯"],
                      EnumTwelveGong.Yin: ["射手"],
                      EnumTwelveGong.Mao: ["天蝎"],
                      EnumTwelveGong.Chen: ["天枰"],
                      EnumTwelveGong.Si: ["处女"],
                      EnumTwelveGong.Wu: ["狮子"],
                      EnumTwelveGong.Wei: ["巨蟹"],
                      EnumTwelveGong.Shen: ["双子"],
                      EnumTwelveGong.You: ["金牛"],
                      EnumTwelveGong.Xu: ["白羊"],
                      EnumTwelveGong.Hai: ["双鱼"],
                    },
                  ),
                  build12DiZhiGong(100, 50),
                  DaXianRing(
                      gongYearsMapper: {
                        // EnumTwelveGong.Zi: 4.5,
                        EnumTwelveGong.Zi: 15,
                        EnumTwelveGong.Chou: 10,
                        EnumTwelveGong.Yin: 11,
                        EnumTwelveGong.Mao: 15,
                        EnumTwelveGong.Chen: 8,
                        EnumTwelveGong.Si: 7,
                        EnumTwelveGong.Wu: 11,
                        EnumTwelveGong.Wei: 6,
                        EnumTwelveGong.Shen: 4.5,
                        EnumTwelveGong.You: 4.5,
                        // EnumTwelveGong.Shen: 5,
                        // EnumTwelveGong.You: 5,
                        EnumTwelveGong.Xu: 5,
                        EnumTwelveGong.Hai: 5,
                      },
                      outerRadius: 480,
                      innerRadius: 448,
                      baseGongOffsetAngle: 30),
                  // DaXianRing(
                  //     gongYearsMapper: {
                  //       // EnumTwelveGong.Zi: 4.5,
                  //       EnumTwelveGong.Zi: 13,
                  //       EnumTwelveGong.Chou: 10,
                  //       EnumTwelveGong.Yin: 11,
                  //       EnumTwelveGong.Mao: 15,
                  //       EnumTwelveGong.Chen: 8,
                  //       EnumTwelveGong.Si: 7,
                  //       EnumTwelveGong.Wu: 11,
                  //       EnumTwelveGong.Wei: 6,
                  //       EnumTwelveGong.Shen: 4.5,
                  //       EnumTwelveGong.You: 4.5,
                  //       // EnumTwelveGong.Shen: 5,
                  //       // EnumTwelveGong.You: 5,
                  //       EnumTwelveGong.Xu: 5,
                  //       EnumTwelveGong.Hai: 5,
                  //     },
                  //     gongOrderSeq: [
                  //       EnumTwelveGong.Zi
                  //     ],
                  //     outerRadius: 494,
                  //     innerRadius: 480,
                  //     baseGongOffsetAngle: 30)
                ]),
              )
            ],
          )),
    );
  }

  Widget build12DiZhiGong(double outerRadius, double innerRadius) {
    TextStyle firstTextStyle =
        TextStyle(fontSize: 18, height: 1.0, color: Colors.black87, shadows: [
      Shadow(
        color: Colors.black26,
        offset: Offset(1, 1),
        blurRadius: 3,
      ),
    ]);
    TextStyle secondTextStyle =
        TextStyle(fontSize: 12, height: 1.0, color: Colors.black87, shadows: [
      Shadow(
        color: Colors.black26,
        offset: Offset(1, 1),
        blurRadius: 3,
      ),
    ]);
    // double outerRadius = 100;
    // double innerRadius = outerRadius - 50;
    return Gong12DiZhiRingV2(
      outerRadius: outerRadius,
      innerRadius: innerRadius,
      // angleOffset: 3,
      shenShaMapper: {
        EnumTwelveGong.Zi: [
          Text("子", style: firstTextStyle),
          Text("坎", style: secondTextStyle),
          Text("土", style: secondTextStyle)
        ],
        EnumTwelveGong.Chou: [
          Text("丑", style: firstTextStyle),
          Text("艮", style: secondTextStyle),
          Text("土", style: secondTextStyle)
        ],
        EnumTwelveGong.Yin: [
          Text("寅", style: firstTextStyle),
          Text("艮", style: secondTextStyle),
          Text("木", style: secondTextStyle)
        ],
        EnumTwelveGong.Mao: [
          Text("卯", style: firstTextStyle),
          Text("震", style: secondTextStyle),
          Text("火", style: secondTextStyle)
        ],
        EnumTwelveGong.Chen: [
          Text("辰", style: firstTextStyle),
          Text("巽", style: secondTextStyle),
          Text("金", style: secondTextStyle)
        ],
        EnumTwelveGong.Si: [
          Text("巳", style: firstTextStyle),
          Text("巽", style: secondTextStyle),
          Text("水", style: secondTextStyle)
        ],
        EnumTwelveGong.Wu: [
          Text("午", style: firstTextStyle),
          Text("离", style: secondTextStyle),
          Text("日", style: secondTextStyle)
        ],
        EnumTwelveGong.Wei: [
          Text("未", style: firstTextStyle),
          Text("坤", style: secondTextStyle),
          Text("月", style: secondTextStyle)
        ],
        EnumTwelveGong.Shen: [
          Text("申", style: firstTextStyle),
          Text("坤", style: secondTextStyle),
          Text("水", style: secondTextStyle)
        ],
        EnumTwelveGong.You: [
          Text("酉", style: firstTextStyle),
          Text("兑", style: secondTextStyle),
          Text("金", style: secondTextStyle)
        ],
        EnumTwelveGong.Xu: [
          Text("戌", style: firstTextStyle),
          Text("乾", style: secondTextStyle),
          Text("火", style: secondTextStyle)
        ],
        EnumTwelveGong.Hai: [
          Text("亥", style: firstTextStyle),
          Text("乾", style: secondTextStyle),
          Text("木", style: secondTextStyle)
        ],
      },
    );
  }

  TextStyle getTextStyle() {
    return const TextStyle(
        fontSize: 13,
        height: 1.1,
        color: Colors.black87,
        shadows: [
          Shadow(
            color: Colors.black26,
            offset: Offset(1, 1),
            blurRadius: 3,
          ),
        ]);
  }

  Map<EnumTwelveGong, List<String>> getShenShaMapper() {
    Map<EnumTwelveGong, List<String>> shenShaMapper = {};
    // shenShaMapper[EnumTwelveGong.Zi] = shenShaList;
    for (int i = 0; i < 12; i++) {
      shenShaMapper[EnumTwelveGong.values[i]] = shenShaList;
      // shenShaList.sublist(0, 0 + math.Random().nextInt((18 - 0) + 1));
      // break;
    }
    return shenShaMapper;
  }

  static List<String> shenShaList = [
    "长生",
    "沐浴",
    "冠带",
    "临官",
    "帝旺",
    "衰",
    "病",
    "死",
    "墓",
    "绝",
    "胎",
    "养",
    "长生",
    "沐浴",
    "冠带",
    "临官",
    "帝旺",
    "衰",
    "病",
    "死",
    "墓",
    "绝",
    "胎",
    // "养",
  ];
}
