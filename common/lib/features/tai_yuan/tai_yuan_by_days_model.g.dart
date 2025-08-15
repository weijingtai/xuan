// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tai_yuan_by_days_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaiYuanByDaysModel _$TaiYuanByDaysModelFromJson(Map<String, dynamic> json) =>
    TaiYuanByDaysModel(
      actualMatureDays: (json['actualMatureDays'] as num).toInt(),
      taiYuanGanZhi: $enumDecode(_$JiaZiEnumMap, json['taiYuanGanZhi']),
      taiYuanBeforeMonth: (json['taiYuanBeforeMonth'] as num).toInt(),
      calculateStrategy: $enumDecode(
          _$TaiYuanCalculateStrategyEnumMap, json['calculateStrategy']),
      totalMatureMonth: (json['totalMatureMonth'] as num?)?.toDouble() ?? 0,
      isTestTubeBaby: json['isTestTubeBaby'] as bool? ?? false,
      adjustedTaiYuan:
          $enumDecodeNullable(_$JiaZiEnumMap, json['adjustedTaiYuan']),
      conceptionDateTime: json['conceptionDateTime'] == null
          ? null
          : DateTime.parse(json['conceptionDateTime'] as String),
      ganZhi: json['ganZhi'] == null
          ? null
          : EightChars.fromJson(json['ganZhi'] as Map<String, dynamic>),
      lunarMonth: (json['lunarMonth'] as num?)?.toInt(),
      lunarDay: (json['lunarDay'] as num?)?.toInt(),
      jieQiInfo: json['jieQiInfo'] == null
          ? null
          : JieQiInfo.fromJson(json['jieQiInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TaiYuanByDaysModelToJson(TaiYuanByDaysModel instance) =>
    <String, dynamic>{
      'conceptionDateTime': instance.conceptionDateTime?.toIso8601String(),
      'ganZhi': instance.ganZhi,
      'lunarMonth': instance.lunarMonth,
      'lunarDay': instance.lunarDay,
      'jieQiInfo': instance.jieQiInfo,
      'taiYuanGanZhi': _$JiaZiEnumMap[instance.taiYuanGanZhi]!,
      'adjustedTaiYuan': _$JiaZiEnumMap[instance.adjustedTaiYuan],
      'taiYuanBeforeMonth': instance.taiYuanBeforeMonth,
      'isTestTubeBaby': instance.isTestTubeBaby,
      'calculateStrategy':
          _$TaiYuanCalculateStrategyEnumMap[instance.calculateStrategy]!,
      'totalMatureMonth': instance.totalMatureMonth,
      'actualMatureDays': instance.actualMatureDays,
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

const _$TaiYuanCalculateStrategyEnumMap = {
  TaiYuanCalculateStrategy.directConceptionDate: '受孕时间法',
  TaiYuanCalculateStrategy.monthPillarMethod: '月柱推算法',
  TaiYuanCalculateStrategy.birthdayCountbackMethod: '生日倒推法',
  TaiYuanCalculateStrategy.dayMasterYinYangMethod: '日主阴阳属性法',
};
