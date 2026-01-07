import 'package:flutter/widgets.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/drag_payloads.dart';
import 'calculator.dart';
import 'enhanced_snapshot.dart';
import 'metrics.dart';

class EnhancedCardMetricsCalculator extends CardMetricsCalculator {
  EnhancedCardMetricsCalculator({
    required super.theme,
    required super.payload,
    super.defaultPillarWidth,
    super.lineHeightFactor,
    super.cellTextSpecMap,
    super.avgGlyphWidthScale,
  });

  EnhancedCardMetricsSnapshot? _enhancedSnapshot;

  void adoptSnapshot(EnhancedCardMetricsSnapshot snapshot) {
    _enhancedSnapshot = snapshot;
  }

  @override
  EnhancedCardMetricsSnapshot compute() {
    if (_enhancedSnapshot != null) {
      return _enhancedSnapshot!;
    }
    return _computeFromPayload();
  }

  /// 强制重新计算（从 payload）
  EnhancedCardMetricsSnapshot forceRecompute() {
    return _computeFromPayload();
  }

  EnhancedCardMetricsSnapshot _computeFromPayload() {
    // 调用父类逻辑计算基础度量 (但这会生成 CardMetricsSnapshot)
    // 我们需要自己实现生成 EnhancedCardMetricsSnapshot 的逻辑
    // 或者我们可以利用父类的 compute() 得到基础数据，然后包装？
    // 父类的 compute() 会生成 pillars, rows, cells, totals
    // 但是父类 compute() 内部使用了 payload.pillarOrderUuid 等
    // 如果我们想完全控制，最好自己实现一遍，或者复用父类逻辑但转换结果

    // 这里我们复用父类的 compute() 结果，然后扩展它
    // 注意：父类 compute() 会修改父类的 _snapshot
    final baseSnapshot = super.compute();

    final enhanced = EnhancedCardMetricsSnapshot(
      pillars: baseSnapshot.pillars,
      rows: baseSnapshot.rows,
      cells: baseSnapshot.cells,
      totals: baseSnapshot.totals,
      defaultGlobalPillarMetric: baseSnapshot.defaultGlobalPillarMetric,
      defaultGlobalRowMetric: baseSnapshot.defaultGlobalRowMetric,
      defaultGlobalCellMetric: baseSnapshot.defaultGlobalCellMetric,
      pillarOrderUuid: List.from(payload.pillarOrderUuid),
      rowOrderUuid: List.from(payload.rowOrderUuid),
      columnWidthOverrides: const {}, // 初始无覆盖
      rowHeightOverrides: const {}, // 初始无覆盖
      dragState: const IdleDragState(),
    );

    _enhancedSnapshot = enhanced;
    return enhanced;
  }

  // ===========================================================================
  // 列操作
  // ===========================================================================

  EnhancedCardMetricsSnapshot insertColumn(int index, PillarPayload column) {
    final current = compute();
    final newOrder = List<String>.from(current.pillarOrderUuid);

    // 插入 UUID
    if (index >= newOrder.length) {
      newOrder.add(column.uuid);
    } else {
      newOrder.insert(index, column.uuid);
    }

    // 计算新列的度量
    // 这需要计算该列在每一行的单元格度量，以及列本身的度量
    // 这是一个复杂操作，简单起见，我们可以更新 payload 然后重新计算？
    // 但 payload 是 final 的。
    // 所以我们需要手动计算新列的 metrics 并添加到 pillars 和 cells 中

    final newPillars = Map<String, PillarMetrics>.from(current.pillars);
    final newCells = Map<String, CellMetrics>.from(current.cells);

    // 1. 计算 Cells
    double maxCellW = 0.0;
    final pt = column.pillarType;
    final decW = theme.pillar.getDecorationWidthBy(pt);
    final decH = theme.pillar.getDecorationHeightBy(pt);

    for (final rowUuid in current.rowOrderUuid) {
      final rm = current.rows[rowUuid];
      if (rm == null) continue;

      // 复用父类逻辑计算 cell metrics 需要访问私有方法或复制逻辑
      // 这里我们复制逻辑
      final rt = RowType.values
          .firstWhere((e) => e == rm.rowType); // 假设 rowType name 匹配

      final cellDecW = theme.cell.getDecorationWidthBy(rt);
      final cellDecH = rm.decorationHeight;
      final mH = _edgeH(theme.cell.getBy(rt).margin);
      final mV = rm.marginVertical;
      final bW = rm.borderWidth;

      double contentW = defaultPillarWidth;
      // 检查是否有 TextSpec (通常新插入的列没有，除非预先设置)
      // 这里简化处理，使用默认宽

      final key = _cellKey(rowUuid, column.uuid);
      final cm = CellMetrics(
        rowUuid: rowUuid,
        pillarUuid: column.uuid,
        contentWidth: _normalizeDouble(contentW),
        contentHeight: rm.contentHeight,
        decorationWidth: _normalizeDouble(cellDecW),
        decorationHeight: _normalizeDouble(cellDecH),
        marginHorizontal: _normalizeDouble(mH),
        marginVertical: _normalizeDouble(mV),
        borderWidth: _normalizeDouble(bW),
        withBorder: theme.cell.getBy(rt).border?.enabled ?? false,
      );
      newCells[key] = cm;

      final cellTotalW = _normalizeDouble(cm.contentWidth + cm.decorationWidth);
      if (cellTotalW > maxCellW) maxCellW = cellTotalW;
    }

    // 2. 计算 Pillar Metrics
    final contentW = (maxCellW > 0.0)
        ? _normalizeDouble(maxCellW)
        : _normalizeDouble(defaultPillarWidth);

    final pm = PillarMetrics(
      pillarUuid: column.uuid,
      pillarType: pt,
      contentWidth: contentW,
      contentHeight: 0.0, // 好像父类也是 0
      decorationWidth: decW,
      decorationHeight: decH,
      marginHorizontal: _edgeH(theme.pillar.getBy(pt).margin),
      marginVertical: _edgeV(theme.pillar.getBy(pt).margin),
      borderWidth: theme.pillar.getBy(pt).border?.width ?? 0.0,
      withBorder: theme.pillar.getBy(pt).border?.enabled ?? false,
    );
    newPillars[column.uuid] = pm;

    // 3. 更新 Totals (宽度增加)
    final addedWidth = contentW + decW;
    final newTotals = current.totals.copyWith(
      totalWidth: current.totals.totalWidth + addedWidth,
      columnCount: newOrder.length,
    );

    final next = current.copyWith(
      pillarOrderUuid: newOrder,
      pillars: newPillars,
      cells: newCells,
      totals: newTotals,
    );
    _enhancedSnapshot = next;
    return next;
  }

  EnhancedCardMetricsSnapshot removeColumn(int index) {
    final current = compute();
    if (index < 0 || index >= current.pillarOrderUuid.length) return current;

    final newOrder = List<String>.from(current.pillarOrderUuid);
    final removedUuid = newOrder.removeAt(index);

    // 移除 metrics
    final newPillars = Map<String, PillarMetrics>.from(current.pillars);
    final removedPillar = newPillars.remove(removedUuid);

    final newCells = Map<String, CellMetrics>.from(current.cells);
    newCells.removeWhere((key, _) => key.endsWith('|$removedUuid'));

    // 更新 Totals
    double removedWidth = 0.0;
    if (removedPillar != null) {
      removedWidth = removedPillar.contentWidth + removedPillar.decorationWidth;
    }

    final newTotals = current.totals.copyWith(
      totalWidth: current.totals.totalWidth - removedWidth,
      columnCount: newOrder.length,
    );

    final next = current.copyWith(
      pillarOrderUuid: newOrder,
      pillars: newPillars,
      cells: newCells,
      totals: newTotals,
    );
    _enhancedSnapshot = next;
    return next;
  }

  EnhancedCardMetricsSnapshot reorderColumn(int from, int to) {
    final current = compute();
    final newOrder = List<String>.from(current.pillarOrderUuid);

    if (from < 0 || from >= newOrder.length) return current;

    final item = newOrder.removeAt(from);
    final target = to > from ? to - 1 : to; // 修正索引
    final safeTarget = target.clamp(0, newOrder.length);
    newOrder.insert(safeTarget, item);

    // 更新拖拽状态
    DragState? newDragState = current.dragState;
    if (current.dragState is ColumnDragging) {
      final currentDrag = current.dragState as ColumnDragging;
      if (currentDrag.currentIndex == from) {
        newDragState = ColumnDragging(
          currentIndex: safeTarget,
          pillarUuid: currentDrag.pillarUuid,
        );
      }
    }

    final next = current.copyWith(
      pillarOrderUuid: newOrder,
      dragState: newDragState,
    );
    _enhancedSnapshot = next;
    return next;
  }

  EnhancedCardMetricsSnapshot updateColumnWidth(int index, double width) {
    final current = compute();
    if (index < 0 || index >= current.pillarOrderUuid.length) return current;

    final newOverrides = Map<int, double>.from(current.columnWidthOverrides);
    newOverrides[index] = width;

    // TODO: 应用宽度覆盖到 metrics
    // 这需要重新计算受影响列的 metrics 和 totalWidth
    // 暂时只更新 overrides map，实际生效可能需要更复杂的逻辑
    // 或者我们在 compute() 时应用 overrides?
    // 这里简单处理：只存 override，不实时更新 metrics (除非我们实现完整的重新布局)
    // 但为了 UI 响应，应该更新 metrics。

    final next = current.copyWith(
      columnWidthOverrides: newOverrides,
    );
    _enhancedSnapshot = next;
    return next;
  }

  EnhancedCardMetricsSnapshot clearColumnWidthOverride(int index) {
    final current = compute();
    final newOverrides = Map<int, double>.from(current.columnWidthOverrides);
    newOverrides.remove(index);

    final next = current.copyWith(
      columnWidthOverrides: newOverrides,
    );
    _enhancedSnapshot = next;
    return next;
  }

  // ===========================================================================
  // 行操作 (类似列操作，略)
  // ===========================================================================

  EnhancedCardMetricsSnapshot insertRow(int index, TextRowPayload row) {
    final current = compute();
    final newOrder = List<String>.from(current.rowOrderUuid);

    if (index >= newOrder.length) {
      newOrder.add(row.uuid);
    } else {
      newOrder.insert(index, row.uuid);
    }

    final newRows = Map<String, RowMetrics>.from(current.rows);
    final newCells = Map<String, CellMetrics>.from(current.cells);

    // 1. 计算 Row Metrics
    final rt = row.rowType;
    // 复用父类 _rowContentHeight 逻辑，但它是私有的。
    // 我们需要复制它的逻辑。
    // _rowContentHeight(rt)
    final ts = theme.typography.getCellContentBy(rt);
    final fontSize = ts.fontStyleDataModel.fontSize ?? 16.0;
    double rowContentH = fontSize * lineHeightFactor;
    if (rt == RowType.separator) {
      rowContentH = 8.0;
    } else if (rt == RowType.columnHeaderRow) {
      final t = theme.typography.getCellTitleBy(rt);
      final fs = t.fontStyleDataModel.fontSize ?? fontSize;
      rowContentH = fs * lineHeightFactor;
    } else {
      rowContentH = _normalizeDouble(rowContentH);
    }

    final rowDecH = theme.cell.getDecorationHeightBy(rt);
    final rowMarginV = _edgeV(theme.cell.getBy(rt).margin);
    final rowBorderW = theme.cell.getBy(rt).border?.width ?? 0.0;

    final rm = RowMetrics(
      rowUuid: row.uuid,
      rowType: rt,
      contentHeight: rowContentH,
      decorationHeight: rowDecH,
      marginVertical: rowMarginV,
      borderWidth: rowBorderW,
      withBorder: false,
    );
    newRows[row.uuid] = rm;

    // 2. 计算 Cells
    for (final pillarUuid in current.pillarOrderUuid) {
      final pm = current.pillars[pillarUuid];
      if (pm == null) continue;

      final decW = theme.cell.getDecorationWidthBy(rt);
      final decH = rowDecH;
      final mH = _edgeH(theme.cell.getBy(rt).margin);
      final mV = rowMarginV;
      final bW = rowBorderW;

      double contentW = defaultPillarWidth;
      // 检查 spec map? 新行通常没有 spec

      final key = _cellKey(row.uuid, pillarUuid);
      newCells[key] = CellMetrics(
        rowUuid: row.uuid,
        pillarUuid: pillarUuid,
        contentWidth: _normalizeDouble(contentW),
        contentHeight: _normalizeDouble(rowContentH),
        decorationWidth: _normalizeDouble(decW),
        decorationHeight: _normalizeDouble(decH),
        marginHorizontal: _normalizeDouble(mH),
        marginVertical: _normalizeDouble(mV),
        borderWidth: _normalizeDouble(bW),
        withBorder: theme.cell.getBy(rt).border?.enabled ?? false,
      );
    }

    // 3. 更新 Totals (高度增加)
    final addedHeight =
        _normalizeDouble(rm.contentHeight + rm.decorationHeight);
    final newTotals = current.totals.copyWith(
      totalHeight: current.totals.totalHeight + addedHeight,
      rowCount: newOrder.length,
    );

    final next = current.copyWith(
      rowOrderUuid: newOrder,
      rows: newRows,
      cells: newCells,
      totals: newTotals,
    );
    _enhancedSnapshot = next;
    return next;
  }

  EnhancedCardMetricsSnapshot removeRow(int index) {
    final current = compute();
    if (index < 0 || index >= current.rowOrderUuid.length) return current;

    final newOrder = List<String>.from(current.rowOrderUuid);
    final removedUuid = newOrder.removeAt(index);

    final newRows = Map<String, RowMetrics>.from(current.rows);
    final removedRow = newRows.remove(removedUuid);

    final newCells = Map<String, CellMetrics>.from(current.cells);
    newCells.removeWhere((key, _) => key.startsWith('$removedUuid|'));

    double removedHeight = 0.0;
    if (removedRow != null) {
      removedHeight = removedRow.contentHeight + removedRow.decorationHeight;
    }

    final newTotals = current.totals.copyWith(
      totalHeight: current.totals.totalHeight - removedHeight,
      rowCount: newOrder.length,
    );

    final next = current.copyWith(
      rowOrderUuid: newOrder,
      rows: newRows,
      cells: newCells,
      totals: newTotals,
    );
    _enhancedSnapshot = next;
    return next;
  }

  EnhancedCardMetricsSnapshot reorderRow(int from, int to) {
    final current = compute();
    final newOrder = List<String>.from(current.rowOrderUuid);

    if (from < 0 || from >= newOrder.length) return current;

    final item = newOrder.removeAt(from);
    final target = to > from ? to - 1 : to;
    final safeTarget = target.clamp(0, newOrder.length);
    newOrder.insert(safeTarget, item);

    DragState? newDragState = current.dragState;
    if (current.dragState is RowDragging) {
      final currentDrag = current.dragState as RowDragging;
      if (currentDrag.currentIndex == from) {
        newDragState = RowDragging(
          currentIndex: safeTarget,
          rowUuid: currentDrag.rowUuid,
        );
      }
    }

    final next = current.copyWith(
      rowOrderUuid: newOrder,
      dragState: newDragState,
    );
    _enhancedSnapshot = next;
    return next;
  }

  EnhancedCardMetricsSnapshot updateRowHeight(int index, double height) {
    final current = compute();
    final newOverrides = Map<int, double>.from(current.rowHeightOverrides);
    newOverrides[index] = height;

    final next = current.copyWith(
      rowHeightOverrides: newOverrides,
    );
    _enhancedSnapshot = next;
    return next;
  }

  EnhancedCardMetricsSnapshot clearRowHeightOverride(int index) {
    final current = compute();
    final newOverrides = Map<int, double>.from(current.rowHeightOverrides);
    newOverrides.remove(index);

    final next = current.copyWith(
      rowHeightOverrides: newOverrides,
    );
    _enhancedSnapshot = next;
    return next;
  }

  // ===========================================================================
  // 拖拽支持
  // ===========================================================================

  EnhancedCardMetricsSnapshot startColumnDrag(int index) {
    final current = compute();
    if (index < 0 || index >= current.pillarOrderUuid.length) return current;

    final uuid = current.pillarOrderUuid[index];
    final next = current.copyWith(
      dragState: ColumnDragging(currentIndex: index, pillarUuid: uuid),
    );
    _enhancedSnapshot = next;
    return next;
  }

  EnhancedCardMetricsSnapshot updateColumnDrag(int newIndex) {
    final current = compute();
    if (current.dragState is! ColumnDragging) return current;

    final drag = current.dragState as ColumnDragging;
    if (newIndex != drag.currentIndex) {
      int to = newIndex;
      if (newIndex > drag.currentIndex) {
        to = newIndex + 1;
      }
      return reorderColumn(drag.currentIndex, to);
    }
    return current;
  }

  EnhancedCardMetricsSnapshot endColumnDrag() {
    final current = compute();
    final next = current.copyWith(
      dragState: const IdleDragState(),
    );
    _enhancedSnapshot = next;
    return next;
  }

  EnhancedCardMetricsSnapshot startRowDrag(int index) {
    final current = compute();
    if (index < 0 || index >= current.rowOrderUuid.length) return current;

    final uuid = current.rowOrderUuid[index];
    final next = current.copyWith(
      dragState: RowDragging(currentIndex: index, rowUuid: uuid),
    );
    _enhancedSnapshot = next;
    return next;
  }

  EnhancedCardMetricsSnapshot updateRowDrag(int newIndex) {
    final current = compute();
    if (current.dragState is! RowDragging) return current;

    final drag = current.dragState as RowDragging;
    if (newIndex != drag.currentIndex) {
      int to = newIndex;
      if (newIndex > drag.currentIndex) {
        to = newIndex + 1;
      }
      return reorderRow(drag.currentIndex, to);
    }
    return current;
  }

  EnhancedCardMetricsSnapshot endRowDrag() {
    final current = compute();
    final next = current.copyWith(
      dragState: const IdleDragState(),
    );
    _enhancedSnapshot = next;
    return next;
  }

  // ===========================================================================
  // 覆盖管理
  // ===========================================================================

  Map<int, double> getColumnWidthOverrides() {
    return compute().columnWidthOverrides;
  }

  Map<int, double> getRowHeightOverrides() {
    return compute().rowHeightOverrides;
  }

  // ===========================================================================
  // 幽灵元素尺寸
  // ===========================================================================

  Size getColumnGhostSize() {
    final current = compute();
    if (current.dragState is ColumnDragging) {
      final drag = current.dragState as ColumnDragging;
      return getPillarSize(drag.pillarUuid);
    }
    return Size.zero;
  }

  Size getRowGhostSize() {
    // Row ghost size is tricky because row spans full width?
    // Or just the content height?
    // Usually ghost is the size of the item being dragged.
    // For row, it's width = totalWidth, height = rowHeight.
    final current = compute();
    if (current.dragState is RowDragging) {
      final drag = current.dragState as RowDragging;
      final rm = current.rows[drag.rowUuid];
      if (rm != null) {
        final h = _normalizeDouble(rm.contentHeight + rm.decorationHeight);
        return Size(current.totals.totalWidth, h);
      }
    }
    return Size.zero;
  }

  // Helpers copied from parent because they are static/private
  static String _cellKey(String rowUuid, String pillarUuid) =>
      '$rowUuid|$pillarUuid';

  static double _normalizeDouble(double v) {
    if (v.isNaN || v.isInfinite) return 0.0;
    if (v < 0) return 0.0;
    return v;
  }

  static double _edgeH(EdgeInsets? e) {
    if (e == null) return 0.0;
    final v = e.left + e.right + 0.0;
    return _normalizeDouble(v);
  }

  static double _edgeV(EdgeInsets? e) {
    if (e == null) return 0.0;
    final v = e.top + e.bottom + 0.0;
    return _normalizeDouble(v);
  }
}
