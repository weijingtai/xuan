// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'three_chuan_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreeChuanDataModel _$ThreeChuanDataModelFromJson(Map<String, dynamic> json) =>
    ThreeChuanDataModel(
      first: EachChuanDataModel.fromJson(json['first'] as Map<String, dynamic>),
      second:
          EachChuanDataModel.fromJson(json['second'] as Map<String, dynamic>),
      third: EachChuanDataModel.fromJson(json['third'] as Map<String, dynamic>),
      nineZongMen: $enumDecode(_$NineZongMenEnumMap, json['nineZongMen']),
    );

Map<String, dynamic> _$ThreeChuanDataModelToJson(
        ThreeChuanDataModel instance) =>
    <String, dynamic>{
      'first': instance.first.toJson(),
      'second': instance.second.toJson(),
      'third': instance.third.toJson(),
      'nineZongMen': _$NineZongMenEnumMap[instance.nineZongMen]!,
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
