import 'package:json_annotation/json_annotation.dart';

enum EnumQueryType {
  @JsonValue("命运")

  /// 命理运势
  destiny,

  @JsonValue("占测")

  /// 占卜事情
  divination,
}
