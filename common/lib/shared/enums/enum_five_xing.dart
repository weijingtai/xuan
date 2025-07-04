import 'package:json_annotation/json_annotation.dart';

enum FiveXing {
  @JsonValue("金")
  JIN("金"),
  @JsonValue("木")
  MU("木"),
  @JsonValue("水")
  SHUI("水"),
  @JsonValue("火")
  HUO("火"),
  @JsonValue("土")
  TU("土");

  final String value;
  const FiveXing(this.value);

  // 被哪个五行克制
  FiveXing get beiKe {
    switch (this) {
      case FiveXing.JIN:
        return FiveXing.HUO;
      case FiveXing.MU:
        return FiveXing.JIN;
      case FiveXing.SHUI:
        return FiveXing.TU;
      case FiveXing.HUO:
        return FiveXing.SHUI;
      case FiveXing.TU:
        return FiveXing.MU;
    }
  }
}
