import 'package:flutter/material.dart';

/// Border rendering style for a pillar card.
enum PillarBorderType { none, solid, dashed, dotted }

@Deprecated("Use PillarStyleConfig instead.")

/// Controls visual appearance of a single pillar tile (card-like).
class PillarCardStyle {
  const PillarCardStyle({
    this.borderEnabled = true,
    this.borderType = PillarBorderType.solid,
    this.borderColor,
    this.borderThickness = 1.0,
    this.cornerRadius = 8.0,
    this.backgroundColor,
    this.elevation = 0.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.headerBackgroundColor,
  });

  final bool borderEnabled;
  final PillarBorderType borderType;
  final Color? borderColor;
  final double borderThickness;
  final double cornerRadius;
  final Color? backgroundColor;
  final double elevation;
  final EdgeInsets padding;
  final Color? headerBackgroundColor;
}

/// Placeholder style used during drag-and-drop. Usually mirrors the pillar card style.
@Deprecated("")
class PillarPlaceholderStyle {
  const PillarPlaceholderStyle({
    this.cardStyle = const PillarCardStyle(),
    this.labelTextStyle,
    this.contentTextStyle,
  });

  final PillarCardStyle cardStyle;
  final TextStyle? labelTextStyle;
  final TextStyle? contentTextStyle;
}

/// Column width allocation policy with min/max constraints and gap between columns.

@Deprecated("")
class PillarWidthPolicy {
  const PillarWidthPolicy({
    this.minWidth = 120.0,
    this.maxWidth = 240.0,
    this.gap = 8.0,
    this.compressWiderFirst = true,
  });

  final double minWidth;
  final double maxWidth;
  final double gap;

  /// If true, when space is tight, shrink wider columns first.
  final bool compressWiderFirst;
}

/// Notifies when the desired card width exceeds available constraints.
typedef CardWidthAdjustmentCallback = void Function(double desiredWidth);

/// Resolves per-pillar visual style. Allows per-index customization.
abstract class PillarStyleResolver {
  const PillarStyleResolver();

  PillarCardStyle resolveCardStyle({
    required BuildContext context,
    required int index,
    required int count,
  });

  PillarPlaceholderStyle resolvePlaceholderStyle({
    required BuildContext context,
  });
}

/// Default resolver with uniform style across pillars.
@Deprecated("")
class DefaultPillarStyleResolver extends PillarStyleResolver {
  const DefaultPillarStyleResolver();

  @override
  PillarCardStyle resolveCardStyle({
    required BuildContext context,
    required int index,
    required int count,
  }) {
    final theme = Theme.of(context);
    return PillarCardStyle(
      borderEnabled: true,
      borderType: PillarBorderType.solid,
      borderColor: theme.dividerColor.withValues(alpha: 0.3),
      borderThickness: 1.0,
      cornerRadius: 8.0,
      backgroundColor: theme.colorScheme.surface,
      headerBackgroundColor:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      elevation: 0.0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    );
  }

  @override
  PillarPlaceholderStyle resolvePlaceholderStyle({
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return PillarPlaceholderStyle(
      cardStyle: PillarCardStyle(
        borderEnabled: true,
        borderType: PillarBorderType.solid,
        borderColor: theme.colorScheme.primary,
        borderThickness: 1.0,
        cornerRadius: 8.0,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.06),
      ),
      labelTextStyle: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
      ),
      contentTextStyle: theme.textTheme.bodySmall,
    );
  }
}
