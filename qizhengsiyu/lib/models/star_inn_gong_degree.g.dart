// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'star_inn_gong_degree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StarInnGongDegreeInfo _$StarInnGongDegreeInfoFromJson(
        Map<String, dynamic> json) =>
    StarInnGongDegreeInfo(
      starType: $enumDecode(_$StarPanelTypeEnumMap, json['starType']),
      starXiu: $enumDecode(_$TwentyEightStarInnEnumMap, json['starXiu']),
      degreeStartAt: (json['degreeStartAt'] as num).toDouble(),
      totalDegree: (json['totalDegree'] as num).toDouble(),
      startAtGongDegree: GongAndDegree.fromJson(
          json['startAtGongDegree'] as Map<String, dynamic>),
      endAtGongDegree: GongAndDegree.fromJson(
          json['endAtGongDegree'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StarInnGongDegreeInfoToJson(
        StarInnGongDegreeInfo instance) =>
    <String, dynamic>{
      'starType': _$StarPanelTypeEnumMap[instance.starType]!,
      'starXiu': _$TwentyEightStarInnEnumMap[instance.starXiu]!,
      'degreeStartAt': instance.degreeStartAt,
      'startAtGongDegree': instance.startAtGongDegree,
      'endAtGongDegree': instance.endAtGongDegree,
      'totalDegree': instance.totalDegree,
    };

const _$StarPanelTypeEnumMap = {
  StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper: '黄道回归制古宿',
  StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper: '黄道回归制矫正古宿',
  StarPanelType.EquatorialSiderealStarsInnSystemMapper: '赤道恒星制',
  StarPanelType.ZodiacSiderealStarsInnSystemMapper: '黄道恒星制',
  StarPanelType.ZodiacTropicalModernStarsInnSystemMapper: '黄道回归制今宿',
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
