// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chinese_date_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChineseDateInfo _$ChineseDateInfoFromJson(Map<String, dynamic> json) =>
    ChineseDateInfo(
      eightChars:
          EightChars.fromJson(json['eightChars'] as Map<String, dynamic>),
      phenology: Phenology.fromJson(json['phenology'] as Map<String, dynamic>),
      lunarMonth: (json['lunarMonth'] as num).toInt(),
      lunarDay: (json['lunarDay'] as num).toInt(),
      isLeapMonth: json['isLeapMonth'] as bool,
      jieQiInfo: JieQiInfo.fromJson(json['jieQiInfo'] as Map<String, dynamic>),
      threeYuan: $enumDecode(_$YuanYunOrderEnumMap, json['threeYuan']),
      nineYun: $enumDecode(_$NineYunEnumMap, json['nineYun']),
    );

Map<String, dynamic> _$ChineseDateInfoToJson(ChineseDateInfo instance) =>
    <String, dynamic>{
      'eightChars': instance.eightChars,
      'phenology': instance.phenology,
      'jieQiInfo': instance.jieQiInfo,
      'threeYuan': _$YuanYunOrderEnumMap[instance.threeYuan]!,
      'nineYun': _$NineYunEnumMap[instance.nineYun]!,
      'lunarMonth': instance.lunarMonth,
      'lunarDay': instance.lunarDay,
      'isLeapMonth': instance.isLeapMonth,
    };

const _$YuanYunOrderEnumMap = {
  YuanYunOrder.upper: '上元',
  YuanYunOrder.middle: '中元',
  YuanYunOrder.lower: '下元',
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
