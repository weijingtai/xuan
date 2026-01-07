import 'package:common/enums.dart';
import 'package:common/models/text_style_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../enums/layout_template_enums.dart';
import '../enums/enum_gender.dart';
import '../utils/constant_values_utils.dart';
import 'pillar_styles.dart';
import 'pillar_content.dart';
import 'row_strategy.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/models/base_style_config.dart';
part 'drag_payloads.g.dart';

/// Payload representing a draggable title item for either columns or rows.
/// Used when the UI allows reordering titles directly without dragging full cells.
/// Title row payload: a special row payload used when dragging row titles.
///
/// 语义：作为“标题行”的拖拽载荷，但继承 `RowInfoPayload`，以便与现有行插入/重排逻辑对齐。
/// 注意：该载荷仅用于标题行的排序，不代表插入新的数据行。
@JsonSerializable()
class TitleRowPayload extends TextRowPayload {
  TitleRowPayload({
    required String uuid,
  }) : super(
          rowType: RowType.columnHeaderRow,
          rowLabel: RowType.columnHeaderRow.name,
          titleInCell: false,
          uuid: uuid,
        );
  factory TitleRowPayload.fromJson(Map<String, dynamic> json) =>
      _$TitleRowPayloadFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TitleRowPayloadToJson(this);
}

/// Title column payload: a special pillar payload used when dragging column titles.
///
/// 语义：作为“标题列”的拖拽载荷，但继承 `PillarPayload`，以便与现有列插入/重排逻辑对齐。
/// 注意：该载荷仅用于标题列的排序，不代表插入新的数据列。
@JsonSerializable()
class TitleColumnPayload extends PillarPayload {
  TitleColumnPayload({required super.uuid})
      : super(
            pillarType: PillarType.rowTitleColumn,
            pillarLabel: PillarType.rowTitleColumn.name);
  factory TitleColumnPayload.fromJson(Map<String, dynamic> json) =>
      _$TitleColumnPayloadFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TitleColumnPayloadToJson(this);
  @override
  PillarPayload copyWith(
      {String? uuid,
      PillarType? pillarType,
      String? pillarLabel,
      TextStyleConfig? textStyleConfig,
      double? width}) {
    return super
        .copyWith(uuid: uuid, pillarType: pillarType, pillarLabel: pillarLabel);
  }
}

/// Column header row payload: represents the special row containing column titles and gender.
///
/// 语义：表头行作为一个特殊的"行"，包含性别标识和所有列的标题文本。
/// 特点：
/// - 每个单元格的内容不同（左上角是性别，其他是列标题）
/// - 可以与普通行（天干/地支/纳音）互换位置
/// - 性别标识随表头行移动而变化（乾造/坤造）
@JsonSerializable()
class ColumnHeaderRowPayload extends TextRowPayload {
  ColumnHeaderRowPayload({
    required this.gender,
    required super.uuid,
  }) : super(
          rowType: RowType.columnHeaderRow,
          rowLabel: FourZhuText.zaoLabelForGender(gender),
          titleInCell: false,
        );
  final Gender gender;
  String get genderLabel => FourZhuText.zaoLabelForGender(gender);
  factory ColumnHeaderRowPayload.fromJson(Map<String, dynamic> json) =>
      _$ColumnHeaderRowPayloadFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ColumnHeaderRowPayloadToJson(this);
}

@JsonSerializable()
class CardPayload extends Equatable {
  List<String> pillarOrderUuid;
  List<String> rowOrderUuid;
  Map<String, RowPayload> rowMap;
  Map<String, PillarPayload> pillarMap;

  Gender gender;
  CardPayload({
    required this.gender,
    required this.pillarMap,
    required this.pillarOrderUuid,
    required this.rowMap,
    required this.rowOrderUuid,
  });
  factory CardPayload.fromJson(Map<String, dynamic> json) =>
      _$CardPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$CardPayloadToJson(this);

  @override
  List<Object?> get props => [
        pillarMap,
        pillarOrderUuid,
        rowOrderUuid,
        gender,
      ];

  copyWith({
    Map<String, PillarPayload>? pillarMap,
    Map<String, RowPayload>? rowMap,
    List<String>? pillarOrderUuid,
    List<String>? rowOrderUuid,
    Gender? gender,
  }) {
    return CardPayload(
      rowMap: rowMap ?? this.rowMap,
      pillarMap: pillarMap ?? this.pillarMap,
      pillarOrderUuid: pillarOrderUuid ?? this.pillarOrderUuid,
      rowOrderUuid: rowOrderUuid ?? this.rowOrderUuid,
      gender: gender ?? this.gender,
    );
  }
}

@JsonSerializable()

/// Payload for dragging a pillar (column) into a card.
class PillarPayload extends Equatable {
  /// The unique identifier for this payload.
  final String uuid;

  const PillarPayload(
      {required this.uuid, required this.pillarType, this.pillarLabel});

  /// The type of pillar to insert (e.g., PillarType.luckCycle for 大运).
  final PillarType pillarType;
  // final PillarContent pillarContent;

  /// Optional custom label to display for the inserted pillar.
  final String? pillarLabel;
  factory PillarPayload.fromJson(Map<String, dynamic> json) =>
      _$PillarPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$PillarPayloadToJson(this);

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
    String? uuid,
  }) {
    return PillarPayload(
      pillarType: pillarType ?? this.pillarType,
      pillarLabel: pillarLabel ?? this.pillarLabel,
      uuid: uuid ?? this.uuid,
    );
  }

  @override
  List<Object?> get props => [pillarType, pillarLabel, uuid];
}

@JsonSerializable()
class RowPayload extends Equatable {
  final RowType rowType;
  final String uuid;
  const RowPayload({
    required this.rowType,
    required this.uuid,
  });
  factory RowPayload.fromJson(Map<String, dynamic> json) =>
      _$RowPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$RowPayloadToJson(this);
  @override
  List<Object?> get props => [rowType, uuid];
}

@JsonSerializable()
class RowSeparatorPayload extends RowPayload {
  RowSeparatorPayload({
    required super.uuid,
  }) : super(rowType: RowType.separator);
  factory RowSeparatorPayload.fromJson(Map<String, dynamic> json) =>
      _$RowSeparatorPayloadFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RowSeparatorPayloadToJson(this);
  @override
  List<Object?> get props => [rowType, uuid];
  copyWith({
    RowType? rowType,
    String? uuid,
  }) {
    return RowSeparatorPayload(
      uuid: uuid ?? this.uuid,
    );
  }
}

/// Payload for dragging a row info into a card (to insert a new row).
@JsonSerializable()
class TextRowPayload extends RowPayload {
  TextRowPayload({
    required super.rowType,
    required super.uuid,
    required this.titleInCell,
    this.rowLabel,
    this.tenGodLabelType = 'name',
  });
  factory TextRowPayload.fromJson(Map<String, dynamic> json) =>
      _$TextRowPayloadFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TextRowPayloadToJson(this);

  // final TextStyleConfig? config;

  /// The type of row to insert (e.g., RowType.kongWang for 空亡).
  // final RowType rowType;

  /// Optional custom label to display for the inserted row.
  final String? rowLabel;
  final bool titleInCell;
  final String tenGodLabelType;

  /// Optional overrides for each pillar in this row.
  /// Keys are pillar unique `id`, e.g. {'year#1': '戌亥', 'month#1': '戌亥'}.
  /// Using `id` differentiates repeated pillar types (e.g., multiple luck cycles).
  // final Map<String, String> perPillarValues;

  /// Optional explicit row height to use for UI rendering.
  /// If provided, UI should prefer this value over implicit heuristics.
  // final double? rowHeight;

  /// Optional text alignment for row title/content in UI.
  // final RowTextAlign? textAlign;

  /// Optional embedded computation strategy producing or owning this row.
  /// Embedding allows late recomputation or context-aware updates by the UI.
  // final RowComputationStrategy? strategy;

  /// Optional vertical padding (top and bottom) for this row.
  /// When provided, the UI should apply this padding to the row content.
  // final double? padding;
  // final double? marginVertical;
  // final double? marginHorizontal;
  // final double? paddingHorizontal;

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
  /// - [padding]: Vertical padding override; set `null` to clear.
  ///
  /// Returns: A copied payload reflecting the specified updates.
  TextRowPayload copyWith({
    String? uuid,
    RowType? rowType,
    String? rowLabel,
    bool? titleInCell,
    String? tenGodLabelType,
  }) {
    return TextRowPayload(
      uuid: uuid ?? this.uuid,
      rowType: rowType ?? this.rowType,
      rowLabel: rowLabel ?? this.rowLabel,
      titleInCell: titleInCell ?? this.titleInCell,
      tenGodLabelType: tenGodLabelType ?? this.tenGodLabelType,
    );
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
    // if (rowHeight != null) return rowHeight!;
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

  @override
  List<Object?> get props => [
        rowType,
        uuid,
        titleInCell,
        rowLabel,
        tenGodLabelType,
      ];
}

@JsonSerializable()
class SeparatorPillarPayload extends PillarPayload {
  const SeparatorPillarPayload({
    required super.uuid,
  }) : super(
          pillarType: PillarType.separator,
          pillarLabel: '分隔符',
        );
  factory SeparatorPillarPayload.fromJson(Map<String, dynamic> json) =>
      _$SeparatorPillarPayloadFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SeparatorPillarPayloadToJson(this);
}

@JsonSerializable()
class ContentPillarPayload extends PillarPayload {
  const ContentPillarPayload({
    required super.uuid,
    required super.pillarType,
    required super.pillarLabel,
    required this.pillarContent,
  });
  final PillarContent pillarContent;
  factory ContentPillarPayload.fromJson(Map<String, dynamic> json) =>
      _$ContentPillarPayloadFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ContentPillarPayloadToJson(this);

  @override
  copyWith({
    PillarType? pillarType,
    String? pillarLabel,
    String? uuid,
    PillarContent? pillarContent,
  }) {
    return ContentPillarPayload(
      pillarType: pillarType ?? this.pillarType,
      pillarLabel: pillarLabel ?? this.pillarLabel,
      uuid: uuid ?? this.uuid,
      pillarContent: pillarContent ?? this.pillarContent,
    );
  }

  @override
  List<Object?> get props => [pillarType, pillarLabel, uuid, pillarContent];
}

/// Row title column payload: represents the special column containing row titles.
///
/// 语义：行标题列作为一个特殊的"柱"，包含所有行的标题文本。
/// 特点：
/// - 每个单元格的内容不同（根据行类型显示不同的标题）
/// - 可以与普通柱（年月日时）互换位置
/// - 左上角单元格显示性别标识（乾造/坤造）
@JsonSerializable()
class RowTitleColumnPayload extends PillarPayload {
  const RowTitleColumnPayload({
    required super.uuid,
  }) : super(
          pillarType: PillarType.rowTitleColumn,
          pillarLabel: '行标题',
        );
  factory RowTitleColumnPayload.fromJson(Map<String, dynamic> json) =>
      _$RowTitleColumnPayloadFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RowTitleColumnPayloadToJson(this);
  @override
  PillarPayload copyWith(
      {String? uuid,
      PillarType? pillarType,
      String? pillarLabel,
      TextStyleConfig? textStyleConfig}) {
    return super
        .copyWith(uuid: uuid, pillarType: pillarType, pillarLabel: pillarLabel);
  }
}
