// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sp_location_datamodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SPLocationDataModel _$SPLocationDataModelFromJson(Map<String, dynamic> json) =>
    SPLocationDataModel(
      appFeatureModule:
          $enumDecode(_$AppFeatureModuleEnumMap, json['appFeatureModule']),
      isRemembered: json['isRemembered'] as bool,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SPLocationDataModelToJson(
        SPLocationDataModel instance) =>
    <String, dynamic>{
      'appFeatureModule': _$AppFeatureModuleEnumMap[instance.appFeatureModule]!,
      'isRemembered': instance.isRemembered,
      'location': instance.location,
    };

const _$AppFeatureModuleEnumMap = {
  AppFeatureModule.Golabel: 'golabel',
  AppFeatureModule.DaLiuRen: 'daliu',
  AppFeatureModule.QiMenDunJia: 'qimen',
  AppFeatureModule.TaiYiShenShu: 'taiyi',
  AppFeatureModule.QiZhengSiYu: '74',
};

SPMyLocationDataModel _$SPMyLocationDataModelFromJson(
        Map<String, dynamic> json) =>
    SPMyLocationDataModel(
      appFeatureModule:
          $enumDecode(_$AppFeatureModuleEnumMap, json['appFeatureModule']),
      isDefault: json['isDefault'] as bool,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SPMyLocationDataModelToJson(
        SPMyLocationDataModel instance) =>
    <String, dynamic>{
      'appFeatureModule': _$AppFeatureModuleEnumMap[instance.appFeatureModule]!,
      'isDefault': instance.isDefault,
      'location': instance.location,
    };
