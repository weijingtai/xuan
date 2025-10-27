import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';
import '../enums/enum_tian_gan.dart' as tg;
import '../enums/enum_di_zhi.dart' as dz;
import '../enums/enum_jia_zi.dart' as jz;
import '../models/eight_chars.dart';
import '../models/layout_template.dart' show CardStyle, RowConfig;
import '../utils/style_resolver.dart';
import '../models/drag_payloads.dart';

/// 允许行拖拽的四柱卡片
/// 使用 ReorderableListView 实现行的拖拽重排
class RowReorderableFourZhuCard extends StatefulWidget {
  const RowReorderableFourZhuCard({
    super.key,
    required this.eightChars,
    this.isEditable = false,
    this.pillarOrder,
    this.rowConfigs,
    this.cardStyle,
    this.onRowConfigsChanged,
    this.styleResolver = const DefaultStyleResolver(),
    this.metricsResolver = const DefaultLayoutMetricsResolver(),
    this.elementColorResolver = const DefaultElementColorResolver(),
    this.rowLabelResolver,
    this.pillarLabelResolver,
  });

  final EightChars eightChars;
  final bool isEditable;
  final List<PillarType>? pillarOrder;
  final List<RowConfig>? rowConfigs;
  final CardStyle? cardStyle;
  final ValueChanged<List<RowConfig>>? onRowConfigsChanged;
  final StyleResolver styleResolver;
  final LayoutMetricsResolver metricsResolver;
  final ElementColorResolver elementColorResolver;
  final RowLabelResolver? rowLabelResolver;
  final PillarLabelResolver? pillarLabelResolver;

  @override
  State<RowReorderableFourZhuCard> createState() =>
      _RowReorderableFourZhuCardState();
}

class _RowReorderableFourZhuCardState extends State<RowReorderableFourZhuCard> {
  late List<PillarType> _pillars;
  late List<RowConfig> _rows;
  final Map<int, Map<PillarType, String>> _rowOverrides = {};
  final Map<int, String> _rowLabelOverrides = {};
  int? _hoverRowInsertIndex;

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
  }

  @override
  void didUpdateWidget(covariant RowReorderableFourZhuCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always refresh local state from incoming props when provided
    if (widget.pillarOrder != null) {
      _pillars = List<PillarType>.of(widget.pillarOrder!);
    }
    if (widget.rowConfigs != null) {
      _rows = List<RowConfig>.of(widget.rowConfigs!);
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 列标题行（不可拖拽）
        _buildStaticColumnHeaders(headerH, labelStyle),

        const SizedBox(height: 8),

        // 数据行（可拖拽）
        if (widget.isEditable)
          ..._buildReorderableDataRows(visibleRows, cellH, labelStyle)
        else
          ...visibleRows.asMap().entries.map((entry) {
            final idx = entry.key;
            final cfg = entry.value;
            final baseLabel = widget.rowLabelResolver?.call(cfg.type) ??
                _defaultRowLabel(cfg.type);
            final rLabel = _rowLabelOverrides[idx] ?? baseLabel;
            final style = widget.styleResolver.resolveTextStyle(
              context: context,
              rowType: cfg.type,
              cardStyle: widget.cardStyle,
              rowConfig: cfg,
            );
            return _buildStaticDataRow(
                idx, rLabel, cfg, style, cellH, labelStyle);
          }),

        // 底部占位行（与列拖拽卡片保持布局一致）
        if (widget.isEditable) ...[
          const SizedBox(height: 4),
          _buildBottomPlaceholderRow(),
        ],
      ],
    );
  }

  Widget _buildStaticColumnHeaders(double headerH, TextStyle labelStyle) {
    return SizedBox(
      height: headerH,
      child: Row(
        children: [
          const SizedBox(width: 72),
          ..._pillars.map((p) {
            final pillarLabel =
                widget.pillarLabelResolver?.call(p) ?? _defaultPillarLabel(p);
            return Expanded(
              child: Center(
                child: Text(
                  '${pillarLabel}柱',
                  style: labelStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
          if (widget.isEditable) const SizedBox(width: 48),
        ],
      ),
    );
  }

  List<Widget> _buildReorderableDataRows(
    List<RowConfig> visibleRows,
    double cellH,
    TextStyle labelStyle,
  ) {
    return [
      Stack(
        children: [
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final t = Curves.easeInOut.transform(animation.value);
                  return Transform.scale(
                    scale: 1.0 + (0.03 * t),
                    child: Material(
                      elevation: 8.0 + (8.0 * t),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2 + t,
                          ),
                        ),
                        child: child,
                      ),
                    ),
                  );
                },
                child: child,
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = _rows.removeAt(oldIndex);
                _rows.insert(newIndex, item);
                _moveRowOverride(oldIndex, newIndex);
              });
              widget.onRowConfigsChanged?.call(List<RowConfig>.of(_rows));
            },
            children: visibleRows.asMap().entries.map((entry) {
              final idx = entry.key;
              final cfg = entry.value;
              final baseLabel = widget.rowLabelResolver?.call(cfg.type) ??
                  _defaultRowLabel(cfg.type);
              final rLabel = _rowLabelOverrides[idx] ?? baseLabel;
              final style = widget.styleResolver.resolveTextStyle(
                context: context,
                rowType: cfg.type,
                cardStyle: widget.cardStyle,
                rowConfig: cfg,
              );
              return _buildReorderableDataRow(
                key: ValueKey('${cfg.type}-$idx'),
                index: idx,
                rowLabel: rLabel,
                cfg: cfg,
                style: style,
                cellH: cellH,
                labelStyle: labelStyle,
              );
            }).toList(),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: Column(
                children: List.generate(visibleRows.length + 1, (i) {
                  return SizedBox(
                    height: cellH,
                    child: DragTarget<RowInfoPayload>(
                      onWillAccept: (data) {
                        setState(() => _hoverRowInsertIndex = i);
                        return data != null;
                      },
                      onLeave: (_) =>
                          setState(() => _hoverRowInsertIndex = null),
                      onAccept: (data) {
                        _insertExternalRow(i, data);
                        setState(() => _hoverRowInsertIndex = null);
                      },
                      builder: (ctx, candidate, rejected) {
                        final active =
                            candidate.isNotEmpty && _hoverRowInsertIndex == i;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          constraints: const BoxConstraints.expand(),
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: active
                                  ? Theme.of(ctx).colorScheme.primary
                                  : Theme.of(ctx)
                                      .dividerColor
                                      .withValues(alpha: 0.1),
                              width: active ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: active
                                ? Theme.of(ctx)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.06)
                                : Colors.transparent,
                          ),
                          child: active
                              ? Center(
                                  child: Text(
                                    '在此插入行',
                                    style: Theme.of(ctx)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color:
                                              Theme.of(ctx).colorScheme.primary,
                                        ),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildReorderableDataRow({
    required Key key,
    required int index,
    required String rowLabel,
    required RowConfig cfg,
    required TextStyle style,
    required double cellH,
    required TextStyle labelStyle,
  }) {
    return ReorderableDragStartListener(
      key: key,
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                // 行标签（带拖拽图标）
                Container(
                  width: 72,
                  height: cellH,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.2),
                    borderRadius:
                        const BorderRadius.horizontal(left: Radius.circular(4)),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.drag_indicator,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            rowLabel,
                            style: labelStyle,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 数据单元格
                ..._pillars.map((p) {
                  return Expanded(
                    child: Container(
                      height: cellH,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Center(
                        child:
                            _buildCellWithOverride(index, cfg.type, p, style),
                      ),
                    ),
                  );
                }),
                // 行拖拽句柄
                SizedBox(
                  width: 48,
                  height: cellH,
                  child: const Center(
                    child: Text('👆', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaticDataRow(
    int index,
    String rowLabel,
    RowConfig cfg,
    TextStyle style,
    double cellH,
    TextStyle labelStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // 行标签
          SizedBox(
            width: 72,
            height: cellH,
            child: Center(
              child: Text(rowLabel,
                  style: labelStyle, textAlign: TextAlign.center),
            ),
          ),
          // 数据单元格
          ..._pillars.map((p) {
            return Expanded(
              child: Container(
                height: cellH,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Center(
                  child: _buildCellWithOverride(index, cfg.type, p, style),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomPlaceholderRow() {
    return Row(
      children: [
        const SizedBox(width: 72),
        ..._pillars.map((_) => const Expanded(child: SizedBox(height: 24))),
        const SizedBox(width: 48),
      ],
    );
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

  // New: cell rendering with per-row overrides
  Widget _buildCellWithOverride(
      int rowIndex, RowType row, PillarType pillar, TextStyle style) {
    final override = _rowOverrides[rowIndex]?[pillar];
    if (override != null) {
      return Text(override, style: style, textAlign: TextAlign.center);
    }
    return _buildCell(context, row, pillar, style);
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

  void _moveRowOverride(int oldIndex, int newIndex) {
    final currentOverrides =
        Map<int, Map<PillarType, String>>.from(_rowOverrides);
    final currentLabels = Map<int, String>.from(_rowLabelOverrides);
    _rowOverrides.clear();
    _rowLabelOverrides.clear();

    for (final entry in currentOverrides.entries) {
      final k = entry.key;
      int newKey;
      if (k == oldIndex) {
        newKey = newIndex;
      } else if (oldIndex < newIndex && k > oldIndex && k <= newIndex) {
        newKey = k - 1;
      } else if (oldIndex > newIndex && k < oldIndex && k >= newIndex) {
        newKey = k + 1;
      } else {
        newKey = k;
      }
      _rowOverrides[newKey] = entry.value;
    }

    for (final entry in currentLabels.entries) {
      final k = entry.key;
      int newKey;
      if (k == oldIndex) {
        newKey = newIndex;
      } else if (oldIndex < newIndex && k > oldIndex && k <= newIndex) {
        newKey = k - 1;
      } else if (oldIndex > newIndex && k < oldIndex && k >= newIndex) {
        newKey = k + 1;
      } else {
        newKey = k;
      }
      _rowLabelOverrides[newKey] = entry.value;
    }
  }

  void _insertExternalRow(int index, RowInfoPayload payload) {
    setState(() {
      if (_rowOverrides.isNotEmpty) {
        final shifted = <int, Map<PillarType, String>>{};
        for (final e in _rowOverrides.entries) {
          final newKey = e.key >= index ? e.key + 1 : e.key;
          shifted[newKey] = e.value;
        }
        _rowOverrides
          ..clear()
          ..addAll(shifted);
      }
      if (_rowLabelOverrides.isNotEmpty) {
        final shiftedLabels = <int, String>{};
        for (final e in _rowLabelOverrides.entries) {
          final newKey = e.key >= index ? e.key + 1 : e.key;
          shiftedLabels[newKey] = e.value;
        }
        _rowLabelOverrides
          ..clear()
          ..addAll(shiftedLabels);
      }

      final newCfg = RowConfig(
        type: payload.rowType,
        isVisible: true,
        isTitleVisible: true,
      );
      _rows.insert(index, newCfg);
      if (payload.rowLabel != null) {
        _rowLabelOverrides[index] = payload.rowLabel!;
      }
      if (payload.perPillarValues != null) {
        _rowOverrides[index] =
            Map<PillarType, String>.of(payload.perPillarValues!);
      }
    });
    debugPrint('[RowCard] Accepted external row at index ' +
        index.toString() +
        ', type=' +
        payload.rowType.name);
    widget.onRowConfigsChanged?.call(List<RowConfig>.of(_rows));
  }
}
