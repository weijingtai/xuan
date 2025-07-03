// lib/domain/enums/nine_zong_men.dart
import 'package:json_annotation/json_annotation.dart';

// 九宗门
enum NineZongMen {
  @JsonValue("贼克")
  ZEI_KE, // 贼克法
  @JsonValue("比用")
  BI_YONG, // 比用法
  @JsonValue("涉害")
  SHE_HAI, // 涉害法
  @JsonValue("遥克")
  YAO_KE, // 遥克法
  @JsonValue("昴星")
  MAO_XING, // 昴星法
  @JsonValue("别责")
  BIE_ZE, // 别责法
  @JsonValue("八专")
  BA_ZHUAN, // 八专法
  @JsonValue("伏吟")
  FU_YIN, // 伏吟法
  @JsonValue("返吟")
  FAN_YIN, // 返吟法
  @JsonValue("未知")
  UNKNOWN,
}
