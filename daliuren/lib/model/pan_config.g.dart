// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pan_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PanConfig _$PanConfigFromJson(Map<String, dynamic> json) => PanConfig(
      monthGeneralType: $enumDecode(
          _$CalculateMonthGeneralTypeEnumMap, json['monthGeneralType']),
      dayNightBoundaryType: $enumDecode(
          _$DayNightBoundaryTypeEnumMap, json['dayNightBoundaryType']),
      guiRenType: $enumDecode(_$GuiRenTypeEnumMap, json['guiRenType']),
      dayNight: $enumDecodeNullable(_$EnumDayNightEnumMap, json['dayNight']),
    );

Map<String, dynamic> _$PanConfigToJson(PanConfig instance) => <String, dynamic>{
      'monthGeneralType':
          _$CalculateMonthGeneralTypeEnumMap[instance.monthGeneralType]!,
      'dayNightBoundaryType':
          _$DayNightBoundaryTypeEnumMap[instance.dayNightBoundaryType]!,
      if (_$EnumDayNightEnumMap[instance.dayNight] case final value?)
        'dayNight': value,
      'guiRenType': _$GuiRenTypeEnumMap[instance.guiRenType]!,
    };

const _$CalculateMonthGeneralTypeEnumMap = {
  CalculateMonthGeneralType.monthJian: '月建',
  CalculateMonthGeneralType.monthHe: '月合',
  CalculateMonthGeneralType.middleQi: '中气',
  CalculateMonthGeneralType.chaoShen: '超神法',
};

const _$DayNightBoundaryTypeEnumMap = {
  DayNightBoundaryType.maoYou: '卯酉',
  DayNightBoundaryType.season4: '四季',
  DayNightBoundaryType.sunRiseSet: '日升落',
  DayNightBoundaryType.manual: '手动',
};

const _$GuiRenTypeEnumMap = {
  GuiRenType.Jia_Wu_Geng_Niu_Yang: '甲戊庚牛羊',
  GuiRenType.Jia_Wu_Jian_Niu_Yang: '甲戊兼牛羊',
  GuiRenType.Jia_Yang_Wu_Geng_Niu: '甲羊戊庚牛',
};

const _$EnumDayNightEnumMap = {
  EnumDayNight.day: '昼',
  EnumDayNight.night: '夜',
};
