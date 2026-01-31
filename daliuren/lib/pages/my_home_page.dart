import 'dart:async';
import 'dart:convert';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:common/const_resources_mapper.dart';
import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:common/widgets/const_ui_resources_mapper.dart';
import 'package:common/widgets/four_zhu_eight_char.dart';
import 'package:common/widgets/twenty_four_jie_qi_tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tyme/tyme.dart' hide YinYang;
import 'package:tuple/tuple.dart';

import '../model/da_liu_ren_gong.dart';
import '../model/da_liu_ren_ke_pan.dart';
import '../model/da_liu_ren_pan_model.dart';
import '../model/da_liu_ren_panel.dart';
import '../model/enum_gui_ren.dart';
import '../model/four_class.dart';
import '../model/three_chuan.dart';
import '../model/yu_ding_da_liu_ren.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String ICONS_ASSETS_PATH = "icons";
  GlobalKey renYearGanZhiShakeKey = GlobalKey<ShakeWidgetState>();
  GlobalKey renMonthGanZhiShakeKey = GlobalKey<ShakeWidgetState>();
  GlobalKey renDayGanZhiShakeKey = GlobalKey<ShakeWidgetState>();
  GlobalKey renTimeGanZhiShakeKey = GlobalKey<ShakeWidgetState>();
  GlobalKey renDunGanZhiShakeKey = GlobalKey<ShakeWidgetState>();
  GlobalKey renJuNumberShakeKey = GlobalKey<ShakeWidgetState>();

  JiaZi? yearJiaZi;
  JiaZi? monthJiaZi;
  JiaZi? dayJiaZi;
  JiaZi? timeJiaZi;
  YinYang? yinYangDun;
  int? juNumber;

  DateTime? prevDatetime;
  final ValueNotifier<DateTime?> panDatetimeNotifier =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<DateTime?> selectedDatetimeNotifier =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<DaLiuRenKePan?> daLiuRenGongNotifier =
      ValueNotifier<DaLiuRenKePan?>(null);
  final ValueNotifier<DaLiuRenPanModel?> daLiuRenModelNotifier =
      ValueNotifier(null);
  final ValueNotifier<LunarDay?> lunarNotifier = ValueNotifier<LunarDay?>(null);
  final ValueNotifier<Tuple2<JiaZi, DiZhi>?> classNumberNotifier =
      ValueNotifier(null);
  final ValueNotifier<int?> juNumberNotifier = ValueNotifier(null);

  final ValueNotifier<bool> _showMonthGeneralJieQi = ValueNotifier(false);
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    juNumberNotifier.dispose();
    panDatetimeNotifier.dispose();
    daLiuRenGongNotifier.dispose();
    lunarNotifier.dispose();
    selectedDatetimeNotifier.dispose();
    daLiuRenModelNotifier.dispose();
    _showMonthGeneralJieQi.dispose();

    // release resources
    if (_showMonthGeneralJieQiTimer != null) {
      _showMonthGeneralJieQiTimer!.cancel();
      _showMonthGeneralJieQiTimer = null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    panDatetimeNotifier.addListener(() {
      if (prevDatetime != panDatetimeNotifier.value) {
        prevDatetime = panDatetimeNotifier.value;
        if (panDatetimeNotifier.value == null) {
          lunarNotifier.value = null;
          daLiuRenGongNotifier.value = null;
          juNumberNotifier.value = null;
        } else {
          final dt = panDatetimeNotifier.value!;
          final solarTime = SolarTime.fromYmdHms(
            dt.year,
            dt.month,
            dt.day,
            dt.hour,
            dt.minute,
            dt.second,
          );
          final lunarHour = solarTime.getLunarHour();
          final eightChar = lunarHour.getEightChar();
          final lunarDay =
              SolarDay.fromYmd(dt.year, dt.month, dt.day).getLunarDay();
          lunarNotifier.value = lunarDay;

          final baZiStr = [
            eightChar.getYear().getName(),
            eightChar.getMonth().getName(),
            eightChar.getDay().getName(),
            eightChar.getHour().getName(),
          ].join(" ");

          // Get prev term for month general
          final solarDay = SolarDay.fromYmd(dt.year, dt.month, dt.day);
          final term = solarDay.getTerm();
          final termJd = term.getJulianDay();
          final termTime = termJd.getSolarTime();
          final termAt = DateTime(
            termTime.getYear(),
            termTime.getMonth(),
            termTime.getDay(),
            termTime.getHour(),
            termTime.getMinute(),
            termTime.getSecond(),
          );
          String prevQiName;
          if (termAt.isAfter(dt)) {
            prevQiName = term.next(-1).getName();
          } else {
            prevQiName = term.getName();
          }

          var pan = DaLiuRenKePan(
            panDateTime: panDatetimeNotifier.value!,
            eightChatStr: baZiStr,
            monthGeneral: MonthGeneral.fromByStartAtJie(prevQiName),
          );
          daLiuRenGongNotifier.value = pan;
          checkPanJu(pan.dayJiaZi, pan.timeJiaZi,
                  pan.isDayGuiRen ? YinYang.YANG : YinYang.YIN)
              .then((va) => juNumberNotifier.value = va);
        }
      }
    });
    lunarNotifier.addListener(() {});
    // load json
    daLiuRenGongNotifier.addListener(() {
      if (daLiuRenGongNotifier.value != null) {
        classNumberNotifier.value = Tuple2(daLiuRenGongNotifier.value!.dayJiaZi,
            daLiuRenGongNotifier.value!.fourClass.first.sky);

        // getPan(daLiuRenGongNotifier.value!.dayJiaZi, daLiuRenGongNotifier.value!.timeJiaZi,daLiuRenGongNotifier.value!.isDayGuiRen?YinYang.YANG:YinYang.YIN);
      } else {
        classNumberNotifier.value = null;
      }
    });
    daLiuRenModelNotifier.addListener(() {
      if (daLiuRenModelNotifier.value != null) {
        classNumberNotifier.value = Tuple2(
            daLiuRenModelNotifier.value!.dayJiaZi,
            daLiuRenModelNotifier.value!.fourClass.first.sky);
        // getPan(daLiuRenGongNotifier.value!.dayJiaZi, daLiuRenGongNotifier.value!.timeJiaZi,daLiuRenGongNotifier.value!.isDayGuiRen?YinYang.YANG:YinYang.YIN);
      } else {
        classNumberNotifier.value = null;
      }
    });
  }

  List<DaLiuRenPanModel> _convertJsonToDaLiuRenPanModel(String jsonString) {
    List<DaLiuRenPanModel> classList = (json.decode(jsonString)
            as List<dynamic>)
        .map((item) => DaLiuRenPanModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return classList;
  }

  Future<int> checkPanJu(
      JiaZi dayJiaZi, JiaZi timeJiaZi, YinYang yinYangDun) async {
    Map<String, Map<String, Map<String, int>>> mapper = await loadJuMapper();
    int juNumber = mapper[dayJiaZi.name]![timeJiaZi.diZhi.name]![
        yinYangDun.isYang ? "yang" : "yin"]!;
    return juNumber;
  }

  Future<Map<String, Map<String, Map<String, int>>>> loadJuMapper() async {
    String jsonString =
        await rootBundle.loadString("assets/da_liu_ren/ju_mapper.json");

    Map<String, dynamic> decodedJson = jsonDecode(jsonString);
    Map<String, Map<String, Map<String, int>>> convertedMap =
        decodedJson.map((key, value) {
      return MapEntry(
        key,
        (value as Map<String, dynamic>).map((subKey, subValue) {
          return MapEntry(
            subKey,
            (subValue as Map<String, dynamic>).map((subSubKey, subSubValue) {
              return MapEntry(subSubKey, subSubValue as int);
            }),
          );
        }),
      );
    });

    return convertedMap;
  }

  Future<List<DaLiuRenPanModel>> loadByYinYangDun(YinYang yinYangDun) async {
    List<DaLiuRenPanModel> resultList;
    if (yinYangDun.isYang) {
      resultList = await rootBundle
          .loadString("assets/da_liu_ren/甲午庚牛羊_阳.json")
          .then(_convertJsonToDaLiuRenPanModel);
    } else {
      resultList = await rootBundle
          .loadString("assets/da_liu_ren/甲午庚牛羊_阴.json")
          .then(_convertJsonToDaLiuRenPanModel);
    }
    return resultList;
  }

  Future<DaLiuRenPanModel> loadPanByJuNumber(
      JiaZi dayJiaZi, YinYang yinYangDun, int number) async {
    // load DaLiuRenPanModel from json file at assets
    List<DaLiuRenPanModel> resultList = await loadByYinYangDun(yinYangDun);
    String juNumberName = ConstResourcesMapper.chineseNumberMapper[number]!;
    return resultList.firstWhere(
        (pan) => pan.dayJiaZi == dayJiaZi && pan.juNumberName == juNumberName);
  }

  Future<DaLiuRenPanModel> loadPanByTimeZhi(
      JiaZi dayJiaZi, DiZhi shiZhi, YinYang yinYangDun) async {
    // load DaLiuRenPanModel from json file at assets
    List<DaLiuRenPanModel> resultList = await loadByYinYangDun(yinYangDun);
    return resultList
        .firstWhere((pan) => pan.dayJiaZi == dayJiaZi && pan.shiChen == shiZhi);
  }

  Future<DaLiuRenPanModel> getPan(
      JiaZi dayJiaZi, JiaZi timeJiaZi, YinYang yinYangDun) async {
    List<DaLiuRenPanModel> list;
    if (yinYangDun.isYang) {
      list = await rootBundle
          .loadString("assets/da_liu_ren/甲午庚牛羊_阳.json")
          .then(_convertJsonToDaLiuRenPanModel);
    } else {
      list = await rootBundle
          .loadString("assets/da_liu_ren/甲午庚牛羊_阴.json")
          .then(_convertJsonToDaLiuRenPanModel);
    }
    var res = list.firstWhere(
        (p) => p.dayJiaZi == dayJiaZi && p.shiChen == timeJiaZi.diZhi);
    // print(res.fourClass.first.tianGan);
    return res;
  }

  Size panSize = const Size(400, 400);
  Size gongSize = const Size(400 * .25, 400 * .25);
  @override
  Widget build(BuildContext context) {
    if (panDatetimeNotifier.value == null) {
      panDatetimeNotifier.value = DateTime.now();
    }
    // dev 三传 九宗门
    return Scaffold(
      appBar: AppBar(
        // title: Text("大六壬"),
        title: ValueListenableBuilder(
          valueListenable: daLiuRenGongNotifier,
          builder: (ctx, daLiuRenGong, child) {
            if (daLiuRenGong != null) {
              return ValueListenableBuilder(
                  valueListenable: juNumberNotifier,
                  builder: (ctx, juNumber, _) {
                    if (juNumber != null) {
                      return Text(
                          "${daLiuRenGong.dayJiaZi.name}日·${daLiuRenGong.timeJiaZi.diZhi.name}时·${daLiuRenGong.isDayGuiRen ? "阳" : "阴"}${ConstResourcesMapper.chineseNumberMapper[juNumber]}局");
                    }
                    return child!;
                  });
            }
            return child!;
          },
          child: const Text("大六壬"),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              pan_base_info(),
              const SizedBox(
                height: 16,
              ),
              // 竖屏是使用Column
              main(),

              const SizedBox(
                height: 32,
              ),
              manuallyJu(),
              const SizedBox(
                height: 32,
              ),
              Row(
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
                        selectedDatetimeNotifier.value = result;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.green, // Background coloronPrimary: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15), // Padding
                      textStyle: const TextStyle(fontSize: 18), // Text style
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    child: const Text('选择时间'),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: () async {
                      selectedDatetimeNotifier.value = DateTime.now();
                    },
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.green, // Background coloronPrimary: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15), // Padding
                      textStyle: const TextStyle(fontSize: 18), // Text style
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    child: const Text('现在'),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (panDatetimeNotifier.value == null &&
                          daLiuRenGongNotifier.value == null &&
                          daLiuRenModelNotifier.value == null) {
                        panDatetimeNotifier.value =
                            selectedDatetimeNotifier.value ?? DateTime.now();
                      } else {
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.red, // Background coloronPrimary: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15), // Padding
                      textStyle: const TextStyle(
                          fontSize: 18, color: Colors.white), // Text style
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    child: const Text('排盘'),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (panDatetimeNotifier.value == null &&
                          daLiuRenModelNotifier.value == null &&
                          daLiuRenGongNotifier.value == null) {
                        if ([
                          yearJiaZi,
                          monthJiaZi,
                          dayJiaZi,
                          timeJiaZi,
                          yinYangDun
                        ].any((e) => e == null)) {
                          if (yearJiaZi == null) {
                            (renYearGanZhiShakeKey.currentState!
                                    as ShakeWidgetState)
                                .shake();
                          }
                          if (monthJiaZi == null) {
                            (renMonthGanZhiShakeKey.currentState!
                                    as ShakeWidgetState)
                                .shake();
                          }
                          if (dayJiaZi == null) {
                            (renDayGanZhiShakeKey.currentState!
                                    as ShakeWidgetState)
                                .shake();
                          }
                          if (yinYangDun == null) {
                            (renDunGanZhiShakeKey.currentState!
                                    as ShakeWidgetState)
                                .shake();
                          }
                          if (timeJiaZi == null && juNumber == null) {
                            (renTimeGanZhiShakeKey.currentState!
                                    as ShakeWidgetState)
                                .shake();
                            (renJuNumberShakeKey.currentState!
                                    as ShakeWidgetState)
                                .shake();
                          }
                        } else {
                          if (timeJiaZi != null) {
                            daLiuRenModelNotifier.value =
                                await loadPanByTimeZhi(
                                    dayJiaZi!, timeJiaZi!.diZhi, yinYangDun!);
                          } else if (juNumber != null) {
                            daLiuRenModelNotifier.value =
                                await loadPanByJuNumber(
                                    dayJiaZi!, yinYangDun!, juNumber!);
                          }
                        }
                      } else {
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.red, // Background coloronPrimary: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15), // Padding
                      textStyle: const TextStyle(
                          fontSize: 18, color: Colors.white), // Text style
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    child: const Text('干支排盘'),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: () async {
                      panDatetimeNotifier.value = null;
                      daLiuRenGongNotifier.value = null;
                      daLiuRenModelNotifier.value = null;
                      yearJiaZi = null;
                      monthJiaZi = null;
                      dayJiaZi = null;
                      timeJiaZi = null;
                      juNumber = null;
                      yinYangDun = null;
                    },
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.red, // Background coloronPrimary: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15), // Padding
                      textStyle: const TextStyle(
                          fontSize: 18, color: Colors.white), // Text style
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    child: const Text('清除'),
                  ),
                ],
              ),
              const SizedBox(
                height: 56,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget pan_base_info() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 240,
            height: 100,
            child: ValueListenableBuilder<DateTime?>(
                valueListenable: panDatetimeNotifier,
                // builder: (ctx, dateTime, child) => dateTime != null ? Text(DateFormat("yyyy-MM-dd HH:mm").format(dateTime!)):child!,
                builder: (ctx, dateTime, child) =>
                    dateTime != null ? buildCenterPanTime(dateTime) : child!,
                child: const SizedBox()),
          ),
          SizedBox(
            width: 260,
            height: 150,
            child: ValueListenableBuilder<DaLiuRenKePan?>(
                valueListenable: daLiuRenGongNotifier,
                builder: (ctx, pan, child) => pan != null
                    ? buildCenterFourZhu(pan.yearJiaZi, pan.monthJiaZi,
                        pan.dayJiaZi, pan.timeJiaZi)
                    : child!,
                child: const SizedBox()),
          )
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 240,
            height: 100,
            child: ValueListenableBuilder<DateTime?>(
                valueListenable: panDatetimeNotifier,
                // builder: (ctx, dateTime, child) => dateTime != null ? Text(DateFormat("yyyy-MM-dd HH:mm").format(dateTime!)):child!,
                builder: (ctx, dateTime, child) =>
                    dateTime != null ? buildCenterPanTime(dateTime) : child!,
                child: const SizedBox()),
          ),
          SizedBox(
            width: 260,
            height: 150,
            child: ValueListenableBuilder<DaLiuRenKePan?>(
                valueListenable: daLiuRenGongNotifier,
                builder: (ctx, pan, child) => pan != null
                    ? buildCenterFourZhu(pan.yearJiaZi, pan.monthJiaZi,
                        pan.dayJiaZi, pan.timeJiaZi)
                    : child!,
                child: const SizedBox()),
          )
        ],
      );
    }
  }

  Widget main() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Column(
        children: [
          Container(
            width: panSize.width,
            height: panSize.height,
            decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 251, 240, 1),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 6,
                  )
                ]),
            alignment: Alignment.center,
            child: ValueListenableBuilder<DaLiuRenKePan?>(
                valueListenable: daLiuRenGongNotifier,
                builder: (ct, pan, child) =>
                    pan == null ? child! : build_panel(pan, gongSize),
                child: ValueListenableBuilder(
                  valueListenable: daLiuRenModelNotifier,
                  builder: (ctx, pan, child) =>
                      pan == null ? child! : build_panel_model(pan, gongSize),
                  child: Container(
                    width: panSize.width,
                    height: panSize.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                )),
          ),
          const SizedBox(
            height: 16,
          ),
          ValueListenableBuilder<Tuple2<JiaZi, DiZhi>?>(
              valueListenable: classNumberNotifier,
              builder: (ctx, tuple2, child) {
                return tuple2 == null
                    ? const SizedBox()
                    : Container(
                            width: panSize.width,
                            // height: panSize.height,
                            padding: const EdgeInsets.symmetric(
                                vertical: 24, horizontal: 16),
                            decoration: BoxDecoration(
                                // color: Colors.blue.withOpacity(.1),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    spreadRadius: 6,
                                  )
                                ]),
                            child: SingleChildScrollView(
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  FutureBuilder(
                                      future:
                                          loadBy(tuple2.item1, tuple2.item2),
                                      builder: (ctx, snap) {
                                        if (snap.hasError) {
                                          logger.e(snap.error.toString());
                                        }
                                        if (snap.hasData) {
                                          return yu_ding(snap.data!);
                                        } else {
                                          return const SizedBox(
                                              height: 64,
                                              width: 64,
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      }),
                                  Positioned(
                                    top: -24,
                                    right: 0,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          // color: Colors.blue.withOpacity(.1),
                                          height: 128,
                                          width: 64,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "${ICONS_ASSETS_PATH}/tag_virt.png"))),
                                          // child:Image.asset("${ICONS_ASSETS_PATH}/tag_virt.png",),
                                        ),
                                        const Column(
                                          children: [Text("元"), Text("首")],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .animate()
                        .moveX(
                            delay: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOutQuint,
                            duration: const Duration(milliseconds: 1000),
                            begin: -128,
                            end: 0)
                        .fadeIn(
                            delay: const Duration(milliseconds: 800),
                            curve: Curves.easeInOutQuint,
                            duration: const Duration(milliseconds: 400),
                            begin: 0);
              })
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: panSize.width,
            height: panSize.height,
            decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 251, 240, 1),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 6,
                  )
                ]),
            alignment: Alignment.center,
            child: ValueListenableBuilder<DaLiuRenKePan?>(
                valueListenable: daLiuRenGongNotifier,
                builder: (ct, pan, child) =>
                    pan == null ? child! : build_panel(pan, gongSize),
                child: ValueListenableBuilder(
                  valueListenable: daLiuRenModelNotifier,
                  builder: (ctx, pan, child) =>
                      pan == null ? child! : build_panel_model(pan, gongSize),
                  child: Container(
                    width: panSize.width,
                    height: panSize.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                )),
          ),
          const SizedBox(
            width: 32,
          ),
          ValueListenableBuilder<Tuple2<JiaZi, DiZhi>?>(
              valueListenable: classNumberNotifier,
              builder: (ctx, tuple2, child) {
                return tuple2 == null
                    ? const SizedBox()
                    : Container(
                            width: panSize.width,
                            height: panSize.height,
                            padding: const EdgeInsets.symmetric(
                                vertical: 24, horizontal: 16),
                            decoration: BoxDecoration(
                                // color: Colors.blue.withOpacity(.1),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    spreadRadius: 6,
                                  )
                                ]),
                            child: SingleChildScrollView(
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  FutureBuilder(
                                      future:
                                          loadBy(tuple2.item1, tuple2.item2),
                                      builder: (ctx, snap) {
                                        if (snap.hasError) {
                                          logger.d(snap.error.toString());
                                        }
                                        if (snap.hasData) {
                                          return yu_ding(snap.data!);
                                        } else {
                                          return const SizedBox(
                                              height: 64,
                                              width: 64,
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      }),
                                  Positioned(
                                    top: -24,
                                    right: 0,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          // color: Colors.blue.withOpacity(.1),
                                          height: 128,
                                          width: 64,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "${ICONS_ASSETS_PATH}/tag_virt.png"))),
                                          // child:Image.asset("${ICONS_ASSETS_PATH}/tag_virt.png",),
                                        ),
                                        const Column(
                                          children: [Text("元"), Text("首")],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .animate()
                        .moveX(
                            delay: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOutQuint,
                            duration: const Duration(milliseconds: 1000),
                            begin: -128,
                            end: 0)
                        .fadeIn(
                            delay: const Duration(milliseconds: 800),
                            curve: Curves.easeInOutQuint,
                            duration: const Duration(milliseconds: 400),
                            begin: 0);
              })
        ],
      );
    }
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
            key: renYearGanZhiShakeKey,
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
            key: renMonthGanZhiShakeKey,
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
            key: renDayGanZhiShakeKey,
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
            key: renTimeGanZhiShakeKey,
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
            key: renDunGanZhiShakeKey,
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

                hintText: "阴阳局",
                // initialItem: "甲子",
                // items: List.generate(12, (i)=>"阳遁${ConstResourcesMapper.chineseNumberMapper[i+1]!}局")..addAll(List.generate(12, (i)=>"阴遁${ConstResourcesMapper.chineseNumberMapper[i+1]!}局")),
                items: const ["阳遁", "阴遁"],
                onChanged: (jiaZiStr) {
                  if (jiaZiStr != null) {
                    List<String> splitedList = jiaZiStr.split("");
                    yinYangDun =
                        splitedList.first == "阳" ? YinYang.YANG : YinYang.YIN;
                  } else {
                    yinYangDun = null;
                  }
                  // print(JiaZi.getFromGanZhiValue(jiaZiStr!));
                },
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          ShakeMe(
            // 4. pass the GlobalKey as an argument
            key: renJuNumberShakeKey,
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

                hintText: "局数",
                // initialItem: "甲子",
                items: List.generate(
                    12,
                    (i) =>
                        "${ConstResourcesMapper.chineseNumberMapper[i + 1]!}局"),
                onChanged: (jiaZiStr) {
                  if (jiaZiStr != null) {
                    List<String> splitedList = jiaZiStr.split("");
                    String numStr = splitedList[2];
                    juNumber = ConstResourcesMapper.chineseNumberMapper.entries
                        .firstWhere((e) => e.value == numStr)
                        .key;
                  } else {
                    juNumber = null;
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildCenterFourZhu(JiaZi year, JiaZi month, JiaZi day, JiaZi time) {
    return Card(
        child: Align(
      alignment: Alignment.center,
      child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FourZhuEightChar(
            year: year,
            month: month,
            day: day,
            chen: time,
            isColorful: true,
            zodiacGanColors: ConstResourcesMapper.zodiacGanColors,
            zodiacZhiColors: ConstResourcesMapper.zodiacZhiColors,
          )),
    ));
  }

  Widget buildCenterPanTime(DateTime time) {
    final solarDay = SolarDay.fromYmd(time.year, time.month, time.day);
    final lunarDay = solarDay.getLunarDay();
    final lunarMonth = lunarDay.getLunarMonth();
    final solarTime = SolarTime.fromYmdHms(
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
      time.second,
    );
    final lunarHour = solarTime.getLunarHour();
    final eightChar = lunarHour.getEightChar();

    // Get term info
    final term = solarDay.getTerm();
    final termJd = term.getJulianDay();
    final termTime = termJd.getSolarTime();
    final termAt = DateTime(
      termTime.getYear(),
      termTime.getMonth(),
      termTime.getDay(),
      termTime.getHour(),
      termTime.getMinute(),
      termTime.getSecond(),
    );

    String prevTermName;
    String prevTermTimeStr;
    String nextTermName;
    String nextTermTimeStr;

    if (termAt.isAfter(time)) {
      // Term hasn't started
      final prevTerm = term.next(-1);
      final prevJd = prevTerm.getJulianDay();
      final prevSt = prevJd.getSolarTime();
      prevTermName = prevTerm.getName();
      prevTermTimeStr =
          '${prevSt.getYear()}/${_pad(prevSt.getMonth())}/${_pad(prevSt.getDay())} ${_pad(prevSt.getHour())}:${_pad(prevSt.getMinute())}:${_pad(prevSt.getSecond())}';
      nextTermName = term.getName();
      nextTermTimeStr =
          '${termTime.getYear()}/${_pad(termTime.getMonth())}/${_pad(termTime.getDay())} ${_pad(termTime.getHour())}:${_pad(termTime.getMinute())}:${_pad(termTime.getSecond())}';
    } else {
      prevTermName = term.getName();
      prevTermTimeStr =
          '${termTime.getYear()}/${_pad(termTime.getMonth())}/${_pad(termTime.getDay())} ${_pad(termTime.getHour())}:${_pad(termTime.getMinute())}:${_pad(termTime.getSecond())}';
      final nextTerm = term.next(1);
      final nextJd = nextTerm.getJulianDay();
      final nextSt = nextJd.getSolarTime();
      nextTermName = nextTerm.getName();
      nextTermTimeStr =
          '${nextSt.getYear()}/${_pad(nextSt.getMonth())}/${_pad(nextSt.getDay())} ${_pad(nextSt.getHour())}:${_pad(nextSt.getMinute())}:${_pad(nextSt.getSecond())}';
    }

    // Year in GanZhi
    final yearGanZhi = eightChar.getYear().getName();
    // Lunar month/day Chinese
    final monthCn = lunarMonth.getName();
    final dayCn = lunarDay.getName();
    // Time Zhi
    final timeZhi = eightChar.getHour().getName().substring(1);

    return Card(
        child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              child: Column(children: [
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
                          "${yearGanZhi}年 ${monthCn}月 $dayCn ${timeZhi}时",
                          style: TextStyle(
                              fontSize: 14, color: Colors.blueGrey.shade800),
                        )),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(flex: 3, child: Text("$prevTermName:")),
                    Flexible(
                        flex: 7,
                        child: Text(
                          prevTermTimeStr,
                          style: TextStyle(
                              fontSize: 14, color: Colors.blueGrey.shade800),
                        )),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(flex: 3, child: Text("$nextTermName:")),
                    Flexible(
                        flex: 7,
                        child: Text(
                          nextTermTimeStr,
                          style: TextStyle(
                              fontSize: 14, color: Colors.blueGrey.shade800),
                        )),
                  ],
                )
              ]),
            )));
  }

  static String _pad(int v) => v.toString().padLeft(2, '0');

  Widget yu_ding(YuDingDaLiuRen yuDing) {
    return Column(
      children: [
        Container(
          child: Text(
            "${yuDing.dayJiaZi.name}日 第${ConstResourcesMapper.chineseNumberMapper[yuDing.juNumber]!} 干上${yuDing.juName.name}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          child: RichText(
              text: TextSpan(
                  text: yuDing.body.join(" "),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)
                  // children: yuDing.body.join(" ").map((e)=>TextSpan(text:e)).toList()
                  )),
        ),
        RichText(
          text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              text: "课义：",
              children: [TextSpan(text: yuDing.meaning)]),
        ),
        const SizedBox(
          height: 12,
        ),
        RichText(
          text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              text: "解曰：",
              children: [TextSpan(text: yuDing.explain)]),
        ),
        const SizedBox(
          height: 12,
        ),
        RichText(
          text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              text: "断曰：",
              children: [TextSpan(text: yuDing.predication)]),
        ),
        const SizedBox(
          height: 12,
        ),
        ...yuDing.details.entries
            .map((entry) => RichText(
                  text: TextSpan(
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                      text: "${entry.key}：",
                      children: [TextSpan(text: entry.value)]),
                ))
            .toList(),
        const SizedBox(
          height: 12,
        ),
        ...yuDing.books.entries
            .map((entry) => RichText(
                  text: TextSpan(
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                      text: "${entry.key}：",
                      children: [TextSpan(text: entry.value)]),
                ))
            .toList()
      ],
    );
  }
  // String numberToStrName(int number){
  //   var res = ["一","二","三","四","五","六","七","八","九","十","十一","十二"][number-1];
  //   return "$res局";
  // }

  Future<YuDingDaLiuRen> loadBy(JiaZi dayJiaZi, DiZhi dayUpperDiZhi) async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/da_liu_ren/御定大六壬.json');
      Iterable res = json.decode(jsonString);
      List<YuDingDaLiuRen> all = List<YuDingDaLiuRen>.from(
          res.map((model) => YuDingDaLiuRen.fromJson(model)));
      var result = all.firstWhere(
          (y) => y.dayJiaZi == dayJiaZi && y.juName == dayUpperDiZhi);
      return result;
    } catch (e) {
      logger.e(e.toString());
      rethrow;
    }
  }

  Widget build_panel_model(DaLiuRenPanModel panModel, Size gongSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        panel_gong(panModel, gongSize),
        SizedBox(
          width: gongSize.width * 2,
          height: gongSize.height * 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: gongSize.height,
                width: gongSize.width,
                // color: Colors.orange.withOpacity(.2),
                child: build_four_ke(panModel.getFourClass()),
              ),
              Container(
                height: gongSize.height,
                width: gongSize.width,
                alignment: Alignment.center,
                // color: Colors.orange.withOpacity(.4),
                child: build_san_chuan(panModel.getThreeChuan()),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget build_panel(DaLiuRenKePan daLiuPan, Size gongSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        panel_gong(daLiuPan, gongSize),
        panel_center(daLiuPan, gongSize),
      ],
    );
  }

  Widget panel_center(DaLiuRenKePan daLiuPan, Size gongSize) {
    double width = gongSize.width * 2;
    double height = gongSize.height * 2;
    return SizedBox(
      width: width,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // buildMonthGeneral(daLiuPan),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onHover: (isHover) {
                      logger.d("isHover $isHover}");
                    },
                    onTap: () => showMonthlyGeneralJieQi(),
                    onLongPress: () {
                      logger.d("on long press ${_showMonthGeneralJieQi.value}");
                      if (_showMonthGeneralJieQi.value) {
                        logger.d("on long press is true");
                        if (_showMonthGeneralJieQiTimer != null) {
                          logger.d("on long press is with cancel timer");
                          _showMonthGeneralJieQiTimer!.cancel();
                          _showMonthGeneralJieQiTimer = null;
                          isLongSticky = true;
                        } else {
                          logger.d("on long press is with hidden");
                          hideMonthlyGeneralJieQi();
                          isLongSticky = false;
                        }
                      } else {
                        isLongSticky = true;
                        showMonthlyGeneralJieQi(autoHidden: false);
                      }
                    },
                    child: MouseRegion(
                      onEnter: (e) =>
                          !isLongSticky ? showMonthlyGeneralJieQi() : null,
                      onExit: (e) =>
                          !isLongSticky ? hideMonthlyGeneralJieQi() : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                        "${ICONS_ASSETS_PATH}/chinese-red-ink-seal.png"),
                                    colorFilter: ColorFilter.mode(
                                        Color.fromRGBO(176, 31, 36, .8),
                                        BlendMode.srcIn))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(daLiuPan.monthGeneral.name.split("").first,
                                    style: guiRenNameTextStyle.copyWith(
                                        fontSize: 28)),
                                Text(daLiuPan.monthGeneral.name.split("").last,
                                    style: guiRenNameTextStyle.copyWith(
                                        fontSize: 28)),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "︹",
                                style: guiRenNameTextStyle.copyWith(
                                    height: 1.0, fontSize: 12),
                              ),
                              Text(
                                daLiuPan.monthGeneral.generalZhi.name,
                                style: diZhiTextStyle.copyWith(
                                    height: 1.0,
                                    fontSize: 14,
                                    color: getZhiColor(
                                        daLiuPan.monthGeneral.generalZhi),
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.grey.withOpacity(.5),
                                        offset: const Offset(0, 0),
                                        blurRadius: 2,
                                      )
                                    ]),
                              ),
                              Text(
                                "将",
                                style: guiRenNameTextStyle.copyWith(
                                    height: 1.0, fontSize: 12),
                              ),
                              Text(
                                "︺",
                                style: guiRenNameTextStyle.copyWith(
                                    height: 1.0, fontSize: 12),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  ValueListenableBuilder(
                      valueListenable: _showMonthGeneralJieQi,
                      builder: (ctx, show, child) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (c, animation) {
                            if ((c.key as ValueKey).value == "jie_qi") {
                              logger.d("display jie_qi");
                              // display jie_qi
                              return c
                                  .animate()
                                  .moveY(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      begin: -2,
                                      end: 0)
                                  .fade(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      begin: 0,
                                      end: 1);
                            } else {
                              logger.d("hidden jie_qi");
                              return c
                                  .animate()
                                  .moveY(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      begin: 0,
                                      end: -1)
                                  .fade(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      begin: 1,
                                      end: 0);
                            }
                          },
                          child: show
                              ? child
                              : const SizedBox(
                                  key: ValueKey("blank"),
                                ),
                        );
                      },
                      child: Column(
                        key: const ValueKey("jie_qi"),
                        children: [
                          SizedBox(
                              width: 30,
                              child: TwentyFourJieQiTag(
                                jieQi: daLiuPan.monthGeneral.jieSegment.item1,
                                fontColor: Colors.blueGrey,
                                backgroundColor: ConstResourcesMapper
                                    .Seasons24ColorMapper[daLiuPan
                                        .monthGeneral.jieSegment.item1.name]!
                                    .withOpacity(.2),
                                isHor: true,
                              )),
                          const SizedBox(height: 2),
                          SizedBox(
                              width: 30,
                              child: TwentyFourJieQiTag(
                                  jieQi: daLiuPan.monthGeneral.jieSegment.item2,
                                  fontColor: Colors.blueGrey,
                                  backgroundColor: ConstResourcesMapper
                                      .Seasons24ColorMapper[daLiuPan
                                          .monthGeneral.jieSegment.item2.name]!
                                      .withOpacity(.2),
                                  isHor: true)),
                        ],
                      ))
                ],
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: buildClassType(daLiuPan))
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              build_san_chuan(daLiuPan.getThreeChuan()),
              build_four_ke(daLiuPan.getFourClass()),
            ],
          )
        ],
      ),
    );
  }

  Widget buildMonthGeneral(DaLiuRenKePan daLiuPan) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 24,
                  child: TwentyFourJieQiTag(
                    jieQi: daLiuPan.monthGeneral.jieSegment.item1,
                    fontColor: Colors.blueGrey,
                    backgroundColor: ConstResourcesMapper.Seasons24ColorMapper[
                            daLiuPan.monthGeneral.jieSegment.item1.name]!
                        .withOpacity(.2),
                    isHor: true,
                  )),
              SizedBox(
                  width: 24,
                  child: TwentyFourJieQiTag(
                      jieQi: daLiuPan.monthGeneral.jieSegment.item2,
                      fontColor: Colors.blueGrey,
                      backgroundColor: ConstResourcesMapper
                          .Seasons24ColorMapper[
                              daLiuPan.monthGeneral.jieSegment.item2.name]!
                          .withOpacity(.2),
                      isHor: true)),
            ],
          ),
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(
                        "${ICONS_ASSETS_PATH}/chinese-red-ink-seal.png"),
                    colorFilter: ColorFilter.mode(
                        Color.fromRGBO(176, 31, 36, .8), BlendMode.srcIn))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(daLiuPan.monthGeneral.name.split("").first,
                    style: guiRenNameTextStyle.copyWith(fontSize: 28)),
                Text(daLiuPan.monthGeneral.name.split("").last,
                    style: guiRenNameTextStyle.copyWith(fontSize: 28)),
                // Text(daLiuPan.monthGeneral.name.split("").first,style: guiRenNameTextStyle.copyWith(fontSize: 28,color: Color.fromRGBO(242,190,69, 1)),),
                // Text(daLiuPan.monthGeneral.name.split("").last,style: guiRenNameTextStyle.copyWith(fontSize: 28,color: Color.fromRGBO(242,190,69, 1)),),
                // GoldText(text: daLiuPan.monthGeneral.name.split("").first,style: guiRenNameTextStyle.copyWith(fontSize: 28,color: Colors.white,fontWeight: FontWeight.w200)),
                // GoldText(text: daLiuPan.monthGeneral.name.split("").last,style: guiRenNameTextStyle.copyWith(fontSize: 28,color: Colors.white,fontWeight: FontWeight.w200)),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "︹",
                style: guiRenNameTextStyle.copyWith(height: 1.0, fontSize: 12),
              ),
              Text(
                daLiuPan.monthGeneral.generalZhi.name,
                style: diZhiTextStyle.copyWith(
                    height: 1.0,
                    fontSize: 14,
                    color: getZhiColor(daLiuPan.monthGeneral.generalZhi),
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.grey.withOpacity(.5),
                        offset: const Offset(0, 0),
                        blurRadius: 2,
                      )
                    ]),
              ),
              Text(
                "将",
                style: guiRenNameTextStyle.copyWith(height: 1.0, fontSize: 12),
              ),
              Text(
                "︺",
                style: guiRenNameTextStyle.copyWith(height: 1.0, fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
    return Container(
      alignment: Alignment.center,
      // height: 120,
      // width: 120,
      // color: Colors.black.withOpacity(.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 14,
                        child: TwentyFourJieQiTag(
                          jieQi: daLiuPan.monthGeneral.jieSegment.item1,
                          fontColor: Colors.blueGrey,
                        )),
                    SizedBox(
                        width: 14,
                        child: TwentyFourJieQiTag(
                          jieQi: daLiuPan.monthGeneral.jieSegment.item2,
                          fontColor: Colors.blueGrey,
                        )),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(
                              "${ICONS_ASSETS_PATH}/chinese-red-ink-seal.png"),
                          colorFilter: ColorFilter.mode(
                              Color.fromRGBO(176, 31, 36, .8),
                              BlendMode.srcIn))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(daLiuPan.monthGeneral.name.split("").first,
                          style: guiRenNameTextStyle.copyWith(fontSize: 28)),
                      Text(daLiuPan.monthGeneral.name.split("").last,
                          style: guiRenNameTextStyle.copyWith(fontSize: 28)),
                      // Text(daLiuPan.monthGeneral.name.split("").first,style: guiRenNameTextStyle.copyWith(fontSize: 28,color: Color.fromRGBO(242,190,69, 1)),),
                      // Text(daLiuPan.monthGeneral.name.split("").last,style: guiRenNameTextStyle.copyWith(fontSize: 28,color: Color.fromRGBO(242,190,69, 1)),),
                      // GoldText(text: daLiuPan.monthGeneral.name.split("").first,style: guiRenNameTextStyle.copyWith(fontSize: 28,color: Colors.white,fontWeight: FontWeight.w200)),
                      // GoldText(text: daLiuPan.monthGeneral.name.split("").last,style: guiRenNameTextStyle.copyWith(fontSize: 28,color: Colors.white,fontWeight: FontWeight.w200)),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "︹",
                      style: guiRenNameTextStyle.copyWith(
                          height: 1.0, fontSize: 12),
                    ),
                    Text(
                      daLiuPan.monthGeneral.generalZhi.name,
                      style: diZhiTextStyle.copyWith(
                          height: 1.0,
                          fontSize: 14,
                          color: getZhiColor(daLiuPan.monthGeneral.generalZhi),
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.grey.withOpacity(.5),
                              offset: const Offset(0, 0),
                              blurRadius: 2,
                            )
                          ]),
                    ),
                    Text(
                      "将",
                      style: guiRenNameTextStyle.copyWith(
                          height: 1.0, fontSize: 12),
                    ),
                    Text(
                      "︺",
                      style: guiRenNameTextStyle.copyWith(
                          height: 1.0, fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFourZhuEightChar(DaLiuRenKePan daLiuPan) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FourZhuEightChar(
            year: daLiuPan.yearJiaZi,
            month: daLiuPan.monthJiaZi,
            day: daLiuPan.dayJiaZi,
            chen: daLiuPan.timeJiaZi,
            isColorful: true,
            zodiacGanColors: ConstResourcesMapper.zodiacGanColors,
            zodiacZhiColors: ConstResourcesMapper.zodiacZhiColors,
          ),
        ],
      ),
    );
  }

  Widget buildClassType(DaLiuRenKePan daLiuPan) {
    List<String> classTypeList = ["退茹", "斩关", "乱首", "不备"];
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            daLiuPan.threeChuan.nineZongMen.name,
            style: eightSeasonTextStyle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade800),
          ),
          if (classTypeList.isNotEmpty)
            ...classTypeList
                .map((e) => RichText(
                    strutStyle: const StrutStyle(height: 1),
                    text: TextSpan(
                      style: eightSeasonTextStyle.copyWith(
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                          color: Colors.blueGrey.shade800),
                      text: e,
                    )))
                .toList()
        ]);
  }

  TextStyle diZhiTextStyle = GoogleFonts.maShanZheng(height: 1, fontSize: 32);
  TextStyle godsNameTextStyle =
      GoogleFonts.zhiMangXing(height: 1, fontSize: 18);

  bool withDiZhiColor = true;

  Text wrappedDiZhiText(DiZhi diZhi, TextStyle textStyle) {
    if (withDiZhiColor) {
      return Text(
        diZhi.value,
        style: textStyle.copyWith(
            color: ConstResourcesMapper.zodiacZhiColors[diZhi]!),
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        diZhi.value,
        textAlign: TextAlign.center,
      );
    }
  }

  Widget build_four_ke(FourClass fourClass) {
    double diZhiFontSize = gongSize.width * .24;
    double otherFontSize = gongSize.width * .24;
    TextStyle tianGanStyle = ConstUIResourcesMapper.tianGanTextStyle
        .copyWith(fontSize: diZhiFontSize, shadows: [
      Shadow(
          color: Colors.grey.withOpacity(.5),
          blurRadius: 2,
          offset: const Offset(0, 0))
    ]);
    TextStyle diZhiStyle = ConstUIResourcesMapper.twelveDiZhiTextStyle
        .copyWith(fontSize: diZhiFontSize, shadows: [
      Shadow(
          color: Colors.grey.withOpacity(.5),
          blurRadius: 2,
          offset: const Offset(0, 0))
    ]);
    TextStyle guiRenName =
        guiRenNameTextStyle.copyWith(fontSize: gongSize.width * .14, shadows: [
      Shadow(
          color: Colors.grey.withOpacity(.5),
          blurRadius: 2,
          offset: const Offset(0, 0))
    ]);
    SizedBox intervalSize = const SizedBox(width: 6);
    double height = gongSize.height;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "四",
              style: GoogleFonts.maShanZheng(height: 1, fontSize: 18),
            ),
            Text(fourClass.fourth.guiRen.name, style: guiRenName),
            Text(fourClass.fourth.sky.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(fourClass.fourth.sky))),
            Text(fourClass.fourth.ground.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(fourClass.fourth.ground)))
          ],
        ),
        intervalSize,
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "三",
              style: GoogleFonts.maShanZheng(height: 1, fontSize: 18),
            ),
            Text(fourClass.third.guiRen.name, style: guiRenName),
            Text(fourClass.third.sky.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(fourClass.third.sky))),
            Text(fourClass.third.ground.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(fourClass.third.ground)))
          ],
        ),
        intervalSize,
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "二",
              style: GoogleFonts.maShanZheng(height: 1, fontSize: 18),
            ),
            Text(fourClass.second.guiRen.name, style: guiRenName),
            Text(fourClass.second.sky.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(fourClass.second.sky))),
            Text(fourClass.second.ground.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(fourClass.second.ground)))
          ],
        ),
        intervalSize,
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "一",
                    style: GoogleFonts.maShanZheng(height: 1, fontSize: 18),
                  ),
                  Text(fourClass.first.guiRen.name, style: guiRenName),
                  Center(
                    child: Text(fourClass.first.sky.value,
                        style: diZhiStyle.copyWith(
                            color: getZhiColor(fourClass.first.sky))),
                  ),
                  Center(
                    child: Text(fourClass.first.tianGan.value,
                        style: tianGanStyle.copyWith(
                            color: getGanColor(fourClass.first.tianGan))),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(fourClass.first.ground.value,
                    style: diZhiStyle.copyWith(
                        color: getZhiColor(fourClass.first.ground),
                        fontSize: gongSize.width * .16)),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget build_san_chuan(ThreeChuan chuan) {
    double diZhiFontSize = gongSize.width * .24;
    TextStyle otherStyle =
        guiRenNameTextStyle.copyWith(fontSize: gongSize.width * .16, shadows: [
      Shadow(
          color: Colors.grey.withOpacity(.5),
          blurRadius: 2,
          offset: const Offset(0, 0))
    ]);

    // TextStyle jiaZi = otherStyle.copyWith(fontSize: 20);
    TextStyle tianGanStyle = ConstUIResourcesMapper.tianGanTextStyle
        .copyWith(fontSize: gongSize.width * .2, shadows: [
      Shadow(
          color: Colors.grey.withOpacity(.5),
          blurRadius: 2,
          offset: const Offset(0, 0))
    ]);
    TextStyle diZhiStyle = ConstUIResourcesMapper.twelveDiZhiTextStyle
        .copyWith(fontSize: diZhiFontSize, shadows: [
      Shadow(
          color: Colors.grey.withOpacity(.5),
          blurRadius: 2,
          offset: const Offset(0, 0))
    ]);
    // TextStyle sixQing = guiRenNameTextStyle.copyWith(fontSize: gongSize.width * .16,shadows:[Shadow(color: Colors.grey.withOpacity(.5), blurRadius: 2, offset: Offset(0, 0))]);
    SizedBox offset = const SizedBox(width: 4);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "初",
              style: otherStyle,
            ),
            offset,
            // Text("兄弟",style: otherStyle),
            Text(chuan.first.liuQin.name, style: otherStyle),
            offset,
            // Text(chuan.first.tianGan?.value ?? "○", style: otherStyle,),
            chuan.first.tianGan == null
                ? buildKongWangCircle(otherStyle.color, 16)
                : Text(chuan.first.tianGan!.value,
                    style: tianGanStyle.copyWith(
                        color: getGanColor(chuan.first.tianGan!))),
            Text(chuan.first.diZhi.value,
                style:
                    diZhiStyle.copyWith(color: getZhiColor(chuan.first.diZhi))),
            offset,
            Text(chuan.first.guiRen.name, style: otherStyle)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("中", style: otherStyle),
            offset,
            Text(chuan.second.liuQin.name, style: otherStyle),
            offset,
            chuan.second.tianGan == null
                ? buildKongWangCircle(otherStyle.color, 16)
                : Text(chuan.second.tianGan!.value,
                    style: tianGanStyle.copyWith(
                        color: getGanColor(chuan.second.tianGan!))),
            Text(chuan.second.diZhi.value,
                style: diZhiStyle.copyWith(
                    color: getZhiColor(chuan.second.diZhi))),
            offset,
            Text(chuan.second.guiRen.name, style: otherStyle)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("末", style: otherStyle),
            offset,
            Text(chuan.third.liuQin.name, style: otherStyle),
            offset,
            chuan.third.tianGan == null
                ? buildKongWangCircle(otherStyle.color, 16)
                : Text(chuan.third.tianGan!.value,
                    style: tianGanStyle.copyWith(
                        color: getGanColor(chuan.third.tianGan!))),
            Text(chuan.third.diZhi.value,
                style:
                    diZhiStyle.copyWith(color: getZhiColor(chuan.third.diZhi))),
            offset,
            Text(chuan.third.guiRen.name, style: otherStyle)
          ],
        ),
      ],
    );
  }

  TextStyle normalTextStyle =
      GoogleFonts.zhiMangXing(color: Colors.black87, fontSize: 12, height: 1.0);

  Widget each_zhu(
      String name, JiaZi xunHead, JiaZi jiaZi, Tuple2<DiZhi, DiZhi> kongWang) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          style: ConstUIResourcesMapper.twelveDiZhiTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.0,
              shadows: []),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          xunHead.ganZhiStr,
          style: normalTextStyle.copyWith(fontSize: 16),
        ),
        Container(
          height: 30,
          width: 30,
          alignment: Alignment.center,
          child: Text(jiaZi.tianGan.value,
              style: eightSeasonTextStyle.copyWith(
                  fontSize: 28,
                  color: ConstResourcesMapper.zodiacGanColors[jiaZi.tianGan]!,
                  fontWeight: FontWeight.w100)),
        ),
        // SizedBox(height: 2,),
        Container(
          height: 30,
          width: 30,
          alignment: Alignment.center,
          child: Text(jiaZi.diZhi.value,
              style: ConstUIResourcesMapper.twelveDiZhiTextStyle.copyWith(
                  fontSize: 28,
                  color: ConstResourcesMapper.zodiacZhiColors[jiaZi.diZhi],
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(
          height: 3,
        ),
        Text(
          "${kongWang.item1.value}${kongWang.item2.value}",
          style: normalTextStyle.copyWith(fontSize: 16),
        )
      ],
    );
  }

  Widget panel_gong(DaLiuRenPanel daLiuPan, Size gongSize) {
    // double width = 200;
    // double height = 200;
    Map<DiZhi, Widget> gongWidgetMapper = {};
    daLiuPan.getGongMapper().forEach((key, value) {
      gongWidgetMapper[key] = content(value.groundPanDiZhi, value, gongSize);
    });
    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                  child: gongWidgetMapper[DiZhi.SI]!,
                ),
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                  child: gongWidgetMapper[DiZhi.WU],
                ),
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                  child: gongWidgetMapper[DiZhi.WEI],
                ),
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                  child: gongWidgetMapper[DiZhi.SHEN],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                  child: gongWidgetMapper[DiZhi.CHEN]!,
                ),
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                ),
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                ),
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                  child: gongWidgetMapper[DiZhi.YOU],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                  child: gongWidgetMapper[DiZhi.MAO],
                ),
                // center blank
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                ),
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                ),
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                  child: gongWidgetMapper[DiZhi.XU],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                  child: gongWidgetMapper[DiZhi.YIN],
                ),
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                  child: gongWidgetMapper[DiZhi.CHOU],
                ),
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                  child: gongWidgetMapper[DiZhi.ZI],
                ),
                SizedBox(
                  width: gongSize.width,
                  height: gongSize.height,
                  child: gongWidgetMapper[DiZhi.HAI],
                )
              ],
            ),
          ],
        ));
  }

  Widget content(DiZhi diZhi, DaLiuRenGong gong, Size gongSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        backgroundContent(diZhi, gongSize),
        buildTianGanJiZhi(diZhi),
        eachGong(gong, gongSize)
      ],
    );
  }

  Widget buildTianGanJiZhi(DiZhi diZhi, {bool isSecond = false}) {
    double defaultOpacity = .3;
    BoxDecoration boxDecoration =
        BoxDecoration(borderRadius: BorderRadius.circular(4), boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 1,
      ),
    ]);
    TextStyle fontStyle = TextStyle(
        color: Colors.white,
        fontSize: gongSize.width * .12,
        height: 1,
        fontWeight: FontWeight.bold);
    if (diZhi == DiZhi.YIN) {
      TianGan gan = TianGan.JIA;
      return Positioned(
        left: gongSize.width * .1,
        child: Opacity(
          opacity: defaultOpacity,
          child: Container(
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: boxDecoration.copyWith(color: getGanColor(gan)),
            child: Text(gan.name, style: fontStyle),
          ),
        ),
      );
    } else if (diZhi == DiZhi.CHEN) {
      TianGan gan = TianGan.YI;
      return Positioned(
        left: gongSize.width * .1,
        child: Opacity(
          opacity: defaultOpacity,
          child: Container(
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: boxDecoration.copyWith(color: getGanColor(gan)),
            child: Text(gan.name, style: fontStyle),
          ),
        ),
      );
    } else if (diZhi == DiZhi.CHOU) {
      TianGan gan = TianGan.GUI;
      return Positioned(
        left: gongSize.width * .1,
        child: Opacity(
          opacity: defaultOpacity,
          child: Container(
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: boxDecoration.copyWith(color: getGanColor(gan)),
            child: Text(gan.name, style: fontStyle),
          ),
        ),
      );
    } else if (diZhi == DiZhi.HAI) {
      TianGan gan = TianGan.REN;
      return Positioned(
        left: gongSize.width * .1,
        child: Opacity(
          opacity: defaultOpacity,
          child: Container(
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: boxDecoration.copyWith(color: getGanColor(gan)),
            child: Text(gan.name, style: fontStyle),
          ),
        ),
      );
    } else if (diZhi == DiZhi.XU) {
      TianGan gan = TianGan.XIN;
      return Positioned(
        left: gongSize.width * .1,
        top: gongSize.width * .1,
        child: Opacity(
          opacity: defaultOpacity,
          child: Container(
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: boxDecoration.copyWith(color: getGanColor(gan)),
            child: Text(gan.name, style: fontStyle),
          ),
        ),
      );
    } else if (diZhi == DiZhi.SHEN) {
      TianGan gan = TianGan.GENG;
      return Positioned(
        left: gongSize.width * .1,
        child: Opacity(
          opacity: defaultOpacity,
          child: Container(
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: boxDecoration.copyWith(color: getGanColor(gan)),
            child: Text(gan.name, style: fontStyle),
          ),
        ),
      );
    } else if (diZhi == DiZhi.SI) {
      TianGan gan = TianGan.BING;
      TianGan gan1 = TianGan.WU;
      return Positioned(
        left: gongSize.width * .1,
        top: gongSize.width * .2,
        child: Column(
          children: [
            Opacity(
              opacity: defaultOpacity,
              child: Container(
                padding: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: boxDecoration.copyWith(color: getGanColor(gan)),
                child: Text(gan.name, style: fontStyle),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Opacity(
              opacity: defaultOpacity,
              child: Container(
                padding: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: boxDecoration.copyWith(color: getGanColor(gan1)),
                child: Text(gan1.name, style: fontStyle),
              ),
            ),
          ],
        ),
      );
    } else if (diZhi == DiZhi.WEI) {
      TianGan gan = TianGan.DING;
      TianGan gan1 = TianGan.JI;
      return Positioned(
        left: gongSize.width * .1,
        top: gongSize.width * .2,
        child: Column(
          children: [
            Opacity(
              opacity: defaultOpacity,
              child: Container(
                padding: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: boxDecoration.copyWith(color: getGanColor(gan)),
                child: Text(gan.name, style: fontStyle),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Opacity(
              opacity: defaultOpacity,
              child: Container(
                padding: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: boxDecoration.copyWith(color: getGanColor(gan1)),
                child: Text(gan1.name, style: fontStyle),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget eachGong(DaLiuRenGong gong, Size gongSize) {
    return Container(
      width: gongSize.width,
      height: gongSize.height,
      alignment: Alignment.center,
      child: centerContent(gong, gongSize),
    );
  }

  Widget backgroundContent(DiZhi diZhi, Size gongSize) {
    BorderRadius radius = BorderRadius.zero;
    double borderRadiusSize = 32;
    Border border = Border.all(color: Colors.grey, width: 1);
    BorderSide defaultBorderSide =
        const BorderSide(color: Colors.grey, width: 1);
    Alignment alignment = Alignment.center;
    switch (diZhi) {
      case DiZhi.ZI:
        border = Border(
            top: defaultBorderSide,
            bottom: defaultBorderSide,
            left: defaultBorderSide);
        alignment = Alignment.topCenter;
        break;
      case DiZhi.CHOU:
        border = Border(top: defaultBorderSide, bottom: defaultBorderSide);
        alignment = Alignment.topCenter;
        break;
      case DiZhi.WU:
        alignment = Alignment.bottomCenter;
        border = Border(
            top: defaultBorderSide,
            bottom: defaultBorderSide,
            right: defaultBorderSide);
        break;
      case DiZhi.WEI:
        alignment = Alignment.bottomCenter;
        border = Border(top: defaultBorderSide, bottom: defaultBorderSide);
        break;

      case DiZhi.CHEN:
        border = Border(left: defaultBorderSide, right: defaultBorderSide);
        alignment = Alignment.centerRight;
        break;
      case DiZhi.YOU:
        border = Border(left: defaultBorderSide, right: defaultBorderSide);
        alignment = Alignment.centerLeft;
        break;
      case DiZhi.XU:
        border = Border(
            left: defaultBorderSide,
            right: defaultBorderSide,
            top: defaultBorderSide);
        alignment = Alignment.centerLeft;
        break;
      case DiZhi.MAO:
        alignment = Alignment.centerRight;
        border = Border(
            left: defaultBorderSide,
            right: defaultBorderSide,
            top: defaultBorderSide);
        break;

      case DiZhi.YIN:
        alignment = Alignment.topRight;
        radius =
            BorderRadius.only(bottomLeft: Radius.circular(borderRadiusSize));
        break;

      case DiZhi.SI:
        alignment = Alignment.bottomRight;
        radius = BorderRadius.only(topLeft: Radius.circular(borderRadiusSize));
        break;
      case DiZhi.SHEN:
        alignment = Alignment.bottomLeft;
        radius = BorderRadius.only(topRight: Radius.circular(borderRadiusSize));
        break;
      case DiZhi.HAI:
        alignment = Alignment.topLeft;
        radius =
            BorderRadius.only(bottomRight: Radius.circular(borderRadiusSize));
        break;
    }
    // return Container(
    //     width: gongSize.width,
    //     height: gongSize.height,
    //     alignment: alignment,
    //     padding: EdgeInsets.all(12),
    //     decoration: BoxDecoration(
    //       color: Colors.red.withOpacity(.2),
    //         border:border,
    //         borderRadius: radius
    //     ),
    //     // child: Text(diZhi.value,style: ConstUIResourcesMapper.twelveDiZhiTextStyle.copyWith(color: Colors.grey.withOpacity(.2),fontSize: gongSize.width * .3),)
    //   child: Stack(
    //     alignment: Alignment.center,
    //     children: [
    //
    //       Text(diZhi.value,style: ConstUIResourcesMapper.twelveDiZhiTextStyle.copyWith(color: Colors.grey.withOpacity(.2),fontSize: gongSize.width * .3),)
    //     ],
    //   ),
    // );
    return Container(
        width: gongSize.width,
        height: gongSize.height,
        alignment: alignment,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: border, borderRadius: radius),
        child: Text(
          diZhi.value,
          style: ConstUIResourcesMapper.twelveDiZhiTextStyle.copyWith(
              color: Colors.grey.withOpacity(.2),
              fontSize: gongSize.width * .3),
        ));
  }

  // zhiMangXing
  TextStyle guiRenNameTextStyle = GoogleFonts.maShanZheng(
      fontSize: 24,
      color: const Color.fromRGBO(68, 68, 60, 1), // 墨染
      // color: Color.fromRGBO(255, 229, 248, 1), // 墨染
      height: 1.0,
      shadows: [
        Shadow(
            color: Colors.grey.withOpacity(.5),
            blurRadius: 2,
            offset: const Offset(0, 0))
      ]);
  TextStyle nineGongNumberTextStyle = GoogleFonts.notoSerif(
    color: Colors.black,
    fontSize: 20,
    height: 1,
  );
  TextStyle eightSkyDoorTextStyle = GoogleFonts.maShanZheng(
    fontSize: 16,
    color: Colors.grey,
    // fontWeight: FontWeight.w600,
  );
  TextStyle twelveDiZhiTextStyle = GoogleFonts.longCang(
      color: Colors.black,
      fontSize: 48,
      height: 1,
      fontWeight: FontWeight.w500,
      shadows: [
        Shadow(
            color: Colors.grey.withOpacity(.5),
            blurRadius: 2,
            offset: const Offset(0, 0))
      ]);
  TextStyle eightSeasonTextStyle = GoogleFonts.zhiMangXing(
      color: const Color.fromRGBO(28, 45, 37, 1),
      fontWeight: FontWeight.w200,
      fontSize: 26,
      height: 1,
      shadows: [
        Shadow(
            color: Colors.grey.withOpacity(.5),
            blurRadius: 2,
            offset: const Offset(0, 0))
      ]);

  Widget centerContent(DaLiuRenGong daLiuRenGong, Size gongSize) {
    double middleHeight = gongSize.height * .5;
    double middleWidth = gongSize.height * .5;
    double godFontSize = gongSize.height * .16;
    double jiaZiFontSize = gongSize.height * .16;
    return Container(
      height: gongSize.height,
      width: gongSize.width,
      alignment: Alignment.center,
      // padding: EdgeInsets.only(top: gongSize.height * .1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              height: gongSize.height * .16,
              width: gongSize.height * .34,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  daLiuRenGong.guiRen == GuiRen.GUI_REN
                      ? SizedBox(
                          width: gongSize.height * .34,
                          child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                  Color.fromRGBO(176, 31, 36, .7),
                                  BlendMode.srcIn),
                              child: Image.asset(
                                "${ICONS_ASSETS_PATH}/wide-black-ink-radian-line2.png",
                              )))
                      : const SizedBox(),
                  Text(
                    daLiuRenGong.guiRen.name,
                    style: guiRenNameTextStyle.copyWith(fontSize: godFontSize),
                  ),
                ],
              )),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: gongSize.width * .2,
              ),
              Container(
                height: gongSize.width * .4,
                alignment: Alignment.center,
                child: Text(
                  daLiuRenGong.skyPanDiZhi.value,
                  style: ConstUIResourcesMapper.twelveDiZhiTextStyle.copyWith(
                      color: ConstResourcesMapper
                          .zodiacZhiColors[daLiuRenGong.skyPanDiZhi]!,
                      fontSize: gongSize.width * .4),
                ),
              ),
              Container(
                height: middleHeight,
                width: gongSize.width * .2,
                alignment: Alignment.bottomCenter,
                // color: Colors.red.withOpacity(.5),
                // padding: EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(child: SizedBox()),
                    daLiuRenGong.tianGan == null
                        ? buildKongWangCircle(
                            const Color.fromRGBO(25, 44, 59, 1),
                            gongSize.width * .2)
                        : Text(
                            daLiuRenGong.tianGan!.value,
                            style: ConstUIResourcesMapper.tianGanTextStyle
                                .copyWith(
                                    color: getGanColor(daLiuRenGong.tianGan!),
                                    fontSize: gongSize.width * .2),
                          ),
                  ],
                ),
              )
            ],
          ),
          Container(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              daLiuRenGong.jiaZi != null
                  ? Text(
                      "「${daLiuRenGong.jiaZi?.ganZhiStr}」",
                      style: eightSkyDoorTextStyle.copyWith(
                          fontSize: jiaZiFontSize),
                    )
                  : RichText(
                      text: TextSpan(
                        text: "「",
                        style: eightSkyDoorTextStyle.copyWith(
                            fontSize: jiaZiFontSize),
                        children: [
                          WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: buildKongWangCircle(
                                  eightSkyDoorTextStyle.color, jiaZiFontSize)),
                          TextSpan(
                              text: "${daLiuRenGong.groundPanDiZhi.value}」")
                        ],
                      ),
                    )
            ],
          )),
        ],
      ),
    );
  }

  Widget buildKongWangCircle([Color? color, double size = 32]) {
    return ColorFiltered(
        colorFilter:
            ColorFilter.mode(color ?? Colors.blueGrey, BlendMode.srcIn),
        child: Image.asset(
          "${ICONS_ASSETS_PATH}/thin-black-ink-circle.png",
          width: size,
          height: size,
        ));
  }

  Color getGanColor(TianGan gan) {
    return ConstResourcesMapper.zodiacGanColors[gan]!.withOpacity(.6);
  }

  Color getZhiColor(DiZhi zhi) {
    return ConstResourcesMapper.zodiacZhiColors[zhi]!.withOpacity(.8);
  }

  // 显示神将节气
  Timer? _showMonthGeneralJieQiTimer;
  bool isLongSticky = false;

  void showMonthlyGeneralJieQi({bool autoHidden = true}) {
    if (!_showMonthGeneralJieQi.value) {
      _showMonthGeneralJieQi.value = true;
      if (autoHidden && _showMonthGeneralJieQiTimer == null) {
        _showMonthGeneralJieQiTimer = Timer(const Duration(seconds: 5), () {
          hideMonthlyGeneralJieQi();
          _showMonthGeneralJieQiTimer = null;
        });
      }
    }
  }

  void hideMonthlyGeneralJieQi() {
    if (_showMonthGeneralJieQi.value) {
      _showMonthGeneralJieQi.value = false;
    }
  }
}
