// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shen_sha.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShenSha _$ShenShaFromJson(Map<String, dynamic> json) => ShenSha(
      json['name'] as String,
      $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      (json['descriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      (json['locationDescriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ShenShaToJson(ShenSha instance) => <String, dynamic>{
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
    };

const _$JiXiongEnumEnumMap = {
  JiXiongEnum.DA_JI: '大吉',
  JiXiongEnum.JI: '吉',
  JiXiongEnum.XIAO_JI: '小吉',
  JiXiongEnum.PING: '平',
  JiXiongEnum.XIAO_XIONG: '小凶',
  JiXiongEnum.XIONG: '凶',
  JiXiongEnum.DA_XIONG: '大凶',
  JiXiongEnum.WEI_ZHI: '未知',
};

ShenShaItem _$ShenShaItemFromJson(Map<String, dynamic> json) => ShenShaItem(
      name: json['name'] as String,
      jiXiong: $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
    )
      ..descriptionList = (json['descriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..locationDescriptionList =
          (json['locationDescriptionList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList();

Map<String, dynamic> _$ShenShaItemToJson(ShenShaItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
    };
