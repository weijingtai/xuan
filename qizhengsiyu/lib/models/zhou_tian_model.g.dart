// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zhou_tian_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZhouTianModel _$ZhouTianModelFromJson(Map<String, dynamic> json) =>
    ZhouTianModel(
      systemType:
          $enumDecode(_$CelestialCoordinateSystemEnumMap, json['systemType']),
      constellationSystemType: $enumDecode(
          _$ConstellationSystemTypeEnumMap, json['constellationSystemType']),
      panelSystemType:
          $enumDecode(_$PanelSystemTypeEnumMap, json['panelSystemType']),
      epochCorrection: json['epochCorrection'] as String,
      totalDegree: (json['totalDegree'] as num).toDouble(),
      gongDegreeSeq: (json['gongDegreeSeq'] as List<dynamic>)
          .map((e) => GongDegree.fromJson(e as Map<String, dynamic>))
          .toList(),
      starInnDegreeSeq: (json['starInnDegreeSeq'] as List<dynamic>)
          .map((e) => ConstellationDegree.fromJson(e as Map<String, dynamic>))
          .toList(),
      alignmentPointAtConstellation: ConstellationDegree.fromJson(
          json['alignmentPointAtConstellation'] as Map<String, dynamic>),
      alignmentPointAtGong: GongDegree.fromJson(
          json['alignmentPointAtGong'] as Map<String, dynamic>),
      zeroPointJieQi:
          $enumDecode(_$TwentyFourJieQiEnumMap, json['zeroPointJieQi']),
      zeroPointAtConstellation: ConstellationDegree.fromJson(
          json['zeroPointAtConstellation'] as Map<String, dynamic>),
      zeroPointAtGong:
          GongDegree.fromJson(json['zeroPointAtGong'] as Map<String, dynamic>),
      celestialLongitude: (json['celestialLongitude'] as num).toDouble(),
      zeroPointOffsetToNow: (json['zeroPointOffsetToNow'] as num).toDouble(),
      rightAscension: (json['rightAscension'] as num).toDouble(),
      specificationList: (json['specificationList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ZhouTianModelToJson(ZhouTianModel instance) =>
    <String, dynamic>{
      'systemType': _$CelestialCoordinateSystemEnumMap[instance.systemType]!,
      'constellationSystemType':
          _$ConstellationSystemTypeEnumMap[instance.constellationSystemType]!,
      'panelSystemType': _$PanelSystemTypeEnumMap[instance.panelSystemType]!,
      'epochCorrection': instance.epochCorrection,
      'totalDegree': instance.totalDegree,
      'gongDegreeSeq': instance.gongDegreeSeq,
      'starInnDegreeSeq': instance.starInnDegreeSeq,
      'alignmentPointAtConstellation': instance.alignmentPointAtConstellation,
      'alignmentPointAtGong': instance.alignmentPointAtGong,
      'zeroPointJieQi': _$TwentyFourJieQiEnumMap[instance.zeroPointJieQi]!,
      'zeroPointAtConstellation': instance.zeroPointAtConstellation,
      'zeroPointAtGong': instance.zeroPointAtGong,
      'celestialLongitude': instance.celestialLongitude,
      'zeroPointOffsetToNow': instance.zeroPointOffsetToNow,
      'rightAscension': instance.rightAscension,
      'specificationList': instance.specificationList,
    };

const _$CelestialCoordinateSystemEnumMap = {
  CelestialCoordinateSystem.ecliptic: '黄道制',
  CelestialCoordinateSystem.equatorial: '赤道制',
  CelestialCoordinateSystem.skyEquatorial: '赤道制',
  CelestialCoordinateSystem.pseudoEcliptic: '似黄道恒星制',
};

const _$ConstellationSystemTypeEnumMap = {
  ConstellationSystemType.classical: '古宿制',
  ConstellationSystemType.adjustedClassical: '矫正古宿制',
  ConstellationSystemType.modern: '今宿制',
};

const _$PanelSystemTypeEnumMap = {
  PanelSystemType.tropical: '回归制',
  PanelSystemType.sidereal: '恒星制',
};

const _$TwentyFourJieQiEnumMap = {
  TwentyFourJieQi.DONG_ZHI: '冬至',
  TwentyFourJieQi.XIAO_HAN: '小寒',
  TwentyFourJieQi.DA_HAN: '大寒',
  TwentyFourJieQi.LI_CHUN: '立春',
  TwentyFourJieQi.YU_SHUI: '雨水',
  TwentyFourJieQi.JING_ZHE: '惊蛰',
  TwentyFourJieQi.CHUN_FEN: '春分',
  TwentyFourJieQi.QING_MING: '清明',
  TwentyFourJieQi.GU_YU: '谷雨',
  TwentyFourJieQi.LI_XIA: '立夏',
  TwentyFourJieQi.XIAO_MAN: '小满',
  TwentyFourJieQi.MANG_ZHONG: '芒种',
  TwentyFourJieQi.XIA_ZHI: '夏至',
  TwentyFourJieQi.XIAO_SHU: '小暑',
  TwentyFourJieQi.DA_SHU: '大暑',
  TwentyFourJieQi.LI_QIU: '立秋',
  TwentyFourJieQi.CHU_SHU: '处暑',
  TwentyFourJieQi.BAI_LU: '白露',
  TwentyFourJieQi.QIU_FEN: '秋分',
  TwentyFourJieQi.HAN_LU: '寒露',
  TwentyFourJieQi.SHUANG_JIANG: '霜降',
  TwentyFourJieQi.LI_DONG: '立冬',
  TwentyFourJieQi.XIAO_XUE: '小雪',
  TwentyFourJieQi.DA_XUE: '大雪',
};
