// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'star_enter_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnteredInfo _$EnteredInfoFromJson(Map<String, dynamic> json) => EnteredInfo(
      gong: $enumDecode(_$EnumTwelveGongEnumMap, json['gong']),
      atGongDegree: (json['atGongDegree'] as num).toDouble(),
      inn: $enumDecode(_$TwentyEightStarInnEnumMap, json['inn']),
      atInnDegree: (json['atInnDegree'] as num).toDouble(),
    );

Map<String, dynamic> _$EnteredInfoToJson(EnteredInfo instance) =>
    <String, dynamic>{
      'gong': _$EnumTwelveGongEnumMap[instance.gong]!,
      'atGongDegree': instance.atGongDegree,
      'inn': _$TwentyEightStarInnEnumMap[instance.inn]!,
      'atInnDegree': instance.atInnDegree,
    };

const _$EnumTwelveGongEnumMap = {
  EnumTwelveGong.Zi: '子',
  EnumTwelveGong.Chou: '丑',
  EnumTwelveGong.Yin: '寅',
  EnumTwelveGong.Mao: '卯',
  EnumTwelveGong.Chen: '辰',
  EnumTwelveGong.Si: '巳',
  EnumTwelveGong.Wu: '午',
  EnumTwelveGong.Wei: '未',
  EnumTwelveGong.Shen: '申',
  EnumTwelveGong.You: '酉',
  EnumTwelveGong.Xu: '戌',
  EnumTwelveGong.Hai: '亥',
};

const _$TwentyEightStarInnEnumMap = {
  TwentyEightStarInn.Lou_Jin_Gou: '娄',
  TwentyEightStarInn.Wei_Tu_Zhi: '胃',
  TwentyEightStarInn.Mao_Ri_Ji: '昴',
  TwentyEightStarInn.Bi_Yue_Wu: '毕',
  TwentyEightStarInn.Zi_Huo_Hou: '觜',
  TwentyEightStarInn.Shen_Shui_Yuan: '参',
  TwentyEightStarInn.Jing_Mu_Han: '井',
  TwentyEightStarInn.Gui_Jin_Yang: '鬼',
  TwentyEightStarInn.Liu_Tu_Zhang: '柳',
  TwentyEightStarInn.Xing_Ri_Ma: '星',
  TwentyEightStarInn.Zhang_Yue_Lu: '张',
  TwentyEightStarInn.Yi_Huo_She: '翼',
  TwentyEightStarInn.Zhen_Shui_Yin: '轸',
  TwentyEightStarInn.Jiao_Mu_Jiao: '角',
  TwentyEightStarInn.Kang_Jin_Long: '亢',
  TwentyEightStarInn.Di_Tu_Lu: '氐',
  TwentyEightStarInn.Fang_Ri_Tu: '房',
  TwentyEightStarInn.Xin_Yue_Hu: '心',
  TwentyEightStarInn.Wei_Huo_Hu: '尾',
  TwentyEightStarInn.Ji_Shui_Bao: '箕',
  TwentyEightStarInn.Dou_Mu_Xie: '斗',
  TwentyEightStarInn.Niu_Jin_Niu: '牛',
  TwentyEightStarInn.Nv_Tu_Fu: '女',
  TwentyEightStarInn.Xu_Ri_Shu: '虚',
  TwentyEightStarInn.Wei_Yue_Yan: '危',
  TwentyEightStarInn.Shi_Huo_Zhu: '室',
  TwentyEightStarInn.Bi_Shui_Yu: '壁',
  TwentyEightStarInn.Kui_Mu_Lang: '奎',
};
