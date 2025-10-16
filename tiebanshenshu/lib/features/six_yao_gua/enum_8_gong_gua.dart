import 'package:json_annotation/json_annotation.dart';

/// 八宫卦的八序枚举
/// 顺序与 `gongGuaName` 一致：
/// [本卦, 一世, 二世, 三世, 四世, 五世, 游魂, 归魂]
enum Enum8GongGuaName {
  @JsonValue("本卦")
  BenGua(0, "本卦"),

  @JsonValue("一世")
  YiShi(1, "一世"),

  @JsonValue("二世")
  ErShi(2, "二世"),

  @JsonValue("三世")
  SanShi(3, "三世"),

  @JsonValue("四世")
  SiShi(4, "四世"),

  @JsonValue("五世")
  WuShi(5, "五世"),

  @JsonValue("游魂")
  YouHun(6, "游魂"),

  @JsonValue("归魂")
  GuiHun(7, "归魂");

  final int order;
  final String name;
  const Enum8GongGuaName(this.order, this.name);

  String get value => name;

  /// 按顺序索引获取枚举（0~7）
  static Enum8GongGuaName getByOrder(int order) {
    return Enum8GongGuaName.values.firstWhere(
      (e) => e.order == order,
      orElse: () => throw ArgumentError('无效的八序索引: $order'),
    );
  }

  /// 按名称获取枚举（"本卦"、"一世"、...）
  static Enum8GongGuaName getByName(String name) {
    return Enum8GongGuaName.values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('无效的八序名称: $name'),
    );
  }
}
