import 'package:common/enums/enum_datetime_type.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timing_divination_model.g.dart';

@JsonSerializable()
class TimingDivinationModel {
  final String uuid;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final DateTime? deletedAt;
  final String queryUuid;
  final DateTimeType timingType;
  final DateTime datetime;
  final bool isManual;
  final JiaZi yearGanZhi;
  final JiaZi monthGanZhi;
  final JiaZi dayGanZhi;
  final JiaZi timeGanZhi;
  final int lunarMonth;
  final bool isLeapMonth;
  final int lunarDay;
  final String timingInfoUuid;
  final List<DivinationDatetimeModel>? timingInfoList;

  TimingDivinationModel({
    required this.uuid,
    required this.createdAt,
    this.lastUpdatedAt,
    this.deletedAt,
    required this.queryUuid,
    required this.timingType,
    required this.datetime,
    required this.isManual,
    required this.yearGanZhi,
    required this.monthGanZhi,
    required this.dayGanZhi,
    required this.timeGanZhi,
    required this.lunarMonth,
    required this.isLeapMonth,
    required this.lunarDay,
    required this.timingInfoUuid,
    this.timingInfoList,
  });

  factory TimingDivinationModel.fromJson(Map<String, dynamic> json) =>
      _$TimingDivinationModelFromJson(json);

  Map<String, dynamic> toJson() => _$TimingDivinationModelToJson(this);
}
