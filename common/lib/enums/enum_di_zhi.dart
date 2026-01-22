import 'package:json_annotation/json_annotation.dart';

import 'enum_chinese_12_zodic.dart';
import 'enum_five_xing.dart';
import 'enum_month_token.dart';
import 'enum_ten_gods.dart';
import 'enum_tian_gan.dart';
import 'enum_yin_yang.dart';

enum DiZhi {
  @JsonValue("子")
  ZI("子", 1),
  @JsonValue("丑")
  CHOU("丑", 2),
  @JsonValue("寅")
  YIN("寅", 3),
  @JsonValue("卯")
  MAO("卯", 4),
  @JsonValue("辰")
  CHEN("辰", 5),
  @JsonValue("巳")
  SI("巳", 6),
  @JsonValue("午")
  WU("午", 7),
  @JsonValue("未")
  WEI("未", 8),
  @JsonValue("申")
  SHEN("申", 9),
  @JsonValue("酉")
  YOU("酉", 10),
  @JsonValue("戌")
  XU("戌", 11),
  @JsonValue("亥")
  HAI("亥", 12);

  final int order;
  final String value;
  String get name => value;
  const DiZhi(this.value, this.order);

  // 六冲地支
  DiZhi get sixChongZhi => DiZhiChong.getOtherDiZhi(this);
  // 六合
  DiZhi get sixHeZhi => DiZhiHe.getOtherDiZhi(this);

  // 六破
  DiZhi get sixPoZhi => DiZhiPo.getOtherDiZhi(this);

  // 六害
  DiZhi get sixHaiZhi => DiZhiHai.getOtherDiZhi(this);

  static DiZhi? getFromValue(String value) {
    for (var element in DiZhi.values) {
      if (element.value == value) {
        return element;
      }
    }
    return null;
  }

  static DiZhi getByOrder(int order) {
    assert(order >= 1 && order <= 12);
    return DiZhi.values[order - 1];
  }

  FiveXing get fiveXing {
    switch (this) {
      case DiZhi.YIN:
      case DiZhi.MAO:
        return FiveXing.MU;
      case DiZhi.SI:
      case DiZhi.WU:
        return FiveXing.HUO;
      case DiZhi.HAI:
      case DiZhi.ZI:
        return FiveXing.SHUI;
      case DiZhi.SHEN:
      case DiZhi.YOU:
        return FiveXing.JIN;
      default:
        return FiveXing.TU;
    }
  }

  YinYang get yinYang {
    if (['子', '寅', '辰', '午', '申', '戌'].contains(value)) {
      return YinYang.YANG;
    } else {
      return YinYang.YIN;
    }
  }

  bool get isYang => yinYang == YinYang.YANG;
  bool get isYin => yinYang == YinYang.YIN;

  (FiveXing, YinYang) get yinYangFiveXing {
    return (fiveXing, yinYang);
  }

  // 藏干
  List<TianGan> get cangGan {
    switch (this) {
      case DiZhi.ZI:
        return [TianGan.GUI];
      case DiZhi.CHOU:
        return [TianGan.JI, TianGan.GUI, TianGan.XIN];
      case DiZhi.YIN:
        return [TianGan.JIA, TianGan.BING, TianGan.WU];
      case DiZhi.MAO:
        return [TianGan.YI];
      case DiZhi.CHEN:
        return [TianGan.WU, TianGan.YI, TianGan.GUI];
      case DiZhi.SI:
        return [TianGan.BING, TianGan.GENG, TianGan.WU];
      case DiZhi.WU:
        return [TianGan.DING, TianGan.JI];
      case DiZhi.WEI:
        return [TianGan.JI, TianGan.DING, TianGan.YI];
      case DiZhi.SHEN:
        return [TianGan.GENG, TianGan.REN, TianGan.WU];
      case DiZhi.YOU:
        return [TianGan.XIN];
      case DiZhi.XU:
        return [TianGan.WU, TianGan.XIN, TianGan.DING];
      case DiZhi.HAI:
        return [TianGan.REN, TianGan.JIA];
    }
  }

  EnumChinese12Zodiac get chinese12Zodiac =>
      EnumChinese12Zodiac.fromDiZhi(this);

  List<EnumTenGods> getTenGods(TianGan dayMaster) {
    return cangGan
        .map((hiddenStem) => hiddenStem.getTenGods(dayMaster))
        .toList();
  }

  static List<DiZhi> get listAll {
    return [ZI, CHOU, YIN, MAO, CHEN, SI, WU, WEI, SHEN, YOU, XU, HAI];
  }

  static Set<DiZhi> get fourMuYu {
    // 沐浴之地
    return {ZI, WU, MAO, YOU};
  }

  static Set<DiZhi> get fourYiMa {
    // 四驿马
    return {YIN, SHEN, SI, HAI};
  }

  static Set<DiZhi> get fourMuKu {
    // 四墓库
    // 墓库之地
    return {CHEN, XU, CHOU, WEI};
  }

  MonthToken get asMonthToken => MonthToken.fromDiZhi(this);
  bool get isSelfXing =>
      [DiZhi.CHEN, DiZhi.WU, DiZhi.YOU, DiZhi.HAI].contains(this);
  // {
  //   if ([DiZhi.CHEN,DiZhi.WU,DiZhi.YOU,DiZhi.HAI].contains(this)){
  //     switch(this){
  //       case DiZhi.CHEN:
  //         return DiZhiXing.CHEN_CHEN;
  //       case DiZhi.WU:
  //         return DiZhiXing.WU_WU;
  //       case DiZhi.YOU:
  //         return DiZhiXing.YOU_YOU;
  //       case DiZhi.HAI:
  //         return DiZhiXing.HAI_HAI;
  //        default:
  //         return null;
  //     }
  //   }
  //   return null;
  // }
}

enum DiZhiRelationship {
  XING("刑"),
  CHONG("冲"),

  HE("合"),
  AN_HE("暗合"),
  SAN_HE("三合"),

  HAI("害"),
  PO("破"),
  SHEN_DI_BAN_HE("生地半合"),
  MU_DI_BAN_HE("墓地半合"),
  SAN_HUI("三会");

  const DiZhiRelationship(this.name);
  final String name;
}
// ... 现有代码 ...

enum DiZhiHe {
  // 地支六合
  ZI_CHOU(name: "子丑", content: {DiZhi.ZI, DiZhi.CHOU}, heResult: FiveXing.TU),
  YIN_HAI(name: "寅亥", content: {DiZhi.YIN, DiZhi.HAI}, heResult: FiveXing.MU),
  MAO_XU(name: "卯戌", content: {DiZhi.MAO, DiZhi.XU}, heResult: FiveXing.HUO),
  CHEN_YOU(
      name: "辰酉", content: {DiZhi.CHEN, DiZhi.YOU}, heResult: FiveXing.JIN),
  SI_SHEN(name: "巳申", content: {DiZhi.SI, DiZhi.SHEN}, heResult: FiveXing.SHUI),
  WU_WEI(name: "午未", content: {DiZhi.WU, DiZhi.WEI}, heResult: FiveXing.TU);

  final String name;
  final Set<DiZhi> content;
  final FiveXing heResult;
  const DiZhiHe(
      {required this.name, required this.content, required this.heResult});

  static DiZhiHe? getFromSingleDiZhi(DiZhi single) {
    return DiZhiHe.values.firstWhere((e) => e.content.contains(single));
  }

  static DiZhi getOtherDiZhi(DiZhi single) {
    DiZhi? res;

    for (var e in getFromSingleDiZhi(single)!.content) {
      if (e != single) {
        res = e;
      }
    }
    return res!;
  }

  static DiZhiHe? getFromValue(String diZhiStr) {
    if (diZhiStr.length != 2) {
      throw Exception("DiZhiHe value is not valid with value:$diZhiStr");
    }
    // 检查是否全部是地支
    Set<String> set = diZhiStr.split("").toSet();
    if (set.length == 1) {
      return DiZhiHe.getFromSingleDiZhi(DiZhi.getFromValue(set.first)!);
    }
    if (!DiZhi.listAll.map((d) => d.value).toSet().containsAll(set)) {
      return throw Exception("DiZhiHe value is not valid with value:$diZhiStr");
    }

    Set<DiZhi> diZhiSet = set.map((e) => DiZhi.getFromValue(e)!).toSet();

    return getFromDiZhi(diZhiSet.first, diZhiSet.last);
  }

  static DiZhiHe? getFromDiZhi(DiZhi diZhi1, DiZhi diZhi2) {
    if (diZhi1 == diZhi2) {
      return null;
    }
    DiZhiHe? he = getFromSingleDiZhi(diZhi1);
    if (he != null && he.content.contains(diZhi2)) {
      return he;
    }
    return null;
  }
}

enum DiZhiXing {
  ZI_MAO(name: "子卯", nickname1: "无礼之刑", content: [DiZhi.ZI, DiZhi.MAO]),
  // 固定刑克顺序
  YIN_SI_SHEN(
      name: "寅巳申",
      nickname1: "无恩之刑",
      content: [DiZhi.YIN, DiZhi.SI, DiZhi.SHEN]),
  CHOU_XU_WEI(
      name: "丑戌未",
      nickname1: "持势之刑",
      content: [DiZhi.CHOU, DiZhi.XU, DiZhi.WEI]),
  CHEN_CHEN(name: "辰辰", nickname1: "辰辰自刑", content: [DiZhi.CHEN]),
  WU_WU(name: "午午", nickname1: "午午自刑", content: [DiZhi.WU]),
  YOU_YOU(name: "酉酉", nickname1: "酉酉自刑", content: [DiZhi.YOU]),
  HAI_HAI(name: "亥亥", nickname1: "亥亥自刑", content: [DiZhi.HAI]);

  final String name;
  final String nickname1;
  final List<DiZhi> content;

  const DiZhiXing({
    required this.name,
    required this.nickname1,
    required this.content,
  });

  static DiZhiXing? getFromValue(String value) {
    if (value.isEmpty) {
      throw Exception("DiZhiXing value is empty");
    }
    Set<String> set = value.split("").toSet();
    Set<String> allDiZhiSet = DiZhi.listAll.map((d) => d.value).toSet();
    if (set.any((e) => !allDiZhiSet.contains(e))) {
      throw Exception("DiZhiXing value is not valid with value:$value");
    }

    Set<DiZhi> diZhiSet = set.map((e) => DiZhi.getFromValue(e)!).toSet();
    return getFromValueDiZhi(diZhiSet);
  }

  static DiZhiXing? getFromValueDiZhi(Set<DiZhi> diZhiSet) {
    /// @return 返回null是则为非刑
    if (diZhiSet.isEmpty) {
      throw Exception("DiZhiXing value is empty");
    }
    if (diZhiSet.length == 1) {
      switch (diZhiSet.first) {
        case DiZhi.WU:
          return DiZhiXing.WU_WU;
        case DiZhi.CHEN:
          return DiZhiXing.CHEN_CHEN;
        case DiZhi.YOU:
          return DiZhiXing.YOU_YOU;
        case DiZhi.HAI:
          return DiZhiXing.HAI_HAI;
        default:
          return null;
      }
    } else if (diZhiSet.length == 2) {
      // 只有可能是子卯相刑
      if (diZhiSet.contains(DiZhi.ZI) && diZhiSet.contains(DiZhi.MAO)) {
        return DiZhiXing.ZI_MAO;
      } else {
        return null;
      }
    } else if (diZhiSet.length == 3) {
      if (diZhiSet.contains(DiZhi.YIN) &&
          diZhiSet.contains(DiZhi.SI) &&
          diZhiSet.contains(DiZhi.SHEN)) {
        return DiZhiXing.YIN_SI_SHEN;
      } else if (diZhiSet.contains(DiZhi.XU) &&
          diZhiSet.contains(DiZhi.CHOU) &&
          diZhiSet.contains(DiZhi.WEI)) {
        return DiZhiXing.CHOU_XU_WEI;
      } else {
        return null;
      }
    } else {
      throw Exception("DiZhiXing value is not valid");
    }
  }

  static DiZhiXing getFromSingle(DiZhi single) {
    switch (single) {
      case DiZhi.ZI:
      case DiZhi.MAO:
        return DiZhiXing.ZI_MAO;
      case DiZhi.YIN:
      case DiZhi.SHEN:
      case DiZhi.SI:
        return DiZhiXing.YIN_SI_SHEN;
      case DiZhi.CHOU:
      case DiZhi.XU:
      case DiZhi.WEI:
        return DiZhiXing.CHOU_XU_WEI;
      case DiZhi.WU:
        return DiZhiXing.WU_WU;
      case DiZhi.CHEN:
        return DiZhiXing.CHEN_CHEN;
      case DiZhi.YOU:
        return DiZhiXing.YOU_YOU;
      case DiZhi.HAI:
        return DiZhiXing.HAI_HAI;
      default:
        throw Exception("DiZhiXing value is not valid");
    }
  }

  // 根据给定地支获取其刑伤的地址
  static DiZhi getOtherDiZhi(DiZhi single) {
    if (single == DiZhi.ZI) {
      return DiZhi.MAO;
    } else if (single == DiZhi.MAO) {
      return DiZhi.ZI;
    }
    if (single == DiZhi.YIN) {
      return DiZhi.SI;
    } else if (single == DiZhi.SI) {
      return DiZhi.SHEN;
    } else if (single == DiZhi.SHEN) {
      return DiZhi.YIN;
    }

    if (single == DiZhi.CHOU) {
      return DiZhi.XU;
    } else if (single == DiZhi.XU) {
      return DiZhi.WEI;
    } else if (single == DiZhi.WEI) {
      return DiZhi.CHOU;
    }

    return single;
  }
}

enum DiZhiChong {
  // 地支六冲
  ZI_WU(name: "子午", content: {DiZhi.ZI, DiZhi.WU}),
  MAO_YOU(name: "卯酉", content: {DiZhi.MAO, DiZhi.YOU}),
  YIN_SHEN(name: "寅申", content: {DiZhi.YIN, DiZhi.SHEN}),
  SI_HAI(name: "巳亥", content: {DiZhi.SI, DiZhi.HAI}),
  CHEN_XU(name: "辰戌", content: {DiZhi.CHEN, DiZhi.XU}),
  CHOU_WEI(name: "丑未", content: {DiZhi.CHOU, DiZhi.WEI});

  final String name;
  final Set<DiZhi> content;
  const DiZhiChong({
    required this.name,
    required this.content,
  });
  static DiZhiChong? getFromSingleDiZhi(DiZhi single) {
    return DiZhiChong.values.firstWhere((e) => e.content.contains(single));
  }

  static DiZhi getOtherDiZhi(DiZhi single) {
    DiZhi? res;

    for (var e in getFromSingleDiZhi(single)!.content) {
      if (e != single) {
        res = e;
      }
    }
    return res!;
  }

  static DiZhiChong? getFromValue(String diZhiStr) {
    if (diZhiStr.length != 2) {
      throw Exception("DiZhiChong value is not valid with value:$diZhiStr");
    }
    // 检查是否全部是地支
    Set<String> set = diZhiStr.split("").toSet();
    if (set.length == 1) {
      return DiZhiChong.getFromSingleDiZhi(DiZhi.getFromValue(set.first)!);
    }
    if (!DiZhi.listAll.map((d) => d.value).toSet().containsAll(set)) {
      return throw Exception(
          "DiZhiChong value is not valid with value:$diZhiStr");
    }

    Set<DiZhi> diZhiSet = set.map((e) => DiZhi.getFromValue(e)!).toSet();

    return getFromDiZhi(diZhiSet.first, diZhiSet.last);
  }

  static DiZhiChong? getFromDiZhi(DiZhi diZhi1, DiZhi diZhi2) {
    if (diZhi1 == diZhi2) {
      return null;
    }
    if (DiZhi.fourMuKu.containsAll({diZhi1, diZhi2}) ||
        DiZhi.fourMuKu.containsAll({diZhi1, diZhi2}) ||
        DiZhi.fourYiMa.containsAll({diZhi1, diZhi2})) {
      DiZhiChong? chong = getFromSingleDiZhi(diZhi1);
      if (chong != null && chong.content.contains(diZhi2)) {
        return chong;
      }
      return null;
    }
    return null;
  }
}

enum DiZhiPo {
  // 地支六破
  ZI_YOU(name: "子酉", content: {DiZhi.ZI, DiZhi.YOU}),
  MAO_WU(name: "卯午", content: {DiZhi.MAO, DiZhi.WU}),

  YIN_HAI(name: "寅亥", content: {DiZhi.YIN, DiZhi.HAI}),
  SI_SHEN(name: "巳申", content: {DiZhi.SI, DiZhi.SHEN}),

  WEI_XU(name: "未戌", content: {DiZhi.WEI, DiZhi.XU}),
  CHOU_CHEN(name: "丑辰", content: {DiZhi.CHOU, DiZhi.CHEN});

  final String name;
  final Set<DiZhi> content;
  const DiZhiPo({
    required this.name,
    required this.content,
  });
  static DiZhiPo? getFromSingleDiZhi(DiZhi single) {
    return DiZhiPo.values.firstWhere((e) => e.content.contains(single));
  }

  static DiZhi getOtherDiZhi(DiZhi single) {
    DiZhi? res;

    for (var e in getFromSingleDiZhi(single)!.content) {
      if (e != single) {
        res = e;
      }
    }
    return res!;
  }

  static DiZhiPo? getFromValue(String diZhiStr) {
    if (diZhiStr.length != 2) {
      throw Exception("DiZhiChong value is not valid with value:$diZhiStr");
    }
    // 检查是否全部是地支
    Set<String> set = diZhiStr.split("").toSet();
    if (set.length == 1) {
      return DiZhiPo.getFromSingleDiZhi(DiZhi.getFromValue(set.first)!);
    }
    if (!DiZhi.listAll.map((d) => d.value).toSet().containsAll(set)) {
      return throw Exception(
          "DiZhiChong value is not valid with value:$diZhiStr");
    }

    Set<DiZhi> diZhiSet = set.map((e) => DiZhi.getFromValue(e)!).toSet();

    return getFromDiZhi(diZhiSet.first, diZhiSet.last);
  }

  static DiZhiPo? getFromDiZhi(DiZhi diZhi1, DiZhi diZhi2) {
    if (diZhi1 == diZhi2) {
      return null;
    }
    if (DiZhi.fourMuKu.containsAll({diZhi1, diZhi2}) ||
        DiZhi.fourMuKu.containsAll({diZhi1, diZhi2}) ||
        DiZhi.fourYiMa.containsAll({diZhi1, diZhi2})) {
      DiZhiPo? po = getFromSingleDiZhi(diZhi1);
      if (po != null && po.content.contains(diZhi2)) {
        return po;
      }
    }

    return null;
  }
}

enum DiZhiHai {
  // 地支六害
  ZI_WEI(name: "子未", content: {DiZhi.ZI, DiZhi.WEI}),
  CHOU_WU(name: "丑午", content: {DiZhi.CHOU, DiZhi.WU}),

  YIN_SI(name: "寅巳", content: {DiZhi.YIN, DiZhi.SI}),
  MAO_CHEN(name: "卯辰", content: {DiZhi.MAO, DiZhi.CHEN}),

  SI_HAI(name: "申亥", content: {DiZhi.SI, DiZhi.HAI}),
  YOU_XU(name: "酉戌", content: {DiZhi.YOU, DiZhi.XU});

  final String name;
  final Set<DiZhi> content;
  const DiZhiHai({
    required this.name,
    required this.content,
  });
  static DiZhiHai? getFromSingleDiZhi(DiZhi single) {
    return DiZhiHai.values.firstWhere((e) => e.content.contains(single));
  }

  static DiZhiHai? getFromValue(String diZhiStr) {
    if (diZhiStr.length != 2) {
      throw Exception("DiZhiChong value is not valid with value:$diZhiStr");
    }
    // 检查是否全部是地支
    Set<String> set = diZhiStr.split("").toSet();
    if (set.length == 1) {
      return DiZhiHai.getFromSingleDiZhi(DiZhi.getFromValue(set.first)!);
    }
    if (!DiZhi.listAll.map((d) => d.value).toSet().containsAll(set)) {
      return throw Exception(
          "DiZhiChong value is not valid with value:$diZhiStr");
    }

    Set<DiZhi> diZhiSet = set.map((e) => DiZhi.getFromValue(e)!).toSet();

    return getFromDiZhi(diZhiSet.first, diZhiSet.last);
  }

  static DiZhi getOtherDiZhi(DiZhi single) {
    DiZhi? res;

    for (var e in getFromSingleDiZhi(single)!.content) {
      if (e != single) {
        res = e;
      }
    }
    return res!;
  }

  static DiZhiHai? getFromDiZhi(DiZhi diZhi1, DiZhi diZhi2) {
    if (diZhi1 == diZhi2) {
      return null;
    }
    DiZhiHai? hai = getFromSingleDiZhi(diZhi1);
    if (hai != null && hai.content.contains(diZhi2)) {
      return hai;
    }
    return null;
  }
}

enum DiZhiSanHui {
  // 三会
  HAI_ZI_CHOU(
      name: "亥子丑",
      content: {DiZhi.HAI, DiZhi.ZI, DiZhi.CHOU},
      fiveXing: FiveXing.SHUI),
  YIN_MAO_CHEN(
      name: "寅卯辰",
      content: {DiZhi.YIN, DiZhi.MAO, DiZhi.CHEN},
      fiveXing: FiveXing.MU),
  SI_WU_WEI(
      name: "巳午未",
      content: {DiZhi.SI, DiZhi.WU, DiZhi.WEI},
      fiveXing: FiveXing.HUO),
  SHEN_YOU_XU(
      name: "申酉戌",
      content: {DiZhi.SHEN, DiZhi.YOU, DiZhi.XU},
      fiveXing: FiveXing.JIN);

  final Set<DiZhi> content;
  final String name;
  final FiveXing fiveXing;
  const DiZhiSanHui({
    required this.name,
    required this.content,
    required this.fiveXing,
  });
  static DiZhiSanHui? getBySingleDiZhi(DiZhi) {
    return DiZhiSanHui.values.firstWhere((e) => e.content.contains(DiZhi));
  }

  static DiZhiSanHui? getFromDiZhiStr(String diZhiStr) {
    Set<String> set = diZhiStr.split("").toSet();
    if (set.length != 3) {
      return null;
    }
    // 查看 _set 是否都是地支
    if (!DiZhi.listAll.map((d) => d.value).toSet().containsAll(set)) {
      return null;
    }
    List<DiZhi> diZhiSet = set.map((e) => DiZhi.getFromValue(e)!).toList();

    return getFromDiZhi(diZhiSet[0], diZhiSet[1], diZhiSet[2]);
  }

  static DiZhiSanHui? getFromDiZhi(DiZhi diZhi1, DiZhi diZhi2, DiZhi diZhi3) {
    if (diZhi1 == diZhi2 || diZhi1 == diZhi3 || diZhi2 == diZhi3) {
      return null;
    }
    DiZhiSanHui? sanHe = getBySingleDiZhi(diZhi1);
    if (sanHe == null) {
      return null;
    }

    if (sanHe.content.contains(diZhi2) && sanHe.content.contains(diZhi3)) {
      return sanHe;
    }
    return null;
  }

  static DiZhiSanHui? getByFiveXing(FiveXing fiveXing) {
    return DiZhiSanHui.values.firstWhere((e) => e.fiveXing == fiveXing);
  }
}

enum DiZhiSanHe {
  // 三合
  Water(
      name: "申子辰",
      content: {DiZhi.SHEN, DiZhi.ZI, DiZhi.CHEN},
      fiveXing: FiveXing.SHUI),
  Wood(
      name: "亥卯未",
      content: {DiZhi.HAI, DiZhi.MAO, DiZhi.WEI},
      fiveXing: FiveXing.MU),
  Fire(
      name: "寅午戌",
      content: {DiZhi.YIN, DiZhi.WU, DiZhi.XU},
      fiveXing: FiveXing.HUO),
  Golden(
      name: "巳酉丑",
      content: {DiZhi.SI, DiZhi.YOU, DiZhi.CHOU},
      fiveXing: FiveXing.JIN);

  final Set<DiZhi> content;
  final String name;
  final FiveXing fiveXing;
  const DiZhiSanHe({
    required this.name,
    required this.content,
    required this.fiveXing,
  });
  static DiZhiSanHe? getBySingleDiZhi(DiZhi diZhi) {
    return DiZhiSanHe.values.firstWhere((e) => e.content.contains(diZhi));
  }

  List<DiZhi> getOrderedSeq() {
    switch (this) {
      case Water:
        return [DiZhi.SHEN, DiZhi.ZI, DiZhi.CHEN];
      case Wood:
        return [DiZhi.HAI, DiZhi.MAO, DiZhi.WEI];
      case Fire:
        return [DiZhi.YIN, DiZhi.WU, DiZhi.XU];
      case Golden:
        return [DiZhi.SI, DiZhi.YOU, DiZhi.CHOU];
    }
  }

  List<DiZhi> getReversedSeq() {
    return getOrderedSeq().reversed.toList();
  }

  // 获取 驿马位置
  static DiZhi getHorseBySingleDiZhi(DiZhi diZhi) {
    var res = getBySingleDiZhi(diZhi);
    if (res == Water) {
      return DiZhi.YIN;
    } else if (res == Wood) {
      return DiZhi.SI;
    } else if (res == Fire) {
      return DiZhi.SHEN;
    } else {
      return DiZhi.HAI;
    }
  }

  static DiZhiSanHe? getFromDiZhiStr(String diZhiStr) {
    Set<String> set = diZhiStr.split("").toSet();
    if (set.length != 3) {
      return null;
    }
    // 查看 _set 是否都是地支
    if (!DiZhi.listAll.map((d) => d.value).toSet().containsAll(set)) {
      return null;
    }
    List<DiZhi> diZhiSet = set.map((e) => DiZhi.getFromValue(e)!).toList();

    return getFromDiZhi(diZhiSet[0], diZhiSet[1], diZhiSet[2]);
  }

  static DiZhiSanHe? getFromDiZhi(DiZhi diZhi1, DiZhi diZhi2, DiZhi diZhi3) {
    if (diZhi1 == diZhi2 || diZhi1 == diZhi3 || diZhi2 == diZhi3) {
      return null;
    }
    DiZhiSanHe? sanHe = getBySingleDiZhi(diZhi1);
    if (sanHe == null) {
      return null;
    }

    if (sanHe.content.contains(diZhi2) && sanHe.content.contains(diZhi3)) {
      return sanHe;
    }
    return null;
  }

  static DiZhiSanHe? getByFiveXing(FiveXing fiveXing) {
    return DiZhiSanHe.values.firstWhere((e) => e.fiveXing == fiveXing);
  }
}

enum DiZhiFourZheng {
  // 地支四正
  // 孟仲季
  @JsonValue("孟")
  Meng("孟", "驿马", {DiZhi.YIN, DiZhi.SI, DiZhi.SHEN, DiZhi.HAI}),
  @JsonValue("仲")
  Zhong("仲", "沐浴", {DiZhi.MAO, DiZhi.WU, DiZhi.YOU, DiZhi.ZI}),
  @JsonValue("季")
  Ji("季", "墓库", {DiZhi.CHEN, DiZhi.WEI, DiZhi.XU, DiZhi.HAI});

  final String name;
  final String nickname;
  final Set<DiZhi> diZhiSet;
  const DiZhiFourZheng(this.name, this.nickname, this.diZhiSet);

  static DiZhiFourZheng getBySingleDiZhi(DiZhi diZhi) {
    if (Meng.diZhiSet.contains(diZhi)) {
      return Meng;
    } else if (Zhong.diZhiSet.contains(diZhi)) {
      return Zhong;
    } else {
      return Ji;
    }
  }

  static Set<DiZhi> getOtherDiZhid(DiZhi diZhi) {
    return getBySingleDiZhi(diZhi).diZhiSet.map((d) => d).toSet()
      ..removeWhere((zhi) => zhi == diZhi);
  }
}
