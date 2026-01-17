import 'package:common/models/pillar_styles.dart';
import 'package:common/features/four_zhu_card/widgets/editable_fourzhu_card/models/pillar_style_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/layout_template_enums.dart';
import '../models/text_style_config.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/models/base_style_config.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/models/card_style_config.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/models/cell_style_config.dart';

part 'editable_four_zhu_card_theme.g.dart';

/// EditableCardThemeBuilder
/// 负责从 EditableFourZhuCardTheme 构建各个 Section 的工具类
class EditableCardThemeBuilder {
  /// 构建 PillarSection 实例
  static PillarSection buildPillarSection(EditableFourZhuCardTheme theme) {
    return PillarSection(
      global: theme.pillar.global,
      mapper: theme.pillar.mapper,
      defaultSeparatorConfig: theme.pillar.defaultSeparatorConfig,
    );
  }

  /// 构建 CellSection 实例
  static CellSection buildCellSection(EditableFourZhuCardTheme theme) {
    return CellSection(
      pillarTitleCellConfig: theme.cell.pillarTitleCellConfig,
      rowTitleCellConfig: theme.cell.rowTitleCellConfig,
      globalCellConfig: theme.cell.globalCellConfig,
      rowTypeCellConfigMapper: theme.cell.rowTypeCellConfigMapper,
    );
  }

  /// 构建 TypographySection 实例
  static TypographySection buildTypographySection(
      EditableFourZhuCardTheme theme) {
    return TypographySection(
      globalContent: theme.typography.globalContent,
      globalTitle: theme.typography.globalTitle,
      globalCellTitle: theme.typography.globalCellTitle,
      rowTitle: theme.typography.rowTitle,
      pillarTitle: theme.typography.pillarTitle,
      cellContentMapper: theme.typography.cellContentMapper,
      cellTitleMapper: theme.typography.cellTitleMapper,
    );
  }

  /// 创建默认主题实例
  static EditableFourZhuCardTheme createDefaultTheme() {
    // Separator 专用配置：窄宽度、无边框、无阴影、背景透明
    final defaultSeparatorConfig = PillarStyleConfig(
      border: BoxBorderStyle.defaultBorder.copyWith(enabled: false),
      lightBackgroundColor: Colors.white.withAlpha(0),
      darkBackgroundColor: Colors.white.withAlpha(0),
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      shadow: BoxShadowStyle.defaultShadow.copyWith(withShadow: false),
      separatorWidth: 32.0,
    );

    // Row Separator 专用配置
    final defaultRowSeparatorConfig =
        CellStyleConfig.defaultCellStyleConfig.copyWith(
      separatorHeight: 8.0,
      lightBackgroundColor: Colors.transparent,
      darkBackgroundColor: Colors.transparent,
    );

    return EditableFourZhuCardTheme(
      displayHeaderRow: true,
      displayRowTitleColumn: true,
      displayCellTitle: false,
      card: CardStyleConfig.defaultCardStyleConfig,
      pillar: PillarSection(
        global: PillarStyleConfig.defaultPillarStyleConfig,
        mapper: {},
        defaultSeparatorConfig: defaultSeparatorConfig,
      ),
      cell: CellSection.defaultCellSection.copyWith(
        rowTypeCellConfigMapper: {
          RowType.separator: defaultRowSeparatorConfig,
        },
      ),
      typography: TypographySection.defaultTypographySection,
    );
  }
}

/// EditableFourZhuCardTheme
/// Encapsulates styling configuration for EditableFourZhuCard V3.
/// Provides validation to enforce consensus constraints:
/// - Non-negative values for margins, padding, borderWidth, cornerRadius
/// - `perPillarMargin` keys limited to {year, month, day, hour, luckCycle}
/// - Font fallback order: user-specified → theme default → system default
@JsonSerializable(explicitToJson: true)
class EditableFourZhuCardTheme extends Equatable {
  /// Creates a theme with optional sections for card, pillar, cell, and typography.
  /// All numeric values are interpreted in logical pixels.
  EditableFourZhuCardTheme({
    required this.displayHeaderRow,
    required this.displayRowTitleColumn,
    required this.card,
    required this.pillar,
    required this.cell,
    required this.typography,
    required this.displayCellTitle,
  });

  bool displayHeaderRow;
  bool displayRowTitleColumn;
  bool displayCellTitle;

  /// Card-level decoration and background.
  final CardStyleConfig card;

  /// Pillar-level decoration (outer margin differentiation is supported).
  final PillarSection pillar;

  /// Cell-level decoration (row-wise padding/border defaults).
  final CellSection cell;

  /// Text styles and font fallback behaviors.
  final TypographySection typography;

  factory EditableFourZhuCardTheme.fromJson(Map<String, dynamic> json) =>
      _$EditableFourZhuCardThemeFromJson(json);

  Map<String, dynamic> toJson() => _$EditableFourZhuCardThemeToJson(this);

  copyWith({
    bool? displayHeaderRow,
    bool? displayRowTitleColumn,
    CardStyleConfig? card,
    PillarSection? pillar,
    CellSection? cell,
    TypographySection? typography,
    bool? displayCellTitle,
  }) {
    return EditableFourZhuCardTheme(
      displayHeaderRow: displayHeaderRow ?? this.displayHeaderRow,
      displayRowTitleColumn:
          displayRowTitleColumn ?? this.displayRowTitleColumn,
      card: card ?? this.card,
      pillar: pillar ?? this.pillar,
      cell: cell ?? this.cell,
      typography: typography ?? this.typography,
      displayCellTitle: displayCellTitle ?? this.displayCellTitle,
    );
  }

  /// Validates this theme and returns a list of discovered problems.
  ///
  /// Returns: A list of `ThemeValidationError` entries describing all found
  /// violations. Use `ensureValidOrThrow` to throw immediately on first error.
  List<ThemeValidationError> validate() {
    final errors = <ThemeValidationError>[];

    // Validate card section
    // card?.validateInto(errors);
    // Validate pillar section
    // pillar?.validateInto(errors);
    // Validate cell section
    cell?.validateInto(errors);
    // Typography has no numeric constraints; fontFamily aliasing is handled elsewhere.

    return errors;
  }

  /// Validates the theme and throws `ArgumentError` on the first violation.
  ///
  /// Throws: `ArgumentError` whose message is the first validation error
  /// encountered. No value is returned.
  void ensureValidOrThrow() {
    final errors = validate();
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.first.message);
    }
  }

  @override
  List<Object?> get props => [
        displayHeaderRow,
        displayRowTitleColumn,
        card,
        pillar,
        cell,
        typography,
      ];
}

/// Captures validation problems with section/scoped context.
class ThemeValidationError {
  /// Creates a validation error message for diagnostic and user feedback.
  const ThemeValidationError({required this.scope, required this.message});

  /// The logical scope where the error was detected: e.g. `card`, `pillar.margin`.
  final String scope;

  /// Human-readable error message describing the violation.
  final String message;
}

/// Card-level decoration section: padding, margin, radius, shadow, and backdrop.
///
@Deprecated('Use CardStyleConfig instead')
class CardSection {
  /// Creates card decoration defaults.
  const CardSection({
    this.backgroundColor,
    this.borderWidth,
    this.borderColor,
    this.elevation,
    this.cornerRadius,
    this.padding,
    this.margin,
    this.shadowColorFollowsBackground,
    this.shadowColor,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.shadowBlurRadius,
  });

  /// Background color of the card surface (nullable for Theme default).
  final Color? backgroundColor;

  /// Card border width; must be non-negative if provided.
  final double? borderWidth;

  /// Card border color (nullable for Theme default).
  final Color? borderColor;

  /// Material elevation (shadows); must be non-negative if provided.
  final double? elevation;

  /// Corner radius in pixels; must be non-negative if provided.
  final double? cornerRadius;

  /// Inner padding; each component must be non-negative if provided.
  final EdgeInsets? padding;

  /// Outer margin; each component must be non-negative if provided.
  final EdgeInsets? margin;

  /// When true, shadow color should follow the `backgroundColor`.
  /// If no background color is set, shadow is considered not present.
  final bool? shadowColorFollowsBackground;

  /// Box shadow color for the card surface.
  final Color? shadowColor;

  /// Box shadow offset X (horizontal), in logical pixels.
  final double? shadowOffsetX;

  /// Box shadow offset Y (vertical), in logical pixels.
  final double? shadowOffsetY;

  /// Box shadow blur radius; must be non-negative if provided.
  final double? shadowBlurRadius;

  /// Serializes this section to JSON.
  ///
  /// Returns: A `Map<String, dynamic>` with color/elevation/radius and
  /// edge-insets (padding/margin) values suitable for persistence.
  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': backgroundColor?.value,
      'borderWidth': borderWidth,
      'borderColor': borderColor?.value,
      'elevation': elevation,
      'cornerRadius': cornerRadius,
      'padding': _edgeToJson(padding),
      'margin': _edgeToJson(margin),
      'shadowColorFollowsBackground': shadowColorFollowsBackground,
      'shadowColor': shadowColor?.value,
      'shadowOffsetX': shadowOffsetX,
      'shadowOffsetY': shadowOffsetY,
      'shadowBlurRadius': shadowBlurRadius,
    };
  }

  /// Deserializes this section from JSON.
  ///
  /// Parameters:
  /// - [json]: A `Map<String, dynamic>` containing serialized card values.
  ///
  /// Returns: A `CardSection` populated from the provided map.
  factory CardSection.fromJson(Map<String, dynamic> json) {
    return CardSection(
      backgroundColor: json['backgroundColor'] is int
          ? Color(json['backgroundColor'] as int)
          : null,
      borderWidth: (json['borderWidth'] as num?)?.toDouble(),
      borderColor:
          json['borderColor'] is int ? Color(json['borderColor'] as int) : null,
      elevation: (json['elevation'] as num?)?.toDouble(),
      cornerRadius: (json['cornerRadius'] as num?)?.toDouble(),
      padding: _edgeFromJson(json['padding']),
      margin: _edgeFromJson(json['margin']),
      shadowColorFollowsBackground:
          json['shadowColorFollowsBackground'] as bool?,
      shadowColor:
          json['shadowColor'] is int ? Color(json['shadowColor'] as int) : null,
      shadowOffsetX: (json['shadowOffsetX'] as num?)?.toDouble(),
      shadowOffsetY: (json['shadowOffsetY'] as num?)?.toDouble(),
      shadowBlurRadius: (json['shadowBlurRadius'] as num?)?.toDouble(),
    );
  }

  /// Appends validation errors into the collector.
  ///
  /// Parameters:
  /// - [out]: A mutable list to which discovered `ThemeValidationError`s are
  /// appended. No value is returned.
  void validateInto(List<ThemeValidationError> out) {
    if (borderWidth != null && borderWidth! < 0) {
      out.add(const ThemeValidationError(
        scope: 'card.borderWidth',
        message: 'Border width must be non-negative.',
      ));
    }
    if (elevation != null && elevation! < 0) {
      out.add(const ThemeValidationError(
        scope: 'card.elevation',
        message: 'Elevation must be non-negative.',
      ));
    }
    if (cornerRadius != null && cornerRadius! < 0) {
      out.add(const ThemeValidationError(
        scope: 'card.cornerRadius',
        message: 'Corner radius must be non-negative.',
      ));
    }
    _validateEdgeInsetsNonNegative('card.padding', padding, out);
    _validateEdgeInsetsNonNegative('card.margin', margin, out);
    if (shadowBlurRadius != null && shadowBlurRadius! < 0) {
      out.add(const ThemeValidationError(
        scope: 'card.shadowBlurRadius',
        message: 'Shadow blur radius must be non-negative.',
      ));
    }
  }

  CardSection copyWith({
    Color? backgroundColor,
    double? borderWidth,
    Color? borderColor,
    double? cornerRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool? shadowColorFollowsBackground,
    Color? shadowColor,
    double? shadowOffsetX,
    double? shadowOffsetY,
    double? shadowBlurRadius,
  }) {
    return CardSection(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      shadowColorFollowsBackground:
          shadowColorFollowsBackground ?? this.shadowColorFollowsBackground,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowOffsetX: shadowOffsetX ?? this.shadowOffsetX,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
    );
  }
}

@JsonSerializable()

/// Pillar-level decoration and per-pillar margin differentiation.
class PillarSection {
  /// Creates pillar decoration settings.
  PillarSection({
    required this.global,
    required this.mapper,
    required this.defaultSeparatorConfig,
  });
  final PillarStyleConfig global;
  final Map<PillarType, PillarStyleConfig> mapper;

  /// Separator 列的默认样式配置
  /// 当 getBy(PillarType.separator) 时：
  /// 1. 优先使用 mapper[PillarType.separator]
  /// 2. 其次使用 defaultSeparatorConfig
  /// 3. 最后回退到 global
  final PillarStyleConfig defaultSeparatorConfig;

  PillarStyleConfig getBy(PillarType pillarType) {
    // 优先查找 mapper 中的配置
    if (mapper.containsKey(pillarType)) {
      return mapper[pillarType]!;
    }
    // 对于 separator，使用专用默认配置
    if (pillarType == PillarType.separator && defaultSeparatorConfig != null) {
      return defaultSeparatorConfig!;
    }
    // 回退到全局配置
    return global;
  }

  PillarSection copyWith({
    PillarStyleConfig? global,
    Map<PillarType, PillarStyleConfig>? mapper,
    PillarStyleConfig? defaultSeparatorConfig,
  }) {
    return PillarSection(
      global: global ?? this.global,
      mapper: mapper ?? this.mapper,
      defaultSeparatorConfig:
          defaultSeparatorConfig ?? this.defaultSeparatorConfig,
    );
  }

  /// Default outer margin applied to pillars unless overridden.
  EdgeInsets? get defaultMargin => global.margin;

  /// Default inner padding applied to pillars.
  EdgeInsets? get defaultPadding => global.padding;

  /// Pillar border width; must be non-negative if provided and not `none`.
  double? get borderWidth => global.border?.width;

  /// Pillar border color (nullable for Theme default).
  Color? get borderColor => global.border?.lightColor;

  /// Corner radius in pixels; must be non-negative if provided.
  double? get cornerRadius => global.border?.radius;

  /// Background color (nullable for transparent/default when not set).
  Color? get backgroundColor => global.lightBackgroundColor;

  Color? resolveBorderColor(Brightness brightness) =>
      global.border?.resolveColor(brightness);

  Color? resolveBackgroundColor(Brightness brightness) =>
      global.resolveBackgroundColor(brightness);

  /// Differentiated outer margins per pillar type.
  /// Only keys in {year, month, day, hour, luckCycle} are allowed.
  EdgeInsets? get perPillarMargin => global.margin;

  /// Whether pillar shadow is enabled explicitly.
  /// When null, legacy behavior applies: enabled if follow-background or color provided.
  bool? get withShadow => global.shadow?.withShadow;

  /// When true, shadow color should follow the `backgroundColor`.
  /// If no background color is set, shadow is considered not present.
  bool? get shadowColorFollowsBackground =>
      global.shadow?.followCardBackgroundColor;

  /// Box shadow color for pillar containers.
  Color? get shadowColor => global.shadow?.lightThemeColor;

  /// Box shadow offset X (horizontal), in logical pixels.
  double? get shadowOffsetX => global.shadow?.offset.dx;

  /// Box shadow offset Y (vertical), in logical pixels.
  double? get shadowOffsetY => global.shadow?.offset.dy;

  /// Box shadow blur radius; must be non-negative if provided.
  double? get shadowBlurRadius => global.shadow?.blurRadius;

  /// Box shadow spread radius; must be non-negative if provided.
  double? get shadowSpreadRadius => global.shadow?.spreadRadius;

  /// Shadow opacity in [0, 1], derived from shadow color alpha.
  double? get shadowOpacity {
    final shadow = global.shadow;
    if (shadow == null) return null;
    return shadow.lightThemeColor.alpha / 255.0;
  }

  /// 计算指定柱类型的装饰宽度（margin + padding + borderWidth*2）。
  /// WARNING: 并不包含组层Pillar的Cell宽度
  /// 参数：
  /// - [pillarType]：柱类型（如年、月、日、时、大运）。
  ///
  ///
  /// 返回：
  /// - `double`：该柱的装饰总宽度（逻辑像素）。
  double getDecorationWidthBy(PillarType pillarType) {
    final cfg = getBy(pillarType);
    return cfg.getDecorationWidth();
  }

  /// 计算指定柱类型的装饰高度（margin + padding + borderWidth*2）。
  /// WARNING: 并不包含组层Pillar的Cell高度
  /// 参数：
  /// - [pillarType]：柱类型（如年、月、日、时、大运）。
  ///
  /// 返回：
  /// - `double`：该柱的装饰总高度（逻辑像素）。
  double getDecorationHeightBy(PillarType pillarType) {
    final cfg = getBy(pillarType);
    return cfg.getDecorationHeight();
  }

  Map<String, dynamic> toJson() => _$PillarSectionToJson(this);
  factory PillarSection.fromJson(Map<String, dynamic> json) =>
      _$PillarSectionFromJson(json);
}

/// Cell-level decoration defaults; row-wise overrides remain in RowConfig.
@JsonSerializable()
class CellSection {
  /// Creates cell decoration settings.
  CellSection({
    required this.pillarTitleCellConfig,
    required this.rowTitleCellConfig,
    required this.globalCellConfig,
    required this.rowTypeCellConfigMapper,
  });
  final CellStyleConfig pillarTitleCellConfig;
  final CellStyleConfig rowTitleCellConfig;
  final CellStyleConfig globalCellConfig;
  final Map<RowType, CellStyleConfig> rowTypeCellConfigMapper;

  /// Default inner padding applied to non-title cells.
  EdgeInsets? get defaultPadding => globalCellConfig.padding;

  /// Default border width applied to cell dividers.
  double? get defaultBorderWidth => globalCellConfig.border?.width;

  CellStyleConfig getBy(RowType rowType) {
    if (rowType == RowType.columnHeaderRow) {
      return pillarTitleCellConfig;
    }
    return rowTypeCellConfigMapper[rowType] ?? globalCellConfig;
  }

  double getDecorationWidthBy(RowType rowType) {
    final cfg = getBy(rowType);
    return cfg.getDecorationWidth();
  }

  double getDecorationHeightBy(RowType rowType) {
    final cfg = getBy(rowType);
    return cfg.getDecorationHeight();
  }

  static CellSection get defaultCellSection => CellSection(
        pillarTitleCellConfig: CellStyleConfig.defaultCellStyleConfig,
        rowTitleCellConfig: CellStyleConfig.defaultCellStyleConfig,
        globalCellConfig: CellStyleConfig.defaultCellStyleConfig,
        rowTypeCellConfigMapper: {},
      );

  factory CellSection.fromJson(Map<String, dynamic> json) =>
      _$CellSectionFromJson(json);
  Map<String, dynamic> toJson() => _$CellSectionToJson(this);

  /// Appends validation errors into the collector.
  ///
  /// Parameters:
  /// - [out]: A mutable list to which discovered `ThemeValidationError`s are
  /// appended. Validates non-negative constraints.
  void validateInto(List<ThemeValidationError> out) {
    _validateEdgeInsetsNonNegative('cell.defaultPadding', defaultPadding, out);
    if (defaultBorderWidth != null && defaultBorderWidth! < 0) {
      out.add(const ThemeValidationError(
        scope: 'cell.defaultBorderWidth',
        message: 'Border width must be non-negative.',
      ));
    }
  }

  copyWith({
    CellStyleConfig? pillarTitleCellConfig,
    CellStyleConfig? rowTitleCellConfig,
    CellStyleConfig? globalCellConfig,
    Map<RowType, CellStyleConfig>? rowTypeCellConfigMapper,
  }) {
    return CellSection(
      pillarTitleCellConfig:
          pillarTitleCellConfig ?? this.pillarTitleCellConfig,
      rowTitleCellConfig: rowTitleCellConfig ?? this.rowTitleCellConfig,
      globalCellConfig: globalCellConfig ?? this.globalCellConfig,
      rowTypeCellConfigMapper:
          rowTypeCellConfigMapper ?? this.rowTypeCellConfigMapper,
    );
  }
}

/// Typography section defines global text family and fallback behaviors.
@JsonSerializable()
class TypographySection {
  /// Creates typography defaults.
  const TypographySection({
    required this.globalContent,
    required this.globalTitle,
    required this.globalCellTitle,
    required this.rowTitle,
    required this.pillarTitle,
    required this.cellContentMapper,
    required this.cellTitleMapper,
  });

  final TextStyleConfig globalContent;
  final TextStyleConfig globalTitle;
  final TextStyleConfig rowTitle;
  final TextStyleConfig pillarTitle;
  final TextStyleConfig globalCellTitle;
  final Map<RowType, TextStyleConfig> cellContentMapper;
  final Map<RowType, TextStyleConfig> cellTitleMapper;

  static TypographySection get defaultTypographySection => TypographySection(
        globalContent: TextStyleConfig.defaultConfig,
        globalTitle: TextStyleConfig.defaultOthersConfig,
        rowTitle: TextStyleConfig.defaultOthersConfig,
        pillarTitle: TextStyleConfig.defaultOthersConfig,
        globalCellTitle: TextStyleConfig.defaultOthersTitleConfig,
        cellContentMapper: {
          RowType.earthlyBranch: TextStyleConfig.defaultZhiConfig,
          RowType.hiddenStemsPrimary: TextStyleConfig.defaultZhiConfig.copyWith(
              fontStyleDataModel: TextStyleConfig
                  .defaultZhiConfig.fontStyleDataModel
                  .copyWith(fontSize: 12)),
          RowType.hiddenStemsSecondary: TextStyleConfig.defaultZhiConfig
              .copyWith(
                  fontStyleDataModel: TextStyleConfig
                      .defaultZhiConfig.fontStyleDataModel
                      .copyWith(fontSize: 12)),
          RowType.hiddenStemsTertiary: TextStyleConfig.defaultZhiConfig
              .copyWith(
                  fontStyleDataModel: TextStyleConfig
                      .defaultZhiConfig.fontStyleDataModel
                      .copyWith(fontSize: 12)),
          RowType.heavenlyStem: TextStyleConfig.defaultGanConfig,
          RowType.tenGod: TextStyleConfig.defaultTenGodsConfig,
          RowType.hiddenStemsSecondaryGods:
              TextStyleConfig.defaultTenGodsConfig,
          RowType.hiddenStemsPrimaryGods: TextStyleConfig.defaultTenGodsConfig,
          RowType.hiddenStemsTertiaryGods: TextStyleConfig.defaultTenGodsConfig,
          RowType.starYun: TextStyleConfig.defaultTwelveZhangShengConfig,
          RowType.selfSiting: TextStyleConfig.defaultTwelveZhangShengConfig,
        },
        cellTitleMapper: {},
      );

  TextStyleConfig getCellContentBy(RowType rowType) {
    if (rowType == RowType.columnHeaderRow) {
      return cellContentMapper[rowType] ?? pillarTitle;
    }
    return cellContentMapper[rowType] ?? globalContent;
  }

  TextStyleConfig getCellTitleBy(RowType rowType) {
    return cellTitleMapper[rowType] ?? globalCellTitle;
  }

  /// Theme-level default font family; used if row-specific is absent.
  String? get globalFontFamily => globalContent.fontStyleDataModel.fontFamily;

  /// Theme-level default font size for general rows.
  double? get globalFontSize => globalContent.fontStyleDataModel.fontSize;

  /// Theme-level default text color.
  Color? get globalFontColor => globalContent.colorMapperDataModel.defaultColor;

  factory TypographySection.fromJson(Map<String, dynamic> json) =>
      _$TypographySectionFromJson(json);
  Map<String, dynamic> toJson() => _$TypographySectionToJson(this);

  copyWith({
    TextStyleConfig? globalContent,
    TextStyleConfig? globalTitle,
    TextStyleConfig? rowTitle,
    TextStyleConfig? pillarTitle,
    TextStyleConfig? globalCellTitle,
    Map<RowType, TextStyleConfig>? cellContentMapper,
    Map<RowType, TextStyleConfig>? cellTitleMapper,
  }) {
    return TypographySection(
      globalContent: globalContent ?? this.globalContent,
      globalTitle: globalTitle ?? this.globalTitle,
      rowTitle: rowTitle ?? this.rowTitle,
      pillarTitle: pillarTitle ?? this.pillarTitle,
      globalCellTitle: globalCellTitle ?? this.globalCellTitle,
      cellContentMapper: cellContentMapper ?? this.cellContentMapper,
      cellTitleMapper: cellTitleMapper ?? this.cellTitleMapper,
    );
  }
}

// ----- Helpers -----

/// Converts [EdgeInsets] to a JSON-friendly map.
///
/// Parameters:
/// - [edge]: An `EdgeInsets?` to convert.
///
/// Returns: A `Map<String, dynamic>?` with left/top/right/bottom values or null.
Map<String, dynamic>? _edgeToJson(EdgeInsets? edge) {
  if (edge == null) return null;
  return {
    'left': edge.left,
    'top': edge.top,
    'right': edge.right,
    'bottom': edge.bottom,
  };
}

/// Constructs [EdgeInsets] from a JSON-friendly map.
///
/// Parameters:
/// - [json]: A dynamic value expected to be `Map<String, dynamic>` with numeric
///   left/top/right/bottom keys.
///
/// Returns: An `EdgeInsets?` constructed from the map or null when input is invalid.
EdgeInsets? _edgeFromJson(dynamic json) {
  if (json is Map<String, dynamic>) {
    final l = (json['left'] as num?)?.toDouble() ?? 0;
    final t = (json['top'] as num?)?.toDouble() ?? 0;
    final r = (json['right'] as num?)?.toDouble() ?? 0;
    final b = (json['bottom'] as num?)?.toDouble() ?? 0;
    return EdgeInsets.fromLTRB(l, t, r, b);
  }
  return null;
}

/// Validates that all EdgeInsets components are non-negative.
///
/// Parameters:
/// - [scope]: A string indicating the validation context (e.g., 'card.margin').
/// - [edge]: The `EdgeInsets?` to validate.
/// - [out]: A mutable list to collect `ThemeValidationError` entries.
///
/// Returns: No value. Appends an error entry to [out] if any component is negative.
void _validateEdgeInsetsNonNegative(
  String scope,
  EdgeInsets? edge,
  List<ThemeValidationError> out,
) {
  if (edge == null) return;
  if (edge.left < 0 || edge.top < 0 || edge.right < 0 || edge.bottom < 0) {
    out.add(ThemeValidationError(
      scope: scope,
      message: 'EdgeInsets components must be non-negative.',
    ));
  }
}
