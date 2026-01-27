// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'each_chuan_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EachChuanDataModel _$EachChuanDataModelFromJson(Map<String, dynamic> json) =>
    EachChuanDataModel(
      diZhi: EachChuanDataModel._diZhiFromJson(json['diZhi'] as String),
      tianGan: EachChuanDataModel._tianGanFromJsonNullable(
          json['tianGan'] as String?),
      guiRen: $enumDecode(_$GuiRenEnumMap, json['guiRen']),
      liuQin: EachChuanDataModel._liuQinFromJson(json['liuQin'] as String),
    );

Map<String, dynamic> _$EachChuanDataModelToJson(EachChuanDataModel instance) =>
    <String, dynamic>{
      'diZhi': EachChuanDataModel._diZhiToJson(instance.diZhi),
      if (EachChuanDataModel._tianGanToJsonNullable(instance.tianGan)
          case final value?)
        'tianGan': value,
      'guiRen': _$GuiRenEnumMap[instance.guiRen]!,
      'liuQin': EachChuanDataModel._liuQinToJson(instance.liuQin),
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
