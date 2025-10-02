// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'three_chuan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreeChuan _$ThreeChuanFromJson(Map<String, dynamic> json) => ThreeChuan(
      nineZongMen: $enumDecode(_$NineZongMenEnumMap, json['nineZongMen']),
      first: EachChuan.fromJson(json['first'] as Map<String, dynamic>),
      second: EachChuan.fromJson(json['second'] as Map<String, dynamic>),
      third: EachChuan.fromJson(json['third'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ThreeChuanToJson(ThreeChuan instance) =>
    <String, dynamic>{
      'nineZongMen': _$NineZongMenEnumMap[instance.nineZongMen]!,
      'first': instance.first,
      'second': instance.second,
      'third': instance.third,
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
