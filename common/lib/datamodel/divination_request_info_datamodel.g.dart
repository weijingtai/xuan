// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divination_request_info_datamodel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DivinationRequestInfoDataModel _$DivinationRequestInfoDataModelFromJson(
        Map<String, dynamic> json) =>
    DivinationRequestInfoDataModel(
      uuid: json['uuid'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdatedAt: json['lastUpdatedAt'] == null
          ? null
          : DateTime.parse(json['lastUpdatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      divinationTypeUuid: json['divinationTypeUuid'] as String,
      fateYear: json['fateYear'] as String?,
      question: json['question'] as String?,
      detail: json['detail'] as String?,
      ownerSeekerUuid: json['ownerSeekerUuid'] as String?,
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      seekerName: json['seekerName'] as String?,
      tinyPredict: json['tinyPredict'] as String?,
      directlyPredict: json['directlyPredict'] as String?,
    );

Map<String, dynamic> _$DivinationRequestInfoDataModelToJson(
        DivinationRequestInfoDataModel instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUpdatedAt': instance.lastUpdatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'divinationTypeUuid': instance.divinationTypeUuid,
      'fateYear': instance.fateYear,
      'question': instance.question,
      'detail': instance.detail,
      'ownerSeekerUuid': instance.ownerSeekerUuid,
      'gender': _$GenderEnumMap[instance.gender],
      'seekerName': instance.seekerName,
      'tinyPredict': instance.tinyPredict,
      'directlyPredict': instance.directlyPredict,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.unknown: 'unknown',
};
