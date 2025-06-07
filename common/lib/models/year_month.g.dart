// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'year_month.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YearMonth _$YearMonthFromJson(Map<String, dynamic> json) => YearMonth(
      (json['year'] as num).toInt(),
      (json['month'] as num).toInt(),
      (json['day'] as num?)?.toInt(),
    );

Map<String, dynamic> _$YearMonthToJson(YearMonth instance) => <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'day': instance.day,
    };
