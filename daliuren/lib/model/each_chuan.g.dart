// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'each_chuan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EachChuan _$EachChuanFromJson(Map<String, dynamic> json) => EachChuan(
      order: (json['order'] as num).toInt(),
      guiRen: $enumDecode(_$GuiRenEnumMap, json['guiRen']),
      liuQin: $enumDecode(_$LiuQinEnumMap, json['liuQin']),
      diZhi: $enumDecode(_$DiZhiEnumMap, json['diZhi']),
      tianGan: $enumDecodeNullable(_$TianGanEnumMap, json['tianGan']),
    );

Map<String, dynamic> _$EachChuanToJson(EachChuan instance) => <String, dynamic>{
      'order': instance.order,
      'diZhi': _$DiZhiEnumMap[instance.diZhi]!,
      'tianGan': _$TianGanEnumMap[instance.tianGan],
      'guiRen': _$GuiRenEnumMap[instance.guiRen]!,
      'liuQin': _$LiuQinEnumMap[instance.liuQin]!,
    };

const _$GuiRenEnumMap = {
  GuiRen.GUI_REN: '贵人',
  GuiRen.TENG_SHE: '腾蛇',
  GuiRen.ZHU_QUE: '朱雀',
  GuiRen.LIU_HE: '六合',
  GuiRen.GOU_CHEN: '勾陈',
  GuiRen.QING_LONG: '青龙',
  GuiRen.TIAN_KONG: '天空',
  GuiRen.BAI_HU: '白虎',
  GuiRen.TAI_CHANG: '太常',
  GuiRen.XUAN_WU: '玄武',
  GuiRen.TAI_YIN: '太阴',
  GuiRen.TIAN_HOU: '天后',
};

const _$LiuQinEnumMap = {
  LiuQin.JI_SHEN: '己身',
  LiuQin.XIONG_DI: '兄弟',
  LiuQin.FU_MU: '父母',
  LiuQin.QI_CAI: '妻财',
  LiuQin.GUAN_GUI: '官鬼',
  LiuQin.ZI_SUN: '子孙',
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
