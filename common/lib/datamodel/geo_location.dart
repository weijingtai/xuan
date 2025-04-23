import 'package:json_annotation/json_annotation.dart';
import 'package:sweph/sweph.dart';
import 'basic_person_info.dart' as my;
part 'geo_location.g.dart';

enum GeoLevel {
  @JsonValue(0)
  country(0),
  @JsonValue(1)
  province(1),
  @JsonValue(2)
  city(2),
  @JsonValue(3)
  county(3);

  final int value;
  const GeoLevel(this.value);
  static GeoLevel fromValue(int value) {
    for (GeoLevel level in GeoLevel.values) {
      if (level.value == value) {
        return level;
      }
    }
    throw ArgumentError('Invalid GeoLevel value: $value');
  }
}

/// 地理位置数据类
@JsonSerializable()
class GeoLocation {
  /// 区域编码
  final String code;

  /// 父级区域编码
  final String parentCode;

  /// 行政级别（1:省, 2:市, 3:县/区）
  final GeoLevel level;

  /// 区域名称
  final String name;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;
  my.Coordinates get coordinates => my.Coordinates(latitude: latitude, longitude: longitude);
  GeoLocation({
    required this.code,
    required this.parentCode,
    required this.level,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() {
    return '$name ($latitude, $longitude)';
  }

  factory GeoLocation.fromJson(Map<String, dynamic> json) =>
      _$GeoLocationFromJson(json);
  Map<String, dynamic> toJson() => _$GeoLocationToJson(this);
}
