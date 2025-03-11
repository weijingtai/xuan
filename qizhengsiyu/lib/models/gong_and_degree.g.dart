// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gong_and_degree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GongAndDegree _$GongAndDegreeFromJson(Map<String, dynamic> json) =>
    GongAndDegree(
      $enumDecode(_$EnumTwelveGongEnumMap, json['gong']),
      (json['degree'] as num).toDouble(),
    );

Map<String, dynamic> _$GongAndDegreeToJson(GongAndDegree instance) =>
    <String, dynamic>{
      'gong': _$EnumTwelveGongEnumMap[instance.gong]!,
      'degree': instance.degree,
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
