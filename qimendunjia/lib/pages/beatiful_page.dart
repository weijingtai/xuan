import 'dart:math';
import 'dart:ui';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:common/widgets/four_zhu_eight_char.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:common/adapters/lunar_adapter.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/model/each_gong.dart';
import 'package:qimendunjia/model/eight_door_ke_ying.dart';
import 'package:qimendunjia/utils/constant_resources_of_qi_men.dart';
import 'package:qimendunjia/utils/constant_ui_resources_of_qi_men.dart';
import 'package:qimendunjia/utils/read_data_utils.dart';
import 'package:qimendunjia/widgets/ten_gan_ke_ying_ge_ju_detail.dart';
import 'package:slide_switcher/slide_switcher.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_arrange_plate_type.dart';
import '../enums/enum_most_popular_ge_ju.dart';
import '../enums/enum_nine_stars.dart';
import '../model/shi_jia_ju.dart';
import '../model/door_star_ke_ying.dart';
import '../model/pan_arrange_settings.dart';
import '../model/qi_yi_ru_gong.dart';
import '../model/shi_jia_qi_men.dart';
import '../model/ten_gan_ke_ying.dart';
import '../model/ten_gan_ke_ying_ge_ju.dart';
import '../ui_models/ui_ten_gan_key_ying_ge_ju.dart';
import '../utils/qi_men_ju_calculator.dart';
import '../widgets/each_gong_widget.dart';

class BeautifulPage extends StatefulWidget {
  DateTime? panDateTime;
  BeautifulPage({super.key, this.panDateTime});

  @override
  State<BeautifulPage> createState() => _BeautifulPageState();
}

class _BeautifulPageState extends State<BeautifulPage>
    with TickerProviderStateMixin {
  double baseEachGongSize = 256;
  Offset panOffset = const Offset(0, 0);
  Size panSize = const Size(816, 816);
  double eachPaddingSize = 8;

  Map<HouTianGua, UITenGanKeYingGeJu> geJuMapper = {};
  final GlobalKey appBarGlobalKey = GlobalKey();
  final GlobalKey panelGlobalKey = GlobalKey();

  GlobalKey yearGanZhiShakeKey = GlobalKey<ShakeWidgetState>();
  GlobalKey monthGanZhiShakeKey = GlobalKey<ShakeWidgetState>();
  GlobalKey dayGanZhiShakeKey = GlobalKey<ShakeWidgetState>();
  GlobalKey timeGanZhiShakeKey = GlobalKey<ShakeWidgetState>();
  GlobalKey dunGanZhiShakeKey = GlobalKey<ShakeWidgetState>();

  late final ValueNotifier<bool> showHintNotifier = ValueNotifier(true);

  late final ValueNotifier<DateTime?> dateTimeValueNotifier;
  late final ValueNotifier<ShiJiaQiMen?> shiJiaZhuanPanQiMenValueNotifier;
  final ValueNotifier<Map<HouTianGua, Widget>?> guaGongMapperNotifier =
      ValueNotifier(null);
  // final ValueNotifier<HouTianGua?> showGongGuaNotifier= ValueNotifier(null);
  final ValueNotifier<Tuple3<Offset, MapEntry<HouTianGua, EachGong>, Widget>?>
      selectedGongWidgetNotifier = ValueNotifier(null);

  final ValueNotifier<double> widthNotifier = ValueNotifier(360);
  final ValueNotifier<CenterGongJiGongType> jiGongHintNotifier =
      ValueNotifier(CenterGongJiGongType.ONLY_KUN_GONG);
  final ValueNotifier<MonthTokenTypeEnum> monthTokenTypeNotifier =
      ValueNotifier(MonthTokenTypeEnum.ZHU_QI);
  final ValueNotifier<GodWithGongTypeEnum> godWithGongTypeNotifier =
      ValueNotifier(GodWithGongTypeEnum.GONG_GUA_ONLY);
  final ValueNotifier<GongTypeEnum> starGongTypeNotifier =
      ValueNotifier(GongTypeEnum.GONG_GUA);
  final ValueNotifier<GongTypeEnum> doorGongTypeNotifier =
      ValueNotifier(GongTypeEnum.GONG_GUA);
  final ValueNotifier<GanGongTypeEnum> ganGongTypeNotifier =
      ValueNotifier(GanGongTypeEnum.WANG_MU);
  final ValueNotifier<ArrangeType> arrangeTypeNotifier =
      ValueNotifier(ArrangeType.CHAI_BU);
  final ValueNotifier<PlateType> plateTypeNotifier =
      ValueNotifier(PlateType.ZHUAN_PAN);

  late final AnimationController _panScaleController;

  TextStyle get twelveDiZhiTextStyle =>
      ConstantUiResourcesOfQiMen.twelveDiZhiTextStyle;
  TextStyle get tianGanTextStyle => ConstantUiResourcesOfQiMen.tianGanTextStyle;
  TextStyle get eightDoorTextStyle =>
      ConstantUiResourcesOfQiMen.eightDoorTextStyle;
  TextStyle get nineStarTextStyle =>
      ConstantUiResourcesOfQiMen.nineStarTextStyle;
  TextStyle get menHuLuFangStyle => ConstantUiResourcesOfQiMen.menHuLuFangStyle;
  TextStyle get panInfoTextStyle => ConstantUiResourcesOfQiMen.panInfoTextStyle;

  TextStyle switcherInactivatedStyle =
      const TextStyle(fontSize: 16, color: Color(0xff636f7b), height: 1.0);
  TextStyle baseActivatedStyle = TextStyle(
      fontSize: 16,
      color: const Color(0xff636f7b),
      height: 1.0,
      fontWeight: FontWeight.w500,
      shadows: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 2.0,
          spreadRadius: 1.0,
        )
      ]);
  TextStyle get zhuanPanActivatedStyle {
    return baseActivatedStyle.copyWith(color: const Color(0xff6682c0));
  }

  TextStyle get feiPanActivatedStyle {
    return baseActivatedStyle.copyWith(color: const Color(0xffdc6c73));
  }

  TextStyle get switcherActivatedStyle {
    return plateTypeNotifier.value == PlateType.ZHUAN_PAN
        ? zhuanPanActivatedStyle
        : feiPanActivatedStyle;
  }

  BoxDecoration cardDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(.2), blurRadius: 5, spreadRadius: 5),
      ]);
  ValueNotifier<DateTime?> selectedDateTimeNotifier =
      ValueNotifier(DateTime.now());

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _panScaleController = AnimationController(vsync: this);

    if (widget.panDateTime != null) {
      dateTimeValueNotifier = ValueNotifier(widget.panDateTime);
      shiJiaZhuanPanQiMenValueNotifier =
          ValueNotifier(create(widget.panDateTime!));
      createPanByEachGongWidget(shiJiaZhuanPanQiMenValueNotifier.value!)
          .then((gongMapper) {
        guaGongMapperNotifier.value = gongMapper;
      });
    } else {
      dateTimeValueNotifier = ValueNotifier(null);
      shiJiaZhuanPanQiMenValueNotifier = ValueNotifier(null);
      guaGongMapperNotifier.value = null;
    }
    dateTimeValueNotifier.addListener(() {
      if (dateTimeValueNotifier.value != null) {
        shiJiaZhuanPanQiMenValueNotifier.value =
            create(dateTimeValueNotifier.value!);
      } else {
        if (shiJiaZhuanPanQiMenValueNotifier.value != null) {
          shiJiaZhuanPanQiMenValueNotifier.value = null;
        }
      }
    });
    shiJiaZhuanPanQiMenValueNotifier.addListener(() {
      if (shiJiaZhuanPanQiMenValueNotifier.value != null) {
        createPanByEachGongWidget(shiJiaZhuanPanQiMenValueNotifier.value!)
            .then((gongMapper) {
          guaGongMapperNotifier.value = gongMapper;
        });
      } else {
        guaGongMapperNotifier.value = null;
      }
    });
    selectedGongWidgetNotifier.addListener(() {
      if (selectedGongWidgetNotifier.value != null) {
        _panScaleController.forward();
      } else {
        _panScaleController.reverse();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final RenderBox renderPan =
            panelGlobalKey.currentContext!.findRenderObject() as RenderBox;
        final RenderBox appBarRender =
            appBarGlobalKey.currentContext!.findRenderObject() as RenderBox;
        panOffset =
            renderPan.localToGlobal(Offset(0, -appBarRender.size.height));
      });
    });
  }

  Future<Map<HouTianGua, Widget>> createPanByEachGongWidget(
      ShiJiaQiMen pan) async {
    geJuMapper = await loadTenGanKeYingGeJu(
        pan.plateType, pan.xunHeaderTianGan, pan.zhiFuGan, pan.gongMapper);
    Map<HouTianGua, Widget> result = {};
    print("~~!!!!!!! ${geJuMapper.containsKey(HouTianGua.Center)}");
    print(
        "~~!!!!!!! ${shiJiaZhuanPanQiMenValueNotifier.value!.gongMapper.containsKey(HouTianGua.Center)}");
    for (HouTianGua gua in HouTianGua.values) {
      if (pan.plateType == PlateType.ZHUAN_PAN && gua == HouTianGua.Center) {
        continue;
      }

      result[gua] = buildEachGong(
          gua, shiJiaZhuanPanQiMenValueNotifier.value!, geJuMapper[gua]!);
    }
    return result;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dateTimeValueNotifier.dispose();
    shiJiaZhuanPanQiMenValueNotifier.dispose();
    guaGongMapperNotifier.dispose();
    // showGongGuaNotifier.dispose();
    selectedGongWidgetNotifier.dispose();

    _panScaleController.dispose();
    jiGongHintNotifier.dispose();
    starGongTypeNotifier.dispose();
    doorGongTypeNotifier.dispose();
    ganGongTypeNotifier.dispose();
    monthTokenTypeNotifier.dispose();
    godWithGongTypeNotifier.dispose();
    arrangeTypeNotifier.dispose();
    plateTypeNotifier.dispose();

    selectedDateTimeNotifier.dispose();
    widthNotifier.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          key: appBarGlobalKey,
          // title: Text("奇门遁甲"),
          title: ValueListenableBuilder(
            valueListenable: shiJiaZhuanPanQiMenValueNotifier,
            builder: (ctx, pan, child) {
              if (pan == null) {
                return const Text("奇门遁甲");
              }
              return Text(
                  "转盘·${pan.arrangeType.name} ${pan.yinYangDun.isYin ? "阴" : "阳"}${ConstResourcesMapper.chineseNumberMapper[pan.juNumber]}局",
                  style: panInfoTextStyle);
            },
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton(
              onSelected: (String item) {
                switch (item) {
                  case "showhHint":
                    showHintNotifier.value = !showHintNotifier.value;
                    break;
                }
              },
              itemBuilder: (ctx) {
                return [
                  const PopupMenuItem<String>(
                    value: "showhHint",
                    child: Text('显示提示'),
                  ),
                ];
              },
            )
          ]),
      // body: SingleChildScrollView(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPanGeJu(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 120,
                      child: ValueListenableBuilder<DateTime?>(
                          valueListenable: dateTimeValueNotifier,
                          // builder: (ctx, dateTime, child) => dateTime != null ? Text(DateFormat("yyyy-MM-dd HH:mm").format(dateTime!)):child!,
                          builder: (ctx, dateTime, child) => dateTime != null
                              ? buildCenterPanTime(dateTime)
                              : child!,
                          child: const SizedBox()),
                    ),
                    IntrinsicHeight(
                      child: SizedBox(
                        width: 240,
                        height: 160,
                        // padding: EdgeInsets.symmetric(vertical: 8,horizontal: 12),
                        child: ValueListenableBuilder<ShiJiaQiMen?>(
                            valueListenable: shiJiaZhuanPanQiMenValueNotifier,
                            // builder: (ctx, dateTime, child) => dateTime != null ? Text(DateFormat("yyyy-MM-dd HH:mm").format(dateTime!)):child!,
                            builder: (ctx, pan, child) =>
                                pan != null ? buildPanInfo(pan) : child!,
                            child: const SizedBox()),
                      ),
                    ),
                    SizedBox(
                      width: 260,
                      height: 150,
                      child: ValueListenableBuilder<ShiJiaQiMen?>(
                          valueListenable: shiJiaZhuanPanQiMenValueNotifier,
                          // builder: (ctx, dateTime, child) => dateTime != null ? Text(DateFormat("yyyy-MM-dd HH:mm").format(dateTime!)):child!,
                          builder: (ctx, pan, child) =>
                              pan != null ? buildCenterFourZhu(pan) : child!,
                          child: const SizedBox()),
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ...tianMenDiHuaRenMenGuiLu(),
                    Container(
                        width: panSize.width + 36,
                        height: panSize.height + 36,
                        alignment: Alignment.center,
                        child: ValueListenableBuilder(
                          valueListenable: guaGongMapperNotifier,
                          child: buildCreatePan(),
                          builder: (ctx, guaGongMapper, child) {
                            if (guaGongMapper == null) {
                              return child!;
                            }
                            // return buildPanel(guaGongMapper);
                            return ValueListenableBuilder(
                                valueListenable: selectedGongWidgetNotifier,
                                builder: (ctx, gong, child) {
                                  return buildPanel(guaGongMapper);
                                });
                          },
                        )),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (dateTimeValueNotifier.value == null) {
                          if (arrangeTypeNotifier.value ==
                              ArrangeType.MANUALLY) {
                            if ([
                              yearJiaZi,
                              monthJiaZi,
                              dayJiaZi,
                              timeJiaZi,
                              yinYangDun
                            ].any((e) => e == null)) {
                              if (yearJiaZi == null) {
                                (yearGanZhiShakeKey.currentState!
                                        as ShakeWidgetState)
                                    .shake();
                              }
                              if (monthJiaZi == null) {
                                (monthGanZhiShakeKey.currentState!
                                        as ShakeWidgetState)
                                    .shake();
                              }
                              if (dayJiaZi == null) {
                                (dayGanZhiShakeKey.currentState!
                                        as ShakeWidgetState)
                                    .shake();
                              }
                              if (timeJiaZi == null) {
                                (timeGanZhiShakeKey.currentState!
                                        as ShakeWidgetState)
                                    .shake();
                              }
                              if (yinYangDun == null) {
                                (dunGanZhiShakeKey.currentState!
                                        as ShakeWidgetState)
                                    .shake();
                              }
                            } else {
                              shiJiaZhuanPanQiMenValueNotifier.value =
                                  create(DateTime.now());
                            }
                          } else {
                            selectedDateTimeNotifier.value ??= DateTime.now();
                            dateTimeValueNotifier.value =
                                selectedDateTimeNotifier.value;
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .white, // Background coloronPrimary: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15), // Padding
                        textStyle: const TextStyle(
                            fontSize: 18, color: Colors.black87), // Text style
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                      ),
                      child: const Text('排盘'),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (dateTimeValueNotifier.value != null) {
                          selectedDateTimeNotifier.value = null;
                          dateTimeValueNotifier.value = null;
                          shiJiaZhuanPanQiMenValueNotifier.value = null;
                          geJuMapper = {};
                          yearJiaZi = null;
                          monthJiaZi = null;
                          dayJiaZi = null;
                          timeJiaZi = null;
                          yinYangDun = null;
                          juNumber = null;
                          jieQi = null;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .white, // Background coloronPrimary: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15), // Padding
                        textStyle: const TextStyle(
                            fontSize: 18, color: Colors.red), // Text style
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                      ),
                      child: const Text('清除'),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    selectDateTimeButton()
                  ],
                ),
                const SizedBox(
                  height: 56,
                )
              ],
            )),
          ),
          ValueListenableBuilder(
              valueListenable: selectedGongWidgetNotifier,
              builder: (ctx, popup, child) {
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: popup == null
                      ? Container()
                      : GestureDetector(
                          onDoubleTap: () {
                            selectedGongWidgetNotifier.value = null;
                            // showGongGuaNotifier.value = null;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.2), // Adjust opacity as needed
                              borderRadius: BorderRadius.circular(
                                  10), // Optional rounded corners
                            ),
                          ),
                        ),
                )
                    .animate(controller: _panScaleController, autoPlay: false)
                    .fadeIn(
                        delay: const Duration(milliseconds: 100),
                        duration: const Duration(milliseconds: 200));
              }),
          ValueListenableBuilder(
              valueListenable: selectedGongWidgetNotifier,
              builder: (ctx, popupGongWidget, child) {
                if (popupGongWidget == null) {
                  return Container();
                }
                HouTianGua gua = popupGongWidget.item2.key;
                EachGong gong = popupGongWidget.item2.value;
                double offsetY = (panOffset.dy + panSize.width / 5) -
                    popupGongWidget.item1.dy;
                double offsetX = (panOffset.dx + panSize.height / 5) -
                    popupGongWidget.item1.dx;
                return Positioned(
                        left: popupGongWidget.item1.dx,
                        top: popupGongWidget.item1.dy,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: getGongBackgroundColor(
                                        popupGongWidget.item2.key),
                                    borderRadius: BorderRadius.circular(36),
                                  ),
                                  child: popupGongWidget.item3,
                                ).animate(onComplete: (ctrl) {
                                  _panScaleController.forward();
                                }).boxShadow(
                                  duration: const Duration(milliseconds: 200),
                                  borderRadius: BorderRadius.circular(36),
                                  begin: BoxShadow(
                                      color: Colors.grey.withOpacity(0),
                                      blurRadius: 0,
                                      spreadRadius: 0),
                                  end: BoxShadow(
                                      color: Colors.grey.withOpacity(.2),
                                      blurRadius: 4,
                                      spreadRadius: 4),
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                SizedBox(
                                  width: baseEachGongSize,
                                  // margin: EdgeInsets.fromLTRB(0, 24, 0, 0),
                                  child: FutureBuilder(
                                    future: loadDoorStarKeYing(
                                        gong.door, gong.star),
                                    builder: (context,
                                        AsyncSnapshot<DoorStarKeYing?>
                                            snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data == null) {
                                          return Container();
                                        }
                                        return IntrinsicHeight(
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: cardDecoration,
                                            child: buildDoorStarKeYing(
                                                snapshot.data!),
                                          ),
                                        );
                                      } else {
                                        return const Text("加载中...");
                                      }
                                    },
                                  ),
                                )
                                    .animate()
                                    .moveY(
                                        delay:
                                            const Duration(milliseconds: 800),
                                        curve: Curves.easeInOutQuint,
                                        duration:
                                            const Duration(milliseconds: 400),
                                        begin: -128,
                                        end: 0)
                                    .fadeIn(
                                        delay:
                                            const Duration(milliseconds: 800),
                                        curve: Curves.easeInOutQuint,
                                        duration:
                                            const Duration(milliseconds: 400),
                                        begin: 0),
                                const SizedBox(
                                  height: 24,
                                ),
                                SizedBox(
                                  width: 256,
                                  child: FutureBuilder(
                                    future: loadEightDoorKeYing(
                                        gong.door,
                                        ConstantResourcesOfQiMen
                                            .defaultGongMapper[gua]!
                                            .defaultDoor),
                                    builder: (context,
                                        AsyncSnapshot<
                                                Map<YinYang, EightDoorKeYing>?>
                                            snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data == null) {
                                          return Container();
                                        }
                                        return IntrinsicHeight(
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: cardDecoration,
                                            child: buildEightDoorKeYing(
                                                snapshot.data!),
                                          ),
                                        );
                                      } else {
                                        return const Text("加载中...");
                                      }
                                    },
                                  ),
                                )
                                    .animate()
                                    .moveY(
                                        delay:
                                            const Duration(milliseconds: 1000),
                                        curve: Curves.easeInOutQuint,
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        begin: 128,
                                        end: 0)
                                    .fadeIn(
                                        delay:
                                            const Duration(milliseconds: 800),
                                        curve: Curves.easeInOutQuint,
                                        duration:
                                            const Duration(milliseconds: 400),
                                        begin: 0),
                                const SizedBox(
                                  height: 24,
                                ),
                                AnimatedContainer(
                                  alignment: Alignment.topCenter,
                                  duration: const Duration(milliseconds: 400),
                                  width: 256,
                                  // margin: EdgeInsets.fromLTRB(24, 0, 24, 24),
                                  child: FutureBuilder(
                                    future: loadEightDoorGanKeYing(
                                        gong.door, gong.tianPan),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String?> snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data == null) {
                                          return Container();
                                        }
                                        return IntrinsicHeight(
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: cardDecoration,
                                            child: buildDoorGan(
                                                gong.gongGua,
                                                gong.tianPan,
                                                gong.door,
                                                snapshot.data),
                                          ),
                                        );
                                      } else {
                                        return const Text("加载中...");
                                      }
                                    },
                                  ),
                                )
                                    .animate()
                                    .moveY(
                                        delay:
                                            const Duration(milliseconds: 800),
                                        curve: Curves.easeInOutQuint,
                                        duration:
                                            const Duration(milliseconds: 400),
                                        begin: -128,
                                        end: 0)
                                    .fadeIn(
                                        delay:
                                            const Duration(milliseconds: 800),
                                        curve: Curves.easeInOutQuint,
                                        duration:
                                            const Duration(milliseconds: 400),
                                        begin: 0),
                                const SizedBox(
                                  height: 24,
                                ),
                                AnimatedContainer(
                                  alignment: Alignment.topCenter,
                                  duration: const Duration(milliseconds: 400),
                                  width: 256,
                                  child: FutureBuilder(
                                    future: Future.wait([
                                      loadThreeQiRuGong(
                                          gong.gongGua, gong.tianPan),
                                      loadTianPanGanRuGong(
                                          gong.gongGua, gong.tianPan),
                                    ]),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<List<dynamic>?>
                                            snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data?[0] == null &&
                                            snapshot.data?[1] == null) {
                                          return Container();
                                        }
                                        return IntrinsicHeight(
                                          child: Container(
                                            width: 256,
                                            padding: const EdgeInsets.all(12),
                                            // margin: EdgeInsets.fromLTRB(24, 0, 24, 24),
                                            decoration: cardDecoration,
                                            child: buildQiYiRuGong(
                                                gong.gongGua,
                                                gong.tianPan,
                                                snapshot.data?[0],
                                                snapshot.data?[1]),
                                          ),
                                        );
                                      } else {
                                        return const Text("加载中...");
                                      }
                                    },
                                  ),
                                )
                                    .animate()
                                    .moveX(
                                        delay:
                                            const Duration(milliseconds: 800),
                                        curve: Curves.easeInOutQuint,
                                        duration:
                                            const Duration(milliseconds: 400),
                                        begin: 128,
                                        end: 0)
                                    .fadeIn(
                                        delay:
                                            const Duration(milliseconds: 800),
                                        curve: Curves.easeInOutQuint,
                                        duration:
                                            const Duration(milliseconds: 400),
                                        begin: 0),
                              ],
                            ),
                            SizedBox(
                              width: 500,
                              child: Scrollbar(
                                controller: _scrollController,
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FutureBuilder(
                                          future: loadTenGanKeyYing(context,
                                              gong.tianPan, gong.diPan),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<TenGanKeYing?>
                                                  snapshot) {
                                            if (snapshot.hasData) {
                                              if (snapshot.data != null) {
                                                return buildNewExplainList(
                                                    snapshot.data!,
                                                    geJuMapper[gong.gongGua]!
                                                        .tianGeJu);
                                              } else {
                                                return const Center(
                                                    child: Text("未找到"));
                                              }
                                            } else {
                                              return const Center(
                                                  child: Text("加载中..."));
                                            }
                                          },
                                        ),
                                        if (gong.tianPanJiGan != null &&
                                            gong.tianPanJiGan ==
                                                gong.diPanJiGan)
                                          FutureBuilder(
                                            future: loadTenGanKeyYing(
                                                context,
                                                gong.tianPanJiGan!,
                                                gong.diPanJiGan!),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<TenGanKeYing?>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                if (snapshot.data != null) {
                                                  return buildNewExplainList(
                                                      snapshot.data!,
                                                      geJuMapper[gong.gongGua]!
                                                          .tianDiJiGanGeJu!);
                                                } else {
                                                  return const Center(
                                                      child: Text("未找到"));
                                                }
                                              } else {
                                                return const Center(
                                                    child: Text("加载中..."));
                                              }
                                            },
                                          ),
                                        if (gong.tianPanJiGan != null &&
                                            gong.diPanJiGan == null)
                                          FutureBuilder(
                                            future: loadTenGanKeyYing(context,
                                                gong.tianPanJiGan!, gong.diPan),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<TenGanKeYing?>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                if (snapshot.data != null) {
                                                  return buildNewExplainList(
                                                      snapshot.data!,
                                                      geJuMapper[gong.gongGua]!
                                                          .tianPanJiGanGeJu!);
                                                } else {
                                                  return const Center(
                                                      child: Text("未找到"));
                                                }
                                              } else {
                                                return const Center(
                                                    child: Text("加载中..."));
                                              }
                                            },
                                          ),
                                        if (gong.tianPanJiGan == null &&
                                            gong.diPanJiGan != null)
                                          FutureBuilder(
                                            future: loadTenGanKeyYing(context,
                                                gong.tianPan, gong.diPanJiGan!),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<TenGanKeYing?>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                if (snapshot.data != null) {
                                                  return buildNewExplainList(
                                                      snapshot.data!,
                                                      geJuMapper[gong.gongGua]!
                                                          .diPanJiGanGeJu!);
                                                } else {
                                                  return const Center(
                                                      child: Text("未找到"));
                                                }
                                              } else {
                                                return const Center(
                                                    child: Text("加载中..."));
                                              }
                                            },
                                          ),
                                        buildExplainList2(
                                            gua,
                                            gong,
                                            shiJiaZhuanPanQiMenValueNotifier
                                                .value!.xunHeaderTianGan,
                                            popupGongWidget.item2.value.door),
                                      ]),
                                ),
                              ),
                            )
                          ],
                        ))
                    .animate()
                    .move(
                        delay: const Duration(milliseconds: 250),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCirc,
                        begin: Offset.zero,
                        end: Offset(offsetX, offsetY));
              }),
        ],
      )
          .animate(controller: _panScaleController, autoPlay: false)
          .scale(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear,
              begin: const Offset(1, 1),
              end: const Offset(.99, .99))
          .move(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear,
              begin: const Offset(0, 0),
              end: const Offset(-2, -2)),
      // ),
    );
  }

  // void createPanel(ShiJiaZhuanPanQiMen pan){
  //
  //   shiJiaZhuanPanQiMenValueNotifier.value = pan;
  //   Map<HouTianGua,Widget> gongWidgetMapper = Map.fromEntries(HouTianGua.values.map((g)=>MapEntry(g, buildEachGong(g,pan))));
  //   guaGongMapperNotifier.value = gongWidgetMapper;
  // }
  Widget buildPanGeJu() {
    return ValueListenableBuilder(
        valueListenable: shiJiaZhuanPanQiMenValueNotifier,
        builder: (ctx, pan, child) {
          List<Widget> list = [];
          if (pan != null) {
            if (EnumMostPopularGeJu.isTianXianShiGe(
                    pan.dayJiaZi, pan.timeJiaZi) !=
                null) {
              list.add(const GeJuPanelTemplateJi1(
                  name: "天显时格",
                  backgroundColor: Color.fromRGBO(32, 50, 54, 1),
                  foregroundColor: Color.fromRGBO(209, 181, 146, 1)));
            }
            if (EnumMostPopularGeJu.isTianFuJiShi(
                    pan.dayJiaZi, pan.timeJiaZi) !=
                null) {
              if (list.isNotEmpty) {
                list.add(const SizedBox(
                  width: 12,
                ));
              }
              list.add(const GeJuPanelTemplateJi1(
                  name: "天辅吉时",
                  backgroundColor: Color.fromRGBO(25, 44, 59, 1),
                  foregroundColor: Color.fromRGBO(176, 132, 88, 1)));
            }
            if (EnumMostPopularGeJu.isYuNvShouMenByTimeJiaZi(pan.timeJiaZi) !=
                null) {
              if (list.isNotEmpty) {
                list.add(const SizedBox(
                  width: 12,
                ));
              }
              list.add(const GeJuPanelTemplateJi1(
                  name: "玉女守门",
                  backgroundColor: Color.fromRGBO(25, 44, 59, 1),
                  foregroundColor: Color.fromRGBO(176, 132, 88, 1)));
            }
            if (EnumMostPopularGeJu.isWuBuYuShi(pan.dayJiaZi, pan.timeJiaZi) !=
                null) {
              if (list.isNotEmpty) {
                list.add(const SizedBox(
                  width: 12,
                ));
              }
              list.add(const GeJuPanelTemplateXiong1(
                name: "五不遇时",
                backgroundColor: Color.fromRGBO(130, 78, 64, 1),
                foregroundColor: Color.fromRGBO(88, 15, 5, 1),
                size: Size(180, 42),
              ));
            }
          }
          return SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: list,
            ),
          );
        });
  }

  List<Widget> tianMenDiHuaRenMenGuiLu() {
    return [
      Positioned(
        top: 0,
        left: 0,
        child: Transform.rotate(
          angle: (315) * (pi / 180),
          child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              child: Text(
                "地户",
                style: menHuLuFangStyle,
              )),
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Transform.rotate(
          angle: (45) * (pi / 180),
          child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              child: Text(
                "人路",
                style: menHuLuFangStyle,
              )),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Transform.rotate(
          angle: (45) * (pi / 180),
          child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              child: Text(
                "鬼方",
                style: menHuLuFangStyle,
              )),
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Transform.rotate(
          angle: 315 * (pi / 180),
          child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              child: Text(
                "天门",
                style: menHuLuFangStyle,
              )),
        ),
      ),
    ];
  }

  JiaZi? yearJiaZi;
  JiaZi? monthJiaZi;
  JiaZi? dayJiaZi;
  JiaZi? timeJiaZi;
  YinYang? yinYangDun;
  int? juNumber;
  TwentyFourJieQi? jieQi;

  Color getTianGanColor(TianGan tianGan) {
    return ConstResourcesMapper.zodiacGanColors[tianGan]!;
  }
  // loadAllExplain() async {
  //   var allExplain = await Future.wait([
  //     ReadDataUtils.readDoorStarKeYing(),
  //     ReadDataUtils.readDoorGanKeYing(),
  //     ReadDataUtils.readTenGanKeYing(),
  //     ReadDataUtils.readEightDoorKeYing()
  //   ]);
  // }

  ///list.length 为 2 或者为 3是
  Future<Map<HouTianGua, UITenGanKeYingGeJu>> loadTenGanKeYingGeJu(
      PlateType plateType,
      TianGan xunShouGan,
      TianGan zhiFuGan,
      Map<HouTianGua, EachGong> gong) async {
    Map<TianGan, Map<TianGan, TenGanKeYingGeJu>> loadResult =
        await ReadDataUtils.readTenGanKeYingGeJu();
    Map<HouTianGua, UITenGanKeYingGeJu> result = {};
    for (var entry in gong.entries) {
      if (plateType == PlateType.ZHUAN_PAN && entry.key == HouTianGua.Center) {
        continue;
      }
      TenGanKeYingGeJu tianGeJu =
          loadResult[entry.value.tianPan]![entry.value.diPan]!;
      TenGanKeYingGeJu? tianDunJiaGeJu;
      if (entry.value.tianPan == xunShouGan) {
        tianDunJiaGeJu = loadResult[TianGan.JIA]![entry.value.diPan]!;
      }
      TenGanKeYingGeJu? diDunJiaGeJu;
      if (entry.value.diPan == xunShouGan) {
        diDunJiaGeJu = loadResult[entry.value.tianPan]![TianGan.JIA]!;
      }
      TenGanKeYingGeJu? diPanJiGeJu;
      TenGanKeYingGeJu? diPanJiJiaGeJu;
      TenGanKeYingGeJu? tianDunJiaDiPanJi;
      if (entry.value.diPanJiGan != null) {
        diPanJiGeJu = loadResult[entry.value.tianPan]![entry.value.diPanJiGan]!;
        if (entry.value.diPanJiGan == xunShouGan) {
          diPanJiJiaGeJu = loadResult[entry.value.tianPan]![TianGan.JIA]!;
        }
        if (entry.value.tianPan == xunShouGan) {
          tianDunJiaDiPanJi = loadResult[TianGan.JIA]![entry.value.diPanJiGan]!;
        }
      }
      TenGanKeYingGeJu? tianPanJiGeJu;
      TenGanKeYingGeJu? tianPanJiJiaGeJu;
      TenGanKeYingGeJu? tianPanJiGanDiPanJia;
      if (entry.value.tianPanJiGan != null) {
        tianPanJiGeJu =
            loadResult[entry.value.tianPanJiGan]![entry.value.diPan]!;
        if (entry.value.tianPanJiGan == xunShouGan) {
          tianPanJiJiaGeJu = loadResult[TianGan.JIA]![entry.value.diPan]!;
        }
        if (entry.value.diPan == xunShouGan) {
          tianPanJiGanDiPanJia =
              loadResult[entry.value.tianPanJiGan]![TianGan.JIA]!;
        }
      }
      TenGanKeYingGeJu? tianDiPanJia; // 天地盘相同，且同为“遁干”
      if (entry.value.tianPan == entry.value.diPan &&
          entry.value.tianPan == xunShouGan) {
        tianDiPanJia = loadResult[TianGan.JIA]![TianGan.JIA]!;
      }
      TenGanKeYingGeJu? tianDiJiGan;
      TenGanKeYingGeJu? tianDiJiaGanJiaGeJu;
      // print("${entry.value.tianPanJiGan != null}=====${entry.value.tianPanJiGan == entry.value.diPanJiGan}");
      if (entry.value.tianPanJiGan != null &&
          entry.value.tianPanJiGan == entry.value.diPanJiGan) {
        tianDiJiGan =
            loadResult[entry.value.tianPanJiGan]![entry.value.diPanJiGan]!;
        if (entry.value.tianPanJiGan == xunShouGan) {
          tianDiJiaGanJiaGeJu = loadResult[TianGan.JIA]![TianGan.JIA]!;
        }
      }

      result[entry.key] = UITenGanKeYingGeJu(
          gongGua: entry.key,
          tianGan: entry.value.tianPan,
          tianGeJu: tianGeJu,
          diGan: entry.value.diPan,
          isTianGanDunJia: entry.value.tianPan == xunShouGan,
          isDiGanDunJia: entry.value.diPan == xunShouGan,
          tianDunJiaGeJu: tianDunJiaGeJu,
          diDunJiaGeJu: diDunJiaGeJu,
          tianPanJiGan: entry.value.tianPanJiGan,
          tianPanJiGanGeJu: tianPanJiGeJu,
          diPanJiGan: entry.value.diPanJiGan,
          diPanJiGanGeJu: diPanJiGeJu,
          isTianJiGanJia: entry.value.tianPanJiGan == xunShouGan,
          isDiJiGanJia: entry.value.diPanJiGan == xunShouGan,
          tianJiGanJiaGeJu: tianPanJiJiaGeJu,
          diJiGanJiaGeJu: diPanJiJiaGeJu,
          tianDiJiGanGeJu: tianDiJiGan,
          tianDiPanGanGeJu: tianDiPanJia,
          tianDiJiaGanJiaGeJu: tianDiJiaGanJiaGeJu,
          tianPanJiGanDiPanJia: tianPanJiGanDiPanJia,
          tianDunJiaDiPanJi: tianDunJiaDiPanJi);
    }

    return result;
  }

  Future<DoorStarKeYing?> loadDoorStarKeYing(
      EightDoorEnum door, NineStarsEnum star) async {
    Map<EightDoorEnum, Map<NineStarsEnum, DoorStarKeYing>> loadResult =
        await ReadDataUtils.readDoorStarKeYing();
    return loadResult[door]?[star];
  }

  Future<String?> loadEightDoorGanKeYing(
      EightDoorEnum door, TianGan tianPanGan) async {
    Map<EightDoorEnum, Map<TianGan, String>> loadResult =
        await ReadDataUtils.readDoorGanKeYing();
    return loadResult[door]?[tianPanGan];
  }

  Future<TenGanKeYing?> loadTenGanKeyYing(
      BuildContext context, TianGan tianPanGan, TianGan diPanGan) async {
    Map<TianGan, Map<TianGan, TenGanKeYing>> loadResult =
        await ReadDataUtils.readTenGanKeYing();
    // if (tianPanGan == TianGan.JIA && diPanGan == TianGan.BING){
    //   print(loadResult[tianPanGan]?[TianGan.BING]);
    // }
    return loadResult[tianPanGan]?[diPanGan];
  }

  Future<Map<YinYang, EightDoorKeYing>?> loadEightDoorKeYing(
      EightDoorEnum door, EightDoorEnum fixDoor) async {
    /// YinYang  阳为动应，阴为静应

    try {
      Map<EightDoorEnum, Map<EightDoorEnum, Map<YinYang, EightDoorKeYing>>>
          loadResult = await ReadDataUtils.readEightDoorKeYing();
      return loadResult[door]?[fixDoor];
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// 当前只有 三奇入宫
  Future<QiYiRuGong?> loadThreeQiRuGong(
      HouTianGua gongGua, TianGan tianPanGan) async {
    if ([TianGan.YI, TianGan.BING, TianGan.DING].contains(tianPanGan)) {
      Map<HouTianGua, Map<TianGan, QiYiRuGong>> qiYiRuGongMapper =
          await ReadDataUtils.readQiYiRuGong();
      return qiYiRuGongMapper[gongGua]![tianPanGan]!;
    }
    return null;
  }

  Future<String?> loadTianPanGanRuGong(
      HouTianGua gongGua, TianGan tianPanGan) async {
    Map<HouTianGua, Map<TianGan, String>> qiYiRuGongMapper =
        await ReadDataUtils.readQiYiRuGongDisease();
    return qiYiRuGongMapper[gongGua]?[tianPanGan];
  }

  Widget buildCreatePan() {
    // Size gongAtPanSize = Size(baseEachGongSize+eachPaddingSize*2, baseEachGongSize+eachPaddingSize*2);
    return Container(
        key: panelGlobalKey,
        width: panSize.width + 2,
        height: panSize.height + 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(1, 1), // changes position of shadow
              )
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 36,
            ),
            Center(
              child: ValueListenableBuilder(
                valueListenable: plateTypeNotifier,
                builder: (ctx, type, _) {
                  return SlideSwitcher(
                      onSelect: (index) {
                        switch (index) {
                          case 0:
                            plateTypeNotifier.value = PlateType.ZHUAN_PAN;
                            break;
                          case 1:
                            plateTypeNotifier.value = PlateType.FEI_PAN;
                            break;
                        }
                      },
                      containerHeight: 56,
                      containerWight: 240,
                      indents: 2,
                      containerColor: const Color(0xffe4e5eb),
                      slidersColors: const [
                        Color(0xfff7f5f7)
                      ],
                      containerBoxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 2,
                          spreadRadius: 4,
                        )
                      ],
                      children: [
                        AnimatedDefaultTextStyle(
                            style: type != PlateType.ZHUAN_PAN
                                ? baseActivatedStyle.copyWith(fontSize: 24)
                                : zhuanPanActivatedStyle.copyWith(fontSize: 24),
                            duration: const Duration(milliseconds: 200),
                            child: Text("${PlateType.ZHUAN_PAN.name}法")),
                        AnimatedDefaultTextStyle(
                            style: type != PlateType.FEI_PAN
                                ? baseActivatedStyle.copyWith(fontSize: 24)
                                : feiPanActivatedStyle.copyWith(fontSize: 24),
                            duration: const Duration(milliseconds: 200),
                            child: Text("${PlateType.FEI_PAN.name}法")),
                      ]);
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ValueListenableBuilder(
                valueListenable: arrangeTypeNotifier,
                builder: (ctx, arrangeType, _) {
                  return SlideSwitcher(
                      initialIndex: arrangeType.index,
                      onSelect: (index) {
                        arrangeTypeNotifier.value = ArrangeType.values[index];
                      },
                      containerHeight: 42,
                      containerWight: 350,
                      indents: 4,
                      containerColor: const Color(0xffe4e5eb),
                      slidersColors: const [Color(0xfff7f5f7)],
                      containerBoxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 2,
                          spreadRadius: 4,
                        )
                      ],
                      children: ArrangeType.values
                          .map((t) => AnimatedDefaultTextStyle(
                              style: arrangeType != t
                                  ? switcherInactivatedStyle
                                  : switcherActivatedStyle,
                              duration: const Duration(milliseconds: 200),
                              child: Text("${t.name}法")))
                          .toList());
                }),
            const SizedBox(
              height: 16,
            ),
            Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              width: 240,
                              child: const Text(
                                "中宫寄宫：",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black87),
                              ),
                            ),
                            ValueListenableBuilder(
                                valueListenable: jiGongHintNotifier,
                                builder: (ctx, cgg, _) {
                                  return SlideSwitcher(
                                      initialIndex: cgg.index,
                                      onSelect: (index) {
                                        jiGongHintNotifier.value =
                                            CenterGongJiGongType.values[index];
                                      },
                                      containerHeight: 36,
                                      containerWight: 240,
                                      indents: 4,
                                      containerColor: const Color(0xffe4e5eb),
                                      slidersColors: const [Color(0xfff7f5f7)],
                                      containerBoxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.4),
                                        )
                                      ],
                                      children: CenterGongJiGongType.values
                                          .map((t) => AnimatedDefaultTextStyle(
                                              style: cgg != t
                                                  ? switcherInactivatedStyle
                                                  : switcherActivatedStyle,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              child: Text(t.name)))
                                          .toList());
                                }),
                            Container(
                              alignment: Alignment.center,
                              width: 240,
                              child: ValueListenableBuilder(
                                  valueListenable: jiGongHintNotifier,
                                  builder: (ctx, hint, _) {
                                    return Text(
                                        ConstantResourcesOfQiMen
                                            .hitCenterGongJiGongMapper[hint]!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w300,
                                            height: 1.1));
                                  }),
                            )
                          ],
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        ValueListenableBuilder(
                            valueListenable: jiGongHintNotifier,
                            builder: (content, jiGong, _) =>
                                ValueListenableBuilder(
                                    valueListenable: arrangeTypeNotifier,
                                    builder: (ctx, arrangeType, _) {
                                      if (arrangeType == ArrangeType.MANUALLY &&
                                          [
                                            CenterGongJiGongType.FOUR_WEI_GONG,
                                            CenterGongJiGongType.EIGTH_GONG
                                          ].contains(jiGong)) {
                                        if (CenterGongJiGongType.EIGTH_GONG ==
                                            jiGong) {
                                          return SizedBox(
                                            width: 160,
                                            height: 48,
                                            child:
                                                CustomDropdown<String>.search(
                                              decoration:
                                                  CustomDropdownDecoration(
                                                closedShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.4),
                                                      spreadRadius: 1,
                                                      blurRadius: 2)
                                                ],
                                                expandedShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.4),
                                                      spreadRadius: 1,
                                                      blurRadius: 2)
                                                ],
                                              ),
                                              hintText: "八节",
                                              // initialItem: "甲子",
                                              items: const [
                                                "立春（艮）",
                                                "春分（震）",
                                                "立夏（巽）",
                                                "夏至（离）",
                                                "立秋（坤）",
                                                "秋分（兑）",
                                                "立冬（乾）",
                                                "冬至（坎）"
                                              ],
                                              onChanged: (eigthJie) {
                                                if (eigthJie != null) {
                                                  jieQi =
                                                      TwentyFourJieQi.fromName(
                                                          eigthJie.substring(
                                                              0, 2));
                                                } else {
                                                  jieQi = null;
                                                }
                                              },
                                            ),
                                          );
                                        } else {
                                          return SizedBox(
                                            width: 160,
                                            height: 48,
                                            child:
                                                CustomDropdown<String>.search(
                                              decoration: CustomDropdownDecoration(
                                                  closedShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.4),
                                                        spreadRadius: 1,
                                                        blurRadius: 2)
                                                  ],
                                                  expandedShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.4),
                                                        spreadRadius: 1,
                                                        blurRadius: 2)
                                                  ],
                                                  searchFieldDecoration:
                                                      const SearchFieldDecoration(
                                                          prefixIcon: null)),
                                              hintText: "四季",
                                              // initialItem: "甲子",
                                              items: const [
                                                "春（艮）",
                                                "夏（巽）",
                                                "秋（坤）",
                                                "冬（乾）"
                                              ],
                                              onChanged: (fourSeasons) {
                                                if (fourSeasons != null) {
                                                  switch (FourSeasons.fromName(
                                                      fourSeasons
                                                          .split("")
                                                          .first)) {
                                                    case FourSeasons.SPRING:
                                                      jieQi = TwentyFourJieQi
                                                          .LI_CHUN;
                                                      break;
                                                    case FourSeasons.SUMMER:
                                                      jieQi = TwentyFourJieQi
                                                          .LI_XIA;
                                                      break;
                                                    case FourSeasons.AUTUMN:
                                                      jieQi = TwentyFourJieQi
                                                          .LI_QIU;
                                                      break;
                                                    case FourSeasons.WINTER:
                                                      jieQi = TwentyFourJieQi
                                                          .LI_DONG;
                                                      break;
                                                    case FourSeasons.EARTH:
                                                      jieQi = null;
                                                    // throw UnimplementedError();
                                                  }
                                                } else {
                                                  jieQi = null;
                                                }
                                              },
                                            ),
                                          );
                                        }
                                      }
                                      return const SizedBox();
                                    }))
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 240,
                          child: const Text(
                            "月令旺衰取法：",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black87),
                          ),
                        ),
                        ValueListenableBuilder(
                            valueListenable: monthTokenTypeNotifier,
                            builder: (ctx, mt, _) {
                              return SlideSwitcher(
                                  initialIndex: mt.index,
                                  onSelect: (index) {
                                    monthTokenTypeNotifier.value =
                                        MonthTokenTypeEnum.values[index];
                                  },
                                  containerHeight: 36,
                                  containerWight: 240,
                                  indents: 4,
                                  containerColor: const Color(0xffe4e5eb),
                                  slidersColors: const [Color(0xfff7f5f7)],
                                  containerBoxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                    )
                                  ],
                                  children: MonthTokenTypeEnum.values
                                      .map((t) => AnimatedDefaultTextStyle(
                                          style: mt != t
                                              ? switcherInactivatedStyle
                                              : switcherActivatedStyle,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: Text(t.name)))
                                      .toList());
                            }),
                        Container(
                          alignment: Alignment.center,
                          width: 240,
                          child: ValueListenableBuilder(
                              valueListenable: monthTokenTypeNotifier,
                              builder: (ctx, hint, _) {
                                LunarAdapter lunar = LunarAdapter.fromDate(DateTime.now());
                                String monthTokenStr = lunar.getMonthZhi();
                                MonthToken monthToken =
                                    DiZhi.getFromValue(monthTokenStr)!
                                        .asMonthToken;
                                return RichText(
                                    text: TextSpan(
                                        text: ConstantResourcesOfQiMen
                                            .monthTokenHintMapper[hint]!,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w300,
                                            height: 1.1),
                                        children: [
                                      const TextSpan(text: "："),
                                      TextSpan(
                                          text: monthToken.diZhi.name,
                                          style: TextStyle(
                                              color: ConstResourcesMapper
                                                      .zodiacZhiColors[
                                                  monthToken.diZhi]!)),
                                      // TextSpan(text: "〔月令〕 → "),
                                      const TextSpan(text: " → "),
                                      TextSpan(
                                          text: monthToken.majorQi.name,
                                          style: TextStyle(
                                            color: ConstResourcesMapper
                                                    .zodiacGanColors[
                                                monthToken.majorQi]!,
                                            fontWeight: hint ==
                                                    MonthTokenTypeEnum
                                                        .ZHU_QI_NA_GUA
                                                ? FontWeight.w300
                                                : FontWeight.w500,
                                          )),
                                      // TextSpan(text:"〔主气〕"),
                                      hint == MonthTokenTypeEnum.ZHU_QI_NA_GUA
                                          ? const TextSpan(text: " → ")
                                          : const TextSpan(text: ""),
                                      hint == MonthTokenTypeEnum.ZHU_QI_NA_GUA
                                          ? TextSpan(
                                              text: monthToken.majorQi.naJiaGua,
                                              style: TextStyle(
                                                  color: ConstResourcesMapper
                                                          .zodiacGuaColors[
                                                      HouTianGua.getGuaByName(
                                                          monthToken.majorQi
                                                              .naJiaGua)]!,
                                                  fontWeight: FontWeight.w500))
                                          : const TextSpan(text: ""),
                                      // TextSpan(text:"〔纳卦〕"),
                                    ]));
                              }),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 240,
                          child: const Text(
                            "“神”与“宫”旺衰：",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black87),
                          ),
                        ),
                        ValueListenableBuilder(
                            valueListenable: godWithGongTypeNotifier,
                            builder: (ctx, ggt, _) {
                              return SlideSwitcher(
                                  initialIndex: ggt.index,
                                  onSelect: (index) {
                                    godWithGongTypeNotifier.value =
                                        GodWithGongTypeEnum.values[index];
                                  },
                                  containerHeight: 36,
                                  containerWight: 240,
                                  indents: 4,
                                  containerColor: const Color(0xffe4e5eb),
                                  slidersColors: const [Color(0xfff7f5f7)],
                                  containerBoxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                    )
                                  ],
                                  children: GodWithGongTypeEnum.values
                                      .map((e) => AnimatedDefaultTextStyle(
                                          style: ggt != e
                                              ? switcherInactivatedStyle
                                              : switcherActivatedStyle,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: Text(e.name)))
                                      .toList());
                            }),
                        Container(
                          alignment: Alignment.center,
                          width: 240,
                          child: ValueListenableBuilder(
                              valueListenable: godWithGongTypeNotifier,
                              builder: (ctx, hint, _) {
                                LunarAdapter lunar = LunarAdapter.fromDate(DateTime.now());
                                String monthTokenStr = lunar.getMonthZhi();
                                MonthToken monthToken =
                                    DiZhi.getFromValue(monthTokenStr)!
                                        .asMonthToken;
                                return RichText(
                                    text: TextSpan(
                                  text: ConstantResourcesOfQiMen
                                      .godWithGongTypeMapper[hint]!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w300,
                                      height: 1.1),
                                ));
                              }),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 240,
                          child: const Text(
                            "“星”与“宫”旺衰：",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black87),
                          ),
                        ),
                        ValueListenableBuilder(
                            valueListenable: starGongTypeNotifier,
                            builder: (ctx, gt, _) {
                              return SlideSwitcher(
                                  onSelect: (index) {
                                    starGongTypeNotifier.value =
                                        GongTypeEnum.values[index];
                                  },
                                  initialIndex: gt.index,
                                  containerHeight: 36,
                                  containerWight: 240,
                                  indents: 4,
                                  containerColor: const Color(0xffe4e5eb),
                                  slidersColors: const [Color(0xfff7f5f7)],
                                  containerBoxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                    )
                                  ],
                                  children: GongTypeEnum.values
                                      .map((e) => AnimatedDefaultTextStyle(
                                          style: gt != e
                                              ? switcherInactivatedStyle
                                              : switcherActivatedStyle,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: Text(e.name)))
                                      .toList());
                            }),
                        Container(
                          alignment: Alignment.center,
                          width: 240,
                          child: ValueListenableBuilder(
                              valueListenable: starGongTypeNotifier,
                              builder: (ctx, hint, _) {
                                LunarAdapter lunar = LunarAdapter.fromDate(DateTime.now());
                                String monthTokenStr = lunar.getMonthZhi();
                                MonthToken monthToken =
                                    DiZhi.getFromValue(monthTokenStr)!
                                        .asMonthToken;
                                return RichText(
                                    text: TextSpan(
                                  text: ConstantResourcesOfQiMen
                                      .gongTypeMapper[hint]!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w300,
                                      height: 1.1),
                                ));
                              }),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 240,
                          child: const Text(
                            "“门”与“宫”旺衰：",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black87),
                          ),
                        ),
                        ValueListenableBuilder(
                            valueListenable: doorGongTypeNotifier,
                            builder: (ctx, gt, _) {
                              return SlideSwitcher(
                                  onSelect: (index) {
                                    doorGongTypeNotifier.value =
                                        GongTypeEnum.values[index];
                                  },
                                  initialIndex: gt.index,
                                  containerHeight: 36,
                                  containerWight: 240,
                                  indents: 4,
                                  containerColor: const Color(0xffe4e5eb),
                                  slidersColors: const [Color(0xfff7f5f7)],
                                  containerBoxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                    )
                                  ],
                                  children: GongTypeEnum.values
                                      .map((e) => AnimatedDefaultTextStyle(
                                          style: gt != e
                                              ? switcherInactivatedStyle
                                              : switcherActivatedStyle,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: Text(e.name)))
                                      .toList());
                            }),
                        Container(
                          alignment: Alignment.center,
                          width: 240,
                          child: ValueListenableBuilder(
                              valueListenable: doorGongTypeNotifier,
                              builder: (ctx, hint, _) {
                                LunarAdapter lunar = LunarAdapter.fromDate(DateTime.now());
                                String monthTokenStr = lunar.getMonthZhi();
                                // MonthToken monthToken = DiZhi.getFromValue(monthTokenStr)!.toMonthToken;
                                return RichText(
                                    text: TextSpan(
                                  text: ConstantResourcesOfQiMen
                                      .gongTypeMapper[hint]!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w300,
                                      height: 1.1),
                                ));
                              }),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 240,
                          child: const Text(
                            "“干”与“宫”旺衰：",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black87),
                          ),
                        ),
                        ValueListenableBuilder(
                            valueListenable: ganGongTypeNotifier,
                            builder: (ctx, gt, _) {
                              return SlideSwitcher(
                                  onSelect: (index) {
                                    ganGongTypeNotifier.value =
                                        GanGongTypeEnum.values[index];
                                  },
                                  initialIndex: gt.index,
                                  containerHeight: 36,
                                  containerWight: 240,
                                  indents: 4,
                                  containerColor: const Color(0xffe4e5eb),
                                  slidersColors: const [Color(0xfff7f5f7)],
                                  containerBoxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.4),
                                    )
                                  ],
                                  children: GanGongTypeEnum.values
                                      .map((e) => AnimatedDefaultTextStyle(
                                          style: gt != e
                                              ? switcherInactivatedStyle
                                              : switcherActivatedStyle,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: Text(e.name)))
                                      .toList());
                            }),
                        Container(
                          alignment: Alignment.center,
                          width: 240,
                          child: ValueListenableBuilder(
                              valueListenable: ganGongTypeNotifier,
                              builder: (ctx, hint, _) {
                                LunarAdapter lunar = LunarAdapter.fromDate(DateTime.now());
                                String monthTokenStr = lunar.getMonthZhi();
                                // MonthToken monthToken = DiZhi.getFromValue(monthTokenStr)!.toMonthToken;
                                return RichText(
                                    text: TextSpan(
                                  text: ConstantResourcesOfQiMen
                                      .ganGongTypeMapper[hint]!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w300,
                                      height: 1.1),
                                ));
                              }),
                        )
                      ],
                    ),
                  ],
                )),
            const SizedBox(
              height: 16,
            ),
            ValueListenableBuilder(
                valueListenable: arrangeTypeNotifier,
                builder: (ctx, arrangeType, _) {
                  if (arrangeType == ArrangeType.MANUALLY) {
                    return manuallyJu();
                  }
                  return const SizedBox(
                    height: 48 + 32,
                  );
                })
          ],
        ));
  }

  Widget manuallyJu() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShakeMe(
            // 4. pass the GlobalKey as an argument
            key: yearGanZhiShakeKey,
            // 5. configure the animation parameters
            shakeCount: 3,
            shakeOffset: 10,
            shakeDuration: const Duration(milliseconds: 500),
            child: SizedBox(
              width: 128,
              height: 48,
              child: CustomDropdown<String>.search(
                decoration: CustomDropdownDecoration(
                    closedShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 2)
                    ],
                    expandedShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 2)
                    ],
                    searchFieldDecoration:
                        const SearchFieldDecoration(prefixIcon: null)),

                hintText: "年干支",
                // initialItem: "甲子",
                items: JiaZi.listAll.map((e) => e.name).toList(),
                onChanged: (jiaZiStr) {
                  if (jiaZiStr != null) {
                    yearJiaZi = JiaZi.getFromGanZhiValue(jiaZiStr);
                  } else {
                    yearJiaZi = null;
                  }
                },
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          ShakeMe(
            // 4. pass the GlobalKey as an argument
            key: monthGanZhiShakeKey,
            // 5. configure the animation parameters
            shakeCount: 3,
            shakeOffset: 10,
            shakeDuration: const Duration(milliseconds: 500),
            child: SizedBox(
              width: 128,
              height: 48,
              child: CustomDropdown<String>.search(
                decoration: CustomDropdownDecoration(
                    closedShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 2)
                    ],
                    expandedShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 2)
                    ],
                    searchFieldDecoration:
                        const SearchFieldDecoration(prefixIcon: null)),

                hintText: "月干支",
                // initialItem: "甲子",
                items: JiaZi.listAll.map((e) => e.name).toList(),
                onChanged: (jiaZiStr) {
                  if (jiaZiStr != null) {
                    monthJiaZi = JiaZi.getFromGanZhiValue(jiaZiStr);
                  } else {
                    monthJiaZi = null;
                  }
                },
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          ShakeMe(
            // 4. pass the GlobalKey as an argument
            key: dayGanZhiShakeKey,
            // 5. configure the animation parameters
            shakeCount: 3,
            shakeOffset: 10,
            shakeDuration: const Duration(milliseconds: 500),
            child: SizedBox(
              width: 128,
              height: 48,
              child: CustomDropdown<String>.search(
                decoration: CustomDropdownDecoration(
                    closedShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 2)
                    ],
                    expandedShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 2)
                    ],
                    searchFieldDecoration:
                        const SearchFieldDecoration(prefixIcon: null)),

                hintText: "日干支",
                // initialItem: "甲子",
                items: JiaZi.listAll.map((e) => e.name).toList(),
                onChanged: (jiaZiStr) {
                  if (jiaZiStr != null) {
                    dayJiaZi = JiaZi.getFromGanZhiValue(jiaZiStr);
                  } else {
                    dayJiaZi = null;
                  }
                },
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          ShakeMe(
            // 4. pass the GlobalKey as an argument
            key: timeGanZhiShakeKey,
            // 5. configure the animation parameters
            shakeCount: 3,
            shakeOffset: 10,
            shakeDuration: const Duration(milliseconds: 500),
            child: SizedBox(
              width: 128,
              height: 48,
              child: CustomDropdown<String>.search(
                decoration: CustomDropdownDecoration(
                    closedShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 2)
                    ],
                    expandedShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 2)
                    ],
                    searchFieldDecoration:
                        const SearchFieldDecoration(prefixIcon: null)),

                hintText: "时干支",
                // initialItem: "甲子",
                items: JiaZi.listAll.map((e) => e.name).toList(),
                onChanged: (jiaZiStr) {
                  if (jiaZiStr != null) {
                    timeJiaZi = JiaZi.getFromGanZhiValue(jiaZiStr);
                  } else {
                    timeJiaZi = null;
                  }
                },
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          ShakeMe(
            // 4. pass the GlobalKey as an argument
            key: dunGanZhiShakeKey,
            // 5. configure the animation parameters
            shakeCount: 3,
            shakeOffset: 10,
            shakeDuration: const Duration(milliseconds: 500),
            child: SizedBox(
              width: 128,
              height: 48,
              child: CustomDropdown<String>.search(
                decoration: CustomDropdownDecoration(
                    closedShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 2)
                    ],
                    expandedShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 2)
                    ],
                    searchFieldDecoration:
                        const SearchFieldDecoration(prefixIcon: null)),

                hintText: "阴阳遁局",
                // initialItem: "甲子",
                items: List.generate(
                    9,
                    (i) =>
                        "阳遁${ConstResourcesMapper.chineseNumberMapper[i + 1]!}局")
                  ..addAll(List.generate(
                      9,
                      (i) =>
                          "阴遁${ConstResourcesMapper.chineseNumberMapper[i + 1]!}局")),
                onChanged: (jiaZiStr) {
                  if (jiaZiStr != null) {
                    List<String> splitedList = jiaZiStr.split("");
                    String numStr = splitedList[2];
                    yinYangDun =
                        splitedList.first == "阳" ? YinYang.YANG : YinYang.YIN;
                    juNumber = ConstResourcesMapper.chineseNumberMapper.entries
                        .firstWhere((e) => e.value == numStr)
                        .key;
                  } else {
                    yinYangDun = null;
                    juNumber = null;
                  }
                  print(JiaZi.getFromGanZhiValue(jiaZiStr!));
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget selectDateTimeButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final result = await showBoardDateTimePicker(
              context: context,
              pickerType: DateTimePickerType.datetime,
            );
            if (result != null) {
              // dateTimeValueNotifier.value = result;
              // selectedDateTime = result;
              selectedDateTimeNotifier.value = result;
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors
                .white, // Background coloronPrimary: Colors.white, // Text color
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 15), // Padding
            textStyle: const TextStyle(fontSize: 18), // Text style
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ValueListenableBuilder(
                  valueListenable: selectedDateTimeNotifier,
                  builder: (ctx, dateTime, _) {
                    DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm");
                    return Text(
                      dateFormat.format(dateTime ?? DateTime.now()),
                      style: const TextStyle(fontSize: 16),
                    );
                  }),
              const Text(
                '选择时间',
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
        ),
        const SizedBox(width: 24),
        ElevatedButton(
          onPressed: () async {
            if (dateTimeValueNotifier.value != null) {
              InteractiveToast.slide(
                context: context,
                // leading: leadingWidget(),
                title: const Text("不能重复"),
                // trailing: trailingWidget(),
                toastStyle: const ToastStyle(titleLeadingGap: 10),
                toastSetting: const SlidingToastSetting(
                  animationDuration: Duration(seconds: 1),
                  displayDuration: Duration(seconds: 2),
                  toastStartPosition: ToastPosition.top,
                  toastAlignment: Alignment.topCenter,
                ),
              );
            } else {
              // dateTimeValueNotifier.value = DateTime.now();
              // selectedDateTime = DateTime.now();
              selectedDateTimeNotifier.value = DateTime.now();
            }
          },
          style: ElevatedButton.styleFrom(
            // backgroundColor: Colors.green, // Background coloronPrimary: Colors.white, // Text color
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 15), // Padding
            textStyle: const TextStyle(fontSize: 18), // Text style
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
          ),
          child: const Text('现在'),
        ),
      ],
    );
  }

  Widget buildNewExplainList(TenGanKeYing tenGanKeYing, TenGanKeYingGeJu geJu) {
    return ValueListenableBuilder(
        valueListenable: widthNotifier,
        builder: (ctx, width, _) {
          return AnimatedContainer(
              alignment: Alignment.topCenter,
              height: 640,
              duration: const Duration(milliseconds: 400),
              width: width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildTenGanKeYingGeJuDetail(geJu, width),
                    if (tenGanKeYing.yiXiang != null ||
                        tenGanKeYing.xiangList != null ||
                        tenGanKeYing.thingOnLocation != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: width,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(.2),
                                  blurRadius: 5,
                                  spreadRadius: 5),
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "意象",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Divider(
                              height: 8,
                              color: Colors.grey,
                            ),
                            tenGanKeYing.yiXiang != null
                                ? Text(tenGanKeYing.yiXiang!,
                                    style: const TextStyle(fontSize: 14))
                                : const SizedBox(),
                            tenGanKeYing.xiangList != null &&
                                    tenGanKeYing.xiangList!.isNotEmpty
                                ? Text(tenGanKeYing.xiangList!.join("、"),
                                    style: const TextStyle(fontSize: 14))
                                : const SizedBox(),
                            tenGanKeYing.thingOnLocation != null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          alignment: Alignment.topRight,
                                          child: const Text(
                                            "方位有：",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          )),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(tenGanKeYing
                                                  .thingOnLocation!))),
                                    ],
                                  )
                                : const SizedBox()
                          ],
                        ),
                      )
                          .animate()
                          .moveX(
                              delay: const Duration(milliseconds: 1000),
                              curve: Curves.easeInOutQuint,
                              duration: const Duration(milliseconds: 400),
                              begin: -128,
                              end: 0)
                          .fadeIn(
                              delay: const Duration(milliseconds: 800),
                              curve: Curves.easeInOutQuint,
                              duration: const Duration(milliseconds: 400),
                              begin: 0),
                    if (tenGanKeYing.others != null &&
                        tenGanKeYing.others!.isNotEmpty)
                      AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: width,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(.2),
                                        blurRadius: 5,
                                        spreadRadius: 5),
                                  ]),
                              child: buildBuWen(tenGanKeYing.others!))
                          .animate()
                          .moveX(
                              delay: const Duration(milliseconds: 1200),
                              curve: Curves.easeInOutQuint,
                              duration: const Duration(milliseconds: 400),
                              begin: -128,
                              end: 0)
                          .fadeIn(
                              delay: const Duration(milliseconds: 800),
                              curve: Curves.easeInOutQuint,
                              duration: const Duration(milliseconds: 400),
                              begin: 0),
                    if (tenGanKeYing.zhu != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: width,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(.2),
                                  blurRadius: 5,
                                  spreadRadius: 5),
                            ]),
                        child: tenGanKeYingZhuJie(tenGanKeYing.zhu!),
                      )
                          .animate()
                          .moveX(
                              delay: const Duration(milliseconds: 1400),
                              curve: Curves.easeInOutQuint,
                              duration: const Duration(milliseconds: 400),
                              begin: -128,
                              end: 0)
                          .fadeIn(
                              delay: const Duration(milliseconds: 800),
                              curve: Curves.easeInOutQuint,
                              duration: const Duration(milliseconds: 400),
                              begin: 0),
                  ],
                ),
              ));
        });
  }

  Widget buildExplainList2(HouTianGua gongGua, EachGong gong,
      TianGan xunShouGan, EightDoorEnum door) {
    return ValueListenableBuilder(
        valueListenable: widthNotifier,
        builder: (ctx, width, _) {
          return AnimatedContainer(
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 400),
              width: width,
              height: 640,
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    if (shiJiaZhuanPanQiMenValueNotifier
                                .value!.xunHeaderTianGan ==
                            gong.tianPan &&
                        shiJiaZhuanPanQiMenValueNotifier
                                .value!.xunHeaderTianGan ==
                            gong.diPan)
                      FutureBuilder(
                        future: loadTenGanKeyYing(
                            context, TianGan.JIA, TianGan.JIA),
                        builder: (BuildContext context,
                            AsyncSnapshot<TenGanKeYing?> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != null) {
                              return buildTenGanKeYingGeJuDetail(
                                  geJuMapper[gong.gongGua]!.tianDiPanGanGeJu!,
                                  width);
                            } else {
                              return const Center(child: Text("未找到"));
                            }
                          } else {
                            return const Center(child: Text("加载中..."));
                          }
                        },
                      ),
                    if (shiJiaZhuanPanQiMenValueNotifier
                                .value!.xunHeaderTianGan ==
                            gong.tianPan &&
                        shiJiaZhuanPanQiMenValueNotifier
                                .value!.xunHeaderTianGan !=
                            gong.diPan)
                      FutureBuilder(
                        future:
                            loadTenGanKeyYing(context, TianGan.JIA, gong.diPan),
                        builder: (BuildContext context,
                            AsyncSnapshot<TenGanKeYing?> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != null) {
                              return buildTenGanKeYingGeJuDetail(
                                  geJuMapper[gong.gongGua]!.tianDunJiaGeJu!,
                                  width);
                            } else {
                              return const Center(child: Text("未找到"));
                            }
                          } else {
                            return const Center(child: Text("加载中..."));
                          }
                        },
                      ),
                    if (shiJiaZhuanPanQiMenValueNotifier
                                .value!.xunHeaderTianGan !=
                            gong.tianPan &&
                        shiJiaZhuanPanQiMenValueNotifier
                                .value!.xunHeaderTianGan ==
                            gong.diPan)
                      FutureBuilder(
                        future: loadTenGanKeyYing(
                            context, gong.tianPan, TianGan.JIA),
                        builder: (BuildContext context,
                            AsyncSnapshot<TenGanKeYing?> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != null) {
                              return buildTenGanKeYingGeJuDetail(
                                  geJuMapper[gong.gongGua]!.diDunJiaGeJu!,
                                  width);
                            } else {
                              return const Center(child: Text("未找到"));
                            }
                          } else {
                            return const Center(child: Text("加载中..."));
                          }
                        },
                      ),
                    if (gong.tianPanJiGan != null &&
                        gong.diPanJiGan == null &&
                        gong.tianPanJiGan ==
                            shiJiaZhuanPanQiMenValueNotifier
                                .value!.xunHeaderTianGan)
                      FutureBuilder(
                        future:
                            loadTenGanKeyYing(context, TianGan.JIA, gong.diPan),
                        builder: (BuildContext context,
                            AsyncSnapshot<TenGanKeYing?> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != null) {
                              return buildTenGanKeYingGeJuDetail(
                                  geJuMapper[gong.gongGua]!.tianJiGanJiaGeJu!,
                                  width);
                            } else {
                              return const Center(child: Text("未找到"));
                            }
                          } else {
                            return const Center(child: Text("加载中..."));
                          }
                        },
                      ),
                    if (gong.tianPanJiGan == null &&
                        gong.diPanJiGan != null &&
                        gong.diPanJiGan ==
                            shiJiaZhuanPanQiMenValueNotifier
                                .value!.xunHeaderTianGan)
                      FutureBuilder(
                        future: loadTenGanKeyYing(
                            context, gong.tianPan, TianGan.JIA),
                        builder: (BuildContext context,
                            AsyncSnapshot<TenGanKeYing?> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != null) {
                              return buildTenGanKeYingGeJuDetail(
                                  geJuMapper[gong.gongGua]!.diJiGanJiaGeJu!,
                                  width);
                            } else {
                              return const Center(child: Text("未找到"));
                            }
                          } else {
                            return const Center(child: Text("加载中..."));
                          }
                        },
                      ),
                  ])));
        });
  }

  Widget buildTenGanKeYingGeJuDetail(TenGanKeYingGeJu geJu, double width) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: width,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(.2),
                blurRadius: 5,
                spreadRadius: 5),
          ]),
      child: TenGanKeYingGeJuDetail(geJu: geJu),
    )
        .animate()
        .moveX(
            delay: const Duration(milliseconds: 800),
            curve: Curves.easeInOutQuint,
            duration: const Duration(milliseconds: 400),
            begin: -128,
            end: 0)
        .fadeIn(
            delay: const Duration(milliseconds: 800),
            curve: Curves.easeInOutQuint,
            duration: const Duration(milliseconds: 400),
            begin: 0);
  }

  Widget buildExplainList(HouTianGua gongGua, TianGan tianPanGan,
      TianGan diPanGan, TianGan xunShouGan, EightDoorEnum door) {
    bool showJiaGan = {tianPanGan, diPanGan}.contains(xunShouGan);
    double explainWidgetWidth = 320;
    return Container(
      alignment: Alignment.topCenter,
      height: 640,
      width: explainWidgetWidth,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: explainWidgetWidth,
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: FutureBuilder(
                future: loadEightDoorGanKeYing(door, tianPanGan),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == null) {
                      return Container();
                    }
                    return IntrinsicHeight(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: cardDecoration,
                        child: buildDoorGan(
                            gongGua, tianPanGan, door, snapshot.data),
                      ),
                    );
                  } else {
                    return const Text("加载中...");
                  }
                },
              ),
            )
                .animate()
                .moveY(
                    delay: const Duration(milliseconds: 800),
                    curve: Curves.easeInOutQuint,
                    duration: const Duration(milliseconds: 400),
                    begin: -128,
                    end: 0)
                .fadeIn(
                    delay: const Duration(milliseconds: 800),
                    curve: Curves.easeInOutQuint,
                    duration: const Duration(milliseconds: 400),
                    begin: 0),
            SizedBox(
              width: explainWidgetWidth,
              child: FutureBuilder(
                future: Future.wait([
                  loadThreeQiRuGong(gongGua, tianPanGan),
                  loadTianPanGanRuGong(gongGua, tianPanGan),
                ]),
                builder: (BuildContext context,
                    AsyncSnapshot<List<dynamic>?> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data?[0] == null &&
                        snapshot.data?[1] == null) {
                      return Container();
                    }
                    return IntrinsicHeight(
                      child: Container(
                        width: explainWidgetWidth,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        decoration: cardDecoration,
                        child: buildQiYiRuGong(gongGua, tianPanGan,
                            snapshot.data?[0], snapshot.data?[1]),
                      ),
                    );
                  } else {
                    return const Text("加载中...");
                  }
                },
              ),
            )
                .animate()
                .moveX(
                    delay: const Duration(milliseconds: 800),
                    curve: Curves.easeInOutQuint,
                    duration: const Duration(milliseconds: 400),
                    begin: 128,
                    end: 0)
                .fadeIn(
                    delay: const Duration(milliseconds: 800),
                    curve: Curves.easeInOutQuint,
                    duration: const Duration(milliseconds: 400),
                    begin: 0),
            if (showJiaGan)
              IntrinsicHeight(
                child: Container(
                        width: explainWidgetWidth,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        decoration: cardDecoration,
                        child: FutureBuilder(
                          future: loadTenGanKeyYing(
                              context,
                              xunShouGan == tianPanGan
                                  ? TianGan.JIA
                                  : tianPanGan,
                              xunShouGan == diPanGan ? TianGan.JIA : diPanGan),
                          builder: (BuildContext context,
                              AsyncSnapshot<TenGanKeYing?> snapshot) {
                            if (snapshot.hasData) {
                              return buildTenGanKeYing(
                                  gongGua,
                                  xunShouGan == tianPanGan
                                      ? TianGan.JIA
                                      : tianPanGan,
                                  xunShouGan == diPanGan
                                      ? TianGan.JIA
                                      : diPanGan,
                                  snapshot.data!);
                            } else {
                              return const Text("加载中...");
                            }
                          },
                        ))
                    .animate()
                    .moveX(
                        delay: const Duration(milliseconds: 800),
                        curve: Curves.easeInOutQuint,
                        duration: const Duration(milliseconds: 400),
                        begin: -128,
                        end: 0)
                    .fadeIn(
                        curve: Curves.easeInOutQuint,
                        delay: const Duration(milliseconds: 800),
                        duration: const Duration(milliseconds: 400),
                        begin: 0),
              ),
            IntrinsicHeight(
              child: Container(
                      width: explainWidgetWidth,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      decoration: cardDecoration,
                      child: FutureBuilder(
                        future:
                            loadTenGanKeyYing(context, tianPanGan, diPanGan),
                        builder: (BuildContext context,
                            AsyncSnapshot<TenGanKeYing?> snapshot) {
                          if (snapshot.hasData) {
                            return buildTenGanKeYing(
                                gongGua, tianPanGan, diPanGan, snapshot.data!);
                          } else {
                            return const Text("加载中...");
                          }
                        },
                      ))
                  .animate()
                  .moveX(
                      delay: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOutQuint,
                      duration: const Duration(milliseconds: 400),
                      begin: -128,
                      end: 0)
                  .fadeIn(
                      curve: Curves.easeInOutQuint,
                      delay: const Duration(milliseconds: 1000),
                      duration: const Duration(milliseconds: 400),
                      begin: 0),
            ),
            const SizedBox(
              height: 24,
            )
          ],
        ),
      ),
    );
  }

  Widget buildEightDoorKeYing(Map<YinYang, EightDoorKeYing> mapper) {
    EightDoorKeYing yinKeYing = mapper[YinYang.YIN]!;
    EightDoorKeYing yangKeYing = mapper[YinYang.YANG]!;
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(style: eightDoorTextStyle, children: [
              TextSpan(
                  text: yinKeYing.door.name,
                  style: TextStyle(
                      color: ConstantUiResourcesOfQiMen
                          .eightDoorColorMapper[yinKeYing.door]!)),
              const TextSpan(
                  text: "遇",
                  style:
                      TextStyle(color: Colors.grey, shadows: [], fontSize: 18)),
              TextSpan(
                  text: yinKeYing.fixDoor.name,
                  style: TextStyle(
                      color: ConstantUiResourcesOfQiMen
                          .eightDoorColorMapper[yinKeYing.fixDoor]!))
            ]),
          ),
          const Divider(),
          RichText(
            text: TextSpan(
                style: const TextStyle(
                    color: Colors.black54, fontSize: 14, shadows: []),
                children: [
                  const TextSpan(
                      text: "静应：",
                      style: TextStyle(color: Colors.black87, fontSize: 16)),
                  TextSpan(text: yinKeYing.description)
                ]),
          ),
          const SizedBox(
            height: 8,
          ),
          RichText(
            text: TextSpan(
                style: const TextStyle(
                    color: Colors.black54, fontSize: 14, shadows: []),
                children: [
                  const TextSpan(
                      text: "动应：",
                      style: TextStyle(color: Colors.black87, fontSize: 16)),
                  TextSpan(text: yangKeYing.description)
                ]),
          ),
        ]);
  }

  Widget buildDoorStarKeYing(DoorStarKeYing doorStarKeYing) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(style: tianGanTextStyle, children: [
                      TextSpan(
                          text: doorStarKeYing.star.name,
                          style: nineStarTextStyle.copyWith(
                              color: ConstantUiResourcesOfQiMen
                                  .nineStarsColorMapper[doorStarKeYing.star]!)),
                      const TextSpan(
                          text: "遇",
                          style: TextStyle(
                              color: Colors.grey, shadows: [], fontSize: 18)),
                      TextSpan(
                          text: doorStarKeYing.door.name,
                          style: eightDoorTextStyle.copyWith(
                              color: ConstantUiResourcesOfQiMen
                                  .eightDoorColorMapper[doorStarKeYing.door]!))
                    ]),
                  ),
                  Container(
                    width: 180,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1))),
                  ),
                  Text(
                    doorStarKeYing.description,
                    style: const TextStyle(fontSize: 14, height: 1.0),
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
              // Text(doorStarKeYing.jiXiong.name,style: TextStyle(fontSize: 14,height: 1.0),),
              buildJiXiongYinZhang(doorStarKeYing.jiXiong)
            ],
          ),
        ]);
  }

  Widget buildJiXiongYinZhang(JiXiongEnum jixiong) {
    return Stack(children: [
      SizedBox(
        width: 28,
        height: 42,
        child: ColorFiltered(
            colorFilter: ColorFilter.mode(
                ConstResourcesMapper.jiXiongColorMapper[jixiong]!,
                BlendMode.srcIn),
            child: Image.asset(
              "assets/icons/ji_xiong_yin_zhang.png",
              width: 32,
              height: 32,
            )),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Text(
          jixiong.name.split("").first,
          style: GoogleFonts.maShanZheng(
              color: Colors.white, fontSize: 22, height: 1),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Text(
          jixiong.name.split("").last,
          style: GoogleFonts.maShanZheng(
              color: Colors.white, fontSize: 22, height: 1),
        ),
      ),
    ]);
  }

  Widget buildDoorGan(
      HouTianGua gongGua, TianGan tianPanGan, EightDoorEnum door, String? str) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(style: tianGanTextStyle, children: [
              TextSpan(
                  text: tianPanGan.name,
                  style: tianGanTextStyle.copyWith(
                      color: getTianGanColor(tianPanGan))),
              const TextSpan(text: "入", style: TextStyle(color: Colors.grey)),
              TextSpan(
                  text: door.name,
                  style: eightDoorTextStyle.copyWith(
                      color: ConstantUiResourcesOfQiMen
                          .eightDoorColorMapper[door]!))
            ]),
          ),
          const Divider(
            color: Colors.grey,
          ),
          str == null
              ? Container()
              : Text(
                  str,
                  style: const TextStyle(fontSize: 14, height: 1.0),
                ),
        ]);
  }

  Widget buildQiYiRuGong(HouTianGua gongGua, TianGan tianPanGan,
      QiYiRuGong? qiYiGong, String? disease) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(style: tianGanTextStyle, children: [
                  TextSpan(
                      text: tianPanGan.name,
                      style: tianGanTextStyle.copyWith(
                          color: getTianGanColor(tianPanGan))),
                  const TextSpan(
                      text: "入", style: TextStyle(color: Colors.grey)),
                  TextSpan(
                      text: "${gongGua.name}宫",
                      style: TextStyle(
                          color:
                              ConstResourcesMapper.zodiacGuaColors[gongGua]!))
                ]),
              ),
              const Expanded(child: SizedBox()),
              qiYiGong != null
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 86,
                          height: 32,
                          child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  ConstResourcesMapper.jiXiongColorMapper[
                                      qiYiGong.geJuJiXiong]!,
                                  BlendMode.srcIn),
                              child: Image.asset(
                                "assets/icons/long_yin_zhang.png",
                                width: 64,
                                height: 20,
                              )),
                        ),
                        Text(
                          qiYiGong.geJuName,
                          style: GoogleFonts.maShanZheng(
                              fontSize: 18, height: 1.0, color: Colors.white),
                        )
                      ],
                    )
                  : Container(),
              const SizedBox(
                width: 8,
              ),
              qiYiGong != null
                  ? Text(
                      qiYiGong.geJuJiXiong.name,
                      style: GoogleFonts.maShanZheng(
                          fontSize: 32,
                          height: 1.0,
                          color: ConstResourcesMapper
                              .jiXiongColorMapper[qiYiGong.geJuJiXiong]!,
                          shadows: [
                            Shadow(
                                color: ConstResourcesMapper
                                    .jiXiongColorMapper[qiYiGong.geJuJiXiong]!
                                    .withOpacity(.4),
                                blurRadius: 4)
                          ]),
                    )
                  : Container(),
            ],
          ),
          const Divider(
            color: Colors.grey,
          ),
          qiYiGong == null
              ? Container()
              : Text(
                  qiYiGong.description,
                  style: const TextStyle(fontSize: 16, height: 1.0),
                ),
          disease == null ? Container() : Text("疾病：$disease")
        ]);
  }

  Widget buildTenGanKeYingYinZhang(String geJuName) {
    List<String> juName = geJuName.split("");
    String yinZhang0 = juName[0];
    String yinZhang1 = juName[1];
    String yinZhang2 = juName[2];
    String yinZhang3 = juName[3];
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 42,
          height: 42,
          child: ColorFiltered(
              colorFilter:
                  ColorFilter.mode(Colors.blueGrey.shade700, BlendMode.srcIn),
              child: Image.asset(
                "assets/icons/yin_zhang.png",
                width: 32,
                height: 32,
              )),
        ),
        SizedBox(
          height: 42,
          width: 42,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    yinZhang2,
                    style: GoogleFonts.maShanZheng(
                        height: 1.0,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    yinZhang3,
                    style: GoogleFonts.maShanZheng(
                        height: 1.0,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(
                width: 2,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    yinZhang0,
                    style: GoogleFonts.maShanZheng(
                        height: 1.0,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    yinZhang1,
                    style: GoogleFonts.maShanZheng(
                        height: 1.0,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildBuWen(List<Map<String, String>> mapper) {
    List<Widget> lists = [];
    for (int i = 0; i < mapper.length; i++) {
      lists.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              alignment: Alignment.topRight,
              child: Text(
                "${mapper[i]["key"]}：",
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
          Expanded(
              flex: 7,
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text("${mapper[i]["content"]}"))),
        ],
      ));
      if (i != mapper.length - 1) {
        lists.add(const SizedBox(
          height: 4,
        ));
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "卜问",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(
          height: 8,
          color: Colors.grey,
        ),
        ...lists
      ],
    );
  }

  Widget tenGanKeYingZhuJie(List<TenGanKeYingZhu> zhuList) {
    TextStyle titleStyle =
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
    TextStyle contentStyle =
        const TextStyle(fontSize: 16, color: Colors.black87);
    TextStyle seeMoreStyle = TextStyle(
        fontSize: 16, color: Colors.blue.shade600, fontWeight: FontWeight.w200);

    List<Widget> lists = [];
    for (var zhu in zhuList) {
      lists.add(Text(zhu.author ?? "注解", style: titleStyle));
      lists.add(const Divider(
        height: 8,
      ));
      lists.add(Container(
        child: AnimatedReadMoreText(
          "利静不利动。出行结伴主失散，还容易得病。遇伏吟，不宜动。一动，就出事。如果此格临马星或九天，你不让他动，他肯定也动，一动就倒霉，然后后悔。此格，遇到击刑，也主牢狱、伤灾。遇此格，自己独立出行、独立行事，一般没有大问题。就怕多人出行以及合作做事，则必然出问题。庚+庚，癸+癸，一合作就出事。遇到此格，切忌结伴出行，若结伴出行：一是自己生病；二是与同伴失去联系或分道扬镳。二者必应其一。",
          maxLines: 3,
          // Set a custom text for the expand button. Defaults to Read more
          readMoreText: '展开',
          // Set a custom text for the collapse button. Defaults to Read less
          readLessText: '收起',
          // Set a custom text style for the main block of text
          textStyle: contentStyle,
          // Set a custom text style for the expand/collapse button
          buttonTextStyle: seeMoreStyle,
          expandOnTextTap: true,
        ),
      ));
      lists.add(const SizedBox(
        height: 8,
      ));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lists,
    );
  }

  Widget buildTenGanKeYing(HouTianGua gong, TianGan tianPanGan,
      TianGan diPanGan, TenGanKeYing tenGanKeying) {
    String shortExplain = tenGanKeying.shortExplain;
    String? longExplain = tenGanKeying.longExplain;
    List<Widget>? zhuList;
    if (tenGanKeying.zhu != null) {
      var tmp =
          tenGanKeying.zhu!.map((e) => Text("${e.author ?? "注"}：${e.content}"));
      zhuList = tmp
          .map((e) => [e, const SizedBox(height: 8)])
          .expand((e) => e)
          .toList();
    }

    String? yiXiang;
    if (tenGanKeying.yiXiang != null) {
      yiXiang = tenGanKeying.yiXiang;
    }
    String? xiangList;
    if (tenGanKeying.xiangList != null && tenGanKeying.xiangList!.isNotEmpty) {
      xiangList = tenGanKeying.xiangList!.join("，");
    }
    String? diseaseAtGong;
    if (tenGanKeying.diseaseAtGongMapper != null) {
      diseaseAtGong = tenGanKeying.diseaseAtGongMapper?[gong.name]?.join(" ");
    }
    List<Map<String, String>>? others = tenGanKeying.others;
    List<Widget>? otherInfo;
    if (others != null) {
      otherInfo = others
          .map((e) => RichText(
                  text: TextSpan(
                      text: "${e["key"]}：",
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                      children: [
                    TextSpan(
                        text: "${e["content"]}",
                        style: const TextStyle(fontWeight: FontWeight.normal))
                  ])))
          .toList();
    }
    String? thingsOnLocation = tenGanKeying.thingOnLocation;

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(style: tianGanTextStyle, children: [
                      TextSpan(
                          text: tianPanGan.name,
                          style: tianGanTextStyle.copyWith(
                              color: getTianGanColor(tianPanGan))),
                      const TextSpan(text: "+"),
                      TextSpan(
                          text: diPanGan.name,
                          style: tianGanTextStyle.copyWith(
                              color: getTianGanColor(diPanGan))),
                    ]),
                  ),
                  Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1))),
                  ),
                  SizedBox(
                    width: 200,
                    child: Text(
                      tenGanKeying.shortExplain,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 4,
              ),
              // Text(snapshot.data!.juName,style: TextStyle(height: 1.0,fontSize: 18),)
              buildTenGanKeYingYinZhang(tenGanKeying.juName)
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          longExplain == null ? Container() : Text(tenGanKeying.longExplain!),
          const SizedBox(
            height: 8,
          ),
          if (zhuList != null) ...zhuList,
          if (xiangList != null)
            const SizedBox(
              height: 8,
            ),
          if (xiangList != null)
            const Text(
              "意象",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          if (xiangList != null) const Divider(),
          if (xiangList != null)
            Text(
              xiangList,
              style: const TextStyle(fontWeight: FontWeight.bold, height: 1.0),
            ),
          const SizedBox(
            height: 4,
          ),
          if (yiXiang != null)
            Text(
              yiXiang,
            ),
          diseaseAtGong == null
              ? Container()
              : const SizedBox(
                  height: 8,
                ),
          diseaseAtGong == null
              ? Container()
              : const Text(
                  "问病",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
          diseaseAtGong == null ? Container() : const Divider(),
          if (diseaseAtGong != null)
            Text(diseaseAtGong, style: const TextStyle(height: 1.0)),
          otherInfo == null
              ? Container()
              : const SizedBox(
                  height: 8,
                ),
          otherInfo == null
              ? Container()
              : const Text(
                  "卜问占测",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
          otherInfo == null ? Container() : const Divider(),
          if (otherInfo != null) ...otherInfo,
          thingsOnLocation == null
              ? Container()
              : const SizedBox(
                  height: 8,
                ),
          thingsOnLocation == null
              ? Container()
              : const Text(
                  "方位上有",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
          thingsOnLocation == null ? Container() : const Divider(),
          if (thingsOnLocation != null)
            Text(
              thingsOnLocation,
              style: const TextStyle(height: 1),
            ),
        ]);
  }

  Widget buildPanel(Map<HouTianGua, Widget> mapper) {
    Size gongAtPanSize = Size(baseEachGongSize + eachPaddingSize * 2,
        baseEachGongSize + eachPaddingSize * 2);
    return Container(
        key: panelGlobalKey,
        width: panSize.width + 2,
        height: panSize.height + 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(1, 1), // changes position of shadow
              )
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                bottom: BorderSide(width: 1, color: Colors.black26),
              )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildEachGongAtPanel(
                      gongAtPanSize, HouTianGua.Xun, mapper[HouTianGua.Xun]!),
                  Container(
                      decoration: const BoxDecoration(
                          border: Border(
                        left: BorderSide(width: 1, color: Colors.black26),
                        right: BorderSide(width: 1, color: Colors.black26),
                      )),
                      child: buildEachGongAtPanel(gongAtPanSize, HouTianGua.Li,
                          mapper[HouTianGua.Li]!)),
                  buildEachGongAtPanel(
                      gongAtPanSize, HouTianGua.Kun, mapper[HouTianGua.Kun]!),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    decoration: const BoxDecoration(
                        border: Border(
                      right: BorderSide(width: 1, color: Colors.black26),
                    )),
                    child: buildEachGongAtPanel(gongAtPanSize, HouTianGua.Zhen,
                        mapper[HouTianGua.Zhen]!)),
                SizedBox(
                  width: gongAtPanSize.width,
                  height: gongAtPanSize.height,
                  child: mapper.containsKey(HouTianGua.Center)
                      ? buildEachGongAtPanel(gongAtPanSize, HouTianGua.Center,
                          mapper[HouTianGua.Center]!)
                      : null,
                ),
                Container(
                  alignment: Alignment.center,
                  width: gongAtPanSize.width,
                  height: gongAtPanSize.height,
                  decoration: const BoxDecoration(
                      border: Border(
                    left: BorderSide(width: 1, color: Colors.black26),
                  )),
                  child: buildEachGongAtPanel(
                      gongAtPanSize, HouTianGua.Dui, mapper[HouTianGua.Dui]!),
                ),
              ],
            ),
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                top: BorderSide(width: 1, color: Colors.black26),
              )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      child: buildEachGongAtPanel(gongAtPanSize, HouTianGua.Gen,
                          mapper[HouTianGua.Gen]!)),
                  Container(
                      decoration: const BoxDecoration(
                          border: Border(
                        left: BorderSide(width: 1, color: Colors.black26),
                        right: BorderSide(width: 1, color: Colors.black26),
                      )),
                      child: buildEachGongAtPanel(gongAtPanSize, HouTianGua.Kan,
                          mapper[HouTianGua.Kan]!)),
                  buildEachGongAtPanel(
                      gongAtPanSize, HouTianGua.Qian, mapper[HouTianGua.Qian]!),
                ],
              ),
            ),
          ],
        ));
  }

  Widget buildEachGongAtPanel(Size size, HouTianGua gong, Widget gongWidget) {
    BorderRadius borderRadius = BorderRadius.zero;
    switch (gong) {
      case HouTianGua.Gen:
        borderRadius = const BorderRadius.only(bottomLeft: Radius.circular(36));
        break;
      case HouTianGua.Qian:
        borderRadius =
            const BorderRadius.only(bottomRight: Radius.circular(36));
        break;
      case HouTianGua.Xun:
        borderRadius = const BorderRadius.only(topLeft: Radius.circular(36));
        break;
      case HouTianGua.Kun:
        borderRadius = const BorderRadius.only(topRight: Radius.circular(36));
        break;
      default:
        break;
    }
    return Container(
        alignment: Alignment.center,
        width: size.width,
        height: size.width,
        decoration: BoxDecoration(
            color: getGongBackgroundColor(gong), borderRadius: borderRadius),
        child: gongWidget);
  }

  Color getGongBackgroundColor(HouTianGua gong) {
    Color backgroundColor;
    if (shiJiaZhuanPanQiMenValueNotifier.value!.yinYangDun.isYang) {
      if ([HouTianGua.Kan, HouTianGua.Gen, HouTianGua.Zhen, HouTianGua.Xun]
          .contains(gong)) {
        // backgroundColor = Colors.grey.withOpacity(.2);
        backgroundColor = Colors.grey.shade100;
      } else {
        backgroundColor = Colors.white;
      }
    } else {
      if ([HouTianGua.Kan, HouTianGua.Gen, HouTianGua.Zhen, HouTianGua.Xun]
          .contains(gong)) {
        backgroundColor = Colors.white;
      } else {
        backgroundColor = Colors.grey.shade100;
      }
    }
    return backgroundColor;
  }

  Widget buildCenterPanTime(DateTime time) {
    LunarAdapter lunar = LunarAdapter.fromDate(time);
    return Card(
        child: Container(
            alignment: Alignment.center,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(flex: 3, child: Text("时间：")),
                      Flexible(
                          flex: 7,
                          child: Text(
                            DateFormat("yyyy/MM/dd HH:mm").format(time),
                            style: TextStyle(
                                fontSize: 14, color: Colors.blueGrey.shade800),
                          )),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(flex: 3, child: Text("农历：")),
                      Flexible(
                          flex: 7,
                          child: Text(
                            "${lunar.getYearInGanZhi()}年 ${lunar.getMonthInChinese()}月 ${lunar.getDayInChinese()} ${lunar.getTimeZhi()}时",
                            style: TextStyle(
                                fontSize: 14, color: Colors.blueGrey.shade800),
                          )),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          flex: 3,
                          child: Text("${lunar.getPrevJieQi().getName()}:")),
                      Flexible(
                          flex: 7,
                          child: Text(
                            lunar
                                .getPrevJieQi()
                                .getSolar()
                                .toYmdHms()
                                .replaceAll("-", "/"),
                            style: TextStyle(
                                fontSize: 14, color: Colors.blueGrey.shade800),
                          )),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flexible(flex:3,child: Text("值符门：")),
                      Flexible(
                          flex: 3,
                          child: Text("${lunar.getNextJieQi().getName()}:")),
                      Flexible(
                          flex: 7,
                          child: Text(
                            lunar
                                .getNextJieQi()
                                .getSolar()
                                .toYmdHms()
                                .replaceAll("-", "/"),
                            style: TextStyle(
                                fontSize: 14, color: Colors.blueGrey.shade800),
                          )),
                    ],
                  )
                ])));
  }

  Widget buildCenterFourZhu(ShiJiaQiMen pan) {
    return Card(
        child: Align(
      alignment: Alignment.center,
      child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FourZhuEightChar(
            year: pan.yearJiaZi,
            month: pan.monthJiaZi,
            day: pan.dayJiaZi,
            chen: pan.timeJiaZi,
            isColorful: true,
            zodiacGanColors: ConstResourcesMapper.zodiacGanColors,
            zodiacZhiColors: ConstResourcesMapper.zodiacZhiColors,
          )),
    ));
  }

  Widget buildCenter(ShiJiaQiMen pan) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Text(
        //   "转盘·拆补 ${pan.yinYangDun.isYin?"阴":"阳"}${ConstResourcesMapper.chineseNumberMapper[pan.juNumber]}局",
        //   style: panInfoTextStyle),
        buildPanInfo(pan),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(flex: 7, child: Container()),
            Flexible(flex: 3, child: Container()),
          ],
        )
      ],
    );
  }

  Widget buildPanInfo(ShiJiaQiMen pan) {
    return Card(
      child: Container(
        alignment: Alignment.center,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  "转盘·${pan.arrangeType.name} ${pan.yinYangDun.isYin ? "阴" : "阳"}${ConstResourcesMapper.chineseNumberMapper[pan.juNumber]}局",
                  style: panInfoTextStyle),
              const Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(flex: 4, child: Text("旬首：")),
                  Flexible(
                      flex: 6,
                      child: RichText(
                          text: TextSpan(
                              style: const TextStyle(fontSize: 18),
                              children: [
                            TextSpan(
                                text: pan.xunShou.name.split("").first,
                                style: tianGanTextStyle.copyWith(
                                    fontSize: 18,
                                    color: ConstResourcesMapper.zodiacGanColors[
                                        TianGan.getFromValue(pan.xunShou.name
                                            .split("")
                                            .first)]!)),
                            TextSpan(
                                text: pan.xunShou.name.split("").last,
                                style: twelveDiZhiTextStyle.copyWith(
                                    fontSize: 19,
                                    color: ConstResourcesMapper.zodiacZhiColors[
                                        DiZhi.getFromValue(pan.xunShou.name
                                            .split("")
                                            .last)]!)),
                            TextSpan(
                                text: " ${pan.xunHeaderTianGan.name}",
                                style: tianGanTextStyle.copyWith(
                                    fontSize: 18,
                                    color: ConstResourcesMapper.zodiacGanColors[
                                        TianGan.getFromValue(
                                            pan.xunHeaderTianGan.name)]!))
                          ]))),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(flex: 4, child: Text("节气：")),
                  Flexible(
                      flex: 6,
                      child: RichText(
                          text: TextSpan(
                              text: pan.shiJiaJu.panJuJieQi?.name ??
                                  pan.jieQi.name,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey.shade800),
                              children: [
                            TextSpan(
                                text: "  ${pan.shiJiaJu.atThreeYuan.name}"),
                            pan.shiJiaJu.juDayNumber == null
                                ? const TextSpan(text: "")
                                : TextSpan(
                                    text: " 第 ${pan.shiJiaJu.juDayNumber!} 天")
                          ]))),
                ],
              ),
              SizedBox(
                height: 26,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(flex: 4, child: Text("值符星：")),
                    // Flexible(flex:6,child: Text("${pan.zhiFuStar.name}星 落 ${pan.zhiFuStarAtGong.name}${ConstResourcesMapper.chineseNumberMapper[pan.zhiFuStarAtGong.houTianOrder]}宫",style: TextStyle(fontSize: 14,color: Colors.blueGrey.shade800),)),
                    Flexible(
                      flex: 6,
                      child: Row(children: [
                        SizedBox(
                          height: 26,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Container(
                                  width: 48,
                                  height: 26,
                                  alignment: Alignment.bottomCenter,
                                  child: ColorFiltered(
                                      colorFilter: const ColorFilter.mode(
                                          Color.fromRGBO(176, 31, 36, .8),
                                          BlendMode.srcIn),
                                      child: Image.asset(
                                        "assets/icons/wide-black-ink-radian-line2.png",
                                      ))),
                              Text("${pan.zhiFuStar.name}星",
                                  style:
                                      nineStarTextStyle.copyWith(fontSize: 18)),
                            ],
                          ),
                        ),
                        RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey.shade800),
                                children: [
                              const TextSpan(
                                  text: " 落 ",
                                  style: TextStyle(color: Colors.grey)),
                              TextSpan(
                                text:
                                    "${pan.zhiFuStarAtGong.name}${ConstResourcesMapper.chineseNumberMapper[pan.zhiFuStarAtGong.houTianOrder]}宫",
                              )
                            ]))
                      ]),
                    )
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(flex: 4, child: Text("值符门：")),
                  Flexible(
                    flex: 6,
                    child: Row(children: [
                      SizedBox(
                        height: 26,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                                width: 42,
                                height: 26,
                                alignment: Alignment.bottomCenter,
                                child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                        Color.fromRGBO(176, 31, 36, .8),
                                        BlendMode.srcIn),
                                    child: Image.asset(
                                      "assets/icons/wide-black-ink-radian-line2.png",
                                    ))),
                            Text(pan.zhiShiDoor.name,
                                style:
                                    eightDoorTextStyle.copyWith(fontSize: 18)),
                          ],
                        ),
                      ),
                      RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey.shade800),
                              children: [
                            const TextSpan(
                                text: " 落 ",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                              text:
                                  "${pan.zhiFuStarAtGong.name}${ConstResourcesMapper.chineseNumberMapper[pan.zhiFuStarAtGong.houTianOrder]}宫",
                            )
                          ]))
                    ]),
                  )
                  // Flexible(flex:6,child: Text(" ${pan.zhiShiDoor.name} 落 ${pan.zhiShiDoorAtGong.name}${ConstResourcesMapper.chineseNumberMapper[pan.zhiShiDoorAtGong.houTianOrder]}宫",style: TextStyle(fontSize: 14,color: Colors.blueGrey.shade800),)),
                ],
              )
            ]),
      ),
    );
  }

  PanArrangeSettings getPanArrageSettings(ArrangeType arrangeType) {
    // godWithGongTypeNotifier.v
    return PanArrangeSettings(
        arrangeType: arrangeType,
        jiGong: jiGongHintNotifier.value,
        starMonthTokenType: monthTokenTypeNotifier.value,
        starFourWeiGongType: starGongTypeNotifier.value,
        doorFourWeiGongType: doorGongTypeNotifier.value,
        godWithGongTypeEnum: godWithGongTypeNotifier.value,
        ganGongType: ganGongTypeNotifier.value);
  }

  ShiJiaQiMen create(DateTime panDatetime) {
    ShiJiaJu shiJiaJu;
    switch (arrangeTypeNotifier.value) {
      case ArrangeType.CHAI_BU:
        shiJiaJu = ChaiBuCalculator(dateTime: panDatetime).calculate();
        break;
      case ArrangeType.ZHI_RUN:
        shiJiaJu = ZhiRunCalculator(dateTime: panDatetime).calculate();
        break;
      case ArrangeType.MAO_SHAN:
        shiJiaJu = MaoShanCalculator(dateTime: panDatetime).calculate();
        break;
      case ArrangeType.YIN_PAN:
        shiJiaJu = YinPanCalculator(dateTime: panDatetime).calculate();
        break;
      default:
        JiaZi fuTou = ChaiBuCalculator.getFuTouByDayJiaZi(dayJiaZi!);
        if ([
          CenterGongJiGongType.ONLY_KUN_GONG,
          CenterGongJiGongType.KUN_GEN_GONG
        ].contains(jiGongHintNotifier.value)) {
          jieQi = yinYangDun!.isYang
              ? TwentyFourJieQi.DONG_ZHI
              : TwentyFourJieQi.XIA_ZHI;
        }
        shiJiaJu = ShiJiaJu(
          juNumber: juNumber!,
          fuTouJiaZi: fuTou,
          yinYangDun: yinYangDun!,
          jieQiAt: jieQi!,
          jieQiEnd: jieQi!,
          atThreeYuan: ShiJiaQiMenJuCalculator.getThreeYuanByFuHead(fuTou),
          fourZhuEightChar:
              "${yearJiaZi?.name} ${monthJiaZi?.name} ${dayJiaZi?.name} ${timeJiaZi?.name}",
          panDateTime: panDatetime,
        );
    }

    var panSettings = getPanArrageSettings(arrangeTypeNotifier.value);
    var shiJiaQiMen = ShiJiaQiMen(
      plateType: plateTypeNotifier.value,
      // panDateTime:panDatetime,
      shiJiaJu: shiJiaJu,
      settings: panSettings,
    );
    return shiJiaQiMen;
  }

  Offset gongPositionOffset(HouTianGua gong) {
    final RenderBox renderPan =
        panelGlobalKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox appBarRender =
        appBarGlobalKey.currentContext!.findRenderObject() as RenderBox;
    Offset currentPanOffset =
        renderPan.localToGlobal(Offset(0, -appBarRender.size.height));
    panOffset = currentPanOffset;

    Offset offset = const Offset(0, 0);
    switch (gong) {
      case HouTianGua.Xun:
        offset = Offset(eachPaddingSize, eachPaddingSize);
        break;
      case HouTianGua.Li:
        offset =
            Offset(baseEachGongSize + eachPaddingSize * 3 + 1, eachPaddingSize);
        break;
      case HouTianGua.Kun:
        offset = Offset(
            baseEachGongSize * 2 + eachPaddingSize * 5 + 2, eachPaddingSize);
        break;
      case HouTianGua.Zhen:
        offset =
            Offset(eachPaddingSize, baseEachGongSize + eachPaddingSize * 3 + 1);
        break;
      case HouTianGua.Dui:
        offset = Offset(baseEachGongSize * 2 + eachPaddingSize * 5 + 2,
            baseEachGongSize + eachPaddingSize * 3 + 1);
        break;
      case HouTianGua.Gen:
        offset = Offset(
            eachPaddingSize, baseEachGongSize * 2 + eachPaddingSize * 5 + 2);
        break;
      case HouTianGua.Kan:
        offset = Offset(baseEachGongSize + eachPaddingSize * 3 + 1,
            baseEachGongSize * 2 + eachPaddingSize * 5 + 2);
        break;
      case HouTianGua.Qian:
        offset = Offset(baseEachGongSize * 2 + eachPaddingSize * 5 + 2,
            baseEachGongSize * 2 + eachPaddingSize * 5 + 2);
        break;
      case HouTianGua.Center:
        // TODO: Handle this case.
        offset = Offset(baseEachGongSize * 2 + eachPaddingSize * 5 + 2,
            baseEachGongSize * 2 + eachPaddingSize * 5 + 2);
    }
    return Offset(
        offset.dx + currentPanOffset.dx, offset.dy + currentPanOffset.dy);
  }

  Widget buildEachGong(
      HouTianGua gua, ShiJiaQiMen pan, UITenGanKeYingGeJu tenGanGeJu) {
    return GestureDetector(
      onDoubleTap: () {
        if (selectedGongWidgetNotifier.value?.item2.key == gua) {
          selectedGongWidgetNotifier.value = null;
        } else {
          Offset offset = gongPositionOffset(gua);
          selectedGongWidgetNotifier.value = Tuple3(
              offset,
              MapEntry<HouTianGua, EachGong>(gua,
                  shiJiaZhuanPanQiMenValueNotifier.value!.gongMapper[gua]!),
              buildEachGong(gua, pan, tenGanGeJu));
        }
      },
      child: Hero(
          tag: gua.name,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            child: EachGongWidget(
              gua: gua,
              pan: pan,
              backgroundGong: gua == HouTianGua.Center
                  ? null
                  : ConstantResourcesOfQiMen.defaultGongMapper[gua]!,
              gongSize: baseEachGongSize,
              withNormalBorder: false,
              showHintNotifier: showHintNotifier,
              tenGanKeYingGeJu: tenGanGeJu,
              gong: pan.gongMapper[gua]!,
            ),
          )),
    );
  }
}
