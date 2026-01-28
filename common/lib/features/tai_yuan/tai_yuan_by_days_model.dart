import 'package:json_annotation/json_annotation.dart';

import '../../enums.dart';
import '../../models/eight_chars.dart';
import '../../models/jie_qi_info.dart';
import 'enum_calculate_strategy.dart';
import 'tai_yuan_model.dart';

part 'tai_yuan_by_days_model.g.dart';

@JsonSerializable()
class TaiYuanByDaysModel extends TaiYuanModel {
  final int actualMatureDays;
  int get taiYuanBeforeDays => actualMatureDays; // 胎元是生日的前多少天
  TaiYuanByDaysModel({
    required this.actualMatureDays,
    required super.taiYuanGanZhi,
    required super.taiYuanBeforeMonth,
    required super.calculateStrategy,
    super.totalMatureMonth = 0,
    super.isTestTubeBaby = false,
    super.adjustedTaiYuan,
    super.conceptionDateTime,
    super.ganZhi,
    // super.lunar,
    super.lunarMonth,
    super.lunarDay,
    super.jieQiInfo,
  });

  factory TaiYuanByDaysModel.fromJson(Map<String, dynamic> json) =>
      _$TaiYuanByDaysModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaiYuanByDaysModelToJson(this);

  @override
  List<Object?> get props => [
        actualMatureDays,
        taiYuanGanZhi,
        adjustedTaiYuan,
      ];
}
