import 'package:flutter/material.dart';

import 'package:common/enums/layout_template_enums.dart';

/// Specification for cell text metrics used in size calculations
class CellTextSpec {
  final String rowUuid;
  final String pillarUuid;
  final int charCount;
  final double? fontSize;

  const CellTextSpec({
    required this.rowUuid,
    required this.pillarUuid,
    required this.charCount,
    this.fontSize,
  });
}

/// Metrics for a single pillar (column)
class PillarMetrics {
  final String pillarUuid;
  final PillarType pillarType;
  final double contentWidth;
  final double contentHeight;
  final double decorationWidth;
  final double decorationHeight;
  final double marginHorizontal;
  final double marginVertical;
  final double borderWidth;
  final bool withBorder;

  const PillarMetrics({
    required this.pillarUuid,
    required this.pillarType,
    required this.contentWidth,
    required this.contentHeight,
    required this.decorationWidth,
    required this.decorationHeight,
    required this.marginHorizontal,
    required this.marginVertical,
    required this.borderWidth,
    required this.withBorder,
  });
  double get width {
    if (withBorder) {
      return decorationWidth + contentWidth + borderWidth * 2;
    } else {
      return decorationWidth + contentWidth;
    }
  }

  double get totalWidth => width + marginHorizontal;
  double get height {
    if (withBorder) {
      return decorationHeight + contentHeight + borderWidth * 2;
    } else {
      return decorationHeight + contentHeight;
    }
  }

  double get totalHeight => height + marginVertical;
}

/// Metrics for a single row
class RowMetrics {
  final String rowUuid;
  final RowType rowType;
  final double contentHeight;
  final double decorationHeight;
  final double marginVertical;
  final double borderWidth;
  final bool withBorder;

  const RowMetrics({
    required this.rowUuid,
    required this.rowType,
    required this.contentHeight,
    required this.decorationHeight,
    required this.marginVertical,
    required this.borderWidth,
    required this.withBorder,
  });
  double get height {
    if (withBorder) {
      return decorationHeight + contentHeight + borderWidth * 2;
    } else {
      return decorationHeight + contentHeight;
    }
  }

  double get totalHeight => height + marginVertical;
}

/// Metrics for a single cell
class CellMetrics {
  final String rowUuid;
  final String pillarUuid;
  final double contentWidth;
  final double contentHeight;
  final double decorationWidth;
  final double decorationHeight;
  final double marginHorizontal;
  final double marginVertical;
  final double borderWidth;
  final bool withBorder;

  const CellMetrics({
    required this.rowUuid,
    required this.pillarUuid,
    required this.contentWidth,
    required this.contentHeight,
    required this.decorationWidth,
    required this.decorationHeight,
    required this.marginHorizontal,
    required this.marginVertical,
    required this.borderWidth,
    required this.withBorder,
  });
  double get height {
    if (withBorder) {
      return decorationHeight + contentHeight + borderWidth * 2;
    } else {
      return decorationHeight + contentHeight;
    }
  }

  double get width {
    if (withBorder) {
      return decorationWidth + contentWidth + borderWidth * 2;
    } else {
      return decorationWidth + contentWidth;
    }
  }

  Size get size => Size(width, height);
  double get totalHeight => height + marginVertical * 2;
  double get totalWidth => width + marginHorizontal;
  Size get totalSize => Size(totalWidth, totalHeight);
}

/// Total card metrics
class CardTotals {
  final double totalWidth;
  final double totalHeight;
  final int columnCount;
  final int rowCount;

  const CardTotals({
    required this.totalWidth,
    required this.totalHeight,
    required this.columnCount,
    required this.rowCount,
  });

  CardTotals copyWith({
    double? totalWidth,
    double? totalHeight,
    int? columnCount,
    int? rowCount,
  }) {
    return CardTotals(
      totalWidth: totalWidth ?? this.totalWidth,
      totalHeight: totalHeight ?? this.totalHeight,
      columnCount: columnCount ?? this.columnCount,
      rowCount: rowCount ?? this.rowCount,
    );
  }
}

/// Snapshot of all card metrics
class CardMetricsSnapshot {
  final Map<String, PillarMetrics> pillars;
  final Map<String, RowMetrics> rows;
  final Map<String, CellMetrics> cells;
  final CardTotals totals;

  // Default global metrics for drag previews and placeholders
  final PillarMetrics defaultGlobalPillarMetric;
  final RowMetrics defaultGlobalRowMetric;
  final CellMetrics defaultGlobalCellMetric;

  const CardMetricsSnapshot({
    required this.pillars,
    required this.rows,
    required this.cells,
    required this.totals,
    required this.defaultGlobalPillarMetric,
    required this.defaultGlobalRowMetric,
    required this.defaultGlobalCellMetric,
  });
}

/// Options for computing card metrics
class MetricsComputeOptions {
  // final bool includeGripRows;
  // final bool includeGripCols;
  final bool includeGrip;
  final bool showTitleRow;
  final bool showTitleCol;
  final bool cellShowsTitle;
  final EdgeInsets? cardPadding;
  final bool withCardBorder;
  final double? cardBorderWidth;
  final double gripRowHeight;
  final double gripColWidth;
  final double columnTitleHeight;
  final double rowTitleWidth;

  const MetricsComputeOptions({
    required this.includeGrip,
    // required this.includeGripCols,
    required this.showTitleRow,
    required this.showTitleCol,
    required this.cellShowsTitle,
    this.cardPadding,
    required this.withCardBorder,
    this.cardBorderWidth,
    required this.gripRowHeight,
    required this.gripColWidth,
    required this.columnTitleHeight,
    required this.rowTitleWidth,
  });
}
