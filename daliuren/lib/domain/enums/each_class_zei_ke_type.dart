// lib/domain/enums/each_class_zei_ke_type.dart
import 'package:json_annotation/json_annotation.dart';

enum EachClassZeiKeType {
  @JsonValue("贼")
  ZEI("贼"), // “贼” -- “下克上”

  @JsonValue("克")
  KE("克"); // “克” -- “上克下”

  const EachClassZeiKeType(this.displayName); // Renamed 'name' to 'displayName' to avoid conflict with enum's inherent 'name' property
  final String displayName;

  // The fromString factory might not be necessary if json_serializable handles it via @JsonValue.
  // If needed for other purposes, it can be kept.
  // static EachClassZeiKeType fromString(String name) {
  //   return EachClassZeiKeType.values.firstWhere((element) => element.displayName == name);
  // }
}
