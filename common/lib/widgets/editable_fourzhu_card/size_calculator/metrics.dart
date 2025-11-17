import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class CellMetrics extends Equatable {
  final String rowUuid;
  final String pillarUuid;
  final double contentWidth;
  final double contentHeight;
  final double decorationWidth;
  final double decorationHeight;
  final double marginHorizontal;
  final double marginVertical;
  final double borderWidth;

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
  });

  CellMetrics copyWith({
    String? rowUuid,
    String? pillarUuid,
    double? contentWidth,
    double? contentHeight,
    double? decorationWidth,
    double? decorationHeight,
    double? marginHorizontal,
    double? marginVertical,
    double? borderWidth,
  }) {
    return CellMetrics(
      rowUuid: rowUuid ?? this.rowUuid,
      pillarUuid: pillarUuid ?? this.pillarUuid,
      contentWidth: contentWidth ?? this.contentWidth,
      contentHeight: contentHeight ?? this.contentHeight,
      decorationWidth: decorationWidth ?? this.decorationWidth,
      decorationHeight: decorationHeight ?? this.decorationHeight,
      marginHorizontal: marginHorizontal ?? this.marginHorizontal,
      marginVertical: marginVertical ?? this.marginVertical,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  factory CellMetrics.fromJson(Map<String, dynamic> json) {
    return CellMetrics(
      rowUuid: json['rowUuid'] as String,
      pillarUuid: json['pillarUuid'] as String,
      contentWidth: (json['contentWidth'] as num).toDouble(),
      contentHeight: (json['contentHeight'] as num).toDouble(),
      decorationWidth: (json['decorationWidth'] as num).toDouble(),
      decorationHeight: (json['decorationHeight'] as num).toDouble(),
      marginHorizontal: (json['marginHorizontal'] as num).toDouble(),
      marginVertical: (json['marginVertical'] as num).toDouble(),
      borderWidth: (json['borderWidth'] as num).toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'rowUuid': rowUuid,
      'pillarUuid': pillarUuid,
      'contentWidth': contentWidth,
      'contentHeight': contentHeight,
      'decorationWidth': decorationWidth,
      'decorationHeight': decorationHeight,
      'marginHorizontal': marginHorizontal,
      'marginVertical': marginVertical,
      'borderWidth': borderWidth,
    };
  }

  @override
  List<Object?> get props => [
        rowUuid,
        pillarUuid,
        contentWidth,
        contentHeight,
        decorationWidth,
        decorationHeight,
        marginHorizontal,
        marginVertical,
        borderWidth,
      ];
}

@immutable
class PillarMetrics extends Equatable {
  final String pillarUuid;
  final String pillarType;
  final double contentWidth;
  final double contentHeight;
  final double decorationWidth;
  final double decorationHeight;
  final double marginHorizontal;
  final double marginVertical;
  final double borderWidth;

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
  });

  PillarMetrics copyWith({
    String? pillarUuid,
    String? pillarType,
    double? contentWidth,
    double? contentHeight,
    double? decorationWidth,
    double? decorationHeight,
    double? marginHorizontal,
    double? marginVertical,
    double? borderWidth,
  }) {
    return PillarMetrics(
      pillarUuid: pillarUuid ?? this.pillarUuid,
      pillarType: pillarType ?? this.pillarType,
      contentWidth: contentWidth ?? this.contentWidth,
      contentHeight: contentHeight ?? this.contentHeight,
      decorationWidth: decorationWidth ?? this.decorationWidth,
      decorationHeight: decorationHeight ?? this.decorationHeight,
      marginHorizontal: marginHorizontal ?? this.marginHorizontal,
      marginVertical: marginVertical ?? this.marginVertical,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  factory PillarMetrics.fromJson(Map<String, dynamic> json) {
    return PillarMetrics(
      pillarUuid: json['pillarUuid'] as String,
      pillarType: json['pillarType'] as String,
      contentWidth: (json['contentWidth'] as num).toDouble(),
      contentHeight: (json['contentHeight'] as num).toDouble(),
      decorationWidth: (json['decorationWidth'] as num).toDouble(),
      decorationHeight: (json['decorationHeight'] as num).toDouble(),
      marginHorizontal: (json['marginHorizontal'] as num).toDouble(),
      marginVertical: (json['marginVertical'] as num).toDouble(),
      borderWidth: (json['borderWidth'] as num).toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'pillarUuid': pillarUuid,
      'pillarType': pillarType,
      'contentWidth': contentWidth,
      'contentHeight': contentHeight,
      'decorationWidth': decorationWidth,
      'decorationHeight': decorationHeight,
      'marginHorizontal': marginHorizontal,
      'marginVertical': marginVertical,
      'borderWidth': borderWidth,
    };
  }

  @override
  List<Object?> get props => [
        pillarUuid,
        pillarType,
        contentWidth,
        contentHeight,
        decorationWidth,
        decorationHeight,
        marginHorizontal,
        marginVertical,
        borderWidth,
      ];
}

@immutable
class RowMetrics extends Equatable {
  final String rowUuid;
  final String rowType;
  final double contentHeight;
  final double decorationHeight;
  final double marginVertical;
  final double borderWidth;

  const RowMetrics({
    required this.rowUuid,
    required this.rowType,
    required this.contentHeight,
    required this.decorationHeight,
    required this.marginVertical,
    required this.borderWidth,
  });

  RowMetrics copyWith({
    String? rowUuid,
    String? rowType,
    double? contentHeight,
    double? decorationHeight,
    double? marginVertical,
    double? borderWidth,
  }) {
    return RowMetrics(
      rowUuid: rowUuid ?? this.rowUuid,
      rowType: rowType ?? this.rowType,
      contentHeight: contentHeight ?? this.contentHeight,
      decorationHeight: decorationHeight ?? this.decorationHeight,
      marginVertical: marginVertical ?? this.marginVertical,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  factory RowMetrics.fromJson(Map<String, dynamic> json) {
    return RowMetrics(
      rowUuid: json['rowUuid'] as String,
      rowType: json['rowType'] as String,
      contentHeight: (json['contentHeight'] as num).toDouble(),
      decorationHeight: (json['decorationHeight'] as num).toDouble(),
      marginVertical: (json['marginVertical'] as num).toDouble(),
      borderWidth: (json['borderWidth'] as num).toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'rowUuid': rowUuid,
      'rowType': rowType,
      'contentHeight': contentHeight,
      'decorationHeight': decorationHeight,
      'marginVertical': marginVertical,
      'borderWidth': borderWidth,
    };
  }

  @override
  List<Object?> get props => [
        rowUuid,
        rowType,
        contentHeight,
        decorationHeight,
        marginVertical,
        borderWidth,
      ];
}

@immutable
class CardTotals extends Equatable {
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

  factory CardTotals.fromJson(Map<String, dynamic> json) {
    return CardTotals(
      totalWidth: (json['totalWidth'] as num).toDouble(),
      totalHeight: (json['totalHeight'] as num).toDouble(),
      columnCount: (json['columnCount'] as num).toInt(),
      rowCount: (json['rowCount'] as num).toInt(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'totalWidth': totalWidth,
      'totalHeight': totalHeight,
      'columnCount': columnCount,
      'rowCount': rowCount,
    };
  }

  @override
  List<Object?> get props => [totalWidth, totalHeight, columnCount, rowCount];
}

class MetricsComputeOptions {
  final bool includeGripRows;
  final bool includeGripCols;
  final bool showTitleRow;
  final bool showTitleCol;
  final bool cellShowsTitle;
  final EdgeInsets? cardPadding;
  final double? cardBorderWidth;
  final double gripRowHeight;
  final double gripColWidth;
  final double columnTitleHeight;
  final double rowTitleWidth;

  const MetricsComputeOptions({
    this.includeGripRows = false,
    this.includeGripCols = false,
    this.showTitleRow = false,
    this.showTitleCol = false,
    this.cellShowsTitle = false,
    this.cardPadding,
    this.cardBorderWidth,
    this.gripRowHeight = 20.0,
    this.gripColWidth = 20.0,
    this.columnTitleHeight = 24.0,
    this.rowTitleWidth = 52.0,
  });
}

@immutable
class CardMetricsSnapshot extends Equatable {
  final Map<String, PillarMetrics> pillars;
  final Map<String, RowMetrics> rows;
  final Map<String, CellMetrics> cells;
  final CardTotals totals;

  const CardMetricsSnapshot({
    required this.pillars,
    required this.rows,
    required this.cells,
    required this.totals,
  });

  CardMetricsSnapshot copyWith({
    Map<String, PillarMetrics>? pillars,
    Map<String, RowMetrics>? rows,
    Map<String, CellMetrics>? cells,
    CardTotals? totals,
  }) {
    return CardMetricsSnapshot(
      pillars: pillars ?? this.pillars,
      rows: rows ?? this.rows,
      cells: cells ?? this.cells,
      totals: totals ?? this.totals,
    );
  }

  factory CardMetricsSnapshot.fromJson(Map<String, dynamic> json) {
    final pillarsJson = json['pillars'] as Map<String, dynamic>;
    final rowsJson = json['rows'] as Map<String, dynamic>;
    final cellsJson = json['cells'] as Map<String, dynamic>;
    return CardMetricsSnapshot(
      pillars: pillarsJson.map(
        (k, v) =>
            MapEntry(k, PillarMetrics.fromJson(v as Map<String, dynamic>)),
      ),
      rows: rowsJson.map(
        (k, v) => MapEntry(k, RowMetrics.fromJson(v as Map<String, dynamic>)),
      ),
      cells: cellsJson.map(
        (k, v) => MapEntry(k, CellMetrics.fromJson(v as Map<String, dynamic>)),
      ),
      totals: CardTotals.fromJson(json['totals'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'pillars': pillars.map((k, v) => MapEntry(k, v.toJson())),
      'rows': rows.map((k, v) => MapEntry(k, v.toJson())),
      'cells': cells.map((k, v) => MapEntry(k, v.toJson())),
      'totals': totals.toJson(),
    };
  }

  @override
  List<Object?> get props => [pillars, rows, cells, totals];
}
