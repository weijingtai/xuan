// lib/domain/enums/each_class_zei_ke_type.dart
import 'package:json_annotation/json_annotation.dart';

enum EachClassZeiKeType {
  @JsonValue("贼")
  ZEI("贼"), // "贼" -- "下克上"

  @JsonValue("克")
  KE("克"); // "克" -- "上克下"

  const EachClassZeiKeType(
      this.displayName); // Renamed 'name' to 'displayName' to avoid conflict with enum's inherent 'name' property
  final String displayName;

  /// 根据字符串获取对应的贼克类型
  static EachClassZeiKeType fromString(String name) {
    return EachClassZeiKeType.values
        .firstWhere((element) => element.displayName == name);
  }
}
