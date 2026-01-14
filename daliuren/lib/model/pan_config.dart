import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

import '../domain/services/calculate_month_general_service.dart';

part 'pan_config.g.dart';

@JsonSerializable()
class DaLiuRenPanConfig {
  CalculateMonthGeneralType monthGeneralType;
  DayNightBoundaryType dayNightBoundaryType;
  EnumDayNight? dayNight;
  GuiRenType guiRenType;

  DaLiuRenPanConfig(
      {required this.monthGeneralType,
      required this.dayNightBoundaryType,
      required this.guiRenType,
      this.dayNight});
  static DaLiuRenPanConfig get defaultConfig => DaLiuRenPanConfig(
        monthGeneralType: CalculateMonthGeneralType.middleQi,
        dayNightBoundaryType: DayNightBoundaryType.maoYou,
        guiRenType: GuiRenType.Jia_Wu_Geng_Niu_Yang,
      );

  factory DaLiuRenPanConfig.fromJson(Map<String, dynamic> json) =>
      _$DaLiuRenPanConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DaLiuRenPanConfigToJson(this);
}
