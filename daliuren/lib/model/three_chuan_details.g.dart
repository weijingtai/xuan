// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'three_chuan_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreeChuanBiYong _$ThreeChuanBiYongFromJson(Map<String, dynamic> json) =>
    ThreeChuanBiYong(
      first: EachChuan.fromJson(json['first'] as Map<String, dynamic>),
      second: EachChuan.fromJson(json['second'] as Map<String, dynamic>),
      third: EachChuan.fromJson(json['third'] as Map<String, dynamic>),
    )..nineZongMen = $enumDecode(_$NineZongMenEnumMap, json['nineZongMen']);

Map<String, dynamic> _$ThreeChuanBiYongToJson(ThreeChuanBiYong instance) =>
    <String, dynamic>{
      'nineZongMen': _$NineZongMenEnumMap[instance.nineZongMen]!,
      'first': instance.first.toJson(),
      'second': instance.second.toJson(),
      'third': instance.third.toJson(),
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
  NineZongMen.FAN_YIN: '返吟',
  NineZongMen.UNKNOWN: '未知',
};

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
      'first': instance.first.toJson(),
      'second': instance.second.toJson(),
      'third': instance.third.toJson(),
      'type': _$SheHaiTypeEnumMap[instance.type]!,
    };

const _$SheHaiTypeEnumMap = {
  SheHaiType.SHEN_QIAN: '深浅',
  SheHaiType.QU_ZHI: '曲直',
  SheHaiType.JIAN_JI: '见机',
  SheHaiType.CHA_WEI: '察微',
  SheHaiType.ZHUI_XIA: '缀瑕',
};

ThreeChuanYaoKe _$ThreeChuanYaoKeFromJson(Map<String, dynamic> json) =>
    ThreeChuanYaoKe(
      type: $enumDecodeNullable(_$YaoKeTypeEnumMap, json['type']),
      first: EachChuan.fromJson(json['first'] as Map<String, dynamic>),
      second: EachChuan.fromJson(json['second'] as Map<String, dynamic>),
      third: EachChuan.fromJson(json['third'] as Map<String, dynamic>),
      isBiYong: json['isBiYong'] as bool?,
      sheHaiType: $enumDecodeNullable(_$SheHaiTypeEnumMap, json['sheHaiType']),
    )..nineZongMen = $enumDecode(_$NineZongMenEnumMap, json['nineZongMen']);

Map<String, dynamic> _$ThreeChuanYaoKeToJson(ThreeChuanYaoKe instance) =>
    <String, dynamic>{
      'nineZongMen': _$NineZongMenEnumMap[instance.nineZongMen]!,
      'first': instance.first.toJson(),
      'second': instance.second.toJson(),
      'third': instance.third.toJson(),
      if (_$YaoKeTypeEnumMap[instance.type] case final value?) 'type': value,
      if (instance.isBiYong case final value?) 'isBiYong': value,
      if (_$SheHaiTypeEnumMap[instance.sheHaiType] case final value?)
        'sheHaiType': value,
    };

const _$YaoKeTypeEnumMap = {
  YaoKeType.GAO_SHI_KE: '蒿失课',
  YaoKeType.TAN_SHE_KE: '弹射课',
};

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
      'first': instance.first.toJson(),
      'second': instance.second.toJson(),
      'third': instance.third.toJson(),
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
