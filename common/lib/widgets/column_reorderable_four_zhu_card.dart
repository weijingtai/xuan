import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../enums/layout_template_enums.dart';
import '../enums/enum_tian_gan.dart' as tg;
import '../enums/enum_di_zhi.dart' as dz;
import '../enums/enum_jia_zi.dart' as jz;
import '../models/eight_chars.dart';
import '../models/layout_template.dart' show CardStyle, RowConfig;
import '../models/pillar_styles.dart';
import '../utils/style_resolver.dart';
import '../models/drag_payloads.dart';

/// 允许列（柱）拖拽的四柱卡片
/// 使用 ReorderableListView 实现列的拖拽重排
class ColumnReorderableFourZhuCard extends StatefulWidget {
  const ColumnReorderableFourZhuCard({
    super.key,
    required this.eightChars,
    this.isEditable = false,
    this.pillarOrder,
    this.rowConfigs,
    this.cardStyle,
    this.onPillarOrderChanged,
    this.styleResolver = const DefaultStyleResolver(),
    this.metricsResolver = const DefaultLayoutMetricsResolver(),
    this.elementColorResolver = const DefaultElementColorResolver(),
    this.rowLabelResolver,
    this.pillarLabelResolver,
    this.columnOverrides,
    this.pillarLabelOverrides,
    this.onColumnOverridesChanged,
    this.onPillarLabelOverridesChanged,
    // New: read-only row-level overrides and labels
    this.rowOverrides,
    this.rowLabelOverrides,
    // New: pillar visual resolver and width policy
    this.pillarStyleResolver = const DefaultPillarStyleResolver(),
    this.pillarWidthPolicy = const PillarWidthPolicy(),
    this.pillarWidthScale = 1.0,
    this.onDesiredCardWidthChanged,
  });

  final EightChars eightChars;
  final bool isEditable;
  final List<PillarType>? pillarOrder;
  final List<RowConfig>? rowConfigs;
  final CardStyle? cardStyle;
  final ValueChanged<List<PillarType>>? onPillarOrderChanged;
  final StyleResolver styleResolver;
  final LayoutMetricsResolver metricsResolver;
  final ElementColorResolver elementColorResolver;
  final RowLabelResolver? rowLabelResolver;
  final PillarLabelResolver? pillarLabelResolver;
  // New: shared overrides and callbacks
  final Map<int, Map<RowType, String>>? columnOverrides;
  final Map<int, String>? pillarLabelOverrides;
  final ValueChanged<Map<int, Map<RowType, String>>>? onColumnOverridesChanged;
  final ValueChanged<Map<int, String>>? onPillarLabelOverridesChanged;
  // New: read-only row-level overrides and labels
  final Map<int, Map<PillarType, String>>? rowOverrides;
  final Map<int, String>? rowLabelOverrides;
  // New: pillar styles and width policy
  final PillarStyleResolver pillarStyleResolver;
  final PillarWidthPolicy pillarWidthPolicy;
  // New: scale factor applied to computed pillar width
  final double pillarWidthScale;
  final CardWidthAdjustmentCallback? onDesiredCardWidthChanged;

  @override
  State<ColumnReorderableFourZhuCard> createState() =>
      _ColumnReorderableFourZhuCardState();
}

class _ColumnReorderableFourZhuCardState
    extends State<ColumnReorderableFourZhuCard> {
  late List<PillarType> _pillars;
  late List<RowConfig> _rows;
  // External insert support: overrides and label overrides keyed by column index
  final Map<int, Map<RowType, String>> _columnOverrides = {};
  final Map<int, String> _pillarLabelOverrides = {};
  // New: shared row-level overrides keyed by absolute row index
  final Map<int, Map<PillarType, String>> _rowOverrides = {};
  final Map<int, String> _rowLabelOverrides = {};
  int? _hoverInsertIndex;
  bool _hoveringExternalPillar = false;

  @override
  void initState() {
    super.initState();
    _pillars = List<PillarType>.of(
      widget.pillarOrder ??
          const [
            PillarType.year,
            PillarType.month,
            PillarType.day,
            PillarType.hour,
          ],
    );
    _rows = List<RowConfig>.of(
      widget.rowConfigs ??
          const [
            RowConfig(
                type: RowType.heavenlyStem,
                isVisible: true,
                isTitleVisible: true),
            RowConfig(
                type: RowType.earthlyBranch,
                isVisible: true,
                isTitleVisible: true),
            RowConfig(
                type: RowType.naYin, isVisible: true, isTitleVisible: true),
          ],
    );
    // Initialize overrides from incoming shared state if provided
    if (widget.columnOverrides != null) {
      _columnOverrides.clear();
      _columnOverrides.addAll(widget.columnOverrides!);
    }
    if (widget.pillarLabelOverrides != null) {
      _pillarLabelOverrides.clear();
      _pillarLabelOverrides.addAll(widget.pillarLabelOverrides!);
    }
    // New: row-level overrides and labels
    if (widget.rowOverrides != null) {
      _rowOverrides.clear();
      _rowOverrides.addAll(widget.rowOverrides!);
    }
    if (widget.rowLabelOverrides != null) {
      _rowLabelOverrides.clear();
      _rowLabelOverrides.addAll(widget.rowLabelOverrides!);
    }
  }

  @override
  void didUpdateWidget(covariant ColumnReorderableFourZhuCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always refresh local state from incoming props when provided
    if (widget.pillarOrder != null) {
      _pillars = List<PillarType>.of(widget.pillarOrder!);
    }
    if (widget.rowConfigs != null) {
      _rows = List<RowConfig>.of(widget.rowConfigs!);
    }
    // Refresh overrides if provided
    if (widget.columnOverrides != null) {
      _columnOverrides
        ..clear()
        ..addAll(widget.columnOverrides!);
    }
    if (widget.pillarLabelOverrides != null) {
      _pillarLabelOverrides
        ..clear()
        ..addAll(widget.pillarLabelOverrides!);
    }
    // New: refresh row-level overrides and labels
    if (widget.rowOverrides != null) {
      _rowOverrides
        ..clear()
        ..addAll(widget.rowOverrides!);
    }
    if (widget.rowLabelOverrides != null) {
      _rowLabelOverrides
        ..clear()
        ..addAll(widget.rowLabelOverrides!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleRows = _rows.where((r) => r.isVisible).toList();
    final headerH = widget.metricsResolver
        .headerHeight(context, cardStyle: widget.cardStyle);
    final cellH =
        widget.metricsResolver.rowHeight(context, cardStyle: widget.cardStyle);

    final labelStyle = widget.styleResolver.resolveTextStyle(
      context: context,
      rowType: RowType.heavenlyStem,
      cardStyle: widget.cardStyle,
      rowConfig: null,
      fontWeight: FontWeight.w600,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final availableWidth =
            containerWidth - 72 - (widget.isEditable ? 48 : 0);
        final desiredTileW = widget.metricsResolver
            .tileWidth(context, cardStyle: widget.cardStyle);
        final clampedTileW = desiredTileW.clamp(
            widget.pillarWidthPolicy.minWidth,
            widget.pillarWidthPolicy.maxWidth);
        // 可选缩放：在钳位后的柱宽基础上应用缩放系数
        final scaledTileW = clampedTileW * widget.pillarWidthScale;
        // 内容驱动宽度：以柱列数量与每列期望宽度计算内容区宽度
        final contentWidth = _pillars.length * scaledTileW;
        final requiredTotal = 72 + contentWidth + (widget.isEditable ? 48 : 0);
        // 始终通知期望卡片宽度，便于父级根据内容调整容器
        widget.onDesiredCardWidthChanged?.call(requiredTotal);
        // 使用统一的列宽（不再按availableWidth平均压缩），由滚动兜底
        final columnWidth = scaledTileW;
        final needsScroll = contentWidth > availableWidth;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 整个表格使用一个 Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧行标签列
                _buildRowLabels(visibleRows, headerH, cellH, labelStyle),

                // 中间可拖拽的列
                Expanded(
                  child: SizedBox(
                    height: headerH +
                        visibleRows.length * cellH +
                        (widget.isEditable ? 32 : 0), // 增加底部👆的高度
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: needsScroll
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        // 使用内容区宽度作为滚动容器的实际宽度
                        width: math.max(availableWidth, contentWidth),
                        child: Stack(
                          children: [
                            // Base: existing reorderable list or static row
                            Positioned.fill(
                              child: widget.isEditable
                                  ? ReorderableListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      buildDefaultDragHandles: false,
                                      itemCount: _pillars.length,
                                      onReorder: (oldIndex, newIndex) {
                                        setState(() {
                                          if (newIndex > oldIndex) {
                                            newIndex -= 1;
                                          }
                                          final item =
                                              _pillars.removeAt(oldIndex);
                                          _pillars.insert(newIndex, item);
                                          _moveColumnOverride(
                                              oldIndex, newIndex);
                                        });
                                        widget.onPillarOrderChanged?.call(
                                            List<PillarType>.of(_pillars));
                                      },
                                      proxyDecorator:
                                          (child, index, animation) {
                                        return AnimatedBuilder(
                                          animation: animation,
                                          builder: (context, child) {
                                            final t = Curves.easeInOut
                                                .transform(animation.value);
                                            return Transform.scale(
                                              scale: 1.0 + (0.05 * t),
                                              child: Transform.rotate(
                                                angle: 0.02 * t,
                                                child: Material(
                                                  elevation: 8.0 + (8.0 * t),
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                        width: 2 + t,
                                                      ),
                                                    ),
                                                    child: child,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: child,
                                        );
                                      },
                                      itemBuilder: (context, index) {
                                        final p = _pillars[index];
                                        // 仅在“插入点”索引之前插入一个占位空盒子，推动其后的所有列整体右移
                                        final bool showGapBefore =
                                            _hoveringExternalPillar &&
                                                _hoverInsertIndex != null &&
                                                index ==
                                                    (_hoverInsertIndex ?? 0);
                                        if (showGapBefore) {
                                          return Row(
                                            key: ValueKey<int>(
                                                identityHashCode(p)),
                                            children: [
                                              SizedBox(width: columnWidth),
                                              SizedBox(
                                                width: columnWidth,
                                                child:
                                                    ReorderableDragStartListener(
                                                  index: index,
                                                  child: _buildColumn(
                                                    p,
                                                    headerH,
                                                    cellH,
                                                    labelStyle,
                                                    visibleRows,
                                                    true,
                                                    index,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                        return SizedBox(
                                          key: ValueKey<int>(
                                              identityHashCode(p)),
                                          width: columnWidth,
                                          child: ReorderableDragStartListener(
                                            index: index,
                                            child: _buildColumn(
                                              p,
                                              headerH,
                                              cellH,
                                              labelStyle,
                                              visibleRows,
                                              true,
                                              index,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Row(
                                      children:
                                          _pillars.asMap().entries.map((e) {
                                        final index = e.key;
                                        final p = e.value;
                                        return SizedBox(
                                          width: columnWidth,
                                          child: _buildColumn(
                                            p,
                                            headerH,
                                            cellH,
                                            labelStyle,
                                            visibleRows,
                                            false,
                                            index,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ),
                            // Overlay: external pillar insert drop zones
                            if (widget.isEditable)
                              Positioned.fill(
                                child: IgnorePointer(
                                  // 始终参与命中，但只在边界窄条处作为投放点，不覆盖整列区域，避免阻挡列拖拽与鼠标指针。
                                  ignoring: false,
                                  child: LayoutBuilder(
                                    builder: (ctx, _) {
                                      final zoneWidth =
                                          math.min(48.0, columnWidth * 0.25);
                                      return Stack(
                                        children: List.generate(
                                            _pillars.length + 1, (i) {
                                          final left = (i * columnWidth) -
                                              (zoneWidth / 2);
                                          return Positioned(
                                            // 基于内容区宽度进行定位与约束，避免被容器宽度截断
                                            left: left.clamp(0.0,
                                                (contentWidth - zoneWidth)),
                                            width: zoneWidth,
                                            top: 0,
                                            bottom: 0,
                                            child: DragTarget<PillarPayload>(
                                              onWillAccept: (data) {
                                                setState(() {
                                                  _hoverInsertIndex = i;
                                                  _hoveringExternalPillar =
                                                      true;
                                                });
                                                return data != null;
                                              },
                                              onLeave: (_) => setState(() {
                                                if (_hoverInsertIndex == i) {
                                                  _hoverInsertIndex = null;
                                                }
                                                _hoveringExternalPillar = false;
                                              }),
                                              onAccept: (data) {
                                                _insertExternalPillar(i, data);
                                                setState(() {
                                                  _hoverInsertIndex = null;
                                                  _hoveringExternalPillar =
                                                      false;
                                                });
                                              },
                                              builder:
                                                  (ctx, candidate, rejected) {
                                                final active =
                                                    candidate.isNotEmpty &&
                                                        _hoverInsertIndex == i;
                                                return AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 120),
                                                  constraints:
                                                      const BoxConstraints
                                                          .expand(),
                                                  margin: EdgeInsets.zero,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: active
                                                          ? Theme.of(ctx)
                                                              .colorScheme
                                                              .primary
                                                          : Theme.of(ctx)
                                                              .dividerColor
                                                              .withValues(
                                                                  alpha: 0.1),
                                                      width: active ? 2 : 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    color: active
                                                        ? Theme.of(ctx)
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                                alpha: 0.06)
                                                        : Colors.transparent,
                                                  ),
                                                  child: active
                                                      ? Center(
                                                          child: Text(
                                                            '在此插入列',
                                                            style: Theme.of(ctx)
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                  color: Theme.of(
                                                                          ctx)
                                                                      .colorScheme
                                                                      .primary,
                                                                ),
                                                          ),
                                                        )
                                                      : null,
                                                );
                                              },
                                            ),
                                          );
                                        }),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            // Card-level visual overlay hint for external pillar drag
                            Positioned.fill(
                              child: IgnorePointer(
                                ignoring: true,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 120),
                                  opacity: _hoveringExternalPillar ? 1.0 : 0.0,
                                  child: Center(
                                    child: Builder(builder: (ctx) {
                                      final ph = widget.pillarStyleResolver
                                          .resolvePlaceholderStyle(
                                              context: ctx);
                                      final card = ph.cardStyle;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: card.backgroundColor ??
                                              Theme.of(ctx)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.06),
                                          border: card.borderEnabled &&
                                                  card.borderType !=
                                                      PillarBorderType.none
                                              ? Border.all(
                                                  color: card.borderColor ??
                                                      Theme.of(ctx)
                                                          .colorScheme
                                                          .primary,
                                                  width: card.borderThickness,
                                                )
                                              : null,
                                          borderRadius: BorderRadius.circular(
                                              card.cornerRadius),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('干',
                                                style: ph.contentTextStyle ??
                                                    Theme.of(ctx)
                                                        .textTheme
                                                        .bodySmall,
                                                textAlign: TextAlign.center),
                                            const SizedBox(height: 4),
                                            Text('支',
                                                style: ph.contentTextStyle ??
                                                    Theme.of(ctx)
                                                        .textTheme
                                                        .bodySmall,
                                                textAlign: TextAlign.center),
                                            const SizedBox(height: 4),
                                            Text('纳音',
                                                style: ph.contentTextStyle ??
                                                    Theme.of(ctx)
                                                        .textTheme
                                                        .bodySmall,
                                                textAlign: TextAlign.center),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 右侧占位移除：避免在编辑态下产生额外空白
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRowLabels(
    List<RowConfig> visibleRows,
    double headerH,
    double cellH,
    TextStyle labelStyle,
  ) {
    return Column(
      children: [
        SizedBox(width: 72, height: headerH),
        ...visibleRows.map((cfg) {
          final baseLabel = widget.rowLabelResolver?.call(cfg.type) ??
              _defaultRowLabel(cfg.type);
          final absIdx = _rows.indexOf(cfg);
          final rLabel = _rowLabelOverrides[absIdx] ?? baseLabel;
          return Container(
            width: 72,
            height: cellH,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Center(
              child:
                  Text(rLabel, style: labelStyle, textAlign: TextAlign.center),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildColumn(
    PillarType pillar,
    double headerH,
    double cellH,
    TextStyle labelStyle,
    List<RowConfig> visibleRows,
    bool isEditable,
    int colIndex,
  ) {
    final baseLabel =
        widget.pillarLabelResolver?.call(pillar) ?? _defaultPillarLabel(pillar);
    final pillarLabel = _pillarLabelOverrides[colIndex] ?? baseLabel;

    final cardStyle = widget.pillarStyleResolver.resolveCardStyle(
      context: context,
      index: colIndex,
      count: _pillars.length,
    );

    return MouseRegion(
      cursor: isEditable ? SystemMouseCursors.grab : SystemMouseCursors.basic,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 主体列
          Padding(
            padding: isEditable ? cardStyle.padding : EdgeInsets.zero,
            child: Container(
              decoration: isEditable
                  ? BoxDecoration(
                      color: cardStyle.backgroundColor,
                      border: cardStyle.borderEnabled &&
                              cardStyle.borderType != PillarBorderType.none
                          ? Border.all(
                              color: cardStyle.borderColor ??
                                  Theme.of(context)
                                      .dividerColor
                                      .withValues(alpha: 0.3),
                              width: cardStyle.borderThickness,
                            )
                          : null,
                      borderRadius:
                          BorderRadius.circular(cardStyle.cornerRadius),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题
                  Container(
                    height: headerH,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: isEditable
                        ? BoxDecoration(
                            color: cardStyle.headerBackgroundColor ??
                                Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(cardStyle.cornerRadius)),
                          )
                        : null,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isEditable)
                            Icon(
                              Icons.drag_indicator,
                              size: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.7),
                            ),
                          if (isEditable) const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${pillarLabel}柱',
                              style: labelStyle,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 数据行
                  ...visibleRows.map((cfg) {
                    final style = widget.styleResolver.resolveTextStyle(
                      context: context,
                      rowType: cfg.type,
                      cardStyle: widget.cardStyle,
                      rowConfig: cfg,
                    );
                    final absIdx = _rows.indexOf(cfg);
                    return Container(
                      height: cellH,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 2),
                      child: Center(
                        child: _buildCellAt(
                          context,
                          row: cfg.type,
                          colIndex: colIndex,
                          pillar: pillar,
                          absRowIndex: absIdx,
                          style: style,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // 底部拖拽指示器（整合到列中）
          if (isEditable) ...[
            const SizedBox(height: 4),
            Container(
              height: 28,
              child: const Center(
                child: Text('👆', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCellAt(
    BuildContext context, {
    required RowType row,
    required int colIndex,
    required PillarType pillar,
    required int absRowIndex,
    required TextStyle style,
  }) {
    final colOverride = _columnOverrides[colIndex]?[row];
    if (colOverride != null) {
      return Text(colOverride, style: style, textAlign: TextAlign.center);
    }
    final rowOverride = _rowOverrides[absRowIndex]?[pillar];
    if (rowOverride != null) {
      return Text(rowOverride, style: style, textAlign: TextAlign.center);
    }
    return _buildCell(context, row, pillar, style);
  }

  Widget _buildCell(
      BuildContext context, RowType row, PillarType pillar, TextStyle style) {
    switch (row) {
      case RowType.heavenlyStem:
        final text = _tianGanForPillar(pillar).value;
        final color = widget.elementColorResolver
            .colorForGan(_tianGanForPillar(pillar), context);
        return Text(text,
            style: style.copyWith(color: color), textAlign: TextAlign.center);
      case RowType.earthlyBranch:
        final text = _diZhiForPillar(pillar).value;
        final color = widget.elementColorResolver
            .colorForZhi(_diZhiForPillar(pillar), context);
        return Text(text,
            style: style.copyWith(color: color), textAlign: TextAlign.center);
      case RowType.naYin:
        final jy = _jiaZiForPillar(pillar);
        return Text(jy.naYin.name, style: style, textAlign: TextAlign.center);
      default:
        return const SizedBox.shrink();
    }
  }

  tg.TianGan _tianGanForPillar(PillarType p) {
    switch (p) {
      case PillarType.year:
        return widget.eightChars.year.tianGan;
      case PillarType.month:
        return widget.eightChars.month.tianGan;
      case PillarType.day:
        return widget.eightChars.day.tianGan;
      case PillarType.hour:
        return widget.eightChars.time.tianGan;
      default:
        return widget.eightChars.year.tianGan;
    }
  }

  dz.DiZhi _diZhiForPillar(PillarType p) {
    switch (p) {
      case PillarType.year:
        return widget.eightChars.year.diZhi;
      case PillarType.month:
        return widget.eightChars.month.diZhi;
      case PillarType.day:
        return widget.eightChars.day.diZhi;
      case PillarType.hour:
        return widget.eightChars.time.diZhi;
      default:
        return widget.eightChars.year.diZhi;
    }
  }

  jz.JiaZi _jiaZiForPillar(PillarType p) {
    switch (p) {
      case PillarType.year:
        return widget.eightChars.year;
      case PillarType.month:
        return widget.eightChars.month;
      case PillarType.day:
        return widget.eightChars.day;
      case PillarType.hour:
        return widget.eightChars.time;
      default:
        return widget.eightChars.year;
    }
  }

  String _defaultRowLabel(RowType type) {
    switch (type) {
      case RowType.heavenlyStem:
        return '天干';
      case RowType.earthlyBranch:
        return '地支';
      case RowType.naYin:
        return '纳音';
      default:
        return '';
    }
  }

  String _defaultPillarLabel(PillarType type) {
    switch (type) {
      case PillarType.year:
        return '年';
      case PillarType.month:
        return '月';
      case PillarType.day:
        return '日';
      case PillarType.hour:
        return '时';
      default:
        return type.name;
    }
  }

  void _insertExternalPillar(int index, PillarPayload data) {
    setState(() {
      // Shift existing overrides to make room for new column
      if (_columnOverrides.isNotEmpty) {
        final shifted = <int, Map<RowType, String>>{};
        for (final entry in _columnOverrides.entries) {
          final newKey = entry.key >= index ? entry.key + 1 : entry.key;
          shifted[newKey] = entry.value;
        }
        _columnOverrides
          ..clear()
          ..addAll(shifted);
      }
      if (_pillarLabelOverrides.isNotEmpty) {
        final shiftedLabels = <int, String>{};
        for (final entry in _pillarLabelOverrides.entries) {
          final newKey = entry.key >= index ? entry.key + 1 : entry.key;
          shiftedLabels[newKey] = entry.value;
        }
        _pillarLabelOverrides
          ..clear()
          ..addAll(shiftedLabels);
      }

      // Insert new pillar and apply overrides/label from payload
      _pillars.insert(index, data.pillarType);
      if (data.perRowValues.isNotEmpty) {
        _columnOverrides[index] = Map<RowType, String>.of(data.perRowValues);
      }
      if (data.pillarLabel != null) {
        _pillarLabelOverrides[index] = data.pillarLabel!;
      }
    });
    // Notify shared controller via callbacks
    widget.onColumnOverridesChanged
        ?.call(Map<int, Map<RowType, String>>.of(_columnOverrides));
    widget.onPillarLabelOverridesChanged
        ?.call(Map<int, String>.of(_pillarLabelOverrides));
    // Notify order change as before
    widget.onPillarOrderChanged?.call(List<PillarType>.of(_pillars));
  }

  void _moveColumnOverride(int oldIndex, int newIndex) {
    final ov = _columnOverrides.remove(oldIndex);
    final label = _pillarLabelOverrides.remove(oldIndex);

    // Shift ranges between oldIndex and newIndex
    if (newIndex > oldIndex) {
      for (final entry in _columnOverrides.entries) {
        final k = entry.key;
        if (k > oldIndex && k <= newIndex) {
          _columnOverrides[k - 1] = entry.value;
          _columnOverrides.remove(k);
        }
      }
      for (final entry in _pillarLabelOverrides.entries) {
        final k = entry.key;
        if (k > oldIndex && k <= newIndex) {
          _pillarLabelOverrides[k - 1] = entry.value;
          _pillarLabelOverrides.remove(k);
        }
      }
    } else if (newIndex < oldIndex) {
      for (final entry in _columnOverrides.entries) {
        final k = entry.key;
        if (k < oldIndex && k >= newIndex) {
          _columnOverrides[k + 1] = entry.value;
          _columnOverrides.remove(k);
        }
      }
      for (final entry in _pillarLabelOverrides.entries) {
        final k = entry.key;
        if (k < oldIndex && k >= newIndex) {
          _pillarLabelOverrides[k + 1] = entry.value;
          _pillarLabelOverrides.remove(k);
        }
      }
    }

    if (ov != null) _columnOverrides[newIndex] = ov;
    if (label != null) _pillarLabelOverrides[newIndex] = label;

    // Notify shared controller via callbacks
    widget.onColumnOverridesChanged
        ?.call(Map<int, Map<RowType, String>>.of(_columnOverrides));
    widget.onPillarLabelOverridesChanged
        ?.call(Map<int, String>.of(_pillarLabelOverrides));
  }
}
