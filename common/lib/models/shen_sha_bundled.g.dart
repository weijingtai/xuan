// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shen_sha_bundled.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BundledShenSha _$BundledShenShaFromJson(Map<String, dynamic> json) =>
    BundledShenSha(
      $enumDecode(_$BundledShenShaTypeEnumMap, json['type']),
      json['name'] as String,
      $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      (json['offset'] as num).toInt(),
      (json['descriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      (json['locationDescriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$BundledShenShaToJson(BundledShenSha instance) =>
    <String, dynamic>{
      'type': _$BundledShenShaTypeEnumMap[instance.type]!,
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
      'offset': instance.offset,
    };

const _$BundledShenShaTypeEnumMap = {
  BundledShenShaType.beforeJia: '驾前',
  BundledShenShaType.afterJia: '驾后',
  BundledShenShaType.beforeHorse: '马前',
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

OtherShenSha _$OtherShenShaFromJson(Map<String, dynamic> json) => OtherShenSha(
      json['name'] as String,
      $enumDecode(_$JiXiongEnumEnumMap, json['jiXiong']),
      (json['descriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      (json['locationDescriptionList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$OtherShenShaToJson(OtherShenSha instance) =>
    <String, dynamic>{
      'name': instance.name,
      'jiXiong': _$JiXiongEnumEnumMap[instance.jiXiong]!,
    };
