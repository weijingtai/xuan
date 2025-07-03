// lib/domain/enums/she_hai_type.dart
import 'package:json_annotation/json_annotation.dart';

enum SheHaiType {
  @JsonValue("深浅")
  SHEN_QIAN("深浅"), // 涉害取深浅
  @JsonValue("曲直")
  QU_ZHI("曲直"),  // "曲直"，涉害深浅次数 (This seems to be a name, not a type directly) - keeping as is from original
  @JsonValue("见机")
  JIAN_JI("见机"), // “见机”，涉害深浅相同， 取孟上神
  @JsonValue("察微")
  CHA_WEI("察微"), // "察微"，涉害深浅相同，无孟，取仲上神
  @JsonValue("缀瑕")
  ZHUI_XIA("缀瑕"); // "缀瑕"又名“复等”，涉害相同，且孟仲没有

  const SheHaiType(this.displayName);
  final String displayName;
}
