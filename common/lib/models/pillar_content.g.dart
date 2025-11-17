// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pillar_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PillarContent _$PillarContentFromJson(Map<String, dynamic> json) =>
    PillarContent(
      id: json['id'] as String,
      pillarType: $enumDecode(_$PillarTypeEnumMap, json['pillarType']),
      label: json['label'] as String,
      jiaZi: $enumDecode(_$JiaZiEnumMap, json['jiaZi']),
      description: json['description'] as String?,
      version: json['version'] as String,
      sourceKind: $enumDecode(_$PillarSourceKindEnumMap, json['sourceKind']),
      operationType: $enumDecodeNullable(
          _$PillarOperationTypeEnumMap, json['operationType']),
    );

Map<String, dynamic> _$PillarContentToJson(PillarContent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pillarType': _$PillarTypeEnumMap[instance.pillarType]!,
      'label': instance.label,
      'jiaZi': _$JiaZiEnumMap[instance.jiaZi]!,
      'description': instance.description,
      'version': instance.version,
      'sourceKind': _$PillarSourceKindEnumMap[instance.sourceKind]!,
      'operationType': _$PillarOperationTypeEnumMap[instance.operationType],
    };

const _$PillarTypeEnumMap = {
  PillarType.year: 'year',
  PillarType.month: 'month',
  PillarType.day: 'day',
  PillarType.hour: 'time',
  PillarType.ke: 'ke',
  PillarType.taiMeta: 'tai_meta',
  PillarType.taiMonth: 'tai_month',
  PillarType.taiDay: 'tai_day',
  PillarType.bodyHouse: 'body_house',
  PillarType.lifeHouse: '命宫',
  PillarType.luckCycle: 'luck_cycle',
  PillarType.annual: 'annual',
  PillarType.monthly: 'monthly',
  PillarType.daily: 'daily',
  PillarType.hourly: 'hourly',
  PillarType.kely: 'kely',
  PillarType.separator: 'separator',
  PillarType.rowTitleColumn: 'row_title_column',
};

const _$JiaZiEnumMap = {
  JiaZi.JIA_ZI: '甲子',
  JiaZi.YI_CHOU: '乙丑',
  JiaZi.BING_YIN: '丙寅',
  JiaZi.DING_MAO: '丁卯',
  JiaZi.WU_CHEN: '戊辰',
  JiaZi.JI_SI: '己巳',
  JiaZi.GENG_WU: '庚午',
  JiaZi.XIN_WEI: '辛未',
  JiaZi.REN_SHEN: '壬申',
  JiaZi.GUI_YOU: '癸酉',
  JiaZi.JIA_XU: '甲戌',
  JiaZi.YI_HAI: '乙亥',
  JiaZi.BING_ZI: '丙子',
  JiaZi.DING_CHOU: '丁丑',
  JiaZi.WU_YIN: '戊寅',
  JiaZi.JI_MAO: '己卯',
  JiaZi.GENG_CHEN: '庚辰',
  JiaZi.XIN_SI: '辛巳',
  JiaZi.REN_WU: '壬午',
  JiaZi.GUI_WEI: '癸未',
  JiaZi.JIA_SHEN: '甲申',
  JiaZi.YI_YOU: '乙酉',
  JiaZi.BING_XU: '丙戌',
  JiaZi.DING_HAI: '丁亥',
  JiaZi.WU_ZI: '戊子',
  JiaZi.JI_CHOU: '己丑',
  JiaZi.GENG_YIN: '庚寅',
  JiaZi.XIN_MAO: '辛卯',
  JiaZi.REN_CHEN: '壬辰',
  JiaZi.GUI_SI: '癸巳',
  JiaZi.JIA_WU: '甲午',
  JiaZi.YI_WEI: '乙未',
  JiaZi.BING_SHEN: '丙申',
  JiaZi.DING_YOU: '丁酉',
  JiaZi.WU_XU: '戊戌',
  JiaZi.JI_HAI: '己亥',
  JiaZi.GENG_ZI: '庚子',
  JiaZi.XIN_CHOU: '辛丑',
  JiaZi.REN_YIN: '壬寅',
  JiaZi.GUI_MAO: '癸卯',
  JiaZi.JIA_CHEN: '甲辰',
  JiaZi.YI_SI: '乙巳',
  JiaZi.BING_WU: '丙午',
  JiaZi.DING_WEI: '丁未',
  JiaZi.WU_SHEN: '戊申',
  JiaZi.JI_YOU: '己酉',
  JiaZi.GENG_XU: '庚戌',
  JiaZi.XIN_HAI: '辛亥',
  JiaZi.REN_ZI: '壬子',
  JiaZi.GUI_CHOU: '癸丑',
  JiaZi.JIA_YIN: '甲寅',
  JiaZi.YI_MAO: '乙卯',
  JiaZi.BING_CHEN: '丙辰',
  JiaZi.DING_SI: '丁巳',
  JiaZi.WU_WU: '戊午',
  JiaZi.JI_WEI: '己未',
  JiaZi.GENG_SHEN: '庚申',
  JiaZi.XIN_YOU: '辛酉',
  JiaZi.REN_XU: '壬戌',
  JiaZi.GUI_HAI: '癸亥',
};

const _$PillarSourceKindEnumMap = {
  PillarSourceKind.operation: 'operation',
  PillarSourceKind.userInput: 'userInput',
  PillarSourceKind.currentTime: 'currentTime',
};

const _$PillarOperationTypeEnumMap = {
  PillarOperationType.taiYuan: 'taiYuan',
  PillarOperationType.shenGong: 'shenGong',
  PillarOperationType.mingGong: 'mingGong',
  PillarOperationType.daYun: 'daYun',
};
