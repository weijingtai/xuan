// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qi_zhen_pan_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QiZhenPanDataModel _$QiZhenPanDataModelFromJson(Map<String, dynamic> json) =>
    QiZhenPanDataModel(
      uuid: json['uuid'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      panelDataJson: json['panelDataJson'] as String,
      panelConfigJson: json['panelConfigJson'] as String,
      observerPositionJson: json['observerPositionJson'] as String,
      divinationUuid: json['divinationUuid'] as String?,
      seekerUuid: json['seekerUuid'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$QiZhenPanDataModelToJson(QiZhenPanDataModel instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUpdatedAt': instance.lastUpdatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'panelDataJson': instance.panelDataJson,
      'panelConfigJson': instance.panelConfigJson,
      'observerPositionJson': instance.observerPositionJson,
      'divinationUuid': instance.divinationUuid,
      'seekerUuid': instance.seekerUuid,
      'title': instance.title,
    };
