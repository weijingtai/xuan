// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'three_chuan_she_hai.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreeChuanSheHai _$ThreeChuanSheHaiFromJson(Map<String, dynamic> json) =>
    ThreeChuanSheHai(
      type: $enumDecode(_$SheHaiTypeEnumMap, json['type']),
      first: EachChuan.fromJson(json['first'] as Map<String, dynamic>),
      second: EachChuan.fromJson(json['second'] as Map<String, dynamic>),
      third: EachChuan.fromJson(json['third'] as Map<String, dynamic>),
    )..nineZongMen = $enumDecode(_$NineZongMenEnumMap, json['nineZongMen']);

Map<String, dynamic> _$ThreeChuanSheHaiToJson(ThreeChuanSheHai instance) =>
    <String, dynamic>{
      'nineZongMen': _$NineZongMenEnumMap[instance.nineZongMen]!,
      'first': instance.first,
      'second': instance.second,
      'third': instance.third,
      'type': _$SheHaiTypeEnumMap[instance.type]!,
    };

const _$SheHaiTypeEnumMap = {
  SheHaiType.SHEN_QIAN: '深浅',
  SheHaiType.QU_ZHI: '曲直',
  SheHaiType.JIAN_JI: '见机',
  SheHaiType.CHA_WEI: '察微',
  SheHaiType.ZHUI_XIA: '缀瑕',
};

const _$NineZongMenEnumMap = {
  NineZongMen.ZEI_KE: '贼克',
  NineZongMen.BI_YONG: '比用',
  NineZongMen.SHE_HAI: '涉害',
  NineZongMen.YAO_KE: '遥克',
  NineZongMen.MAO_XING: '昴星',
  NineZongMen.BIE_ZE: '别责',
  NineZongMen.BA_ZHUAN: '八专',
  NineZongMen.FU_YIN: '伏吟',
  NineZongMen.FAN_YIN: '反吟',
};
