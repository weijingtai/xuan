// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liu_ren_pan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiuRenPanModel _$LiuRenPanModelFromJson(Map<String, dynamic> json) =>
    LiuRenPanModel(
      dayJiaZi: $enumDecode(_$JiaZiEnumMap, json['dayJiaZi']),
      timeGanZhi: $enumDecode(_$JiaZiEnumMap, json['timeGanZhi']),
      fourClasses: (json['fourClasses'] as List<dynamic>)
          .map((e) => RawEachClass.fromJson(e as Map<String, dynamic>))
          .toList(),
      threeChuans: (json['threeChuans'] as List<dynamic>)
          .map((e) => EachChuan.fromJson(e as Map<String, dynamic>))
          .toList(),
      nineZongMen: $enumDecode(_$NineZongMenEnumMap, json['nineZongMen']),
      monthGeneral: $enumDecode(_$MonthGeneralEnumMap, json['monthGeneral']),
      dayNight: $enumDecode(_$EnumDayNightEnumMap, json['dayNight']),
      keTiComplement: (json['keTiComplement'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ju: (json['ju'] as num).toInt(),
      panType: $enumDecode(_$PanTypeEnumMap, json['panType']),
      guiRenLocation: $enumDecode(_$DiZhiEnumMap, json['guiRenLocation']),
      gongMapper: (json['gongMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$DiZhiEnumMap, k),
            EachGong.fromJson(e as Map<String, dynamic>)),
      ),
      patternName: (json['patternName'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$LiuRenPanModelToJson(LiuRenPanModel instance) =>
    <String, dynamic>{
      'dayJiaZi': _$JiaZiEnumMap[instance.dayJiaZi]!,
      'timeGanZhi': _$JiaZiEnumMap[instance.timeGanZhi]!,
      'panType': _$PanTypeEnumMap[instance.panType]!,
      'monthGeneral': _$MonthGeneralEnumMap[instance.monthGeneral]!,
      'dayNight': _$EnumDayNightEnumMap[instance.dayNight]!,
      'fourClasses': instance.fourClasses.map((e) => e.toJson()).toList(),
      'threeChuans': instance.threeChuans.map((e) => e.toJson()).toList(),
      'nineZongMen': _$NineZongMenEnumMap[instance.nineZongMen]!,
      'keTiComplement': instance.keTiComplement,
      'gongMapper': instance.gongMapper
          .map((k, e) => MapEntry(_$DiZhiEnumMap[k]!, e.toJson())),
      'ju': instance.ju,
      'patternName': instance.patternName,
      'guiRenLocation': _$DiZhiEnumMap[instance.guiRenLocation]!,
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

const _$MonthGeneralEnumMap = {
  MonthGeneral.HAI_ZHENG_MING: 'HAI_ZHENG_MING',
  MonthGeneral.XU_TIAN_KUI: 'XU_TIAN_KUI',
  MonthGeneral.YOU_CONG_KUI: 'YOU_CONG_KUI',
  MonthGeneral.SHEN_CHUAN_SONG: 'SHEN_CHUAN_SONG',
  MonthGeneral.WEI_XIAO_JI: 'WEI_XIAO_JI',
  MonthGeneral.WU_SHENG_GUANG: 'WU_SHENG_GUANG',
  MonthGeneral.SI_TAI_YI: 'SI_TAI_YI',
  MonthGeneral.CHEN_TIAN_GANG: 'CHEN_TIAN_GANG',
  MonthGeneral.MAO_TAI_CHONG: 'MAO_TAI_CHONG',
  MonthGeneral.YIN_GONG_CAO: 'YIN_GONG_CAO',
  MonthGeneral.CHOU_DA_JI: 'CHOU_DA_JI',
  MonthGeneral.ZI_SHEN_HOU: 'ZI_SHEN_HOU',
};

const _$EnumDayNightEnumMap = {
  EnumDayNight.day: '昼',
  EnumDayNight.night: '夜',
};

const _$PanTypeEnumMap = {
  PanType.fuYin: '伏吟',
  PanType.tui_lianRu: '退连茹',
  PanType.tui_jianChua: '退间传',
  PanType.bingTai: '病胎',
  PanType.ni_sanHe: '逆三合',
  PanType.siJue: '四绝',
  PanType.fanYin: '反吟',
  PanType.siMuFuSheng: '四目覆生',
  PanType.shun_sanHe: '顺三合',
  PanType.shengTai: '生胎',
  PanType.shun_jianChuan: '顺间传',
  PanType.luoWang: '罗网',
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
