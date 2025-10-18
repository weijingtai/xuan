// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yuan_tang_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YuanTangInfo _$YuanTangInfoFromJson(Map<String, dynamic> json) => YuanTangInfo(
  eightChars: EightChars.fromJson(json['eightChars'] as Map<String, dynamic>),
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  threeYuan: $enumDecode(_$YuanYunOrderEnumMap, json['threeYuan']),
  calanderType: $enumDecode(_$CalanderTypeEnumMap, json['calanderType']),
  birthMonth: (json['birthMonth'] as num).toInt(),
  birthAfterJieQi: $enumDecode(
    _$TwentyFourJieQiEnumMap,
    json['birthAfterJieQi'],
  ),
  xianTanGua: PureYuanTangGua.fromJson(
    json['xianTanGua'] as Map<String, dynamic>,
  ),
  houTianGua: PureYuanTangGua.fromJson(
    json['houTianGua'] as Map<String, dynamic>,
  ),
  tianDiGuaData: json['tianDiGuaData'] == null
      ? null
      : TianDiGuaData.fromJson(json['tianDiGuaData'] as Map<String, dynamic>),
);

Map<String, dynamic> _$YuanTangInfoToJson(YuanTangInfo instance) =>
    <String, dynamic>{
      'eightChars': instance.eightChars,
      'gender': _$GenderEnumMap[instance.gender]!,
      'threeYuan': _$YuanYunOrderEnumMap[instance.threeYuan]!,
      'calanderType': _$CalanderTypeEnumMap[instance.calanderType]!,
      'birthMonth': instance.birthMonth,
      'birthAfterJieQi': _$TwentyFourJieQiEnumMap[instance.birthAfterJieQi]!,
      'xianTanGua': instance.xianTanGua,
      'houTianGua': instance.houTianGua,
      'tianDiGuaData': instance.tianDiGuaData,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.unknown: 'unknown',
};

const _$YuanYunOrderEnumMap = {
  YuanYunOrder.upper: '上元',
  YuanYunOrder.middle: '中元',
  YuanYunOrder.lower: '下元',
};

const _$CalanderTypeEnumMap = {
  CalanderType.lunar: 'lunar',
  CalanderType.solar: 'solar',
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
