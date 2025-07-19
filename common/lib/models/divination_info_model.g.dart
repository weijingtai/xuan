// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divination_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DivinationInfoModel _$DivinationInfoModelFromJson(Map<String, dynamic> json) =>
    DivinationInfoModel(
      divination: DivinationRequestInfoDataModel.fromJson(
          json['divination'] as Map<String, dynamic>),
      divinationDatetime: DatatimeDivinationDetailsDataModel.fromJson(
          json['divinationDatetime'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DivinationInfoModelToJson(
        DivinationInfoModel instance) =>
    <String, dynamic>{
      'divination': instance.divination,
      'divinationDatetime': instance.divinationDatetime,
    };
