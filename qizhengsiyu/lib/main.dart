import 'dart:math' as math;

import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:common/database/app_database.dart' as rootDB;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/presentation/pages/beauty_page_viewmodel.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/body_life_circle_widget.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/circle_text_painter.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/da_xian_ring.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/gong_12_dizhi.dart';
import 'package:qizhengsiyu/presentation/widgets/rings/gong_ming_li_ring.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_ui_constant_resources.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tuple/tuple.dart';

import 'data/datasources/local/app_database.dart';
import 'data/repositories/interfaces/i_qizhengsiyu_pan_repository.dart';
import 'data/repositories/qizhengsiyu_pan_repository.dart';
import 'domain/entities/models/body_life_model.dart';
import 'domain/entities/models/naming_degree_pair.dart';
import 'domain/entities/models/panel_config.dart';
import 'domain/entities/models/zhou_tian_model.dart';
import 'domain/managers/hua_yao_manager.dart';
import 'domain/managers/shen_sha_manager.dart';
import 'domain/managers/zhou_tian_model_manager.dart';
import 'domain/usecases/calculate_fate_dong_wei_usecase.dart';
import 'domain/usecases/save_calculated_panel_usecase.dart';
import 'navigator.dart';
import 'di.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...createProviders(),
        Provider<AppDatabase>(
          create: (ctx) => AppDatabase(),
          dispose: (ctx, db) => db.close(),
        ),
        Provider<IQiZhengSiYuPanRepository>(
          create: (ctx) => QiZhengSiYuPanRepository(
            appDatabase: ctx.read<AppDatabase>(),
          ),
        ),
        Provider<SaveCalculatedPanelUseCase>(
            create: (ctx) => SaveCalculatedPanelUseCase(
                qiZhengSiYuPanRepository: ctx.read<IQiZhengSiYuPanRepository>())),
        ChangeNotifierProvider<BeautyPageViewModel>(
            create: (ctx) => BeautyPageViewModel(
                  calculateFateDongWeiUseCase: CalculateFateDongWeiUseCase(),
                  saveCalculatedPanelUseCase:
                      ctx.read<SaveCalculatedPanelUseCase>(),
                  shenShaManager: ctx.read<ShenShaManager>(),
                  huaYaoManager: ctx.read<HuaYaoManager>(),
                  zhouTianModelManager: ctx.read<ZhouTianModelManager>(),
                )),
        ChangeNotifierProvider<QiZhengSiYuViewModel>(
            create: (ctx) => QiZhengSiYuViewModel(
                  shenShaManager: ctx.read<ShenShaManager>(),
                  huaYaoManager: ctx.read<HuaYaoManager>(),
                  zhouTianModelManager: ctx.read<ZhouTianModelManager>(),
                )),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: "/qizhengsiyu/panel",
        onGenerateRoute: NavigatorGenerator.generateRoute,
      ),
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
    final zhouTianModelManager = context.read<ZhouTianModelManager>();
    zhouTianModelManager.load();
    final zhouTianModel =
        zhouTianModelManager.getZhouTianModelBy(BasePanelConfig.defaultBasicPanelConfig());
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
                    outerRadius: 190,
                    innerRadius: 150,
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
                    }, zhouTianModel: zhouTianModel,
                  ),
                  Normal12GongRing(
                    outerRadius: 150,
                    innerRadius: 130,
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
                    }, zhouTianModel: zhouTianModel,
                  ),
                  build12DiZhiGong(130, 80, zhouTianModel),
                  DaXianRing(
                      gongYearsMapper: {
                        EnumTwelveGong.Zi: YearMonth(10, 3),
                        // EnumTwelveGong.Chou: 4.5,
                        // EnumTwelveGong.Zi: 15,
                        EnumTwelveGong.Chou: YearMonth(10, 0),
                        EnumTwelveGong.Yin: YearMonth(11, 0),
                        EnumTwelveGong.Mao: YearMonth(15, 0),
                        EnumTwelveGong.Chen: YearMonth(8, 0),
                        EnumTwelveGong.Si: YearMonth(7, 0),
                        EnumTwelveGong.Wu: YearMonth(11, 0),
                        EnumTwelveGong.Wei: YearMonth(4, 6),
                        EnumTwelveGong.Shen: YearMonth(4, 6),
                        EnumTwelveGong.You: YearMonth(4, 6),
                        // EnumTwelveGong.Shen: 5,
                        // EnumTwelveGong.You: 5,
                        EnumTwelveGong.Xu: YearMonth(5, 0),
                        EnumTwelveGong.Hai: YearMonth(5, 0),
                      },
                      outerRadius: 480,
                      innerRadius: 432,
                      baseGongOffsetAngle: 30),
                  // textCicle(),
                  BodyLifeCircleWidget(
                    bodyLifeModel: BodyLifeModel(
                      lifeGongInfo:
                          GongDegree(gong: EnumTwelveGong.Chen, degree: 17.2),
                      lifeConstellationInfo: ConstellationDegree(
                          constellation: Enum28Constellations.Zhen_Shui_Yin,
                          degree: 2.2),
                      bodyGongInfo:
                          GongDegree(gong: EnumTwelveGong.Chen, degree: 17.2),
                      bodyConstellationInfo: ConstellationDegree(
                          constellation: Enum28Constellations.Zhen_Shui_Yin,
                          degree: 2.2),
                    ),
                    itemSize: 80,
                    ringColor: Colors.blue,
                  ),
                ]),
              )
            ],
          )),
    );
  }

  Tuple2<String, String?> toStringDegree(double degree) {
    var mingGongDegree = degree.toString();
    List<String> _tmpList = mingGongDegree.split(".");
    var mingGongDegreeFirstPart = _tmpList[0];
    String? mingGongDegreeSecondPar;
    if (_tmpList.length > 1) {
      mingGongDegreeFirstPart = _tmpList[0] + ".";
      mingGongDegreeSecondPar = _tmpList[1] + "°";
      return Tuple2(mingGongDegreeFirstPart, mingGongDegreeSecondPar);
    } else {
      mingGongDegreeFirstPart = _tmpList[0] + "°";
      return Tuple2(mingGongDegreeFirstPart, null);
    }
  }

  Widget textCicle() {
    double itemSize = 80;
    BodyLifeModel bodyLifeModel = BodyLifeModel(
      lifeGongInfo: GongDegree(gong: EnumTwelveGong.Chen, degree: 17.2),
      lifeConstellationInfo: ConstellationDegree(
          constellation: Enum28Constellations.Zhen_Shui_Yin, degree: 2.2),
      bodyGongInfo: GongDegree(gong: EnumTwelveGong.Chen, degree: 17.2),
      bodyConstellationInfo: ConstellationDegree(
          constellation: Enum28Constellations.Zhen_Shui_Yin, degree: 2.2),
    );
    TextStyle textStyle = const TextStyle(
        fontSize: 14,
        height: 1,
        color: Colors.black54,
        fontWeight: FontWeight.w400);
    TextStyle starTextStyle =
        textStyle.copyWith(fontWeight: FontWeight.bold, shadows: const [
      Shadow(
        color: Colors.grey,
        offset: Offset(1, 1),
        blurRadius: 1,
      ),
    ]);
    Tuple2<String, String?> lifeGongTuple =
        toStringDegree(bodyLifeModel.lifeGongInfo.degree);
    Tuple2<String, String?> lifeConstellationTuple =
        toStringDegree(bodyLifeModel.lifeConstellationInfo.degree);

    Tuple2<String, String?> bodyConstellationTuple =
        toStringDegree(bodyLifeModel.bodyConstellationInfo.degree);
    Tuple2<String, String?> bodyGongTuple =
        toStringDegree(bodyLifeModel.bodyGongInfo.degree);

    return SizedBox(
        width: itemSize,
        height: itemSize,
        child: CustomMultiChildLayout(
          delegate: _TempLayoutDelegate(
            itemCount: 1,
            radius: 0, // 所有子项都从中心开始布局
            itemSize: itemSize,
          ),
          children: [
            LayoutId(
                id: 0,
                child: SizedBox(
                  width: itemSize,
                  height: itemSize,
                  child: Transform.rotate(
                      angle: 0,
                      child: CustomPaint(
                        size: Size(itemSize, itemSize),
                        painter: CircleTextPainter(
                            startAngle: 30 + 30 + 30,
                            // sweepRadian: 2 * math.pi,
                            sweepRadian: (3 * 30) * math.pi / 180,
                            color: Colors.blue,
                            outerRadius: itemSize,
                            innerRadius: itemSize - 20,
                            borderColor: Colors.black12,
                            gongYearsMapper: {
                              EnumTwelveGong.Yin: [
                                Text("身", style: textStyle),
                                Text("主", style: textStyle),
                                Text(
                                    bodyLifeModel
                                        .bodyGong.sevenZheng.singleName,
                                    style: starTextStyle.copyWith(
                                        color: QiZhengSiYuUIConstantResources
                                                .zhengColorMap[
                                            bodyLifeModel
                                                .bodyGong.sevenZheng])),
                                Text(bodyLifeModel.bodyGong.name,
                                    style: textStyle),
                                Text(bodyGongTuple.item1, style: textStyle),
                                if (bodyGongTuple.item2 != null)
                                  Text(bodyGongTuple.item2!, style: textStyle),
                              ],
                              EnumTwelveGong.Si: [
                                Text("命", style: textStyle),
                                Text("主", style: textStyle),
                                Text(
                                    bodyLifeModel
                                        .lifeGong.sevenZheng.singleName,
                                    style: starTextStyle.copyWith(
                                        color: QiZhengSiYuUIConstantResources
                                                .zhengColorMap[
                                            bodyLifeModel
                                                .lifeGong.sevenZheng])),
                                Text(bodyLifeModel.lifeGong.name,
                                    style: textStyle),
                                Text(lifeGongTuple.item1, style: textStyle),
                                if (lifeGongTuple.item2 != null)
                                  Text(lifeGongTuple.item2!, style: textStyle),
                              ],
                              EnumTwelveGong.Shen: [
                                Text("命", style: textStyle),
                                Text("度", style: textStyle),
                                Text(
                                    bodyLifeModel.lifeConstellatioin.sevenZheng
                                        .singleName,
                                    style: starTextStyle.copyWith(
                                        color: QiZhengSiYuUIConstantResources
                                                .zhengColorMap[
                                            bodyLifeModel.lifeConstellatioin
                                                .sevenZheng])),
                                Text(bodyLifeModel.lifeConstellatioin.name,
                                    style: textStyle),
                                Text(lifeConstellationTuple.item1,
                                    style: textStyle),
                                if (lifeConstellationTuple.item2 != null)
                                  Text(lifeConstellationTuple.item2!,
                                      style: textStyle),
                              ],
                              EnumTwelveGong.Hai: [
                                Text("身", style: textStyle),
                                Text("度", style: textStyle),
                                Text(
                                    bodyLifeModel.bodyConstellation.sevenZheng
                                        .singleName,
                                    style: starTextStyle.copyWith(
                                        color: QiZhengSiYuUIConstantResources
                                                .zhengColorMap[
                                            bodyLifeModel.bodyConstellation
                                                .sevenZheng])),
                                Text(bodyLifeModel.bodyConstellation.name,
                                    style: textStyle),
                                Text(bodyConstellationTuple.item1,
                                    style: textStyle),
                                if (bodyConstellationTuple.item2 != null)
                                  Text(bodyConstellationTuple.item2!,
                                      style: textStyle),
                              ],
                            },
                            textStyle: const TextStyle(
                                height: 1, color: Colors.black87, fontSize: 16),
                            gongOrderedSeq: [
                              EnumTwelveGong.Yin,
                              EnumTwelveGong.Si,
                              EnumTwelveGong.Shen,
                              EnumTwelveGong.Hai,
                            ]),
                      )),
                )),
          ],
        ));
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

class _TempLayoutDelegate extends MultiChildLayoutDelegate {
  /// 子项数量
  final int itemCount;

  /// 布局半径
  final double radius;

  /// 子项尺寸
  final double itemSize;

  _TempLayoutDelegate({
    required this.itemCount,
    required this.radius,
    required this.itemSize,
  });

  @override
  void performLayout(Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < itemCount; i++) {
      if (!hasChild(i)) continue;

      final childSize =
          layoutChild(i, BoxConstraints.tight(Size(itemSize, itemSize)));
      // 所有子项都放置在中心点
      positionChild(
        i,
        Offset(
            center.dx - childSize.width / 2, center.dy - childSize.height / 2),
      );
    }
  }

  @override
  bool shouldRelayout(covariant _TempLayoutDelegate oldDelegate) =>
      oldDelegate.itemCount != itemCount ||
      oldDelegate.radius != radius ||
      oldDelegate.itemSize != itemSize;
}
