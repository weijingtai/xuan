import 'package:json_annotation/json_annotation.dart';

enum CoordinateSystem {
  /// 黄道坐标系（基于地球公转轨道）
  @JsonValue("黄道制")
  Ecliptic(
    name: '黄道制',
    referencePlane: '黄道面',
  ),

  @JsonValue("赤道制")

  /// 赤道坐标系（基于地球自转轴）
  Equatorial(
    name: '赤道制',
    referencePlane: '赤道面',
  );

  final String name;
  final String referencePlane;

  const CoordinateSystem({
    required this.name,
    required this.referencePlane,
  });
}

///
enum StarInnType {
  @JsonValue("古宿")
  Classical("古宿"),
  @JsonValue("矫正古宿")
  AdjustedClassical("矫正古宿"),
  @JsonValue("今宿")
  Mordern("今宿");

  final String name;
  const StarInnType(this.name);
}

enum StarInnSystem {
  @JsonValue("回归制")
  Tropical("回归制"),
  @JsonValue("恒星制")
  Sidereal("恒星制");

  final String name;
  const StarInnSystem(this.name);
}
