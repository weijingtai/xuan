import 'package:json_annotation/json_annotation.dart';

enum YinYang {
  @JsonValue("阳")
  YANG("阳", "1"),
  @JsonValue("阴")
  YIN("阴", "0");

  bool get isYang => this == YinYang.YANG;
  bool get isYin => this == YinYang.YIN;

  final String binaryStr;
  final String value;
  const YinYang(
    this.value,
    this.binaryStr,
  );
  String get name => value;

  static YinYang getByBinaryStr(String value) {
    return value == "1" ? YinYang.YANG : YinYang.YIN;
  }
}
