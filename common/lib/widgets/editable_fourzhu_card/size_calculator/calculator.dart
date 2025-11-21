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
  final Map<String, CellTextSpec> cellTextSpecMap;
  final double avgGlyphWidthScale;

  CardMetricsSnapshot? _snapshot;

  CardMetricsCalculator({
    required this.theme,
    required this.payload,
    this.defaultPillarWidth = 32.0,
    this.lineHeightFactor = 1.4,
    this.cellTextSpecMap = const {},
    this.avgGlyphWidthScale = 1.2,
  });

  Size computeFinalSize(MetricsComputeOptions options) {
    final s = _snapshot ?? compute();
    double w = s.totals.totalWidth;
    double h = s.totals.totalHeight;

    print("=== computeFinalSize START ===");
    print("基础宽度 totalWidth: $w");

    if (options.includeGripCols) {
      final gripW = _normalizeDouble(options.gripColWidth) * 2;
      w += gripW;
      print("+ Grip cols: $gripW, 累计: $w");
    }
    if (options.includeGripRows) {
      h += _normalizeDouble(options.gripRowHeight) * 2;
    }

    final hasTitleColInPayload = payload.pillarMap.values
        .any((p) => p.pillarType == PillarType.rowTitleColumn);
    final hasTitleRowInPayload =
        payload.rowMap.values.any((r) => r.rowType == RowType.columnHeaderRow);

    print("hasTitleColInPayload: $hasTitleColInPayload");
    print("rowTitleWidth: ${options.rowTitleWidth}");

    if (options.showTitleCol && !hasTitleColInPayload) {
      final titleW = _normalizeDouble(options.rowTitleWidth);
      w += titleW;
      print("+ Row title width: $titleW, 累计: $w");
    } else {
      print("跳过 row title (已在payload中)");
    }

    if (options.showTitleRow) {
      h += _normalizeDouble(options.columnTitleHeight);
    }

    // Padding and border are applied by Container decoration, not included in content size
    final pad = options.cardPadding ?? EdgeInsets.zero;
    final padW = _normalizeDouble(pad.left + pad.right);
    w += padW;
    h += _normalizeDouble(pad.top + pad.bottom);
    print("+ Padding: $padW, 累计: $w");

    final bw = _normalizeDouble(options.cardBorderWidth ?? 0.0);
    final borderW = bw * 2;
    w += borderW;
    h += bw * 2;
    print("+ Border: $borderW, 累计: $w");
    print("=== 最终宽度: $w ===\n");

    return Size(w, h);
  }

  /// 计算卡片最终尺寸（不重复叠加列垂直装饰），并根据可选项聚合
  /// - 基础宽度：所有列的 `contentWidth + decorationWidth` 之和
  /// - 基础高度：所有行的 `contentHeight + decorationHeight` 之和
  /// - 选项叠加：抓手行/列、标题行/列（若未在 payload 中且 cell 不显示 title）、卡片级 padding 与 border
  Size getCardSize(MetricsComputeOptions options) {
    final s = _snapshot ?? compute();
    double baseW = 0.0;
    double baseH = 0.0;
    for (final pm in s.pillars.values) {
      baseW += _normalizeDouble(pm.contentWidth + pm.decorationWidth);
    }
    for (final rm in s.rows.values) {
      baseH += _normalizeDouble(rm.contentHeight + rm.decorationHeight);
    }

    bool hasTitleColInPayload = payload.pillarMap.values
        .any((p) => p.pillarType == PillarType.rowTitleColumn);
    bool hasTitleRowInPayload =
        payload.rowMap.values.any((r) => r.rowType == RowType.columnHeaderRow);

    double w = baseW;
    double h = baseH;

    if (options.includeGripCols) {
      w += _normalizeDouble(options.gripColWidth);
    }
    if (options.includeGripRows) {
      h += _normalizeDouble(options.gripRowHeight);
    }
    if (options.showTitleCol &&
        !options.cellShowsTitle &&
        !hasTitleColInPayload) {
      w += _normalizeDouble(options.rowTitleWidth);
    }
    if (options.showTitleRow &&
        !options.cellShowsTitle &&
        !hasTitleRowInPayload) {
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

  /// 通过 `pillarUuid` 获取该列的最终尺寸
  /// - 宽度：`contentWidth + decorationWidth`
  /// - 高度：所有行的 `contentHeight + decorationHeight` 之和
  Size getPillarSize(String pillarUuid) {
    final s = _snapshot ?? compute();
    final pm = s.pillars[pillarUuid];
    if (pm == null) return Size.zero;
    final w = _normalizeDouble(pm.contentWidth + pm.decorationWidth);
    double h = 0.0;
    for (final rm in s.rows.values) {
      h += _normalizeDouble(rm.contentHeight + rm.decorationHeight);
    }
    return Size(w, h);
  }

  /// 获取单元格最终尺寸（内容 + 装饰），由 `rowUuid + pillarUuid` 唯一定位
  Size getCellFinalSize(String rowUuid, String pillarUuid) {
    final c = getCell(rowUuid, pillarUuid);
    if (c == null) return Size.zero;
    return Size(
      _normalizeDouble(c.contentWidth + c.decorationWidth),
      _normalizeDouble(c.contentHeight + c.decorationHeight),
    );
  }

  /// 计算并生成当前卡片的度量快照
  ///
  /// 功能说明：
  /// - 遍历 `payload` 中的列与行顺序，分别计算并填充 `PillarMetrics`、`RowMetrics`；
  /// - 基于列与行的度量，组合生成每个单元格的 `CellMetrics`（内容尺寸与装饰/边距/边框分离）；
  /// - 汇总得到卡片的 `CardTotals`：
  ///   - 总宽度为所有列的「内容宽 + 列装饰宽」之和；
  ///   - 总高度为所有行的「内容高 + 行装饰高」之和，再加上「列垂直装饰高度」的最大值（列装饰包裹整列，只叠加一次）；
  /// - 所有参与度量的数值均通过 `_normalizeDouble` 做鲁棒性处理，避免负值、NaN、Infinity 导致布局异常。
  ///
  /// 参数：无（使用构造时注入的 `theme` 与 `payload`）。
  /// 返回：`CardMetricsSnapshot`，包含 `pillars/rows/cells/totals` 四类度量数据。
  CardMetricsSnapshot compute() {
    final pillarOrder = payload.pillarOrderUuid;
    final rowOrder = payload.rowOrderUuid;
    final pillarMap = payload.pillarMap;
    final rowMap = payload.rowMap;

    final pillars = <String, PillarMetrics>{};
    final rows = <String, RowMetrics>{};
    final cells = <String, CellMetrics>{};

    // 1) 先按行类型计算每行的内容高与装饰高，并生成所有单元格度量
    for (final rowUuid in rowOrder) {
      final r = rowMap[rowUuid];
      if (r == null) continue;
      final rt = r.rowType;
      final rowContentH = _rowContentHeight(rt);
      final rowDecH = theme.cell.getDecorationHeightBy(rt);
      final rowMarginV = _edgeV(theme.cell.getBy(rt).margin);
      final rowBorderW = theme.cell.getBy(rt).border?.width ?? 0.0;

      rows[rowUuid] = RowMetrics(
        rowUuid: rowUuid,
        rowType: rt.name,
        contentHeight: rowContentH,
        decorationHeight: rowDecH,
        marginVertical: rowMarginV,
        borderWidth: rowBorderW,
      );

      for (final pillarUuid in pillarOrder) {
        final p = pillarMap[pillarUuid];
        if (p == null) continue;
        final decW = theme.cell.getDecorationWidthBy(rt);
        final decH = rowDecH;
        final mH = _edgeH(theme.cell.getBy(rt).margin);
        final mV = rowMarginV;
        final bW = rowBorderW;
        double contentW = defaultPillarWidth;
        final spec = cellTextSpecMap[_cellKey(rowUuid, pillarUuid)];
        if (spec != null) {
          final fs = spec.fontSize ??
              theme.typography
                  .getCellContentBy(rt)
                  .fontStyleDataModel
                  .fontSize ??
              14.0;
          contentW = _normalizeDouble(spec.charCount * fs * avgGlyphWidthScale);
        } else {
          // 调试：cellTextSpecMap 中没有此 cell 的 spec
          if (pillars.length == 5) {
            // 只在异常情况下打印
            print(
                "⚠️ Cell spec missing for row=${rowMap[rowUuid]?.rowType}, pillar=${p.pillarType}");
          }
        }
        final contentH = rowContentH;
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

    // 2) 计算列度量与总宽
    double totalWidth = 0.0;
    for (final pillarUuid in pillarOrder) {
      final p = pillarMap[pillarUuid];
      if (p == null) continue;
      final pt = p.pillarType;
      final decW = theme.pillar.getDecorationWidthBy(pt);
      final decH = theme.pillar.getDecorationHeightBy(pt);
      double maxCellW = 0.0;
      int cellCount = 0;
      for (final rowUuid in rowOrder) {
        final cm = cells[_cellKey(rowUuid, pillarUuid)];
        if (cm == null) continue;
        cellCount++;
        final cellW = _normalizeDouble(cm.contentWidth + cm.decorationWidth);
        if (cellW > maxCellW) maxCellW = cellW;
      }
      final contentW = (maxCellW > 0.0)
          ? _normalizeDouble(maxCellW)
          : _normalizeDouble(defaultPillarWidth);

      // 调试：检测使用默认宽度的情况
      if (contentW == defaultPillarWidth && cellCount > 0) {
        print(
            "⚠️ Pillar ${p.pillarType} 使用默认宽度 $defaultPillarWidth (cellCount=$cellCount, maxCellW=$maxCellW)");
      }
      const contentH = 0.0;
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

    // 3) 计算总高（由所有行的最终高度决定）
    double totalHeight = 0.0;
    for (final rowUuid in rowOrder) {
      final rm = rows[rowUuid];
      if (rm == null) continue;
      totalHeight += _normalizeDouble(rm.contentHeight + rm.decorationHeight);
    }

    final totalW = pillars.values.fold(0.0, (sum, p) => sum + p.width);

    // 只在宽度异常时打印详细信息
    if ((totalW - 272).abs() > 1.0) {
      print("\n" + "!" * 60);
      print("!!! ANOMALY DETECTED: totalWidth = $totalW (expected ~272) !!!");
      print("!" * 60);
      print("=== PILLARS DEBUG (compute) ===");
      print("Pillar 数量: ${pillars.length}");
      for (final entry in pillars.entries) {
        final uuid = entry.key;
        final pm = entry.value;
        final pillarPayload = payload.pillarMap[uuid];
        final pillarType = pillarPayload?.pillarType.toString() ?? 'unknown';
        print(
            "  UUID: ${uuid.substring(0, 8)}... Type: $pillarType, width: ${pm.width} "
            "(content: ${pm.contentWidth}, decoration: ${pm.decorationWidth})");
      }
      print("Total Width (sum): $totalW");
      print("=== END PILLARS DEBUG ===");
      print("!" * 60 + "\n");
    }

    final totals = CardTotals(
      totalWidth: _normalizeDouble(totalW),
      totalHeight: _normalizeDouble(totalHeight),
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

  Size getCellSize(String rowUuid, String pillarUuid) {
    final c = getCell(rowUuid, pillarUuid);
    if (c == null) return Size.zero;
    return Size(
      _normalizeDouble(c.contentWidth),
      _normalizeDouble(c.contentHeight),
    );
  }

  Size getCellDecorationSize(String rowUuid, String pillarUuid) {
    final c = getCell(rowUuid, pillarUuid);
    if (c == null) return Size.zero;
    return Size(
      _normalizeDouble(c.decorationWidth),
      _normalizeDouble(c.decorationHeight),
    );
  }

  double _rowContentHeight(RowType rt) {
    final ts = theme.typography.getCellContentBy(rt);
    final fontSize = ts.fontStyleDataModel.fontSize ?? 16.0;
    final h = (fontSize * lineHeightFactor).toInt().toDouble();
    if (rt == RowType.separator) {
      return 8.0;
    }
    if (rt == RowType.columnHeaderRow) {
      final t = theme.typography.getCellContentBy(rt);
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
