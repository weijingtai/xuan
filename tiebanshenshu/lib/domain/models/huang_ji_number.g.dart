// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'huang_ji_number.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HuangJiNumber _$HuangJiNumberFromJson(Map<String, dynamic> json) =>
    HuangJiNumber(
      name: json['name'] as String,
      description: json['description'] as String,
      number: (json['number'] as num).toInt(),
    );

Map<String, dynamic> _$HuangJiNumberToJson(HuangJiNumber instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'number': instance.number,
    };

HuangJiBaseNumber _$HuangJiBaseNumberFromJson(Map<String, dynamic> json) =>
    HuangJiBaseNumber(
      name: json['name'] as String,
      description: json['description'] as String,
      orinialNumber: (json['orinialNumber'] as num).toInt(),
      baseNumberType: $enumDecode(
        _$BaseNumberTypeEnumMap,
        json['baseNumberType'],
      ),
      numberSource: $enumDecode(_$NumberSourceEnumMap, json['numberSource']),
    )..number = (json['number'] as num).toInt();

Map<String, dynamic> _$HuangJiBaseNumberToJson(HuangJiBaseNumber instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'baseNumberType': _$BaseNumberTypeEnumMap[instance.baseNumberType]!,
      'numberSource': _$NumberSourceEnumMap[instance.numberSource]!,
      'orinialNumber': instance.orinialNumber,
      'number': instance.number,
    };

const _$BaseNumberTypeEnumMap = {
  BaseNumberType.basic: '基础',
  BaseNumberType.primary: '主数',
  BaseNumberType.secondary: '次数',
  BaseNumberType.tiaoWen: '条文',
  BaseNumberType.selection: '选择',
};

const _$NumberSourceEnumMap = {
  NumberSource.yuanHui: '元会',
  NumberSource.yunShi: '运世',
  NumberSource.sixQinCorrectKe: '六亲考刻',
};

HuangJiPlacedNumber _$HuangJiPlacedNumberFromJson(Map<String, dynamic> json) =>
    HuangJiPlacedNumber(
      number: (json['number'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      raw: (json['raw'] as num).toInt(),
      place: $enumDecode(_$EnumNumberPlaceEnumMap, json['place']),
      fourZhuName: $enumDecode(_$FourZhuNameEnumMap, json['fourZhuName']),
      ganZhiType: $enumDecode(_$FourZhuGanZhiTypeEnumMap, json['ganZhiType']),
    );

Map<String, dynamic> _$HuangJiPlacedNumberToJson(
  HuangJiPlacedNumber instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'number': instance.number,
  'raw': instance.raw,
  'place': _$EnumNumberPlaceEnumMap[instance.place]!,
  'fourZhuName': _$FourZhuNameEnumMap[instance.fourZhuName]!,
  'ganZhiType': _$FourZhuGanZhiTypeEnumMap[instance.ganZhiType]!,
};

const _$EnumNumberPlaceEnumMap = {
  EnumNumberPlace.Units: '个',
  EnumNumberPlace.Tens: '十',
  EnumNumberPlace.Hundreds: '百',
  EnumNumberPlace.Thousands: '千',
};

const _$FourZhuNameEnumMap = {
  FourZhuName.year: '年柱',
  FourZhuName.month: '月柱',
  FourZhuName.day: '日柱',
  FourZhuName.time: '时柱',
};

const _$FourZhuGanZhiTypeEnumMap = {
  FourZhuGanZhiType.gan: '天干',
  FourZhuGanZhiType.zhi: '地支',
};

HuangJiOperatedNumber _$HuangJiOperatedNumberFromJson(
  Map<String, dynamic> json,
) => HuangJiOperatedNumber(
  name: json['name'] as String,
  description: json['description'] as String,
  scr1: HuangJiNumber.fromJson(json['scr1'] as Map<String, dynamic>),
  scr2: HuangJiNumber.fromJson(json['scr2'] as Map<String, dynamic>),
  operator: $enumDecode(_$EnumHuangJiOperatorEnumMap, json['operator']),
)..number = (json['number'] as num).toInt();

Map<String, dynamic> _$HuangJiOperatedNumberToJson(
  HuangJiOperatedNumber instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'number': instance.number,
  'scr1': instance.scr1,
  'scr2': instance.scr2,
  'operator': _$EnumHuangJiOperatorEnumMap[instance.operator]!,
};

const _$EnumHuangJiOperatorEnumMap = {
  EnumHuangJiOperator.add: 'add',
  EnumHuangJiOperator.merge: 'merge',
};

HuangJiEachPart _$HuangJiEachPartFromJson(Map<String, dynamic> json) =>
    HuangJiEachPart(
      order: (json['order'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      operator: $enumDecode(_$EnumHuangJiOperatorEnumMap, json['operator']),
      huangJiNumber: HuangJiNumber.fromJson(
        json['huangJiNumber'] as Map<String, dynamic>,
      ),
    )..number = (json['number'] as num).toInt();

Map<String, dynamic> _$HuangJiEachPartToJson(HuangJiEachPart instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'number': instance.number,
      'order': instance.order,
      'operator': _$EnumHuangJiOperatorEnumMap[instance.operator]!,
      'huangJiNumber': instance.huangJiNumber,
    };

HuangJiTiaoWenNumber _$HuangJiTiaoWenNumberFromJson(
  Map<String, dynamic> json,
) => HuangJiTiaoWenNumber(
  name: json['name'] as String,
  description: json['description'] as String,
  tiaoWenNumber: (json['tiaoWenNumber'] as num).toInt(),
  huangJiBaseNumber: HuangJiBaseNumber.fromJson(
    json['huangJiBaseNumber'] as Map<String, dynamic>,
  ),
  parts: (json['parts'] as List<dynamic>)
      .map((e) => HuangJiNumber.fromJson(e as Map<String, dynamic>))
      .toList(),
)..number = (json['number'] as num).toInt();

Map<String, dynamic> _$HuangJiTiaoWenNumberToJson(
  HuangJiTiaoWenNumber instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'tiaoWenNumber': instance.tiaoWenNumber,
  'number': instance.number,
  'huangJiBaseNumber': instance.huangJiBaseNumber,
  'parts': instance.parts,
};
