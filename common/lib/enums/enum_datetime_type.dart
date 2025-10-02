import 'package:json_annotation/json_annotation.dart';

enum DateTimeType {
  @JsonValue("solar")
  solar,
  @JsonValue("lunar")
  lunar,
  @JsonValue("ganZhi")
  ganZhi;

  getFromIndex(int index) {
    return DateTimeType.values[index];
  }
}
