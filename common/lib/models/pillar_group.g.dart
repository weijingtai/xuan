// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pillar_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PillarGroup _$PillarGroupFromJson(Map<String, dynamic> json) => PillarGroup(
      id: json['id'] as String?,
      title: json['title'] as String,
      pillars: (json['pillars'] as List<dynamic>)
          .map((e) => PillarData.fromJson(e as Map<String, dynamic>))
          .toList(),
      isBenMing: json['isBenMing'] as bool? ?? false,
      rowOrder: (json['rowOrder'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      pillarOrder: (json['pillarOrder'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PillarGroupToJson(PillarGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'pillars': instance.pillars.map((e) => e.toJson()).toList(),
      'isBenMing': instance.isBenMing,
      'rowOrder': instance.rowOrder,
      'pillarOrder': instance.pillarOrder,
    };
