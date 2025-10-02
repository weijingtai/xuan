import 'package:json_annotation/json_annotation.dart';

enum EachClassZeiKeType{
  @JsonValue("贼")
  ZEI("贼"), // “贼” -- “下克上”
  @JsonValue("克")
  KE("克"); // “克” -- “上克下”
  const EachClassZeiKeType(this.name);
  final String name;
  static EachClassZeiKeType fromString(String name){
    return EachClassZeiKeType.values.firstWhere((element) => element.name == name);
  }
}