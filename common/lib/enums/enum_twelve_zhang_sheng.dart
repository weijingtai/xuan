import 'package:common/enums/enum_tian_gan.dart';

import 'enum_di_zhi.dart';

enum TwelveZhangSheng {
  ZHANG_SHEN(0, "长生"),
  MU_YU(1, "沐浴"),
  GUAN_DAI(2, "冠带"),
  LIN_GUAN(3, "临官"),
  DI_WANG(4, "帝旺"),
  SHUAI(5, "衰"),
  BING(6, "病"),
  SI(7, "死"),
  MU(8, "墓"),
  JUE(9, "绝"),
  TAI(10, "胎"),
  YANG(11, "养");

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

  final int orderIndex;
  final String name;
  const TwelveZhangSheng(this.orderIndex, this.name);

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
