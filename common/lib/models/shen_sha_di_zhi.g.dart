// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shen_sha_di_zhi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiZhiShenSha _$DiZhiShenShaFromJson(Map<String, dynamic> json) => DiZhiShenSha(
      json['name'] as String,
      $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      (json['descriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      (json['locationDescriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      (json['locationMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$DiZhiEnumMap, k), $enumDecode(_$DiZhiEnumMap, e)),
      ),
    );

Map<String, dynamic> _$DiZhiShenShaToJson(DiZhiShenSha instance) =>
    <String, dynamic>{
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
      'locationMapper': instance.locationMapper
          .map((k, e) => MapEntry(_$DiZhiEnumMap[k]!, _$DiZhiEnumMap[e]!)),
    };

const _$JiXiongEnumEnumMap = {
  JiXiongEnum.DA_JI: '大吉',
  JiXiongEnum.JI: '吉',
  JiXiongEnum.XIAO_JI: '小吉',
  JiXiongEnum.PING: '平',
  JiXiongEnum.XIAO_XIONG: '小凶',
  JiXiongEnum.XIONG: '凶',
  JiXiongEnum.DA_XIONG: '大凶',
  JiXiongEnum.WEI_ZHI: '未知',
};

const _$DiZhiEnumMap = {
  DiZhi.ZI: '子',
  DiZhi.CHOU: '丑',
  DiZhi.YIN: '寅',
  DiZhi.MAO: '卯',
  DiZhi.CHEN: '辰',
  DiZhi.SI: '巳',
  DiZhi.WU: '午',
  DiZhi.WEI: '未',
  DiZhi.SHEN: '申',
  DiZhi.YOU: '酉',
  DiZhi.XU: '戌',
  DiZhi.HAI: '亥',
};
