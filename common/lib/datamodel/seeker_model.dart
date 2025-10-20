import 'package:common/models/divination_datetime.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:common/enums.dart';
import 'datetime_divination_datamodel.dart';
import 'location.dart';

part 'seeker_model.g.dart';

@JsonSerializable()
class SeekerModel extends DatatimeDivinationDetailsDataModel {
  final String? username;
  final String? nickname;
  final Gender gender;
  // final Location? birthLocation;

  SeekerModel({
    required super.uuid,
    required super.createdAt,
    super.lastUpdatedAt,
    super.deletedAt,
    super.location,
    super.divinationUuid,
    required super.timingType,
    required super.datetime,
    required super.yearGanZhi,
    required super.monthGanZhi,
    required super.dayGanZhi,
    required super.timeGanZhi,
    required super.lunarMonth,
    required super.isLeapMonth,
    required super.lunarDay,
    super.timingInfoUuid,
    super.timingInfoListJson,
    this.username,
    this.nickname,
    required this.gender,
  });

  factory SeekerModel.fromJson(Map<String, dynamic> json) =>
      _$SeekerModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SeekerModelToJson(this);
}
