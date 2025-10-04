import 'package:json_annotation/json_annotation.dart';

enum EnumDayNight {
  @JsonValue("昼")
  day("昼"),
  @JsonValue("夜")
  night("夜");

  final String name;

  bool get isDay => this == day;
  bool get isNight => this == night;

  const EnumDayNight(this.name);
}
