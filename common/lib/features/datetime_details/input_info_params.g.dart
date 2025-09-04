// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_info_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DateTimeDetailsBundle _$DateTimeDetailsBundleFromJson(
        Map<String, dynamic> json) =>
    DateTimeDetailsBundle(
      calculationConfig: CalculationStrategyConfig.fromJson(
          json['calculationConfig'] as Map<String, dynamic>),
      standeredDatetime: DateTime.parse(json['standeredDatetime'] as String),
      standeredChineseInfo: ChineseDateInfo.fromJson(
          json['standeredChineseInfo'] as Map<String, dynamic>),
      utcDatetime: DateTime.parse(json['utcDatetime'] as String),
      timezoneStr: json['timezoneStr'] as String,
      isDST: json['isDST'] as bool?,
      removeDSTDatetime: json['removeDSTDatetime'] == null
          ? null
          : DateTime.parse(json['removeDSTDatetime'] as String),
      removeDSTChineseInfo: json['removeDSTChineseInfo'] == null
          ? null
          : ChineseDateInfo.fromJson(
              json['removeDSTChineseInfo'] as Map<String, dynamic>),
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      meanSolarDatetime: json['meanSolarDatetime'] == null
          ? null
          : DateTime.parse(json['meanSolarDatetime'] as String),
      meanSolarChineseInfo: json['meanSolarChineseInfo'] == null
          ? null
          : ChineseDateInfo.fromJson(
              json['meanSolarChineseInfo'] as Map<String, dynamic>),
      coordinates: json['coordinates'] == null
          ? null
          : Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      trueSolarDatetime: json['trueSolarDatetime'] == null
          ? null
          : DateTime.parse(json['trueSolarDatetime'] as String),
      trueSolarChineseInfo: json['trueSolarChineseInfo'] == null
          ? null
          : ChineseDateInfo.fromJson(
              json['trueSolarChineseInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DateTimeDetailsBundleToJson(
        DateTimeDetailsBundle instance) =>
    <String, dynamic>{
      'calculationConfig': instance.calculationConfig,
      'standeredDatetime': instance.standeredDatetime.toIso8601String(),
      'standeredChineseInfo': instance.standeredChineseInfo,
      'utcDatetime': instance.utcDatetime.toIso8601String(),
      'timezoneStr': instance.timezoneStr,
      'isDST': instance.isDST,
      'removeDSTDatetime': instance.removeDSTDatetime?.toIso8601String(),
      'removeDSTChineseInfo': instance.removeDSTChineseInfo,
      'location': instance.location,
      'meanSolarDatetime': instance.meanSolarDatetime?.toIso8601String(),
      'meanSolarChineseInfo': instance.meanSolarChineseInfo,
      'coordinates': instance.coordinates,
      'trueSolarDatetime': instance.trueSolarDatetime?.toIso8601String(),
      'trueSolarChineseInfo': instance.trueSolarChineseInfo,
    };
