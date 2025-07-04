import 'package:json_annotation/json_annotation.dart';
import 'enum_di_zhi.dart';
import 'enum_five_xing.dart';
import 'enum_tian_gan.dart';

enum TwelveZhangSheng {
  @JsonValue("长生")
  ZHANG_SHEN(0, "长生"),
  @JsonValue("沐浴")
  MU_YU(1, "沐浴"),
  @JsonValue("冠带")
  GUAN_DAI(2, "冠带"),
  @JsonValue("临官")
  LIN_GUAN(3, "临官"),
  @JsonValue("帝旺")
  DI_WANG(4, "帝旺"),
  @JsonValue("衰")
  SHUAI(5, "衰"),
  @JsonValue("病")
  BING(6, "病"),
  @JsonValue("死")
  SI(7, "死"),
  @JsonValue("墓")
  MU(8, "墓"),
  @JsonValue("绝")
  JUE(9, "绝"),
  @JsonValue("胎")
  TAI(10, "胎"),
  @JsonValue("养")
  YANG(11, "养");

  // list 的顺序是根据 values.orderIndex 的顺序
  static final Map<TianGan, List<String>> zhangShengMapper = {
    TianGan.JIA: ["亥", "子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌"],
    TianGan.BING: ["寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥", "子", "丑"],
    TianGan.WU: ["寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥", "子", "丑"],
    TianGan.GENG: ["巳", "午", "未", "申", "酉", "戌", "亥", "子", "丑", "寅", "卯", "辰"],
    TianGan.REN: ["申", "酉", "戌", "亥", "子", "丑", "寅", "卯", "辰", "巳", "午", "未"],
    TianGan.YI: ["午", "巳", "辰", "卯", "寅", "丑", "子", "亥", "戌", "酉", "申", "未"],
    TianGan.DING: ["酉", "申", "未", "午", "巳", "辰", "卯", "寅", "丑", "子", "亥", "戌"],
    TianGan.JI: ["酉", "申", "未", "午", "巳", "辰", "卯", "寅", "丑", "子", "亥", "戌"],
    TianGan.XIN: ["子", "亥", "戌", "酉", "申", "未", "午", "巳", "辰", "卯", "寅", "丑"],
    TianGan.GUI: ["卯", "寅", "丑", "子", "亥", "戌", "酉", "申", "未", "午", "巳", "辰"],
  };

  static final Map<FiveXing, List<DiZhi>> fiveXingZhangShengMapper = {
    FiveXing.MU: [
      DiZhi.HAI,
      DiZhi.ZI,
      DiZhi.CHOU,
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU
    ],
    FiveXing.HUO: [
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU,
      DiZhi.HAI,
      DiZhi.ZI,
      DiZhi.CHOU
    ],
    FiveXing.SHUI: [
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU,
      DiZhi.HAI,
      DiZhi.ZI,
      DiZhi.CHOU,
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI
    ],
    FiveXing.JIN: [
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU,
      DiZhi.HAI,
      DiZhi.ZI,
      DiZhi.CHOU,
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN
    ],
    FiveXing.TU: [
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU,
      DiZhi.HAI,
      DiZhi.ZI,
      DiZhi.CHOU,
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI
    ]
  };
  static final Map<TianGan, List<DiZhi>> zhangShengDiZhiMapper = {
    TianGan.JIA: [
      DiZhi.HAI,
      DiZhi.ZI,
      DiZhi.CHOU,
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU
    ],
    TianGan.BING: [
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU,
      DiZhi.HAI,
      DiZhi.ZI,
      DiZhi.CHOU
    ],
    TianGan.WU: [
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU,
      DiZhi.HAI,
      DiZhi.ZI,
      DiZhi.CHOU
    ],
    TianGan.GENG: [
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU,
      DiZhi.HAI,
      DiZhi.ZI,
      DiZhi.CHOU,
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN
    ],
    TianGan.REN: [
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU,
      DiZhi.HAI,
      DiZhi.ZI,
      DiZhi.CHOU,
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI
    ],
    TianGan.YI: [
      DiZhi.WU,
      DiZhi.SI,
      DiZhi.CHEN,
      DiZhi.MAO,
      DiZhi.YIN,
      DiZhi.CHOU,
      DiZhi.ZI,
      DiZhi.HAI,
      DiZhi.XU,
      DiZhi.YOU,
      DiZhi.SHEN,
      DiZhi.WEI
    ],
    TianGan.DING: [
      DiZhi.YOU,
      DiZhi.SHEN,
      DiZhi.WEI,
      DiZhi.WU,
      DiZhi.SI,
      DiZhi.CHEN,
      DiZhi.MAO,
      DiZhi.YIN,
      DiZhi.CHOU,
      DiZhi.ZI,
      DiZhi.HAI,
      DiZhi.XU,
    ],
    TianGan.JI: [
      DiZhi.YOU,
      DiZhi.SHEN,
      DiZhi.WEI,
      DiZhi.WU,
      DiZhi.SI,
      DiZhi.CHEN,
      DiZhi.MAO,
      DiZhi.YIN,
      DiZhi.CHOU,
      DiZhi.ZI,
      DiZhi.HAI,
      DiZhi.XU,
    ],
    TianGan.XIN: [
      DiZhi.ZI,
      DiZhi.HAI,
      DiZhi.XU,
      DiZhi.YOU,
      DiZhi.SHEN,
      DiZhi.WEI,
      DiZhi.WU,
      DiZhi.SI,
      DiZhi.CHEN,
      DiZhi.MAO,
      DiZhi.YIN,
      DiZhi.CHOU,
    ],
    TianGan.GUI: [
      DiZhi.MAO,
      DiZhi.YIN,
      DiZhi.CHOU,
      DiZhi.ZI,
      DiZhi.HAI,
      DiZhi.XU,
      DiZhi.YOU,
      DiZhi.SHEN,
      DiZhi.WEI,
      DiZhi.WU,
      DiZhi.SI,
      DiZhi.CHEN,
    ],
  };

  final int orderIndex;
  final String name;
  const TwelveZhangSheng(this.orderIndex, this.name);

  // 获取天干对应的禄地
  static DiZhi getLuZhi(TianGan tianGan) {
    final String diZhi =
        zhangShengMapper[tianGan]![TwelveZhangSheng.LIN_GUAN.orderIndex];
    return DiZhi.getFromValue(diZhi)!;
  }

  static TwelveZhangSheng fromIndex(int index) =>
      TwelveZhangSheng.values[index];
  static TwelveZhangSheng fromName(String name) =>
      TwelveZhangSheng.values.firstWhere((element) => element.name == name);
  static TwelveZhangSheng getZhangShengByTianGanDiZhi(
      TianGan tianGan, DiZhi diZhi) {
    var index = zhangShengMapper[tianGan]!.indexOf(diZhi.name);
    return TwelveZhangSheng.fromIndex(index);
  }

  bool get isStrong =>
      {ZHANG_SHEN, MU_YU, GUAN_DAI, LIN_GUAN, DI_WANG}.contains(this);
  bool get isWeak => {SHUAI, BING, SI, MU, JUE, TAI, YANG}.contains(this);

  List<TwelveZhangSheng> get listStrong =>
      [ZHANG_SHEN, MU_YU, GUAN_DAI, LIN_GUAN, DI_WANG];
  List<TwelveZhangSheng> get listWeak => [SHUAI, BING, SI, MU, JUE, TAI, YANG];

  // "子丑寅卯辰巳午未申酉戌亥";
  // "亥戌酉申未午巳辰卯寅丑子";

  // "亥子丑寅卯辰巳午未申酉戌";
  // "寅卯辰巳午未申酉戌亥子丑";
  // "寅卯辰巳午未申酉戌亥子丑";
  // "巳午未申酉戌亥子丑寅卯辰";
  // "申酉戌亥子丑寅卯辰巳午未";
  // "午巳辰卯寅丑子亥戌酉申未";
  // "酉申未午巳辰卯寅丑子亥戌";
  // "酉申未午巳辰卯寅丑子亥戌";
  // "子亥戌酉申未午巳辰卯寅丑";
  // "卯寅丑子亥戌酉申未午巳辰";
}
