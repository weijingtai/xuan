import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:qimendunjia/utils/arrange_plate_utils.dart';
import 'package:tuple/tuple.dart';

class QiMenDunJiaGong {
  // 后天八卦顺序为id
  int id;
  // 宫名称，如坎，坤， 需要与宫位对应
  String gua; // 中宫因该为 ‘中’

  String? diPan; // 地盘三奇六仪, 中宫可能没有，
  String? diPan_ji; // 地盘三奇六仪，用于寄存中宫

  String? tianPan; // 天盘三奇六仪，中宫可能没有
  String? tianPan_ji; // 天盘三奇六仪，用于寄存中宫

  String? yinPan; // 隐干，阴干

  String? nineStar; // 中宫可能没有
  String? nineStar_ji; // 用于寄存中宫

  String? eightDoor; // 中宫可能没有
  String? eightGod; // 八神
  // 构造方法
  QiMenDunJiaGong(
      {required this.id,
      required this.gua,
      this.diPan,
      this.diPan_ji,
      this.tianPan,
      this.tianPan_ji,
      this.yinPan,
      this.nineStar,
      this.nineStar_ji,
      this.eightDoor,
      this.eightGod});

  @override
  String toString() {
    // TODO: implement toString
    // return super.toString();
    // return "${diPan}[${diPan_ji == null ? "":diPan_ji}]";
    return "$diPan${diPan_ji ?? ""}/$tianPan${tianPan_ji ?? ""}/$yinPan[${nineStar ?? ""}|${eightGod ?? ""}|${eightDoor ?? ""}]";
    // toJsonString
  }
}

enum QiMenDunJiaPlateType {
  turnPlate_divisionAppend, // 转盘奇门，拆补法
  turnPlate_repeatTail, // 转盘奇门, 置润法
}

class QiMenDunJiaPlate {
  // DEFAULT_SAN_QI_LIU_YI_SEQ
  static final DEFAULT_SAN_QI_LIU_YI_SEQ = [
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
  // DEFAULT_NINE_STAR_SEQ
  static final DEFAULT_NINE_STAR_SEQ = [
    "天蓬星",
    "天任星",
    "天冲星",
    "天辅星",
    "天英星",
    "天芮星",
    "天柱星",
    "天心星"
  ];
  // DEFAULT_EIGHT_GOD_SEQ
  static final DEFAULT_EIGHT_GOD_SEQ = [
    "值符",
    "螣蛇",
    "太阴",
    "六合",
    "白虎",
    "玄武",
    "九地",
    "九天"
  ];
  // DEFAULT_TIAN_GAN_SEQ
  static final DEFAULT_TIAN_GAN_SEQ = [
    "甲",
    "乙",
    "丙",
    "丁",
    "戊",
    "己",
    "庚",
    "辛",
    "壬",
    "癸"
  ];
  // DEFAULT_EIGHT_DOOR_SEQ
  static final DEFAULT_EIGHT_DOOR_SEQ = [
    "休门",
    "生门",
    "伤门",
    "杜门",
    "景门",
    "死门",
    "惊门",
    "开门"
  ];
  // CLOCKWISE_ORDER
  static final CLOCKWISE_ORDER = [1, 8, 3, 4, 9, 2, 7, 6];
  // ANTICLOCKWISE_ORDER
  static final ANTICLOCKWISE_ORDER = [1, 6, 7, 2, 9, 4, 3, 8];

  // QI_MEN_GONG_TEMPLATE
  static final List<List<QiMenDunJiaGong>> QI_MEN_GONG_TEMPLATE = [
    [
      QiMenDunJiaGong(id: 4, gua: "巽"),
      QiMenDunJiaGong(id: 9, gua: "离"),
      QiMenDunJiaGong(id: 2, gua: "坤")
    ],
    [
      QiMenDunJiaGong(id: 3, gua: "震"),
      QiMenDunJiaGong(id: 5, gua: "中"),
      QiMenDunJiaGong(id: 7, gua: "兑")
    ],
    [
      QiMenDunJiaGong(id: 8, gua: "艮"),
      QiMenDunJiaGong(id: 1, gua: "坎"),
      QiMenDunJiaGong(id: 6, gua: "乾")
    ],
  ];
  // 元一宫，值符，值使门
  //  index 是后天八卦数
  final List<Tuple2<String, String?>> ORIGINAL_FU_SHI_LIST = [
    const Tuple2("天蓬星", "休门"),
    const Tuple2("天芮星", "死门"),
    const Tuple2("天冲星", "伤门"),
    const Tuple2("天辅星", "杜门"),
    const Tuple2("天禽星", null),
    const Tuple2("天心星", "开门"),
    const Tuple2("天柱星", "惊门"),
    const Tuple2("天任星", "生门"),
    const Tuple2("天英星", "景门"),
  ];

  // tuple1: 旬头
  // tuple2: 符头
  final Map<String, Tuple2<String, String>> XUN_FU_HEADER = {
    "甲子": const Tuple2("甲子", "甲子"),
    "乙丑": const Tuple2("甲子", "甲子"),
    "丙寅": const Tuple2("甲子", "甲子"),
    "丁卯": const Tuple2("甲子", "甲子"),
    "戊辰": const Tuple2("甲子", "甲子"),
    "己巳": const Tuple2("甲子", "己巳"),
    "庚午": const Tuple2("甲子", "己巳"),
    "辛未": const Tuple2("甲子", "己巳"),
    "壬申": const Tuple2("甲子", "己巳"),
    "癸酉": const Tuple2("甲子", "己巳"),
    "甲戌": const Tuple2("甲戌", "甲戌"),
    "乙亥": const Tuple2("甲戌", "甲戌"),
    "丙子": const Tuple2("甲戌", "甲戌"),
    "丁丑": const Tuple2("甲戌", "甲戌"),
    "戊寅": const Tuple2("甲戌", "甲戌"),
    "己卯": const Tuple2("甲戌", "己卯"),
    "庚辰": const Tuple2("甲戌", "己卯"),
    "辛巳": const Tuple2("甲戌", "己卯"),
    "壬午": const Tuple2("甲戌", "己卯"),
    "癸未": const Tuple2("甲戌", "己卯"),
    "甲申": const Tuple2("甲申", "甲申"),
    "乙酉": const Tuple2("甲申", "甲申"),
    "丙戌": const Tuple2("甲申", "甲申"),
    "丁亥": const Tuple2("甲申", "甲申"),
    "戊子": const Tuple2("甲申", "甲申"),
    "己丑": const Tuple2("甲申", "己丑"),
    "庚寅": const Tuple2("甲申", "己丑"),
    "辛卯": const Tuple2("甲申", "己丑"),
    "壬辰": const Tuple2("甲申", "己丑"),
    "癸巳": const Tuple2("甲申", "己丑"),
    "甲午": const Tuple2("甲午", "甲午"),
    "乙未": const Tuple2("甲午", "甲午"),
    "丙申": const Tuple2("甲午", "甲午"),
    "丁酉": const Tuple2("甲午", "甲午"),
    "戊戌": const Tuple2("甲午", "甲午"),
    "己亥": const Tuple2("甲午", "己亥"),
    "庚子": const Tuple2("甲午", "己亥"),
    "辛丑": const Tuple2("甲午", "己亥"),
    "壬寅": const Tuple2("甲午", "己亥"),
    "癸卯": const Tuple2("甲午", "己亥"),
    "甲辰": const Tuple2("甲辰", "甲辰"),
    "乙巳": const Tuple2("甲辰", "甲辰"),
    "丙午": const Tuple2("甲辰", "甲辰"),
    "丁未": const Tuple2("甲辰", "甲辰"),
    "戊申": const Tuple2("甲辰", "甲辰"),
    "己酉": const Tuple2("甲辰", "己酉"),
    "庚戌": const Tuple2("甲辰", "己酉"),
    "辛亥": const Tuple2("甲辰", "己酉"),
    "壬子": const Tuple2("甲辰", "己酉"),
    "癸丑": const Tuple2("甲辰", "己酉"),
    "甲寅": const Tuple2("甲寅", "甲寅"),
    "乙卯": const Tuple2("甲寅", "甲寅"),
    "丙辰": const Tuple2("甲寅", "甲寅"),
    "丁巳": const Tuple2("甲寅", "甲寅"),
    "戊午": const Tuple2("甲寅", "甲寅"),
    "己未": const Tuple2("甲寅", "己未"),
    "庚申": const Tuple2("甲寅", "己未"),
    "辛酉": const Tuple2("甲寅", "己未"),
    "壬戌": const Tuple2("甲寅", "己未"),
    "癸亥": const Tuple2("甲寅", "己未"),
  };
  final List<String> SIX_JIA = [
    "甲子戊",
    "甲戌己",
    "甲申庚",
    "甲午辛",
    "甲辰壬",
    "甲寅癸",
  ];

  // 节气 定局
  final Map<String, Tuple4<int, int, int, bool>> JIE_QI_JU_MAPPER = {
    "冬至": const Tuple4(1, 7, 4, true),
    "惊蛰": const Tuple4(1, 7, 4, true),
    "小寒": const Tuple4(2, 8, 5, true),
    "大寒": const Tuple4(3, 9, 6, true),
    "春分": const Tuple4(3, 9, 6, true),
    "雨水": const Tuple4(9, 6, 3, true),
    "清明": const Tuple4(4, 1, 7, true),
    "立夏": const Tuple4(4, 1, 7, true),
    "立春": const Tuple4(8, 5, 2, true),
    "谷雨": const Tuple4(5, 2, 8, true),
    "小满": const Tuple4(5, 2, 8, true),
    "芒种": const Tuple4(6, 3, 9, true),
    "夏至": const Tuple4(9, 3, 6, false),
    "白露": const Tuple4(9, 3, 6, false),
    "小暑": const Tuple4(8, 2, 5, false),
    "大暑": const Tuple4(7, 1, 4, false),
    "秋分": const Tuple4(7, 1, 4, false),
    "立秋": const Tuple4(2, 5, 8, false),
    "寒露": const Tuple4(6, 9, 3, false),
    "立冬": const Tuple4(6, 9, 3, false),
    "处暑": const Tuple4(1, 4, 7, false),
    "霜降": const Tuple4(5, 8, 2, false),
    "小雪": const Tuple4(5, 8, 2, false),
    "大雪": const Tuple4(4, 7, 1, false),
  };

  // 十二地支定三元
  final Map<String, int> THREE_YUAN_MAPPER = {
    "子": 0,
    "午": 0,
    "卯": 0,
    "酉": 0,
    "寅": 1,
    "申": 1,
    "巳": 1,
    "亥": 1,
    "辰": 2,
    "戌": 2,
    "丑": 2,
    "未": 2,
  };

  late final DateTime plateDateTime;

  late final QiMenDunJiaPlateType plateType;

  // key 是后天八卦数
  final Map<int, QiMenDunJiaGong> _houTianNumber_gongMapper = {};
  // key 是地盘三奇六仪
  final Map<String, QiMenDunJiaGong> _diPan_gongMapper = {};

  List<List<QiMenDunJiaGong>> plate = [[], [], []];
  String yearGanZhi = "";
  String monthGanZhi = "";
  String dayGanZhi = "";
  String timeGanZhi = "";
  String timeGan = ""; // 时干

  String jieQi = "";
  bool isYangDun = true;
  int juNumber = -1;
  String zhiShiDoor = "";
  String zhiFuStar = "";

  QiMenDunJiaPlate({required this.plateDateTime, required this.plateType});

  void arrange() {
    // String dateTime = "2022-12-14 16:30:00"; // 正确

    // String dateTime = "2020-08-10 10:00:00"; // 正确
    // String dateTime = "2020-09-30 18:08:00"; // 正确
    // String dateTime = "2015-02-15 18:08:00"; // 正确

    // var time = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateTime);
    // debugPrint(dateTime);
    // 1. 根据给定的阳历时间获取 四柱以及节气
    Tuple5 ganZhiTuple = ArrangePlateUtils.getGanZhiDateString(plateDateTime);
    yearGanZhi = ganZhiTuple.item1.toString();
    // 月干支
    monthGanZhi = ganZhiTuple.item2.toString();
    // 天干支
    dayGanZhi = ganZhiTuple.item3.toString();
    // 时间
    timeGanZhi = ganZhiTuple.item4.toString();
    timeGan = timeGanZhi.split("").first;
    // 节气
    jieQi = ganZhiTuple.item5.toString();
    debugPrint(DateFormat("yyyy-MM-dd HH:mm:ss").format(plateDateTime));
    debugPrint(ganZhiTuple.toString());
    switch (plateType) {
      case QiMenDunJiaPlateType.turnPlate_divisionAppend:
        plate = arrangeTurnPlate(plateDateTime);
        break;
      case QiMenDunJiaPlateType.turnPlate_repeatTail:
        // TODO: Handle this case.
        throw UnimplementedError("未实现 转盘奇门 置润法");
    }
  }

  // 转盘奇门 拆不法
  List<List<QiMenDunJiaGong>> arrangeTurnPlate(DateTime dateTime) {
    // 2. 根据日期的干支获取符头与旬首
    // 2.1. 节气排盘
    Tuple4<int, int, int, bool> dingJuTuple = JIE_QI_JU_MAPPER[jieQi]!;
    // 2.2. 旬首 与 符头
    Tuple2<String, String> xunShouFuHeader = XUN_FU_HEADER[dayGanZhi]!;
    // 符头
    String dayFuHeader = xunShouFuHeader.item2;
    debugPrint(jsonEncode({
      "节气": dingJuTuple.toString(),
      "旬首": xunShouFuHeader.toString(),
      "符头": dayFuHeader,
    }));
    // assert(dayFuHeader == "己亥");
    // 2.3. 根据日干支所属的符头，以地支获取 上、中、下元
    int yunaType = THREE_YUAN_MAPPER[dayFuHeader.split("").last]!;
    // assert(yunaType == 1);
    // 2.4. 根据 元 的类型确定局
    juNumber = ArrangePlateUtils.getJuNumber(dingJuTuple, yunaType);
    isYangDun = dingJuTuple.item4;
    debugPrint(jsonEncode({"元": yunaType, "局数": juNumber, "阴阳": isYangDun}));

    // 请从 juNumber进行创建list
    List<int> juList = ArrangePlateUtils.yangShunYinNiSeq(juNumber, isYangDun);
    debugPrint(jsonEncode(juList));

    // 2.5. 根据局的顺序，惊醒宫位的排布
    // 使用 juList与defaultSanQiLiuYiSeq
    // zip defaultSeq 与 juList
    List<Tuple2<String, int>> diPan = [];
    for (int i = 0; i < DEFAULT_SAN_QI_LIU_YI_SEQ.length; i++) {
      diPan.add(Tuple2(DEFAULT_SAN_QI_LIU_YI_SEQ[i], juList[i]));
    }
    debugPrint(diPan.toString());
    // debugPrint("diPan: $diPan");
    // 2.6. 根据局的顺序，确定八门的排布
    // 克隆 defaultGongContent 成为 initGongContent

    List<List<QiMenDunJiaGong>> ju = QI_MEN_GONG_TEMPLATE
        .map((e) => e
            .map((e) => QiMenDunJiaGong(
                  id: e.id,
                  gua: e.gua,
                ))
            .toList())
        .toList();

    // print diPan vs two as a table
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        QiMenDunJiaGong currentGong = ju[i][j];
        var currentGongIndex = currentGong.id;
        var tuple = diPan.firstWhere((e) => e.item2 == currentGongIndex);
        currentGong.diPan = tuple.item1;
        _houTianNumber_gongMapper[tuple.item2] = currentGong;
        _diPan_gongMapper[tuple.item1] = currentGong;
      }
    }
    // debugPrint(ju.toString());
    // debugPrint(_houTianNumber_gongMapper.toString());
    // debugPrint(_diPan_gongMapper.toString());

    // 中宫地盘天干寄宫
    QiMenDunJiaGong zhongGongDiPan = _houTianNumber_gongMapper[5]!;
    QiMenDunJiaGong jiInGong = _houTianNumber_gongMapper[2]!;
    jiInGong.diPan_ji = zhongGongDiPan.diPan;

    // 3. 定九星，八门
    // 3.1. 根据时辰干支获取 旬首
    String timeXunShou = XUN_FU_HEADER[timeGanZhi]!.item1;
    // assert(timeXunShou == "甲午");
    // 3.2. 根据旬首，旬首所处的六仪
    String xunShouYi =
        SIX_JIA.firstWhere((e) => e.startsWith(timeXunShou)).substring(2);
    // 3.3. 根据六仪，获取六仪的顺序
    // int yiIndex = defaultSanQiLiuYiSeq.indexOf(xunShouYi);

    // zip defaultSeq 与 juList

    // List<Tuple2<int,String>> yiJuList = zipTwoList(juList, defaultSanQiLiuYiSeq);
    List<Tuple2<int, String>> yiJuList =
        IterableZip([juList, DEFAULT_SAN_QI_LIU_YI_SEQ])
            .map((p) => Tuple2<int, String>(p[0] as int, p[1] as String))
            .toList();
    // 根据 xunShouYi 找到对应的
    int gongIndex = yiJuList.firstWhere((e) => e.item2 == xunShouYi).item1;

    // 根据 gongIndex 与 yiJuList 生成 gongList
    Tuple2<String, String?> gongList1 = ORIGINAL_FU_SHI_LIST[gongIndex - 1];
    zhiFuStar = gongList1.item1;
    zhiShiDoor = gongList1.item2!;

    debugPrint(jsonEncode({
      "list": gongList1.toString(),
      "值符": zhiFuStar,
      "值使": zhiShiDoor,
    }));
    debugPrint("$timeGan, $timeGanZhi");

    // 4. 将时干作为其实的宫位，确定九星的位置
    // 4.1. 将星放在对应十干对应的地盘宫位上
    _diPan_gongMapper[timeGan]!.nineStar = zhiFuStar;
    feiPan(_diPan_gongMapper[timeGan]!.id, zhiFuStar, ju);
    // 天禽星 寄宫
    tianQinStarJiGong_1(ju);

    dingEightShen(_diPan_gongMapper[timeGan]!.id, ju, isYangDun);
    debugPrint(ju.toString());

    // 5. 定门
    debugPrint(xunShouYi);
    String diPanGan = dingDoor(xunShouYi, ju);

    debugPrint("$zhiShiDoor, $diPanGan, $isYangDun");
    arrangeDoor(zhiShiDoor, diPanGan, ju, isYangDun);

    // 6. 定天盘
    debugPrint(gongIndex.toString());
    dingTianPan(gongIndex);
    tianPanJiGong();

    dingYinPan_1(zhiShiDoor, ju, isYangDun);
    debugPrint("---------------");
    debugPrint(ju.toString());
    return ju;
  }

  // 转盘奇门
  // 根据给定信息进行飞盘
  // 排九星
  void feiPan(int startFromId, String xing, List<List<QiMenDunJiaGong>> pan) {
    // final forwardTimeMinutsPointSeq = [1,8,3,4,9,2,7,6];
    List<int> gongSeq =
        ArrangePlateUtils.turingListSeq(CLOCKWISE_ORDER, startFromId);

    List<String> nineStarSeq =
        ArrangePlateUtils.turingStringListSeq(DEFAULT_NINE_STAR_SEQ, xing);
    // zip nineStarSeq 与 seq
    List<Tuple2<int, String>> nineStarSeq1 = IterableZip([gongSeq, nineStarSeq])
        .map((p) => Tuple2<int, String>(p[0] as int, p[1] as String))
        .toList();
    // 根据 nineStarSeq1 与 seq 生成 gongList
    // 跳过第一个，因为已经在其中了
    // 对pan 进行 flatmap 操作 便于后续的操作

    nineStarSeq1.skip(1).forEach((t) {
      // 根据给定的id，找到对应的宫位
      _houTianNumber_gongMapper[t.item1]!.nineStar = t.item2;
    });
    pan[1][1].nineStar = "天禽星";
  }

  // 天盘寄宫
  void tianPanJiGong() {
    // 找到存在“地盘寄宫”的地盘天干
    QiMenDunJiaGong diPanJiGong =
        _houTianNumber_gongMapper.values.firstWhere((e) => e.diPan_ji != null);
    // 找到天盘中对应这个 diPanJiGong.diPan
    QiMenDunJiaGong tianPanJiGong = _houTianNumber_gongMapper.values
        .firstWhere((e) => e.tianPan == diPanJiGong.diPan);
    // diPanJiGong 的 ji宫设置给 tianPanJiGong.tianPan_ji
    tianPanJiGong.tianPan_ji = diPanJiGong.diPan_ji;
  }

  void dingTianPan(int gongIndex) {
    // 6.1. 根据 gongIndex 获取对应的宫位天干
    // String gongTianGan = houTianNumber_gongMapper[gongIndex]!.diPan!;
    // 6.2. 根据十干获取对应的宫位的编号
    int diPanId = _diPan_gongMapper[timeGan]!.id;
    // 6.3. 对其顺时针宫位编号，以及天的"干"
    List<int> tianPanTimeList =
        ArrangePlateUtils.turingListSeq(CLOCKWISE_ORDER, diPanId);
    debugPrint("$diPanId $tianPanTimeList");
    // 6.4. 从旬首所在宫顺时针获取所有地支g
    List<int> tmpTianPanTimeList =
        ArrangePlateUtils.turingListSeq(CLOCKWISE_ORDER, gongIndex);
    List<String> tianPanSeq = tmpTianPanTimeList
        .map((e) => _houTianNumber_gongMapper[e]!.diPan!)
        .toList();
    // zip tianPanSeq 与 tianPanTimeList
    // List<Tuple2<int,String>> tianPanSeq1 = zipTwoList(tianPanTimeList,tianPanSeq);
    List<Tuple2<int, String>> tianPanSeq1 =
        IterableZip([tianPanTimeList, tianPanSeq])
            .map((p) => Tuple2<int, String>(p[0] as int, p[1] as String))
            .toList();
    // 根据 tianPanSeq1 放入
    for (var t in tianPanSeq1) {
      _houTianNumber_gongMapper[t.item1]!.tianPan = t.item2;
    }
  }

  // 排八神
  void dingEightShen(
      int startFromId, List<List<QiMenDunJiaGong>> pan, bool isYangDun) {
    List<int> seq = isYangDun
        ? CLOCKWISE_ORDER.toList(growable: true)
        : ANTICLOCKWISE_ORDER.toList(growable: true);
    seq = ArrangePlateUtils.turingListSeq(seq, startFromId);
    // zip nineStarSeq 与 seq
    // List<Tuple2<int,String>> nineStarSeq1 = zipTwoList(seq,defaultEightShenSeq);
    List<Tuple2<int, String>> nineStarSeq1 =
        IterableZip([seq, DEFAULT_EIGHT_GOD_SEQ])
            .map((p) => Tuple2<int, String>(p[0] as int, p[1] as String))
            .toList();
    for (var t in nineStarSeq1) {
      // 根据给定的id，找到对应的宫位
      _houTianNumber_gongMapper[t.item1]!.eightGod = t.item2;
    }
  }

  String dingDoor(String xunShouTianGan, List<List<QiMenDunJiaGong>> pan) {
    // 5.1. 根据时辰的旬首，找到对应的地支
    // 从initGongContent中找 xunShouYi 对应的天干
    // EachGong xunShouGong = pan.expand((e) => e).toList().firstWhere((e) => e.diPan == xunShouTianGan);
    // 计算从 xunShouYi 到 时辰的天干
    // 5.2. 根据地支，找到对应的八门
    List<String> seq = ArrangePlateUtils.turingStringListSeq(
        DEFAULT_SAN_QI_LIU_YI_SEQ, xunShouTianGan);
    debugPrint("!!!!!!!!!!!!!!!!!!!!!!!!!!");
    debugPrint(seq.toString());
    // String timeGan =timeGanZhi.split("").first;
    int timeGanIndex = DEFAULT_TIAN_GAN_SEQ.indexOf(timeGan);
    debugPrint(DEFAULT_TIAN_GAN_SEQ.toString());
    debugPrint(timeGanIndex.toString());
    debugPrint("!!!!!!!!!!!!!!!!!!!!!!!!!!");
    return seq[timeGanIndex];
  }

  void arrangeDoor(String zhiShiDoor, String zhiShiDoorGan,
      List<List<QiMenDunJiaGong>> pan, bool isYangDun) {
    // flatmap pan
    List<QiMenDunJiaGong> panList = pan.expand((e) => e).toList();
    int firstDoorInGongIndex = -1;
    panList.map((e) {
      if (e.diPan == zhiShiDoorGan) {
        e.eightDoor = zhiShiDoor;
        firstDoorInGongIndex = e.id;
      }
    }).toList();
    List<String> doorList = ArrangePlateUtils.turingStringListSeq(
        DEFAULT_EIGHT_DOOR_SEQ, zhiShiDoor);
    debugPrint(doorList.toString());
    List<int> gongIndexSeq =
        ArrangePlateUtils.turingListSeq(CLOCKWISE_ORDER, firstDoorInGongIndex);
    debugPrint(gongIndexSeq.toString());
    // zip gongIndexSeq与doorList

    // List<Tuple2<int,String>> gongIndexSeq1 = zipTwoList(gongIndexSeq,doorList);
    List<Tuple2<int, String>> gongIndexSeq1 =
        IterableZip([gongIndexSeq, doorList])
            .map((p) => Tuple2<int, String>(p[0] as int, p[1] as String))
            .toList();
    // 根据 gongIndexSeq1 与 doorList 生成 gongList
    // 跳过第一个，因为已经在其中了

    gongIndexSeq1.skip(1).forEach((t) {
      _houTianNumber_gongMapper[t.item1]!.eightDoor = t.item2;
      // 根据给定的id，找到对应的宫位
    });
  }

  // 永远寄在坤二宫，一直与天芮星一起
  void tianQinStarJiGong_1(List<List<QiMenDunJiaGong>> ju) {
    // 找到天芮星所在宫位并将“天禽星”设置上
    QiMenDunJiaGong tianQinGong =
        _houTianNumber_gongMapper.values.firstWhere((e) => e.nineStar == "天芮星");
    tianQinGong.nineStar_ji = "天禽星";
  }

  // 寄二八宫，天禽星阴遁寄在坤二宫，阳遁寄在艮八宫。
  void tianQinStarJiGong_2() {}

  // 寄四维宫，四维宫，具体而言，分别指艮八宫、巽四宫、坤二宫和乾六宫。
  // 天禽星是如何寄四隅宫的呢？根据二十四节气配八宫表，可知立春在艮八宫，立夏在巽四宫，立秋在坤二宫，立冬在乾六宫。所以天禽星春季寄艮八宫，夏季寄巽四宫，秋季寄坤二宫，冬季寄乾六宫。
  void tianQinStarJiGong_3() {}

  // 寄八节法
  // 八宫我们知道，就是从坎一宫开始，顺时针转起，依次为艮八宫、震三宫、巽四宫、离九宫、坤二宫、兑七宫、乾六宫。
  // 那八节又指的是哪八个节气呢？所谓八节，即立春、春分、立夏、夏至、立秋、秋分、立冬、冬至。
  // 立春、春雨、惊蛰三个节气，寄居艮八宫；
  // 春分、清明、谷雨三个节气，寄居震三宫；
  // 立夏、小满、芒种三个节气，寄居巽四宫；
  // 夏至、小暑、大暑三个节气，寄居离九宫；
  // 立秋、处暑、白露三个节气，寄居坤二宫；
  // 秋分、寒露、霜降三个节气，寄居兑七宫；
  // 立冬、小雪、大雪三个节气，寄居乾六宫；
  // 冬至、小寒、大寒三个节气，寄居坎一宫。
  void tianQinStarJiGong_4() {}

  // 时干找值使法
  // 1. 首先十干进入值使门所在的宫位上
  //  1.1. 如果 十干与值使门所在宫位的地盘相同，则直接进入则进入中宫
  //  1.2. 如果不同，则继续下一步
  // 2. 随后按照 阳顺阴逆的顺序以九宫数排入 “戊己庚辛壬癸丁丙乙”
  void dingYinPan_1(
      String zhiShiDoor, List<List<QiMenDunJiaGong>> ju, bool isYangDun) {
    // debugPrint("$shiGan -- $zhiShiDoor -- $isYangDun");
    // find eachGong from ju bu zhiShiDoor
    List<QiMenDunJiaGong> zhiShiGongList = ju.expand((e) => e).toList();
    QiMenDunJiaGong zhiShiGong =
        zhiShiGongList.firstWhere((e) => e.eightDoor == zhiShiDoor);

    // find eachGong from ju bu shiGan
    int fromGongNumber = zhiShiGong.id;
    // 1. 十干与值使门所在宫位的地盘相同，则直接进入则进入中宫
    if (zhiShiGong.diPan == timeGan) {
      fromGongNumber = 5;
    }
    // debugPrint("zhiShiGong: ${zhiShiGong.gua} , $fromGongNumber");

    List<int> juList =
        ArrangePlateUtils.yangShunYinNiSeq(fromGongNumber, isYangDun);

    List<String> ganList = ArrangePlateUtils.turingStringListSeq(
        DEFAULT_SAN_QI_LIU_YI_SEQ, timeGan);

    // debugPrint(juList.toString());
    // debugPrint(ganList.toString());

    // zip
    // List<Tuple2<int,String>> ganJuList = zipTwoList(juList, ganList);
    List<Tuple2<int, String>> ganJuList = IterableZip([juList, ganList])
        .map((p) => Tuple2<int, String>(p[0] as int, p[1] as String))
        .toList();
    // 根据 ganJuList 生成 gongList
    for (var t in ganJuList) {
      _houTianNumber_gongMapper[t.item1]!.yinPan = t.item2;
    }
  }
}
