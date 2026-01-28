// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drag_payloads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TitleRowPayload _$TitleRowPayloadFromJson(Map<String, dynamic> json) =>
    TitleRowPayload(
      uuid: json['uuid'] as String,
    );

Map<String, dynamic> _$TitleRowPayloadToJson(TitleRowPayload instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
    };

TitleColumnPayload _$TitleColumnPayloadFromJson(Map<String, dynamic> json) =>
    TitleColumnPayload(
      uuid: json['uuid'] as String,
    );

Map<String, dynamic> _$TitleColumnPayloadToJson(TitleColumnPayload instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
    };

ColumnHeaderRowPayload _$ColumnHeaderRowPayloadFromJson(
        Map<String, dynamic> json) =>
    ColumnHeaderRowPayload(
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      uuid: json['uuid'] as String,
    );

Map<String, dynamic> _$ColumnHeaderRowPayloadToJson(
        ColumnHeaderRowPayload instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'gender': _$GenderEnumMap[instance.gender]!,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.unknown: 'unknown',
};

CardPayload _$CardPayloadFromJson(Map<String, dynamic> json) => CardPayload(
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      pillarMap: (json['pillarMap'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, PillarPayload.fromJson(e as Map<String, dynamic>)),
      ),
      pillarOrderUuid: (json['pillarOrderUuid'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      rowMap: (json['rowMap'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, RowPayload.fromJson(e as Map<String, dynamic>)),
      ),
      rowOrderUuid: (json['rowOrderUuid'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CardPayloadToJson(CardPayload instance) =>
    <String, dynamic>{
      'pillarOrderUuid': instance.pillarOrderUuid,
      'rowOrderUuid': instance.rowOrderUuid,
      'rowMap': instance.rowMap,
      'pillarMap': instance.pillarMap,
      'gender': _$GenderEnumMap[instance.gender]!,
    };

PillarPayload _$PillarPayloadFromJson(Map<String, dynamic> json) =>
    PillarPayload(
      uuid: json['uuid'] as String,
      pillarType: $enumDecode(_$PillarTypeEnumMap, json['pillarType']),
      pillarLabel: json['pillarLabel'] as String?,
    );

Map<String, dynamic> _$PillarPayloadToJson(PillarPayload instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'pillarType': _$PillarTypeEnumMap[instance.pillarType]!,
      'pillarLabel': instance.pillarLabel,
    };

const _$PillarTypeEnumMap = {
  PillarType.year: 'year',
  PillarType.month: 'month',
  PillarType.day: 'day',
  PillarType.hour: 'time',
  PillarType.ke: 'ke',
  PillarType.taiMeta: 'tai_meta',
  PillarType.taiMonth: 'tai_month',
  PillarType.taiDay: 'tai_day',
  PillarType.bodyHouse: 'body_house',
  PillarType.lifeHouse: '命宫',
  PillarType.luckCycle: 'luck_cycle',
  PillarType.annual: 'annual',
  PillarType.monthly: 'monthly',
  PillarType.daily: 'daily',
  PillarType.hourly: 'hourly',
  PillarType.kely: 'kely',
  PillarType.separator: 'separator',
  PillarType.rowTitleColumn: 'row_title_column',
};

RowPayload _$RowPayloadFromJson(Map<String, dynamic> json) => RowPayload(
      rowType: $enumDecode(_$RowTypeEnumMap, json['rowType']),
      uuid: json['uuid'] as String,
    );

Map<String, dynamic> _$RowPayloadToJson(RowPayload instance) =>
    <String, dynamic>{
      'rowType': _$RowTypeEnumMap[instance.rowType]!,
      'uuid': instance.uuid,
    };

const _$RowTypeEnumMap = {
  RowType.columnHeaderRow: 'column_header_row',
  RowType.heavenlyStem: 'heavenly_stem_row',
  RowType.earthlyBranch: 'earthly_branch_row',
  RowType.tenGod: 'ten_god_row',
  RowType.naYin: 'na_yin_row',
  RowType.kongWang: 'kong_wang_row',
  RowType.gu: 'gu_row',
  RowType.xu: 'xu_row',
  RowType.xunShou: 'xun_shou_row',
  RowType.yiMa: 'yi_ma_row',
  RowType.hiddenStems: 'hidden_stems_row',
  RowType.hiddenStemsTenGod: 'hidden_stems_ten_god_row',
  RowType.hiddenStemsPrimary: 'hidden_stems_primary_row',
  RowType.hiddenStemsSecondary: 'hidden_stems_secondary_row',
  RowType.hiddenStemsTertiary: 'hidden_stems_tertiary_row',
  RowType.hiddenStemsPrimaryGods: 'hidden_stems_primary_gods_row',
  RowType.hiddenStemsSecondaryGods: 'hidden_stems_secondary_gods_row',
  RowType.hiddenStemsTertiaryGods: 'hidden_stems_tertiary_gods_row',
  RowType.starYun: 'star_yun_row',
  RowType.selfSiting: 'self_siting_row',
  RowType.separator: 'separator_row',
};

RowSeparatorPayload _$RowSeparatorPayloadFromJson(Map<String, dynamic> json) =>
    RowSeparatorPayload(
      uuid: json['uuid'] as String,
    );

Map<String, dynamic> _$RowSeparatorPayloadToJson(
        RowSeparatorPayload instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
    };

TextRowPayload _$TextRowPayloadFromJson(Map<String, dynamic> json) =>
    TextRowPayload(
      rowType: $enumDecode(_$RowTypeEnumMap, json['rowType']),
      uuid: json['uuid'] as String,
      titleInCell: json['titleInCell'] as bool,
      rowLabel: json['rowLabel'] as String?,
      tenGodLabelType: json['tenGodLabelType'] as String? ?? 'name',
    );

Map<String, dynamic> _$TextRowPayloadToJson(TextRowPayload instance) =>
    <String, dynamic>{
      'rowType': _$RowTypeEnumMap[instance.rowType]!,
      'uuid': instance.uuid,
      'rowLabel': instance.rowLabel,
      'titleInCell': instance.titleInCell,
      'tenGodLabelType': instance.tenGodLabelType,
    };

SeparatorPillarPayload _$SeparatorPillarPayloadFromJson(
        Map<String, dynamic> json) =>
    SeparatorPillarPayload(
      uuid: json['uuid'] as String,
    );

Map<String, dynamic> _$SeparatorPillarPayloadToJson(
        SeparatorPillarPayload instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
    };

ContentPillarPayload _$ContentPillarPayloadFromJson(
        Map<String, dynamic> json) =>
    ContentPillarPayload(
      uuid: json['uuid'] as String,
      pillarType: $enumDecode(_$PillarTypeEnumMap, json['pillarType']),
      pillarLabel: json['pillarLabel'] as String?,
      pillarContent:
          PillarContent.fromJson(json['pillarContent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContentPillarPayloadToJson(
        ContentPillarPayload instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'pillarType': _$PillarTypeEnumMap[instance.pillarType]!,
      'pillarLabel': instance.pillarLabel,
      'pillarContent': instance.pillarContent,
    };

RowTitleColumnPayload _$RowTitleColumnPayloadFromJson(
        Map<String, dynamic> json) =>
    RowTitleColumnPayload(
      uuid: json['uuid'] as String,
    );

Map<String, dynamic> _$RowTitleColumnPayloadToJson(
        RowTitleColumnPayload instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
    };
