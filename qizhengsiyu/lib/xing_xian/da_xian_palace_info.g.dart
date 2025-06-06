// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'da_xian_palace_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DaXianPalaceInfo _$DaXianPalaceInfoFromJson(Map<String, dynamic> json) =>
    DaXianPalaceInfo(
      order: (json['order'] as num).toInt(),
      palace: $enumDecode(_$EnumTwelveGongEnumMap, json['palace']),
      durationYears:
          YearMonth.fromJson(json['durationYears'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      startAge: YearMonth.fromJson(json['startAge'] as Map<String, dynamic>),
      endAge: YearMonth.fromJson(json['endAge'] as Map<String, dynamic>),
      rateYearsPerDegree: YearMonth.fromJson(
          json['rateYearsPerDegree'] as Map<String, dynamic>),
      constellationPassages: (json['constellationPassages'] as List<dynamic>)
          .map((e) => DaXianConstellationPassageInfo.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DaXianPalaceInfoToJson(DaXianPalaceInfo instance) =>
    <String, dynamic>{
      'order': instance.order,
      'palace': _$EnumTwelveGongEnumMap[instance.palace]!,
      'durationYears': instance.durationYears,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'startAge': instance.startAge,
      'endAge': instance.endAge,
      'rateYearsPerDegree': instance.rateYearsPerDegree,
      'constellationPassages': instance.constellationPassages,
    };

const _$EnumTwelveGongEnumMap = {
  EnumTwelveGong.Zi: '子',
  EnumTwelveGong.Chou: '丑',
  EnumTwelveGong.Yin: '寅',
  EnumTwelveGong.Mao: '卯',
  EnumTwelveGong.Chen: '辰',
  EnumTwelveGong.Si: '巳',
  EnumTwelveGong.Wu: '午',
  EnumTwelveGong.Wei: '未',
  EnumTwelveGong.Shen: '申',
  EnumTwelveGong.You: '酉',
  EnumTwelveGong.Xu: '戌',
  EnumTwelveGong.Hai: '亥',
};
