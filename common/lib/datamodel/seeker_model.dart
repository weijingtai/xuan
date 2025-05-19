import 'package:common/enums/enum_datetime_type.dart';
import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:json_annotation/json_annotation.dart';

import 'location.dart';

part 'seeker_model.g.dart';

@JsonSerializable()
class SeekerModel {
  final String uuid;
  final String? username;
  final String? nickname;
  final Gender gender;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final DateTime? deletedAt;
  final DateTimeType timingType;
  final DateTime birthDatetime;
  final JiaZi yearGanZhi;
  final JiaZi monthGanZhi;
  final JiaZi dayGanZhi;
  final JiaZi timeGanZhi;
  final int lunarMonth;
  final bool isLeapMonth;
  final int lunarDay;
  final String timingInfoUuid;
  final List<DivinationDatetimeModel>? timingInfoList;
  final Location? birthLocation;

  SeekerModel({
    required this.uuid,
    this.username,
    this.nickname,
    required this.gender,
    required this.createdAt,
    this.lastUpdatedAt,
    this.deletedAt,
    required this.timingType,
    required this.birthDatetime,
    required this.yearGanZhi,
    required this.monthGanZhi,
    required this.dayGanZhi,
    required this.timeGanZhi,
    required this.lunarMonth,
    required this.isLeapMonth,
    required this.lunarDay,
    required this.timingInfoUuid,
    this.timingInfoList,
    this.birthLocation,
  });

  factory SeekerModel.fromJson(Map<String, dynamic> json) =>
      _$SeekerModelFromJson(json);

  Map<String, dynamic> toJson() => _$SeekerModelToJson(this);
}
