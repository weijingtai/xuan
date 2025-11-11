import 'package:common/models/text_style_config.dart';
import 'package:flutter/material.dart';
import '../enums/layout_template_enums.dart';
import '../enums/enum_gender.dart';
import 'pillar_styles.dart';
import 'pillar_content.dart';
import 'row_strategy.dart';

/// Payload representing a draggable title item for either columns or rows.
/// Used when the UI allows reordering titles directly without dragging full cells.
/// Title row payload: a special row payload used when dragging row titles.
///
/// 语义：作为“标题行”的拖拽载荷，但继承 `RowInfoPayload`，以便与现有行插入/重排逻辑对齐。
/// 注意：该载荷仅用于标题行的排序，不代表插入新的数据行。
class TitleRowPayload extends RowInfoPayload {
  /// Creates a title row payload for drag interactions.
  ///
  /// Parameters:
  /// - [rowType]: The associated `RowType` of the title row（如天干/地支）。
  /// - [titleLabel]: Optional display label for the title row（如“天干”）。
  TitleRowPayload({
    required RowType rowType,
    String? titleLabel,
  }) : super(
          rowType: rowType,
          rowLabel: titleLabel,
          config: TextStyleConfig(
            colorMapperDataModel: ColorMapperDataModel(
              pureLightMapper: {
                "乾造": Colors.black87,
                "坤造": Colors.black87,
              },
              colorfulLightMapper: {
                "乾造": Colors.black87,
                "坤造": Colors.black87,
              },
              pureDarkMapper: {
                "乾造": Colors.white,
                "坤造": Colors.white,
              },
              colorfulDarkMapper: {
                "乾造": Colors.white,
                "坤造": Colors.white,
              },
            ),
            textShadowDataModel: TextShadowDataModel(),
            fontStyleDataModel: FontStyleDataModel(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'NotoSansSC',
            ),
          ),
        );
}

/// Title column payload: a special pillar payload used when dragging column titles.
///
/// 语义：作为“标题列”的拖拽载荷，但继承 `PillarPayload`，以便与现有列插入/重排逻辑对齐。
/// 注意：该载荷仅用于标题列的排序，不代表插入新的数据列。
class TitleColumnPayload extends PillarPayload {
  /// Creates a title column payload for drag interactions.
  ///
  /// Parameters:
  /// - [pillarType]: The associated `PillarType` of the title column（如年/月/日/时）。
  /// - [titleLabel]: Optional display label for the title column（如“年”）。
  const TitleColumnPayload({
    required PillarType pillarType,
    String? titleLabel,
  }) : super(pillarType: pillarType, pillarLabel: titleLabel);
}

/// Row title column payload: represents the special column containing row titles.
///
/// 语义：行标题列作为一个特殊的"柱"，包含所有行的标题文本。
/// 特点：
/// - 每个单元格的内容不同（根据行类型显示不同的标题）
/// - 可以与普通柱（年月日时）互换位置
/// - 左上角单元格显示性别标识（乾造/坤造）
class RowTitleColumnPayload extends PillarPayload {
  /// Creates a row title column payload.
  ///
  /// Parameters:
  /// - [width]: Optional custom width for the row title column.
  const RowTitleColumnPayload({
    double? width,
  }) : super(
          pillarType: PillarType.rowTitleColumn,
          pillarLabel: '行标题',
          columnWidth: width,
        );
}

/// Column header row payload: represents the special row containing column titles and gender.
///
/// 语义：表头行作为一个特殊的"行"，包含性别标识和所有列的标题文本。
/// 特点：
/// - 每个单元格的内容不同（左上角是性别，其他是列标题）
/// - 可以与普通行（天干/地支/纳音）互换位置
/// - 性别标识随表头行移动
class ColumnHeaderRowPayload extends RowInfoPayload {
  /// Creates a column header row payload.
  ///
  /// Parameters:
  /// - [gender]: Gender for the chart (male = 乾造, female = 坤造).
  /// - [height]: Optional custom height for the header row.
  ColumnHeaderRowPayload({
    required this.gender,
    double? height,
  }) : super(
          config: TextStyleConfig(
            colorMapperDataModel: ColorMapperDataModel(
              pureLightMapper: {
                "乾造": Colors.black87,
                "坤造": Colors.black87,
              },
              colorfulLightMapper: {
                "乾造": Colors.black87,
                "坤造": Colors.black87,
              },
              pureDarkMapper: {
                "乾造": Colors.white,
                "坤造": Colors.white,
              },
              colorfulDarkMapper: {
                "乾造": Colors.white,
                "坤造": Colors.white,
              },
            ),
            textShadowDataModel: TextShadowDataModel(),
            fontStyleDataModel: FontStyleDataModel(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'NotoSansSC',
            ),
          ),
          rowType: RowType.columnHeaderRow,
          rowLabel: null, // Label will be derived from gender
          rowHeight: height,
        );

  /// Gender identifier to display in the left-top corner cell.
  final Gender gender;

  /// Get the gender label text.
  String get genderLabel => gender == Gender.male ? '乾造' : '坤造';
}

/// Payload for dragging a pillar (column) into a card.
class PillarPayload {
  const PillarPayload({
    required this.pillarType,
    this.pillarLabel,
    this.perRowValues = const {},
    this.columnWidth,
    this.columnMargin,
    this.placeholderStyle,
    this.textAlign,
    this.orderIndex,
    this.pillarContent,
  });

  /// The type of pillar to insert (e.g., PillarType.luckCycle for 大运).
  final PillarType pillarType;

  /// Optional custom label to display for the inserted pillar.
  final String? pillarLabel;

  /// Optional overrides for each row in this pillar.
  /// For example: {RowType.heavenlyStem: '乙', RowType.earthlyBranch: '亥'}
  final Map<RowType, String> perRowValues;

  /// Optional explicit column width for UI rendering during external drag.
  /// If provided, UI can use this width to size the ghost column.
  final double? columnWidth;

  /// Optional per-column margin override for UI decoration.
  /// When provided, this overrides the global `pillarMargin` for this pillar.
  final EdgeInsets? columnMargin;

  /// Optional placeholder style for drag-and-drop feedback.
  final PillarPlaceholderStyle? placeholderStyle;

  /// Optional text alignment for pillar label/content.
  final RowTextAlign? textAlign;

  /// Optional UI insertion order within a container.
  /// When provided, the UI may use this value to place the pillar.
  final int? orderIndex;

  /// Optional embedded core data for this pillar.
  /// When provided, row strategies and other modules can consume
  /// `PillarContent` directly without additional lookups.
  final PillarContent? pillarContent;

  /// Returns a new `PillarPayload` with selected fields updated.
  ///
  /// Parameters:
  /// - [pillarType]: New pillar type if changing semantic。
  /// - [pillarLabel]: New display label for the pillar。
  /// - [perRowValues]: New per-row override values。
  /// - [columnWidth]: Explicit width override; set `null` to clear。
  /// - [placeholderStyle]: Placeholder style for feedback overlay。
  /// - [textAlign]: Text alignment override; set `null` to clear。
  ///
  /// Returns: A copied payload reflecting the specified updates.
  PillarPayload copyWith({
    PillarType? pillarType,
    String? pillarLabel,
    Map<RowType, String>? perRowValues,
    double? columnWidth,
    EdgeInsets? columnMargin,
    PillarPlaceholderStyle? placeholderStyle,
    RowTextAlign? textAlign,
    int? orderIndex,
    PillarContent? pillarContent,
  }) {
    return PillarPayload(
      pillarType: pillarType ?? this.pillarType,
      pillarLabel: pillarLabel ?? this.pillarLabel,
      perRowValues: perRowValues ?? this.perRowValues,
      columnWidth: columnWidth ?? this.columnWidth,
      columnMargin: columnMargin ?? this.columnMargin,
      placeholderStyle: placeholderStyle ?? this.placeholderStyle,
      textAlign: textAlign ?? this.textAlign,
      orderIndex: orderIndex ?? this.orderIndex,
      pillarContent: pillarContent ?? this.pillarContent,
    );
  }

  /// Resolves the expected ghost column width for UI.
  ///
  /// Parameters:
  /// - [defaultWidth]: Current unified pillar width used by the card。
  /// - [minWidth]: Minimum allowed width（默认 40）。
  /// - [maxWidth]: Maximum allowed width（默认 160）。
  ///
  /// Returns: A `double` representing the width to apply.
  double resolveWidth({
    required double defaultWidth,
    double minWidth = 40.0,
    double maxWidth = 160.0,
  }) {
    final w = columnWidth ?? defaultWidth;
    if (w.isNaN || w.isInfinite) return defaultWidth;
    return w.clamp(minWidth, maxWidth);
  }

  /// Factory helper: create a Luck Cycle pillar payload with common row values.
  static PillarPayload luckCycle({
    String label = '大运',
    Map<RowType, String> perRowValues = const {},
    double? columnWidth,
    PillarPlaceholderStyle? placeholderStyle,
    RowTextAlign? textAlign,
    int? orderIndex,
    PillarContent? pillarContent,
  }) {
    return PillarPayload(
      pillarType: PillarType.luckCycle,
      pillarLabel: label,
      perRowValues: perRowValues,
      columnWidth: columnWidth,
      placeholderStyle: placeholderStyle,
      textAlign: textAlign,
      orderIndex: orderIndex,
      pillarContent: pillarContent,
    );
  }
}

/// Payload for dragging a row info into a card (to insert a new row).
class RowInfoPayload {
  const RowInfoPayload({
    required this.rowType,
    required this.config,
    this.rowLabel,
    this.perPillarValues = const {},
    this.rowHeight,
    this.textAlign,
    this.strategy,
  });

  final TextStyleConfig? config;

  /// The type of row to insert (e.g., RowType.kongWang for 空亡).
  final RowType rowType;

  /// Optional custom label to display for the inserted row.
  final String? rowLabel;

  /// Optional overrides for each pillar in this row.
  /// Keys are pillar unique `id`, e.g. {'year#1': '戌亥', 'month#1': '戌亥'}.
  /// Using `id` differentiates repeated pillar types (e.g., multiple luck cycles).
  final Map<String, String> perPillarValues;

  /// Optional explicit row height to use for UI rendering.
  /// If provided, UI should prefer this value over implicit heuristics.
  final double? rowHeight;

  /// Optional text alignment for row title/content in UI.
  final RowTextAlign? textAlign;

  /// Optional embedded computation strategy producing or owning this row.
  /// Embedding allows late recomputation or context-aware updates by the UI.
  final RowComputationStrategy? strategy;

  /// Creates a standard 空亡 row payload.
  ///
  /// Parameters:
  /// - [label]: Custom row title to display (defaults to '空亡').
  /// - [values]: Per-pillar overrides (e.g., 年/月/日/时/大运 的空亡值)。
  /// - [rowHeight]: Explicit UI height override for the row.
  /// - [textAlign]: Optional text alignment for UI rendering.
  ///
  /// Returns: A `RowInfoPayload` representing an 空亡信息行。
  // static RowInfoPayload kongWang({
  //   String label = '空亡',
  //   Map<String, String> values = const {},
  //   double? rowHeight,
  //   RowTextAlign? textAlign,
  //   RowComputationStrategy? strategy,
  // }) {
  //   return RowInfoPayload(
  //     // config: TextStyleConfig(),
  //     rowType: RowType.kongWang,
  //     rowLabel: label,
  //     perPillarValues: values,
  //     rowHeight: rowHeight,
  //     textAlign: textAlign,
  //     strategy: strategy,
  //   );
  // }

  /// Returns a new `RowInfoPayload` with selected fields updated.
  ///
  /// Parameters:
  /// - [rowType]: New row type if changing semantic (e.g., 从空亡切换到纳音)。
  /// - [rowLabel]: New display label for the row.
  /// - [perPillarValues]: New per-pillar override values.
  /// - [rowHeight]: Explicit height override; set `null` to clear.
  /// - [textAlign]: Text alignment override; set `null` to clear.
  ///
  /// Returns: A copied payload reflecting the specified updates.
  RowInfoPayload copyWith({
    TextStyleConfig? config,
    RowType? rowType,
    String? rowLabel,
    Map<String, String>? perPillarValues,
    double? rowHeight,
    RowTextAlign? textAlign,
    RowComputationStrategy? strategy,
  }) {
    return RowInfoPayload(
      config: config ?? this.config,
      rowType: rowType ?? this.rowType,
      rowLabel: rowLabel ?? this.rowLabel,
      perPillarValues: perPillarValues ?? this.perPillarValues,
      rowHeight: rowHeight ?? this.rowHeight,
      textAlign: textAlign ?? this.textAlign,
      strategy: strategy ?? this.strategy,
    );
  }

  /// Resolve display value for a pillar (prefer overrides; fall back to strategy).
  ///
  /// Parameters:
  /// - [pillar]: Target `PillarContent`.
  /// - [input]: Computation context to use when no override is present.
  ///
  /// Returns: The text value; returns `null` if no override and no strategy.
  String? valueFor(PillarContent pillar, RowComputationInput input) {
    final override = perPillarValues[pillar.id];
    if (override != null) return override;
    final s = strategy;
    if (s == null) return null;
    final result = s.compute(input);
    return result.perPillarValues[pillar.id];
  }

  /// Compute per-pillar values for this row across all pillars.
  /// Overrides win; strategy fills missing entries.
  Map<String, String> computeValues(RowComputationInput input) {
    final s = strategy;
    if (s == null) return perPillarValues;
    final result = s.compute(input);
    return {
      ...result.perPillarValues,
      ...perPillarValues,
    };
  }

  /// Resolves the expected UI height for this row.
  ///
  /// Parameters:
  /// - [heavenlyAndEarthlyHeight]: Height to use for 干支行（默认 48）。
  /// - [otherHeight]: Height for general rows like 空亡/纳音（默认 32）。
  /// - [dividerHeight]: Height for divider-like rows（默认 8）。
  ///
  /// Returns: A `double` representing the UI height to apply.
  double resolveHeight({
    double heavenlyAndEarthlyHeight = 48,
    double otherHeight = 32,
    double dividerHeight = 8,
    double headerHeight = 24, // 新增：表头行默认高度
  }) {
    if (rowHeight != null) return rowHeight!;
    // 特殊处理：表头行
    if (rowType == RowType.columnHeaderRow) {
      return headerHeight;
    }
    // 类型优先：统一由 RowType 驱动高度
    if (rowType == RowType.heavenlyStem || rowType == RowType.earthlyBranch) {
      return heavenlyAndEarthlyHeight;
    }
    if (rowType == RowType.separator) {
      return dividerHeight;
    }
    return otherHeight;
  }
}
