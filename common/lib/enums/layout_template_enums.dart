import 'package:json_annotation/json_annotation.dart';

import '../models/pillar_content.dart';

enum PillarType {
  @JsonValue('year')
  year('年'),
  @JsonValue('month')
  month('月'),
  @JsonValue('day')
  day('日'),
  @JsonValue('time')
  hour('时'),
  @JsonValue("ke")
  ke('刻'),

  @JsonValue('tai_meta')
  taiMeta('胎元'),
  @JsonValue('tai_month')
  taiMonth('胎月'),
  @JsonValue('tai_day')
  taiDay('胎日'),
  @JsonValue('body_house')
  bodyHouse('身宫'),
  @JsonValue("命宫")
  lifeHouse('命宫'),

  @JsonValue('luck_cycle')
  luckCycle('大运'),
  @JsonValue('annual')
  annual('流年'),
  @JsonValue('monthly')
  monthly('流月'),
  @JsonValue('daily')
  daily('流日'),
  @JsonValue("hourly")
  hourly("流时"),
  @JsonValue('kely')
  kely('流刻'),

  @JsonValue('separator')
  separator('ui分割线'),
  @JsonValue('row_title_column')
  rowTitleColumn('行标题列');

  final String name;
  const PillarType(this.name);
}

enum RowType {
  @JsonValue('column_header_row')
  columnHeaderRow, // 列标题行
  @JsonValue('heavenly_stem_row')
  heavenlyStem, // 天干
  @JsonValue('earthly_branch_row')
  earthlyBranch, // 地支
  @JsonValue('ten_god_row')
  tenGod, // 十神
  @JsonValue('na_yin_row')
  naYin, // 纳音
  @JsonValue('kong_wang_row')
  kongWang, // 空亡
  @JsonValue('gu_row')
  gu, // 孤（旬空）
  @JsonValue('xu_row')
  xu, // 虚（孤位对冲）
  @JsonValue('xun_shou_row')
  xunShou, // 旬首
  @JsonValue('yi_ma_row')
  yiMa, // 驿马
  @JsonValue('hidden_stems_row')
  hiddenStems, // 藏干
  @JsonValue('hidden_stems_ten_god_row')
  hiddenStemsTenGod, // 藏干十神
  @JsonValue('hidden_stems_primary_row')
  hiddenStemsPrimary, // 藏干主气
  @JsonValue('hidden_stems_secondary_row')
  hiddenStemsSecondary, // 藏干中气
  @JsonValue('hidden_stems_tertiary_row')
  hiddenStemsTertiary, // 藏干余气
  @JsonValue('hidden_stems_primary_gods_row')
  hiddenStemsPrimaryGods, // 藏干主气 十神
  @JsonValue('hidden_stems_secondary_gods_row')
  hiddenStemsSecondaryGods, // 藏干中气 十神
  @JsonValue('hidden_stems_tertiary_gods_row')
  hiddenStemsTertiaryGods, // 藏干余气 十神
  @JsonValue('star_yun_row')
  starYun, // 星运
  @JsonValue('self_siting_row')
  selfSiting, // 自坐
  /// UI 分隔行：仅用于渲染水平分割线，不包含数据内容
  @JsonValue('separator_row')
  separator;
}

enum BorderType { solid, dashed, dotted, none }

enum RowTextAlign { left, center, right }
