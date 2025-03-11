// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_system_dateset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PanelSystemDataSet _$PanelSystemDataSetFromJson(Map<String, dynamic> json) =>
    PanelSystemDataSet(
      name: json['name'] as String,
      calenderName: json['calenderName'] as String,
      features: json['features'] as String,
      coordinateSystem:
          $enumDecode(_$CoordinateSystemEnumMap, json['coordinateSystem']),
      starInnSystem: $enumDecode(_$StarInnSystemEnumMap, json['starInnSystem']),
      starInnType: $enumDecode(_$StarInnTypeEnumMap, json['starInnType']),
      originPoint:
          EnteredInfo.fromJson(json['originPoint'] as Map<String, dynamic>),
      originPointJieQi:
          $enumDecode(_$TwentyFourJieQiEnumMap, json['originPointJieQi']),
      descriptionList: (json['descriptionList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    )..starInnGongDegreeMap =
          (json['starInnGongDegreeMap'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$TwentyEightStarInnEnumMap, k),
            StarInnGongDegreeInfo.fromJson(e as Map<String, dynamic>)),
      );

Map<String, dynamic> _$PanelSystemDataSetToJson(PanelSystemDataSet instance) =>
    <String, dynamic>{
      'name': instance.name,
      'calenderName': instance.calenderName,
      'features': instance.features,
      'coordinateSystem': _$CoordinateSystemEnumMap[instance.coordinateSystem]!,
      'starInnSystem': _$StarInnSystemEnumMap[instance.starInnSystem]!,
      'starInnType': _$StarInnTypeEnumMap[instance.starInnType]!,
      'originPoint': instance.originPoint,
      'originPointJieQi': _$TwentyFourJieQiEnumMap[instance.originPointJieQi]!,
      'descriptionList': instance.descriptionList,
      'starInnGongDegreeMap': instance.starInnGongDegreeMap
          .map((k, e) => MapEntry(_$TwentyEightStarInnEnumMap[k]!, e)),
    };

const _$CoordinateSystemEnumMap = {
  CoordinateSystem.Ecliptic: '黄道制',
  CoordinateSystem.Equatorial: '赤道制',
};

const _$StarInnSystemEnumMap = {
  StarInnSystem.Tropical: '回归制',
  StarInnSystem.Sidereal: '恒星制',
};

const _$StarInnTypeEnumMap = {
  StarInnType.Classical: '古宿',
  StarInnType.AdjustedClassical: '矫正古宿',
  StarInnType.Mordern: '今宿',
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
