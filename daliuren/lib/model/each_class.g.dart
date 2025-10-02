// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'each_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EachClass _$EachClassFromJson(Map<String, dynamic> json) => EachClass(
      order: (json['order'] as num).toInt(),
      sky: $enumDecode(_$DiZhiEnumMap, json['sky']),
      ground: $enumDecode(_$DiZhiEnumMap, json['ground']),
      guiRen: $enumDecode(_$GuiRenEnumMap, json['guiRen']),
      isSkyKeDayGan: json['isSkyKeDayGan'] as bool? ?? false,
      isSkySameYinYangWithDayGan:
          json['isSkySameYinYangWithDayGan'] as bool? ?? false,
      isFirstClass: json['isFirstClass'] as bool? ?? false,
    )
      ..sheHaiTimes = (json['sheHaiTimes'] as num?)?.toInt()
      ..otherSameSkyGroundIndexList =
          (json['otherSameSkyGroundIndexList'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList()
      ..zeiKeType =
          $enumDecodeNullable(_$EachClassZeiKeTypeEnumMap, json['zeiKeType']);

Map<String, dynamic> _$EachClassToJson(EachClass instance) => <String, dynamic>{
      'order': instance.order,
      'sky': _$DiZhiEnumMap[instance.sky]!,
      'ground': _$DiZhiEnumMap[instance.ground]!,
      'isFirstClass': instance.isFirstClass,
      'guiRen': _$GuiRenEnumMap[instance.guiRen]!,
      'sheHaiTimes': instance.sheHaiTimes,
      'otherSameSkyGroundIndexList': instance.otherSameSkyGroundIndexList,
      'zeiKeType': _$EachClassZeiKeTypeEnumMap[instance.zeiKeType],
      'isSkyKeDayGan': instance.isSkyKeDayGan,
      'isSkySameYinYangWithDayGan': instance.isSkySameYinYangWithDayGan,
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

const _$EachClassZeiKeTypeEnumMap = {
  EachClassZeiKeType.ZEI: '贼',
  EachClassZeiKeType.KE: '克',
};
