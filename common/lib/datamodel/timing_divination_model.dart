import 'package:common/models/divination_datetime.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_datetime_type.dart';
import '../enums/enum_jia_zi.dart';
import 'datetime_divination_datamodel.dart';
import 'location.dart';

part 'timing_divination_model.g.dart';

@JsonSerializable()
class TimingDivinationModel extends DatatimeDivinationDetailsDataModel {
  final bool isManual;

  TimingDivinationModel({
    required super.uuid,
    required super.createdAt,
    super.lastUpdatedAt,
    super.deletedAt,
    super.divinationUuid,
    required super.timingType,
    required super.datetime,
    required this.isManual,
    required super.yearGanZhi,
    required super.monthGanZhi,
    required super.dayGanZhi,
    required super.timeGanZhi,
    required super.lunarMonth,
    required super.isLeapMonth,
    required super.lunarDay,
    super.timingInfoUuid,
    super.location,
    super.timingInfoListJson,
  });

  factory TimingDivinationModel.fromJson(Map<String, dynamic> json) =>
      _$TimingDivinationModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TimingDivinationModelToJson(this);
}
