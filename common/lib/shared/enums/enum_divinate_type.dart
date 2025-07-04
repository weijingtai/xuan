import 'package:json_annotation/json_annotation.dart';

enum EnumDivinateType {
  @JsonValue("timing")
  timing("时间起卦"),
  @JsonValue("random")
  random("随机起卦"),
  @JsonValue("number")
  number("数字起卦"),
  @JsonValue("manual")
  manual("手动起卦"),
  @JsonValue("characters")
  characters("测字"),
  @JsonValue("sentence")
  sentence("语句起卦");

  final String name;
  const EnumDivinateType(this.name);
}
