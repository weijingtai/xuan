// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divination_type_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DivinationTypeDataModel _$DivinationTypeDataModelFromJson(
        Map<String, dynamic> json) =>
    DivinationTypeDataModel(
      uuid: json['uuid'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdatedAt: json['lastUpdatedAt'] == null
          ? null
          : DateTime.parse(json['lastUpdatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      isCustomized: json['isCustomized'] as bool,
      isAvailable: json['isAvailable'] as bool,
    );

Map<String, dynamic> _$DivinationTypeDataModelToJson(
        DivinationTypeDataModel instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUpdatedAt': instance.lastUpdatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'name': instance.name,
      'description': instance.description,
      'isCustomized': instance.isCustomized,
      'isAvailable': instance.isAvailable,
    };
