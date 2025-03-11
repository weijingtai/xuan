import 'dart:math';
import 'dart:ui' as ui;
import 'package:common/painter/text_circle_ring_painter.dart';
import 'package:common/painter/circle_ring_printer.dart';
import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/pages/ui_star_model.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:sweph/sweph.dart';
import 'package:tuple/tuple.dart';

import 'package:timezone/timezone.dart' as tz;

import '../enums/enum_twelve_gong.dart';
import '../models/panel_stars_info.dart';
import '../models/observer_position.dart';
import '../painter/star_xiu_ring_painter.dart';
import '../painter/twelve_zhi_gong_circle_ring_printer.dart';
import '../qi_zheng_si_yu_ui_constant_resources.dart';

class BeautyPage extends StatefulWidget {
  const BeautyPage({super.key});

  @override
  State<BeautyPage> createState() => _BeautyPageState();
}

class _BeautyPageState extends State<BeautyPage> with TickerProviderStateMixin {
  final GlobalKey key1 = GlobalKey();
  final GlobalKey key2 = GlobalKey();

  late AnimationController _jupiterController; // 木星
  late AnimationController _saturnController; // 土星
  late AnimationController _venusController; // 金星
  late AnimationController _mercuryController; // 水星
  late AnimationController _marsController; // 火星

  late AnimationController _sunController; // 太阳
  late AnimationController _moonController; // 月亮

  late AnimationController _luoHouJiDuController; // 罗睺 计都
  late AnimationController _yueBeiController; // 月孛
  late AnimationController _ziQiController; // 紫炁

  double yuStarSize = 16;
  double zhengStarSize = 26;
  double yinYangStarSize = 32;

  double marsSkyCoordLon = 75.58091941;
  double venusSkyCoordLon = 359.88416846;
  double mercurySkyCoordLon = 312.79800634;
  double jupiterSkyCoordLon = 9.67729768;
  double saturnSkyCoordLon = 327.87317251;
  double sunSkyCoordLon = 331.24872792;
  double moonSkyCoordLon = 334.13505029;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 0°02′02‘’ 一天
    _jupiterController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1062))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _jupiterController.repeat();
        }
      });

    // 土星 0°00′59'' 一天
    _saturnController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2197))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _saturnController.repeat();
        }
      });

    // 金星 1°33′ 一天
    _venusController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1393))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _venusController.repeat();
        }
      });

    // 水星 4°5′ 一天
    _mercuryController =
        AnimationController(vsync: this, duration: const Duration(seconds: 88))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _mercuryController.repeat();
            }
          });

    // 火星 0°32′ 一天
    _marsController =
        AnimationController(vsync: this, duration: const Duration(seconds: 675))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _marsController.repeat();
            }
          });

    _sunController =
        AnimationController(vsync: this, duration: const Duration(seconds: 360))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _sunController.repeat();
            }
          });
    // 月亮 13°10′35" 一天
    _moonController =
        AnimationController(vsync: this, duration: const Duration(seconds: 27))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _moonController.repeat();
            }
          });

    _luoHouJiDuController =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _luoHouJiDuController.repeat();
            }
          });
    _yueBeiController =
        AnimationController(vsync: this, duration: const Duration(seconds: 18))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _yueBeiController.repeat();
            }
          });
    _ziQiController =
        AnimationController(vsync: this, duration: const Duration(seconds: 14))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _ziQiController.repeat();
            }
          });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _jupiterController.dispose();
    _saturnController.dispose();
    _venusController.dispose();
    _mercuryController.dispose();
    _marsController.dispose();

    _sunController.dispose();
    _moonController.dispose();

    _luoHouJiDuController.dispose();
    _yueBeiController.dispose();
    _ziQiController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    // double width  = MediaQuery.of(context).size.width;
    // double minSize = height > width ? width : height;

    // 黄道十二宫 从白羊开始
    // List<String> zodiacEnglishList = <String>["Ari白羊♈︎", "Tau金牛♉︎", "Gem双子♊︎", "Can巨蟹♋︎", "Leo狮子♌︎", "Vir处女♍︎", "Lib天秤♎︎︎", "Sco天蝎♏︎", "Sag射手♐︎", "Cap摩羯♑︎", "Agu水瓶♒︎", "Pis双鱼♓︎",];
    // List<String> zodiacList = <String>["白羊♈︎", "金牛♉︎", "双子♊︎", "巨蟹♋︎", "狮子♌︎", "处女♍︎", "天秤♎︎︎", "天蝎♏︎", "射手♐︎", "摩羯♑︎", "水瓶♒︎", "双鱼♓︎",];
    List<String> zodiacList = <String>[
      "白羊",
      "金牛",
      "双子",
      "巨蟹",
      "狮子",
      "处女",
      "天秤",
      "天蝎",
      "射手",
      "摩羯",
      "水瓶",
      "双鱼",
    ];
    // TextStyle zodiacTextStyle = TextStyle(color: Colors.grey, fontSize: 12,fontFamily: 'KaiTi',fontWeight: FontWeight.w300,height: 1.2);
    TextStyle zodiacTextStyle = GoogleFonts.longCang(
        color: const Color.fromRGBO(66, 76, 80, 1),
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.0);
    List<Text> zodiacTextList = zodiacList
        .map((e) => Text(
              e,
              style: zodiacTextStyle,
            ))
        .toList();

    // 十二星次 从大梁开始
    List<String> starSeqList = <String>[
      "降娄",
      "大梁",
      "实沈",
      "鹑首",
      "鹑火",
      "鹑尾",
      "寿星",
      "大火",
      "析木",
      "星纪",
      "玄枵",
      "娵訾",
    ];
    // TextStyle starTextStyle = TextStyle(color: Colors.grey, fontSize: 12,fontFamily: 'KaiTi',fontWeight: FontWeight.w300,height: 1.2);
    TextStyle starTextStyle = GoogleFonts.zhiMangXing(
        color: const Color.fromRGBO(80, 97, 109, 1),
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.0);
    List<Text> starSeqTextList = starSeqList
        .map((e) => Text(
              e,
              style: starTextStyle,
            ))
        .toList();
    // 命理十二宫 从命宫开始
    // List<String> destinyList = <String>["命宫①", "财帛②", "兄弟③", "田宅④", "男女⑤", "奴仆⑥", "夫妻⑦", "疾厄⑧", "迁移⑨", "官禄⑩", "福德⑪", "相貌⑫",];
    List<String> destinyList = <String>[
      "命宫",
      "财帛",
      "兄弟",
      "田宅",
      "男女",
      "奴仆",
      "夫妻",
      "疾厄",
      "迁移",
      "官禄",
      "福德",
      "相貌",
    ];
    // TextStyle destinyTextStyle = TextStyle(color: Colors.black, fontSize: 20,fontFamily: 'KaiTi',fontWeight: FontWeight.w400);
    TextStyle destinyTextStyle = GoogleFonts.maShanZheng(
        color: Colors.black87,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        shadows: [
          BoxShadow(
            color: Colors.black45.withOpacity(.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1), // changes position of shadow
          )
        ]);

    List<Text> destinySeqTextList = destinyList
        .map((e) => Text(
              e,
              style: destinyTextStyle.copyWith(
                  decoration: e == destinyList[0]
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  fontWeight:
                      e == destinyList[0] ? FontWeight.w600 : FontWeight.w500),
            ))
        .toList();

    // 设定观察者的经纬度和高度（例如：上海）
    double latitude = 31.2304; // 纬度
    double longitude = 121.4737; // 经度
    double altitude = 0; // 高度（米）
    var observerPostion = ObserverPosition(
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        birthday: DateTime(2024, 10, 13, 16, 45),
        timezone: 'Asia/Shanghai');

    StarsAngle starsAngle = calculateSevenZhengAngle(observerPostion);

    // print(starsAngle.toString());
    // StarsResolver.calculateMinSafeAngle(outerR, innerR, r)

    // FiveStarWalkingInfo value = StarWalkingInfoUtils.calculateStarWalkingInfo(EnumStars.Venus,observerPostion,StarsAngle.moirasFiveStartsMapper);
    // 使用 dart:math 库中的函数进行转换
    return Scaffold(
      body: Container(
          width: 1000,
          height: 1000,
          alignment: Alignment.center,
          child: Column(
            children: [
              // ArcButton(),
              const SizedBox(
                height: 20,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  // 黄道十二宫
                  // Container(
                  //   alignment: Alignment.center,
                  //   height: 292,
                  //   width: 292,
                  //   decoration: BoxDecoration(
                  //     color: Colors.red.withOpacity(.1),
                  //     borderRadius: BorderRadius.circular(292),
                  //     border: Border.all(color: Colors.black,width: 1),
                  //   ),
                  //   child: Transform.rotate(
                  //     angle: 105 * pi / 180,
                  //     origin: Offset.zero,
                  //     child:CustomPaint(
                  //       size: Size(292,292),
                  //       painter:CircleRingPainter(
                  //         innerRadius: 86,
                  //         outerRadius: 148,
                  //         textList:[
                  //           "戌乾火",
                  //           "亥乾木",
                  //           "子坎土",
                  //           "丑艮土",
                  //           "寅艮木",
                  //           "卯震火",
                  //           "辰巽金",
                  //           "巳巽水",
                  //           "午离日",
                  //           "未坤月",
                  //           "申坤水",
                  //           "酉兑金",
                  //         ],
                  //         isAntiClockwise: false,
                  //         innerPadding: 3,
                  //         isReverseText: false,
                  //         isHorizontalText: false,
                  //         textStyle: TextStyle(color: Colors.black, fontSize: 16,height: 1.2),),
                  //     ),
                  //   ),
                  // ),
                  Container(
                    alignment: Alignment.center,
                    height: 292,
                    width: 292,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.1),
                      borderRadius: BorderRadius.circular(292),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Transform.rotate(
                      angle: 105 * pi / 180,
                      origin: Offset.zero,
                      child: CustomPaint(
                          size: const Size(292, 292),
                          painter: TwelveZhiGongCircleRingPrinter(
                            innerRadius: 86,
                            outerRadius: 148,
                            twelveGongList: [
                              EnumTwelveGong.Xu,
                              EnumTwelveGong.Hai,
                              EnumTwelveGong.Zi,
                              EnumTwelveGong.Chou,
                              EnumTwelveGong.Yin,
                              EnumTwelveGong.Mao,
                              EnumTwelveGong.Chen,
                              EnumTwelveGong.Si,
                              EnumTwelveGong.Wu,
                              EnumTwelveGong.Wei,
                              EnumTwelveGong.Shen,
                              EnumTwelveGong.You,
                            ],
                            starColorMapper:
                                QiZhengSiYuUIConstantResources.zhengColorMap,
                            isAntiClockwise: false,
                            innerPadding: 3,
                            isReverseText: false,
                            isHorizontalText: false,
                            textStyle: GoogleFonts.maShanZheng(
                              height: 1.2,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          )),
                    ),
                  ),
                  // 黄道十二宫
                  drawRingWithTextList(333, 18, zodiacTextList),
                  // 星次十二宫
                  drawRingWithTextList(369, 18, starSeqTextList),
                  // 命理十二宫
                  drawRingWithTextList(436, 33, destinySeqTextList,
                      innerPadding: 2),
                  Transform.rotate(
                    // angle: 60 * math.pi / 180,
                    angle: 30 * pi / 180,
                    // origin: Offset.zero,
                    child: starXiuRing(520, 40),
                  ),

                  Container(
                      width: 172,
                      height: 172,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.1),
                        borderRadius: BorderRadius.circular(172),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "立命",
                                    style: TextStyle(fontSize: 12, height: 1.2),
                                  ),
                                  // SizedBox(width: 4,),
                                  Text(
                                    "昴日鸡",
                                    style: TextStyle(fontSize: 14, height: 1.2),
                                  ),
                                  Text(
                                    "六度",
                                    style: TextStyle(fontSize: 12, height: 1.2),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "运",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text("癸", style: TextStyle(fontSize: 16)),
                                  Text("卯", style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("流", style: TextStyle(fontSize: 10)),
                                  Text("辛", style: TextStyle(fontSize: 16)),
                                  Text("丑", style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "年",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text("癸", style: TextStyle(fontSize: 16)),
                                  Text("卯", style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("月", style: TextStyle(fontSize: 10)),
                                  Text("辛", style: TextStyle(fontSize: 16)),
                                  Text("丑", style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "日",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Text("癸", style: TextStyle(fontSize: 16)),
                                  Text("卯", style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("时", style: TextStyle(fontSize: 10)),
                                  Text("辛", style: TextStyle(fontSize: 16)),
                                  Text("丑", style: TextStyle(fontSize: 16)),
                                ],
                              )
                            ],
                          ),
                          Column(
                            children: [Text("ok3"), Text("ok3")],
                          ),
                        ],
                      )),
                  Container(
                    width: 520 + 32 + 10,
                    height: 520 + 32 + 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(560 + 32 + 10),
                      border: Border.all(
                          color: Colors.black.withOpacity(.1), width: 1),
                    ),
                  ),
                  // 月
                  // star("月",30),
                  // star("金",45),
                  // star("火",70),
                  // star("罗",90),
                  // star("日",270),
                  // star("水",250),
                  // star("木",120),
                  // star("土",210),
                  // star("孛",0),
                  // star("炁",260),
                  // star("计",340),

                  // star2(EnumStars.Saturn,350,64,offsetWidthTimes:2),
                  // star2(EnumStars.Venus,0,64,offsetWidthTimes:3),
                  // star2(EnumStars.Lunar,0,64,offsetWidthTimes:1),
                  // star2(EnumStars.Sun,0,64,offsetWidthTimes:-1),
                  // star2(EnumStars.Water,0,64,offsetWidthTimes:-3),
                  // star2(EnumStars.Jupiter,0,64,offsetWidthTimes:-5),
                  // star2(EnumStars.Mars,0,64,offsetWidthTimes:-7),
                  // star2(EnumStars.Qi,0,64,offsetWidthTimes:-9),
                  //
                  // star2(EnumStars.Venus,120,64,offsetWidthTimes:2),
                  // star2(EnumStars.Luo,120,64,offsetWidthTimes:0),
                  // star2(EnumStars.Water,120,64,offsetWidthTimes:-2),
                  // star2(EnumStars.Qi,124,64,offsetWidthTimes:-3),
                  //
                  // star2(EnumStars.Ji,300,64,offsetWidthTimes:0),
                  //
                  // star2(EnumStars.Bei,270,64,offsetWidthTimes:0),

                  // star2(EnumStars.Sun,200.16,64,offsetWidthTimes:0),
                  // star2(EnumStars.Lunar,322.97,64,offsetWidthTimes:0),

                  // star2(EnumStars.Sun,starsAngle.sun,64,offsetWidthTimes:0),
                  // star2(EnumStars.Moon,starsAngle.moon,64,offsetWidthTimes:0),
                  drawUIStarBody(UIStarModel(
                      star: EnumStars.Sun,
                      priority: 4,
                      originalAngle: 10,
                      rangeAngleEachSide: 4)),

                  // star2(EnumStars.Lunar,332.30,64,offsetWidthTimes:0),
                  // star2(EnumStars.Venus,283.98,64,offsetWidthTimes:0),
                  // star2(EnumStars.Jupiter,71.10,64,offsetWidthTimes:0),
                  // star2(EnumStars.Water,228.41,64,offsetWidthTimes:0),
                  // star2(EnumStars.Mars,69.78,64,offsetWidthTimes:0),
                  // star2(EnumStars.Saturn,346.78,64,offsetWidthTimes:0),
                  star2(EnumStars.Venus, starsAngle.Venus, 64,
                      offsetWidthTimes: 0),
                  star2(EnumStars.Jupiter, starsAngle.Jupiter, 64,
                      offsetWidthTimes: 0),
                  star2(EnumStars.Mercury, starsAngle.water, 64,
                      offsetWidthTimes: 0),
                  star2(EnumStars.Mars, starsAngle.Mars, 64,
                      offsetWidthTimes: 0),
                  star2(EnumStars.Saturn, starsAngle.Saturn, 64,
                      offsetWidthTimes: 0),

                  star2(EnumStars.Luo, starsAngle.southNode, 64,
                      offsetWidthTimes: 0),
                  star2(EnumStars.Ji, starsAngle.northNode, 64,
                      offsetWidthTimes: 0),

                  // 月孛
                  star2(EnumStars.Bei, starsAngle.lilith, 64,
                      offsetWidthTimes: 0),
                  star2(EnumStars.Qi, starsAngle.qi, 64, offsetWidthTimes: 0),

                  // star2("新",0,3)
                  buildCenterContainer()
                ],
              ),
            ],
          )),
    );
  }

  Widget buildCenterContainer() {
    return Container(
        width: 172,
        height: 172,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.1),
          borderRadius: BorderRadius.circular(172),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "立命",
                      style: TextStyle(fontSize: 12, height: 1.2),
                    ),
                    // SizedBox(width: 4,),
                    Text(
                      "昴日鸡",
                      style: TextStyle(fontSize: 14, height: 1.2),
                    ),
                    Text(
                      "六度",
                      style: TextStyle(fontSize: 12, height: 1.2),
                    ),
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "运",
                      style: TextStyle(fontSize: 10),
                    ),
                    Text("癸", style: TextStyle(fontSize: 16)),
                    Text("卯", style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(
                  width: 6,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("流", style: TextStyle(fontSize: 10)),
                    Text("辛", style: TextStyle(fontSize: 16)),
                    Text("丑", style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(
                  width: 6,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "年",
                      style: TextStyle(fontSize: 10),
                    ),
                    Text("癸", style: TextStyle(fontSize: 16)),
                    Text("卯", style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(
                  width: 6,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("月", style: TextStyle(fontSize: 10)),
                    Text("辛", style: TextStyle(fontSize: 16)),
                    Text("丑", style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(
                  width: 6,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "日",
                      style: TextStyle(fontSize: 10),
                    ),
                    Text("癸", style: TextStyle(fontSize: 16)),
                    Text("卯", style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(
                  width: 6,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("时", style: TextStyle(fontSize: 10)),
                    Text("辛", style: TextStyle(fontSize: 16)),
                    Text("丑", style: TextStyle(fontSize: 16)),
                  ],
                )
              ],
            ),
            Column(
              children: [Text("ok3"), Text("ok3")],
            ),
          ],
        ));
  }

  StarsAngle calculateSevenZhengAngle(ObserverPosition observerPosition) {
    double roundHelper(double number) {
      // 保留小数点后两位，四舍五入
      num factor = pow(10, 2);
      return ((number * factor).round() / factor);
    }

    double ziQi() {
      // # moria 软件中
      // # 2013-04-09 02:57 am 紫炁在戌0°
      // # 2013-04-10 02:57 am 紫炁在戌0°02′07″处
      // # 每24小时运行 02′07″ 或 0.0352° 度 28年运行一周，一年以365.2422天为准
      // # 紫炁的运行规律为 一日行三分五十七秒，一宫住二十八个月，二十八年行一周天，一日行3分57秒（百进制）
      // # 设置基准时间为上海时区
      tz.TZDateTime baseShangHaiTime =
          tz.TZDateTime(tz.getLocation('Asia/Shanghai'), 2013, 4, 9, 2, 58);
      // BASE_SHANG_HAI_TIME.toUtc();

      const angleForEachMinutes = 0.0352 / (24 * 60);
      final localTime = tz.TZDateTime(
          tz.getLocation(observerPosition.timezone),
          observerPosition.birthday.year,
          observerPosition.birthday.month,
          observerPosition.birthday.day,
          observerPosition.birthday.hour,
          observerPosition.birthday.minute);
      final targetTime =
          tz.TZDateTime.from(localTime, tz.getLocation('Asia/Shanghai'));

      if (targetTime.isAtSameMomentAs(baseShangHaiTime)) {
        return 0;
      }

      var diffInMinutes = targetTime.isBefore(baseShangHaiTime)
          ? baseShangHaiTime.difference(targetTime)
          : targetTime.difference(baseShangHaiTime);
      // minutes_difference = delta.total_seconds() // 60

      return diffInMinutes.inMinutes * angleForEachMinutes;
    }

    // 设置观察者的位置
    Sweph.swe_set_topo(observerPosition.longitude, observerPosition.latitude,
        observerPosition.altitude);
    DateTime utcTime = observerPosition.birthdayUtcTime;

    final double julianDay = Sweph.swe_julday(
        utcTime.year,
        utcTime.month,
        utcTime.day,
        utcTime.hour + utcTime.minute / 60,
        CalendarType.SE_GREG_CAL);

    var lunar =
        Sweph.swe_calc(julianDay, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
    var sun =
        Sweph.swe_calc(julianDay, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);

    var Venus = Sweph.swe_calc(julianDay, HeavenlyBody.SE_VENUS,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var Jupiter = Sweph.swe_calc(julianDay, HeavenlyBody.SE_JUPITER,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var water = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MERCURY,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var Mars = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MARS,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var Saturn = Sweph.swe_calc(julianDay, HeavenlyBody.SE_SATURN,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    print(Venus.speedInLongitude);

    // 计算北交点的黄道角度
    var northNode = Sweph.swe_calc(
        julianDay, HeavenlyBody.SE_MEAN_NODE, SwephFlag.SEFLG_SWIEPH);
    double northNodeAngle = northNode.longitude;
    // 计算南交点的黄道角度
    double southNodeAngle = (northNodeAngle + 180) % 360;
    var lilith = Sweph.swe_calc(
        julianDay, HeavenlyBody.SE_MEAN_APOG, SwephFlag.SEFLG_SWIEPH);

    return StarsAngle(
        moon: roundHelper(lunar.longitude),
        sun: roundHelper(sun.longitude),
        Venus: roundHelper(Venus.longitude),
        VenusSpeed: roundHelper(Venus.speedInLongitude),
        Jupiter: roundHelper(Jupiter.longitude),
        JupiterSpeed: roundHelper(Jupiter.speedInLongitude),
        water: roundHelper(water.longitude),
        waterSpeed: roundHelper(water.speedInLongitude),
        Mars: roundHelper(Mars.longitude),
        MarsSpeed: roundHelper(Mars.speedInLongitude),
        Saturn: roundHelper(Saturn.longitude),
        SaturnSpeed: roundHelper(Saturn.speedInLongitude),
        northNode: roundHelper(northNodeAngle),
        southNode: roundHelper(southNodeAngle),
        lilith: roundHelper(lilith.longitude),
        qi: roundHelper(ziQi()));
  }

  double getMoonAngle(ObserverPosition observerPosition) {
    // 设置观察者的位置
    Sweph.swe_set_topo(observerPosition.longitude, observerPosition.latitude,
        observerPosition.altitude);
    DateTime utcTime = observerPosition.birthdayUtcTime;

    double julianDay = Sweph.swe_julday(
        utcTime.year,
        utcTime.month,
        utcTime.day,
        utcTime.hour + utcTime.minute / 60,
        CalendarType.SE_GREG_CAL);

    var moon =
        Sweph.swe_calc(julianDay, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
    double number = moon.longitude;
    num factor = pow(10, 2);
    double roundedNumber = ((number * factor).round() / factor);
    return roundedNumber;
  }

  getMoonPosition() {
    DateTime now = DateTime(2024, 10, 13, 16, 45).toUtc();
    double jd =
        Sweph.swe_julday(2024, 10, 13, 16 + 45 / 60, CalendarType.SE_GREG_CAL);
    double jd2 = Sweph.swe_julday(now.year, now.month, now.day,
        now.hour + now.minute / 60, CalendarType.SE_GREG_CAL);
    final pos2 =
        Sweph.swe_calc_ut(jd2, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_ICRS);
    print("$now - ${pos2.longitude.toStringAsFixed(3)}");

    // final jd = Sweph.swe_julday(2024, 10, 13, (2 + 52 / 60), CalendarType.SE_GREG_CAL);
    final pos =
        Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
    return 'lat=${pos.latitude.toStringAsFixed(3)} lon=${pos.longitude.toStringAsFixed(3)}';
  }

  Widget drawUIStarBody(UIStarModel uiStarBody) {
    Color backgroundColor = QiZhengSiYuUIConstantResources.starsColorMap[star]!;

    // print("-------- $oWidth");
    return Transform.rotate(
      // angle: (120 * pi) / 180,
      angle: 0,
      child: Transform.rotate(
          angle: (120 - uiStarBody.angle) * pi / 180,
          child: Container(
            width: 32 + 64,
            height: 610,
            alignment: Alignment.topCenter,
            child: ElTooltip(
              showModal: false,
              showChildAboveOverlay: false,
              content: const Text("tooltip"),
              child: FutureBuilder(
                future: loadImage(),
                builder: (
                  ctx,
                  asyncSnap,
                ) {
                  // if (asyncSnap.hasData && asyncSnap.data != null){
                  //   return CustomPaint(
                  //     size: Size(32, 650-600-4),
                  //     painter: PlanetPainter(
                  //         starName:starName,
                  //         angle:((360-degree) * pi) / 180,
                  //         offsetTimes: offsetWidthTimes,
                  //         image: asyncSnap.data!
                  //     ),
                  //   );
                  // }
                  // if (asyncSnap.hasError){
                  //   print(asyncSnap.error);
                  // }
                  return CustomPaint(
                    size: const Size(32, 650 - 600 - 4),
                    painter: MyCirclePainter(
                        starName: uiStarBody.star.singleName,
                        // angle:((360-degree) * pi) / 180,
                        angle: ((360 - (120 - uiStarBody.angle)) * pi) / 180,
                        offsetTimes: 0,
                        backgroundColor: backgroundColor),
                  );
                },
              ),
            ),
          )),
    );
  }

  Widget star2(EnumStars star, double degree, double offsetWidth,
      {int offsetWidthTimes = 0}) {
    Color backgroundColor = QiZhengSiYuUIConstantResources.starsColorMap[star]!;
    double oWidth = offsetWidth;
    if (offsetWidthTimes != 0) {
      if (offsetWidthTimes < 0) {
        int owt = offsetWidthTimes * -1;
        oWidth = offsetWidth + offsetWidth * (owt - 1) / 2;
      } else {
        oWidth = offsetWidth + offsetWidth * (offsetWidthTimes - 1) / 2;
      }
    }
    // print("-------- $oWidth");
    return Transform.rotate(
      // angle: (120 * pi) / 180,
      angle: 0,
      child: Transform.rotate(
          angle: (120 - degree) * pi / 180,
          child: Container(
            width: 32 + oWidth,
            // height: 560,
            height: 610,
            // color: Colors.blue.withOpacity(.1),
            alignment: Alignment.topCenter,
            child: ElTooltip(
              showModal: false,
              showChildAboveOverlay: false,
              content: const Text("tooltip"),
              child: FutureBuilder(
                future: loadImage(),
                builder: (
                  ctx,
                  asyncSnap,
                ) {
                  // if (asyncSnap.hasData && asyncSnap.data != null){
                  //   return CustomPaint(
                  //     size: Size(32, 650-600-4),
                  //     painter: PlanetPainter(
                  //         starName:starName,
                  //         angle:((360-degree) * pi) / 180,
                  //         offsetTimes: offsetWidthTimes,
                  //         image: asyncSnap.data!
                  //     ),
                  //   );
                  // }
                  // if (asyncSnap.hasError){
                  //   print(asyncSnap.error);
                  // }
                  return CustomPaint(
                    size: const Size(32, 650 - 600 - 4),
                    painter: MyCirclePainter(
                        starName: star.singleName,
                        // angle:((360-degree) * pi) / 180,
                        angle: ((360 - (120 - degree)) * pi) / 180,
                        offsetTimes: offsetWidthTimes,
                        backgroundColor: backgroundColor),
                  );
                },
              ),
            ),
          )),
    );
  }

  Future<ui.Image> loadImage() async {
    var data = await rootBundle.load(
        'assets/planets/mars-bubbles-50.png'); // Replace with your image path
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: 40, targetWidth: 42);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Widget star(String starName, double degree) {
    return Transform.rotate(
        angle: (degree * pi) / 180,
        child: Container(
          width: 32,
          // height: 560,
          height: 650,
          color: Colors.blue.withOpacity(.1),
          padding: const EdgeInsets.only(top: 8),
          alignment: Alignment.topCenter,
          child: Transform.rotate(
            angle: ((360 - degree) * pi) / 180,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black87.withOpacity(.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Text(
                starName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.normal, height: 1),
              ),
            ),
          ),
        ));
  }

  // 二十八星宿 刻度环
  Widget starXiuRing(double size, double ringWidth) {
    double outerRadius = size / 2;
    return Container(
        width: size, //
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(.4), width: 1),
          color: Colors.black.withOpacity(.1),
          borderRadius: BorderRadius.circular(outerRadius),
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: StarXiuRingPainter(
            outerSize: size,
            innerSize: size - ringWidth,
            mapper: QiZhengSiYuConstantResources
                .ZodiacTropicalModernStarsInnSystemMapper,
            sevenZhengColorMapper: QiZhengSiYuUIConstantResources.zhengColorMap,
          ),
        ));
  }

  Widget rulingRing(double size, double ringWidth) {
    double outerRadius = size / 2;
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
              width: size, //
              height: size,
              alignment: Alignment.center,
              child: CustomPaint(
                size: Size(size, size),
                painter: IndicatorScalePainter(
                    ringWidth: ringWidth, tickLength: 7, indicatorAngle: 45.1),
              )),
          Container(
              width: size, //
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.grey.withOpacity(.4), width: 1),
                color: Colors.black.withOpacity(.1),
                borderRadius: BorderRadius.circular(outerRadius),
              ),
              child: CustomPaint(
                size: Size(size, size),
                painter: StarXiuRingPainter(
                  outerSize: size,
                  innerSize: size - ringWidth,
                  mapper: QiZhengSiYuConstantResources
                      .ZodiacTropicalModernStarsInnSystemMapper,
                  sevenZhengColorMapper:
                      QiZhengSiYuUIConstantResources.zhengColorMap,
                ),
              )),
          // Container(
          //   width: size, //
          //   height: size,
          //   alignment: Alignment.center,
          //   decoration: BoxDecoration(
          //     border: Border.all(color: Colors.grey.withOpacity(.4),width: 1),
          //     color: Colors.black.withOpacity(.1),
          //     borderRadius: BorderRadius.circular(outerRadius),
          //   ),
          //   child: CustomPaint(
          //     size: Size(size, size),
          //     painter: RingScalePainter(
          //       ringWidth: ringWidth,
          //       tickLength: 5,
          //       longTickLength: 10,
          //       longTickAngles: <double>[
          //         0,
          //         30,
          //         60,
          //         90,
          //         120,
          //         150,
          //         180,
          //         210,
          //         240,
          //         270,
          //         300,
          //         330,
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // 绘制星宿环
  Widget constellationRing(double size, double ringWidth) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: size, //
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(.4), width: 1),
          // color: Colors.black.withOpacity(.1),
          borderRadius: BorderRadius.circular(270),
        ),
        child: Transform.rotate(
          // angle: 0,
          // 逆时针旋转80°
          angle: 6 * pi / 180,
          // angle: 0,
          // origin: Offset.zero,
          // origin: Offset(245,245),
          child: CustomPaint(
            size: Size(size, size),
            painter: TwentyEightStarsCircle(
              innerRadius: 210,
              outerRadius: 240,
              innerPadding: 4,
              outerPadding: 2,
              isReverseText: true,
              isReverseOrderSequence: false,
              textStyle: const TextStyle(
                  color: Colors.black, fontSize: 18, height: 1.2),
              twentyEightStarsList: <Tuple5<int, String, String, Color, num>>[
                Tuple5(
                    1, "角", "角木蛟", const Color(0xff006400).withOpacity(.2), 11),
                Tuple5(
                    1, "亢", "亢金龙", const Color(0xffFFD166).withOpacity(.2), 11),
                Tuple5(
                    1, "氐", "氐土貉", const Color(0xffFFD700).withOpacity(.2), 18),
                Tuple5(
                    1, "房", "房日兔", const Color(0xffFFD166).withOpacity(.2), 5),
                Tuple5(
                    1, "心", "心月狐", const Color(0xfffffef8).withOpacity(.2), 8),
                Tuple5(
                    1, "尾", "尾火虎", const Color(0xffE34234).withOpacity(.2), 15),
                Tuple5(
                    1, "箕", "箕水豹", const Color(0xff93b5cf).withOpacity(.2), 9),
                Tuple5(
                    4, "斗", "斗木獬", const Color(0xff7CFC00).withOpacity(.2), 24),
                Tuple5(
                    4, "牛", "牛金牛", const Color(0xffFF8C00).withOpacity(.2), 8),
                Tuple5(
                    4, "女", "女土蝠", const Color(0xff6F4E37).withOpacity(.2), 11),
                Tuple5(
                    4, "虚", "虚日鼠", const Color(0xffFF8C00).withOpacity(.2), 10),
                Tuple5(
                    4, "危", "危月燕", const Color(0xffEEE9E6).withOpacity(.2), 20),
                Tuple5(
                    4, "室", "室火猪", const Color(0xff964B00).withOpacity(.2), 16),
                Tuple5(
                    4, "壁", "壁水㺄", const Color(0xff2775b6).withOpacity(.2), 13),
                Tuple5(
                    3, "奎", "奎木狼", const Color(0xff556B2F).withOpacity(.2), 11),
                Tuple5(
                    3, "娄", "娄金狗", const Color(0xffD2B48C).withOpacity(.2), 13),
                Tuple5(
                    3, "胃", "胃土雉", const Color(0xffCD853F).withOpacity(.2), 12),
                Tuple5(
                    3, "昴", "昴日鸡", const Color(0xffFFC125).withOpacity(.2), 9),
                Tuple5(
                    3, "毕", "毕月乌", const Color(0xffC0C0C0).withOpacity(.2), 15),
                Tuple5(
                    3, "觜", "觜火猴", const Color(0xffDF302E).withOpacity(.2), 1),
                Tuple5(
                    3, "参", "参水猿", const Color(0xff1772b4).withOpacity(.2), 11),
                Tuple5(
                    2, "井", "井木犴", const Color(0xff306754).withOpacity(.2), 31),
                Tuple5(
                    2, "鬼", "鬼金羊", const Color(0xffFFC125).withOpacity(.2), 5),
                Tuple5(
                    2, "柳", "柳土獐", const Color(0xff8B795E).withOpacity(.2), 17),
                Tuple5(
                    2, "星", "星日马", const Color(0xffD2B48C).withOpacity(.2), 8),
                Tuple5(
                    2, "张", "张月鹿", const Color(0xffFDF5E6).withOpacity(.2), 18),
                Tuple5(
                    2, "翼", "翼火蛇", const Color(0xffFF0000).withOpacity(.2), 17),
                Tuple5(
                    2, "轸", "轸水蚓", const Color(0xff346c9c).withOpacity(.2), 13),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget drawRing(double size, double ringWidth, List<String> contentList,
      TextStyle textStyle,
      {double innerPadding = 2}) {
    double outerRadius = size / 2;
    double innerRadius = outerRadius - ringWidth;
    return Container(
        alignment: Alignment.center,
        height: size,
        width: size,
        decoration: BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(size),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Transform.rotate(
          angle: 105 * pi / 180,
          origin: Offset.zero,
          child: CustomPaint(
            size: Size(size, size),
            painter: CircleRingPainter(
              innerRadius: innerRadius,
              outerRadius: outerRadius,
              textList: contentList,
              isAntiClockwise: true,
              innerPadding: innerPadding,
              isReverseText: false,
              isHorizontalText: true,
              textStyle: textStyle.copyWith(height: 1.2),
            ),
          ),
        ));
  }

  Widget drawRingWithTextList(
      double size, double ringWidth, List<Text> contentList,
      {double innerPadding = 2}) {
    double outerRadius = size / 2;
    double innerRadius = outerRadius - ringWidth;
    return Container(
        alignment: Alignment.center,
        height: size,
        width: size,
        decoration: BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(size),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Transform.rotate(
          angle: 105 * pi / 180,
          // angle: 0,
          origin: Offset.zero,
          child: CustomPaint(
            size: Size(size, size),
            painter: TextCircleRingPainter(
              innerRadius: innerRadius,
              outerRadius: outerRadius,
              textList: contentList,
              isAntiClockwise: true,
              innerPadding: innerPadding,
              isReverseText: false,
              isHorizontalText: true,
            ),
          ),
        ));
  }
}

// 当前为赤道
class TwentyEightStarsCircle extends CustomPainter {
  static const int TOTAL = 28;
  final double innerRadius;
  final double outerRadius;
  // tuple5: 东南西北, 星宿名,星宿全称, 颜色, 角度
  List<Tuple5<int, String, String, Color, num>> twentyEightStarsList;
  late TextStyle textStyle;
  bool isReverseText = false;
  bool isReverseOrderSequence = false;

  double innerPadding = 12;
  double outerPadding = 12;

  TwentyEightStarsCircle({
    required this.innerRadius,
    required this.outerRadius,
    required this.twentyEightStarsList,
    this.isReverseText = true,
    this.isReverseOrderSequence = false,
    this.innerPadding = 12,
    this.outerPadding = 12,
    this.textStyle =
        const TextStyle(color: Colors.black, fontSize: 18, height: 1.2),
  });

  void debugPaint(Canvas canvas, Size size, Offset center) {
    // canvas.translate(center.dx, center.dy);
    // 给canvas绘制灰色透明度为0.1的背景
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width / 2, backgroundPaint);

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

    canvas.translate(center.dx, center.dy);
    // canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 4);

    // final res = sweepAngleDegree *0.5 * math.pi / 180;
    // final double startAngle = math.pi / 2 - res;
    // final double sweepAngle = sweepAngleDegree * math.pi / 180;
    const double startAngle = 0;
    final fanRingWidth = outerRadius - innerRadius;

    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = fanRingWidth;

    // canvas.translate(center.dx, center.dy);
    // 计算每个扇环的中心角度
    // double angle = startAngle;
    double arcDrawCircleRadius = innerRadius + (fanRingWidth * 0.5);
    // double textRotationAngle =startAngle + sweepAngle / 2;
    // double textRotationAngle =startAngle;

    // 12点方向为起始点
    canvas.rotate(pi - pi / 4);
    // 9点方向为起始点 -- not work
    // canvas.rotate(pi/4);
    // 6点方向为起始点 -- not work
    // canvas.rotate(-pi/4);
    // 3点方向为起始点 -- not work
    // canvas.rotate(pi + pi/4);

    double angleCounter = startAngle;
    for (int i = 0; i < TOTAL; i++) {
      double sweepAngle = -twentyEightStarsList[i].item5 * pi / 180;
      // double sweepAngle = 0.18954444444444445;
      // 绘制扇环
      Path path = Path()
        ..addArc(
          Rect.fromCircle(center: Offset.zero, radius: arcDrawCircleRadius),
          angleCounter,
          sweepAngle,
        );
      // canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: arcDrawCircleRadius), startAngle, sweepAngle, false, paint);
      paint.color = twentyEightStarsList[i].item4;
      canvas.drawPath(path, paint);
      angleCounter += sweepAngle;
    }
    double prevAngle = 0;
    canvas.rotate(pi + pi / 2);

    double radi = pi / 360;
    double offsetRadi = 5 * radi;

    for (int i = 0; i < TOTAL; i++) {
      String text = twentyEightStarsList[i].item2;
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
      // angle to radian
      num currentAngle = twentyEightStarsList[i].item5;
      double angle = prevAngle - currentAngle * radi + offsetRadi;
      canvas.rotate(angle);
      prevAngle = -(currentAngle * radi + offsetRadi);
      textPainter.paint(canvas, Offset(0, innerRadius + innerPadding));
    }
  }

  void paintSingleChar(Canvas canvas, Size size, String text, Offset center,
      double rotationAngle, double yOffset) {
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
    Offset offset = isReverseText
        ? Offset(
            -textPainter.width * 0.5,
            -innerRadius -
                innerPadding -
                textPainter.height +
                textPainter.height * .1,
          )
        : Offset(
            -textPainter.width * 0.5,
            innerRadius + innerPadding,
          );
    double rotateAngle = isReverseText ? pi : 0.0;
    canvas.rotate(rotateAngle);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}

class IndicatorScalePainter extends CustomPainter {
  final double ringWidth;
  final double tickLength;
  final double indicatorAngle;

  IndicatorScalePainter({
    required this.indicatorAngle,
    required this.ringWidth,
    required this.tickLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = size.width / 2;
    final double innerRadius = outerRadius - ringWidth;
    // final Paint ringPaint = Paint()
    //   ..color = Colors.black
    //   ..strokeWidth = .5
    //   ..style = PaintingStyle.stroke;

    // Draw outer ring
    // canvas.drawCircle(Offset(centerX, centerY), outerRadius, ringPaint);

    // Draw inner ring
    // canvas.drawCircle(Offset(centerX, centerY), innerRadius, ringPaint);

    final Paint scalePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw regular tick marks
    final double angle = indicatorAngle * pi / 180;
    double length = tickLength;
    // if (i != 0){
    //   if (i % 10 == 0){
    //     length = tickLength *2;
    //   }else if (i % 5 == 0){
    //     length = tickLength + tickLength *0.5;
    //   }
    // }
    final double outerX = centerX + outerRadius * cos(angle);
    final double outerY = centerY + outerRadius * sin(angle);
    final double innerX = centerX + (outerRadius - length) * cos(angle);
    final double innerY = centerY + (outerRadius - length) * sin(angle);
    // Draw scale line near the outer ring
    canvas.drawLine(
      Offset(outerX, outerY),
      Offset(innerX, innerY),
      scalePaint,
    );

    final double innerTickStartX = centerX + innerRadius * cos(angle);
    final double innerTickStartY = centerY + innerRadius * sin(angle);
    final double innerTickEndX = centerX + (innerRadius + length) * cos(angle);
    final double innerTickEndY = centerY + (innerRadius + length) * sin(angle);

    // Draw scale line near the inner ring
    canvas.drawLine(
      Offset(innerTickStartX, innerTickStartY),
      Offset(innerTickEndX, innerTickEndY),
      scalePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  MyPainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PlanetPainter extends CustomPainter {
  double angle;
  final String starName;
  final ui.Image image;

  int offsetTimes;
  PlanetPainter(
      {required this.angle,
      required this.starName,
      required this.offsetTimes,
      required this.image});
  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width * .5 - (offsetTimes * size.width * .5);
    int subCenterHeightTimes = 0;
    if (offsetTimes != 0) {
      subCenterHeightTimes = offsetTimes < 0 ? offsetTimes * -1 : offsetTimes;
    }
    double centerY =
        size.height * .5 + (size.height * .05 * subCenterHeightTimes);
    Offset center = Offset(centerX, centerY);
    // const radius = 12.0; // Fixed radius

    // indicator line
    // draw a line from, left edge center to canves center
    // canvas.rotate(offsetDegree * pi/180);
    canvas.drawLine(center, Offset(size.width * .5, size.height),
        Paint()..color = Colors.red);
    canvas.translate(center.dx, center.dy);

    // canvas.drawLine(center, Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)), Paint()..color = Colors.red);

    // turning with 45 degree, turning center is center
    // canvas.translate(0, size.height / 2);
    // canvas.translate(size.width, size.height / 2);

    // canvas.rotate(pi / 6);
    // canvas.rotate((360-108) * pi / 180);

    // canvas.drawCircle(Offset.zero, radius, Paint()..color = Colors.green.withOpacity(.1));

    // canvas draw image from assets
    // ui.Image.asset("assets/planets/mars-bubbles-50.png")

    // draw a background block size as this canvas, color with Colors.black.whithOpactiy(.1)
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black.withOpacity(0.4));

    // canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size.width, height: size.height), Paint()..color = Colors.black87.withOpacity(.5));

    canvas.rotate(angle);
    // draw text content
    final textStyle = GoogleFonts.longCang(
        fontSize: 22.0,
        height: 1,
        color: const Color.fromRGBO(55, 53, 52, 1),
        fontWeight: FontWeight.w600,
        shadows: [
          BoxShadow(
            color: Colors.black38.withOpacity(.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1), // changes position of shadow
          )
        ]);
    var textPainter = TextPainter(
      text: TextSpan(
        text: starName,
        style: textStyle,
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    Offset textCenter = Offset(-textPainter.width / 2, -textPainter.height / 2);
    // canvas.drawImage(image, Offset(-textPainter.width * .75, -textPainter.height * .75), Paint());
    canvas.drawImage(image, const Offset(-20, -20), Paint());
    // 创建一个模糊效果的层
    // final layer = ui.ImageFilterLayer(
    //   imageFilter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    // );
    canvas.saveLayer(Offset.zero & size,
        Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0));
    canvas.restore();

    textPainter.paint(canvas, textCenter);

    // draw a red dot at center
    canvas.drawCircle(Offset.zero, 1, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class MyCirclePainter extends CustomPainter {
  double angle;
  final String starName;
  final Color backgroundColor;
  int offsetTimes;
  MyCirclePainter(
      {required this.angle,
      required this.starName,
      required this.offsetTimes,
      required this.backgroundColor});
  @override
  void paint(Canvas canvas, Size size) {
    // final center = Offset(size.width / 2, size.height / 2);
    // Offset center = toLeft != null?Offset((toLeft!) ?0:size.width, size.height * .5):Offset(size.width * .5, size.height * .5);
    // if (toLeft != null){
    //   offsetTimes = toLeft! ? 1: -1;
    // }else{
    //   offsetTimes = 0;
    // }
    // Offset center = Offset(size.width*.5-(offsetTimes*size.width*.5),size.height*.5);
    double centerX = size.width * .5 - (offsetTimes * size.width * .5);
    int subCenterHeightTimes = 0;
    if (offsetTimes != 0) {
      subCenterHeightTimes = offsetTimes < 0 ? offsetTimes * -1 : offsetTimes;
    }
    double centerY =
        size.height * .5 + (size.height * .05 * subCenterHeightTimes);
    if (subCenterHeightTimes >= 7) {
      centerY += size.height * .2;
    }
    if (subCenterHeightTimes >= 9) {
      centerY += size.height * .3;
    }
    Offset center = Offset(centerX, centerY);
    // print("$center $subCenterHeightTimes ${size.width*.5}");
    const radius = 16.0; // Fixed radius

    // indicator line
    // draw a line from, left edge center to canves center
    // canvas.rotate(offsetDegree * pi/180);
    // line's shadow
    canvas.drawLine(
        center,
        Offset(size.width * .5, size.height),
        Paint()
          ..color = Colors.black38.withOpacity(.1)
          ..strokeWidth = 3);
    canvas.drawLine(
        center,
        Offset(size.width * .5, size.height),
        Paint()
          ..color = backgroundColor
          ..strokeWidth = .5);
    // add shadow to drawLine

    canvas.translate(center.dx, center.dy);

    // canvas.drawLine(center, Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)), Paint()..color = Colors.red);

    // turning with 45 degree, turning center is center
    // canvas.translate(0, size.height / 2);
    // canvas.translate(size.width, size.height / 2);

    // canvas.rotate(pi / 6);
    // canvas.rotate((360-108) * pi / 180);

    canvas.drawCircle(
        Offset.zero, radius, Paint()..color = backgroundColor.withOpacity(.1));

    // canvas draw image from assets
    // ui.Image.asset("assets/planets/mars-bubbles-50.png")

    // draw a background block size as this canvas, color with Colors.black.whithOpactiy(.1)
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black.withOpacity(0.4));

    // canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size.width, height: size.height), Paint()..color = Colors.black87.withOpacity(.5));

    canvas.rotate(angle);
    // draw text content
    final textStyle = GoogleFonts.notoSans(
        fontSize: 20.0,
        height: 1,
        // color: Color.fromRGBO(55, 53, 52, 1),
        color: backgroundColor,
        fontWeight: FontWeight.normal,
        shadows: [
          BoxShadow(
            color: Colors.black38.withOpacity(.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1), // changes position of shadow
          )
        ]);
    var textPainter = TextPainter(
      text: TextSpan(
        text: starName,
        style: textStyle,
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2 + 1));

    // draw a red dot at center
    canvas.drawCircle(Offset.zero, 1, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
