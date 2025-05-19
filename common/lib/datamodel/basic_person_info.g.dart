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
  DateTimeType.ganZhi: 'ganZhi',
};

BasicPersonInfo _$BasicPersonInfoFromJson(Map<String, dynamic> json) =>
    BasicPersonInfo(
      name: json['name'] as String?,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      birthTime: DateTime.parse(json['birthTime'] as String),
      birthLocation:
          Address.fromJson(json['birthLocation'] as Map<String, dynamic>),
      trueSolarTime: DateTime.parse(json['trueSolarTime'] as String),
      bazi: EightChars.fromJson(json['bazi'] as Map<String, dynamic>),
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
