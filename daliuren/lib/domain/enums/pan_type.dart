import 'package:json_annotation/json_annotation.dart';

enum PanType {
  @JsonValue("伏吟")
  fuYin("伏吟"), // 伏吟
  @JsonValue("退连茹")
  tui_lianRu("退连茹"), // 退连茹
  @JsonValue("退间传")
  tui_jianChua("退间传"), // 退间传
  @JsonValue("病胎")
  bingTai("病胎"), // 病胎
  @JsonValue("逆三合")
  ni_sanHe("逆三合"), // 逆三合
  @JsonValue("四绝")
  siJue("四绝"), // 四绝
  @JsonValue("反吟")
  fanYin("反吟"), // 反吟
  @JsonValue("四目覆生")
  siMuFuSheng("四目覆生"), // 四目覆生
  @JsonValue("顺三合")
  shun_sanHe("顺三合"), // 顺三合
  @JsonValue("生胎")
  shengTai("生胎"), // 生胎
  @JsonValue("顺间传")
  shun_jianChuan("顺间传"), // 顺间传
  @JsonValue("罗网")
  luoWang("罗网"); // 罗网

  final String name;
  const PanType(this.name);
}
