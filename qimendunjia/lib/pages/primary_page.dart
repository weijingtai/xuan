import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:common/adapters/lunar_adapter.dart';
import 'package:qimendunjia/data.dart';
import 'package:tuple/tuple.dart';

import '../widgets/OctagonPainter.dart';
import "package:qimendunjia/utils/datetime_jie_qi.dart";

class PrimaryPage extends StatefulWidget {
  const PrimaryPage({super.key});

  @override
  State<PrimaryPage> createState() => _PrimaryPageState();
}

class _PrimaryPageState extends State<PrimaryPage> {
  int? previousIndex;
  int currentIndex = 0;
  TextStyle background_gongName_TextStyle = TextStyle(
    fontSize: 96,
    height: 1,
    color: Colors.grey.withOpacity(.2),
  );
  TextStyle panTianGanTextStyle =
      TextStyle(fontSize: 24, color: Colors.white, height: 1, shadows: [
    Shadow(
      color: Colors.grey.withOpacity(.6),
      offset: const Offset(0, 2),
      blurRadius: 4,
    )
  ]);

  List<List<String>> twoDimensionalList = [
    ["A1", "A2", "A3"],
    ["B1", "B2", "B3"],
    ["C1", "C2", "C3"],
  ];
  List<List<GongFixedContent>> twoFixedContent = [
    [
      GongFixedContent(
          numberName: "肆",
          guaName: "巽",
          jieQiData: const Tuple3<String, String, String>("立夏", "小满", "芒种")),
      GongFixedContent(
          numberName: "玖",
          guaName: "离",
          jieQiData: const Tuple3<String, String, String>("夏至", "小暑", "大暑")),
      GongFixedContent(
          numberName: "贰",
          guaName: "坤",
          jieQiData: const Tuple3<String, String, String>("立秋", "处暑", "白露")),
    ],
    [
      GongFixedContent(
          numberName: "叁",
          guaName: "震",
          jieQiData: const Tuple3<String, String, String>("春分", "清明", "谷雨")),
      GongFixedContent(numberName: "伍", guaName: "中", jieQiData: null),
      GongFixedContent(
          numberName: "柒",
          guaName: "兑",
          jieQiData: const Tuple3<String, String, String>("秋分", "寒露", "霜降")),
    ],
    [
      GongFixedContent(
          numberName: "捌",
          guaName: "艮",
          jieQiData: const Tuple3<String, String, String>("立春", "雨水", "惊蛰")),
      GongFixedContent(
          numberName: "壹",
          guaName: "坎",
          jieQiData: const Tuple3<String, String, String>("冬至", "小寒", "大寒")),
      GongFixedContent(
          numberName: "陆",
          guaName: "乾",
          jieQiData: const Tuple3<String, String, String>("立冬", "小雪", "大雪")),
    ],
  ];
  final List<String> indexList = const [
    "A1",
    "A2",
    "A3",
    "B1",
    "B2",
    "B3",
    "C1",
    "C2",
    "C3"
  ];
  Map<String, GlobalKey<CellState>> cellMapper = {
    "A1": GlobalKey<CellState>(),
    "A2": GlobalKey<CellState>(),
    "A3": GlobalKey<CellState>(),
    "B1": GlobalKey<CellState>(),
    "B2": GlobalKey<CellState>(),
    "B3": GlobalKey<CellState>(),
    "C1": GlobalKey<CellState>(),
    "C2": GlobalKey<CellState>(),
    "C3": GlobalKey<CellState>(),
  };
  Map<String, Tuple2<int, int>> mapper = {
    "A1": const Tuple2(0, 0),
    "A2": const Tuple2(0, 1),
    "A3": const Tuple2(0, 2),
    "B1": const Tuple2(1, 0),
    "B2": const Tuple2(1, 1),
    "B3": const Tuple2(1, 2),
    "C1": const Tuple2(2, 0),
    "C2": const Tuple2(2, 1),
    "C3": const Tuple2(2, 2),
  };

  List<String> xianTianIndex = [
    "A2",
    "A1",
    "B1",
    "C1",
    "A3",
    "B3",
    "C3",
    "C2",
    "B2"
  ];

  final List<String> nineStarsSeq = [
    "天蓬星",
    "天芮星",
    "天冲星",
    "天辅星",
    "天禽星",
    "天心星",
    "天柱星",
    "天任星",
    "天英星"
  ];
  final List<String> eightDoorSeq = ["休", "生", "伤", "杜", "景", "死", "惊", "开"];
  final List<String> eightShenSeq = [
    "值符",
    "螣蛇",
    "太阴",
    "六合",
    "白虎",
    "玄武",
    "九地",
    "九天"
  ];

  final List<String> houTianIndex = [
    "C2",
    "A3",
    "B1",
    "A1",
    "B2",
    "C3",
    "B3",
    "C1",
    "A2"
  ];

  final List<String> yangDunOrder = [
    "戊",
    "己",
    "庚",
    "辛",
    "壬",
    "癸",
    "丁",
    "丙",
    "乙"
  ];
  final List<String> yinDunOrder = [
    "戊",
    "乙",
    "丙",
    "丁",
    "壬",
    "癸",
    "庚",
    "辛",
  ];

  Map<String, String> eightDoorContentMapper = {
    "休": "C2",
    "生": "C1",
    "伤": "B1",
    "杜": "A1",
    "景": "A2",
    "死": "A3",
    "惊": "B3",
    "开": "C3",
  };

  Map<String, String> gongEightDoorMapper = {
    // 交换key与value
    "C2": "休",
    "C1": "生",
    "B1": "伤",
    "A1": "杜",
    "A2": "景",
    "A3": "死",
    "B3": "惊",
    "C3": "开",
  };

  Map<String, String> houTianContent = {
    "C2": "坎",
    "A3": "坤",
    "B1": "震",
    "A1": "巽",
    "B2": "中",
    "C3": "乾",
    "B3": "兑",
    "C1": "艮",
    "A2": "离"
  };
  Map<String, String> nineStarContent = {
    "C2": "天蓬星",
    "A3": "天芮星",
    "B1": "天冲星",
    "A1": "天辅星",
    "B2": "天禽星",
    "C3": "天心星",
    "B3": "天柱星",
    "C1": "天任星",
    "A2": "天英星"
  };
  late Map<String, Widget> houTianChild;
  List<String> tenTianGan = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"];
  List<String> twelveDiZhi = [
    "子",
    "丑",
    "寅",
    "卯",
    "辰",
    "巳",
    "午",
    "未",
    "申",
    "酉",
    "戌",
    "亥"
  ];
  List<String> sixtyJiaZi = [];

  List<String> circleList = ["C2", "C1", "B1", "A1", "A2", "A3", "B2", "C3"];
  List<String> seqList = ["C2", "A3", "B1", "A1", "B2", "C3", "B3", "C1", "B2"];

  Map<String, Tuple2<String, String?>> first = {};
  // 甲子日，甲子时
  void yuanGong() {
    // eightDoorSeq, eightShenSeq, nineStarsSeq
    // houTianIndex

    Map<String, Tuple2<String, String?>> mapper = {};
    for (int i = 0; i < houTianIndex.length; i++) {
      String gongIndex = houTianIndex[i];
      String nineShenName = nineStarsSeq[i];
      mapper[gongIndex] = Tuple2(nineShenName, null);
    }

    mapper = Map.fromEntries(mapper
        .map((key, value) =>
            MapEntry(key, Tuple2(value.item1, gongEightDoorMapper[key])))
        .entries);
    // mapper.forEach((key, value) {
    //   debugPrint("$key -- $value");
    // });
  }

  List<Tuple3<String, List<String>, Tuple2<String, String>?>> sixXunList = [];
  // key is 旬首
  // value.item1 list for eachDay
  // value.item2 for 空亡
  Map<String, Tuple2<List<String>, Tuple2<String, String>?>> sixXunMapper = {};
  void generateJiaZi() {
    // 根据天干地支生成六十甲子
    int xunCounter = 0;
    for (int i = 0; i < 60; i++) {
      int tianGanIndex = i % 10;
      int diZhiIndex = i % 12;
      String eachJiaZi = tenTianGan[tianGanIndex] + twelveDiZhi[diZhiIndex];
      sixtyJiaZi.add(eachJiaZi);
      if (eachJiaZi.startsWith("甲")) {
        sixXunList.add(Tuple3(eachJiaZi, [], null));
        xunCounter += 1;
      }

      var currentXunList = sixXunList[xunCounter - 1];
      currentXunList.item2.add(eachJiaZi);
      if (eachJiaZi.startsWith("乙")) {
        if (xunCounter >= 2) {
          var previousXunList = sixXunList[xunCounter - 2];
          var kongWangTuple = Tuple2(currentXunList.item2.first.split("").last,
              eachJiaZi.split("").last);
          sixXunList[xunCounter - 2] = Tuple3(
              previousXunList.item1, previousXunList.item2, kongWangTuple);
        }
      }
    }

    for (var e in sixXunList) {
      sixXunMapper[e.item1] = Tuple2(e.item2, e.item3);
      debugPrint(sixXunMapper[e.item1]!.item1.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    generateJiaZi();

    houTianChild = {
      "C2": buildEachCell("坎"),
      "A3": buildEachCell("坤"),
      "B1": buildEachCell("震"),
      "A1": buildEachCell("巽"),
      "B2": buildEachCell("中"),
      "C3": buildEachCell("乾"),
      "B3": buildEachCell("兑"),
      "C1": buildEachCell("艮"),
      "A2": buildEachCell("离")
    };
  }

  late final ValueNotifier<QiMenDunJiaPlate?> _qiMenDunJiaPlateNotifier =
      ValueNotifier<QiMenDunJiaPlate?>(null);
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _qiMenDunJiaPlateNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('奇门遁甲'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 6 + 256 * 3,
                height: 6 + 256 * 3,
                decoration: const BoxDecoration(
                    // border: Border.all(color: Colors.grey, width: 1),
                    ),
                // 使用Row与Column完成一个3*3的单元格
                child: ValueListenableBuilder<QiMenDunJiaPlate?>(
                  valueListenable: _qiMenDunJiaPlateNotifier,
                  builder: (ctx, QiMenDunJiaPlate? plate, child) {
                    return plate == null
                        ? buildEmptyPlate()
                        : buildPlate(plate);
                  },
                  child: buildEmptyPlate(),
                )),
            Container(
              padding: const EdgeInsets.only(top: 8),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // String dateTime = "2022-12-14 16:30:00"; // 正确
                      String dateTime = "2023-08-31 23:07:00"; // 正确
                      var time =
                          DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateTime);

                      plate = QiMenDunJiaPlate(
                          plateDateTime: time,
                          plateType:
                              QiMenDunJiaPlateType.turnPlate_divisionAppend);
                      plate!.arrange();
                      debugPrint(plate!.jieQi);
                      _qiMenDunJiaPlateNotifier.value = plate;
                      debugPrintCurrentPan(plate!.plate);
                      // generateJiaZi();

                      // var indexName = xianTianIndex[currentIndex];
                      // debugPrint(indexName);
                      // if (previousIndex != null) {
                      //   updateCell(xianTianIndex[previousIndex!], xianTianIndex[previousIndex!], Colors.transparent);
                      // }
                      // updateCell(indexName, indexName, Colors.blue.withOpacity(0.2));
                      // previousIndex = currentIndex;
                      // currentIndex++;
                      // if (currentIndex >= xianTianIndex.length - 1) {
                      //   currentIndex = 0;
                      // }
                    },
                    child: const Text("先天"),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      var indexName = houTianIndex[currentIndex];
                      debugPrint(indexName);
                      if (previousIndex != null) {
                        updateCell(houTianIndex[previousIndex!],
                            houTianIndex[previousIndex!], Colors.transparent);
                      }
                      updateCell(
                          indexName, indexName, Colors.blue.withOpacity(0.2));

                      previousIndex = currentIndex;
                      currentIndex++;
                      if (currentIndex >= houTianIndex.length) {
                        currentIndex = 0;
                      }
                    },
                    child: const Text("后天"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildHouTianGongGuaTag(String gongName) {
    // 后天八卦宫卦名
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
              opacity: .3,
              child: Image.asset("assets/icons/bagua-mirror-64.png")),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            style: const TextStyle(
                fontSize: 24,
                color: Colors.black54,
                height: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.grey,
                    offset: Offset(0, 1),
                    blurRadius: 4,
                  ),
                  Shadow(
                    color: Colors.white,
                    offset: Offset(1, 2),
                    blurRadius: 4,
                  )
                ]),
            child: Text(gongName),
          ),
        ],
      ),
    );
  }

  QiMenDunJiaPlate? plate;

  void debugPrintCurrentPan(List<List<QiMenDunJiaGong>> pan) {
    // print initGongContent as a table
    for (var e in pan) {
      debugPrint(e.toString());
    }
  }

  Widget buildJieQiTag(String? name, {bool isVertical = true}) {
    if (name == null) {
      return Container(
        width: 24,
      );
    }
    return Opacity(
      opacity: .6,
      child: Container(
        width: 24,
        height: 48,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 4, right: 2, bottom: 2),
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.blueAccent, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: Colors.blueAccent.withOpacity(.2),
        ),
        child: Text(
          name,
          style:
              const TextStyle(fontSize: 16, color: Colors.black87, height: 1.0),
        ),
      ),
    );
  }

  Widget buildGong(GongFixedContent fixed, QiMenDunJiaGong moving) {
    return Container(
      width: 256,
      height: 256,
      // padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        // color: Colors.lightBlueAccent.withOpacity(.2),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Container(
                width: 256,
                height: 256,
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 2,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 500),
                        style: background_gongName_TextStyle,
                        child: Text(fixed.numberName),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(
                            width: 72,
                            height: 48,
                          ),

                          // 节气
                          Container(
                            alignment: Alignment.centerRight,
                            // width: 256,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                buildHouTianGongGuaTag(fixed.guaName),
                                const SizedBox(
                                  width: 8,
                                ),
                                buildJieQiTag(fixed.jieQiData?.item3),
                                const SizedBox(
                                  width: 8,
                                ),
                                buildJieQiTag(fixed.jieQiData?.item2),
                                const SizedBox(
                                  width: 8,
                                ),
                                buildJieQiTag(fixed.jieQiData?.item1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            SizedBox(
              width: 256,
              height: 256,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container(
                      //   alignment: Alignment.centerLeft,
                      //   width:80,
                      //   child: tianDiYinPan(moving),
                      // ),
                      tianDiYinPan(moving),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(left: 24),
                        child: RichText(
                            text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 36,
                                    color: Colors.black87,
                                    height: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.grey,
                                        offset: Offset(0, 1),
                                        blurRadius: 4,
                                      ),
                                      Shadow(
                                        color: Colors.white,
                                        offset: Offset(1, 2),
                                        blurRadius: 4,
                                      )
                                    ]),
                                children: [
                              TextSpan(text: moving.eightDoor ?? ""),
                            ])),
                      ),
                      moving.eightGod == null
                          ? const SizedBox(
                              height: 72,
                              width: 108,
                            )
                          : shenStarPart(moving.eightGod!, moving.nineStar!,
                              moving.nineStar_ji),
                    ],
                  ),
                  SizedBox(
                    height: 72,
                    width: 256,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(),
                        const SizedBox(height: 48)
                        // Container(
                        //   height: 48,
                        //   width: 48,
                        //   alignment: Alignment.center,
                        //   padding: EdgeInsets.only(bottom: 4),
                        //   decoration: BoxDecoration(
                        //     color: Colors.black45,
                        //     borderRadius: BorderRadius.all(Radius.circular(24)),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.black.withOpacity(.3),
                        //         offset: Offset(0, 1),
                        //         blurRadius: 4,
                        //         spreadRadius: 2,
                        //       )
                        //     ],
                        //   ),
                        //   child: Text(
                        //     moving.diPan!,
                        //     style: TextStyle(
                        //         fontSize: 24,
                        //         color: Colors.white,
                        //         height: 1,
                        //         shadows: [
                        //           Shadow(
                        //             color: Colors.white.withOpacity(.4),
                        //             offset: Offset(0, 2),
                        //             blurRadius: 4,
                        //           )
                        //         ]),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: 50,
                  // )
                  Container(
                    width: 256,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      width: 72,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue[800],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 2,
                          )
                        ],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                      ),
                      child: const AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 500),
                        style: TextStyle(
                            fontSize: 24, color: Colors.white, height: 1.2),
                        child: Text("甲子"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tianDiYinPan(QiMenDunJiaGong moving) {
    return Container(
        width: 56,
        height: 108 + 6,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // color: Colors.blue,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 2,
            )
          ],
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 56,
                height: 36,
                padding: const EdgeInsets.only(bottom: 4),
                alignment: Alignment.bottomCenter,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                ),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: moving.tianPan ?? "",
                      style: panTianGanTextStyle
                          .copyWith(color: Colors.black87, shadows: [
                        Shadow(
                          color: Colors.black87.withOpacity(.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        )
                      ]),
                    ),
                    TextSpan(
                      text: moving.tianPan_ji ?? "",
                      style: panTianGanTextStyle.copyWith(
                          fontSize: 16,
                          color: Colors.black87,
                          shadows: [
                            Shadow(
                              color: Colors.black87.withOpacity(.2),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            )
                          ]),
                    )
                  ]),
                )),
            Container(
                width: 56,
                height: 36,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(.5),
                ),
                child: Text(moving.yinPan ?? "",
                    style: panTianGanTextStyle
                        .copyWith(color: Colors.deepPurple, shadows: [
                      Shadow(
                        color: Colors.deepPurple.withOpacity(.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      )
                    ]))),
            Container(
                width: 56,
                height: 40,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16)),
                ),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: moving.diPan ?? "",
                        style: panTianGanTextStyle
                            .copyWith(color: Colors.white, shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          )
                        ])),
                    TextSpan(
                        text: moving.diPan_ji ?? "",
                        style: panTianGanTextStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(.2),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              )
                            ])),
                  ]),
                ))
          ],
        ));
  }

  @deprecated
  Widget buildGong1(GongFixedContent fixed, GongMovingContent moving) {
    return Container(
      width: 256,
      height: 256,
      // padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        // color: Colors.lightBlueAccent.withOpacity(.2),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Container(
                width: 256,
                height: 256,
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 2,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 500),
                        style: background_gongName_TextStyle,
                        // child: Text(fixed.numberName),
                        child: Text(fixed.guaName),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          moving.eightDoor == null
                              ? const SizedBox(
                                  width: 48,
                                  height: 48,
                                )
                              : Container(
                                  width: 64,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.withOpacity(.8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueGrey.withOpacity(.2),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                        spreadRadius: 2,
                                      )
                                    ],
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(16)),
                                  ),
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 500),
                                    style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        height: 1.2),
                                    child: Text(moving.eightDoor!),
                                  ),
                                ),
                          // 节气
                          Container(
                            alignment: Alignment.centerRight,
                            // width: 256,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                buildHouTianGongGuaTag(fixed.guaName),
                                const SizedBox(
                                  width: 8,
                                ),
                                buildJieQiTag(fixed.jieQiData?.item3),
                                const SizedBox(
                                  width: 8,
                                ),
                                buildJieQiTag(fixed.jieQiData?.item2),
                                const SizedBox(
                                  width: 8,
                                ),
                                buildJieQiTag(fixed.jieQiData?.item1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            SizedBox(
              width: 256,
              height: 256,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 86,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(.4),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              spreadRadius: 2,
                            )
                          ],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 500),
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.grey.withOpacity(.6),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                )
                              ]),
                          child: Text(
                              "${moving.sixtyJiaZi.split("").first} ${moving.sixtyJiaZi.split("").last}"),
                        ),
                      ),
                      moving.eightShen == null
                          ? const SizedBox(
                              height: 72,
                              width: 86,
                            )
                          : shenStarPart(
                              moving.eightShen!, moving.nineStar!, null),
                    ],
                  ),
                  SizedBox(
                    height: 72,
                    width: 256,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(),
                        Container(
                          height: 48,
                          width: 48,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.3),
                                offset: const Offset(0, 1),
                                blurRadius: 4,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Text(
                            moving.tianGan,
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                height: 1,
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withOpacity(.4),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  )
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 72,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget shenStarPart(String shenName, String starName, String? jiStarName) {
    return Container(
      height: 72 + 22,
      width: 86,
      alignment: Alignment.centerRight,
      // color: Colors.redAccent.withOpacity(.2),
      child: Column(
        children: [
          eightShenTag(shenName),
          const SizedBox(
            height: 6,
          ),
          starTag(starName, jiStarName),
          // nineStarTag(startName, withoutTianQin: withoutTianQin),
        ],
      ),
    );
  }

  Widget eightShenTag(String shenName) {
    return Container(
      height: 30,
      width: 72,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.indigoAccent.withOpacity(.2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(Icons.bolt,size: 22,color: Colors.amber,),
            Image.asset(
              "assets/icons/flash-32.png",
              width: 18,
              height: 18,
            ),
            const SizedBox(
              width: 2,
            ),
            Text(
              shenName,
              style: const TextStyle(
                  fontSize: 18, color: Colors.black87, height: 1),
            ),
          ]),
    );
  }

  Widget starTag(String starName, String? jiStar) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: jiStar == null ? 32 : 32 + 18 + 2,
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(.2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            starName,
            style: TextStyle(
                fontSize: jiStar == null ? 18 : 16,
                color: Colors.black87,
                height: 1),
          ),
          jiStar == null
              ? Container()
              : Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 4,
                      ),
                      const Divider(
                        height: 1,
                        color: Colors.black12,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon(Icons.star,size: 22,color: Colors.amber,),
                            Image.asset(
                              "assets/icons/stars-64.png",
                              width: 14,
                              height: 14,
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            const Text(
                              "天擒星",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.2),
                            ),
                          ]),
                    ],
                  ),
                )
        ],
      ),
    );
  }

  Widget nineStarTag(String starName, {bool withoutTianQin = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      height: withoutTianQin ? 32 : 32 + 18,
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(.2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: withoutTianQin
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Text(
                    starName,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black87, height: 1.1),
                  ),
                ])
          : Column(
              children: [
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.star,size: 22,color: Colors.amber,),
                      // Image.asset(
                      //   "assets/icons/stars-64.png",
                      //   width: 20,
                      //   height: 20,
                      // ),
                      // SizedBox(
                      //   width: 2,
                      // ),
                      Text(
                        starName,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87, height: 1.2),
                      ),
                    ]),
                const SizedBox(
                  height: 4,
                ),
                const Divider(
                  height: 1,
                  color: Colors.black12,
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(Icons.star,size: 22,color: Colors.amber,),
                      Image.asset(
                        "assets/icons/stars-64.png",
                        width: 14,
                        height: 14,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      const Text(
                        "天擒星",
                        style: TextStyle(
                            fontSize: 12, color: Colors.black87, height: 1.2),
                      ),
                    ]),
              ],
            ),
    );
  }

  void updateCell(String indexKey, String value, Color backgroundColor) {
    cellMapper[indexKey]?.currentState!.updateValue(value, backgroundColor);
  }

  Widget buildPlate(QiMenDunJiaPlate plate) {
    List<Widget> rows = [];
    var index = 0;
    for (int i = 0; i < 3; i++) {
      List<Widget> cells = [];
      for (int j = 0; j < 3; j++) {
        // cells.add(buildEachCell(number[index-1]);
        String key = twoDimensionalList[i][j];
        GongFixedContent fixed = twoFixedContent[i][j];
        String? doorName;
        String? shenName;
        String nineStar = nineStarContent[key]!;
        if (index < 4) {
          shenName = eightShenSeq[index];
          // doorName = eightDoorList[index];
          doorName = eightDoorContentMapper.entries
              .firstWhere((element) => element.value == key)
              .key;
        } else if (index >= 5) {
          shenName = eightShenSeq[index - 1];
          // doorName = eightDoorList[index-1];
          doorName = eightDoorContentMapper.entries
              .firstWhere((element) => element.value == key)
              .key;
        }

        int houTianIndexNumber = houTianIndex.indexOf(key);
        String tianGan = yangDunOrder[houTianIndexNumber];
        cells.add(buildGong(fixed, plate.plate[i][j]));
        // String hongTianIndex = houTianIndex[index];

        index += 1;
      }
      rows.add(Expanded(child: Row(children: cells)));
    }
    return Column(children: rows);
  }

  Widget buildEmptyPlate() {
    List<Widget> rows = [];
    var index = 0;
    for (int i = 0; i < 3; i++) {
      List<Widget> cells = [];
      for (int j = 0; j < 3; j++) {
        // cells.add(buildEachCell(number[index-1]);
        String key = twoDimensionalList[i][j];
        GongFixedContent fixed = twoFixedContent[i][j];
        String? doorName;
        String? shenName;
        String nineStar = nineStarContent[key]!;
        if (index < 4) {
          shenName = eightShenSeq[index];
          // doorName = eightDoorList[index];
          doorName = eightDoorContentMapper.entries
              .firstWhere((element) => element.value == key)
              .key;
        } else if (index >= 5) {
          shenName = eightShenSeq[index - 1];
          // doorName = eightDoorList[index-1];
          doorName = eightDoorContentMapper.entries
              .firstWhere((element) => element.value == key)
              .key;
        }

        int houTianIndexNumber = houTianIndex.indexOf(key);
        String tianGan = yangDunOrder[houTianIndexNumber];
        cells.add(buildGong1(
            fixed,
            GongMovingContent(
                sixtyJiaZi: "乙丑",
                eightShen: shenName,
                nineStar: key == "B2" ? null : nineStar,
                eightDoor: doorName,
                tianGan: tianGan)));

        index += 1;
      }
      rows.add(Expanded(child: Row(children: cells)));
    }
    return Column(children: rows);
  }

  Widget buildEachCell(String value) {
    return Container(
      width: 256,
      height: 256,
      decoration: const BoxDecoration(
          // border: Border.all(color: Colors.black, width: 1),
          ),
      child: Center(child: Text(value)),
    );
  }

  Widget jieqi() {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "大寒",
              style: TextStyle(color: Colors.black38, fontSize: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "23/01/20 16:29:31",
                  style: TextStyle(
                      color: Colors.black38, fontSize: 12, height: 1.0),
                ),
                Text(
                  "23/02/04 10:42:21",
                  style: TextStyle(
                      color: Colors.black38, fontSize: 12, height: 1.0),
                ),
              ],
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "小寒",
              style: TextStyle(color: Colors.black38, fontSize: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "23/01/05 23:04:39",
                  style: TextStyle(
                      color: Colors.black38, fontSize: 12, height: 1.0),
                ),
                Text(
                  "23/01/20 16:29:20",
                  style: TextStyle(
                      color: Colors.black38, fontSize: 12, height: 1.0),
                ),
              ],
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "冬至",
              style: TextStyle(color: Colors.black38, fontSize: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "22/12/22 05:48:01",
                  style: TextStyle(
                      color: Colors.black38, fontSize: 12, height: 1.0),
                ),
                Text(
                  "23/01/05 23:04:38",
                  style: TextStyle(
                      color: Colors.black38, fontSize: 12, height: 1.0),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}

class GongContent {
  String eightShen; // 八神
  String nineStar; // 九星
  String eightDoor; // 八门
  GongContent(
      {required this.eightShen,
      required this.nineStar,
      required this.eightDoor});
}

class GongMovingContent {
  String sixtyJiaZi; // 甲子
  String? eightShen; // 八神
  String? nineStar; // 九星
  String? eightDoor; // 八门
  String tianGan;
  GongMovingContent(
      {required this.sixtyJiaZi,
      this.eightShen,
      this.nineStar,
      this.eightDoor,
      required this.tianGan});
}

class GongFixedContent {
  String numberName;
  String guaName;
  Tuple3<String, String, String>? jieQiData;
  GongFixedContent(
      {required this.numberName, required this.guaName, this.jieQiData});
}

class Cell extends StatefulWidget {
  @override
  final GlobalKey<CellState> key;
  final String gongName;
  Widget child;

  Cell({required this.key, required this.gongName, required this.child})
      : super(key: key);

  @override
  CellState createState() => CellState();
}

class CellState extends State<Cell> {
  // String value = '';
  Color color = Colors.transparent;

  void updateValue(String newValue, Color newColor) {
    setState(() {
      // value = newValue;
      color = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: widget.child,
      // child: Center(child: Text(widget.gongName)),
    );
  }
}
