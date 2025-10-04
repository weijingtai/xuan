import 'package:json_annotation/json_annotation.dart';

import 'enum_di_zhi.dart';

enum FourSeasons {
  @JsonValue("春")
  SPRING(0, "春"),
  @JsonValue("夏")
  SUMMER(1, "夏"),
  @JsonValue("秋")
  AUTUMN(2, "秋"),
  @JsonValue("冬")
  WINTER(3, "冬"),
  @JsonValue("土")
  EARTH(4, "土");

  final int order;
  final String name;
  const FourSeasons(this.order, this.name);

  // get by name
  static FourSeasons fromName(String name) {
    return values.firstWhere((e) => e.name == name);
  }

  static FourSeasons getFourSeason(DiZhi monthDiZhi) {
    switch (monthDiZhi) {
      case DiZhi.ZI:
      case DiZhi.HAI:
        return FourSeasons.WINTER;
      case DiZhi.YIN:
      case DiZhi.MAO:
        return FourSeasons.SPRING;
      case DiZhi.WU:
      case DiZhi.WEI:
        return FourSeasons.SUMMER;
      case DiZhi.SHEN:
      case DiZhi.YOU:
        return FourSeasons.AUTUMN;
      default:
        return FourSeasons.EARTH;
    }
  }
}
