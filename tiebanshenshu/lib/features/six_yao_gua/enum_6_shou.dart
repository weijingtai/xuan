import 'package:json_annotation/json_annotation.dart';

enum Enum6Shou {
  @JsonValue("青龙")
  qingLong("青龙", 0),
  @JsonValue("朱雀")
  zhuQue("朱雀", 1),
  @JsonValue("勾陈")
  gouChen("勾陈", 2),
  @JsonValue("腾蛇")
  tengShe("腾蛇", 3),
  @JsonValue("白虎")
  baiHu("白虎", 4),
  @JsonValue("玄武")
  xuanWu("玄武", 5);

  final String name;
  final int order;
  const Enum6Shou(this.name, this.order);

  /// 从order获取6经卦
  static Enum6Shou? fromOrder(int order) {
    return Enum6Shou.values.firstWhere(
      (element) => element.order == order,
      orElse: () => Enum6Shou.qingLong,
    );
  }

  static Enum6Shou? fromName(String name) {
    return Enum6Shou.values.firstWhere(
      (element) => element.name == name,
      orElse: () => Enum6Shou.qingLong,
    );
  }
}
