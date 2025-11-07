import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';

/// EditableFourZhuCardTheme
/// Encapsulates styling configuration for EditableFourZhuCard V3.
/// Provides validation to enforce consensus constraints:
/// - Non-negative values for margins, padding, borderWidth, cornerRadius
/// - `perPillarMargin` keys limited to {year, month, day, hour, luckCycle}
/// - Font fallback order: user-specified → theme default → system default
class EditableFourZhuCardTheme {
  /// Creates a theme with optional sections for card, pillar, cell, and typography.
  /// All numeric values are interpreted in logical pixels.
  const EditableFourZhuCardTheme({
    this.card,
    this.pillar,
    this.cell,
    this.typography,
  });

  /// Card-level decoration and background.
  final CardSection? card;

  /// Pillar-level decoration (outer margin differentiation is supported).
  final PillarSection? pillar;

  /// Cell-level decoration (row-wise padding/border defaults).
  final CellSection? cell;

  /// Text styles and font fallback behaviors.
  final TypographySection? typography;

  /// Returns a copy with selectively overridden sections.
  ///
  /// Parameters:
  /// - [card]: Optional card section override.
  /// - [pillar]: Optional pillar section override.
  /// - [cell]: Optional cell section override.
  /// - [typography]: Optional typography section override.
  ///
  /// Returns: A new `EditableFourZhuCardTheme` with provided overrides applied.
  EditableFourZhuCardTheme copyWith({
    CardSection? card,
    PillarSection? pillar,
    CellSection? cell,
    TypographySection? typography,
  }) {
    return EditableFourZhuCardTheme(
      card: card ?? this.card,
      pillar: pillar ?? this.pillar,
      cell: cell ?? this.cell,
      typography: typography ?? this.typography,
    );
  }

  /// Serializes this theme to JSON.
  ///
  /// Returns: A `Map<String, dynamic>` containing serializable representation
  /// of the theme sections. Sections not provided are omitted or set to null.
  Map<String, dynamic> toJson() {
    return {
      'card': card?.toJson(),
      'pillar': pillar?.toJson(),
      'cell': cell?.toJson(),
      'typography': typography?.toJson(),
    };
  }

  /// Deserializes a theme from JSON.
  ///
  /// Parameters:
  /// - [json]: A `Map<String, dynamic>` previously produced by `toJson`.
  ///
  /// Returns: An `EditableFourZhuCardTheme` with all available sections parsed.
  factory EditableFourZhuCardTheme.fromJson(Map<String, dynamic> json) {
    return EditableFourZhuCardTheme(
      card: json['card'] is Map<String, dynamic>
          ? CardSection.fromJson(json['card'] as Map<String, dynamic>)
          : null,
      pillar: json['pillar'] is Map<String, dynamic>
          ? PillarSection.fromJson(json['pillar'] as Map<String, dynamic>)
          : null,
      cell: json['cell'] is Map<String, dynamic>
          ? CellSection.fromJson(json['cell'] as Map<String, dynamic>)
          : null,
      typography: json['typography'] is Map<String, dynamic>
          ? TypographySection.fromJson(
              json['typography'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Validates this theme and returns a list of discovered problems.
  ///
  /// Returns: A list of `ThemeValidationError` entries describing all found
  /// violations. Use `ensureValidOrThrow` to throw immediately on first error.
  List<ThemeValidationError> validate() {
    final errors = <ThemeValidationError>[];

    // Validate card section
    card?.validateInto(errors);
    // Validate pillar section
    pillar?.validateInto(errors);
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
}

/// Pillar-level decoration and per-pillar margin differentiation.
class PillarSection {
  /// Creates pillar decoration settings.
  const PillarSection({
    this.defaultMargin,
    this.defaultPadding,
    this.borderWidth,
    this.borderColor,
    this.cornerRadius,
    this.backgroundColor,
    this.perPillarMargin,
    this.shadowColorFollowsBackground,
    this.shadowColor,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.shadowBlurRadius,
  });

  /// Default outer margin applied to pillars unless overridden.
  final EdgeInsets? defaultMargin;

  /// Default inner padding applied to pillars.
  final EdgeInsets? defaultPadding;

  /// Pillar border width; must be non-negative if provided and not `none`.
  final double? borderWidth;

  /// Pillar border color (nullable for Theme default).
  final Color? borderColor;

  /// Corner radius in pixels; must be non-negative if provided.
  final double? cornerRadius;

  /// Background color (nullable for transparent/default when not set).
  final Color? backgroundColor;

  /// Differentiated outer margins per pillar type.
  /// Only keys in {year, month, day, hour, luckCycle} are allowed.
  final Map<PillarType, EdgeInsets>? perPillarMargin;

  /// When true, shadow color should follow the `backgroundColor`.
  /// If no background color is set, shadow is considered not present.
  final bool? shadowColorFollowsBackground;

  /// Box shadow color for pillar containers.
  final Color? shadowColor;

  /// Box shadow offset X (horizontal), in logical pixels.
  final double? shadowOffsetX;

  /// Box shadow offset Y (vertical), in logical pixels.
  final double? shadowOffsetY;

  /// Box shadow blur radius; must be non-negative if provided.
  final double? shadowBlurRadius;

  /// Serializes this section to JSON.
  ///
  /// Returns: A `Map<String, dynamic>` including default decorations and
  /// per-pillar margins keyed by `PillarType.name`.
  Map<String, dynamic> toJson() {
    return {
      'defaultMargin': _edgeToJson(defaultMargin),
      'defaultPadding': _edgeToJson(defaultPadding),
      'borderWidth': borderWidth,
      'borderColor': borderColor?.value,
      'cornerRadius': cornerRadius,
      'backgroundColor': backgroundColor?.value,
      'perPillarMargin': perPillarMargin?.map(
        (k, v) => MapEntry(k.name, _edgeToJson(v)),
      ),
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
  /// - [json]: A `Map<String, dynamic>` with serialized pillar settings.
  ///
  /// Returns: A `PillarSection` populated from the provided map.
  factory PillarSection.fromJson(Map<String, dynamic> json) {
    final ppmRaw = json['perPillarMargin'];
    Map<PillarType, EdgeInsets>? ppm;
    if (ppmRaw is Map<String, dynamic>) {
      ppm = ppmRaw.map((key, value) {
        final ptype = PillarType.values.firstWhere(
          (e) => e.name == key,
          orElse: () => PillarType.year,
        );

        /// Ensure non-null EdgeInsets for map values; fallback to zero margins.
        final edge = _edgeFromJson(value) ?? EdgeInsets.zero;
        return MapEntry(ptype, edge);
      });
    }

    return PillarSection(
      defaultMargin: _edgeFromJson(json['defaultMargin']),
      defaultPadding: _edgeFromJson(json['defaultPadding']),
      borderWidth: (json['borderWidth'] as num?)?.toDouble(),
      borderColor:
          json['borderColor'] is int ? Color(json['borderColor'] as int) : null,
      cornerRadius: (json['cornerRadius'] as num?)?.toDouble(),
      backgroundColor: json['backgroundColor'] is int
          ? Color(json['backgroundColor'] as int)
          : null,
      perPillarMargin: ppm,
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
  /// appended. Validates non-negative constraints and allowed keys.
  void validateInto(List<ThemeValidationError> out) {
    _validateEdgeInsetsNonNegative('pillar.defaultMargin', defaultMargin, out);
    _validateEdgeInsetsNonNegative(
        'pillar.defaultPadding', defaultPadding, out);
    if (borderWidth != null && borderWidth! < 0) {
      out.add(const ThemeValidationError(
        scope: 'pillar.borderWidth',
        message: 'Border width must be non-negative.',
      ));
    }
    if (cornerRadius != null && cornerRadius! < 0) {
      out.add(const ThemeValidationError(
        scope: 'pillar.cornerRadius',
        message: 'Corner radius must be non-negative.',
      ));
    }
    if (shadowBlurRadius != null && shadowBlurRadius! < 0) {
      out.add(const ThemeValidationError(
        scope: 'pillar.shadowBlurRadius',
        message: 'Shadow blur radius must be non-negative.',
      ));
    }
    if (perPillarMargin != null) {
      final allowed = {
        PillarType.year,
        PillarType.month,
        PillarType.day,
        PillarType.hour,
        PillarType.luckCycle,
      };
      for (final entry in perPillarMargin!.entries) {
        if (!allowed.contains(entry.key)) {
          out.add(ThemeValidationError(
            scope: 'pillar.perPillarMargin',
            message:
                'Unsupported PillarType for margin differentiation: ${entry.key.name}.',
          ));
        }
        _validateEdgeInsetsNonNegative(
          'pillar.perPillarMargin.${entry.key.name}',
          entry.value,
          out,
        );
      }
    }
  }
}

/// Cell-level decoration defaults; row-wise overrides remain in RowConfig.
class CellSection {
  /// Creates cell decoration settings.
  const CellSection({this.defaultPadding, this.defaultBorderWidth});

  /// Default inner padding applied to non-title cells.
  final EdgeInsets? defaultPadding;

  /// Default border width applied to cell dividers.
  final double? defaultBorderWidth;

  /// Serializes this section to JSON.
  ///
  /// Returns: A `Map<String, dynamic>` containing default padding and border width.
  Map<String, dynamic> toJson() {
    return {
      'defaultPadding': _edgeToJson(defaultPadding),
      'defaultBorderWidth': defaultBorderWidth,
    };
  }

  /// Deserializes this section from JSON.
  ///
  /// Parameters:
  /// - [json]: A `Map<String, dynamic>` with serialized cell settings.
  ///
  /// Returns: A `CellSection` populated from the provided map.
  factory CellSection.fromJson(Map<String, dynamic> json) {
    return CellSection(
      defaultPadding: _edgeFromJson(json['defaultPadding']),
      defaultBorderWidth: (json['defaultBorderWidth'] as num?)?.toDouble(),
    );
  }

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
}

/// Typography section defines global text family and fallback behaviors.
class TypographySection {
  /// Creates typography defaults.
  const TypographySection({
    this.globalFontFamily,
    this.globalFontSize,
    this.globalFontColor,
    this.preferredFamilies,
  });

  /// Theme-level default font family; used if row-specific is absent.
  final String? globalFontFamily;

  /// Theme-level default font size for general rows.
  final double? globalFontSize;

  /// Theme-level default text color.
  final Color? globalFontColor;

  /// Ordered list of preferred font families for fallback.
  /// Resolution priority: row-specific → theme [globalFontFamily] → first of [preferredFamilies] → system default.
  final List<String>? preferredFamilies;

  /// Serializes this section to JSON.
  ///
  /// Returns: A `Map<String, dynamic>` with global text family/size/color and
  /// preferred fallback families for resolution.
  Map<String, dynamic> toJson() {
    return {
      'globalFontFamily': globalFontFamily,
      'globalFontSize': globalFontSize,
      'globalFontColor': globalFontColor?.value,
      'preferredFamilies': preferredFamilies,
    };
  }

  /// Deserializes this section from JSON.
  ///
  /// Parameters:
  /// - [json]: A `Map<String, dynamic>` with serialized typography settings.
  ///
  /// Returns: A `TypographySection` populated from the provided map.
  factory TypographySection.fromJson(Map<String, dynamic> json) {
    return TypographySection(
      globalFontFamily: json['globalFontFamily'] as String?,
      globalFontSize: (json['globalFontSize'] as num?)?.toDouble(),
      globalFontColor: json['globalFontColor'] is int
          ? Color(json['globalFontColor'] as int)
          : null,
      preferredFamilies: (json['preferredFamilies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
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
