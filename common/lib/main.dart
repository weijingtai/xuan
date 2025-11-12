import 'dart:ui';

import 'package:common/const_resources_mapper.dart';
import 'package:common/database/app_database.dart' as db;
import 'package:common/database/world_info_database.dart' as db;
import 'package:common/themes/app_themes.dart';
import 'package:common/viewmodels/dev_enter_page_view_model.dart';
import 'package:common/viewmodels/four_zhu_card_demo_viewmodel.dart';
import 'package:common/viewmodels/four_zhu_editor_view_model.dart';
import 'package:common/viewmodels/timezone_location_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:common/navigator.dart';
import 'package:common/widgets/eight_gua_widget.dart';
import 'package:common/widgets/yao_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweph/sweph.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'common_logger.dart';
import 'enums/enum_hou_tian_gua.dart';
import 'line_painter_widget.dart';
import 'features/datetime_details/zi_strategy_store.dart';
import 'features/datetime_details/jieqi_phenology_store.dart';
import 'features/datetime_details/jieqi_entry_strategy_store.dart';

Future<void> initServices() async {
  // 在这里可以进行其他异步初始化操作
  // 例如加载配置文件等
  await FontLoader('NotoSansSC-Regular').load();
  tz.initializeTimeZones();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  CommonLogger().logger.i("common module is started.");
  WidgetsFlutterBinding.ensureInitialized();
  // await initSweph([
  //   'packages/sweph/assets/ephe/sefstars.txt', // For star position
  // ]);
}

void main() async {
  // runApp(
  //   MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider<ShiJiaQiMenViewModel>(create: (context) => ShiJiaQiMenViewModel(context)),
  //     ],
  //     child: const MyApp(),
  //   ),
  // );

  initServices().then((_) async {
    // Load persisted default 子时策略 before building widgets
    await ZiStrategyStore.initFromPrefs();
    await JieQiPhenologyStore.initFromPrefs();
    await JieQiEntryStrategyStore.initFromPrefs();
    runApp(
      MultiProvider(
        providers: [
          Provider<db.AppDatabase>(
            create: (ctx) => db.AppDatabase(),
            dispose: (ctx, db) => db.close(),
          ),
          Provider<db.WorldInfoDatabase>(
            create: (ctx) => db.WorldInfoDatabase(),
            dispose: (ctx, db) => db.close(),
          ),
          ListenableProvider<DevEnterPageViewModel>(
            create: (ctx) =>
                DevEnterPageViewModel(appDatabase: ctx.read<db.AppDatabase>())
                  ..initState(),
          ),
          ListenableProvider<FourZhuCardDemoViewModel>(
            create: (ctx) => FourZhuCardDemoViewModel(),
            dispose: (ctx, mapper) => mapper.dispose(),
          ),
          ListenableProvider<TimezoneLocationViewModel>(
              create: (ctx) => TimezoneLocationViewModel(
                    appFeatureModule: AppFeatureModule.Golabel,
                  ))
        ],
        child: const MyApp(),
      ),
    );
    // runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Common Widgets Dev',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      //   useMaterial3: false,
      // ),
      // home: const MyHomePage(title: 'Common Widgets Dev'),
      // home:ChineseStyleTheme1HomePage(),
      // home:WidgetExamplePage(),
      // initialRoute: '/common/history',
      theme: AppThemes.lightTheme, // 默认使用亮色主题
      darkTheme: AppThemes.darkTheme, // 设置深色主题
      themeMode: ThemeMode.system, // 跟随系统设置切换
      // initialRoute: '/common/editable_card_demo',
      initialRoute: '/common/four_zhu_edit',
      onGenerateRoute: NavigatorGenerator.generateRoute,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return const LinePainterWidget();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 32,
            ),
            SizedBox(
              height: 280,
              width: 760,
              child: Card(
                child: Container(
                  // padding: EdgeInsets.all(16),
                  child: mei_hua_three_gua(),
                ),
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            build_lian_hu(),
            const SizedBox(
              height: 32,
            ),
            build_bao_gua(),
            const SizedBox(
              height: 32,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildChangedSixYaoGuaByName(
                    "雷泽", "天水", const Size(160, 24), true),
                const SizedBox(
                  width: 32,
                ),
                buildEightGuaByName("水火", const Size(160, 24), true),
                const SizedBox(
                  width: 32 + 24,
                ),
                buildEightGuaByName("天水", const Size(160, 24), true),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget build_bao_gua() {
    return Container(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildEightGuaByGuaName(
                  HouTianGua.Li, const Size(120, 20), 4, true),
              const SizedBox(
                height: 24,
              ),
              buildEightGuaByGuaName(
                  HouTianGua.Kan, const Size(120, 20), 4, true),
            ],
          ),
          const SizedBox(
            width: 64,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildEightGuaByGuaName(
                  HouTianGua.Kan, const Size(120, 20), 4, true),
              const SizedBox(
                height: 24,
              ),
              buildEightGuaByGuaName(
                  HouTianGua.Kan, const Size(120, 20), 4, true),
            ],
          )
        ]));
  }

  // 连互
  Widget build_lian_hu() {
    return Container(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildEightGuaByGuaName(
                  HouTianGua.Li, const Size(120, 20), 4, true),
              const SizedBox(
                height: 24,
              ),
              buildEightGuaByGuaName(
                  HouTianGua.Kan, const Size(120, 20), 4, true),
            ],
          ),
          const SizedBox(
            width: 64,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildEightGuaByGuaName(
                  HouTianGua.Kan, const Size(80, 12), 4, true),
              const SizedBox(
                height: 24,
              ),
              buildEightGuaByGuaName(
                  HouTianGua.Li, const Size(80, 12), 4, true),
              const SizedBox(
                height: 24,
              ),
              buildEightGuaByGuaName(
                  HouTianGua.Kan, const Size(80, 12), 4, true),
              const SizedBox(
                height: 24,
              ),
              buildEightGuaByGuaName(
                  HouTianGua.Li, const Size(80, 12), 4, true),
            ],
          )
        ]));
  }

  Widget mei_hua_three_gua() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildChangedSixYaoGuaByName("火水", "天水", const Size(160, 24), true),
        const SizedBox(
          width: 32,
        ),
        buildEightGuaByName("水火", const Size(160, 24), true),
        const SizedBox(
          width: 32 + 24,
        ),
        buildEightGuaByName("天水", const Size(160, 24), true),
      ],
    );
  }

  /// binary str  从下向上爻
  /// changedSixYaoBinaryStr 为“变卦”的binaryStr
  Widget buildEightGuaByName(String guaName, Size yaoSize, bool isColorful,
      [int yaoIntervalHeight = 12, double guaIntervalHeight = 20]) {
    // String fromTopToBottom = sixYaoBinaryStr.split("").reversed.join("");
    // String topGua = guaName.split("")[0];
    // String bottomGua = guaName.split("")[1];

    HouTianGua topGua = HouTianGua.getGuaByNickname(guaName.split("")[0]);
    HouTianGua bottomGua = HouTianGua.getGuaByNickname(guaName.split("")[1]);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        EightGuaWidget(
            gua: topGua,
            yaoSize: yaoSize,
            intervalHeight: yaoIntervalHeight,
            color: isColorful
                ? ConstResourcesMapper.zodiacGuaColors[topGua]!
                : Colors.blueGrey.shade900),
        SizedBox(
          height: guaIntervalHeight,
        ),
        EightGuaWidget(
            gua: bottomGua,
            yaoSize: yaoSize,
            intervalHeight: yaoIntervalHeight,
            color: isColorful
                ? ConstResourcesMapper.zodiacGuaColors[bottomGua]!
                : Colors.blueGrey.shade900),
      ],
    );
  }

  Widget buildChangedSixYaoGuaByName(
      String guaName, String changedGaName, Size yaoSize, bool isColorful,
      [int yaoIntervalHeight = 12, double guaIntervalHeight = 20]) {
    // original top binary
    HouTianGua originalTopGua =
        HouTianGua.getGuaByNickname(guaName.split("").first);
    HouTianGua originalBottomGua =
        HouTianGua.getGuaByNickname(guaName.split("").last);
    // String originalTopBinaryStr = originalTopGua.binaryStr.split("").reversed.join();
    String originalTopBinaryStr = originalTopGua.binaryStr.split("").join();
    // original bottom binary
    // String originalBottomBinaryStr = originalBottomGua.binaryStr.split("").reversed.join();
    String originalBottomBinaryStr =
        originalBottomGua.binaryStr.split("").join();

    // changed top binary
    String changedTopBinaryStr =
        HouTianGua.getGuaByNickname(changedGaName.split("").first)
            .binaryStr
            .split("")
            .reversed
            .join();
    // changed bottom binary
    String changedBottomBinaryStr =
        HouTianGua.getGuaByNickname(changedGaName.split("").last)
            .binaryStr
            .split("")
            .reversed
            .join();

    // String fromTopToBottom = sixYaoBinaryStr.split("").reversed.join("");
    // String changedFromTopToBottom= changedThreeYaoBinaryStr.split("").reversed.join("");
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        buildThreeYaoGuaWithChangeYao(
            originalTopBinaryStr,
            yaoSize,
            changedTopBinaryStr,
            yaoIntervalHeight,
            guaIntervalHeight,
            ConstResourcesMapper.zodiacGuaColors[originalTopGua]!),
        SizedBox(
          height: guaIntervalHeight,
        ),
        buildThreeYaoGuaWithChangeYao(
            originalBottomBinaryStr,
            yaoSize,
            changedBottomBinaryStr,
            yaoIntervalHeight,
            guaIntervalHeight,
            ConstResourcesMapper.zodiacGuaColors[originalBottomGua]!)
      ],
    );
  }

  /// binary str  从下向上爻
  /// changedSixYaoBinaryStr 为“变卦”的binaryStr
  Widget buildSixYaoGua(String sixYaoBinaryStr, Size yaoSize, bool isColorful,
      [int yaoIntervalHeight = 12, double guaIntervalHeight = 20]) {
    String fromTopToBottom = sixYaoBinaryStr.split("").reversed.join("");
    HouTianGua topGua =
        HouTianGua.getGuaByBinaryStr(fromTopToBottom.substring(0, 3));
    HouTianGua bottomGua =
        HouTianGua.getGuaByBinaryStr(fromTopToBottom.substring(3));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        EightGuaWidget(
            gua: topGua,
            yaoSize: yaoSize,
            intervalHeight: yaoIntervalHeight,
            color: isColorful
                ? ConstResourcesMapper.zodiacGuaColors[topGua]!
                : Colors.blueGrey.shade900),
        SizedBox(
          height: guaIntervalHeight,
        ),
        EightGuaWidget(
            gua: bottomGua,
            yaoSize: yaoSize,
            intervalHeight: yaoIntervalHeight,
            color: isColorful
                ? ConstResourcesMapper.zodiacGuaColors[bottomGua]!
                : Colors.blueGrey.shade900),
      ],
    );
  }

  Widget buildChangedSixYaoGua(
      String sixYaoBinaryStr, String changedThreeYaoBinaryStr, Size yaoSize,
      [int yaoIntervalHeight = 12, double guaIntervalHeight = 20]) {
    String fromTopToBottom = sixYaoBinaryStr.split("").reversed.join("");
    String changedFromTopToBottom =
        changedThreeYaoBinaryStr.split("").reversed.join("");
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        buildThreeYaoGuaWithChangeYao(fromTopToBottom.substring(0, 3), yaoSize,
            changedFromTopToBottom.substring(0, 3), yaoIntervalHeight),
        SizedBox(
          height: guaIntervalHeight,
        ),
        buildThreeYaoGuaWithChangeYao(fromTopToBottom.substring(3), yaoSize,
            changedFromTopToBottom.substring(3), yaoIntervalHeight)
      ],
    );
  }

  Widget buildThreeYaoGuaWithChangeYao(
      String threeYaoBinaryStr, Size yaoSize, String changedThreeYaoBinaryStr,
      [int yaoIntervalHeight = 12,
      double guaIntervalHeight = 20,
      Color color = Colors.black87]) {
    List<String> threeYaoList = threeYaoBinaryStr.split("");
    List<String> changedThreeYaoList = changedThreeYaoBinaryStr.split("");
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        EightGuaWidget(
          gua: HouTianGua.getGuaByBinaryStr(threeYaoBinaryStr),
          yaoSize: yaoSize,
          intervalHeight: yaoIntervalHeight,
          color: color,
        ),
        const SizedBox(
          width: 8,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
                height: yaoSize.height,
                width: yaoSize.height,
                child: threeYaoList[2] != changedThreeYaoList[2]
                    ? buildChangeYaoMark()
                    : const SizedBox()),
            SizedBox(
              height: yaoSize.height * 0.5,
            ),
            SizedBox(
                height: yaoSize.height,
                width: yaoSize.height,
                child: threeYaoList[1] != changedThreeYaoList[1]
                    ? buildChangeYaoMark()
                    : const SizedBox()),
            SizedBox(
              height: yaoSize.height * 0.5,
            ),
            SizedBox(
                height: yaoSize.height,
                width: yaoSize.height,
                child: threeYaoList[0] != changedThreeYaoList[0]
                    ? buildChangeYaoMark()
                    : const SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget buildChangeYaoMark() {
    return Stack(alignment: Alignment.center, children: [
      Positioned(
        // top: -1,
        // left: -1,
        child: ColorFiltered(
            colorFilter:
                const ColorFilter.mode(Colors.redAccent, BlendMode.srcIn),
            child: Image.asset(
              "assets/icons/chinese_ink_mark.png",
              width: 20,
              height: 20,
            )
            // child: Image.asset("assets/icons/chinese_ink_mark.png",width: 18,height: 18,)
            ),
      ),
      ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: ColorFiltered(
            colorFilter: ColorFilter.mode(
                Colors.grey.withValues(alpha: .7), BlendMode.srcIn),
            child: Image.asset(
              "assets/icons/chinese_ink_mark.png",
              width: 21,
              height: 21,
            )
            // child: Image.asset("assets/icons/chinese_ink_mark.png",width: 18,height: 18,)
            ),
      ),
    ]);
  }

  Widget buildEightGuaByGuaName(HouTianGua gua, Size yaoSize,
      [int yaoIntervalHeight = 12, bool isColorful = false]) {
    return EightGuaWidget(
        gua: gua,
        yaoSize: yaoSize,
        intervalHeight: yaoIntervalHeight,
        color: isColorful
            ? ConstResourcesMapper.zodiacGuaColors[gua]!
            : Colors.blueGrey.shade900);
    // return buildEightGua(gua.binaryStr,yaoSize,yaoIntervalHeight,isColorful?ConstResourcesMapper.zodiacGuaColors[gua]!:Colors.black87);
  }
}
