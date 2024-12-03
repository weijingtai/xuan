
import 'package:json_annotation/json_annotation.dart';

enum EnumThreeYuan{
  @JsonValue("无")
  NONE("无"), // 阴遁无三元
  @JsonValue("上元")
  START("上元"), // 上元
  @JsonValue("中元")
  MIDDLE("中元"), // 中元
  @JsonValue("下元")
  END("下元");  // 下元
  final String name;
  const EnumThreeYuan(this.name);
}