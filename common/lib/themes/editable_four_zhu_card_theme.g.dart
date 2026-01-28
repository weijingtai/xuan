// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editable_four_zhu_card_theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditableFourZhuCardTheme _$EditableFourZhuCardThemeFromJson(
        Map<String, dynamic> json) =>
    EditableFourZhuCardTheme(
      displayHeaderRow: json['displayHeaderRow'] as bool,
      displayRowTitleColumn: json['displayRowTitleColumn'] as bool,
      card: CardStyleConfig.fromJson(json['card'] as Map<String, dynamic>),
      pillar: PillarSection.fromJson(json['pillar'] as Map<String, dynamic>),
      cell: CellSection.fromJson(json['cell'] as Map<String, dynamic>),
      typography: TypographySection.fromJson(
          json['typography'] as Map<String, dynamic>),
      displayCellTitle: json['displayCellTitle'] as bool,
    );

Map<String, dynamic> _$EditableFourZhuCardThemeToJson(
        EditableFourZhuCardTheme instance) =>
    <String, dynamic>{
      'displayHeaderRow': instance.displayHeaderRow,
      'displayRowTitleColumn': instance.displayRowTitleColumn,
      'displayCellTitle': instance.displayCellTitle,
      'card': instance.card.toJson(),
      'pillar': instance.pillar.toJson(),
      'cell': instance.cell.toJson(),
      'typography': instance.typography.toJson(),
    };

PillarSection _$PillarSectionFromJson(Map<String, dynamic> json) =>
    PillarSection(
      global:
          PillarStyleConfig.fromJson(json['global'] as Map<String, dynamic>),
      mapper: (json['mapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$PillarTypeEnumMap, k),
            PillarStyleConfig.fromJson(e as Map<String, dynamic>)),
      ),
      defaultSeparatorConfig: PillarStyleConfig.fromJson(
          json['defaultSeparatorConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PillarSectionToJson(PillarSection instance) =>
    <String, dynamic>{
      'global': instance.global,
      'mapper':
          instance.mapper.map((k, e) => MapEntry(_$PillarTypeEnumMap[k]!, e)),
      'defaultSeparatorConfig': instance.defaultSeparatorConfig,
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

CellSection _$CellSectionFromJson(Map<String, dynamic> json) => CellSection(
      pillarTitleCellConfig: CellStyleConfig.fromJson(
          json['pillarTitleCellConfig'] as Map<String, dynamic>),
      rowTitleCellConfig: CellStyleConfig.fromJson(
          json['rowTitleCellConfig'] as Map<String, dynamic>),
      globalCellConfig: CellStyleConfig.fromJson(
          json['globalCellConfig'] as Map<String, dynamic>),
      rowTypeCellConfigMapper:
          (json['rowTypeCellConfigMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$RowTypeEnumMap, k),
            CellStyleConfig.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$CellSectionToJson(CellSection instance) =>
    <String, dynamic>{
      'pillarTitleCellConfig': instance.pillarTitleCellConfig,
      'rowTitleCellConfig': instance.rowTitleCellConfig,
      'globalCellConfig': instance.globalCellConfig,
      'rowTypeCellConfigMapper': instance.rowTypeCellConfigMapper
          .map((k, e) => MapEntry(_$RowTypeEnumMap[k]!, e)),
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

TypographySection _$TypographySectionFromJson(Map<String, dynamic> json) =>
    TypographySection(
      globalContent: TextStyleConfig.fromJson(
          json['globalContent'] as Map<String, dynamic>),
      globalTitle:
          TextStyleConfig.fromJson(json['globalTitle'] as Map<String, dynamic>),
      globalCellTitle: TextStyleConfig.fromJson(
          json['globalCellTitle'] as Map<String, dynamic>),
      rowTitle:
          TextStyleConfig.fromJson(json['rowTitle'] as Map<String, dynamic>),
      pillarTitle:
          TextStyleConfig.fromJson(json['pillarTitle'] as Map<String, dynamic>),
      cellContentMapper:
          (json['cellContentMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$RowTypeEnumMap, k),
            TextStyleConfig.fromJson(e as Map<String, dynamic>)),
      ),
      cellTitleMapper: (json['cellTitleMapper'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$RowTypeEnumMap, k),
            TextStyleConfig.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$TypographySectionToJson(TypographySection instance) =>
    <String, dynamic>{
      'globalContent': instance.globalContent,
      'globalTitle': instance.globalTitle,
      'rowTitle': instance.rowTitle,
      'pillarTitle': instance.pillarTitle,
      'globalCellTitle': instance.globalCellTitle,
      'cellContentMapper': instance.cellContentMapper
          .map((k, e) => MapEntry(_$RowTypeEnumMap[k]!, e)),
      'cellTitleMapper': instance.cellTitleMapper
          .map((k, e) => MapEntry(_$RowTypeEnumMap[k]!, e)),
    };
