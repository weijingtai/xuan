import 'metrics.dart';

/// Base class for drag state
sealed class DragState {
  const DragState();
}

/// Idle state - no dragging
class IdleDragState extends DragState {
  const IdleDragState();
}

/// Column dragging state
class ColumnDragging extends DragState {
  final int currentIndex;
  final String pillarUuid;

  const ColumnDragging({
    required this.currentIndex,
    required this.pillarUuid,
  });
}

/// Row dragging state
class RowDragging extends DragState {
  final int currentIndex;
  final String rowUuid;

  const RowDragging({
    required this.currentIndex,
    required this.rowUuid,
  });
}

/// Enhanced snapshot that extends CardMetricsSnapshot with additional state
class EnhancedCardMetricsSnapshot extends CardMetricsSnapshot {
  final List<String> pillarOrderUuid;
  final List<String> rowOrderUuid;
  final Map<int, double> columnWidthOverrides;
  final Map<int, double> rowHeightOverrides;
  final DragState dragState;

  const EnhancedCardMetricsSnapshot({
    required super.pillars,
    required super.rows,
    required super.cells,
    required super.totals,
    required super.defaultGlobalPillarMetric,
    required super.defaultGlobalRowMetric,
    required super.defaultGlobalCellMetric,
    required this.pillarOrderUuid,
    required this.rowOrderUuid,
    required this.columnWidthOverrides,
    required this.rowHeightOverrides,
    required this.dragState,
  });

  EnhancedCardMetricsSnapshot copyWith({
    Map<String, PillarMetrics>? pillars,
    Map<String, RowMetrics>? rows,
    Map<String, CellMetrics>? cells,
    CardTotals? totals,
    PillarMetrics? defaultGlobalPillarMetric,
    RowMetrics? defaultGlobalRowMetric,
    CellMetrics? defaultGlobalCellMetric,
    List<String>? pillarOrderUuid,
    List<String>? rowOrderUuid,
    Map<int, double>? columnWidthOverrides,
    Map<int, double>? rowHeightOverrides,
    DragState? dragState,
  }) {
    return EnhancedCardMetricsSnapshot(
      pillars: pillars ?? this.pillars,
      rows: rows ?? this.rows,
      cells: cells ?? this.cells,
      totals: totals ?? this.totals,
      defaultGlobalPillarMetric:
          defaultGlobalPillarMetric ?? this.defaultGlobalPillarMetric,
      defaultGlobalRowMetric:
          defaultGlobalRowMetric ?? this.defaultGlobalRowMetric,
      defaultGlobalCellMetric:
          defaultGlobalCellMetric ?? this.defaultGlobalCellMetric,
      pillarOrderUuid: pillarOrderUuid ?? this.pillarOrderUuid,
      rowOrderUuid: rowOrderUuid ?? this.rowOrderUuid,
      columnWidthOverrides: columnWidthOverrides ?? this.columnWidthOverrides,
      rowHeightOverrides: rowHeightOverrides ?? this.rowHeightOverrides,
      dragState: dragState ?? this.dragState,
    );
  }
}
