// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_person_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BirthTime _$BirthTimeFromJson(Map<String, dynamic> json) => BirthTime(
      type: $enumDecode(_$DateTimeTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isLeapMonth: json['isLeapMonth'] as bool,
    );

Map<String, dynamic> _$BirthTimeToJson(BirthTime instance) => <String, dynamic>{
      'type': _$DateTimeTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'isLeapMonth': instance.isLeapMonth,
    };

const _$DateTimeTypeEnumMap = {
  DateTimeType.solar: 'solar',
  DateTimeType.lunar: 'lunar',
};

Coordinates _$CoordinatesFromJson(Map<String, dynamic> json) => Coordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$CoordinatesToJson(Coordinates instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      province: GeoLocation.fromJson(json['province'] as Map<String, dynamic>),
      city: GeoLocation.fromJson(json['city'] as Map<String, dynamic>),
      timezone: json['timezone'] as String,
      area: json['area'] == null
          ? null
          : GeoLocation.fromJson(json['area'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'province': instance.province,
      'city': instance.city,
      'area': instance.area,
      'timezone': instance.timezone,
    };

BasicPersonInfo _$BasicPersonInfoFromJson(Map<String, dynamic> json) =>
    BasicPersonInfo(
      name: json['name'] as String?,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      birthTime: DateTime.parse(json['birthTime'] as String),
      birthLocation:
          Location.fromJson(json['birthLocation'] as Map<String, dynamic>),
      trueSolarTime: DateTime.parse(json['trueSolarTime'] as String),
      bazi: EightChars.fromJson(json['bazi'] as Map<String, dynamic>),
      hasDaylightSaving: json['hasDaylightSaving'] as bool,
      isTrueSolarTime: json['isTrueSolarTime'] as bool,
    );

Map<String, dynamic> _$BasicPersonInfoToJson(BasicPersonInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'gender': _$GenderEnumMap[instance.gender]!,
      'birthTime': instance.birthTime.toIso8601String(),
      'birthLocation': instance.birthLocation,
      'trueSolarTime': instance.trueSolarTime.toIso8601String(),
      'bazi': instance.bazi,
      'hasDaylightSaving': instance.hasDaylightSaving,
      'isTrueSolarTime': instance.isTrueSolarTime,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.unknown: 'unknown',
};
