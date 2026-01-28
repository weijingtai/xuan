// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'row_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RowData _$RowDataFromJson(Map<String, dynamic> json) => RowData(
      rowId: json['rowId'] as String,
      rowType: $enumDecode(_$RowTypeEnumMap, json['rowType']),
      label: json['label'] as String,
    );

Map<String, dynamic> _$RowDataToJson(RowData instance) => <String, dynamic>{
      'rowId': instance.rowId,
      'rowType': _$RowTypeEnumMap[instance.rowType]!,
      'label': instance.label,
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
