// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_divination_type_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubDivinationTypeDataModel _$SubDivinationTypeDataModelFromJson(
        Map<String, dynamic> json) =>
    SubDivinationTypeDataModel(
      uuid: json['uuid'] as String,
      lastUpdatedAt: json['lastUpdatedAt'] == null
          ? null
          : DateTime.parse(json['lastUpdatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      hiddenAt: json['hiddenAt'] == null
          ? null
          : DateTime.parse(json['hiddenAt'] as String),
      name: json['name'] as String,
      isCustomized: json['isCustomized'] as bool,
      isAvailable: json['isAvailable'] as bool,
    );

Map<String, dynamic> _$SubDivinationTypeDataModelToJson(
        SubDivinationTypeDataModel instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'lastUpdatedAt': instance.lastUpdatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'hiddenAt': instance.hiddenAt?.toIso8601String(),
      'name': instance.name,
      'isCustomized': instance.isCustomized,
      'isAvailable': instance.isAvailable,
    };
