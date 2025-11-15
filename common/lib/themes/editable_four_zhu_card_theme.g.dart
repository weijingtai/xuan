// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editable_four_zhu_card_theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PillarSection _$PillarSectionFromJson(Map<String, dynamic> json) =>
    PillarSection(
      global:
          PillarStyleConfig.fromJson(json['global'] as Map<String, dynamic>),
      mapper: (json['mapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$PillarTypeEnumMap, k),
            PillarStyleConfig.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$PillarSectionToJson(PillarSection instance) =>
    <String, dynamic>{
      'global': instance.global,
      'mapper':
          instance.mapper.map((k, e) => MapEntry(_$PillarTypeEnumMap[k]!, e)),
    };

const _$PillarTypeEnumMap = {
  PillarType.year: 'year',
  PillarType.month: 'month',
  PillarType.day: 'day',
  PillarType.hour: 'hour',
  PillarType.ke: 'ke',
  PillarType.taiMeta: 'taiMeta',
  PillarType.taiMonth: 'taiMonth',
  PillarType.taiDay: 'taiDay',
  PillarType.lifeHouse: 'lifeHouse',
  PillarType.luckCycle: 'luckCycle',
  PillarType.annual: 'annual',
  PillarType.monthly: 'monthly',
  PillarType.daily: 'daily',
  PillarType.hourly: 'hourly',
  PillarType.separator: 'separator',
  PillarType.rowTitleColumn: 'rowTitleColumn',
};
