import 'package:json_annotation/json_annotation.dart';

enum NineZongMen{
  /// 九宗门
  @JsonValue("贼克")
  ZEI_KE("贼克"), // 贼克

  @JsonValue("比用")
  BI_YONG("比用"), // 比用

  @JsonValue("涉害")
  SHE_HAI("涉害"), // 涉害

  @JsonValue("遥克")
  YAO_KE("遥克"), // 遥克

  @JsonValue("昴星")
  MAO_XING("昴星"), // 昴星

   @JsonValue("别责")
  BIE_ZE("别责"), // 别责

  @JsonValue("八专")
  BA_ZHUAN("八专"), // 八专

  @JsonValue("伏吟")
  FU_YIN("伏吟"), // 伏吟

  @JsonValue("反吟")
  FAN_YIN("反吟"); // 反吟

  final String name;
  const NineZongMen(this.name);

}