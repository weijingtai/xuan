// lib/domain/enums/zei_ke_type.dart
import 'package:json_annotation/json_annotation.dart';

enum ZeiKeType {
  @JsonValue("始入课")
  SHI_RU_KE("始入课"), // 有且仅有一组下贼上
  @JsonValue("元首课")
  YUAN_SHOU_KE("元首课"), // 只有一组上克下
  @JsonValue("重申课")
  CHONG_SHEN_KE("重申课"); // 有多组克，但只有一组贼

  const ZeiKeType(this.displayName);
  final String displayName;
}
