import 'package:json_annotation/json_annotation.dart';

import 'enum_di_zhi.dart';
import 'enum_five_xing.dart';

enum XianTianGua {
  @JsonValue("乾")
  Qian(1, "乾", "南"),
  @JsonValue("兑")
  Dui(2, "兑", "东南"),
  @JsonValue("离")
  Li(3, "离", "东"),
  @JsonValue("震")
  Zhen(4, "震", "东北"),
  @JsonValue("巽")
  Xun(5, "巽", "东南"),
  @JsonValue("坎")
  Kan(6, "坎", "西"),
  @JsonValue("艮")
  Gen(7, "艮", "西北"),
  @JsonValue("坤")
  Kun(8, "坤", "北");

  final int order;
  final String name;
  final String direction;
  const XianTianGua(this.order, this.name, this.direction);
}

enum Enum8Gua {
  @JsonValue("乾")
  Qian("乾", "天", "111"),
  @JsonValue("兑")
  Dui("兑", "泽", "110"),
  @JsonValue("离")
  Li("离", "火", "101"),
  @JsonValue("震")
  Zhen("震", "雷", "100"),
  @JsonValue("巽")
  Xun("巽", "风", "011"),
  @JsonValue("坎")
  Kan("坎", "水", "010"),
  @JsonValue("艮")
  Gen("艮", "山", "001"),
  @JsonValue("坤")
  Kun("坤", "地", "000");

  final String name;
  final String nickname;
  final String bottomTopBinaryStr;
  String get topBottomBinaryStr => bottomTopBinaryStr.split('').reversed.join();
  String get value => name;
  const Enum8Gua(this.name, this.nickname, this.bottomTopBinaryStr);

  /// 转换为先天八卦
  XianTianGua toXianTianGua() {
    return XianTianGua.values.firstWhere((e) => e.name == name);
  }

  /// 转换为后天八卦
  HouTianGua toHouTianGua() {
    return HouTianGua.values.firstWhere((e) => e.name == name);
  }

  Enum8Gua getByNickname(String nickname) {
    return Enum8Gua.values.firstWhere((e) => e.nickname == nickname);
  }

  /// 从字符串值获取枚举
  static Enum8Gua fromValue(String value) {
    return Enum8Gua.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('无法找到对应的八卦: $value'),
    );
  }

  /// 从二进制字符串获取枚举
  static Enum8Gua fromBottomTopBinaryStr(String value) {
    return Enum8Gua.values.firstWhere(
      (e) => e.bottomTopBinaryStr == value,
      orElse: () => throw ArgumentError('无法找到对应的八卦: $value'),
    );
  }

  /// 从顶部到底部的二进制字符串获取枚举
  static Enum8Gua fromTopBottomBinaryStr(String value) {
    return Enum8Gua.values.firstWhere(
      (e) => e.topBottomBinaryStr == value,
      orElse: () => throw ArgumentError('无法找到对应的八卦: $value'),
    );
  }
}

enum HouTianGua {
  @JsonValue("坎")
  Kan(1, "坎", FiveXing.SHUI, DiZhi.ZI, null),
  @JsonValue("坤")
  Kun(2, "坤", FiveXing.TU, DiZhi.WEI, DiZhi.SHEN),
  @JsonValue("震")
  Zhen(3, "震", FiveXing.MU, DiZhi.MAO, null),
  @JsonValue("巽")
  Xun(4, "巽", FiveXing.MU, DiZhi.CHEN, DiZhi.SI),

  @JsonValue("中")
  Center(5, "中", FiveXing.TU, DiZhi.XU, DiZhi.XU),

  @JsonValue("乾")
  Qian(6, "乾", FiveXing.JIN, DiZhi.XU, DiZhi.HAI),
  @JsonValue("兑")
  Dui(7, "兑", FiveXing.JIN, DiZhi.YOU, null),
  @JsonValue("艮")
  Gen(8, "艮", FiveXing.TU, DiZhi.CHOU, DiZhi.YIN),
  @JsonValue("离")
  Li(9, "离", FiveXing.HUO, DiZhi.WU, null);

  final String name;
  final int houTianOrder;
  final FiveXing fiveXing;
  final DiZhi diZhi1;
  final DiZhi? diZhi2;
  const HouTianGua(
      this.houTianOrder, this.name, this.fiveXing, this.diZhi1, this.diZhi2);
  bool get isZheng => diZhi2 == null;
  bool get isYu => diZhi2 != null;

  // 全部为从下到上 排列顺序
  String get binaryStr {
    switch (this) {
      case Kan:
        return "010";
      case Gen:
        return "001";
      case Zhen:
        return "100";
      case Xun:
        return "011";
      case Li:
        return "101";
      case Dui:
        return "110";
      case Qian:
        return "111";
      default:
        return "000";
    }
  }

  bool isDuiChongWithOther(HouTianGua other) =>
      checkDuiChong(this, other) ?? false;
  bool isSameGong(HouTianGua gong) => gong.houTianOrder == houTianOrder;

  static HouTianGua getGuaByBinaryStr(String binaryStr) {
    switch (binaryStr) {
      case "010":
        return Kan;
      case "001":
        return Gen;
      case "100":
        return Zhen;
      case "011":
        return Xun;
      case "101":
        return Li;
      case "110":
        return Dui;
      case "111":
        return Qian;
      default:
        return Kun;
    }
  }

  // 根据后天宫数获取卦
  static HouTianGua getGua(int num) =>
      HouTianGua.values.firstWhere((element) => element.houTianOrder == num);

  // 根据后天宫名称获取卦
  static HouTianGua getGuaByName(String name) =>
      HouTianGua.values.firstWhere((element) => element.name == name);
  static HouTianGua getGuaByNickname(String nickname) {
    switch (nickname) {
      case "水":
        return Kan;
      case "雷":
        return Zhen;
      case "风":
        return Xun;
      case "天":
        return Qian;
      case "泽":
        return Dui;
      case "山":
        return Gen;
      case "火":
        return Li;
        defaule:
        return Kun;
    }
    return Kun;
  }

  /// 两宫是否为对冲宫位
  /// 返回空表明参数有误，两个宫是同一个宫
  static bool? checkDuiChong(HouTianGua g1, HouTianGua g2) {
    Set<int> allGongNumber = {g1.houTianOrder, g2.houTianOrder};
    if (allGongNumber.length != 2) {
      return null;
    }
    if ({1, 9}.containsAll(allGongNumber)) {
      // 坎离对冲
      return true;
    } else if ({2, 8}.containsAll(allGongNumber)) {
      return true;
    } else if ({3, 7}.containsAll(allGongNumber)) {
      return true;
    } else if ({4, 6}.containsAll(allGongNumber)) {
      return true;
    } else {
      // 其余情况 不是。
      return false;
    }
  }
}
