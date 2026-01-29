// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tiao_wen_datamodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TiaoWenDataModel _$TiaoWenDataModelFromJson(Map<String, dynamic> json) =>
    TiaoWenDataModel(
      id: (json['id'] as num).toInt(),
      setName: $enumDecode(_$DiZhiEnumMap, json['setName']),
      content1: json['content1'] as String,
      content2: json['content2'] as String?,
      ageSet1: (json['ageSet1'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      ageSet2: (json['ageSet2'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$TiaoWenDataModelToJson(TiaoWenDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'setName': _$DiZhiEnumMap[instance.setName]!,
      'content1': instance.content1,
      'content2': instance.content2,
      'ageSet1': instance.ageSet1,
      'ageSet2': instance.ageSet2,
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
