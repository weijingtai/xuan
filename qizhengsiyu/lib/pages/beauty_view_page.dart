import 'dart:math';
import 'dart:ui' as ui;
import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:common/enums/enum_stars.dart';
import 'package:qizhengsiyu/models/eleven_stars_info.dart';
import 'package:qizhengsiyu/pages/circle_indicator_widget.dart';
import 'package:qizhengsiyu/pages/ui_star_model.dart';
import 'package:qizhengsiyu/painter/StarInn28RingPainter.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:qizhengsiyu/pages/qi_zheng_si_yu_viewmodel.dart';
import 'package:tuple/tuple.dart';

import 'package:common/painter/text_circle_ring_painter.dart';
import 'package:common/painter/circle_ring_printer.dart';
import '../enums/enum_twelve_gong.dart';
import '../models/panel_stars_info.dart';
import '../models/stars_angle.dart';
import '../models/observer_position.dart';
import '../painter/painters.dart';
import '../painter/star_body_ring_painter.dart';
import '../painter/star_xiu_ring_painter.dart';
import '../painter/twelve_zhi_gong_circle_ring_printer.dart';
import '../qi_zheng_si_yu_ui_constant_resources.dart';
import '../widgets/star_body.dart';

class QiZhengSiYuPanSizeDataModel {
  // default:

  // late final double centerSize = 172;
  // late final double diZhi12GongSize = 120;
  // late final double zodiac12GongSize = 41;
  // late final double starSeq12GongSize = 360;
  // late final double destiny12GongSize = 67;
  // late final double lifeStarRingSize = 16 * 8; // 564
  // late final double starXiu28RingSize = 96; // 660

  late final double centerSize;
  late final double diZhi12GongHeight;
  late final double zodiac12GongHeight;
  late final double starSeq12GongHeight;
  late final double destiny12GongHeight;
  late final double lifeStarRingHeight; // 564
  late final double starXiu28RingHeight; // 660
  late final double innerShenShaHeight;
  late final double outerShenShaHeight;

  double starBodyRadius;
  double get starBodySize => starBodyRadius * 2;
  late bool showFateLifeStarRing;

  late double diZhi12GongInner;
  late double diZhi12GongOuter;

  late double zodiac12GongSizeInner;
  late double zodiac12GongSizeOuter;

  late double starSeq12GongSizeInner;
  late double starSeq12GongSizeOuter;

  late double destiny12GongSizeInner;
  late double destiny12GongSizeOuter;

  late double innerShenShaSizeInner;
  late double innerShenShaSizeOuter;

  late double outerShenShaSizeInner;
  late double outerShenShaSizeOuter;

  // double starXiu28RingSizeOuter = 520 + 96; // 616
  // double starXiu28RingSizeInner = 520 + 96 - 80; // 616 - 80 = 536

  // double fateLifeStarOuterSize = 520 + 96 - 80;
  // double fateLifeStarTrackSize = 520 + 96 - 80 - 16*3;
  // double fateLifeStarInnerSize = 436;

  late double innerLifeStarRingOuterSize; //564
  late double innerLifeStarRingTrackSize;
  late double innerLifeStarRingInnerSize;

  late double starXiu28RingSizeOuter; // 660
  late double starXiu28RingSizeInner; // 616 - 80 = 536

  late double outerLifeStarRingInnerSize; // starXiu28RingSizeOuter
  late double outerLifeStarRingTrackSize;
  late double outerLifeStarRingOuterSize;

  QiZhengSiYuPanSizeDataModel({
    required this.starBodyRadius,
    required this.centerSize,
    required this.diZhi12GongHeight,
    required this.zodiac12GongHeight,
    required this.starSeq12GongHeight,
    required this.destiny12GongHeight,
    required this.lifeStarRingHeight,
    required this.starXiu28RingHeight,
    required this.showFateLifeStarRing,
    required this.innerShenShaHeight,
    required this.outerShenShaHeight,
  }) {
    diZhi12GongInner = centerSize;
    diZhi12GongOuter = centerSize + diZhi12GongHeight * 2;

    zodiac12GongSizeInner = diZhi12GongOuter;
    zodiac12GongSizeOuter = diZhi12GongOuter + zodiac12GongHeight * 2;

    starSeq12GongSizeInner = zodiac12GongSizeOuter;
    starSeq12GongSizeOuter = zodiac12GongSizeOuter + starSeq12GongHeight * 2;

    destiny12GongSizeInner = starSeq12GongSizeOuter;
    destiny12GongSizeOuter = starSeq12GongSizeOuter + destiny12GongHeight * 2;

    innerLifeStarRingInnerSize = destiny12GongSizeOuter;
    innerLifeStarRingTrackSize =
        innerLifeStarRingInnerSize + lifeStarRingHeight;
    innerLifeStarRingOuterSize =
        innerLifeStarRingInnerSize + lifeStarRingHeight * 2;

    starXiu28RingSizeInner = innerLifeStarRingOuterSize;
    starXiu28RingSizeOuter = starXiu28RingSizeInner + starXiu28RingHeight * 2;

    outerLifeStarRingInnerSize =
        starXiu28RingSizeOuter; // starXiu28RingSizeOuter
    outerLifeStarRingTrackSize = starXiu28RingSizeOuter + lifeStarRingHeight;
    outerLifeStarRingOuterSize =
        starXiu28RingSizeOuter + lifeStarRingHeight * 2;

    innerShenShaSizeInner = outerLifeStarRingOuterSize;
    innerShenShaSizeOuter = innerShenShaSizeInner + innerShenShaHeight * 2;

    outerShenShaSizeInner = innerShenShaSizeOuter;
    outerShenShaSizeOuter = outerShenShaSizeInner + outerShenShaHeight * 2;
  }
}

class BeautyViewPage extends StatefulWidget {
  const BeautyViewPage({super.key});

  @override
  State<BeautyViewPage> createState() => _BeautyViewPageState();
}

class _BeautyViewPageState extends State<BeautyViewPage>
    with TickerProviderStateMixin {
  static final Logger logger = Logger(
    output: ConsoleOutput(),
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      // Should each log print contain a timestamp
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
  static const List<String> destinyList = <String>[
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

  late QiZhengSiYuPanSizeDataModel panelSizeDataModel;

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

    panelSizeDataModel = QiZhengSiYuPanSizeDataModel(
        starBodyRadius: 16 + 4,
        centerSize: 172,
        diZhi12GongHeight: 60,
        zodiac12GongHeight: 42,
        starSeq12GongHeight: 0,
        destiny12GongHeight: 64,
        lifeStarRingHeight: 16 * 4, // 564
        starXiu28RingHeight: 48, // 660
        innerShenShaHeight: 128,
        outerShenShaHeight: 128,
        showFateLifeStarRing: true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
    showTaiJiDianButtonNotifier.dispose();
    _destiny12GongListNotifier.dispose();
    _selectedTaiJiDestiny12GongListNotifier.dispose();
    super.dispose();
  }

  bool isFirst = true;
  ValueNotifier<bool> showTaiJiDianButtonNotifier = ValueNotifier(false);
  ValueNotifier<bool> showStarHuaJiInfoNotifier = ValueNotifier(false);

  double get centerSize => panelSizeDataModel.centerSize;
  double get diZhi12GongInner => panelSizeDataModel.diZhi12GongInner;
  double get diZhi12GongOuter => panelSizeDataModel.diZhi12GongOuter;
  double get zodiac12GongSizeInner => panelSizeDataModel.zodiac12GongSizeInner;
  double get zodiac12GongSizeOuter => panelSizeDataModel.zodiac12GongSizeOuter;
  double get starSeq12GongSizeInner =>
      panelSizeDataModel.starSeq12GongSizeInner;
  double get starSeq12GongSizeOuter =>
      panelSizeDataModel.starSeq12GongSizeOuter;
  double get destiny12GongSizeInner =>
      panelSizeDataModel.destiny12GongSizeInner;
  double get destiny12GongSizeOuter =>
      panelSizeDataModel.destiny12GongSizeOuter;
  double get fateLifeStarOuterSize =>
      panelSizeDataModel.innerLifeStarRingOuterSize; //564
  double get fateLifeStarTrackSize =>
      panelSizeDataModel.innerLifeStarRingTrackSize;
  double get fateLifeStarInnerSize =>
      panelSizeDataModel.innerLifeStarRingInnerSize;
  double get starXiu28RingSizeOuter =>
      panelSizeDataModel.starXiu28RingSizeOuter; // 660
  double get starXiu28RingSizeInner =>
      panelSizeDataModel.starXiu28RingSizeInner; // 616 - 80 = 536
  double get basicLifeStarRingInnerSize =>
      panelSizeDataModel.outerLifeStarRingInnerSize; // starXiu28RingSizeOuter
  double get basicLifeStarBodyTrackSize =>
      panelSizeDataModel.outerLifeStarRingTrackSize;
  double get basicLifeStarRingOuterSize =>
      panelSizeDataModel.outerLifeStarRingOuterSize;

  /// _destiny12GongListNotifier list#index 对应地支方位 0-子 1-亥 ...
  final ValueNotifier<List<String>> _destiny12GongListNotifier = ValueNotifier([
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
  ]);

  /// _selectedTaiJiDestiny12GongListNotifier list#index 对应地支方位 0-子 1-亥
  final ValueNotifier<List<String>?> _selectedTaiJiDestiny12GongListNotifier =
      ValueNotifier(null);
  TextStyle destinyTextStyle = GoogleFonts.maShanZheng(
      color: Colors.black87,
      fontSize: 28,
      fontWeight: FontWeight.normal,
      height: 1.0,
      shadows: [
        BoxShadow(
          color: Colors.black45.withOpacity(.2),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(1, 1), // changes position of shadow
        )
      ]);

  @override
  Widget build(BuildContext context) {
    // late final double centerSize = 171;
    // late final double diZhi11GongSize = 120;
    // late final double zodiac11GongSize = 41;
    // late final double starSeq11GongSize = 360;
    // late final double destiny11GongSize = 67;
    // late final double lifeStarRingSize = 15 * 8; // 564
    // late final double starXiu27RingSize = 96; // 660

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double minSize = height > width ? width : height;
    // double panelMaxSize = minSize * .8;
    double panelMaxSize = 1700;
    logger.d("盘最大Size为$panelMaxSize");
    // 星体半径 16
    double starBodyRadius = panelSizeDataModel.starBodyRadius;
    // 本命盘星轨内环
    double starInnRangeMiddleSize = 520 + 96;
    // 本命盘星轨外环
    double basicLifeStarCenterCircleSize =
        starInnRangeMiddleSize + starBodyRadius * 2 + 12;

    // double fateLifeStarCenterCircleSize= starInnRangeMiddleSize+starBodyRadius*2+12;

    // 星轨外环，当前 80 为 星宿ring的 width*2
    Provider.of<QiZhengSiYuViewModel>(context).calculateBasicStarsSafetyAngle(
        starBodyRadius, starInnRangeMiddleSize, basicLifeStarCenterCircleSize);
    Provider.of<QiZhengSiYuViewModel>(context).calculateFateStarsSafetyAngle(
        starBodyRadius, destiny12GongSizeOuter, fateLifeStarOuterSize);

    if (isFirst) {
      Future.delayed(const Duration(seconds: 3), () {
        isFirst = false;
        calculatePanel();
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              child: ValueListenableBuilder(
                valueListenable: showStarHuaJiInfoNotifier,
                builder: (ctx, show, _) {
                  return Switch(
                      value: show,
                      onChanged: (n) {
                        showStarHuaJiInfoNotifier.value = n;
                      });
                },
              ),
            ),
            Container(
                width: panelMaxSize,
                height: panelMaxSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Consumer<QiZhengSiYuViewModel>(
                        builder: (context, viewModel, child) {
                          if (viewModel.basicLifeStarsAngle == null) {
                            return child!;
                          }
                          return Transform.rotate(
                            angle: 30 * pi / 180,
                            child: panel(viewModel.uiBasicLifeStars,
                                viewModel.uiFateLifeStars, starBodyRadius),
                          );
                        },
                        child: const CircularProgressIndicator(),
                      ),
                      const Expanded(child: SizedBox()),
                    ])),
          ],
        ),
      ),
    );
  }

  void calculatePanel() {
    // 设定观察者的经纬度和高度（例如：上海）
    double latitude = 31.2304; // 纬度
    double longitude = 121.4737; // 经度
    double altitude = 0; // 高度（米）
    var observerPosition = ObserverPosition(
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        fateLifeDateTime: DateTime(2024, 10, 13, 16, 45),
        birthday: DateTime(1982, 10, 25, 02, 30),
        timezone: 'Asia/Shanghai');
    Provider.of<QiZhengSiYuViewModel>(context, listen: false)
        .calculate(observerPosition);
  }

  Widget center() {
    return Container(
        width: centerSize,
        height: centerSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // color: Colors.black.withOpacity(.1),
          borderRadius: BorderRadius.circular(centerSize),
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

  Widget panel(
    List<UIStarModel> uiBasicStarList,
    List<UIStarModel> uiFateStarList,
    // StarsAngle basicLifeStarsAngle,
    // StarsAngle? fateLifeStarsAngle,
    double starBodyRadius,
    // double starInnRangeMiddleSize,
    // double fateLifeStarTrackOuterSize,
    // double basicLifeStarCenterCircleSize
  ) {
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
        fontSize: 16,
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
    // TextStyle destinyTextStyle = TextStyle(color: Colors.black, fontSize: 20,fontFamily: 'KaiTi',fontWeight: FontWeight.w400);

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

    double rotating = 0;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          height: diZhi12GongOuter,
          width: diZhi12GongOuter,
          decoration: BoxDecoration(
            // color: Colors.red.withOpacity(.1),
            borderRadius: BorderRadius.circular(diZhi12GongOuter),
            // border: Border.all(color: Colors.black,width: 1),
          ),
          child: Transform.rotate(
            angle: 75 * pi / 180,
            origin: Offset.zero,
            child: CustomPaint(
                size: Size(diZhi12GongOuter, diZhi12GongOuter),
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
                  starColorMapper: QiZhengSiYuUIConstantResources.zhengColorMap,
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
        draw12GongRingText(
            zodiac12GongSizeInner, zodiac12GongSizeOuter, zodiacTextList,
            innerPadding: 2),
        // 星次十二宫
        // drawRingWithTextList(starSeq12GongSizeOuter, 18, starSeqTextList),
        // 命理十二宫
        draw12GongRing(
            destiny12GongSizeInner, destiny12GongSizeOuter, destinySeqTextList,
            innerPadding: 2),
        // drawRingWithTextList(destiny12GongSizeOuter, 33, destinySeqTextList,innerPadding: 2),
        Transform.rotate(
          angle: rotating * pi / 180,
          child: starXiuRing(starXiu28RingSizeOuter, 40),
        ),

        draw12GongRingGrid(
          panelSizeDataModel.innerShenShaSizeInner,
          panelSizeDataModel.innerShenShaSizeOuter,
        ),
        draw12GongRingGrid(
          panelSizeDataModel.outerShenShaSizeInner,
          panelSizeDataModel.outerShenShaSizeOuter,
        ),

        // 大限星轨
        Transform.rotate(
          angle: rotating * pi / 180,
          child: innerStarTrackRing(uiFateStarList),
        ),
        // 本命盘星轨
        Transform.rotate(
          angle: rotating * pi / 180,
          child: outerStarTrackRing(uiBasicStarList),
        ),

        Transform.rotate(
          angle: -(rotating - 90) * pi / 180,
          child: outerStarBodyRotating(uiBasicStarList),
        ),
        Transform.rotate(
          angle: -(rotating - 90) * pi / 180,
          child: innerStarBodyRotating(uiFateStarList),
        ),

        // 命理十二宫
        ValueListenableBuilder(
            valueListenable: _destiny12GongListNotifier,
            builder: (ctx, destiny12GongList, child) {
              // return drawDestiny12Gong(destiny12GongSizeInner,
              // destiny12GongSizeOuter - 40 * 2, destiny12GongList);
              return ValueListenableBuilder(
                  valueListenable: _selectedTaiJiDestiny12GongListNotifier,
                  builder: (ctx, selectedTaiJiDestiny12GongList, child) {
                    return destiny12Gong(
                        destiny12GongSizeInner,
                        destiny12GongSizeOuter,
                        destiny12GongList,
                        selectedTaiJiDestiny12GongList);
                  });
            }),
        Transform.rotate(
            angle: 120 * pi / 180, // 和命理十二宫一样为逆时针转，也从子宫位第一宫
            // angle: 0,
            child: innerShenShaRing(panelSizeDataModel.innerShenShaSizeInner,
                panelSizeDataModel.innerShenShaSizeOuter)),
        Transform.rotate(
          angle: -30 * pi / 180,
          child: center(),
        ),
      ],
    );
  }

  Widget innerShenShaRing(double innerSize, double outerSize) {
    TextStyle textStyle = const TextStyle(
      fontSize: 18,
      color: Colors.black87,
      height: 1.0,
      fontWeight: FontWeight.w400,
    );
    return Stack(
        alignment: Alignment.center,
        children: List.generate(
            6,
            (i) => innerShenShaEachGong(i, innerSize, outerSize, textStyle,
                i <= 3 && i >= 8 ? i * 30 : -i * 30)).toList());
  }

  Widget innerShenShaEachGong(int number, double innerSize, double outerSize,
      TextStyle textStyle, double basicRotatedAngle) {
    List<String> twelveZhangShengShenSha = [
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
      "养"
    ];
    if ([0, 1, 4, 5].contains(number)) {
      return Transform.rotate(
        angle: -(number * 30) * (pi / 180),
        // angle: 0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(
                7,
                (i) => eachShenShaVertical(
                    twelveZhangShengShenSha[i],
                    4.2 * i + 2.0,
                    basicRotatedAngle,
                    outerSize,
                    textStyle)).toList(growable: false),
            ...List.generate(
                6,
                (i) => eachShenShaVertical(
                    twelveZhangShengShenSha[i + 6],
                    4.2 * i + 2.0,
                    basicRotatedAngle,
                    outerSize - 120,
                    textStyle)).toList(growable: false),
          ],
        ),
      );
    } else {
      return Transform.rotate(
        // angle: -((number - 3) * 30) * (pi / 180),
        angle: -(150 - 30 * (number - 3)) * (pi / 180),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(
                7,
                (i) => eachShenShaHorizontal(
                    twelveZhangShengShenSha[i],
                    4.2 * i + 2.0,
                    basicRotatedAngle,
                    outerSize,
                    textStyle)).toList(growable: false),
            ...List.generate(
                6,
                (i) => eachShenShaHorizontal(
                    twelveZhangShengShenSha[i + 6],
                    4.2 * i + 2.0,
                    basicRotatedAngle,
                    outerSize - 120,
                    textStyle)).toList(growable: false),
          ],
        ),
      );
    }
  }

  Widget eachShenShaHorizontal(String shenShaName, double rotateOffset,
      double fontBasicRotated, double height, TextStyle textStyle) {
    List<String> nameList = shenShaName.split("");
    return Transform.rotate(
      angle: rotateOffset * (pi / 180),
      // angle: 0,
      child: Container(
        alignment: Alignment.centerRight,
        height: 32,
        width: height,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
            // TODO: DevHelper Color
            color: Colors.blue.withOpacity(.1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RotatedBox(
              quarterTurns: 0,
              child: Container(
                  height: 22,
                  width: 54,
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.teal),
                  alignment: Alignment.center,
                  child: Row(
                      mainAxisAlignment: nameList.length > -1
                          ? MainAxisAlignment.spaceAround
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: nameList
                          .map(
                            (singleName) => Transform.rotate(
                                angle: pi / 178,
                                child: Text(
                                  singleName,
                                  style: textStyle,
                                )),
                          )
                          .toList())),
            ),
            const Expanded(child: SizedBox()),
            RotatedBox(
              quarterTurns: 0,
              child: Container(
                  height: 24,
                  width: 56,
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.amber),
                  alignment: Alignment.center,
                  child: Row(
                      mainAxisAlignment: nameList.length > 1
                          ? MainAxisAlignment.spaceAround
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: nameList
                          .map(
                            (singleName) => Transform.rotate(
                                angle: pi / 180,
                                child: Text(
                                  singleName,
                                  style: textStyle,
                                )),
                          )
                          .toList())),
            ),
          ],
        ),
      ),
    );
  }

  Widget eachShenShaVertical(String shenShaName, double rotateOffset,
      double fontBasicRotated, double height, TextStyle textStyle) {
    List<String> nameList = shenShaName.split("");
    return Transform.rotate(
      angle: rotateOffset * (pi / 180),
      // angle: 0,
      child: Container(
        alignment: Alignment.center,
        height: height,
        width: 32,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
            // TODO: DevHelper Color
            color: Colors.blue.withOpacity(.1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RotatedBox(
              quarterTurns: 0,
              child: Container(
                  height: 56,
                  width: 24,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.teal),
                  alignment: Alignment.center,
                  child: Column(
                      mainAxisAlignment: nameList.length > 1
                          ? MainAxisAlignment.spaceAround
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: nameList
                          .map(
                            (singleName) => Transform.rotate(
                                angle: pi / 180,
                                child: Text(
                                  singleName,
                                  style: textStyle,
                                )),
                          )
                          .toList())),
            ),
            const Expanded(child: SizedBox()),
            RotatedBox(
              quarterTurns: 0,
              child: Container(
                  height: 56,
                  width: 24,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.cyan),
                  alignment: Alignment.center,
                  child: Column(
                      mainAxisAlignment: nameList.length > 1
                          ? MainAxisAlignment.spaceAround
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: nameList
                          .map(
                            (singleName) => Transform.rotate(
                                angle: pi / 180,
                                child: Text(
                                  singleName,
                                  style: textStyle,
                                )),
                          )
                          .toList())),
            ),
          ],
        ),
      ),
    );
  }

  Widget innerStarTrackRing(List<UIStarModel> uiFateStarList) {
    return Container(
      width: fateLifeStarOuterSize,
      height: fateLifeStarOuterSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(fateLifeStarOuterSize),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      child: CustomPaint(
        size: Size(fateLifeStarOuterSize, fateLifeStarOuterSize), // 设置画布大小
        painter: InnerLifeStarRangePainter(
          stars: uiFateStarList,
          starsColorMap: QiZhengSiYuUIConstantResources.starsColorMap,
          outerSize: fateLifeStarOuterSize,
          innerSize: fateLifeStarInnerSize,
          trackSize: fateLifeStarTrackSize,
          textStyle: GoogleFonts.notoSans(
              fontSize: 24.0,
              height: 1,
              // color: Color.fromRGBO(55, 53, 52, 1),
              color: Colors.black87,
              fontWeight: FontWeight.normal,
              shadows: [
                BoxShadow(
                  color: Colors.black38.withOpacity(.3),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(1, 1), // changes position of shadow
                )
              ]),
        ),
      ),
    );
  }

  Widget innerStarBodyRotating(List<UIStarModel> uiBasicLifeStarList) {
    return Container(
        width: fateLifeStarOuterSize,
        height: fateLifeStarOuterSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(fateLifeStarOuterSize),
          border: Border.all(color: Colors.black87, width: 1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: uiBasicLifeStarList
              .map((s) => outerEachStarBodyRotation(s))
              .toList(),
        ));
  }

  Widget outerStarBodyRotating(List<UIStarModel> uiBasicLifeStarList) {
    return Container(
        width: basicLifeStarRingOuterSize,
        height: basicLifeStarRingOuterSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(basicLifeStarRingOuterSize),
          border: Border.all(color: Colors.black87, width: 1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: uiBasicLifeStarList
              .map((s) => outerEachStarBodyRotation(s))
              .toList(),
        ));
  }

  Widget outerEachStarBodyRotation(UIStarModel star) {
    TextStyle starStatusStyle =
        const TextStyle(height: 1, color: Colors.black87, fontSize: 12);
    return AnimatedRotation(
      turns: -star.angle / 360,
      duration: const Duration(milliseconds: 400),
      child: Container(
        height: basicLifeStarRingOuterSize,
        width: panelSizeDataModel.starBodySize,
        padding: EdgeInsets.symmetric(
            vertical: (basicLifeStarRingOuterSize -
                    panelSizeDataModel.outerLifeStarRingTrackSize -
                    panelSizeDataModel.starBodySize) *
                .4),
        // decoration: BoxDecoration(
        // color: Colors.blue.withOpacity(.1),
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedRotation(
              duration: const Duration(milliseconds: 400),
              turns: (star.angle - 120) / 360,
              child: starBody(star),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget starBody(UIStarModel starBody) {
    TextStyle starBodyTextStyle = GoogleFonts.notoSans(
        fontSize: 24.0,
        height: 1,
        color: QiZhengSiYuUIConstantResources.starsColorMap[starBody.star]!,
        fontWeight: FontWeight.normal,
        shadows: [
          BoxShadow(
            color: Colors.black38.withOpacity(.3),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1), // changes position of shadow
          )
        ]);

    return StarBody(
      starSize: panelSizeDataModel.starBodySize,
      starBody: starBody,
      textStyle: starBodyTextStyle,
      allStarsShowNotifier: showStarHuaJiInfoNotifier,
    );
  }

  Widget outerStarTrackRing(List<UIStarModel> uiBasicLifeStarList) {
    return Container(
      width: basicLifeStarRingOuterSize,
      height: basicLifeStarRingOuterSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(basicLifeStarRingOuterSize),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      child: CustomPaint(
        // size: Size(basicLifeStarCenterCircleSize + starBodyRadius * 4, basicLifeStarCenterCircleSize + starBodyRadius * 4), // 设置画布大小
        size: Size(
            basicLifeStarRingOuterSize, basicLifeStarRingOuterSize), // 设置画布大小
        painter: OuterLifeStarRangePainter(
          stars: uiBasicLifeStarList,
          starsColorMap: QiZhengSiYuUIConstantResources.starsColorMap,
          outerSize: basicLifeStarRingOuterSize,
          innerSize: basicLifeStarRingInnerSize,
          trackSize: basicLifeStarBodyTrackSize,
          textStyle: GoogleFonts.notoSans(
              fontSize: 24.0,
              height: 1,
              // color: Color.fromRGBO(55, 53, 52, 1),
              color: Colors.black87,
              fontWeight: FontWeight.normal,
              shadows: [
                BoxShadow(
                  color: Colors.black38.withOpacity(.3),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(1, 1), // changes position of shadow
                )
              ]),
        ),
      ),
    );
  }

  UIStarsAngle correctBasicLifeAngle(
      StarsAngle starsAngle, double basicLifeStarCenterCircleSize) {
    double? uiSunAngle;
    double? uiMoonAngle;
    double? uiVenusAngle;
    double? uiJupiterAngle;
    double? uiMarsAngle;
    double? uiSaturnAngle;
    double? uiWaterAngle;
    double? uiSouthNodeAngle;
    double? uiNorthNodeAngle;
    double? uiBeiNodeAngle;
    double? uiQiAngle;
    double miniCollisionDistance = 48;
    double cosValue =
        (2 * basicLifeStarCenterCircleSize * basicLifeStarCenterCircleSize -
                miniCollisionDistance * miniCollisionDistance) /
            (2 * basicLifeStarCenterCircleSize * basicLifeStarCenterCircleSize);
    double acosValue = acos(cosValue);
    double minCollision = acosValue * (180 / pi); // 当小于等于这个值时 两个星体碰撞

    double diffDegree = 0;
    if (starsAngle.Venus < starsAngle.sun) {
      diffDegree = starsAngle.sun - starsAngle.Venus;
    } else {
      diffDegree = starsAngle.Venus - starsAngle.sun;
    }
    double needDegreeInTotal = minCollision - diffDegree;
    double needDegreeAddEach = needDegreeInTotal * .5;
    if (starsAngle.Venus < starsAngle.sun) {
      uiSunAngle = starsAngle.sun + needDegreeAddEach;
      uiVenusAngle = starsAngle.Venus - needDegreeAddEach;
    } else {
      uiSunAngle = starsAngle.sun - needDegreeAddEach;
      uiVenusAngle = starsAngle.Venus + needDegreeAddEach;
    }

    // create UIStarsAngle from StarsAngle

    return UIStarsAngle.from(starsAngle,
        uiSunAngle: uiSunAngle,
        uiMoonAngle: uiMoonAngle,
        uiVenusAngle: uiVenusAngle,
        uiJupiterAngle: uiJupiterAngle,
        uiMarsAngle: uiMarsAngle,
        uiSaturnAngle: uiSaturnAngle,
        uiWaterAngle: uiWaterAngle,
        uiSouthNodeAngle: uiSouthNodeAngle,
        uiNorthNodeAngle: uiNorthNodeAngle,
        uiBeiNodeAngle: uiBeiNodeAngle,
        uiQiAngle: uiQiAngle);
  }

  List<Widget> buildAllBasicLifePanelStars(
      StarsAngle starsAngle, double basicLifeStarCenterCircleSize) {
    UIStarsAngle uiStarsAngle =
        correctBasicLifeAngle(starsAngle, basicLifeStarCenterCircleSize);

    return [
      basicLifePanelStar(EnumStars.Sun, uiStarsAngle),
      basicLifePanelStar(EnumStars.Moon, uiStarsAngle),
      basicLifePanelStar(EnumStars.Venus, uiStarsAngle),
      basicLifePanelStar(EnumStars.Jupiter, uiStarsAngle),
      basicLifePanelStar(EnumStars.Mercury, uiStarsAngle),
      basicLifePanelStar(EnumStars.Mars, uiStarsAngle),
      basicLifePanelStar(EnumStars.Saturn, uiStarsAngle),
      basicLifePanelStar(EnumStars.Qi, uiStarsAngle),
      basicLifePanelStar(EnumStars.Bei, uiStarsAngle),
      basicLifePanelStar(EnumStars.Ji, uiStarsAngle),
      basicLifePanelStar(EnumStars.Luo, uiStarsAngle),
    ];
  }

  List<Widget> buildAllFateLifePanelStars(StarsAngle starsAngle, double size) {
    return [
      fateLifePanelStar(EnumStars.Sun, starsAngle, size),
      fateLifePanelStar(EnumStars.Moon, starsAngle, size),
      fateLifePanelStar(EnumStars.Venus, starsAngle, size),
      fateLifePanelStar(EnumStars.Jupiter, starsAngle, size),
      fateLifePanelStar(EnumStars.Mercury, starsAngle, size),
      fateLifePanelStar(EnumStars.Mars, starsAngle, size),
      fateLifePanelStar(EnumStars.Saturn, starsAngle, size),
      fateLifePanelStar(EnumStars.Qi, starsAngle, size),
      fateLifePanelStar(EnumStars.Bei, starsAngle, size),
      fateLifePanelStar(EnumStars.Ji, starsAngle, size),
      fateLifePanelStar(EnumStars.Luo, starsAngle, size),
    ];
  }

  Widget fateLifePanelStar(EnumStars star, StarsAngle starsAngle, double size) {
    return Consumer<QiZhengSiYuViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.daXianMapper != null && star.isFiveStar) {
          return fatePanelStar(viewModel.daXianMapper![star]!, size);
        } else {
          return child!;
        }
      },
      child: fatePanelStarDefault(star, starsAngle.getByStar(star), 64, size,
          offsetWidthTimes: 0),
    );
  }

  Widget basicLifePanelStar(EnumStars star, UIStarsAngle starsAngle) {
    return lifePanelStarDefault(star, starsAngle.getUIAngleByStar(star), 64,
        offsetWidthTimes: 0);

    // return Consumer<QiZhengSiYuViewModel>(
    //   builder: (context, viewModel, child) {
    //     if (viewModel.basicLifePanelStarsInfo != null){
    //       return lifePanelStar(viewModel.basicLifePanelStarsInfo!.getByStar(star),64,offsetWidthTimes:0);
    //     }else{
    //       return child!;
    //     }
    //   },
    //   child:lifePanelStarDefault(star,starsAngle.getUIAngleByStar(star),64,offsetWidthTimes:0),
    // );
  }

  Widget basicLifeStarPanelHelperCircle(double size) {
    return Container(
      width: size,
      height: size,
      // width: 520+32+10,
      // height: 520+32+10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: Colors.black.withOpacity(.1), width: 1),
      ),
    );
  }

  Widget fatePanelStarDefault(
      EnumStars star, double degree, double offsetWidth, double size,
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
    return Transform.rotate(
        angle: (120 - degree) * pi / 180,
        child: Container(
          width: 32 + oWidth,
          // height: 560,
          // height: 610,
          height: size,
          // color: Colors.blue.withOpacity(.1),
          alignment: Alignment.topCenter,
          child: ElTooltip(
            showModal: false,
            showChildAboveOverlay: false,
            content: const Text("tooltip"),
            child: CustomPaint(
              size: const Size(32, 650 - 600 - 4),
              painter: MyCirclePainter(
                  toOuter: true,
                  starName: star.singleName,
                  starAngle: degree,
                  // angle:((360-degree) * pi) / 180,
                  radians: ((360 - (120 - degree)) * pi) / 180,
                  offsetTimes: offsetWidthTimes,
                  backgroundColor: backgroundColor,
                  textStyle: GoogleFonts.notoSans(
                      fontSize: 20.0,
                      height: 1,
                      // color: Color.fromRGBO(55, 53, 52, 1),
                      color:
                          QiZhengSiYuUIConstantResources.starsColorMap[star]!,
                      fontWeight: FontWeight.normal,
                      shadows: [
                        BoxShadow(
                          color: Colors.black38.withOpacity(.1),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset:
                              const Offset(1, 1), // changes position of shadow
                        )
                      ])),
            ),
          ),
        ));
  }

  Widget lifePanelUIStarDefault(UIStarModel uiStar) {
    Color backgroundColor =
        QiZhengSiYuUIConstantResources.starsColorMap[uiStar.star]!;
    return Transform.rotate(
        angle: (120 - uiStar.angle) * pi / 180,
        child: Container(
          width: 32,
          height: 706,
          // color: Colors.blue.withOpacity(.1),
          alignment: Alignment.topCenter,
          child: ElTooltip(
            showModal: false,
            showChildAboveOverlay: false,
            content: const Text("tooltip"),
            // child: Container(),
            child: CustomPaint(
              size: const Size(32, 48),
              painter: StarBodyPainter(
                  star: uiStar,
                  // angle:((360-degree) * pi) / 180,
                  radians: ((360 - (120 - uiStar.angle)) * pi) / 180,
                  backgroundColor: backgroundColor,
                  textStyle: GoogleFonts.notoSans(
                      fontSize: 20.0,
                      height: 1,
                      // color: Color.fromRGBO(55, 53, 52, 1),
                      color: QiZhengSiYuUIConstantResources
                          .starsColorMap[uiStar.star]!,
                      fontWeight: FontWeight.normal,
                      shadows: [
                        BoxShadow(
                          color: Colors.black38.withOpacity(.3),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset:
                              const Offset(1, 1), // changes position of shadow
                        )
                      ])),
            ),
          ),
        ));
  }

  Widget lifePanelStarDefault(EnumStars star, double degree, double offsetWidth,
      {int offsetWidthTimes = 0}) {
    Color backgroundColor = QiZhengSiYuUIConstantResources.starsColorMap[star]!;
    return Transform.rotate(
        angle: (120 - degree) * pi / 180,
        child: Container(
          width: 32,
          // height: 560,
          // height: 610,
          // height: 610 + 64+32,
          height: 706,
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
                return CustomPaint(
                  size: const Size(32, 650 - 600 - 4),
                  painter: MyCirclePainter(
                      starName: star.singleName,
                      starAngle: degree,
                      // angle:((360-degree) * pi) / 180,
                      radians: ((360 - (120 - degree)) * pi) / 180,
                      offsetTimes: offsetWidthTimes,
                      backgroundColor: backgroundColor,
                      textStyle: GoogleFonts.notoSans(
                          fontSize: 20.0,
                          height: 1,
                          // color: Color.fromRGBO(55, 53, 52, 1),
                          color: QiZhengSiYuUIConstantResources
                              .starsColorMap[star]!,
                          fontWeight: FontWeight.normal,
                          shadows: [
                            BoxShadow(
                              color: Colors.black38.withOpacity(.3),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(
                                  1, 1), // changes position of shadow
                            )
                          ])),
                );
              },
            ),
          ),
        ));
  }

  Widget lifePanelStar(ElevenStarsInfo star, double offsetWidth,
      {int offsetWidthTimes = 0}) {
    Color backgroundColor =
        QiZhengSiYuUIConstantResources.starsColorMap[star.star]!;
    double oWidth = offsetWidth;
    if (offsetWidthTimes != 0) {
      if (offsetWidthTimes < 0) {
        int owt = offsetWidthTimes * -1;
        oWidth = offsetWidth + offsetWidth * (owt - 1) / 2;
      } else {
        oWidth = offsetWidth + offsetWidth * (offsetWidthTimes - 1) / 2;
      }
    }
    return Transform.rotate(
      // angle: (120 * pi) / 180,
      angle: 0,
      child: Transform.rotate(
          angle: (120 - star.angle) * pi / 180,
          child: Container(
            width: 32 + oWidth,
            // height: 560,
            // height: 610,
            height: 610 + 64 + 32,
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
                        starName: star.star.singleName,
                        // angle:((360-degree) * pi) / 180,
                        radians: ((360 - (120 - star.angle)) * pi) / 180,
                        starAngle: star.angle,
                        offsetTimes: offsetWidthTimes,
                        backgroundColor: backgroundColor,
                        textStyle: GoogleFonts.notoSans(
                            fontSize: 20.0,
                            height: 1,
                            // color: Color.fromRGBO(55, 53, 52, 1),
                            color: QiZhengSiYuUIConstantResources
                                .starsColorMap[star.star]!,
                            fontWeight: FontWeight.normal,
                            shadows: [
                              BoxShadow(
                                color: Colors.black38.withOpacity(.1),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: const Offset(
                                    1, 1), // changes position of shadow
                              )
                            ])),
                  );
                },
              ),
            ),
          )),
    );
  }

  Widget fatePanelStar(FiveStarWalkingInfo walkingInfo, double size) {
    Map<FiveStarWalkingType, Color> colorMap = {
      FiveStarWalkingType.Retrograde: Colors.black,
      FiveStarWalkingType.Fast: Colors.red,
      FiveStarWalkingType.Normal: Colors.blue,
      FiveStarWalkingType.Slow: Colors.brown,
      FiveStarWalkingType.Stay: Colors.blueGrey
    };
    Color backgroundColor = colorMap[walkingInfo.walkingType]!;
    double oWidth = 0;
    int offsetWidthTimes = 0;
    double offsetWidth = 0;
    if (offsetWidthTimes != 0) {
      if (offsetWidthTimes < 0) {
        int owt = offsetWidthTimes * -1;
        oWidth = offsetWidth + offsetWidth * (owt - 1) / 2;
      } else {
        oWidth = offsetWidth + offsetWidth * (offsetWidthTimes - 1) / 2;
      }
    }
    final textStyle = GoogleFonts.notoSans(
        fontSize: 20.0,
        height: 1,
        // color: Color.fromRGBO(55, 53, 52, 1),
        color: QiZhengSiYuUIConstantResources.zhengColorMap[walkingInfo.star]!,
        fontWeight: FontWeight.normal,
        shadows: [
          BoxShadow(
            color: Colors.black38.withOpacity(.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1), // changes position of shadow
          )
        ]);
    return Transform.rotate(
        angle: (120 - walkingInfo.angle) * pi / 180,
        child: Container(
          width: 32 + oWidth,
          height: size,
          // height: 610,
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
                return CustomPaint(
                  size: const Size(32, 650 - 600 - 4),
                  painter: MyCirclePainter(
                      starName: walkingInfo.star.singleName,
                      // angle:((360-degree) * pi) / 180,
                      textStyle: textStyle,
                      radians: ((360 - (120 - walkingInfo.angle)) * pi) / 180,
                      starAngle: walkingInfo.angle,
                      offsetTimes: offsetWidthTimes,
                      backgroundColor: backgroundColor,
                      toOuter: true),
                );
              },
            ),
          ),
        ));
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
          // color: Colors.black.withOpacity(.1),
          borderRadius: BorderRadius.circular(outerRadius),
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: StarXiuRingPainter(
            outerSize: starXiu28RingSizeOuter,
            innerSize: starXiu28RingSizeInner,
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
                // color: Colors.black.withOpacity(.1),
                borderRadius: BorderRadius.circular(outerRadius),
              ),
              child: CustomPaint(
                size: Size(size, size),
                painter: StarXiuRingPainter(
                  outerSize: starXiu28RingSizeOuter,
                  innerSize: starXiu28RingSizeInner,
                  mapper: QiZhengSiYuConstantResources
                      .ZodiacTropicalModernStarsInnSystemMapper,
                  sevenZhengColorMapper:
                      QiZhengSiYuUIConstantResources.zhengColorMap,
                ),
              )),
        ],
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

  Widget destiny12Gong(double innerSize, double outerSize,
      List<String> contentList, List<String>? zhuanTaiJiList) {
    return Transform.rotate(
      angle: 30 * pi / 180,
      child: ClipOval(
        child: MouseRegion(
          hitTestBehavior: HitTestBehavior.translucent,
          onEnter: (event) => showTaiJiDianButtonNotifier.value = true,
          onExit: (event) => showTaiJiDianButtonNotifier.value = false,
          child: Semantics(
            explicitChildNodes: true,
            child: Container(
              alignment: Alignment.center,
              height: outerSize,
              width: outerSize,
              // color: Colors.blue.withOpacity(.1),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(outerSize),
              ),
              child: Stack(
                children: [
                  ...List.generate(
                    12,
                    (i) => Transform.rotate(
                        angle: -(i * 30 + 75) * pi / 180,
                        // angle: 0,
                        origin: Offset.zero,
                        child: eachDestiny12Gong(contentList[i],
                            zhuanTaiJiList?[i], i >= 3 && i <= 8)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Transform.rotate(
      angle: 30 * pi / 180,
      child: PhysicalModel(
        shape: BoxShape.circle,
        color: Colors.red,
        clipBehavior: Clip.antiAlias,
        child: MouseRegion(
          onEnter: (event) => showTaiJiDianButtonNotifier.value = true,
          onExit: (event) => showTaiJiDianButtonNotifier.value = false,
          child: Container(
            alignment: Alignment.center,
            height: outerSize,
            width: outerSize,
            // color: Colors.blue.withOpacity(.1),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(outerSize),
              color: Colors.yellow.withOpacity(.2),
            ),
            child: Stack(
              children: [
                ...List.generate(
                  12,
                  (i) => Transform.rotate(
                      angle: -(i * 30 + 75) * pi / 180,
                      // angle: 0,
                      origin: Offset.zero,
                      child: eachDestiny12Gong(contentList[i],
                          zhuanTaiJiList?[i], i >= 3 && i <= 8)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget eachDestiny12Gong(
      String gongName, String? zhuanTaiJiGongName, bool reversedDisplay) {
    Widget taiJiButton = InkWell(
      borderRadius: BorderRadius.circular(48),
      onTap: () {
        selectTaiJiDestinyByGongName(gongName);
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          width: 64,
          alignment: Alignment.center,
          // decoration: BoxDecoration(
          //   color: Colors.teal[100]!.withOpacity(.2),
          //   borderRadius: BorderRadius.circular(10),
          // ),
          child: ValueListenableBuilder(
              valueListenable: showTaiJiDianButtonNotifier,
              builder: (ctx, show, _) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: show ? .6 : .2,
                  child: Text(
                    "转太极",
                    style: destinyTextStyle.copyWith(
                        fontSize: 18,
                        color: Colors.teal,
                        fontWeight: FontWeight.w300,
                        decorationStyle: ui.TextDecorationStyle.solid),
                  ),
                );
              })),
    );
    if (zhuanTaiJiGongName != null) {
      taiJiButton = InkWell(
        onTap: () {
          unselectTaiJiDestiny();
        },
        child: Container(
            width: 64,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(child: SizedBox()),
                Text(
                  zhuanTaiJiGongName,
                  style: destinyTextStyle.copyWith(
                      fontSize: 18,
                      color: zhuanTaiJiGongName == "命宫"
                          ? Colors.red
                          : destinyTextStyle.color,
                      fontWeight: zhuanTaiJiGongName == "命宫"
                          ? FontWeight.w500
                          : FontWeight.w300,
                      decorationStyle: ui.TextDecorationStyle.solid),
                ),
                InkWell(
                    onTap: () {
                      unselectTaiJiDestiny();
                    },
                    child: const Icon(Icons.dangerous_outlined,
                        size: 14, color: Colors.grey))
              ],
            )),
      );
    }
    Widget gong = AnimatedOpacity(
        opacity: zhuanTaiJiGongName == null ? 1 : .4,
        duration: const Duration(milliseconds: 200),
        child: Text(gongName,
            style: destinyTextStyle.copyWith(
              color: gongName == "命宫" ? Colors.red : destinyTextStyle.color,
            )));
    // Widget gong = Text(
    //   gongName,
    //   style: gongName == "命宫"
    //       ? destinyTextStyle.copyWith(color: Colors.red)
    //       : destinyTextStyle,
    // );
    List<Widget> widgets = [];
    if (reversedDisplay) {
      widgets.addAll([taiJiButton, gong]);
    } else {
      widgets.addAll([gong, taiJiButton]);
    }
    return Column(
      children: [
        Expanded(
          child: Container(),
        ),
        Transform.rotate(
          angle: reversedDisplay ? pi : 0,
          child: Container(
              alignment: Alignment.bottomCenter,
              // height: 36,
              width: 64,
              child: Column(
                children: widgets,
              )),
        ),
      ],
    );
  }

  Widget drawDestiny12Gong(
    double innerSize,
    double outerSize,
    List<String> contentList,
    // List<Text> contentList,
  ) {
    return Transform.rotate(
      angle: 30 * pi / 180,
      child: Container(
        alignment: Alignment.center,
        height: outerSize,
        width: outerSize,
        // color: Colors.blue.withOpacity(.1),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(.1),
          // borderRadius: BorderRadius.circular(outerSize)
        ),
        child: Stack(
          children: [
            ...List.generate(
                12,
                (i) => Transform.rotate(
                      angle: -(i * 30 + 75) * pi / 180,
                      // angle: 0,
                      origin: Offset.zero,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(),
                          ),
                          Transform.rotate(
                            angle: (i >= 3 && i <= 8) ? pi : 0,
                            child: Container(
                                alignment: Alignment.bottomCenter,
                                height: 36,
                                width: 64,
                                color: Colors.red.withOpacity(.1),
                                // child: e.value,
                                child: Text(
                                  contentList[i],
                                  style: contentList[i] == "命宫"
                                      ? destinyTextStyle.copyWith(
                                          color: Colors.red)
                                      : destinyTextStyle,
                                )),
                          )
                        ],
                      ),
                    ))
          ],
        ),
      ),
    );
  }

  Widget drawSelectedTaiJiDestiny12Gong(
    double innerSize,
    double outerSize,
    List<String>? contentList,
    // List<Text> contentList,
  ) {
    return Transform.rotate(
      angle: 30 * pi / 180,
      // angle: 0,
      child: Container(
        alignment: Alignment.center,
        height: outerSize,
        width: outerSize,
        decoration: BoxDecoration(
            // color: Colors.orange.withOpacity(.1),
            borderRadius: BorderRadius.circular(outerSize)),
        child: Stack(
          children: [
            if (contentList != null)
              ...List.generate(
                  12,
                  (i) => Transform.rotate(
                        angle: -(i * 30 + 75) * pi / 180,
                        origin: Offset.zero,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(),
                            ),
                            Transform.rotate(
                              angle: (i >= 3 && i <= 9) ? pi : 0,
                              child: Container(
                                  height: 42,
                                  width: 64,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Expanded(child: SizedBox()),
                                      // Icon(Icons.dangerous,size: 14,color: Colors.transparent,),
                                      Text(
                                        contentList[i],
                                        style: destinyTextStyle.copyWith(
                                            fontSize: 18,
                                            color: contentList[i] == "命宫"
                                                ? Colors.red
                                                : Colors.black45,
                                            fontWeight: contentList[i] == "命宫"
                                                ? FontWeight.w500
                                                : FontWeight.w300,
                                            decorationStyle:
                                                ui.TextDecorationStyle.solid),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            unselectTaiJiDestiny();
                                          },
                                          child: const Icon(
                                              Icons.dangerous_outlined,
                                              size: 14,
                                              color: Colors.grey))
                                    ],
                                  )),
                            ),
                            const SizedBox(
                              height: 4,
                            )
                          ],
                        ),
                      )),
            if (contentList == null)
              ...List.generate(
                  12,
                  (i) => Transform.rotate(
                        angle: -(i * 30 + 75) * pi / 180,
                        // angle: 0,
                        origin: Offset.zero,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(),
                            ),
                            Transform.rotate(
                              angle: (i >= 3 && i <= 8) ? pi : 0,
                              child: InkWell(
                                onTap: () {
                                  selectTaiJiDestiny(i);
                                },
                                child: ValueListenableBuilder(
                                    valueListenable:
                                        showTaiJiDianButtonNotifier,
                                    builder: (ctx, isShow, child) {
                                      return isShow
                                          ? child!
                                          : const SizedBox(
                                              height: 24,
                                            );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      width: 64,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.teal[100]!.withOpacity(.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        "太极点",
                                        style: destinyTextStyle.copyWith(
                                            fontSize: 18,
                                            color: Colors.black45,
                                            fontWeight: FontWeight.w300,
                                            decorationStyle:
                                                ui.TextDecorationStyle.solid),
                                      ),
                                    )),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            )
                          ],
                        ),
                      ))
          ],
        ),
      ),
    );
  }

  Widget draw12GongRingGrid(double innerSize, double outerSize,
      {double innerPadding = 2}) {
    double outerRadius = outerSize * .5;
    double innerRadius = innerSize * .5;
    return Container(
        alignment: Alignment.center,
        height: outerSize,
        width: outerSize,
        decoration: BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(outerSize),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Transform.rotate(
          angle: 75 * pi / 180,
          // angle: 0,
          origin: Offset.zero,
          child: CustomPaint(
            size: Size(outerSize, outerSize),
            painter: RingSheetPainter(
              innerRadius: innerRadius,
              outerRadius: outerRadius,
            ),
          ),
        ));
  }

  Widget draw12GongRingText(
      double innerSize, double outerSize, List<Text> contentList,
      {double innerPadding = 2}) {
    double outerRadius = outerSize * .5;
    double innerRadius = innerSize * .5;
    return Container(
        alignment: Alignment.center,
        height: outerSize,
        width: outerSize,
        decoration: BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(outerSize),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Transform.rotate(
          angle: 75 * pi / 180,
          // angle: 0,
          origin: Offset.zero,
          child: CustomPaint(
            size: Size(outerSize, outerSize),
            painter: TextCircleRingPainter(
              innerRadius: innerRadius,
              outerRadius: outerRadius,
              textList: contentList,
              isAntiClockwise: true,
              innerPadding: 0,
              isReverseText: false,
              isHorizontalText: true,
            ),
          ),
        ));
  }

  Widget draw12GongRing(
      double innerSize, double outerSize, List<Text> contentList,
      {double innerPadding = 2}) {
    double outerRadius = outerSize * .5;
    double innerRadius = innerSize * .5;
    return Container(
        alignment: Alignment.center,
        height: outerSize,
        width: outerSize,
        decoration: BoxDecoration(
          // color: Colors.red.withOpacity(.1),
          borderRadius: BorderRadius.circular(outerSize),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Transform.rotate(
          angle: 75 * pi / 180,
          // angle: 0,
          origin: Offset.zero,
          child: CustomPaint(
            size: Size(outerSize, outerSize),
            painter: RingSheetPainter(
              innerRadius: innerRadius,
              outerRadius: outerRadius,
            ),
            // painter:TextCircleRingPainter(
            //   innerRadius: innerRadius,
            //   outerRadius: outerRadius,
            //   textList: contentList,
            //   isAntiClockwise: true,
            //   innerPadding: 0,
            //   isReverseText: false,
            //   isHorizontalText: true,
            // ),
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
          angle: 75 * pi / 180,
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

  /// gongIndex 0-11 子-亥
  void selectTaiJiDestinyByGongName(String selectedGongName) {
    // 根据给定gongIndex
    List<String> tmpDefaultList = destinyList.map((d) => d).toList();
    List<String> tmpDestinyList =
        _destiny12GongListNotifier.value.map((d) => d).toList();
    int selectedIndex = _destiny12GongListNotifier.value
        .indexWhere((x) => x == selectedGongName);
    String taiJiAtGong = _destiny12GongListNotifier.value[selectedIndex];
    logger.i("user select as TaiJi, which is $taiJiAtGong");
    int index = tmpDefaultList.indexOf(taiJiAtGong);
    // 将_tmpList 从 gongIndex 处分成两个

    List<String> tmpList1 = tmpDefaultList.sublist(12 - index);
    List<String> tmpList2 = tmpDefaultList.sublist(0, 12 - index);
    logger.d("_tmpList1 $tmpList1");
    logger.d("_tmpList2 $tmpList2");
    // 将_tmpList2 拼接在 _tmpList1 前面
    _selectedTaiJiDestiny12GongListNotifier.value = tmpList1 + tmpList2;
    logger.i(_selectedTaiJiDestiny12GongListNotifier.value);
  }

  /// gongIndex 0-11 子-亥
  void selectTaiJiDestiny(int selectedIndex) {
    // 根据给定gongIndex
    List<String> tmpDefaultList = destinyList.map((d) => d).toList();
    List<String> tmpDestinyList =
        _destiny12GongListNotifier.value.map((d) => d).toList();
    String taiJiAtGong = _destiny12GongListNotifier.value[selectedIndex];
    logger
        .i("user select index:$selectedIndex as TaiJi, which is $taiJiAtGong");
    int index = tmpDefaultList.indexOf(taiJiAtGong);
    // 将_tmpList 从 gongIndex 处分成两个

    List<String> tmpList1 = tmpDefaultList.sublist(12 - index);
    List<String> tmpList2 = tmpDefaultList.sublist(0, 12 - index);
    logger.d("_tmpList1 $tmpList1");
    logger.d("_tmpList2 $tmpList2");
    // 将_tmpList2 拼接在 _tmpList1 前面
    _selectedTaiJiDestiny12GongListNotifier.value = tmpList1 + tmpList2;
    logger.i(_selectedTaiJiDestiny12GongListNotifier.value);
  }

  void unselectTaiJiDestiny() {
    _selectedTaiJiDestiny12GongListNotifier.value = null;
  }
}
