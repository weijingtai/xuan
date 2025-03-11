import 'package:json_annotation/json_annotation.dart';

enum DateTimeType {
  @JsonValue("solar")
  solar,
  @JsonValue("lunar")
  lunar
}
