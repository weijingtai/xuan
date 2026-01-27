// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'six_yao_gua.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SixYaoGua _$SixYaoGuaFromJson(Map<String, dynamic> json) => SixYaoGua(
  benName: json['benName'] as String,
  objectName: json['objectName'] as String,
  guaName: json['guaName'] as String,
  shiYaoIndex: (json['shiYaoIndex'] as num).toInt(),
  yingYaoIndex: (json['yingYaoIndex'] as num).toInt(),
  guaGong: json['guaGong'] as String,
  gongGuaName: json['gongGuaName'] as String,
  liuqinList: (json['liuqinList'] as List<dynamic>)
      .map((e) => $enumDecode(_$LiuQinEnumMap, e))
      .toList(),
  topBottomGanZhiList: (json['topBottomGanZhiList'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  binaryList: (json['binaryList'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  bottomTopGanList: (json['bottomTopGanList'] as List<dynamic>)
      .map((e) => $enumDecode(_$TianGanEnumMap, e))
      .toList(),
  bottomTopZhiList: (json['bottomTopZhiList'] as List<dynamic>)
      .map((e) => $enumDecode(_$DiZhiEnumMap, e))
      .toList(),
);

Map<String, dynamic> _$SixYaoGuaToJson(SixYaoGua instance) => <String, dynamic>{
  'benName': instance.benName,
  'objectName': instance.objectName,
  'guaName': instance.guaName,
  'shiYaoIndex': instance.shiYaoIndex,
  'yingYaoIndex': instance.yingYaoIndex,
  'guaGong': instance.guaGong,
  'gongGuaName': instance.gongGuaName,
  'liuqinList': instance.liuqinList.map((e) => _$LiuQinEnumMap[e]!).toList(),
  'topBottomGanZhiList': instance.topBottomGanZhiList,
  'bottomTopGanList': instance.bottomTopGanList
      .map((e) => _$TianGanEnumMap[e]!)
      .toList(),
  'bottomTopZhiList': instance.bottomTopZhiList
      .map((e) => _$DiZhiEnumMap[e]!)
      .toList(),
  'binaryList': instance.binaryList,
};

const _$LiuQinEnumMap = {
  LiuQin.JI_SHEN: '己身',
  LiuQin.XIONG_DI: '兄弟',
  LiuQin.FU_MU: '父母',
  LiuQin.QI_CAI: '妻财',
  LiuQin.GUAN_GUI: '官鬼',
  LiuQin.ZI_SUN: '子孙',
};

const _$TianGanEnumMap = {
  TianGan.JIA: '甲',
  TianGan.YI: '乙',
  TianGan.BING: '丙',
  TianGan.DING: '丁',
  TianGan.WU: '戊',
  TianGan.JI: '己',
  TianGan.GENG: '庚',
  TianGan.XIN: '辛',
  TianGan.REN: '壬',
  TianGan.GUI: '癸',
  TianGan.KONG_WANG: '空亡',
};

const _$DiZhiEnumMap = {
  DiZhi.ZI: '子',
  DiZhi.CHOU: '丑',
  DiZhi.YIN: '寅',
  DiZhi.MAO: '卯',
  DiZhi.CHEN: '辰',
  DiZhi.SI: '巳',
  DiZhi.WU: '午',
  DiZhi.WEI: '未',
  DiZhi.SHEN: '申',
  DiZhi.YOU: '酉',
  DiZhi.XU: '戌',
  DiZhi.HAI: '亥',
};
