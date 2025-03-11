// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_person_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BirthTime _$BirthTimeFromJson(Map<String, dynamic> json) => BirthTime(
      type: $enumDecode(_$DateTimeTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isLeapMonth: json['isLeapMonth'] as bool,
    );

Map<String, dynamic> _$BirthTimeToJson(BirthTime instance) => <String, dynamic>{
      'type': _$DateTimeTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'isLeapMonth': instance.isLeapMonth,
    };

const _$DateTimeTypeEnumMap = {
  DateTimeType.solar: 'solar',
  DateTimeType.lunar: 'lunar',
};

Coordinates _$CoordinatesFromJson(Map<String, dynamic> json) => Coordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$CoordinatesToJson(Coordinates instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      province: GeoLocation.fromJson(json['province'] as Map<String, dynamic>),
      city: GeoLocation.fromJson(json['city'] as Map<String, dynamic>),
      timezone: json['timezone'] as String,
      area: json['area'] == null
          ? null
          : GeoLocation.fromJson(json['area'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'province': instance.province,
      'city': instance.city,
      'area': instance.area,
      'timezone': instance.timezone,
    };

BaZi _$BaZiFromJson(Map<String, dynamic> json) => BaZi(
      year: $enumDecode(_$JiaZiEnumMap, json['year']),
      month: $enumDecode(_$JiaZiEnumMap, json['month']),
      day: $enumDecode(_$JiaZiEnumMap, json['day']),
      hour: $enumDecode(_$JiaZiEnumMap, json['hour']),
    );

Map<String, dynamic> _$BaZiToJson(BaZi instance) => <String, dynamic>{
      'year': _$JiaZiEnumMap[instance.year]!,
      'month': _$JiaZiEnumMap[instance.month]!,
      'day': _$JiaZiEnumMap[instance.day]!,
      'hour': _$JiaZiEnumMap[instance.hour]!,
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

BasicPersonInfo _$BasicPersonInfoFromJson(Map<String, dynamic> json) =>
    BasicPersonInfo(
      name: json['name'] as String?,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      birthTime: DateTime.parse(json['birthTime'] as String),
      birthLocation:
          Location.fromJson(json['birthLocation'] as Map<String, dynamic>),
      trueSolarTime: DateTime.parse(json['trueSolarTime'] as String),
      bazi: BaZi.fromJson(json['bazi'] as Map<String, dynamic>),
      hasDaylightSaving: json['hasDaylightSaving'] as bool,
      isTrueSolarTime: json['isTrueSolarTime'] as bool,
    );

Map<String, dynamic> _$BasicPersonInfoToJson(BasicPersonInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'gender': _$GenderEnumMap[instance.gender]!,
      'birthTime': instance.birthTime.toIso8601String(),
      'birthLocation': instance.birthLocation,
      'trueSolarTime': instance.trueSolarTime.toIso8601String(),
      'bazi': instance.bazi,
      'hasDaylightSaving': instance.hasDaylightSaving,
      'isTrueSolarTime': instance.isTrueSolarTime,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.unknown: 'unknown',
};
