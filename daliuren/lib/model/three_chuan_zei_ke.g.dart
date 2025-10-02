// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'three_chuan_zei_ke.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreeChuanZeiKe _$ThreeChuanZeiKeFromJson(Map<String, dynamic> json) =>
    ThreeChuanZeiKe(
      type: $enumDecode(_$ZeiKeTypeEnumMap, json['type']),
      zeiKeType: $enumDecode(_$EachClassZeiKeTypeEnumMap, json['zeiKeType']),
      first: EachChuan.fromJson(json['first'] as Map<String, dynamic>),
      second: EachChuan.fromJson(json['second'] as Map<String, dynamic>),
      third: EachChuan.fromJson(json['third'] as Map<String, dynamic>),
    )..nineZongMen = $enumDecode(_$NineZongMenEnumMap, json['nineZongMen']);

Map<String, dynamic> _$ThreeChuanZeiKeToJson(ThreeChuanZeiKe instance) =>
    <String, dynamic>{
      'nineZongMen': _$NineZongMenEnumMap[instance.nineZongMen]!,
      'first': instance.first,
      'second': instance.second,
      'third': instance.third,
      'type': _$ZeiKeTypeEnumMap[instance.type]!,
      'zeiKeType': _$EachClassZeiKeTypeEnumMap[instance.zeiKeType]!,
    };

const _$ZeiKeTypeEnumMap = {
  ZeiKeType.SHI_RU_KE: '始入课',
  ZeiKeType.YUAN_SHOU_KE: '元首课',
  ZeiKeType.CHONG_SHEN_KE: '重申课',
};

const _$EachClassZeiKeTypeEnumMap = {
  EachClassZeiKeType.ZEI: '贼',
  EachClassZeiKeType.KE: '克',
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
