// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yun_yun_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EachYuanYunInfo _$EachYuanYunInfoFromJson(Map<String, dynamic> json) =>
    EachYuanYunInfo(
      type: $enumDecode(_$YuanYunTypeEnumMap, json['type']),
      startYear: (json['startYear'] as num).toInt(),
      endYear: (json['endYear'] as num).toInt(),
      version: json['version'] as String? ?? "1",
    );

Map<String, dynamic> _$EachYuanYunInfoToJson(EachYuanYunInfo instance) =>
    <String, dynamic>{
      'type': _$YuanYunTypeEnumMap[instance.type]!,
      'startYear': instance.startYear,
      'endYear': instance.endYear,
      'version': instance.version,
    };

const _$YuanYunTypeEnumMap = {
  YuanYunType.yuan: '元',
  YuanYunType.yun: '运',
};

EachYuanInfo _$EachYuanInfoFromJson(Map<String, dynamic> json) => EachYuanInfo(
      type: $enumDecode(_$YuanYunTypeEnumMap, json['type']),
      name: $enumDecode(_$YuanYunOrderEnumMap, json['name']),
      startYear: (json['startYear'] as num).toInt(),
      endYear: (json['endYear'] as num).toInt(),
      version: json['version'] as String? ?? "1",
    );

Map<String, dynamic> _$EachYuanInfoToJson(EachYuanInfo instance) =>
    <String, dynamic>{
      'type': _$YuanYunTypeEnumMap[instance.type]!,
      'startYear': instance.startYear,
      'endYear': instance.endYear,
      'version': instance.version,
      'name': _$YuanYunOrderEnumMap[instance.name]!,
    };

const _$YuanYunOrderEnumMap = {
  YuanYunOrder.upper: '上元',
  YuanYunOrder.middle: '中元',
  YuanYunOrder.lower: '下元',
};

EachYunInfo _$EachYunInfoFromJson(Map<String, dynamic> json) => EachYunInfo(
      type: $enumDecode(_$YuanYunTypeEnumMap, json['type']),
      name: $enumDecode(_$NineYunEnumMap, json['name']),
      startYear: (json['startYear'] as num).toInt(),
      endYear: (json['endYear'] as num).toInt(),
      version: json['version'] as String? ?? "1",
    );

Map<String, dynamic> _$EachYunInfoToJson(EachYunInfo instance) =>
    <String, dynamic>{
      'type': _$YuanYunTypeEnumMap[instance.type]!,
      'startYear': instance.startYear,
      'endYear': instance.endYear,
      'version': instance.version,
      'name': _$NineYunEnumMap[instance.name]!,
    };

const _$NineYunEnumMap = {
  NineYun.first: '一运',
  NineYun.second: '二运',
  NineYun.third: '三运',
  NineYun.fourth: '四运',
  NineYun.fifth: '五运',
  NineYun.sixth: '六运',
  NineYun.seventh: '七运',
  NineYun.eighth: '八运',
  NineYun.ninth: '九运',
};

ThreeYuanNineYunInfo _$ThreeYuanNineYunInfoFromJson(
        Map<String, dynamic> json) =>
    ThreeYuanNineYunInfo(
      targetYear: (json['targetYear'] as num).toInt(),
      yuanInfo: EachYuanInfo.fromJson(json['yuanInfo'] as Map<String, dynamic>),
      yunInfo: EachYunInfo.fromJson(json['yunInfo'] as Map<String, dynamic>),
      currentCycleStartYear: (json['currentCycleStartYear'] as num).toInt(),
      currentCycleEndYear: (json['currentCycleEndYear'] as num).toInt(),
      version: json['version'] as String? ?? "1",
    );

Map<String, dynamic> _$ThreeYuanNineYunInfoToJson(
        ThreeYuanNineYunInfo instance) =>
    <String, dynamic>{
      'targetYear': instance.targetYear,
      'yuanInfo': instance.yuanInfo,
      'yunInfo': instance.yunInfo,
      'currentCycleStartYear': instance.currentCycleStartYear,
      'currentCycleEndYear': instance.currentCycleEndYear,
      'version': instance.version,
    };
