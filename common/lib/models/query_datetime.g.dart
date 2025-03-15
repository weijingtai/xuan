// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_datetime.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueryDateTime _$QueryDateTimeFromJson(Map<String, dynamic> json) =>
    QueryDateTime(
      type: $enumDecode(_$EnumDatetimeTypeEnumMap, json['type']),
      datetime: DateTime.parse(json['datetime'] as String),
      bazi: EightChars.fromJson(json['bazi'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QueryDateTimeToJson(QueryDateTime instance) =>
    <String, dynamic>{
      'type': _$EnumDatetimeTypeEnumMap[instance.type]!,
      'datetime': instance.datetime.toIso8601String(),
      'bazi': instance.bazi,
    };

const _$EnumDatetimeTypeEnumMap = {
  EnumDatetimeType.standard: '阳历',
  EnumDatetimeType.meanSolar: '平太阳时',
  EnumDatetimeType.trueSolar: '真太阳时',
};

NormalQueryDateTime _$NormalQueryDateTimeFromJson(Map<String, dynamic> json) =>
    NormalQueryDateTime(
      datetime: DateTime.parse(json['datetime'] as String),
      bazi: EightChars.fromJson(json['bazi'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NormalQueryDateTimeToJson(
        NormalQueryDateTime instance) =>
    <String, dynamic>{
      'datetime': instance.datetime.toIso8601String(),
      'bazi': instance.bazi,
    };

TZNormalQueryDateTime _$TZNormalQueryDateTimeFromJson(
        Map<String, dynamic> json) =>
    TZNormalQueryDateTime(
      timezoneName: json['timezoneName'] as String,
      datetime: DateTime.parse(json['datetime'] as String),
      bazi: EightChars.fromJson(json['bazi'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TZNormalQueryDateTimeToJson(
        TZNormalQueryDateTime instance) =>
    <String, dynamic>{
      'datetime': instance.datetime.toIso8601String(),
      'bazi': instance.bazi,
      'timezoneName': instance.timezoneName,
    };

MeanSolarQueryDateTime _$MeanSolarQueryDateTimeFromJson(
        Map<String, dynamic> json) =>
    MeanSolarQueryDateTime(
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      datetime: DateTime.parse(json['datetime'] as String),
      bazi: EightChars.fromJson(json['bazi'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MeanSolarQueryDateTimeToJson(
        MeanSolarQueryDateTime instance) =>
    <String, dynamic>{
      'datetime': instance.datetime.toIso8601String(),
      'bazi': instance.bazi,
      'location': instance.location,
    };

TrueSolarQueryDateTime _$TrueSolarQueryDateTimeFromJson(
        Map<String, dynamic> json) =>
    TrueSolarQueryDateTime(
      coordinates:
          Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      datetime: DateTime.parse(json['datetime'] as String),
      bazi: EightChars.fromJson(json['bazi'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TrueSolarQueryDateTimeToJson(
        TrueSolarQueryDateTime instance) =>
    <String, dynamic>{
      'datetime': instance.datetime.toIso8601String(),
      'bazi': instance.bazi,
      'coordinates': instance.coordinates,
    };
