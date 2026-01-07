import 'dart:math';

import 'package:flutter/material.dart';

import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'metrics.dart';

class CardMetricsCalculator {
  final EditableFourZhuCardTheme theme;
  final CardPayload payload;
  final double defaultPillarWidth;
  final double defaultRowHeight;
  final double lineHeightFactor;
  final Map<String, CellTextSpec> cellTextSpecMap;
  final double avgGlyphWidthScale;
  final double defaultSeparatorWidth;
  final Map<String, double> rowHeightOverrides;
  final double rowTitleWidth;

  CardMetricsSnapshot? _snapshot;

  CardMetricsCalculator({
    required this.theme,
    required this.payload,
    this.defaultPillarWidth = 32.0,
    this.lineHeightFactor = 1.4,
    this.cellTextSpecMap = const {},
    this.avgGlyphWidthScale = 1.2,
    this.defaultRowHeight = 48.0,
    this.defaultSeparatorWidth = 8.0,
    this.rowHeightOverrides = const {},
    this.rowTitleWidth = 52.0,
  });

  Size computeFinalSize(MetricsComputeOptions options) {
    final s = _snapshot ?? compute();
    double w = s.totals.totalWidth;
    double h = s.totals.totalHeight;

    if (options.includeGrip) {
      final gripW = _normalizeDouble(options.gripColWidth) * 2;
      w += gripW;
    }
    if (options.includeGrip) {
      h += _normalizeDouble(options.gripRowHeight) * 2;
    }
    // final hasTitleRowInPayload = options.showTitleRow;
    // final hasTitleColInPayload = options.showTitleCol;
    final hasTitleColInPayload = payload.pillarMap.values
        .any((p) => p.pillarType == PillarType.rowTitleColumn);
    final hasTitleRowInPayload =
        payload.rowMap.values.any((r) => r.rowType == RowType.columnHeaderRow);

    if (options.showTitleCol &&
        !options.cellShowsTitle &&
        !hasTitleColInPayload) {
      final titleW = _normalizeDouble(options.rowTitleWidth);
      w += titleW;
    }

    if (options.showTitleRow &&
        !options.cellShowsTitle &&
        !hasTitleRowInPayload) {
      h += _normalizeDouble(options.columnTitleHeight);
    }

    // Padding and border are applied by Container decoration, not included in content size
    final pad = options.cardPadding ?? EdgeInsets.zero;
    final padW = _normalizeDouble(pad.left + pad.right);
    w += padW;
    h += _normalizeDouble(pad.top + pad.bottom);

    final bw = _normalizeDouble(options.cardBorderWidth ?? 0.0);
    if (options.withCardBorder && bw > 0.0) {
      final borderW = bw * 2;
      w += borderW;
      h += bw * 2;
    }
    w = w.ceilToDouble();
    h = h.ceilToDouble();
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

    if (options.includeGrip) {
      w += _normalizeDouble(options.gripColWidth) * 2;
    }
    if (options.includeGrip) {
      h += _normalizeDouble(options.gripRowHeight) * 2;
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
  @Deprecated("计算顺序错误，此方法先计算row再计算pillar最后计算cell，不符合计算逻辑，已废弃")
  CardMetricsSnapshot compute_wrong() {
    final pillarOrder = payload.pillarOrderUuid;
    final rowOrder = payload.rowOrderUuid;
    final pillarMap = payload.pillarMap;
    final rowMap = payload.rowMap;

    final pillars = <String, PillarMetrics>{};
    final rows = <String, RowMetrics>{};
    final cells = <String, CellMetrics>{};

    // Temporary storage for intrinsic cell sizes
    final intrinsicCellHeights = <String, double>{}; // key: rowUuid|pillarUuid
    final intrinsicCellWidths = <String, double>{}; // key: rowUuid|pillarUuid

    // 1. Calculate intrinsic size for ALL cells first
    for (final rowUuid in rowOrder) {
      final r = rowMap[rowUuid];
      if (r == null) continue;
      final rt = r.rowType;

      for (final pillarUuid in pillarOrder) {
        final p = pillarMap[pillarUuid];
        if (p == null) continue;

        final key = _cellKey(rowUuid, pillarUuid);

        // Calculate intrinsic height
        final h = _calculateCellContentHeight(rt, rowUuid, pillarUuid);
        intrinsicCellHeights[key] = h;

        // Calculate intrinsic width
        final w = _calculateCellContentWidth(rt, rowUuid, pillarUuid);
        intrinsicCellWidths[key] = w;
      }
    }

    // 2. Determine Row Metrics (Height determined by max cell height in row)
    for (final rowUuid in rowOrder) {
      final r = rowMap[rowUuid];
      if (r == null) continue;
      final rt = r.rowType;

      double maxRowContentH = 0.0;
      // Fallback if no pillars (though unlikely in valid grid)
      if (pillarOrder.isEmpty) {
        maxRowContentH = _calculateCellContentHeight(rt, rowUuid, null);
      } else {
        for (final pillarUuid in pillarOrder) {
          final key = _cellKey(rowUuid, pillarUuid);
          final h = intrinsicCellHeights[key] ?? 0.0;
          if (h > maxRowContentH) maxRowContentH = h;
        }
      }

      final rowContentH = maxRowContentH;
      final rowDecH = theme.cell.getDecorationHeightBy(rt);
      final rowMarginV = _edgeV(theme.cell.getBy(rt).margin);
      final rowBorderW = 0.0;

      rows[rowUuid] = RowMetrics(
        rowUuid: rowUuid,
        rowType: rt,
        contentHeight: rowContentH,
        decorationHeight: rowDecH,
        marginVertical: rowMarginV,
        borderWidth: rowBorderW,
        withBorder: false,
      );
    }

    // 3. Determine Pillar Metrics (Width determined by max cell width in column)
    double totalWidth = 0.0;
    for (final pillarUuid in pillarOrder) {
      final p = pillarMap[pillarUuid];
      if (p == null) continue;
      final pt = p.pillarType;

      final decW = theme.pillar.getDecorationWidthBy(pt);
      final decH = theme.pillar.getDecorationHeightBy(pt); // Usually 0 or fixed

      double maxCellW = 0.0;
      int cellCount = 0;

      for (final rowUuid in rowOrder) {
        final key = _cellKey(rowUuid, pillarUuid);
        // Note: Cell width logic usually includes decoration width when comparing?
        // In original code: cellW = contentWidth + decorationWidth
        // Here we need to be consistent.
        // Let's assume intrinsicCellWidths is CONTENT width.
        // We need to add cell decoration width to find the max PILLAR content width?
        // Wait, Pillar Content Width = Max(Cell Width).
        // Cell Width = Cell Content Width + Cell Decoration Width.
        // But Pillar Width = Pillar Content Width + Pillar Decoration Width.
        // Usually Pillar Content Width is defined as the max of (Cell Content Width + Cell Decoration Width).
        // Let's check original logic:
        // final cellW = _normalizeDouble(cm.contentWidth + cm.decorationWidth);
        // if (cellW > maxCellW) maxCellW = cellW;
        // final contentW = maxCellW;

        final r = rowMap[rowUuid];
        if (r == null) continue;
        final rt = r.rowType;
        final cellDecW = theme.cell.getDecorationWidthBy(rt);

        final intrinsicW = intrinsicCellWidths[key] ?? 0.0;
        final cellTotalW = intrinsicW + cellDecW;

        if (cellTotalW > maxCellW) maxCellW = cellTotalW;
        cellCount++;
      }

      final contentW = (maxCellW > 0.0)
          ? _normalizeDouble(maxCellW)
          : _normalizeDouble(defaultPillarWidth);

      // Debug: Check default width usage
      if (contentW == defaultPillarWidth && cellCount > 0) {
        // print("⚠️ Pillar ${p.pillarType} using default width $defaultPillarWidth");
      }

      const contentH =
          0.0; // Pillars don't really have a content height sum usually
      final mH = _edgeH(theme.pillar.getBy(pt).margin);
      final mV = _edgeV(theme.pillar.getBy(pt).margin);
      final bW = theme.pillar.getBy(pt).border?.width ?? 0.0;

      totalWidth += (contentW + decW);

      pillars[pillarUuid] = PillarMetrics(
        pillarUuid: pillarUuid,
        pillarType: pt,
        contentWidth: contentW,
        contentHeight: contentH,
        decorationWidth: decW,
        decorationHeight: decH,
        marginHorizontal: mH,
        marginVertical: mV,
        withBorder: theme.pillar.getBy(pt).border?.enabled ?? false,
        borderWidth: bW,
      );
    }

    // 4. Finalize Cell Metrics (Stretched to match Row Height)
    for (final rowUuid in rowOrder) {
      final r = rowMap[rowUuid];
      if (r == null) continue;
      final rt = r.rowType;
      final rm = rows[rowUuid];
      if (rm == null) continue;

      for (final pillarUuid in pillarOrder) {
        final p = pillarMap[pillarUuid];
        if (p == null) continue;

        final key = _cellKey(rowUuid, pillarUuid);

        // Width: Intrinsic (or should it be stretched? Usually cells in a grid stretch to column width?
        // But original code kept 'contentW' as intrinsic. Let's keep it intrinsic to be safe,
        // or check if UI stretches it. UI usually uses Column Width.)
        // Original code: contentWidth: _normalizeDouble(contentW) -> intrinsic
        final intrinsicW = intrinsicCellWidths[key] ?? defaultPillarWidth;

        // Height: Stretched to Row Content Height
        final contentH = rm.contentHeight;

        final decW = theme.cell.getDecorationWidthBy(rt);
        final decH = rm.decorationHeight; // Consistent with row
        final mH = _edgeH(theme.cell.getBy(rt).margin);
        final mV = rm.marginVertical;
        final bW = rm.borderWidth;

        cells[key] = CellMetrics(
          rowUuid: rowUuid,
          pillarUuid: pillarUuid,
          contentWidth: _normalizeDouble(intrinsicW),
          contentHeight: _normalizeDouble(contentH),
          decorationWidth: _normalizeDouble(decW),
          decorationHeight: _normalizeDouble(decH),
          marginHorizontal: _normalizeDouble(mH),
          marginVertical: _normalizeDouble(mV),
          withBorder: theme.cell.getBy(rt).border?.enabled ?? false,
          borderWidth: _normalizeDouble(bW),
        );
      }
    }

    // 5. Calculate Total Height
    double totalHeight = 0.0;
    for (final rowUuid in rowOrder) {
      final rm = rows[rowUuid];
      if (rm == null) continue;
      totalHeight += _normalizeDouble(rm.contentHeight + rm.decorationHeight);
    }

    final totalW = pillars.values.fold(0.0, (sum, p) => sum + p.totalWidth);

    // Anomaly check

    final totals = CardTotals(
      totalWidth: _normalizeDouble(totalW),
      totalHeight: _normalizeDouble(totalHeight),
      columnCount: pillarOrder.length,
      rowCount: rowOrder.length,
    );

    // 6. Calculate Default Global Metrics (using helper methods)
    final representativeRowType = payload.rowMap.values
        .firstWhere(
          (r) => r.rowType != RowType.separator,
          orElse: () => payload.rowMap.values.first,
        )
        .rowType;
    final defaultCell = _computeDefaultGlobalCellMetric(representativeRowType);
    final defaultPillar = _computeDefaultGlobalPillarMetric(
      rows: rows,
      rowOrder: rowOrder,
    );
    final defaultRow = _computeDefaultGlobalRowMetric(
      pillars: pillars,
      pillarOrder: pillarOrder,
      representativeRowType: representativeRowType,
    );

    _snapshot = CardMetricsSnapshot(
      pillars: pillars,
      rows: rows,
      cells: cells,
      totals: totals,
      defaultGlobalPillarMetric: defaultPillar,
      defaultGlobalRowMetric: defaultRow,
      defaultGlobalCellMetric: defaultCell,
    );

    return _snapshot!;
  }

  /// 计算并生成当前卡片的度量快照
  ///
  /// 核心逻辑链（严格按你的需求定义）：
  /// 1. 单元格完整尺寸 → 2. 行度量（行高=同行单元格完整垂直尺寸最大值）→ 3. 列度量（列宽=同列单元格完整水平尺寸最大值；列高=同列行总高之和）→ 4. 单元格最终度量 → 5. 卡片总尺寸
  /// 关键尺寸构成：
  /// - 单元格完整垂直尺寸 = cell.contentHeight（内在内容高） + cell.decorationHeight + cell.marginVertical*2 + cell.borderWidth*2
  /// - 单元格完整水平尺寸 = cell.contentWidth（内在内容宽） + cell.decorationWidth + cell.marginHorizontal*2 + cell.borderWidth*2
  /// - 行contentHeight = 同行单元格完整垂直尺寸的最大值
  /// - 行总高 = row.contentHeight + row.decorationHeight + row.borderWidth*2
  /// - 列contentWidth = 同列单元格完整水平尺寸的最大值
  /// - 列contentHeight = 同列所有行总高之和
  /// - 卡片总宽 = 所有列总宽（contentWidth + 列装饰宽 + 列marginHorizontal*2 + 列borderWidth*2）之和
  /// - 卡片总高 = 所有行总高之和 + 列垂直装饰高的最大值
  CardMetricsSnapshot compute() {
    final pillarOrder = payload.pillarOrderUuid;
    final rowOrder = payload.rowOrderUuid;
    final pillarMap = payload.pillarMap;
    final rowMap = payload.rowMap;

    final pillars = <String, PillarMetrics>{};
    final rows = <String, RowMetrics>{};
    final cells = <String, CellMetrics>{};

    // 临时存储：单元格核心数据（内在尺寸 + 完整尺寸）
    final intrinsicCellHeights = <String, double>{}; // 单元格内在内容高（仅内容）
    final intrinsicCellWidths = <String, double>{}; // 单元格内在内容宽（仅内容）
    final cellFullVerticalSizes = <String, double>{}; // 单元格完整垂直尺寸（含装饰+边距+边框）
    final cellFullHorizontalSizes = <String, double>{}; // 单元格完整水平尺寸（含装饰+边距+边框）

    // 默认配置（可提取到主题或配置类，此处为方便展示）
    const defaultCellContentHeight = 48.0; // 单元格默认内在内容高
    const defaultCellContentWidth = 80.0; // 单元格默认内在内容宽
    const defaultPillarContentWidth = 100.0; // 列默认内容宽
    const defaultRowContentHeight = 60.0; // 行默认内容高（含单元格基础附加尺寸）

    // 1. 第一步：计算所有单元格的「内在尺寸」和「完整尺寸」（行/列计算的输入基础）
    for (final rowUuid in rowOrder) {
      final row = rowMap[rowUuid];
      if (row == null) continue;
      final rowType = row.rowType;
      final cellConfig = theme.cell.getBy(rowType); // 单元格主题配置（边距、边框、装饰）

      // 单元格固定配置（从主题读取，统一应用于该行所有单元格）
      final cellDecorationH = theme.cell.getDecorationHeightBy(rowType);
      final cellDecorationW = theme.cell.getDecorationWidthBy(rowType);
      final cellMarginV =
          cellConfig.margin.top + cellConfig.margin.bottom; // 上下边距之和
      final cellMarginH =
          cellConfig.margin.left + cellConfig.margin.right; // 左右边距之和
      final cellBorderW = cellConfig.border?.width ?? 0.0;

      for (final pillarUuid in pillarOrder) {
        final pillar = pillarMap[pillarUuid];
        if (pillar == null) continue;
        final cellKey = _cellKey(rowUuid, pillarUuid);

        // 1.1 单元格内在内容尺寸（仅文本、图片等纯内容，无任何附加）
        final cellIntrinsicContentH = _normalizeDouble(
          _calculateCellContentHeight(rowType, rowUuid, pillarUuid) ??
              defaultCellContentHeight,
        );
        final cellIntrinsicContentW = _normalizeDouble(
          _calculateCellContentWidth(rowType, rowUuid, pillarUuid) ??
              defaultCellContentWidth,
        );

        // 1.2 单元格完整垂直尺寸（按你的公式：内容高 + 装饰高 + 上下边距*2 + 边框*2）
        final cellFullVSize = _normalizeDouble(
          cellIntrinsicContentH +
              cellDecorationH +
              cellMarginV +
              (cellConfig.border?.enabled ?? false ? cellBorderW * 2 : 0.0),
        );

        // 1.3 单元格完整水平尺寸（用于计算列宽：内容宽 + 装饰宽 + 左右边距*2 + 边框*2）
        final cellFullHSize = _normalizeDouble(
          cellIntrinsicContentW +
              cellDecorationW +
              cellMarginH +
              ((cellConfig.border?.enabled ?? false) ? cellBorderW * 2 : 0.0),
        );

        // 存入临时字典（鲁棒性处理：确保非负、非NaN）
        intrinsicCellHeights[cellKey] = cellIntrinsicContentH;
        intrinsicCellWidths[cellKey] = cellIntrinsicContentW;
        cellFullVerticalSizes[cellKey] = cellFullVSize;
        cellFullHorizontalSizes[cellKey] = cellFullHSize;
      }
    }

    // 2. 第二步：计算「行度量」→ 行contentHeight=同行单元格内在内容高度最大值
    for (final rowUuid in rowOrder) {
      final row = rowMap[rowUuid];
      if (row == null) continue;
      final rowType = row.rowType;
      // final rowConfig = theme.row.getBy(rowType); // 行主题配置（装饰、边框）, 当前版本中没有提供行相关装饰，因此设置为0，预留后续扩展接口
      final cellConfig = theme.cell.getBy(rowType); // 单元格配置（用于默认值计算）
      final cellDecorationH = theme.cell.getDecorationHeightBy(rowType);
      final cellMarginV = cellConfig.margin.top + cellConfig.margin.bottom;
      final cellBorderW = cellConfig.border?.width ?? 0.0;
      final cellBorderEnabled = cellConfig.border?.enabled ?? false;

      // 2.1 计算同行单元格内在内容高度的最大值
      double maxIntrinsicContentH = 0.0;
      for (final pillarUuid in pillarOrder) {
        final cellKey = _cellKey(rowUuid, pillarUuid);
        final intrinsicH = intrinsicCellHeights[cellKey] ?? 0.0;
        if (intrinsicH > maxIntrinsicContentH) {
          maxIntrinsicContentH = intrinsicH;
        }
      }

      // 2.3 行自身配置（装饰、边框）
      // final rowDecorationH = theme.row.getDecorationHeightBy(rowType);
      // final rowDecorationW = theme.row.getDecorationWidthBy(rowType);
      // final rowBorderW = rowConfig.border?.width ?? 0.0;
      // final rowMarginV = rowConfig.margin.top + rowConfig.margin.bottom;
      // final rowMarginH = rowConfig.margin.left + rowConfig.margin.right;
      // WARNING: 当前版本中没有提供行相关装饰，因此设置为0，预留后续扩展接口
      final rowDecorationH =
          cellDecorationH + (cellBorderEnabled ? cellBorderW * 2 : 0.0);
      final rowDecorationW = 0.0;
      final rowBorderW = 0.0;
      final rowMarginV = cellMarginV;
      final rowMarginH = 0.0;

      // 2.2 行contentHeight兜底逻辑（无单元格时用默认值，仅内容高度）
      final defaultRowIntrinsicContentH =
          _normalizeDouble(defaultRowContentHeight);

      double rowContentH = _normalizeDouble(
        maxIntrinsicContentH > 0.0
            ? maxIntrinsicContentH
            : defaultRowIntrinsicContentH,
      );

      // 构建行度量（含计算属性totalHeight，简化后续总高计算）
      rows[rowUuid] = RowMetrics(
        rowUuid: rowUuid,
        rowType: rowType,
        contentHeight: rowContentH,
        decorationHeight: _normalizeDouble(rowDecorationH),
        // decorationWidth: _normalizeDouble(rowDecorationW),
        marginVertical: _normalizeDouble(rowMarginV),
        // marginHorizontal: _normalizeDouble(rowMarginH),
        borderWidth: _normalizeDouble(rowBorderW),
        withBorder: false,
      );
    }

    // 3. 第三步：计算「列度量」→ 列宽=同列单元格完整水平尺寸最大值；列高=同列行总高之和
    for (final pillarUuid in pillarOrder) {
      final pillar = pillarMap[pillarUuid];
      if (pillar == null) continue;
      final pillarConfig = theme.pillar.getBy(pillar.pillarType); // 列主题配置

      // 3.1 计算同列单元格完整水平尺寸的最大值（列contentWidth的基础）
      double maxCellFullHSize = 0.0;
      for (final rowUuid in rowOrder) {
        final row = rowMap[rowUuid];
        if (row == null) continue;
        final cellKey = _cellKey(rowUuid, pillarUuid);
        final cellFullHSize = cellFullHorizontalSizes[cellKey] ?? 0.0;
        if (cellFullHSize > maxCellFullHSize) {
          maxCellFullHSize = cellFullHSize;
        }
      }

      // 3.2 列contentWidth兜底逻辑
      double pillarContentW = 0.0;
      if (pillar.pillarType == PillarType.separator) {
        pillarContentW = pillarConfig.separatorWidth ?? defaultSeparatorWidth;
      } else if (pillar.pillarType == PillarType.rowTitleColumn) {
        pillarContentW = rowTitleWidth;
      } else {
        pillarContentW = _normalizeDouble(
          maxCellFullHSize > 0.0 ? maxCellFullHSize : defaultPillarContentWidth,
        );
      }

      // 3.3 计算列contentHeight（同列所有行总高之和）
      double pillarContentH = 0.0;
      for (final rowUuid in rowOrder) {
        final rowMetrics = rows[rowUuid];
        if (rowMetrics == null) continue;
        pillarContentH += rowMetrics.totalHeight; // 累加行总高（含行自身装饰+边框）
      }
      pillarContentH = _normalizeDouble(pillarContentH);

      // 3.4 列自身配置（装饰、边距、边框）
      final pillarDecorationH =
          pillarConfig.padding.top + pillarConfig.padding.bottom;
      final pillarDecorationW =
          pillarConfig.padding.left + pillarConfig.padding.right;
      final pillarBorderW = pillarConfig.border?.width ?? 0.0;
      final pillarMarginV =
          pillarConfig.margin.top + pillarConfig.margin.bottom;
      final pillarMarginH =
          pillarConfig.margin.left + pillarConfig.margin.right;

      // 构建列度量（含计算属性totalWidth，简化后续总宽计算）
      pillars[pillarUuid] = PillarMetrics(
        pillarUuid: pillarUuid,
        pillarType: pillar.pillarType,
        contentWidth: pillarContentW,
        contentHeight: pillarContentH,
        withBorder: pillarConfig.border?.enabled ?? false,
        decorationHeight: _normalizeDouble(pillarDecorationH),
        decorationWidth: _normalizeDouble(pillarDecorationW),
        marginVertical: _normalizeDouble(pillarMarginV),
        marginHorizontal: _normalizeDouble(pillarMarginH),
        borderWidth: _normalizeDouble(pillarBorderW),
      );
    }

    // 4. 第四步：计算「单元格最终度量」→ 适配列宽+拉伸内容高度到行内容高度
    for (final rowUuid in rowOrder) {
      final rowMetrics = rows[rowUuid];
      if (rowMetrics == null) continue;
      final rowType = rowMetrics.rowType;
      final cellConfig = theme.cell.getBy(rowType);

      // 单元格固定配置（从主题读取）
      final cellDecorationH = theme.cell.getDecorationHeightBy(rowType);
      final cellDecorationW = theme.cell.getDecorationWidthBy(rowType);
      final cellMarginV = cellConfig.margin.top + cellConfig.margin.bottom;
      final cellMarginH = cellConfig.margin.left + cellConfig.margin.right;
      final cellBorderW = cellConfig.border?.width ?? 0.0;

      for (final pillarUuid in pillarOrder) {
        final pillarMetrics = pillars[pillarUuid];
        if (pillarMetrics == null) continue;
        final cellKey = _cellKey(rowUuid, pillarUuid);

        // 单元格最终尺寸：宽度适配列宽，高度拉伸到行内容高度（行装饰/边距由 RowMetrics + CellMetrics 承载）
        final cellFinalContentW = pillarMetrics.contentWidth;
        final cellFinalContentH = rowMetrics.contentHeight;

        // 构建单元格度量（所有数值鲁棒性处理）
        cells[cellKey] = CellMetrics(
          rowUuid: rowUuid,
          pillarUuid: pillarUuid,
          withBorder: cellConfig.border?.enabled ?? false,
          contentWidth: _normalizeDouble(cellFinalContentW),
          contentHeight: _normalizeDouble(cellFinalContentH),
          decorationHeight: _normalizeDouble(cellDecorationH),
          decorationWidth: _normalizeDouble(cellDecorationW),
          marginVertical: _normalizeDouble(cellMarginV),
          marginHorizontal: _normalizeDouble(cellMarginH),
          borderWidth: _normalizeDouble(cellBorderW),
        );
      }
    }

    // 5. 第五步：汇总「卡片总尺寸」
    // 5.1 卡片总宽 = 所有列总宽（列完整水平尺寸）之和
    final totalWidth = pillars.values.fold(0.0, (sum, pillar) {
      return sum + pillar.totalWidth;
    });

    // 5.2 卡片总高 = 所有行总高之和 + 列垂直装饰高的最大值
    final totalRowTotalHeight = rows.values.fold(0.0, (sum, row) {
      return sum + row.totalHeight;
    });
    final maxPillarVerticalExtras = pillars.values.fold(0.0, (max, pillar) {
      final extras = pillar.decorationHeight +
          pillar.marginVertical +
          (pillar.withBorder ? pillar.borderWidth * 2 : 0.0);
      return extras > max ? extras : max;
    });
    // print("maxPillarVerticalExtras: $maxPillarVerticalExtras");
    final totalHeight =
        _normalizeDouble(totalRowTotalHeight + maxPillarVerticalExtras);

    // 构建最终快照
    final totals = CardTotals(
      totalWidth: _normalizeDouble(totalWidth),
      totalHeight: _normalizeDouble(totalHeight),
      columnCount: pillarOrder.length,
      rowCount: rowOrder.length,
    );

    // 6. 第六步：计算默认全局度量
    // 6.1 Default Cell Metric
    final representativeRowType = payload.rowMap.values
        .firstWhere(
          (r) => r.rowType != RowType.separator,
          orElse: () => payload.rowMap.values.first,
        )
        .rowType;
    final defaultCell = _computeDefaultGlobalCellMetric(representativeRowType);

    // 6.2 Default Pillar Metric
    final defaultPillar = _computeDefaultGlobalPillarMetric(
      rows: rows,
      rowOrder: rowOrder,
    );

    // 6.3 Default Row Metric
    final defaultRow = _computeDefaultGlobalRowMetric(
      pillars: pillars,
      pillarOrder: pillarOrder,
      representativeRowType: representativeRowType,
    );

    _snapshot = CardMetricsSnapshot(
      pillars: pillars,
      rows: rows,
      cells: cells,
      totals: totals,
      defaultGlobalPillarMetric: defaultPillar,
      defaultGlobalRowMetric: defaultRow,
      defaultGlobalCellMetric: defaultCell,
    );

    return _snapshot!;
  }

  CellMetrics _computeDefaultGlobalCellMetric(RowType rowType) {
    // 使用全局Cell配置
    final cellConfig = theme.cell.globalCellConfig;

    // 计算内容尺寸（基于rowType）
    final contentWidth = _calculateCellContentWidth(
      rowType,
      "placeholder",
      "placeholder",
    );
    final contentHeight = _calculateCellContentHeight(
      rowType,
      "placeholder",
      "placeholder",
    );

    // 装饰、边距、边框
    final decorationWidth = cellConfig.padding.left + cellConfig.padding.right;
    final decorationHeight = cellConfig.padding.top + cellConfig.padding.bottom;
    final marginHorizontal = cellConfig.margin.left + cellConfig.margin.right;
    final marginVertical = cellConfig.margin.top + cellConfig.margin.bottom;
    final borderWidth = cellConfig.border?.width ?? 0.0;
    final withBorder = cellConfig.border?.enabled ?? false;

    return CellMetrics(
      rowUuid: "placeholder",
      pillarUuid: "placeholder",
      contentWidth: _normalizeDouble(contentWidth),
      contentHeight: _normalizeDouble(contentHeight),
      decorationWidth: _normalizeDouble(decorationWidth),
      decorationHeight: _normalizeDouble(decorationHeight),
      marginHorizontal: _normalizeDouble(marginHorizontal),
      marginVertical: _normalizeDouble(marginVertical),
      borderWidth: _normalizeDouble(borderWidth),
      withBorder: withBorder,
    );
  }

  PillarMetrics _computeDefaultGlobalPillarMetric({
    required Map<String, RowMetrics> rows,
    required List<String> rowOrder,
  }) {
    final pillarConfig = theme.pillar.global;

    // 步骤1：计算 contentWidth = 所有现有pillars中最宽的 contentWidth
    double maxPillarContentW = 0.0;
    // 注意：这里我们需要的是已经计算好的 pillars 的 contentWidth。
    // 但是 compute() 方法中 pillars 是在步骤3计算的，而 defaultPillar 是在步骤6计算的，
    // 所以我们可以直接访问 compute() 作用域内的 pillars 变量。
    // 为了避免参数传递复杂，我们假设调用此方法时 pillars 已经计算好。
    // 实际上，为了更清晰，我们可以在 compute 方法中直接计算，或者传参。
    // 这里我们选择在 compute 中计算好 maxPillarContentW 传进来，或者直接在 compute 中访问。
    // 鉴于 _computeDefaultGlobalPillarMetric 是私有方法，我们可以让它接收 pillars map。
    // 但为了遵循 implementation plan，我们使用 max(existing pillars contentWidth)。
    // 等等，implementation plan 说的是 "contentWidth = max(cell.totalWidth) for all cells in pillar"
    // 但用户后来更正为 "直接使用所有 pillars 中最宽的 contentWidth"。
    // 所以我们需要访问 pillars map。

    // 让我们修改方法签名以接收 pillars
    // 实际上，由于我在 compute 方法内部调用，我可以访问 pillars 变量，但为了代码结构清晰，
    // 我还是通过参数传递比较好。
    // 但是 replace_file_content 只能替换代码块，不能轻易改变上下文变量的可见性。
    // 所以我将在 compute 方法内部直接传递 pillars。
    // 哎，wait，我在上面的 replacement content 中调用了 _computeDefaultGlobalPillarMetric
    // 但没有传递 pillars。让我修正一下调用和定义。

    // 重新设计调用：
    // final defaultPillar = _computeDefaultGlobalPillarMetric(
    //   rows: rows,
    //   rowOrder: rowOrder,
    //   pillars: pillars, // 添加这个
    // );

    // 稍等，上面的 replacement content 已经写进去了，我需要在方法定义中添加 pillars 参数。
    return _computeDefaultGlobalPillarMetricImpl(
        rows, rowOrder, _snapshot?.pillars ?? {});
  }

  // 辅助方法实现
  PillarMetrics _computeDefaultGlobalPillarMetricImpl(
      Map<String, RowMetrics> rows,
      List<String> rowOrder,
      Map<String, PillarMetrics> pillars) {
    final pillarConfig = theme.pillar.global;

    double maxPillarContentW = 0.0;
    if (pillars.isNotEmpty) {
      maxPillarContentW = pillars.values
          .map((p) => p.contentWidth)
          .reduce((a, b) => a > b ? a : b);
    } else {
      // Fallback if no pillars exist
      maxPillarContentW = defaultPillarWidth;
    }

    // 步骤2：高度 = 所有现有行的高度之和
    double contentHeight = 0.0;
    for (final rowUuid in rowOrder) {
      final rowMetrics = rows[rowUuid];
      if (rowMetrics == null) continue;
      contentHeight += rowMetrics.totalHeight;
    }

    // 步骤3：装饰、边距、边框
    final decorationWidth =
        pillarConfig.padding.left + pillarConfig.padding.right;
    final decorationHeight =
        pillarConfig.padding.top + pillarConfig.padding.bottom;
    final marginHorizontal =
        pillarConfig.margin.left + pillarConfig.margin.right;
    final marginVertical = pillarConfig.margin.top + pillarConfig.margin.bottom;
    final borderWidth = pillarConfig.border?.width ?? 0.0;
    final withBorder = pillarConfig.border?.enabled ?? false;

    return PillarMetrics(
      pillarUuid: "placeholder",
      pillarType: PillarType.year, // 占位
      contentWidth: _normalizeDouble(maxPillarContentW),
      contentHeight: _normalizeDouble(contentHeight),
      decorationWidth: _normalizeDouble(decorationWidth),
      decorationHeight: _normalizeDouble(decorationHeight),
      marginHorizontal: _normalizeDouble(marginHorizontal),
      marginVertical: _normalizeDouble(marginVertical),
      borderWidth: _normalizeDouble(borderWidth),
      withBorder: withBorder,
    );
  }

  RowMetrics _computeDefaultGlobalRowMetric({
    required Map<String, PillarMetrics> pillars,
    required List<String> pillarOrder,
    required RowType representativeRowType,
  }) {
    // 步骤1：宽度 = 所有现有pillars的总宽度
    double contentWidth = 0.0;
    for (final pillarUuid in pillarOrder) {
      final pillarMetrics = pillars[pillarUuid];
      if (pillarMetrics == null) continue;
      contentWidth += pillarMetrics.totalWidth;
    }

    // 步骤2：高度 = 所有现有pillars中虚拟单元格的最大高度
    double maxCellTotalHeight = 0.0;

    for (final pillarUuid in pillarOrder) {
      // 计算虚拟单元格的 totalHeight
      final cellMetric = _computeDefaultGlobalCellMetric(representativeRowType);
      final cellTotalHeight = cellMetric.totalHeight;

      if (cellTotalHeight > maxCellTotalHeight) {
        maxCellTotalHeight = cellTotalHeight;
      }
    }

    // 如果没有 pillar，使用默认高度
    if (pillarOrder.isEmpty) {
      final cellMetric = _computeDefaultGlobalCellMetric(representativeRowType);
      maxCellTotalHeight = cellMetric.totalHeight;
    }

    final contentHeight = maxCellTotalHeight;

    // 步骤3：装饰、边距、边框（使用全局配置，当前版本为0）
    final decorationHeight = 0.0;
    final marginVertical = 0.0;
    final borderWidth = 0.0;

    return RowMetrics(
      rowUuid: "placeholder",
      rowType: representativeRowType,
      contentHeight: _normalizeDouble(contentHeight),
      decorationHeight: _normalizeDouble(decorationHeight),
      marginVertical: _normalizeDouble(marginVertical),
      borderWidth: _normalizeDouble(borderWidth),
      withBorder: false,
    );
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

  double _calculateCellContentHeight(
      RowType rt, String rowUuid, String? pillarUuid) {
    if (rt == RowType.separator) {
      // Return configured height or 0
      final cellConfig = theme.cell.getBy(rt);
      return _normalizeDouble(cellConfig.separatorHeight ?? 0.0);
    }

    // 标题柱：始终用 rowTitle 字体参与“行高取最大值”的比较
    if (pillarUuid != null) {
      final pillar = payload.pillarMap[pillarUuid];
      if (pillar != null && pillar.pillarType == PillarType.rowTitleColumn) {
        final ts = theme.typography.rowTitle;
        final fontSize = ts.fontStyleDataModel.fontSize ?? 16.0;
        final contentLineHeight =
            ts.fontStyleDataModel.height ?? lineHeightFactor;
        final h = (fontSize * contentLineHeight).ceilToDouble();
        return _normalizeDouble(h);
      }
    }

    double? fontSize;

    if (pillarUuid != null) {
      final spec = cellTextSpecMap[_cellKey(rowUuid, pillarUuid)];
      if (spec != null && spec.fontSize != null) {
        fontSize = spec.fontSize;
      }
    }

    if (fontSize == null) {
      final ts = theme.typography.getCellContentBy(rt);
      fontSize = ts.fontStyleDataModel.fontSize ?? 16.0;

      if (rt == RowType.columnHeaderRow) {
        final t = theme.typography.getCellContentBy(rt);
        final fs = t.fontStyleDataModel.fontSize;
        fontSize = fs ?? fontSize;
      }
    }

    final contentLineHeight =
        theme.typography.getCellContentBy(rt).fontStyleDataModel.height ??
            lineHeightFactor;
    double h = (fontSize * contentLineHeight).ceilToDouble();

    // 样式层：若当前行类型开启“单元格内显示标题”，叠加标题高度
    final showTitle = () {
      if (rt == RowType.columnHeaderRow || rt == RowType.separator) {
        return false;
      }
      return theme.cell.getBy(rt).showsTitleInCell;
    }();
    if (showTitle) {
      final ts = theme.typography.getCellTitleBy(rt);
      final titleFs = ts.fontStyleDataModel.fontSize ?? 12.0;
      final titleLineHeight = ts.fontStyleDataModel.height ?? contentLineHeight;
      h += (titleFs * titleLineHeight).ceilToDouble();
    }

    return _normalizeDouble(h);
  }

  double _calculateCellContentWidth(
      RowType rt, String rowUuid, String pillarUuid) {
    // 检查是否为 separator 柱
    final pillar = payload.pillarMap[pillarUuid];
    if (pillar != null && pillar.pillarType == PillarType.separator) {
      // 从主题获取separator宽度配置
      final separatorConfig = theme.pillar.getBy(PillarType.separator);

      double separatorWidth = (separatorConfig.separatorWidth ?? 8.0) +
          separatorConfig.getDecorationWidth();

      return _normalizeDouble(separatorWidth);
    }

    double contentW = defaultPillarWidth;
    final spec = cellTextSpecMap[_cellKey(rowUuid, pillarUuid)];

    if (spec != null) {
      final fs = spec.fontSize ??
          theme.typography.getCellContentBy(rt).fontStyleDataModel.fontSize ??
          14.0;
      contentW = _normalizeDouble(spec.charCount * fs * avgGlyphWidthScale);
    }

    double titleW = 0.0;
    final showTitle = () {
      if (rt == RowType.columnHeaderRow || rt == RowType.separator) {
        return false;
      }
      return theme.cell.getBy(rt).showsTitleInCell;
    }();

    if (showTitle) {
      final rowPayload = payload.rowMap[rowUuid];
      String label = '';
      if (rowPayload is TextRowPayload) {
        label = rowPayload.rowLabel ?? '';
      }
      if (label.isNotEmpty) {
        final ts = theme.typography.getCellTitleBy(rt);
        final titleFs = ts.fontStyleDataModel.fontSize ?? 12.0;
        titleW = _normalizeDouble(label.length * titleFs * avgGlyphWidthScale);
      }
    }

    final maxW = (titleW > contentW ? titleW : contentW).ceilToDouble();
    return maxW;
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
