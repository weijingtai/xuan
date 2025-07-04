import 'package:json_annotation/json_annotation.dart';

enum EnumPanelType {
  @JsonValue("single")
  single("单例"),
  @JsonValue("marriage")
  marriage("合婚"),
  @JsonValue("collaboration")
  collaboration("合盘"),
  @JsonValue("coopredict")
  coopredict("同参"),
  @JsonValue("verify")
  verify("校验");

  final String name;
  const EnumPanelType(this.name);
}
