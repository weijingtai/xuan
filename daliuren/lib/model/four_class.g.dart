// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'four_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
      'first': instance.first,
      'second': instance.second,
      'third': instance.third,
      'fourth': instance.fourth,
      'sameSkyGroundClassList': instance.sameSkyGroundClassList,
    };
