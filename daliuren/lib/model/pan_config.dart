import 'package:common/shared/enums/enum_day_night.dart';
import 'package:json_annotation/json_annotation.dart';

import '../domain/services/calculate_month_general_service.dart';

part 'pan_config.g.dart';

@JsonSerializable()
class PanConfig {
  CalculateMonthGeneralType monthGeneralType;
  DayNightBoundaryType dayNightBoundaryType;
  EnumDayNight? dayNight;
  GuiRenType guiRenType;

  PanConfig(
      {required this.monthGeneralType,
      required this.dayNightBoundaryType,
      required this.guiRenType,
      this.dayNight});
  static PanConfig get defaultConfig => PanConfig(
        monthGeneralType: CalculateMonthGeneralType.middleQi,
        dayNightBoundaryType: DayNightBoundaryType.maoYou,
        guiRenType: GuiRenType.Jia_Wu_Geng_Niu_Yang,
      );

  factory PanConfig.fromJson(Map<String, dynamic> json) =>
      _$PanConfigFromJson(json);
  Map<String, dynamic> toJson() => _$PanConfigToJson(this);
}
