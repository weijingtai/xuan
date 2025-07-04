// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'each_class_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EachClassDataModel _$EachClassDataModelFromJson(Map<String, dynamic> json) =>
    EachClassDataModel(
      order: (json['order'] as num).toInt(),
      sky: EachClassDataModel._diZhiFromJson(json['sky'] as String),
      ground: EachClassDataModel._diZhiFromJson(json['ground'] as String),
      guiRen: $enumDecode(_$GuiRenEnumMap, json['guiRen']),
      isSkyKeDayGan: json['isSkyKeDayGan'] as bool?,
      isSkySameYinYangWithDayGan:
          json['isSkySameYinYangWithDayGan'] as bool? ?? false,
      isFirstClass: json['isFirstClass'] as bool? ?? false,
      sheHaiTimes: (json['sheHaiTimes'] as num?)?.toInt(),
      otherSameSkyGroundIndexList:
          (json['otherSameSkyGroundIndexList'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
    );

Map<String, dynamic> _$EachClassDataModelToJson(EachClassDataModel instance) =>
    <String, dynamic>{
      'order': instance.order,
      'sky': EachClassDataModel._diZhiToJson(instance.sky),
      'ground': EachClassDataModel._diZhiToJson(instance.ground),
      'isFirstClass': instance.isFirstClass,
      'guiRen': _$GuiRenEnumMap[instance.guiRen]!,
      if (instance.sheHaiTimes case final value?) 'sheHaiTimes': value,
      if (instance.otherSameSkyGroundIndexList case final value?)
        'otherSameSkyGroundIndexList': value,
      if (instance.isSkyKeDayGan case final value?) 'isSkyKeDayGan': value,
      'isSkySameYinYangWithDayGan': instance.isSkySameYinYangWithDayGan,
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
