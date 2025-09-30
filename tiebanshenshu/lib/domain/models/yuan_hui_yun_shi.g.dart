// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yuan_hui_yun_shi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YuanHuiYunShi _$YuanHuiYunShiFromJson(Map<String, dynamic> json) =>
    YuanHuiYunShi(
        year: $enumDecode(_$JiaZiEnumMap, json['year']),
        month: $enumDecode(_$JiaZiEnumMap, json['month']),
        day: $enumDecode(_$JiaZiEnumMap, json['day']),
        time: $enumDecode(_$JiaZiEnumMap, json['time']),
      )
      ..yearZhi = $enumDecode(_$DiZhiEnumMap, json['yearZhi'])
      ..yearGan = $enumDecode(_$TianGanEnumMap, json['yearGan'])
      ..yearZhiNumber = (json['yearZhiNumber'] as num).toInt()
      ..yearGanNumber = (json['yearGanNumber'] as num).toInt()
      ..monthZhi = $enumDecode(_$DiZhiEnumMap, json['monthZhi'])
      ..monthGan = $enumDecode(_$TianGanEnumMap, json['monthGan'])
      ..monthZhiNumber = (json['monthZhiNumber'] as num).toInt()
      ..monthGanNumber = (json['monthGanNumber'] as num).toInt()
      ..dayZhi = $enumDecode(_$DiZhiEnumMap, json['dayZhi'])
      ..dayGan = $enumDecode(_$TianGanEnumMap, json['dayGan'])
      ..dayZhiNumber = (json['dayZhiNumber'] as num).toInt()
      ..dayGanNumber = (json['dayGanNumber'] as num).toInt()
      ..timeZhi = $enumDecode(_$DiZhiEnumMap, json['timeZhi'])
      ..timeGan = $enumDecode(_$TianGanEnumMap, json['timeGan'])
      ..timeZhiNumber = (json['timeZhiNumber'] as num).toInt()
      ..timeGanNumber = (json['timeGanNumber'] as num).toInt()
      ..yuanNumber = (json['yuanNumber'] as num).toInt()
      ..huiNumber = (json['huiNumber'] as num).toInt()
      ..yunNumber = (json['yunNumber'] as num).toInt()
      ..shiNumber = (json['shiNumber'] as num).toInt()
      ..yuanHuiMergeNumber = HuangJiBaseNumber.fromJson(
        json['yuanHuiMergeNumber'] as Map<String, dynamic>,
      )
      ..yunShiMergeNumber = HuangJiBaseNumber.fromJson(
        json['yunShiMergeNumber'] as Map<String, dynamic>,
      );

Map<String, dynamic> _$YuanHuiYunShiToJson(YuanHuiYunShi instance) =>
    <String, dynamic>{
      'year': _$JiaZiEnumMap[instance.year]!,
      'month': _$JiaZiEnumMap[instance.month]!,
      'day': _$JiaZiEnumMap[instance.day]!,
      'time': _$JiaZiEnumMap[instance.time]!,
      'yearZhi': _$DiZhiEnumMap[instance.yearZhi]!,
      'yearGan': _$TianGanEnumMap[instance.yearGan]!,
      'yearZhiNumber': instance.yearZhiNumber,
      'yearGanNumber': instance.yearGanNumber,
      'monthZhi': _$DiZhiEnumMap[instance.monthZhi]!,
      'monthGan': _$TianGanEnumMap[instance.monthGan]!,
      'monthZhiNumber': instance.monthZhiNumber,
      'monthGanNumber': instance.monthGanNumber,
      'dayZhi': _$DiZhiEnumMap[instance.dayZhi]!,
      'dayGan': _$TianGanEnumMap[instance.dayGan]!,
      'dayZhiNumber': instance.dayZhiNumber,
      'dayGanNumber': instance.dayGanNumber,
      'timeZhi': _$DiZhiEnumMap[instance.timeZhi]!,
      'timeGan': _$TianGanEnumMap[instance.timeGan]!,
      'timeZhiNumber': instance.timeZhiNumber,
      'timeGanNumber': instance.timeGanNumber,
      'yuanNumber': instance.yuanNumber,
      'huiNumber': instance.huiNumber,
      'yunNumber': instance.yunNumber,
      'shiNumber': instance.shiNumber,
      'yuanHuiMergeNumber': instance.yuanHuiMergeNumber,
      'yunShiMergeNumber': instance.yunShiMergeNumber,
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
