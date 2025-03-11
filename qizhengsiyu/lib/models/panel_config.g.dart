// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PanelConfig _$PanelConfigFromJson(Map<String, dynamic> json) => PanelConfig(
      queryType: $enumDecode(_$EnumQueryTypeEnumMap, json['queryType']),
      coordinateSystem:
          $enumDecode(_$CoordinateSystemEnumMap, json['coordinateSystem']),
      starInnSystem: $enumDecode(_$StarInnSystemEnumMap, json['starInnSystem']),
      starInnType: $enumDecode(_$StarInnTypeEnumMap, json['starInnType']),
      schoolType: $enumDecode(_$EnumSchoolTypeEnumMap, json['schoolType']),
      settleLifeType:
          $enumDecode(_$EnumSettleLifeTypeEnumMap, json['settleLifeType']),
      settleBodyType:
          $enumDecode(_$EnumSettleBodyTypeEnumMap, json['settleBodyType']),
      withAscendant: json['withAscendant'] as bool,
      huaYaoType: $enumDecode(_$EnumHuaYaoTypeEnumMap, json['huaYaoType']),
      panelRingOrder: (json['panelRingOrder'] as List<dynamic>)
          .map((e) => $enumDecode(_$EnumPanelRingEnumMap, e))
          .toList(),
      classicBooks: (json['classicBooks'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PanelConfigToJson(PanelConfig instance) =>
    <String, dynamic>{
      'queryType': _$EnumQueryTypeEnumMap[instance.queryType]!,
      'coordinateSystem': _$CoordinateSystemEnumMap[instance.coordinateSystem]!,
      'starInnSystem': _$StarInnSystemEnumMap[instance.starInnSystem]!,
      'starInnType': _$StarInnTypeEnumMap[instance.starInnType]!,
      'schoolType': _$EnumSchoolTypeEnumMap[instance.schoolType]!,
      'settleLifeType': _$EnumSettleLifeTypeEnumMap[instance.settleLifeType]!,
      'settleBodyType': _$EnumSettleBodyTypeEnumMap[instance.settleBodyType]!,
      'classicBooks': instance.classicBooks,
      'withAscendant': instance.withAscendant,
      'huaYaoType': _$EnumHuaYaoTypeEnumMap[instance.huaYaoType]!,
      'panelRingOrder': instance.panelRingOrder
          .map((e) => _$EnumPanelRingEnumMap[e]!)
          .toList(),
    };

const _$EnumQueryTypeEnumMap = {
  EnumQueryType.destiny: '命运',
  EnumQueryType.divination: '占测',
};

const _$CoordinateSystemEnumMap = {
  CoordinateSystem.Ecliptic: '黄道制',
  CoordinateSystem.Equatorial: '赤道制',
};

const _$StarInnSystemEnumMap = {
  StarInnSystem.Tropical: '回归制',
  StarInnSystem.Sidereal: '恒星制',
};

const _$StarInnTypeEnumMap = {
  StarInnType.Classical: '古宿',
  StarInnType.AdjustedClassical: '矫正古宿',
  StarInnType.Mordern: '今宿',
};

const _$EnumSchoolTypeEnumMap = {
  EnumSchoolType.GuoLao: '果老派',
  EnumSchoolType.TianGuan: '天官派',
  EnumSchoolType.QinTang: '琴堂派',
  EnumSchoolType.Customerized: '自定义',
};

const _$EnumSettleLifeTypeEnumMap = {
  EnumSettleLifeType.Mao: 'byMao',
  EnumSettleLifeType.YinMaoChen: 'byYinMaoChen',
  EnumSettleLifeType.Mannual: 'byMannual',
  EnumSettleLifeType.Ascendant: 'byAscendant',
};

const _$EnumSettleBodyTypeEnumMap = {
  EnumSettleBodyType.TiaYin: 'byTaiYin',
  EnumSettleBodyType.You: 'byYou',
};

const _$EnumHuaYaoTypeEnumMap = {
  EnumHuaYaoType.GuoLao: 'GuoLao',
  EnumHuaYaoType.TianGuan: 'TianGuan',
  EnumHuaYaoType.Both: 'Both',
};

const _$EnumPanelRingEnumMap = {
  EnumPanelRing.PersonInfo: '命主',
  EnumPanelRing.DiZhi12Gong: '地支',
  EnumPanelRing.TwelveGong: '十二宫',
  EnumPanelRing.DestinyGong: '命理宫',
  EnumPanelRing.BasicTrack: '本命星轨',
  EnumPanelRing.FateTrack: '流年星轨',
  EnumPanelRing.StarInn: '星宿环',
  EnumPanelRing.BasicShenSha: '本命神煞',
  EnumPanelRing.FateShenSha: '流年',
};
