import 'package:flutter/foundation.dart';

import '../enums/layout_template_enums.dart';

/// 模板预设配置
///
/// 定义常用模板的预设配置,用于快速应用到编辑器
/// 包含默认柱位列表、行显示配置等
@immutable
class TemplatePreset {
  const TemplatePreset({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultPillars,
    this.thumbnailAsset,
    this.defaultVisibleRows,
    this.category = TemplatePresetCategory.basic,
  });

  /// 预设唯一标识
  final String id;

  /// 预设名称（如"流年盘"）
  final String name;

  /// 预设描述（如"年月日时四柱"）
  final String description;

  /// 默认柱位列表（从左到右的顺序）
  final List<PillarType> defaultPillars;

  /// 缩略图资源路径（可选）
  final String? thumbnailAsset;

  /// 默认可见行配置（可选，如果为null则使用全局默认）
  final List<RowType>? defaultVisibleRows;

  /// 预设分类
  final TemplatePresetCategory category;

  TemplatePreset copyWith({
    String? id,
    String? name,
    String? description,
    List<PillarType>? defaultPillars,
    String? thumbnailAsset,
    List<RowType>? defaultVisibleRows,
    TemplatePresetCategory? category,
  }) {
    return TemplatePreset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      defaultPillars: defaultPillars ?? this.defaultPillars,
      thumbnailAsset: thumbnailAsset ?? this.thumbnailAsset,
      defaultVisibleRows: defaultVisibleRows ?? this.defaultVisibleRows,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TemplatePreset &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        listEquals(other.defaultPillars, defaultPillars) &&
        other.thumbnailAsset == thumbnailAsset &&
        listEquals(other.defaultVisibleRows, defaultVisibleRows) &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        Object.hashAll(defaultPillars),
        thumbnailAsset,
        defaultVisibleRows == null ? null : Object.hashAll(defaultVisibleRows!),
        category,
      );
}

/// 预设分类
enum TemplatePresetCategory {
  /// 基础模板（本命盘）
  basic,

  /// 运势模板（大运、流年等）
  fortune,

  /// 其他模板（胎元��命宫等）
  other,
}

/// 常用预设模板列表
class TemplatePresets {
  TemplatePresets._();

  /// 流年盘预设
  static const liuNianPan = TemplatePreset(
    id: 'preset_liu_nian_pan',
    name: '流年盘',
    description: '年月日时四柱',
    defaultPillars: [
      PillarType.year,
      PillarType.month,
      PillarType.day,
      PillarType.hour,
    ],
    defaultVisibleRows: [
      RowType.heavenlyStem,
      RowType.earthlyBranch,
      RowType.tenGod,
      RowType.naYin,
    ],
    category: TemplatePresetCategory.basic,
  );

  /// 大运盘预设
  static const daYunPan = TemplatePreset(
    id: 'preset_da_yun_pan',
    name: '大运盘',
    description: '含大运流年',
    defaultPillars: [
      PillarType.year,
      PillarType.month,
      PillarType.day,
      PillarType.hour,
      PillarType.luckCycle,
      PillarType.annual,
    ],
    defaultVisibleRows: [
      RowType.heavenlyStem,
      RowType.earthlyBranch,
      RowType.tenGod,
      RowType.hiddenStems,
    ],
    category: TemplatePresetCategory.fortune,
  );

  /// 胎元分析预设
  static const taiYuanFenXi = TemplatePreset(
    id: 'preset_tai_yuan_fen_xi',
    name: '胎元分析',
    description: '含胎元命宫',
    defaultPillars: [
      PillarType.year,
      PillarType.month,
      PillarType.day,
      PillarType.hour,
      PillarType.taiMeta,
      PillarType.lifeHouse,
    ],
    defaultVisibleRows: [
      RowType.heavenlyStem,
      RowType.earthlyBranch,
      RowType.tenGod,
      RowType.naYin,
      RowType.kongWang,
    ],
    category: TemplatePresetCategory.other,
  );

  /// 完整命盘预设
  static const wanZhengMingPan = TemplatePreset(
    id: 'preset_wan_zheng_ming_pan',
    name: '完整命盘',
    description: '四柱+胎元+大运',
    defaultPillars: [
      PillarType.year,
      PillarType.month,
      PillarType.day,
      PillarType.hour,
      PillarType.taiMeta,
      PillarType.lifeHouse,
      PillarType.luckCycle,
    ],
    defaultVisibleRows: [
      RowType.heavenlyStem,
      RowType.earthlyBranch,
      RowType.tenGod,
      RowType.hiddenStems,
      RowType.hiddenStemsTenGod,
      RowType.naYin,
      RowType.kongWang,
      RowType.xunShou,
    ],
    category: TemplatePresetCategory.basic,
  );

  /// 流月流日盘预设
  static const liuYueLiuRiPan = TemplatePreset(
    id: 'preset_liu_yue_liu_ri_pan',
    name: '流月流日盘',
    description: '本命+流年月日',
    defaultPillars: [
      PillarType.year,
      PillarType.month,
      PillarType.day,
      PillarType.hour,
      PillarType.annual,
      PillarType.monthly,
      PillarType.daily,
    ],
    defaultVisibleRows: [
      RowType.heavenlyStem,
      RowType.earthlyBranch,
      RowType.tenGod,
      RowType.hiddenStems,
    ],
    category: TemplatePresetCategory.fortune,
  );

  /// 所有预设模板列表
  static const List<TemplatePreset> allPresets = [
    liuNianPan,
    daYunPan,
    taiYuanFenXi,
    wanZhengMingPan,
    liuYueLiuRiPan,
  ];

  /// 根据ID获取预设
  static TemplatePreset? getById(String id) {
    try {
      return allPresets.firstWhere((preset) => preset.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 根据分类获取预设列表
  static List<TemplatePreset> getByCategory(TemplatePresetCategory category) {
    return allPresets.where((preset) => preset.category == category).toList();
  }
}
