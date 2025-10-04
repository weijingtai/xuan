// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observer_datamodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObserverDataModel _$ObserverDataModelFromJson(Map<String, dynamic> json) =>
    ObserverDataModel(
      timezoneStr: json['timezoneStr'] as String,
      type: $enumDecode(_$EnumDatetimeTypeEnumMap, json['type']),
      coordinate: json['coordinate'] == null
          ? null
          : Coordinates.fromJson(json['coordinate'] as Map<String, dynamic>),
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      hourAdjusted: (json['hourAdjusted'] as num?)?.toInt(),
      isManualCalibration: json['isManualCalibration'] as bool? ?? false,
    );

Map<String, dynamic> _$ObserverDataModelToJson(ObserverDataModel instance) =>
    <String, dynamic>{
      'coordinate': instance.coordinate,
      'location': instance.location,
      'timezoneStr': instance.timezoneStr,
      'type': _$EnumDatetimeTypeEnumMap[instance.type]!,
      'hourAdjusted': instance.hourAdjusted,
      'isManualCalibration': instance.isManualCalibration,
    };

const _$EnumDatetimeTypeEnumMap = {
  EnumDatetimeType.standard: '标准时间',
  EnumDatetimeType.removeDST: '移除夏令时',
  EnumDatetimeType.meanSolar: '平太阳时',
  EnumDatetimeType.trueSolar: '真太阳时',
};
