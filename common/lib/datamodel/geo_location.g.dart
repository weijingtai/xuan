// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoLocation _$GeoLocationFromJson(Map<String, dynamic> json) => GeoLocation(
      code: json['code'] as String,
      parentCode: json['parentCode'] as String,
      level: $enumDecode(_$GeoLevelEnumMap, json['level']),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$GeoLocationToJson(GeoLocation instance) =>
    <String, dynamic>{
      'code': instance.code,
      'parentCode': instance.parentCode,
      'level': _$GeoLevelEnumMap[instance.level]!,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

const _$GeoLevelEnumMap = {
  GeoLevel.country: 0,
  GeoLevel.province: 1,
  GeoLevel.city: 2,
  GeoLevel.county: 3,
};
