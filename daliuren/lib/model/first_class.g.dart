// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirstClass _$FirstClassFromJson(Map<String, dynamic> json) => FirstClass(
      sky: $enumDecode(_$DiZhiEnumMap, json['sky']),
      ground: $enumDecode(_$DiZhiEnumMap, json['ground']),
      guiRen: $enumDecode(_$GuiRenEnumMap, json['guiRen']),
      tianGan: $enumDecode(_$TianGanEnumMap, json['tianGan']),
    )
      ..isFirstClass = json['isFirstClass'] as bool
      ..sheHaiTimes = (json['sheHaiTimes'] as num?)?.toInt()
      ..otherSameSkyGroundIndexList =
          (json['otherSameSkyGroundIndexList'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList()
      ..zeiKeType =
          $enumDecodeNullable(_$EachClassZeiKeTypeEnumMap, json['zeiKeType'])
      ..isSkyKeDayGan = json['isSkyKeDayGan'] as bool?
      ..isSkySameYinYangWithDayGan = json['isSkySameYinYangWithDayGan'] as bool;

Map<String, dynamic> _$FirstClassToJson(FirstClass instance) =>
    <String, dynamic>{
      'sky': _$DiZhiEnumMap[instance.sky]!,
      'ground': _$DiZhiEnumMap[instance.ground]!,
      'isFirstClass': instance.isFirstClass,
      'guiRen': _$GuiRenEnumMap[instance.guiRen]!,
      'sheHaiTimes': instance.sheHaiTimes,
      'otherSameSkyGroundIndexList': instance.otherSameSkyGroundIndexList,
      'zeiKeType': _$EachClassZeiKeTypeEnumMap[instance.zeiKeType],
      'isSkyKeDayGan': instance.isSkyKeDayGan,
      'isSkySameYinYangWithDayGan': instance.isSkySameYinYangWithDayGan,
      'tianGan': _$TianGanEnumMap[instance.tianGan]!,
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

const _$EachClassZeiKeTypeEnumMap = {
  EachClassZeiKeType.ZEI: '贼',
  EachClassZeiKeType.KE: '克',
};
