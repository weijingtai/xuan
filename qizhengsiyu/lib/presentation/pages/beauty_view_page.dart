import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:common/datamodel/divination_type_data_model.dart';
import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:common/module.dart';
import 'package:common/shared/shared.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';

import 'package:common/painter/text_circle_ring_painter.dart';
import 'package:common/painter/circle_ring_printer.dart';
import '../../domain/entities/models/base_panel_model.dart';
import '../../domain/entities/models/body_life_model.dart';
import '../../domain/entities/models/eleven_stars_info.dart';
import '../../domain/entities/models/naming_degree_pair.dart';
import '../../domain/entities/models/observer_position.dart';
import '../../domain/entities/models/panel_stars_info.dart';
import '../../domain/entities/models/passage_year_panel_model.dart';
import '../../domain/entities/models/stars_angle.dart';
import '../../domain/entities/models/zhou_tian_model.dart';
import '../../enums/enum_twelve_gong.dart';
import '../../painter/painters.dart';
import '../../painter/star_body_ring_painter.dart';
import '../../painter/star_xiu_ring_painter.dart';
import '../../qi_zheng_si_yu_ui_constant_resources.dart';
import '../../utils/star_enter_info_calculator.dart';
import '../models/ui_star_model.dart';
import '../widgets/rings/body_life_circle_widget.dart';
import '../widgets/rings/da_xian_ring.dart';
import '../widgets/rings/gong_12_dizhi.dart';
import '../widgets/rings/gong_ming_li_ring.dart';
import '../widgets/rings/gong_shen_sha_ring.dart';
import '../widgets/star_body.dart';
import 'beauty_page_viewmodel.dart';

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

class BeautyViewPageParams {
  DivinationInfoModel? divinationInfoModel;
  DivinationTypeDataModel divinationTypeDataModel;
  // pan uuid
  String? panUuid;
  BeautyViewPageParams({
    required this.divinationTypeDataModel,
    this.divinationInfoModel,
    this.panUuid,
  }) : assert(divinationInfoModel != null || panUuid != null,
            '必须提供 divinationInfoModel 或 uuid 中的一个参数');

  static BeautyViewPageParams get devDefault {
    // 根据注释中的JSON数据创建DivinationInfoModel
    final jsonData = {
      "divination": {
        "uuid": "01971a88-45a0-7fff-ad25-2123d9955f2c",
        "createdAt": "2025-05-28T22:33:47.000",
        "lastUpdatedAt": "2025-05-28T22:33:47.000",
        "deletedAt": null,
        "divinationTypeUuid": "b07421dc-6ef5-4959-afd3-7c618b152fb4",
        "fateYear": null,
        "question": "卜问前程，开发《七政四余》",
        "detail": "卜问前程，开发《七政四余》",
        "ownerSeekerUuid": null,
        "gender": "male",
        "seekerName": "wjt",
        "tinyPredict": null,
        "directlyPredict": null
      },
      "divinationDatetime": {
        "uuid": "01971a88-45a1-7582-b2d6-bfbeacef71ea",
        "createdAt": "2025-05-28T22:33:47.000",
        "lastUpdatedAt": "2025-05-28T22:33:47.000",
        "deletedAt": null,
        "timingType": "solar",
        "datetime": "2025-05-28T22:33:37.000",
        "yearGanZhi": "乙巳",
        "monthGanZhi": "辛巳",
        "dayGanZhi": "丁酉",
        "timeGanZhi": "辛亥",
        "lunarMonth": 5,
        "isLeapMonth": false,
        "lunarDay": 2,
        "timingInfoUuid": "0b80fd88-a3c9-4582-a4a3-802e49b65787",
        "location": {
          "preciseCoordinates": {
            "latitude": 36.08602199797812,
            "longitude": -115.25735962437955
          },
          "address": {
            "countryName": "United States",
            "countryId": 233,
            "regionId": 2,
            "province": {
              "code": "1458",
              "parentCode": "233",
              "level": 1,
              "name": "Nevada",
              "latitude": 38.8026097,
              "longitude": -116.419389
            },
            "city": {
              "code": "126881",
              "parentCode": "1458",
              "level": 2,
              "name": "Spring Valley",
              "latitude": 36.10803,
              "longitude": -115.245
            },
            "area": null,
            "timezone": "America/Los_Angeles"
          },
          "isReverseSpeculation": false
        },
        "timingInfoListJson": [
          {
            "uuid": "0b80fd88-a3c9-4582-a4a3-802e49b65787",
            "isDst": true,
            "isSeersLocation": true,
            "observer": {
              "coordinate": null,
              "location": {
                "preciseCoordinates": {
                  "latitude": 36.08602199797812,
                  "longitude": -115.25735962437955
                },
                "address": {
                  "countryName": "United States",
                  "countryId": 233,
                  "regionId": 2,
                  "province": {
                    "code": "1458",
                    "parentCode": "233",
                    "level": 1,
                    "name": "Nevada",
                    "latitude": 38.8026097,
                    "longitude": -116.419389
                  },
                  "city": {
                    "code": "126881",
                    "parentCode": "1458",
                    "level": 2,
                    "name": "Spring Valley",
                    "latitude": 36.10803,
                    "longitude": -115.245
                  },
                  "area": null,
                  "timezone": "America/Los_Angeles"
                },
                "isReverseSpeculation": false
              },
              "timezoneStr": "America/Los_Angeles",
              "type": "阳历",
              "hourAdjusted": null,
              "isManualCalibration": false
            },
            "datetime": "2025-05-28T22:33:37.000",
            "yearJiaZi": "乙巳",
            "monthJiaZi": "辛巳",
            "dayJiaZi": "丁酉",
            "timeJiaZi": "辛亥",
            "lunarMonth": 5,
            "isLeapMonth": false,
            "lunarDay": 2,
            "jieQiInfo": {
              "jieQi": "小满",
              "startAt": "2025-05-21T02:54:23.000",
              "endAt": "2025-06-05T17:56:16.000"
            }
          }
        ],
        "divinationUuid": "01971a88-45a0-7fff-ad25-2123d9955f2c",
        "username": null,
        "nickname": null,
        "gender": "male"
      }
    };

    // 从JSON创建DivinationInfoModel
    final divinationInfoModel = DivinationInfoModel.fromJson(jsonData);

    // 创建DivinationTypeDataModel
    final divinationTypeDataModel = DivinationTypeDataModel(
      uuid: "b07421dc-6ef5-4959-afd3-7c618b152fb4",
      createdAt: DateTime.parse("2025-05-28T22:33:47.000"),
      lastUpdatedAt: DateTime.parse("2025-05-28T22:33:47.000"),
      deletedAt: null,
      name: "占测", // 根据divinationType推断
      description: "七政四余占测",
      isCustomized: false,
      isAvailable: true,
    );

    return BeautyViewPageParams(
      divinationTypeDataModel: divinationTypeDataModel,
      divinationInfoModel: divinationInfoModel,
    );
  }
}

class BeautyViewPage extends StatefulWidget {
  final BeautyViewPageParams params;
  const BeautyViewPage({super.key, required this.params});
  // const BeautyViewPage({super.key});

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

  double yuStarSize = 16;
  double zhengStarSize = 26;
  double yinYangStarSize = 32;

  late QiZhengSiYuPanSizeDataModel panelSizeDataModel;

  @deprecated
  Future<void> devInit() async {
    final res = await Future.wait([
      loadDiviniation(),
    ]);
    init_calculate(res[0] as DivinationInfoModel);
  }

  init_calculate(DivinationInfoModel divinationInfoModel) {
    context.read<BeautyPageViewModel>().setLifeObserver(divinationInfoModel);
    context
        .read<BeautyPageViewModel>().calculate(
            context.read<BeautyPageViewModel>().panelConfig,
            context.read<BeautyPageViewModel>().lifeObserver!);
  }

  @deprecated
  Future<DivinationInfoModel> loadDiviniation() async {
    var divinations = await context
        .read<DevEnterPageViewModel>()
        .appDatabase
        .divinationsDao
        .getAllDivinations();
    var seeker = await context
        .read<DevEnterPageViewModel>()
        .appDatabase
        .seekersDao
        .getSeekersByDivinationUuid(divinations.last.uuid);

    var res = DivinationInfoModel(
        divination: divinations.last, divinationDatetime: seeker.first);

    return res;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // devInit().then((value) {
    //   logger.d("devInit finished");
    // });
    Future.delayed(Duration(seconds: 3),
        () => {init_calculate(widget.params.divinationInfoModel!)});

    Future.delayed(Duration(seconds: 5), () {
      context.read<BeautyPageViewModel>().calculateDaXian(DateTime.now());
    });

    panelSizeDataModel = QiZhengSiYuPanSizeDataModel(
        starBodyRadius: 16,
        centerSize: 128,
        diZhi12GongHeight: 50,
        zodiac12GongHeight: 24,
        starSeq12GongHeight: 0,
        destiny12GongHeight: 42,
        lifeStarRingHeight: 48, // 64
        starXiu28RingHeight: 36, // 660
        innerShenShaHeight: 90,
        outerShenShaHeight: 90,
        showFateLifeStarRing: true);

    // panelSizeDataModel = QiZhengSiYuPanSizeDataModel(
    //     starBodyRadius: 16 + 4,
    //     centerSize: 172,
    //     diZhi12GongHeight: 60,
    //     zodiac12GongHeight: 42,
    //     starSeq12GongHeight: 0,
    //     destiny12GongHeight: 64,
    //     lifeStarRingHeight: 16 * 4, // 564
    //     starXiu28RingHeight: 48, // 660
    //     innerShenShaHeight: 128,
    //     outerShenShaHeight: 128,
    //     showFateLifeStarRing: true);
  }

  @override
  void dispose() {
    // TODO: implement dispose

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
  ///

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

    if (isFirst) {
      Future.delayed(const Duration(seconds: 3), () {
        isFirst = false;
        // calculatePanel();
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Container(
            //   padding: const EdgeInsets.all(15),
            //   child: ValueListenableBuilder(
            //     valueListenable: showStarHuaJiInfoNotifier,
            //     builder: (ctx, show, _) {
            //       return Switch(
            //           value: show,
            //           onChanged: (n) {
            //             showStarHuaJiInfoNotifier.value = n;
            //           });
            //     },
            //   ),
            // ),
            Container(
                width: panelMaxSize,
                height: panelMaxSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<ZhouTianModel?>(
                        valueListenable: context.read<BeautyPageViewModel>().zhouTianModelNotifier,
                        builder: (ctx, zhouTianModel, _) {
                          if (zhouTianModel == null) {
                            return const CircularProgressIndicator(); // Or a placeholder
                          }
                          return Transform.rotate(
                            angle: 30 * pi / 180,
                            child: panel(starBodyRadius, zhouTianModel),
                          );
                        },
                      ),
                      const Expanded(child: SizedBox()),
                    ])),
          ],
        ),
      ),
    );
  }

  Widget center(BasePanelModel basePanel) {
    return Container(
        width: centerSize,
        height: centerSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // color: Colors.black.withOpacity(.1),
          borderRadius: BorderRadius.circular(centerSize),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  basePanel.bodyLifeModel.lifeConstellatioin.fullname,
                  style: TextStyle(fontSize: 14, height: 1.2),
                ),
                Text(
                  "${basePanel.bodyLifeModel.lifeDegree.toStringAsFixed(1)}°",
                  style: TextStyle(fontSize: 12, height: 1.2),
                ),
              ],
            ),
            fourZhu(basePanel.bodyLifeModel),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${basePanel.bodyLifeModel.bodyGongDegree.toStringAsFixed(1)}°",
                  style: TextStyle(fontSize: 12, height: 1.2),
                ),
                // SizedBox(width: 4,),
                Text(
                  basePanel.bodyLifeModel.bodyConstellation.fullname,
                  style: TextStyle(fontSize: 14, height: 1.2),
                ),

                Text(
                  "安身",
                  style: TextStyle(fontSize: 12, height: 1.2),
                ),
              ],
            )
          ],
        ));
  }

  Widget fourZhu(BodyLifeModel bodyLifeModel) {
    TextStyle titleTextStyle =
        TextStyle(fontSize: 14, height: 1.2, color: Colors.black38);
    TextStyle infoTextStyle =
        TextStyle(fontSize: 14, height: 1.2, fontWeight: FontWeight.bold);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text.rich(TextSpan(text: "命主:", style: titleTextStyle, children: [
                TextSpan(
                    text: bodyLifeModel.lifeGong.sevenZheng.singleName,
                    style: infoTextStyle.copyWith(
                        color: QiZhengSiYuUIConstantResources
                            .zhengColorMap[bodyLifeModel.lifeGong.sevenZheng])),
              ])),
              Text.rich(TextSpan(text: "度主:", style: titleTextStyle, children: [
                TextSpan(
                    text:
                        bodyLifeModel.lifeConstellatioin.sevenZheng.singleName,
                    style: infoTextStyle.copyWith(
                        color: QiZhengSiYuUIConstantResources.zhengColorMap[
                            bodyLifeModel.lifeConstellatioin.sevenZheng]))
              ])),
            ]),
        SizedBox(
          width: 24,
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text.rich(TextSpan(text: "身主:", style: titleTextStyle, children: [
                TextSpan(
                    text: bodyLifeModel.bodyGong.sevenZheng.singleName,
                    style: infoTextStyle.copyWith(
                        color: QiZhengSiYuUIConstantResources
                            .zhengColorMap[bodyLifeModel.bodyGong.sevenZheng]))
              ])),
              Text.rich(TextSpan(text: "身度:", style: titleTextStyle, children: [
                TextSpan(
                    text: bodyLifeModel.bodyConstellation.sevenZheng.singleName,
                    style: infoTextStyle.copyWith(
                        color: QiZhengSiYuUIConstantResources.zhengColorMap[
                            bodyLifeModel.bodyConstellation.sevenZheng]))
              ])),
            ])
      ],
    );
  }

  Widget eigthChatPanel(ObserverPosition observer) {
    // ValueListenableBuilder<ObserverPosition?>(
    // valueListenable: context
    //     .read<BeautyPageViewModel>()
    //     .observerPositionNotifier,
    // builder: (ctx, position, _) {
    //   if (position == null) {
    //     return SizedBox();
    //   }
    //   return eigthChatPanel(position);
    // }),

    TextStyle titleStyle = TextStyle(fontSize: 12, height: 1.0);
    TextStyle ganZhiStyle = TextStyle(fontSize: 16, height: 1.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "运",
              style: titleStyle,
            ),
            Text("癸", style: ganZhiStyle),
            Text("卯", style: ganZhiStyle),
          ],
        ),
        SizedBox(
          width: 6,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("流", style: titleStyle),
            Text("辛", style: ganZhiStyle),
            Text("丑", style: ganZhiStyle),
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
              style: titleStyle,
            ),
            Text(observer.yearGanZhi.gan.name, style: ganZhiStyle),
            Text(observer.yearGanZhi.zhi.name, style: ganZhiStyle),
          ],
        ),
        SizedBox(
          width: 6,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("月", style: titleStyle),
            Text(observer.monthGanZhi.gan.name, style: ganZhiStyle),
            Text(observer.monthGanZhi.zhi.name, style: ganZhiStyle),
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
              style: titleStyle,
            ),
            Text(observer.dayGanZhi.gan.name, style: ganZhiStyle),
            Text(observer.dayGanZhi.zhi.name, style: ganZhiStyle),
          ],
        ),
        SizedBox(
          width: 6,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("时", style: titleStyle),
            Text(observer.timeGanZhi.gan.name, style: ganZhiStyle),
            Text(observer.timeGanZhi.zhi.name, style: ganZhiStyle),
          ],
        )
      ],
    );
  }

  Widget panel(double starBodyRadius, ZhouTianModel zhouTianModel) {
    // 黄道十二宫 从白羊开始
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

    final constellationPositions = StarEnterInfoCalculator.generateConstellationSequence(
        zhouTianModel.alignmentPointAtConstellation,
        zhouTianModel.starInnDegreeSeq);

    double rotating = 0;
    return Stack(
      alignment: Alignment.center,
      children: [
        ValueListenableBuilder(
            valueListenable:
                context.read<BeautyPageViewModel>().dongWeiFateResultNotifier,
            builder: (ctx, dongWei, child) {
              if (dongWei == null) {
                return SizedBox();
              }
              final Map<EnumTwelveGong, YearMonth> gongYearMapper =
                  Map.fromEntries(dongWei.daXianResult.daXianGongs
                      .map((e) => MapEntry(e.gong, e.totalYears)));
              return Transform.rotate(
                angle: -30 * pi / 180,
                child: DaXianRing(
                    outerRadius:
                        (panelSizeDataModel.outerShenShaSizeOuter * .5) + 32,
                    innerRadius:
                        (panelSizeDataModel.outerShenShaSizeOuter * .5) + 24,
                    gongYearsMapper: gongYearMapper,
                    baseGongOffsetAngle: 30),
              );
            }),
        // 十二地支宫
        Transform.rotate(
          angle: -30 * pi / 180,
          child: build12DiZhiGong(diZhi12GongOuter * .5, diZhi12GongInner * .5, zhouTianModel),
        ),
        // 黄道十二宫
        Transform.rotate(
          angle: -30 * pi / 180,
          child: zhouTian12GongRing(
              zodiac12GongSizeInner * .5, zodiac12GongSizeOuter * .5,zhouTianModel),
        ),
        // 星次十二宫
        // drawRingWithTextList(starSeq12GongSizeOuter, 18, starSeqTextList),
        // 命理十二宫
        Transform.rotate(
          angle: -30 * pi / 180,
          child: buildMingLi12GongRing(
              destiny12GongSizeInner * .5, destiny12GongSizeOuter * .5, zhouTianModel),
        ),

        Transform.rotate(
          angle: rotating * pi / 180,
          child: starXiuRing(starXiu28RingSizeOuter, 40, zhouTianModel, constellationPositions),
        ),

        draw12GongRingGrid(
          panelSizeDataModel.innerShenShaSizeInner,
          panelSizeDataModel.innerShenShaSizeOuter,
          zhouTianModel,
        ),
        draw12GongRingGrid(
          panelSizeDataModel.outerShenShaSizeInner,
          panelSizeDataModel.outerShenShaSizeOuter,
          zhouTianModel,
        ),

        // 大限星轨
        // 本命盘星轨
        ValueListenableBuilder<List<UIStarModel>?>(
            valueListenable:
                context.read<BeautyPageViewModel>().uiFateLifeStarsNotifier,
            builder: (ctx, uiFateStarsList, child) {
              if (uiFateStarsList == null) {
                return Container(
                  width: fateLifeStarOuterSize,
                  height: fateLifeStarOuterSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(fateLifeStarOuterSize),
                    border: Border.all(color: Colors.black87, width: 1),
                  ),
                );
              }
              return Transform.rotate(
                angle: -(rotating - 90) * pi / 180,
                child: innerStarBodyRotating(uiFateStarsList),
              );
              // return Transform.rotate(
              //   angle: rotating * pi / 180,
              //   child: innerStarBodyRotating(uiFateStarsList),
              // );
            }),
        ValueListenableBuilder<List<UIStarModel>?>(
            valueListenable:
                context.read<BeautyPageViewModel>().uiFateLifeStarsNotifier,
            builder: (ctx, uiFateStarsList, child) {
              if (uiFateStarsList == null) {
                return Container(
                  width: fateLifeStarOuterSize,
                  height: fateLifeStarOuterSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(fateLifeStarOuterSize),
                    border: Border.all(color: Colors.black87, width: 1),
                  ),
                );
              }
              return Transform.rotate(
                angle: rotating * pi / 180,
                child: innerStarTrackRing(uiFateStarsList),
              );
            }),

        ValueListenableBuilder<List<UIStarModel>?>(
            valueListenable:
                context.read<BeautyPageViewModel>().uiBasicLifeStarsNotifier,
            builder: (ctx, uiBasicStarsList, child) {
              if (uiBasicStarsList == null) {
                return Container(
                  width: basicLifeStarRingOuterSize,
                  height: basicLifeStarRingOuterSize,
                  decoration: BoxDecoration(
                    // color: Colors.yellow,
                    borderRadius:
                        BorderRadius.circular(basicLifeStarRingOuterSize),
                    border: Border.all(color: Colors.black87, width: 1),
                  ),
                );
              }
              return Transform.rotate(
                angle: -(rotating - 90) * pi / 180,
                child: outerStarBodyRotating(uiBasicStarsList),
              );
            }),
        ValueListenableBuilder<List<UIStarModel>?>(
            valueListenable:
                context.read<BeautyPageViewModel>().uiBasicLifeStarsNotifier,
            builder: (ctx, uiBasicStarsList, child) {
              if (uiBasicStarsList == null) {
                return Container(
                  width: basicLifeStarRingOuterSize,
                  height: basicLifeStarRingOuterSize,
                  decoration: BoxDecoration(
                    // color: Colors.yellow,
                    borderRadius:
                        BorderRadius.circular(basicLifeStarRingOuterSize),
                    border: Border.all(color: Colors.black87, width: 1),
                  ),
                );
              }
              return Transform.rotate(
                angle: rotating * pi / 180,
                child: outerStarTrackRing(uiBasicStarsList),
              );
            }),

        // 神煞
        Transform.rotate(
          angle: 0 * pi / 180, // 和命理十二宫一样为逆时针转，也从子宫位第一宫
          // angle: 0,
          child: ValueListenableBuilder<BasePanelModel?>(
            valueListenable:
                context.read<BeautyPageViewModel>().uiBasePanelNotifier,
            builder: (ctx, basePanel, child) {
              if (basePanel == null) {
                return child!;
              }
              return Transform.rotate(
                angle: -30 * pi / 180,
                                  child: AllShenShaRing(
                                    outerRadius: panelSizeDataModel.innerShenShaSizeOuter * .5,
                                    innerRadius: panelSizeDataModel.innerShenShaSizeInner * .5,
                                    shenShaMapper: basePanel.shenShaItemMapper,
                                    gongOrder: EnumTwelveGong.listAll,
                                    zhouTianModel: zhouTianModel,
                                  ),              );
            },
            child: Container(
              width: panelSizeDataModel.innerShenShaSizeOuter,
              height: panelSizeDataModel.innerShenShaSizeOuter,
            ),
          ),
        ),

        // 流年神煞
        Transform.rotate(
          angle: 0 * pi / 180, // 和命理十二宫一样为逆时针转，也从子宫位第一宫
          // angle: 0,
          child: ValueListenableBuilder<PassageYearPanelModel?>(
              valueListenable:
                  context.read<BeautyPageViewModel>().uiDaXianPanelNotifier,
              builder: (ctx, daXianPanel, child) {
                if (daXianPanel == null) {
                  return child!;
                }
                return Transform.rotate(
                  angle: -30 * pi / 180,
                  child: AllShenShaRing(
                    outerRadius: panelSizeDataModel.outerShenShaSizeOuter * .5,
                    innerRadius: panelSizeDataModel.outerShenShaSizeInner * .5,
                    shenShaMapper: daXianPanel.shenShaItemMapper,
                    gongOrder: EnumTwelveGong.listAll,
                    zhouTianModel: zhouTianModel,
                  ),
                );
              },
              child: Container(
                width: panelSizeDataModel.outerShenShaSizeOuter,
                height: panelSizeDataModel.outerShenShaSizeOuter,
              )),
        ),
        Transform.rotate(
            angle: -30 * pi / 180,
            child: ValueListenableBuilder<BasePanelModel?>(
                valueListenable:
                    context.read<BeautyPageViewModel>().uiBasePanelNotifier,
                builder: (ctx, basePanel, _) {
                  if (basePanel == null) return Container();
                  return BodyLifeCircleWidget(
                    bodyLifeModel: basePanel.bodyLifeModel,
                    itemSize: 64,
                    ringColor: Colors.transparent,
                    textStyle: TextStyle(
                        fontSize: 12, color: Colors.black38, height: 1),
                    starTextStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withAlpha(80),
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ]),
                  );
                })),

        // Transform.rotate(
        //   angle: -30 * pi / 180,
        //   child: ValueListenableBuilder<BasePanelModel?>(
        //       valueListenable:
        //           context.read<BeautyPageViewModel>().uiBasePanelNotifier,
        //       builder: (ctx, baseModel, _) {
        //         if (baseModel == null) {
        //           return Container(
        //             width: panelSizeDataModel.outerShenShaSizeOuter,
        //             height: panelSizeDataModel.outerShenShaSizeOuter,
        //           );
        //         }
        //         return center(baseModel);
        //       }),
        // ),
      ],
    );
  }

  Widget build12DiZhiGong(double outerRadius, double innerRadius, ZhouTianModel zhouTianModel) {
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
    return Gong12DiZhiRing(
      outerRadius: outerRadius,
      innerRadius: innerRadius,
      zhouTianModel: zhouTianModel,
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

    return Transform.rotate(
      angle: -(number * 30) * (pi / 180),
      // angle: 0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(
              1,
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
        // decoration: BoxDecoration(
        // TODO: DevHelper Color
        // color: Colors.blue.withOpacity(.1)),
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
            // border: BorderSide(color: Colors.black87, width: 1),
            // 底部 border
            border: Border(
          bottom: BorderSide(color: Colors.yellow, width: 1),
        )),
        // decoration: BoxDecoration(
        // TODO: DevHelper Color
        // color: Colors.blue.withOpacity(.1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RotatedBox(
              quarterTurns: 2,
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
              quarterTurns: 2,
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
    print("-------- ${uiBasicLifeStarList.length}");
    print(
        "---- ${uiBasicLifeStarList.map((e) => e.star.singleName).join(",")}");
    return Container(
      width: basicLifeStarRingOuterSize,
      height: basicLifeStarRingOuterSize,
      decoration: BoxDecoration(
        // color: Colors.yellow,
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
    if (starsAngle.venus < starsAngle.sun) {
      diffDegree = starsAngle.sun - starsAngle.venus;
    } else {
      diffDegree = starsAngle.venus - starsAngle.sun;
    }
    double needDegreeInTotal = minCollision - diffDegree;
    double needDegreeAddEach = needDegreeInTotal * .5;
    if (starsAngle.venus < starsAngle.sun) {
      uiSunAngle = starsAngle.sun + needDegreeAddEach;
      uiVenusAngle = starsAngle.venus - needDegreeAddEach;
    } else {
      uiSunAngle = starsAngle.sun - needDegreeAddEach;
      uiVenusAngle = starsAngle.venus + needDegreeAddEach;
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
  Widget starXiuRing(double size, double ringWidth, ZhouTianModel zhouTianModel, List<ConstellationPosition> constellationPositions) {
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
            zhouTianModel: zhouTianModel,
            constellationPositions: constellationPositions, // Pass the calculated positions
            sevenZhengColorMapper: QiZhengSiYuUIConstantResources.zhengColorMap,
          ),
        ));
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

  Widget draw12GongRingGrid(double innerSize, double outerSize, ZhouTianModel zhouTianModel,
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
              zhouTianModel: zhouTianModel,
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

  // 周天12宫
  Widget zhouTian12GongRing(double innerSize, double outerSize,ZhouTianModel zhouTianModel) {
    return zodicalRing(innerSize, outerSize,zhouTianModel);
  }

  Widget zodicalRing(double innerSize, double outerSize,ZhouTianModel zhouTianModel) {
    return generateDefault12GongRing(
        innerSize, outerSize, defaultZodiac12GongMapper,zhouTianModel);
  }

  Widget starSeqRing(double innerSize, double outerSize,ZhouTianModel zhouTianModel) {
    return generateDefault12GongRing(
        innerSize, outerSize, defaultStarSeq12GongMapper,zhouTianModel);
  }

  Widget buildMingLi12GongRing(double innerSize, double outerSize, ZhouTianModel zhouTianModel) {
    return ValueListenableBuilder<BasePanelModel?>(
        valueListenable:
            context.read<BeautyPageViewModel>().uiBasePanelNotifier,
        builder: (ctx, basePanel, child) {
          if (basePanel == null) return child!;
          final gongStrEntry = basePanel.twelveGongMapper.entries
              .map((en) => MapEntry(en.key, [en.value.name]));
          final resultMapper = Map.fromEntries(gongStrEntry);
          return generateDefault12GongRing(innerSize, outerSize, resultMapper, zhouTianModel);
        },
        child: generateDefault12GongRing(
            innerSize, outerSize, defaultDestiny12GongMapper, zhouTianModel));
  }

  Map<EnumTwelveGong, List<String>> defaultStarSeq12GongMapper = {
    EnumTwelveGong.Zi: ["玄枵"],
    EnumTwelveGong.Chou: ["星纪"],
    EnumTwelveGong.Yin: ["析木"],
    EnumTwelveGong.Mao: ["大火"],
    EnumTwelveGong.Chen: ["寿星"],
    EnumTwelveGong.Si: ["鹑尾"],
    EnumTwelveGong.Wu: ["鹑火"],
    EnumTwelveGong.Wei: ["鹑首"],
    EnumTwelveGong.Shen: ["实沈"],
    EnumTwelveGong.You: ["大梁"],
    EnumTwelveGong.Xu: ["降娄"],
    EnumTwelveGong.Hai: ["娵訾"],
  };

  Map<EnumTwelveGong, List<String>> defaultZodiac12GongMapper = {
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
  };

  Map<EnumTwelveGong, List<String>> defaultDestiny12GongMapper = {
    EnumTwelveGong.Zi: ["命宫"],
    EnumTwelveGong.Chou: ["相貌"],
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
  };


  Widget generateDefault12GongRing(double innerSize, double outerSize,
      Map<EnumTwelveGong, List<String>> mapper, ZhouTianModel zhouTianModel) {
    return Normal12GongRing(
      outerRadius: outerSize,
      innerRadius: innerSize,
      baseGongOffsetAngle: 2 * 30,
      shenShaMapper: mapper,
      zhouTianModel: zhouTianModel,
    );
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
