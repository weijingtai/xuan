import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../common_logger.dart';

part 'sp_timezone_datamodel.g.dart';

@JsonSerializable()
class SPTimezoneDataModel extends Equatable {
  static const String SharedPreferencesBaseKey = "TimezoneDataModel";
  AppFeatureModule appFeatureModule;
  String? timezoneStr;
  bool? isAutoHandleDST;
  bool? isDefaultTimezone;
  String get spKey => "${appFeatureModule.spPrefix}$SharedPreferencesBaseKey";
  SPTimezoneDataModel(
      {required this.appFeatureModule,
      required this.timezoneStr,
      required this.isAutoHandleDST,
      required this.isDefaultTimezone});
  factory SPTimezoneDataModel.fromJson(Map<String, dynamic> json) =>
      _$SPTimezoneDataModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SPTimezoneDataModelToJson(this);

  SPTimezoneDataModel copyWith({
    AppFeatureModule? appFeatureModule,
    String? timezoneStr,
    String? lastTimeUsing,
    bool? isAutoHandleDST,
    bool? isDefaultTimezone,
  }) {
    return SPTimezoneDataModel(
      appFeatureModule: appFeatureModule ?? this.appFeatureModule,
      timezoneStr: timezoneStr ?? this.timezoneStr,
      isAutoHandleDST: isAutoHandleDST ?? this.isAutoHandleDST,
      isDefaultTimezone: isDefaultTimezone ?? this.isDefaultTimezone,
    );
  }

  // toString
  @override
  String toString() {
    return 'SPTimezoneDataModel(appFeatureModule: $appFeatureModule, timezoneStr: $timezoneStr, isAutoHandleDST: $isAutoHandleDST, isDefaultTimezone: $isDefaultTimezone)';
  }

  @override
  List<Object?> get props => [
        appFeatureModule,
        timezoneStr,
        isAutoHandleDST,
        isDefaultTimezone,
      ];
}
