import 'package:json_annotation/json_annotation.dart';

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
}
