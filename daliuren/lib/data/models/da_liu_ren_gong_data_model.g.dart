// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'da_liu_ren_gong_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DaLiuRenGongDataModel _$DaLiuRenGongDataModelFromJson(
        Map<String, dynamic> json) =>
    DaLiuRenGongDataModel(
      skyPanDiZhi:
          DaLiuRenGongDataModel._diZhiFromJson(json['skyPanDiZhi'] as String),
      groundPanDiZhi: DaLiuRenGongDataModel._diZhiFromJson(
          json['groundPanDiZhi'] as String),
      guiRen: $enumDecode(_$GuiRenEnumMap, json['guiRen']),
      jiaZi: DaLiuRenGongDataModel._jiaZiFromJsonNullable(
          json['jiaZi'] as String?),
      tianGan: DaLiuRenGongDataModel._tianGanFromJsonNullable(
          json['tianGan'] as String?),
    );

Map<String, dynamic> _$DaLiuRenGongDataModelToJson(
        DaLiuRenGongDataModel instance) =>
    <String, dynamic>{
      'groundPanDiZhi':
          DaLiuRenGongDataModel._diZhiToJson(instance.groundPanDiZhi),
      'guiRen': _$GuiRenEnumMap[instance.guiRen]!,
      'skyPanDiZhi': DaLiuRenGongDataModel._diZhiToJson(instance.skyPanDiZhi),
      if (DaLiuRenGongDataModel._tianGanToJsonNullable(instance.tianGan)
          case final value?)
        'tianGan': value,
      if (DaLiuRenGongDataModel._jiaZiToJsonNullable(instance.jiaZi)
          case final value?)
        'jiaZi': value,
    };

const _$GuiRenEnumMap = {
  GuiRen.GUI_REN: '贵人',
  GuiRen.TENG_SHE: '螣蛇',
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
  GuiRen.UNKNOWN: '未知',
};
