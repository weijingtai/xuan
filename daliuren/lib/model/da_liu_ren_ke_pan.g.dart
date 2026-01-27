// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'da_liu_ren_ke_pan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EachChuan _$EachChuanFromJson(Map<String, dynamic> json) => EachChuan(
      order: (json['order'] as num).toInt(),
      guiRen: $enumDecode(_$GuiRenEnumMap, json['guiRen']),
      liuQin: $enumDecode(_$LiuQinEnumMap, json['liuQin']),
      diZhi: $enumDecode(_$DiZhiEnumMap, json['diZhi']),
      jiaZi: $enumDecodeNullable(_$JiaZiEnumMap, json['jiaZi']),
    );

Map<String, dynamic> _$EachChuanToJson(EachChuan instance) => <String, dynamic>{
      'order': instance.order,
      'diZhi': _$DiZhiEnumMap[instance.diZhi]!,
      'guiRen': _$GuiRenEnumMap[instance.guiRen]!,
      'liuQin': _$LiuQinEnumMap[instance.liuQin]!,
      if (_$JiaZiEnumMap[instance.jiaZi] case final value?) 'jiaZi': value,
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

const _$JiaZiEnumMap = {
  JiaZi.JIA_ZI: '甲子',
  JiaZi.YI_CHOU: '乙丑',
  JiaZi.BING_YIN: '丙寅',
  JiaZi.DING_MAO: '丁卯',
  JiaZi.WU_CHEN: '戊辰',
  JiaZi.JI_SI: '己巳',
  JiaZi.GENG_WU: '庚午',
  JiaZi.XIN_WEI: '辛未',
  JiaZi.REN_SHEN: '壬申',
  JiaZi.GUI_YOU: '癸酉',
  JiaZi.JIA_XU: '甲戌',
  JiaZi.YI_HAI: '乙亥',
  JiaZi.BING_ZI: '丙子',
  JiaZi.DING_CHOU: '丁丑',
  JiaZi.WU_YIN: '戊寅',
  JiaZi.JI_MAO: '己卯',
  JiaZi.GENG_CHEN: '庚辰',
  JiaZi.XIN_SI: '辛巳',
  JiaZi.REN_WU: '壬午',
  JiaZi.GUI_WEI: '癸未',
  JiaZi.JIA_SHEN: '甲申',
  JiaZi.YI_YOU: '乙酉',
  JiaZi.BING_XU: '丙戌',
  JiaZi.DING_HAI: '丁亥',
  JiaZi.WU_ZI: '戊子',
  JiaZi.JI_CHOU: '己丑',
  JiaZi.GENG_YIN: '庚寅',
  JiaZi.XIN_MAO: '辛卯',
  JiaZi.REN_CHEN: '壬辰',
  JiaZi.GUI_SI: '癸巳',
  JiaZi.JIA_WU: '甲午',
  JiaZi.YI_WEI: '乙未',
  JiaZi.BING_SHEN: '丙申',
  JiaZi.DING_YOU: '丁酉',
  JiaZi.WU_XU: '戊戌',
  JiaZi.JI_HAI: '己亥',
  JiaZi.GENG_ZI: '庚子',
  JiaZi.XIN_CHOU: '辛丑',
  JiaZi.REN_YIN: '壬寅',
  JiaZi.GUI_MAO: '癸卯',
  JiaZi.JIA_CHEN: '甲辰',
  JiaZi.YI_SI: '乙巳',
  JiaZi.BING_WU: '丙午',
  JiaZi.DING_WEI: '丁未',
  JiaZi.WU_SHEN: '戊申',
  JiaZi.JI_YOU: '己酉',
  JiaZi.GENG_XU: '庚戌',
  JiaZi.XIN_HAI: '辛亥',
  JiaZi.REN_ZI: '壬子',
  JiaZi.GUI_CHOU: '癸丑',
  JiaZi.JIA_YIN: '甲寅',
  JiaZi.YI_MAO: '乙卯',
  JiaZi.BING_CHEN: '丙辰',
  JiaZi.DING_SI: '丁巳',
  JiaZi.WU_WU: '戊午',
  JiaZi.JI_WEI: '己未',
  JiaZi.GENG_SHEN: '庚申',
  JiaZi.XIN_YOU: '辛酉',
  JiaZi.REN_XU: '壬戌',
  JiaZi.GUI_HAI: '癸亥',
};

EachClass _$EachClassFromJson(Map<String, dynamic> json) => EachClass(
      order: (json['order'] as num).toInt(),
      sky: $enumDecode(_$DiZhiEnumMap, json['sky']),
      ground: $enumDecode(_$DiZhiEnumMap, json['ground']),
      guiRen: $enumDecode(_$GuiRenEnumMap, json['guiRen']),
      isSkyKeDayGan: json['isSkyKeDayGan'] as bool? ?? false,
      isSkySameYinYangWithDayGan:
          json['isSkySameYinYangWithDayGan'] as bool? ?? false,
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
      'guiRen': _$GuiRenEnumMap[instance.guiRen]!,
      if (instance.sheHaiTimes case final value?) 'sheHaiTimes': value,
      if (instance.otherSameSkyGroundIndexList case final value?)
        'otherSameSkyGroundIndexList': value,
      if (_$EachClassZeiKeTypeEnumMap[instance.zeiKeType] case final value?)
        'zeiKeType': value,
      if (instance.isSkyKeDayGan case final value?) 'isSkyKeDayGan': value,
      'isSkySameYinYangWithDayGan': instance.isSkySameYinYangWithDayGan,
    };

const _$EachClassZeiKeTypeEnumMap = {
  EachClassZeiKeType.ZEI: '贼',
  EachClassZeiKeType.KE: '克',
};

EachGong _$EachGongFromJson(Map<String, dynamic> json) => EachGong(
      skyPanDiZhi: $enumDecode(_$DiZhiEnumMap, json['skyPanDiZhi']),
      groundPanDiZhi: $enumDecode(_$DiZhiEnumMap, json['groundPanDiZhi']),
      guiRen: $enumDecode(_$GuiRenEnumMap, json['guiRen']),
      jiaZi: $enumDecodeNullable(_$JiaZiEnumMap, json['jiaZi']),
    );

Map<String, dynamic> _$EachGongToJson(EachGong instance) => <String, dynamic>{
      'groundPanDiZhi': _$DiZhiEnumMap[instance.groundPanDiZhi]!,
      'guiRen': _$GuiRenEnumMap[instance.guiRen]!,
      'skyPanDiZhi': _$DiZhiEnumMap[instance.skyPanDiZhi]!,
      if (_$JiaZiEnumMap[instance.jiaZi] case final value?) 'jiaZi': value,
    };

FirstClass _$FirstClassFromJson(Map<String, dynamic> json) => FirstClass(
      sky: $enumDecode(_$DiZhiEnumMap, json['sky']),
      ground: $enumDecode(_$DiZhiEnumMap, json['ground']),
      guiRen: $enumDecode(_$GuiRenEnumMap, json['guiRen']),
      tianGan: $enumDecode(_$TianGanEnumMap, json['tianGan']),
    )
      ..order = (json['order'] as num).toInt()
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
      'order': instance.order,
      'sky': _$DiZhiEnumMap[instance.sky]!,
      'ground': _$DiZhiEnumMap[instance.ground]!,
      'guiRen': _$GuiRenEnumMap[instance.guiRen]!,
      if (instance.sheHaiTimes case final value?) 'sheHaiTimes': value,
      if (instance.otherSameSkyGroundIndexList case final value?)
        'otherSameSkyGroundIndexList': value,
      if (_$EachClassZeiKeTypeEnumMap[instance.zeiKeType] case final value?)
        'zeiKeType': value,
      if (instance.isSkyKeDayGan case final value?) 'isSkyKeDayGan': value,
      'isSkySameYinYangWithDayGan': instance.isSkySameYinYangWithDayGan,
      'tianGan': _$TianGanEnumMap[instance.tianGan]!,
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

FourClass _$FourClassFromJson(Map<String, dynamic> json) => FourClass(
      first: FirstClass.fromJson(json['first'] as Map<String, dynamic>),
      second: EachClass.fromJson(json['second'] as Map<String, dynamic>),
      third: EachClass.fromJson(json['third'] as Map<String, dynamic>),
      fourth: EachClass.fromJson(json['fourth'] as Map<String, dynamic>),
      isFuYin: json['isFuYin'] as bool,
      isFanYin: json['isFanYin'] as bool,
      isThreeClassOnly: json['isThreeClassOnly'] as bool,
      isFullClass: json['isFullClass'] as bool,
      sameSkyGroundClassList: (json['sameSkyGroundClassList'] as List<dynamic>?)
          ?.map((e) => EachClass.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FourClassToJson(FourClass instance) => <String, dynamic>{
      'isFullClass': instance.isFullClass,
      'isThreeClassOnly': instance.isThreeClassOnly,
      'isFuYin': instance.isFuYin,
      'isFanYin': instance.isFanYin,
      'first': instance.first.toJson(),
      'second': instance.second.toJson(),
      'third': instance.third.toJson(),
      'fourth': instance.fourth.toJson(),
      if (instance.sameSkyGroundClassList?.map((e) => e.toJson()).toList()
          case final value?)
        'sameSkyGroundClassList': value,
    };

ThreeChuan _$ThreeChuanFromJson(Map<String, dynamic> json) => ThreeChuan(
      nineZongMen: $enumDecode(_$NineZongMenEnumMap, json['nineZongMen']),
      first: EachChuan.fromJson(json['first'] as Map<String, dynamic>),
      second: EachChuan.fromJson(json['second'] as Map<String, dynamic>),
      third: EachChuan.fromJson(json['third'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ThreeChuanToJson(ThreeChuan instance) =>
    <String, dynamic>{
      'nineZongMen': _$NineZongMenEnumMap[instance.nineZongMen]!,
      'first': instance.first.toJson(),
      'second': instance.second.toJson(),
      'third': instance.third.toJson(),
    };

const _$NineZongMenEnumMap = {
  NineZongMen.ZEI_KE: '贼克',
  NineZongMen.BI_YONG: '比用',
  NineZongMen.SHE_HAI: '涉害',
  NineZongMen.YAO_KE: '遥克',
  NineZongMen.MAO_XING: '昴星',
  NineZongMen.BIE_ZE: '别责',
  NineZongMen.BA_ZHUAN: '八专',
  NineZongMen.FU_YIN: '伏吟',
  NineZongMen.FAN_YIN: '返吟',
  NineZongMen.UNKNOWN: '未知',
};
