import 'package:json_annotation/json_annotation.dart';

enum JiXiongEnum {
  @JsonValue("大吉")
  DA_JI("大吉"),
  @JsonValue("吉")
  JI("吉"),
  @JsonValue("小吉")
  XIAO_JI("小吉"),
  @JsonValue("平")
  PING("平"),
  @JsonValue("小凶")
  XIAO_XIONG("小凶"),
  @JsonValue("凶")
  XIONG("凶"),
  @JsonValue("大凶")
  DA_XIONG("大凶"),
  @JsonValue("未知")
  WEI_ZHI("未知");

  const JiXiongEnum(this.name);
  final String name;

  bool isJi() {
    return this == JiXiongEnum.DA_JI ||
        this == JiXiongEnum.JI ||
        this == JiXiongEnum.XIAO_JI;
  }

  bool isXiong() {
    return this == JiXiongEnum.DA_XIONG ||
        this == JiXiongEnum.XIONG ||
        this == JiXiongEnum.XIAO_XIONG;
  }

  static JiXiongEnum fromName(String jiXiong) {
    for (JiXiongEnum jiXiongEnum in JiXiongEnum.values) {
      if (jiXiongEnum.name == jiXiong) {
        return jiXiongEnum;
      }
    }
    return JiXiongEnum.WEI_ZHI;
  }
}
