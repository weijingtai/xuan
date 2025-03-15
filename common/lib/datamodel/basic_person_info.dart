import 'package:common/enums/enum_datetime_type.dart';
import 'package:common/enums/enum_gender.dart';
import 'package:json_annotation/json_annotation.dart';

import '../models/eight_chars.dart';
import 'geo_location.dart';

part 'basic_person_info.g.dart';

@JsonSerializable()
class BirthTime {
  DateTimeType type;
  DateTime timestamp;
  bool isLeapMonth;

  BirthTime({
    required this.type,
    required this.timestamp,
    required this.isLeapMonth,
  });

  factory BirthTime.fromJson(Map<String, dynamic> json) =>
      _$BirthTimeFromJson(json);
  Map<String, dynamic> toJson() => _$BirthTimeToJson(this);
}

@JsonSerializable()
class Coordinates {
  double latitude;
  double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);
  Map<String, dynamic> toJson() => _$CoordinatesToJson(this);
}

@JsonSerializable()
class Location {
  GeoLocation province;
  GeoLocation city;
  GeoLocation? area;
  // String country;
  // String province;
  // String city;
  GeoLocation get lowestGeoLocation => area ?? city;
  Coordinates get coordinates => area == null
      ? Coordinates(
          latitude: city.latitude,
          longitude: city.longitude,
        )
      : Coordinates(
          latitude: area!.latitude,
          longitude: area!.longitude,
        );

  String timezone;

  Location({
    required this.province,
    required this.city,
    required this.timezone,
    this.area,
  });

  // 写一个copyWith方法，用于修改某些属性
  Location copyWith({
    GeoLocation? province,
    GeoLocation? city,
    GeoLocation? area,
    String? timezone,
  }) {
    return Location(
      province: province ?? this.province,
      city: city ?? this.city,
      area: area ?? this.area,
      timezone: timezone ?? this.timezone,
    );
  }

  static Location get defualtLocation {
    return Location(
      province: GeoLocation(
          name: '北京市',
          latitude: 39.9042,
          longitude: 116.4074,
          level: GeoLevel.province,
          code: '110000',
          parentCode: "0"),
      city: GeoLocation(
        name: '北京市',
        latitude: 39.9042,
        longitude: 116.4074,
        code: '110100',
        parentCode: "110000",
        level: GeoLevel.city,
      ),
      timezone: 'Asia/Shanghai',
    );
  }

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class BasicPersonInfo {
  // ------ 基础信息 ------
  String? name; // 用户姓名（可选）
  Gender gender; // 性别（用于部分流年推运）

  // ------ 出生时间与地点 ------
  // BirthTime birthTime;
  DateTime birthTime;
  Location birthLocation;

  // ------ 计算衍生数据 ------
  DateTime trueSolarTime; // 真太阳时（通过经纬度计算）
  EightChars bazi;

  /// 是否有夏令时
  bool hasDaylightSaving;

  /// 是否是真太阳时
  bool isTrueSolarTime;

  // TODO: 阴历生日

  BasicPersonInfo(
      {this.name,
      required this.gender,
      required this.birthTime,
      required this.birthLocation,
      required this.trueSolarTime,
      required this.bazi,
      required this.hasDaylightSaving,
      required this.isTrueSolarTime});

  factory BasicPersonInfo.fromJson(Map<String, dynamic> json) =>
      _$BasicPersonInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BasicPersonInfoToJson(this);
}
