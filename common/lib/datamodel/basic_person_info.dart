import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_datetime_type.dart';
import '../enums/enum_gender.dart';
import '../models/eight_chars.dart';
import 'geo_location.dart';
import 'location.dart';

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
class BasicPersonInfo {
  // ------ 基础信息 ------
  String? name; // 用户姓名（可选）
  Gender gender; // 性别（用于部分流年推运）

  // ------ 出生时间与地点 ------
  // BirthTime birthTime;
  DateTime birthTime;
  Address birthLocation;

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
