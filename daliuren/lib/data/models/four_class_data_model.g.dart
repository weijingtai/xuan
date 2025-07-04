// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'four_class_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FourClassDataModel _$FourClassDataModelFromJson(Map<String, dynamic> json) =>
    FourClassDataModel(
      first: EachClassDataModel.fromJson(json['first'] as Map<String, dynamic>),
      firstClassDayGan: FourClassDataModel._tianGanFromJson(
          json['firstClassDayGan'] as String),
      second:
          EachClassDataModel.fromJson(json['second'] as Map<String, dynamic>),
      third: EachClassDataModel.fromJson(json['third'] as Map<String, dynamic>),
      fourth:
          EachClassDataModel.fromJson(json['fourth'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FourClassDataModelToJson(FourClassDataModel instance) =>
    <String, dynamic>{
      'first': instance.first.toJson(),
      'firstClassDayGan':
          FourClassDataModel._tianGanToJson(instance.firstClassDayGan),
      'second': instance.second.toJson(),
      'third': instance.third.toJson(),
      'fourth': instance.fourth.toJson(),
    };
