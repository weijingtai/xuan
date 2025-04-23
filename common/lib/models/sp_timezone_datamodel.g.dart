// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sp_timezone_datamodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SPTimezoneDataModel _$SPTimezoneDataModelFromJson(Map<String, dynamic> json) =>
    SPTimezoneDataModel(
      appFeatureModule:
          $enumDecode(_$AppFeatureModuleEnumMap, json['appFeatureModule']),
      timezoneStr: json['timezoneStr'] as String?,
      isAutoHandleDST: json['isAutoHandleDST'] as bool?,
      isDefaultTimezone: json['isDefaultTimezone'] as bool?,
    );

Map<String, dynamic> _$SPTimezoneDataModelToJson(
        SPTimezoneDataModel instance) =>
    <String, dynamic>{
      'appFeatureModule': _$AppFeatureModuleEnumMap[instance.appFeatureModule]!,
      'timezoneStr': instance.timezoneStr,
      'isAutoHandleDST': instance.isAutoHandleDST,
      'isDefaultTimezone': instance.isDefaultTimezone,
    };

const _$AppFeatureModuleEnumMap = {
  AppFeatureModule.Golabel: 'golabel',
  AppFeatureModule.DaLiuRen: 'daliu',
  AppFeatureModule.QiMenDunJia: 'qimen',
  AppFeatureModule.TaiYiShenShu: 'taiyi',
  AppFeatureModule.QiZhengSiYu: '74',
};
