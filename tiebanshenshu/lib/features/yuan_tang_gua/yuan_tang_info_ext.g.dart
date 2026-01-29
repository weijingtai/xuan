// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yuan_tang_info_ext.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TianDiGuaData _$TianDiGuaDataFromJson(Map<String, dynamic> json) =>
    TianDiGuaData(
      ganNumList: (json['ganNumList'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      zhiNumList: (json['zhiNumList'] as List<dynamic>)
          .map(
            (e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
          )
          .toList(),
      oddNumTotal: (json['oddNumTotal'] as num).toInt(),
      evenNumTotal: (json['evenNumTotal'] as num).toInt(),
      tianGuaNum: (json['tianGuaNum'] as num).toInt(),
      diGuaNum: (json['diGuaNum'] as num).toInt(),
      tianGua: $enumDecode(_$Enum8GuaEnumMap, json['tianGua']),
      diGua: $enumDecode(_$Enum8GuaEnumMap, json['diGua']),
      usedThreeYuanWuGong: json['usedThreeYuanWuGong'] as bool,
    );

Map<String, dynamic> _$TianDiGuaDataToJson(TianDiGuaData instance) =>
    <String, dynamic>{
      'ganNumList': instance.ganNumList,
      'zhiNumList': instance.zhiNumList,
      'oddNumTotal': instance.oddNumTotal,
      'evenNumTotal': instance.evenNumTotal,
      'tianGuaNum': instance.tianGuaNum,
      'diGuaNum': instance.diGuaNum,
      'tianGua': _$Enum8GuaEnumMap[instance.tianGua]!,
      'diGua': _$Enum8GuaEnumMap[instance.diGua]!,
      'usedThreeYuanWuGong': instance.usedThreeYuanWuGong,
    };

const _$Enum8GuaEnumMap = {
  Enum8Gua.Qian: '乾',
  Enum8Gua.Dui: '兑',
  Enum8Gua.Li: '离',
  Enum8Gua.Zhen: '震',
  Enum8Gua.Xun: '巽',
  Enum8Gua.Kan: '坎',
  Enum8Gua.Gen: '艮',
  Enum8Gua.Kun: '坤',
};

TiaowenNumbers _$TiaowenNumbersFromJson(Map<String, dynamic> json) =>
    TiaowenNumbers(
      jiazeXiantian: (json['jiazeXiantian'] as num).toInt(),
      jiazeHoutian: (json['jiazeHoutian'] as num).toInt(),
      najiaTaixuanXiantian: (json['najiaTaixuanXiantian'] as num).toInt(),
      najiaTaixuanHoutian: (json['najiaTaixuanHoutian'] as num).toInt(),
      benhuXiantian: (json['benhuXiantian'] as num).toInt(),
      benhuHoutian: (json['benhuHoutian'] as num).toInt(),
      guahuListXiantian: (json['guahuListXiantian'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      guahuListHoutian: (json['guahuListHoutian'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$TiaowenNumbersToJson(TiaowenNumbers instance) =>
    <String, dynamic>{
      'jiazeXiantian': instance.jiazeXiantian,
      'jiazeHoutian': instance.jiazeHoutian,
      'najiaTaixuanXiantian': instance.najiaTaixuanXiantian,
      'najiaTaixuanHoutian': instance.najiaTaixuanHoutian,
      'benhuXiantian': instance.benhuXiantian,
      'benhuHoutian': instance.benhuHoutian,
      'guahuListXiantian': instance.guahuListXiantian,
      'guahuListHoutian': instance.guahuListHoutian,
    };
