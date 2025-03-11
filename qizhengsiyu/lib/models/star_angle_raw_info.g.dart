// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'star_angle_raw_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StarAngleRawInfo _$StarAngleRawInfoFromJson(Map<String, dynamic> json) =>
    StarAngleRawInfo(
      starInnSystem: $enumDecode(_$StarInnSystemEnumMap, json['starInnSystem']),
      coordinateSystem:
          $enumDecode(_$CoordinateSystemEnumMap, json['coordinateSystem']),
      angle: (json['angle'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
    );

Map<String, dynamic> _$StarAngleRawInfoToJson(StarAngleRawInfo instance) =>
    <String, dynamic>{
      'starInnSystem': _$StarInnSystemEnumMap[instance.starInnSystem]!,
      'coordinateSystem': _$CoordinateSystemEnumMap[instance.coordinateSystem]!,
      'angle': instance.angle,
      'speed': instance.speed,
    };

const _$StarInnSystemEnumMap = {
  StarInnSystem.Tropical: '回归制',
  StarInnSystem.Sidereal: '恒星制',
};

const _$CoordinateSystemEnumMap = {
  CoordinateSystem.Ecliptic: '黄道制',
  CoordinateSystem.Equatorial: '赤道制',
};
