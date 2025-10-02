import 'package:common/enums/enum_datetime_type.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'location.dart';

part 'base_divination_datetime_datamodel.g.dart';

@JsonSerializable()
class BaseDivinationDatetimeDataModel extends Equatable {
  final String uuid;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final DateTime? deletedAt;
  final DateTimeType timingType;
  final DateTime datetime;
  final JiaZi yearGanZhi;
  final JiaZi monthGanZhi;
  final JiaZi dayGanZhi;
  final JiaZi timeGanZhi;
  final int lunarMonth;
  final bool isLeapMonth;
  final int lunarDay;
  final String? timingInfoUuid;
  final Location? location;
  final List<DivinationDatetimeModel>? timingInfoListJson;
  final String? divinationUuid;

  BaseDivinationDatetimeDataModel({
    required this.uuid,
    required this.createdAt,
    this.lastUpdatedAt,
    this.deletedAt,
    required this.timingType,
    required this.datetime,
    required this.yearGanZhi,
    required this.monthGanZhi,
    required this.dayGanZhi,
    required this.timeGanZhi,
    required this.lunarMonth,
    required this.isLeapMonth,
    required this.lunarDay,
    this.timingInfoUuid,
    this.divinationUuid,
    this.location,
    this.timingInfoListJson,
  });

  factory BaseDivinationDatetimeDataModel.fromJson(Map<String, dynamic> json) =>
      _$BaseDivinationDatetimeDataModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$BaseDivinationDatetimeDataModelToJson(this);

  @override
  List<Object?> get props => [
        uuid,
        createdAt,
        lastUpdatedAt,
        deletedAt,
        timingType,
        datetime,
        yearGanZhi,
        monthGanZhi,
        dayGanZhi,
        timeGanZhi,
        lunarMonth,
        isLeapMonth,
        lunarDay,
        timingInfoUuid,
        divinationUuid,
        location,
      ];
}
