import 'package:flutter/material.dart';

import '../../../enums/layout_template_enums.dart';
import '../../../themes/editable_four_zhu_card_theme.dart';
import '../../../models/drag_payloads.dart';
import 'metrics.dart';

class CardMetricsCalculator {
  final EditableFourZhuCardTheme theme;
  final CardPayload payload;
  final double defaultPillarWidth;
  final double lineHeightFactor;

  CardMetricsSnapshot? _snapshot;

  CardMetricsCalculator({
    required this.theme,
    required this.payload,
    this.defaultPillarWidth = 64.0,
    this.lineHeightFactor = 1.4,
  });

  Size computeFinalSize(MetricsComputeOptions options) {
    final s = _snapshot ?? compute();
    double w = s.totals.totalWidth;
    double h = s.totals.totalHeight;

    if (options.includeGripCols) {
      w += _normalizeDouble(options.gripColWidth);
    }
    if (options.includeGripRows) {
      h += _normalizeDouble(options.gripRowHeight);
    }

    final hasTitleColInPayload = payload.pillarMap.values
        .any((p) => p.pillarType == PillarType.rowTitleColumn);
    final hasTitleRowInPayload = payload.rowMap.values
        .any((r) => r.rowType == RowType.columnHeaderRow);

    if (options.showTitleCol && !options.cellShowsTitle && !hasTitleColInPayload) {
      w += _normalizeDouble(options.rowTitleWidth);
    }
    if (options.showTitleRow && !options.cellShowsTitle && !hasTitleRowInPayload) {
      h += _normalizeDouble(options.columnTitleHeight);
    }

    final pad = options.cardPadding ?? EdgeInsets.zero;
    w += _normalizeDouble(pad.left + pad.right);
    h += _normalizeDouble(pad.top + pad.bottom);

    final bw = _normalizeDouble(options.cardBorderWidth ?? 0.0);
    w += bw * 2;
    h += bw * 2;

    return Size(w, h);
  }

  CardMetricsSnapshot compute() {
    final pillarOrder = payload.pillarOrderUuid;
    final rowOrder = payload.rowOrderUuid;
    final pillarMap = payload.pillarMap;
    final rowMap = payload.rowMap;

    final pillars = <String, PillarMetrics>{};
    final rows = <String, RowMetrics>{};
    final cells = <String, CellMetrics>{};

    final pillarDecorationHeights = <double>[];
    double totalWidth = 0.0;

    for (final pillarUuid in pillarOrder) {
      final p = pillarMap[pillarUuid];
      if (p == null) continue;
      final pt = p.pillarType;
      final decW = theme.pillar.getDecorationWidthBy(pt);
      final decH = theme.pillar.getDecorationHeightBy(pt);
      pillarDecorationHeights.add(decH);
      final contentW = _normalizeDouble(defaultPillarWidth);
      final contentH = 0.0;
      final mH = _edgeH(theme.pillar.getBy(pt).margin);
      final mV = _edgeV(theme.pillar.getBy(pt).margin);
      final bW = theme.pillar.getBy(pt).border?.width ?? 0.0;
      final measuredW = contentW + decW;
      totalWidth += measuredW;
      pillars[pillarUuid] = PillarMetrics(
        pillarUuid: pillarUuid,
        pillarType: pt.name,
        contentWidth: contentW,
        contentHeight: contentH,
        decorationWidth: decW,
        decorationHeight: decH,
        marginHorizontal: mH,
        marginVertical: mV,
        borderWidth: bW,
      );
    }

    double totalHeight = 0.0;
    for (final rowUuid in rowOrder) {
      final r = rowMap[rowUuid];
      if (r == null) continue;
      final rt = r.rowType;
      final contentH = _rowContentHeight(rt);
      final decH = theme.cell.getDecorationHeightBy(rt);
      final mV = _edgeV(theme.cell.getBy(rt).margin);
      final bW = theme.cell.getBy(rt).border?.width ?? 0.0;
      final measuredH = contentH + decH;
      totalHeight += measuredH;
      rows[rowUuid] = RowMetrics(
        rowUuid: rowUuid,
        rowType: rt.name,
        contentHeight: contentH,
        decorationHeight: decH,
        marginVertical: mV,
        borderWidth: bW,
      );
    }

    for (final rowUuid in rowOrder) {
      final r = rowMap[rowUuid];
      if (r == null) continue;
      for (final pillarUuid in pillarOrder) {
        final p = pillarMap[pillarUuid];
        if (p == null) continue;
        final rt = r.rowType;
        final decW = theme.cell.getDecorationWidthBy(rt);
        final decH = theme.cell.getDecorationHeightBy(rt);
        final mH = _edgeH(theme.cell.getBy(rt).margin);
        final mV = _edgeV(theme.cell.getBy(rt).margin);
        final bW = theme.cell.getBy(rt).border?.width ?? 0.0;
        final contentW =
            pillars[pillarUuid]?.contentWidth ?? defaultPillarWidth;
        final contentH = rows[rowUuid]?.contentHeight ?? _rowContentHeight(rt);
        final key = _cellKey(rowUuid, pillarUuid);
        cells[key] = CellMetrics(
          rowUuid: rowUuid,
          pillarUuid: pillarUuid,
          contentWidth: _normalizeDouble(contentW),
          contentHeight: _normalizeDouble(contentH),
          decorationWidth: _normalizeDouble(decW),
          decorationHeight: _normalizeDouble(decH),
          marginHorizontal: _normalizeDouble(mH),
          marginVertical: _normalizeDouble(mV),
          borderWidth: _normalizeDouble(bW),
        );
      }
    }

    final maxPillarDecH = pillarDecorationHeights.isEmpty
        ? 0.0
        : pillarDecorationHeights.reduce((a, b) => a > b ? a : b);
    final totals = CardTotals(
      totalWidth: _normalizeDouble(totalWidth),
      totalHeight: _normalizeDouble(totalHeight + maxPillarDecH),
      columnCount: pillarOrder.length,
      rowCount: rowOrder.length,
    );

    _snapshot = CardMetricsSnapshot(
      pillars: pillars,
      rows: rows,
      cells: cells,
      totals: totals,
    );
    return _snapshot!;
  }

  CellMetrics? getCell(String rowUuid, String pillarUuid) {
    final s = _snapshot;
    if (s == null) return null;
    return s.cells[_cellKey(rowUuid, pillarUuid)];
  }

  PillarMetrics? getPillar(String pillarUuid) {
    final s = _snapshot;
    if (s == null) return null;
    return s.pillars[pillarUuid];
  }

  CardTotals? getTotals() {
    final s = _snapshot;
    if (s == null) return null;
    return s.totals;
  }

  double _rowContentHeight(RowType rt) {
    final ts = theme.typography.getCellContentBy(rt);
    final fontSize = ts.fontStyleDataModel.fontSize ?? 16.0;
    final h = fontSize * lineHeightFactor;
    if (rt == RowType.separator) {
      return 8.0;
    }
    if (rt == RowType.columnHeaderRow) {
      final t = theme.typography.getCellTitleBy(rt);
      final fs = t.fontStyleDataModel.fontSize ?? fontSize;
      return fs * lineHeightFactor;
    }
    return _normalizeDouble(h);
  }

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
