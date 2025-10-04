import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

import 'enum_five_xing.dart';
import 'enum_yin_yang.dart';

enum EnumStars {
  @JsonValue("日")
  Sun("太阳", "日", FiveXing.HUO, YinYang.YANG, true), // 太阳
  @JsonValue("月")
  Moon("太阴", "月", FiveXing.SHUI, YinYang.YIN, false), // 太阴
  @JsonValue("水")
  Mercury("辰星", "水", FiveXing.SHUI, YinYang.YIN, true), // 水
  @JsonValue("火")
  Mars("荧惑", "火", FiveXing.HUO, YinYang.YANG, false), // 火
  @JsonValue("土")
  Saturn("镇星", "土", FiveXing.TU, YinYang.YIN, true), // 土
  @JsonValue("金")
  Venus("太白", "金", FiveXing.JIN, YinYang.YIN, false), // 金
  @JsonValue("木")
  Jupiter("岁星", "木", FiveXing.MU, YinYang.YANG, true), // 木
  @JsonValue("炁")
  Qi("紫炁", "炁", FiveXing.MU, YinYang.YANG, true),
  @JsonValue("罗")
  Luo("罗睺", "罗", FiveXing.HUO, YinYang.YANG, false),
  @JsonValue("计")
  Ji("计都", "计", FiveXing.TU, YinYang.YIN, true),
  @JsonValue("孛")
  Bei("月孛", "孛", FiveXing.SHUI, YinYang.YIN, false);

  final String starName;
  final String singleName;
  final FiveXing fiveXing;
  final bool isDayOrNight; // true is day; false is night
  final YinYang yiYang;

  const EnumStars(this.starName, this.singleName, this.fiveXing, this.yiYang,
      this.isDayOrNight);

  bool get isFiveStar => [Mercury, Mars, Saturn, Venus, Jupiter].contains(this);
  bool get isYuNu => [Qi, Luo, Ji, Bei].contains(this);
  static List<EnumStars> get sevenZhengStars =>
      [Sun, Moon, Mercury, Mars, Saturn, Venus, Jupiter];
  static List<EnumStars> get fiveStars =>
      [Mercury, Mars, Saturn, Venus, Jupiter];
  static List<EnumStars> get allStars =>
      [Sun, Moon, Mercury, Mars, Saturn, Venus, Jupiter, Luo, Ji, Qi, Bei];

  EnumStars? get yu {
    switch (this) {
      case Mars:
        return Luo;
      case Mercury:
        return Bei;
      case Jupiter:
        return Qi;
      case Saturn:
        return Ji;
      default:
        return null;
    }
  }

  EnumStars? get zheng {
    switch (this) {
      case Luo:
        return Mars;
      case Bei:
        return Mercury;
      case Qi:
        return Jupiter;
      case Ji:
        return Saturn;
      default:
        return null;
    }
  }

  static EnumStars? getByName(String name) {
    if (name == "太阳") {
      return Sun;
    } else if (["月亮", "太阴"].contains(name)) {
      return Moon;
    } else if (name == "水星") {
      return Mercury;
    } else if (name == "火星") {
      return Mars;
    } else if (name == "土星") {
      return Saturn;
    } else if (name == "金星") {
      return Venus;
    } else if (name == "木星") {
      return Jupiter;
    } else if (["紫炁", "紫气"].contains(name)) {
      return Qi;
    } else if (["罗睺", "天首"].contains(name)) {
      return Luo;
    } else if (["计都", "天尾"].contains(name)) {
      return Ji;
    } else if (["月孛", "攙抢"].contains(name)) {
      return Bei;
    } else {
      return null;
    }
  }

  static EnumStars? getBySingleName(String singleName) {
    if (["阳", "日"].contains(singleName)) {
      return Sun;
    } else if (["月", "阴"].contains(singleName)) {
      return Moon;
    } else if (singleName == "水") {
      return Mercury;
    } else if (singleName == "火") {
      return Mars;
    } else if (singleName == "土") {
      return Saturn;
    } else if (singleName == "金") {
      return Venus;
    } else if (singleName == "木") {
      return Jupiter;
    } else if (["炁", "气"].contains(singleName)) {
      return Qi;
    } else if ("罗" == singleName) {
      return Luo;
    } else if ("计" == singleName) {
      return Ji;
    } else if ("孛" == singleName) {
      return Bei;
    } else {
      return null;
    }
  }
}

enum EnumStarsPriority implements Comparable<EnumStarsPriority> {
  Primary(4),
  Secondary(3),
  Normal(2),
  Lowest(1);

  final int number;
  const EnumStarsPriority(this.number);

  @override
  int compareTo(EnumStarsPriority other) {
    return other.number.compareTo(number);
  }
}
