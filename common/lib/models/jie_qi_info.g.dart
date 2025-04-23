// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jie_qi_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JieQiInfo _$JieQiInfoFromJson(Map<String, dynamic> json) => JieQiInfo(
      jieQi: $enumDecode(_$TwentyFourJieQiEnumMap, json['jieQi']),
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
    );

Map<String, dynamic> _$JieQiInfoToJson(JieQiInfo instance) => <String, dynamic>{
      'jieQi': _$TwentyFourJieQiEnumMap[instance.jieQi]!,
      'startAt': instance.startAt.toIso8601String(),
      'endAt': instance.endAt.toIso8601String(),
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
