// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seventy_two_phenology.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Phenology _$PhenologyFromJson(Map<String, dynamic> json) => Phenology(
      name: json['name'] as String,
      jieqi: $enumDecode(_$TwentyFourJieQiEnumMap, json['jieqi']),
      description: json['description'] as String,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$PhenologyToJson(Phenology instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'jieqi': _$TwentyFourJieQiEnumMap[instance.jieqi]!,
      'order': instance.order,
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
