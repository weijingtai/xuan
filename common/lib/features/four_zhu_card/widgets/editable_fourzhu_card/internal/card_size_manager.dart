import 'package:flutter/material.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/models/row_strategy.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import '../size_calculator/enhanced_calculator.dart';
import '../size_calculator/enhanced_snapshot.dart';
import '../size_calculator/metrics.dart';
import 'card_data_adapter.dart';

/// CardSizeManager
///
/// 负责所有尺寸计算,统一使用 CardMetricsCalculator 系统。
/// 完全移除了旧的 CardLayoutModel/MeasurementContext。
class CardSizeManager {
  EditableFourZhuCardTheme theme;
  CardPayload payload;
  final Map<RowType, RowComputationStrategy> rowStrategyMapper;
  final Map<PillarType, PillarComputationStrategy> pillarStrategyMapper;

  // 缓存的快照 (使用 EnhancedCardMetricsSnapshot 以支持拖拽)
  EnhancedCardMetricsSnapshot? _cachedSnapshot;

  // 默认尺寸
  final double defaultPillarWidth = 64.0;
  final double rowTitleWidth = 52.0;
  final double columnTitleHeight = 24.0;
  final double otherCellHeight = 32.0;
  final double ganZhiCellHeight = 32.0;
  final double lineHeightFactor = 1.4;
  final double avgGlyphWidthScale = 1.2;

  // 抓手尺寸
  final double dragHandleRowHeight = 20.0;
  final double dragHandleColWidth = 20.0;

  // Widget 参数 (用于 computeCardSize)
  bool showGripRows = true;
  bool showGripColumns = true;
  EdgeInsets cardPadding = EdgeInsets.zero;

  CardSizeManager({
    required this.theme,
    required this.payload,
    required this.rowStrategyMapper,
    this.pillarStrategyMapper = const <PillarType, PillarComputationStrategy>{},
    this.showGripRows = true,
    this.showGripColumns = true,
    this.cardPadding = EdgeInsets.zero,
  });

  /// 更新 payload 并清除缓存
  void updatePayload(CardPayload newPayload) {
    payload = newPayload;
    _cachedSnapshot = null;
    _calculator = null;
  }

  /// 更新 theme 并清除缓存
  void updateTheme(EditableFourZhuCardTheme newTheme) {
    theme = newTheme;
    _cachedSnapshot = null;
    _calculator = null;
  }

  /// 计算并缓存 metrics snapshot
  EnhancedCardMetricsSnapshot computeSnapshot() {
    if (_cachedSnapshot != null) {
      return _cachedSnapshot!;
    }

    _ensureCalculator();
    _cachedSnapshot = _calculator!.compute();
    return _cachedSnapshot!;
  }

  EnhancedCardMetricsCalculator get calculator {
    _ensureCalculator();
    return _calculator!;
  }

  // ===========================================================================
  // 拖拽支持代理方法
  // ===========================================================================

  void startColumnDrag(int index) {
    _ensureCalculator();
    _cachedSnapshot = _calculator!.startColumnDrag(index);
  }

  void updateColumnDrag(int newIndex) {
    // 需要先确保当前 snapshot 包含拖拽状态
    // 但 calculator 是新创建的, 它不知道之前的状态
    // 所以我们需要让 calculator 基于 _cachedSnapshot 进行计算
    // EnhancedCardMetricsCalculator 目前不支持基于已有 snapshot 计算

    // 修正方案:
    // 我们应该让 calculator 成为 CardSizeManager 的成员变量?
    // 或者修改 EnhancedCardMetricsCalculator 让它可以接受 snapshot?

    // 鉴于 EnhancedCardMetricsCalculator 的设计, 它内部维护 _enhancedSnapshot
    // 我们应该在 CardSizeManager 中持有 calculator 实例吗?
    // 如果持有实例, 当 payload 变化时需要重建 calculator.

    // 临时方案: 每次操作都使用当前 snapshot 的状态重新初始化 calculator?
    // 不行, calculator 初始化只接受 payload.

    // 正确方案: EnhancedCardMetricsCalculator 应该允许注入 snapshot.
    // 或者我们修改 calculator 的方法, 让它们接受 snapshot?
    // 查看 EnhancedCardMetricsCalculator, 它的方法都是实例方法, 使用内部 _enhancedSnapshot.

    // 让我们修改 CardSizeManager, 让它持有一个 _calculator 实例.
    _ensureCalculator();
    _cachedSnapshot = _calculator!.updateColumnDrag(newIndex);
  }

  void endColumnDrag() {
    _ensureCalculator();
    _cachedSnapshot = _calculator!.endColumnDrag();
  }

  void startRowDrag(int index) {
    _ensureCalculator();
    _cachedSnapshot = _calculator!.startRowDrag(index);
  }

  void updateRowDrag(int newIndex) {
    _ensureCalculator();
    _cachedSnapshot = _calculator!.updateRowDrag(newIndex);
  }

  void endRowDrag() {
    _ensureCalculator();
    _cachedSnapshot = _calculator!.endRowDrag();
  }

  // 内部 Calculator 实例
  EnhancedCardMetricsCalculator? _calculator;

  void _ensureCalculator() {
    if (_calculator != null) return;

    final specMap = CardDataAdapter.buildCellTextSpecMap(
      payload: payload,
      rowStrategyMapper: rowStrategyMapper,
      pillarStrategyMapper: pillarStrategyMapper,
      typography: theme.typography,
    );

    _calculator = EnhancedCardMetricsCalculator(
      theme: theme,
      payload: payload,
      defaultPillarWidth: defaultPillarWidth,
      lineHeightFactor: lineHeightFactor,
      cellTextSpecMap: specMap,
      avgGlyphWidthScale: avgGlyphWidthScale,
    );

    if (_cachedSnapshot != null) {
      _calculator!.adoptSnapshot(_cachedSnapshot!);
    }
  }

  /// 计算卡片最终尺寸
  Size computeCardSize() {
    computeSnapshot(); // 确保 snapshot 已计算

    final options = MetricsComputeOptions(
      // includeGripRows: showGripRows,
      // includeGripCols: showGripColumns,
      includeGrip: showGripRows,
      showTitleRow: theme.displayHeaderRow,
      showTitleCol: theme.displayRowTitleColumn,
      cellShowsTitle: false,
      withCardBorder: theme.card.border?.enabled ?? false,
      cardPadding: cardPadding,
      cardBorderWidth: _getCardBorderWidth(),
      gripRowHeight: dragHandleRowHeight,
      gripColWidth: dragHandleColWidth,
      columnTitleHeight: columnTitleHeight,
      rowTitleWidth: rowTitleWidth,
    );

    _ensureCalculator();

    return _calculator!.computeFinalSize(options);
  }

  /// 获取列宽
  double getColumnWidth(int index) {
    final snapshot = computeSnapshot();
    // 注意: 使用 snapshot 中的 pillarOrderUuid, 因为拖拽可能改变了顺序
    final pillars = snapshot.pillarOrderUuid;

    if (index < 0 || index >= pillars.length) {
      return defaultPillarWidth;
    }

    final pillarUuid = pillars[index];
    final pillarMetrics = snapshot.pillars[pillarUuid];

    if (pillarMetrics == null) {
      return defaultPillarWidth;
    }

    return pillarMetrics.contentWidth + pillarMetrics.decorationWidth;
  }

  /// 获取行高
  double getRowHeight(int index) {
    final snapshot = computeSnapshot();
    final rows = snapshot.rowOrderUuid;

    if (index < 0 || index >= rows.length) {
      return otherCellHeight;
    }

    final rowUuid = rows[index];
    final rowMetrics = snapshot.rows[rowUuid];

    if (rowMetrics == null) {
      return otherCellHeight;
    }

    return rowMetrics.contentHeight + rowMetrics.decorationHeight;
  }

  /// 获取单元格尺寸
  Size getCellSize(String rowUuid, String pillarUuid) {
    final snapshot = computeSnapshot();
    final cellKey = '$rowUuid|$pillarUuid';
    final cellMetrics = snapshot.cells[cellKey];

    if (cellMetrics == null) {
      return Size(defaultPillarWidth, otherCellHeight);
    }

    return Size(
      cellMetrics.contentWidth + cellMetrics.decorationWidth,
      cellMetrics.contentHeight + cellMetrics.decorationHeight,
    );
  }

  /// 获取卡片边框宽度
  double _getCardBorderWidth() {
    final border = theme.card.border;
    if (border == null || !border.enabled) {
      return 0.0;
    }
    return border.width;
  }

  /// 清除缓存
  void clearCache() {
    _cachedSnapshot = null;
    _calculator = null; // 清除 calculator 以便重建
  }
}
