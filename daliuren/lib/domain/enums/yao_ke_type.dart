// lib/domain/enums/yao_ke_type.dart
import 'package:json_annotation/json_annotation.dart';

enum YaoKeType {
  @JsonValue("蒿失课")
  GAO_SHI_KE("蒿失课"),
  @JsonValue("弹射课")
  TAN_SHE_KE("弹射课");

  const YaoKeType(this.displayName);
  final String displayName;
}
