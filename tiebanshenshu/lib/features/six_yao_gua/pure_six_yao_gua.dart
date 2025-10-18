import 'package:common/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'enum_6_shou.dart';

part 'pure_six_yao_gua.g.dart';

enum EnumYaoOrder {
  @JsonValue("初")
  init(order: 1, name: '初', indexAtYaoList: 0),
  @JsonValue("二")
  second(order: 2, name: '二', indexAtYaoList: 1),
  @JsonValue("三")
  third(order: 3, name: '三', indexAtYaoList: 2),
  @JsonValue("四")
  fourth(order: 4, name: '四', indexAtYaoList: 3),
  @JsonValue("五")
  fifth(order: 5, name: '五', indexAtYaoList: 4),
  @JsonValue("上")
  top(order: 6, name: '上', indexAtYaoList: 5),
  @JsonValue("无")
  none(order: -1, name: '无', indexAtYaoList: 6);

  final String name;
  final int indexAtYaoList;
  final int order;
  const EnumYaoOrder({
    required this.order,
    required this.name,
    required this.indexAtYaoList,
  });
  static EnumYaoOrder fromOrder(int order) {
    return EnumYaoOrder.values.firstWhere((element) => element.order == order);
  }

  static EnumYaoOrder fromIndex(int index) {
    return EnumYaoOrder.values.firstWhere(
      (element) => element.indexAtYaoList == index,
    );
  }

  static EnumYaoOrder fromName(String name) {
    return EnumYaoOrder.values.firstWhere((element) => element.name == name);
  }
}

enum Enum64Gua {
  @JsonValue("乾")
  qian_wei_tian("乾为天", "乾", Enum8Gua.Qian, Enum8Gua.Qian),
  @JsonValue("姤")
  tian_feng_gou("天风姤", "姤", Enum8Gua.Qian, Enum8Gua.Xun),
  @JsonValue("遁")
  tian_shan_dun("天山遁", "遁", Enum8Gua.Qian, Enum8Gua.Gen),
  @JsonValue("否")
  tian_di_pi("天地否", "否", Enum8Gua.Qian, Enum8Gua.Kun),
  @JsonValue("观")
  feng_di_guan("风地观", "观", Enum8Gua.Xun, Enum8Gua.Gen),
  @JsonValue("剥")
  shan_di_bo("山地剥", "剥", Enum8Gua.Gen, Enum8Gua.Kun),
  @JsonValue("晋")
  huo_di_jin("火地晋", "晋", Enum8Gua.Li, Enum8Gua.Kun),
  @JsonValue("大有")
  huo_tian_da_you("火天大有", "大有", Enum8Gua.Li, Enum8Gua.Qian),

  @JsonValue("兑")
  dui_wei_ze("兑为泽", "泽", Enum8Gua.Dui, Enum8Gua.Dui),
  @JsonValue("困")
  ze_shui_kun("泽水困", "困", Enum8Gua.Dui, Enum8Gua.Kan),
  @JsonValue("萃")
  ze_di_cui("泽地萃", "萃", Enum8Gua.Dui, Enum8Gua.Kun),
  @JsonValue("咸")
  ze_shan_xian("泽山咸", "咸", Enum8Gua.Dui, Enum8Gua.Gen),
  @JsonValue("蹇")
  shui_shan_jian("水山蹇", "蹇", Enum8Gua.Kan, Enum8Gua.Gen),
  @JsonValue("谦")
  di_shan_qian("地山谦", "谦", Enum8Gua.Kun, Enum8Gua.Gen),
  @JsonValue("小过")
  lei_shan_xiao_gu("雷山小过", "小过", Enum8Gua.Zhen, Enum8Gua.Gen),
  @JsonValue("归妹")
  lei_ze_gui_mei("雷泽归妹", "归妹", Enum8Gua.Zhen, Enum8Gua.Dui),

  @JsonValue("离")
  li_wei_huo("离为火", "火", Enum8Gua.Li, Enum8Gua.Li),
  @JsonValue("旅")
  huo_shan_lv("火山旅", "旅", Enum8Gua.Li, Enum8Gua.Gen),
  @JsonValue("鼎")
  huo_feng_ding("火风鼎", "鼎", Enum8Gua.Li, Enum8Gua.Xun),
  @JsonValue("未济")
  huo_shui_wei_ji("火水未济", "未济", Enum8Gua.Li, Enum8Gua.Kan),
  @JsonValue("蒙")
  shan_shui_meng("山水蒙", "蒙", Enum8Gua.Gen, Enum8Gua.Kan),
  @JsonValue("涣")
  feng_shui_huan("风水涣", "涣", Enum8Gua.Xun, Enum8Gua.Kan),
  @JsonValue("讼")
  tian_shui_song("天水讼", "讼", Enum8Gua.Qian, Enum8Gua.Kan),
  @JsonValue("同人")
  tian_huo_tong_ren("天火同人", "同人", Enum8Gua.Qian, Enum8Gua.Li),

  @JsonValue("震")
  zhen_wei_lei("震为雷", "雷", Enum8Gua.Zhen, Enum8Gua.Zhen),
  @JsonValue("豫")
  lei_di_yu("雷地豫", "豫", Enum8Gua.Zhen, Enum8Gua.Kun),
  @JsonValue("解")
  lei_shui_jie("雷水解", "解", Enum8Gua.Zhen, Enum8Gua.Kan),
  @JsonValue("恒")
  lei_feng_heng("雷风恒", "恒", Enum8Gua.Zhen, Enum8Gua.Xun),
  @JsonValue("升")
  di_feng_sheng("地风升", "升", Enum8Gua.Kun, Enum8Gua.Xun),
  @JsonValue("井")
  shui_feng_jing("水风井", "井", Enum8Gua.Kan, Enum8Gua.Xun),
  @JsonValue("大过")
  ze_feng_da_guo("泽风大过", "大过", Enum8Gua.Dui, Enum8Gua.Xun),
  @JsonValue("随")
  ze_lei_sui("泽雷随", "随", Enum8Gua.Dui, Enum8Gua.Zhen),

  @JsonValue("巽")
  xun_wei_feng("巽为风", "风", Enum8Gua.Xun, Enum8Gua.Xun),
  @JsonValue("小畜")
  feng_tian_xiao_xu("风天小畜", "小畜", Enum8Gua.Xun, Enum8Gua.Qian),
  @JsonValue("家人")
  feng_huo_jia_ren("风火家人", "家人", Enum8Gua.Xun, Enum8Gua.Li),
  @JsonValue("益")
  feng_lei_yi("风雷益", "益", Enum8Gua.Xun, Enum8Gua.Zhen),
  @JsonValue("无妄")
  tian_lei_wu_wang("天雷无妄", "无妄", Enum8Gua.Qian, Enum8Gua.Zhen),
  @JsonValue("噬嗑")
  huo_lei_shi_he("火雷噬嗑", "噬嗑", Enum8Gua.Li, Enum8Gua.Zhen),
  @JsonValue("颐")
  shan_lei_yi("山雷颐", "颐", Enum8Gua.Gen, Enum8Gua.Zhen),
  @JsonValue("蛊")
  shan_feng_gu("山风蛊", "蛊", Enum8Gua.Gen, Enum8Gua.Xun),

  @JsonValue("坎")
  kan_wei_shui("坎为水", "水", Enum8Gua.Kan, Enum8Gua.Kan),
  @JsonValue("节")
  shui_ze_jie("水泽节", "节", Enum8Gua.Kan, Enum8Gua.Dui),
  @JsonValue("屯")
  shui_lei_tun("水雷屯", "屯", Enum8Gua.Kan, Enum8Gua.Zhen),
  @JsonValue("既济")
  shui_huo_ji_ji("水火既济", "既济", Enum8Gua.Kan, Enum8Gua.Li),
  @JsonValue("革")
  ze_huo_ge("泽火革", "革", Enum8Gua.Dui, Enum8Gua.Li),
  @JsonValue("丰")
  lei_huo_feng("雷火丰", "丰", Enum8Gua.Zhen, Enum8Gua.Li),
  @JsonValue("明夷")
  di_huo_ming_yi("地火明夷", "明夷", Enum8Gua.Kun, Enum8Gua.Li),
  @JsonValue("师")
  di_shui_shi("地水师", "师", Enum8Gua.Kun, Enum8Gua.Kan),

  @JsonValue("艮")
  gen_wei_shan("艮为山", "山", Enum8Gua.Gen, Enum8Gua.Gen),
  @JsonValue("贲")
  shan_huo_bi("山火贲", "贲", Enum8Gua.Gen, Enum8Gua.Li),
  @JsonValue("大畜")
  shan_tian_da_xu("山天大畜", "大畜", Enum8Gua.Gen, Enum8Gua.Qian),
  @JsonValue("损")
  shan_ze_sun("山泽损", "损", Enum8Gua.Gen, Enum8Gua.Dui),
  @JsonValue("睽")
  huo_ze_kui("火泽睽", "睽", Enum8Gua.Li, Enum8Gua.Dui),
  @JsonValue("履")
  tian_ze_lv("天泽履", "履", Enum8Gua.Qian, Enum8Gua.Dui),
  @JsonValue("中孚")
  feng_ze_zhong_fu("风泽中孚", "中孚", Enum8Gua.Xun, Enum8Gua.Dui),
  @JsonValue("渐")
  feng_shan_jian("风山渐", "渐", Enum8Gua.Xun, Enum8Gua.Gen),
  @JsonValue("坤")
  kun_wei_di("坤为地", "地", Enum8Gua.Kun, Enum8Gua.Kun),
  @JsonValue("复")
  di_lei_fu("地雷复", "复", Enum8Gua.Kun, Enum8Gua.Zhen),
  @JsonValue("临")
  di_ze_lin("地泽临", "临", Enum8Gua.Kun, Enum8Gua.Dui),
  @JsonValue("泰")
  di_tian_tai("地天泰", "泰", Enum8Gua.Kun, Enum8Gua.Qian),
  @JsonValue("大壮")
  lei_tian_da_zhuang("雷天大壮", "大壮", Enum8Gua.Zhen, Enum8Gua.Qian),
  @JsonValue("夬")
  ze_tian_guai("泽天夬", "夬", Enum8Gua.Dui, Enum8Gua.Qian),
  @JsonValue("需")
  shui_tian_xu("水天需", "需", Enum8Gua.Kan, Enum8Gua.Qian),
  @JsonValue("比")
  shui_di_bi("水地比", "比", Enum8Gua.Kan, Enum8Gua.Kun);

  final String name;
  final String fullname;

  final Enum8Gua top;
  final Enum8Gua bottom;

  const Enum64Gua(this.fullname, this.name, this.top, this.bottom);
  static Enum64Gua fromName(String name) {
    return Enum64Gua.values.firstWhere((element) => element.name == name);
  }

  static Enum64Gua fromFullName(String fullname) {
    return Enum64Gua.values.firstWhere(
      (element) => element.fullname == fullname,
    );
  }

  static Enum64Gua getBy8Gua(Enum8Gua topGua, Enum8Gua bottomGua) {
    if (topGua == bottomGua) {
      switch (topGua) {
        case Enum8Gua.Qian:
          return Enum64Gua.qian_wei_tian;
        case Enum8Gua.Dui:
          return Enum64Gua.dui_wei_ze;
        case Enum8Gua.Li:
          return Enum64Gua.li_wei_huo;

        case Enum8Gua.Zhen:
          return Enum64Gua.zhen_wei_lei;

        case Enum8Gua.Xun:
          return Enum64Gua.xun_wei_feng;
        case Enum8Gua.Kan:
          return Enum64Gua.kan_wei_shui;
        case Enum8Gua.Gen:
          return Enum64Gua.gen_wei_shan;
        case Enum8Gua.Kun:
          return Enum64Gua.kun_wei_di;
      }
    }
    return Enum64Gua.values.firstWhere(
      (e) => e.fullname.startsWith(topGua.nickname + bottomGua.nickname),
    );
  }

  static Enum64Gua fromBinaryStr(String binaryStr) {
    return fromBinaryList(
      binaryStr.split("").map((e) => int.parse(e)).toList(),
    );
  }

  static Enum64Gua fromBinaryList(List<int> binaryList) {
    final topGua = Enum8Gua.fromBottomTopBinaryStr(
      binaryList.sublist(0, 3).join(""),
    );
    final bottomGua = Enum8Gua.fromBottomTopBinaryStr(
      binaryList.sublist(3).join(""),
    );
    return Enum64Gua.getBy8Gua(bottomGua, topGua);
  }

  List<int> get bottomTopBinaryList => [
    bottom.bottomTopBinaryStr,
    top.bottomTopBinaryStr,
  ].join("").split("").map((e) => int.parse(e)).toList();

  String get bottomTopBinaryStr =>
      "${bottom.bottomTopBinaryStr}${top.bottomTopBinaryStr}";
}

@JsonSerializable()
class GuaYao extends Equatable {
  final EnumYaoOrder order; // 爻位的顺序，初->上
  final YinYang yinYang; // 爻位的阴阳
  TianGan? naJia; // 爻纳甲
  DiZhi? naZhi; // 爻纳支
  LiuQin? liuQin; // 六亲
  Enum6Shou? sixShou; // 六兽
  bool isShiYao; // 是否为世爻
  bool isYingYao; // 是否为应爻

  JiaZi? get ganZhi => naJia != null && naZhi != null
      ? JiaZi.getFromGanZhiEnum(naJia!, naZhi!)
      : null;

  GuaYao({
    required this.order,
    required this.yinYang,
    this.naJia,
    this.naZhi,
    this.liuQin,
    this.sixShou,
    this.isShiYao = false,
    this.isYingYao = false,
  });

  factory GuaYao.fromJson(Map<String, dynamic> json) => _$GuaYaoFromJson(json);

  Map<String, dynamic> toJson() => _$GuaYaoToJson(this);

  GuaYao copyWith({
    EnumYaoOrder? order,
    YinYang? yinYang,
    TianGan? naJia,
    DiZhi? naZhi,
    LiuQin? liuQin,
    Enum6Shou? sixShou,
    bool? isShiYao,
    bool? isYingYao,
  }) {
    return GuaYao(
      order: order ?? this.order,
      yinYang: yinYang ?? this.yinYang,
      naJia: naJia ?? this.naJia,
      naZhi: naZhi ?? this.naZhi,
      liuQin: liuQin ?? this.liuQin,
      sixShou: sixShou ?? this.sixShou,
      isShiYao: isShiYao ?? this.isShiYao,
      isYingYao: isYingYao ?? this.isYingYao,
    );
  }

  @override
  List<Object?> get props => [
    order,
    yinYang,
    naJia,
    naZhi,
    liuQin,
    sixShou,
    isShiYao,
    isYingYao,
  ];
}

@JsonSerializable()
class PureSixYaoGua extends Equatable {
  final Enum64Gua gua;
  Enum8Gua get topGua => gua.top;
  Enum8Gua get bottomGua => gua.bottom;

  final List<GuaYao> yaoList; // 下爻->上爻

  List<GuaYao> get topBottomYaoList => yaoList.reversed.toList(); // 上爻->下爻
  String get binStr =>
      yaoList.map((e) => e.yinYang == YinYang.YIN ? "0" : "1").join("");
  List<int> get binaryList =>
      yaoList.map((e) => e.yinYang == YinYang.YIN ? 0 : 1).toList();
  List<TianGan?> get bottomTopGanList =>
      topBottomYaoList.map((e) => e.naJia).toList();
  List<TianGan?> get topBottomGanList =>
      topBottomYaoList.map((e) => e.naJia).toList().reversed.toList();

  List<DiZhi?> get bottomTopZhiList =>
      topBottomYaoList.map((e) => e.naZhi).toList();
  List<DiZhi?> get topBottomZhiList =>
      topBottomYaoList.map((e) => e.naZhi).toList().reversed.toList();

  List<JiaZi?> get bottomTopJiaZiList => topBottomYaoList.map((e) {
    if (e.naJia == null || e.naZhi == null) {
      return null;
    }
    return JiaZi.getFromGanZhiEnum(e.naJia!, e.naZhi!);
  }).toList();
  List<JiaZi?> get topBottomJiaZiList =>
      bottomTopJiaZiList.toList().reversed.toList();

  String get yaoBinStr =>
      yaoList.map((e) => e.yinYang == YinYang.YIN ? "0" : "1").join("");
  String get topBotYaoBinStr => topBottomYaoList
      .map((e) => e.yinYang == YinYang.YIN ? "0" : "1")
      .join("");

  /// 变爻标签（自下而上索引 0..5 -> 初、二、三、四、五、上）
  static const List<String> _yaoPositionLabels = ["初", "二", "三", "四", "五", "上"];

  /// 获取爻位标签：0->初、1->二、...、5->上
  static String getYaoPositionLabel(int indexFromBottomZeroBased) {
    if (indexFromBottomZeroBased < 0 || indexFromBottomZeroBased > 5) {
      throw ArgumentError("变爻索引越界，应为 0..5，当前: $indexFromBottomZeroBased");
    }
    return _yaoPositionLabels[indexFromBottomZeroBased];
  }

  /// 单爻变卦：按自下而上编号（1..6）进行阴阳翻转，返回变卦的 Gua64Enum
  Enum64Gua bianYaoByOrder(int yaoOrder) {
    if (yaoOrder < 1 || yaoOrder > 6) {
      throw ArgumentError("变爻编号越界，应为 1..6，当前: $yaoOrder");
    }
    final indexFromBottomZeroBased = yaoOrder - 1;
    final newBinary = List<int>.from(binaryList);
    newBinary[indexFromBottomZeroBased] =
        newBinary[indexFromBottomZeroBased] == 0 ? 1 : 0;
    return Enum64Gua.fromBinaryList(newBinary.toList());
  }

  /// 批量变爻：返回 1..6（初..上）爻位对应的变卦映射
  /// 键为 1..6（人类易于理解的爻序），值为对应的 Gua64Enum
  Map<int, Enum64Gua> bianYaoAll() {
    final result = <int, Enum64Gua>{};
    for (int i = 1; i <= 6; i++) {
      result[i] = bianYaoByOrder(i);
    }
    return result;
  }

  /// 带来源标签的候选变卦映射：
  /// - 包含"互卦"
  /// - 包含六个"变爻"（变初爻、变二爻、...、变上爻）
  /// 用于 UI/UseCase 标注条文来源（先天/后天 + 变爻位置）
  Map<String, Enum64Gua> changedVariantsWithLabels() {
    final variants = <String, Enum64Gua>{};
    variants["互卦"] = hu;
    for (int i = 0; i < 6; i++) {
      final label = getYaoPositionLabel(i);
      variants["变${label}爻"] = bianYaoByOrder(i + 1);
    }
    return variants;
  }

  PureSixYaoGua({required this.gua, required this.yaoList});
  factory PureSixYaoGua.by8Gua(Enum8Gua topGua, Enum8Gua bottomGua) {
    final bottomTopBinaryStr =
        "${bottomGua.bottomTopBinaryStr}${topGua.bottomTopBinaryStr}";
    final botTopBinStrList = bottomTopBinaryStr.split("");

    return PureSixYaoGua(
      gua: Enum64Gua.getBy8Gua(topGua, bottomGua),
      yaoList: botTopBinStrList
          .map(
            (b) => GuaYao(
              order: EnumYaoOrder.fromIndex(botTopBinStrList.indexOf(b)),
              yinYang: YinYang.getByBinaryStr(b),
            ),
          )
          .toList(),
    );
  }

  factory PureSixYaoGua.fromJson(Map<String, dynamic> json) =>
      _$PureSixYaoGuaFromJson(json);

  Map<String, dynamic> toJson() => _$PureSixYaoGuaToJson(this);

  copyWith({Enum64Gua? gua, List<GuaYao>? yaoList}) {
    return PureSixYaoGua(
      gua: gua ?? this.gua,
      yaoList: yaoList ?? this.yaoList,
    );
  }

  Enum64Gua get zong {
    final newBinaryList = binaryList.reversed.toList();
    return Enum64Gua.fromBinaryList(newBinaryList);
  }

  Enum64Gua get cuo {
    // 所有的爻，进行 阴变阳、阳变阴的转换
    final newBinaryList = binaryList.map((e) => e == 0 ? 1 : 0).toList();
    return Enum64Gua.fromBinaryList(newBinaryList);
  }

  Enum64Gua get hu {
    // 二、三、四爻为互卦的 初、二、三爻
    final binaryList = this.binaryList;
    final downBinStr = binaryList.sublist(1, 4).join("");
    // 四、五、六爻为互卦的四、五、上 爻
    final upBinStr = binaryList.sublist(2, 5).join("");
    final downGua = Enum8Gua.fromBottomTopBinaryStr(downBinStr);
    final upGua = Enum8Gua.fromBottomTopBinaryStr(upBinStr);
    return Enum64Gua.getBy8Gua(upGua, downGua);
  }

  @override
  List<Object?> get props => [gua, yaoList];
}
