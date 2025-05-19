import 'package:common/datamodel/location.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../common_logger.dart';

part 'sp_location_datamodel.g.dart';

@JsonSerializable()
class SPLocationDataModel extends Equatable {
  static const String SharedPreferencesBaseKey = "LocationDataModel";
  AppFeatureModule appFeatureModule;
  bool isRemembered;
  Location? location;

  String get spKey => "${appFeatureModule.spPrefix}$SharedPreferencesBaseKey";
  SPLocationDataModel(
      {required this.appFeatureModule,
      required this.isRemembered,
      required this.location});

  factory SPLocationDataModel.fromJson(Map<String, dynamic> json) =>
      _$SPLocationDataModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SPLocationDataModelToJson(this);

  @override
  List<Object?> get props => [appFeatureModule, location, isRemembered];
  SPLocationDataModel copyWith({
    AppFeatureModule? appFeatureModule,
    Location? location,
    bool? isRemembered,
  }) {
    return SPLocationDataModel(
      appFeatureModule: appFeatureModule ?? this.appFeatureModule,
      location: location ?? this.location,
      isRemembered: isRemembered ?? this.isRemembered,
    );
  }
}

@JsonSerializable()
class SPMyLocationDataModel extends Equatable {
  static const String SharedPreferencesBaseKey = "MyLocationDataModel";
  AppFeatureModule appFeatureModule;
  bool isDefault;
  Location? location;

  String get spKey => "${appFeatureModule.spPrefix}$SharedPreferencesBaseKey";
  SPMyLocationDataModel(
      {required this.appFeatureModule,
      required this.isDefault,
      required this.location});

  factory SPMyLocationDataModel.fromJson(Map<String, dynamic> json) =>
      _$SPMyLocationDataModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SPMyLocationDataModelToJson(this);

  @override
  List<Object?> get props => [appFeatureModule, location, isDefault];
  SPMyLocationDataModel copyWith({
    AppFeatureModule? appFeatureModule,
    Location? location,
    bool? isDefault,
  }) {
    return SPMyLocationDataModel(
      appFeatureModule: appFeatureModule ?? this.appFeatureModule,
      location: location ?? this.location,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
