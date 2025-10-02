import 'package:json_annotation/json_annotation.dart';

enum ZeiKeType{
  @JsonValue("始入课")
  SHI_RU_KE("始入课"), // 有且仅有一组下贼上
  @JsonValue("元首课")
  YUAN_SHOU_KE("元首课"), // 只有一组上克下
  @JsonValue("重申课")
  CHONG_SHEN_KE("重申课"); // 有多组克，但只有一组贼
  final String name;
  const ZeiKeType(this.name);
}

enum SheHaiType{
  @JsonValue("深浅")
  SHEN_QIAN, // 深浅
  @JsonValue("曲直")
  QU_ZHI,  // "曲直"，涉害深浅次数。
  @JsonValue("见机")
  JIAN_JI, // “见机”，涉害深浅相同， 取孟上神
  @JsonValue("察微")
  CHA_WEI, // "察微"，涉害深浅相同，无孟，取仲上神
  @JsonValue("缀瑕")
  ZHUI_XIA, // "缀瑕"又名“复等”，涉害相同，且孟仲没有
}

enum YaoKeType{
  @JsonValue("蒿失课")
  GAO_SHI_KE("蒿失课"),
  @JsonValue("弹射课")
  TAN_SHE_KE("弹射课");
  final String name;
  const YaoKeType(this.name);
}
