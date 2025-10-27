import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';
import '../enums/enum_tian_gan.dart' as tg;
import '../enums/enum_di_zhi.dart' as dz;
import '../enums/enum_ten_gods.dart' as gods;
import '../enums/enum_jia_zi.dart' as jz;
import '../models/eight_chars.dart';
import '../models/layout_template.dart' show CardStyle, RowConfig;
import '../utils/style_resolver.dart';

typedef RowCellBuilder = Widget Function(
  BuildContext context, {
  required RowType rowType,
  required PillarType pillarType,
  required EightChars eightChars,
  required TextStyle effectiveTextStyle,
});

typedef PillarHeaderBuilder = Widget Function(
  BuildContext context, {
  required PillarType pillarType,
  required TextStyle labelTextStyle,
});

class EditableFourZhuCard extends StatefulWidget {
  const EditableFourZhuCard({
    super.key,
    required this.eightChars,
    this.isEditable = false,
    this.pillarOrder,
    this.rowConfigs,
    this.cardStyle,
    this.onPillarOrderChanged,
    this.onRowConfigsChanged,
    this.pillarHeaderBuilder,
    this.rowCellBuilder,
    this.dividerBuilder,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.styleResolver = const DefaultStyleResolver(),
    this.metricsResolver = const DefaultLayoutMetricsResolver(),
    this.elementColorResolver = const DefaultElementColorResolver(),
    this.rowLabelResolver,
    this.pillarLabelResolver,
    this.axis = Axis.horizontal,
    this.onAddPillarRequested,
  });

  final EightChars eightChars;
  final bool isEditable;
  final List<PillarType>? pillarOrder;
  final List<RowConfig>? rowConfigs;
  final CardStyle? cardStyle;

  final ValueChanged<List<PillarType>>? onPillarOrderChanged;
  final ValueChanged<List<RowConfig>>? onRowConfigsChanged;

  final PillarHeaderBuilder? pillarHeaderBuilder;
  final RowCellBuilder? rowCellBuilder;
  final Widget Function(BuildContext context)? dividerBuilder;

  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  final StyleResolver styleResolver;
  final LayoutMetricsResolver metricsResolver;
  final ElementColorResolver elementColorResolver;
  final RowLabelResolver? rowLabelResolver;
  final PillarLabelResolver? pillarLabelResolver;
  final Axis axis;
  final VoidCallback? onAddPillarRequested;

  @override
  State<EditableFourZhuCard> createState() => _EditableFourZhuCardState();
}

class _EditableFourZhuCardState extends State<EditableFourZhuCard> {
  late List<PillarType> _pillars;
  late List<RowConfig> _rows;
  int? _hoverDropIndex;
  int? _draggingIndex;
  int? _draggingRowIndex;

  @override
  void initState() {
    super.initState();
    _pillars = List<PillarType>.of(
      widget.pillarOrder ?? const [
        PillarType.year,
        PillarType.month,
        PillarType.day,
        PillarType.hour,
      ],
    );
    _rows = List<RowConfig>.of(
      widget.rowConfigs ??
          const [
            RowConfig(type: RowType.heavenlyStem, isVisible: true, isTitleVisible: true),
            RowConfig(type: RowType.earthlyBranch, isVisible: true, isTitleVisible: true),
            RowConfig(type: RowType.tenGod, isVisible: true, isTitleVisible: true),
            RowConfig(type: RowType.naYin, isVisible: true, isTitleVisible: true),
          ],
    );
  }

  @override
  void didUpdateWidget(covariant EditableFourZhuCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pillarOrder != null && widget.pillarOrder != oldWidget.pillarOrder) {
      _pillars = List<PillarType>.of(widget.pillarOrder!);
    }
    if (widget.rowConfigs != null && widget.rowConfigs != oldWidget.rowConfigs) {
      _rows = List<RowConfig>.of(widget.rowConfigs!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = widget.backgroundColor ?? theme.cardColor;
    final pad = widget.padding ?? const EdgeInsets.all(16);
    final radius = widget.borderRadius ?? BorderRadius.circular(12);
    final elevation = widget.elevation ?? 1.0;

    final content = widget.axis == Axis.horizontal
        ? _buildHorizontalContent(context)
        : _buildVerticalContent(context);

    return Card(
      color: bg,
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: Padding(
        padding: pad,
        child: content,
      ),
    );
  }

  Widget _buildHorizontalContent(BuildContext context) {
    final visibleRows = _rows.where((r) => r.isVisible).toList();
    final headerH = widget.metricsResolver.headerHeight(context, cardStyle: widget.cardStyle);
    final cellH = widget.metricsResolver.rowHeight(context, cardStyle: widget.cardStyle);
    final slotW = widget.metricsResolver.slotWidth(context);

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
        // Header row with column titles
        Row(
          children: [
            // Empty cell for row labels column
            const SizedBox(width: 72),
            // Drop zone at start
            if (widget.isEditable) _buildColumnDropZone(0, slotW),
            // Column headers with drag handles
            ..._pillars.asMap().entries.map((entry) {
              final idx = entry.key;
              final p = entry.value;
              final pillarLabel = widget.pillarLabelResolver?.call(p) ?? _defaultPillarLabel(p);
              final isDragging = _draggingIndex == idx;

              final header = Expanded(
                child: Container(
                  height: headerH,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      '${pillarLabel}柱',
                      style: labelStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );

              final draggable = widget.isEditable
                  ? LongPressDraggable<int>(
                      data: idx,
                      onDragStarted: () => setState(() => _draggingIndex = idx),
                      onDragEnd: (_) => setState(() => _draggingIndex = null),
                      feedback: Material(
                        color: Colors.transparent,
                        elevation: 8,
                        child: Container(
                          width: 120,
                          height: headerH,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${pillarLabel}柱',
                              style: labelStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Expanded(
                        child: Container(
                          height: headerH,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: header,
                    )
                  : header;

              return [
                if (!isDragging) draggable,
                if (widget.isEditable) _buildColumnDropZone(idx + 1, slotW),
              ];
            }).expand((e) => e),
            // Spacer for row drag handle column
            if (widget.isEditable) const SizedBox(width: 48),
          ],
        ),

        const SizedBox(height: 8),

        // Data rows with drop zones
        ...visibleRows.asMap().entries.expand((entry) {
          final rowIdx = entry.key;
          final cfg = entry.value;
          final rLabel = widget.rowLabelResolver?.call(cfg.type) ?? _defaultRowLabel(cfg.type);

          return [
            if (widget.isEditable && rowIdx == 0) _buildRowDropZone(0),
            _buildTableRow(
              context,
              rowIdx,
              cfg,
              rLabel,
              cellH,
              labelStyle,
            ),
            if (widget.isEditable) _buildRowDropZone(rowIdx + 1),
          ];
        }),

        // Bottom row with column drag handles (only in edit mode)
        if (widget.isEditable) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(width: 72),
              ..._pillars.asMap().entries.map((entry) {
                final idx = entry.key;
                return Expanded(
                  child: Center(
                    child: LongPressDraggable<int>(
                      data: idx,
                      onDragStarted: () => setState(() => _draggingIndex = idx),
                      onDragEnd: (_) => setState(() => _draggingIndex = null),
                      feedback: const Material(
                        color: Colors.transparent,
                        child: Text('👆', style: TextStyle(fontSize: 24)),
                      ),
                      child: const Text('👆', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    int rowIdx,
    RowConfig cfg,
    String rLabel,
    double cellH,
    TextStyle labelStyle,
  ) {
    final style = widget.styleResolver.resolveTextStyle(
      context: context,
      rowType: cfg.type,
      cardStyle: widget.cardStyle,
      rowConfig: cfg,
    );

    final rowContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Row label
          SizedBox(
            width: 72,
            height: cellH,
            child: Center(
              child: Text(rLabel, style: labelStyle, textAlign: TextAlign.center),
            ),
          ),
          // Data cells
          ..._pillars.map((p) {
            return Expanded(
              child: Container(
                height: cellH,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Center(
                  child: _buildCell(context, cfg.type, p, style),
                ),
              ),
            );
          }),
          // Row drag handle (only in edit mode)
          if (widget.isEditable)
            SizedBox(
              width: 48,
              height: cellH,
              child: const Center(
                child: Text('👆', style: TextStyle(fontSize: 20)),
              ),
            ),
        ],
      ),
    );

    // Wrap in draggable if in edit mode
    if (!widget.isEditable) return rowContent;

    return LongPressDraggable<String>(
      data: 'row_$rowIdx',
      onDragStarted: () => setState(() => _draggingRowIndex = rowIdx),
      onDragEnd: (_) => setState(() => _draggingRowIndex = null),
      feedback: Material(
        color: Colors.transparent,
        elevation: 8,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: rowContent,
        ),
      ),
      childWhenDragging: Container(
        height: cellH + 4,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: rowContent,
    );
  }

  Widget _buildColumnDropZone(int position, double width) {
    final active = _hoverDropIndex == position;

    return DragTarget<Object>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        final accept = data is int || data is PillarType;
        if (accept) setState(() => _hoverDropIndex = position);
        return accept;
      },
      onLeave: (_) {
        if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
      },
      onAcceptWithDetails: (details) {
        final data = details.data;
        if (data is int) {
          _reorderPillars(data, position);
        } else if (data is PillarType) {
          _insertPillarAt(position, data);
        }
        setState(() => _hoverDropIndex = null);
      },
      builder: (context, candidateData, rejectedData) {
        final show = active || candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: show ? 80 : width,
          child: show
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildRowDropZone(int position) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        if (data.startsWith('row_')) {
          setState(() => _hoverDropIndex = position + 1000); // Offset to distinguish from column zones
          return true;
        }
        return false;
      },
      onLeave: (_) {
        if (_hoverDropIndex == position + 1000) {
          setState(() => _hoverDropIndex = null);
        }
      },
      onAcceptWithDetails: (details) {
        final data = details.data;
        if (data.startsWith('row_')) {
          final fromIndex = int.parse(data.substring(4));
          _reorderRows(fromIndex, position);
          setState(() => _hoverDropIndex = null);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final show = _hoverDropIndex == position + 1000 || candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: show ? 40 : 4,
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: show
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  void _reorderRows(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    final visibleRows = _rows.where((r) => r.isVisible).toList();
    if (oldIndex < 0 || oldIndex >= visibleRows.length) return;

    var targetIndex = newIndex;
    if (newIndex > oldIndex) {
      targetIndex = newIndex - 1;
    }
    targetIndex = targetIndex.clamp(0, visibleRows.length - 1);

    // Create new list with reordered visible rows
    final reorderedVisible = List<RowConfig>.of(visibleRows);
    final item = reorderedVisible.removeAt(oldIndex);
    reorderedVisible.insert(targetIndex, item);

    // Merge back with invisible rows (keeping their original positions)
    final newRows = <RowConfig>[];
    var visibleIdx = 0;
    for (final row in _rows) {
      if (row.isVisible) {
        newRows.add(reorderedVisible[visibleIdx]);
        visibleIdx++;
      } else {
        newRows.add(row);
      }
    }

    setState(() => _rows = newRows);
    widget.onRowConfigsChanged?.call(List<RowConfig>.of(_rows));
  }

  Widget _buildHorizontalPillarTile(
    BuildContext context,
    int idx,
    PillarType pillar,
    List<RowConfig> visibleRows,
    double tileW,
    double headerH,
    double cellH,
    double tileH,
  ) {
    final border = Theme.of(context).dividerColor;
    final labelStyle = widget.styleResolver.resolveTextStyle(
      context: context,
      rowType: RowType.heavenlyStem,
      cardStyle: widget.cardStyle,
      rowConfig: null,
      fontWeight: FontWeight.w600,
    );
    final pillarLabel = widget.pillarLabelResolver?.call(pillar) ?? _defaultPillarLabel(pillar);

    // Special rendering for separator pillar
    if (pillar == PillarType.separator) {
      return SizedBox(
        width: tileW,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
          ),
          child: Center(
            child: Container(
              width: 2,
              height: tileH - 12,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: tileW,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: headerH,
              child: Row(
                children: [
                  if (widget.isEditable)
                    LongPressDraggable<int>(
                      data: idx,
                      onDragStarted: () => setState(() => _draggingIndex = idx),
                      onDragEnd: (_) => setState(() => _draggingIndex = null),
                      feedback: Material(
                        color: Colors.transparent,
                        elevation: 8,
                        child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(width: tileW, height: tileH),
                          child: Opacity(opacity: 0.95, child: _buildHorizontalPillarTile(context, idx, pillar, visibleRows, tileW, headerH, cellH, tileH)),
                        ),
                      ),
                      child: const Icon(Icons.pan_tool_alt, size: 18), // ✋🏻 handle
                    )
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(pillarLabel, style: labelStyle, textAlign: TextAlign.center),
                  ),
                  if (widget.isEditable)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: '删除',
                      onPressed: () => _removePillarAt(idx),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...visibleRows.map((cfg) {
              final style = widget.styleResolver.resolveTextStyle(
                context: context,
                rowType: cfg.type,
                cardStyle: widget.cardStyle,
                rowConfig: cfg,
              );
              return SizedBox(
                height: cellH,
                child: Align(
                  alignment: Alignment.center,
                  child: _buildCell(context, cfg.type, pillar, style),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _horizontalPlaceholderTile(BuildContext context, double tileH, double tileW) {
    final color = Theme.of(context)
        .colorScheme
        .primary
        .withValues(alpha: widget.metricsResolver.ghostFillAlpha(context));
    final border = Theme.of(context)
        .colorScheme
        .primary
        .withValues(alpha: widget.metricsResolver.ghostBorderAlpha(context));
    return SizedBox(
      width: tileW,
      height: tileH,
      child: Container(
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.metricsResolver.cornerRadius(context)),
            border: Border.all(color: border)),
        margin: widget.metricsResolver.tileMargin(context),
      ),
    );
  }

  Widget _buildHorizontalSlot(int position, double slotW, double tileH, double tileW) {
    final active = _hoverDropIndex == position;
    final placeholder = _horizontalPlaceholderTile(context, tileH, tileW);
    return DragTarget<Object>(
      onWillAccept: (data) {
        final accept = data is int || data is PillarType;
        if (accept) setState(() => _hoverDropIndex = position);
        return accept;
      },
      onLeave: (_) {
        if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
      },
      onAccept: (data) {
        if (data is int) {
          _reorderPillars(data, position);
        } else if (data is PillarType) {
          _insertPillarAt(position, data);
        }
        if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
      },
      builder: (context, candidate, rejected) {
        final show = active || candidate.isNotEmpty;
        return SizedBox(
          width: show ? tileW : slotW,
          height: tileH,
          child: show ? placeholder : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildAddTile(double tileH, double tileW) {
    return SizedBox(
      width: tileW,
      height: tileH,
      child: Stack(
        children: [
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: widget.onAddPillarRequested,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)),
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                ),
                width: tileW - 12,
                height: tileH - 12,
                child: const Center(child: Icon(Icons.add, size: 20)),
              ),
            ),
          ),
          Positioned.fill(
            child: DragTarget<PillarType>(
              onWillAccept: (data) => data != null,
              onAccept: (type) => _insertPillarAt(_pillars.length, type),
              builder: (context, candidate, rejected) {
                return IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: candidate.isNotEmpty
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _removePillarAt(int index) {
    if (index < 0 || index >= _pillars.length) return;
    final next = List<PillarType>.of(_pillars)..removeAt(index);
    setState(() => _pillars = next);
    widget.onPillarOrderChanged?.call(List<PillarType>.of(_pillars));
  }

  Widget _buildVerticalContent(BuildContext context) {
    final visibleRows = _rows.where((r) => r.isVisible).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildVerticalHeader(context),
        const SizedBox(height: 8),
        // Top slot
        if (widget.isEditable) _buildVerticalSlot(0),
        ..._pillars.asMap().entries.expand((entry) {
          final idx = entry.key;
          final p = entry.value;
          final tile = _buildVerticalPillarTile(context, p, visibleRows);
          final draggable = widget.isEditable
              ? LongPressDraggable<int>(
                  data: idx,
                  feedback: Material(
                    color: Colors.transparent,
                    elevation: 8,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Opacity(opacity: 0.9, child: tile),
                    ),
                  ),
                  childWhenDragging: _verticalPlaceholderTile(context),
                  child: tile,
                )
              : tile;
          return [
            draggable,
            if (widget.isEditable) _buildVerticalSlot(idx + 1),
          ];
        }).toList(),
      ],
    );
  }

  Widget _buildVerticalHeader(BuildContext context) {
    final labelStyle = widget.styleResolver.resolveTextStyle(
      context: context,
      rowType: RowType.heavenlyStem,
      cardStyle: widget.cardStyle,
      rowConfig: null,
      fontWeight: FontWeight.w600,
    );
    return Row(
      children: [
        SizedBox(width: 48, child: Text('四柱', style: labelStyle, textAlign: TextAlign.center)),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 16,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _rows
                .where((r) => r.isVisible)
                .map((r) => Text(
                      widget.rowLabelResolver?.call(r.type) ?? _defaultRowLabel(r.type),
                      style: labelStyle,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalPillarTile(BuildContext context, PillarType pillar, List<RowConfig> visibleRows) {
    final border = Theme.of(context).dividerColor;
    final labelStyle = widget.styleResolver.resolveTextStyle(
      context: context,
      rowType: RowType.heavenlyStem,
      cardStyle: widget.cardStyle,
      rowConfig: null,
      fontWeight: FontWeight.w600,
    );
    final pillarLabel = widget.pillarLabelResolver?.call(pillar) ?? _defaultPillarLabel(pillar);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.drag_indicator, size: 18, color: widget.isEditable ? null : Colors.transparent),
          const SizedBox(width: 8),
          SizedBox(width: 36, child: Text(pillarLabel, style: labelStyle, textAlign: TextAlign.center)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: visibleRows.map((cfg) {
                final style = widget.styleResolver.resolveTextStyle(
                  context: context,
                  rowType: cfg.type,
                  cardStyle: widget.cardStyle,
                  rowConfig: cfg,
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Align(
                    alignment: Alignment.center,
                    child: _buildCell(context, cfg.type, pillar, style),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalPlaceholderTile(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.10);
    final border = Theme.of(context).colorScheme.primary.withValues(alpha: 0.35);
    return Container(
      height: 72,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
      margin: const EdgeInsets.symmetric(vertical: 6),
    );
  }

  Widget _buildVerticalSlot(int position) {
    final active = _hoverDropIndex == position;
    return DragTarget<Object>(
      onWillAccept: (data) {
        final accept = data is int || data is PillarType;
        if (accept) setState(() => _hoverDropIndex = position);
        return accept;
      },
      onLeave: (_) {
        if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
      },
      onAccept: (data) {
        if (data is int) {
          _reorderPillars(data, position);
        } else if (data is PillarType) {
          _insertPillarAt(position, data);
        }
        if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
      },
      builder: (context, candidate, rejected) {
        final show = active || candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: show ? 72 : 12,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: show
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)),
                )
              : const BoxDecoration(),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final labelStyle = widget.styleResolver.resolveTextStyle(
      context: context,
      rowType: RowType.heavenlyStem,
      cardStyle: widget.cardStyle,
      rowConfig: null,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            '四柱',
            style: labelStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final w = constraints.maxWidth;
              final count = _pillars.length;
              const dzWidth = 20.0;
              final totalDz = count + 1;
              final cellW = count > 0 ? (w - dzWidth * totalDz) / count : 0.0;
              return Stack(
                children: [
                  Row(
                    children: [
                      if (widget.isEditable)
                        _buildPillarSlot(0, dzWidth, cellW)
                      else
                        SizedBox(width: dzWidth),
                      ..._pillars.asMap().entries.expand((entry) {
                        final index = entry.key;
                        final p = entry.value;
                        final label = widget.pillarLabelResolver?.call(p) ?? _defaultPillarLabel(p);
                        final headerChild = widget.pillarHeaderBuilder?.call(
                              context,
                              pillarType: p,
                              labelTextStyle: labelStyle,
                            ) ??
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.isEditable) const Icon(Icons.drag_indicator, size: 16),
                                Flexible(child: Text(label, style: labelStyle, textAlign: TextAlign.center)),
                              ],
                            );
                        final cell = SizedBox(
                          width: cellW,
                          child: headerChild,
                        );
                        final draggable = widget.isEditable
                            ? LongPressDraggable<int>(
                                data: index,
                                onDragStarted: () => setState(() => _draggingIndex = index),
                                onDragEnd: (_) => setState(() => _draggingIndex = null),
                                feedback: Material(
                                  elevation: 8,
                                  color: Colors.transparent,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints.tightFor(width: cellW),
                                    child: Opacity(opacity: 0.85, child: headerChild),
                                  ),
                                ),
                                childWhenDragging: _placeholderColumn(context, cellW),
                                child: cell,
                              )
                            : cell;
                        return [
                          draggable,
                          if (widget.isEditable)
                            _buildPillarSlot(index + 1, dzWidth, cellW)
                          else
                            SizedBox(width: dzWidth),
                        ];
                      }).toList(),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPillarSlot(int position, double dzWidth, double cellW) {
    final active = _hoverDropIndex == position;
    final color = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      width: active ? cellW : dzWidth,
      height: 28,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (active) _placeholderColumn(context, cellW),
          DragTarget<int>(
            onWillAccept: (from) {
              final accept = from != null && from >= 0 && from < _pillars.length;
              if (accept) setState(() => _hoverDropIndex = position);
              return accept;
            },
            onLeave: (_) {
              if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
            },
            onAccept: (from) {
              _reorderPillars(from, position);
              if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
            },
            builder: (context, _, __) => const SizedBox.expand(),
          ),
          DragTarget<PillarType>(
            onWillAccept: (data) {
              final accept = data != null;
              if (accept) setState(() => _hoverDropIndex = position);
              return accept;
            },
            onLeave: (_) {
              if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
            },
            onAccept: (pillarType) {
              _insertPillarAt(position, pillarType);
              if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
            },
            builder: (context, _, __) => const SizedBox.expand(),
          ),
        ],
      ),
    );
  }

  Widget _placeholderColumn(BuildContext context, double cellW) {
    final color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);
    final border = Theme.of(context).colorScheme.primary.withValues(alpha: 0.35);
    return Container(
      width: cellW,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: border),
      ),
    );
  }

  Widget _buildPillarDropZone(int position, double width) {
    final isActive = _hoverDropIndex == position;
    final decoration = BoxDecoration(
      color: isActive ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
      border: isActive
          ? Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5))
          : null,
    );
    return SizedBox(
      width: width,
      height: 28,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            decoration: decoration,
          ),
          // Internal reorder target (pillar index drag)
          DragTarget<int>(
            onWillAccept: (from) {
              final accept = from != null && from >= 0 && from < _pillars.length;
              if (accept) setState(() => _hoverDropIndex = position);
              return accept;
            },
            onLeave: (_) {
              if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
            },
            onAccept: (from) {
              _reorderPillars(from, position);
              if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
            },
            builder: (context, _, __) => const SizedBox.expand(),
          ),
          // External add target (accept PillarType from test draggable)
          DragTarget<PillarType>(
            onWillAccept: (data) {
              final accept = data != null;
              if (accept) setState(() => _hoverDropIndex = position);
              return accept;
            },
            onLeave: (_) {
              if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
            },
            onAccept: (pillarType) {
              _insertPillarAt(position, pillarType);
              if (_hoverDropIndex == position) setState(() => _hoverDropIndex = null);
            },
            builder: (context, _, __) => const SizedBox.expand(),
          ),
        ],
      ),
    );
  }

  void _reorderPillars(int oldIndex, int newIndex) {
    // newIndex is a drop zone slot index in [0.._pillars.length]
    // Use utility to handle index shift semantics.
    final moved = _moveItem(_pillars, oldIndex, newIndex);
    setState(() => _pillars = moved);
    widget.onPillarOrderChanged?.call(List<PillarType>.of(_pillars));
  }

  void _insertPillarAt(int index, PillarType type) {
    final copy = List<PillarType>.of(_pillars);
    final insertIndex = index.clamp(0, copy.length);
    copy.insert(insertIndex, type);
    setState(() => _pillars = copy);
    widget.onPillarOrderChanged?.call(List<PillarType>.of(_pillars));
  }

  List<T> _moveItem<T>(List<T> list, int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return List<T>.of(list);
    if (oldIndex < 0 || oldIndex >= list.length) return List<T>.of(list);
    if (newIndex < 0 || newIndex > list.length) return List<T>.of(list);
    final copy = List<T>.of(list);
    final item = copy.removeAt(oldIndex);
    var insertIndex = newIndex;
    if (newIndex > oldIndex) {
      insertIndex = newIndex - 1;
    }
    copy.insert(insertIndex, item);
    return copy;
  }

  List<Widget> _buildRows(BuildContext context) {
    final visible = _rows.where((r) => r.isVisible).toList();
    final List<Widget> children = [];
    for (var i = 0; i < visible.length; i++) {
      final cfg = visible[i];
      children.add(_buildRow(context, cfg));
      if (i != visible.length - 1) {
        final divider = widget.dividerBuilder?.call(context) ??
            widget.styleResolver.resolveRowDivider(context: context, cardStyle: widget.cardStyle, rowConfig: cfg);
        children.add(divider);
      }
    }
    return children;
  }

  Widget _buildRow(BuildContext context, RowConfig cfg) {
    final rowLabel = widget.rowLabelResolver?.call(cfg.type) ?? _defaultRowLabel(cfg.type);
    final labelStyle = widget.styleResolver.resolveTextStyle(
      context: context,
      rowType: cfg.type,
      cardStyle: widget.cardStyle,
      rowConfig: cfg,
      fontWeight: FontWeight.w600,
    );

    final rowPad = widget.styleResolver.resolveRowPadding(
      context: context,
      rowType: cfg.type,
      cardStyle: widget.cardStyle,
      rowConfig: cfg,
    );

    return Padding(
      padding: rowPad,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            child: cfg.isTitleVisible
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isEditable)
                        const Icon(Icons.drag_handle, size: 16),
                      Flexible(
                        child: Text(rowLabel, style: labelStyle, textAlign: TextAlign.center),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final contentWidth = constraints.maxWidth;
                final count = _pillars.length;
                const dzWidth = 24.0;
                final cellW = count > 0 ? contentWidth / count : 0.0;

                final rowCells = Row(
                  children: _pillars.map((p) {
                    final effective = widget.styleResolver.resolveTextStyle(
                      context: context,
                      rowType: cfg.type,
                      cardStyle: widget.cardStyle,
                      rowConfig: cfg,
                    );
                    return SizedBox(
                      width: cellW,
                      child: _buildCell(context, cfg.type, p, effective),
                    );
                  }).toList(),
                );

                return Stack(
                  children: [
                    rowCells,
                    if (widget.isEditable)
                      Positioned.fill(
                        child: Stack(
                          children: [
                            if (_hoverDropIndex != null)
                              Positioned(
                                left: (_hoverDropIndex! * cellW).clamp(0.0, contentWidth - cellW),
                                width: cellW,
                                top: 0,
                                bottom: 0,
                                child: IgnorePointer(
                                  child: Container(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                                  ),
                                ),
                              ),
                            ...List.generate(count + 1, (i) {
                              final left = (i * cellW - dzWidth / 2).clamp(0.0, contentWidth - dzWidth);
                              return Positioned(
                                left: left,
                                width: dzWidth,
                                top: 0,
                                bottom: 0,
                                child: DragTarget<PillarType>(
                                  onWillAccept: (data) {
                                    final accept = data != null;
                                    if (accept) setState(() => _hoverDropIndex = i);
                                    return accept;
                                  },
                                  onLeave: (_) {
                                    if (_hoverDropIndex == i) setState(() => _hoverDropIndex = null);
                                  },
                                  onAccept: (type) {
                                    _insertPillarAt(i, type);
                                    if (_hoverDropIndex == i) setState(() => _hoverDropIndex = null);
                                  },
                                  builder: (context, candidate, rejected) {
                                    final active = candidate.isNotEmpty && _hoverDropIndex == i;
                                    return IgnorePointer(
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 120),
                                        decoration: BoxDecoration(
                                          color: active
                                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                                              : Colors.transparent,
                                          border: active
                                              ? Border.all(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.35),
                                                )
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, RowType row, PillarType pillar, TextStyle style) {
    if (widget.rowCellBuilder != null) {
      return widget.rowCellBuilder!(
        context,
        rowType: row,
        pillarType: pillar,
        eightChars: widget.eightChars,
        effectiveTextStyle: style,
      );
    }
    // Default cells: resolve data from EightChars
    switch (row) {
      case RowType.heavenlyStem:
        final text = _tianGanForPillar(pillar).value;
        final color = widget.elementColorResolver.colorForGan(_tianGanForPillar(pillar), context);
        return Text(text, style: style.copyWith(color: color), textAlign: TextAlign.center);
      case RowType.earthlyBranch:
        final text = _diZhiForPillar(pillar).value;
        final color = widget.elementColorResolver.colorForZhi(_diZhiForPillar(pillar), context);
        return Text(text, style: style.copyWith(color: color), textAlign: TextAlign.center);
      case RowType.tenGod:
        final tg = widget.eightChars.dayTianGan;
        final god = _tenGodForPillar(pillar, tg);
        return Text(god.shortName, style: style, textAlign: TextAlign.center);
      case RowType.naYin:
        final jy = _jiaZiForPillar(pillar);
        return Text(jy.naYin.name, style: style, textAlign: TextAlign.center);
      default:
        return const SizedBox.shrink();
    }
  }

  // Helpers to extract row content from EightChars
  // These do not hardcode colors/fonts; color is delegated to elementColorResolver.
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

  gods.EnumTenGods _tenGodForPillar(PillarType p, tg.TianGan dayMaster) {
    switch (p) {
      case PillarType.year:
        return widget.eightChars.yearTianGan.getTenGods(dayMaster);
      case PillarType.month:
        return widget.eightChars.monthTianGan.getTenGods(dayMaster);
      case PillarType.day:
        return widget.eightChars.dayTianGan.getTenGods(dayMaster);
      case PillarType.hour:
        return widget.eightChars.hourTianGan.getTenGods(dayMaster);
      default:
        return widget.eightChars.yearTianGan.getTenGods(dayMaster);
    }
  }

  String _defaultRowLabel(RowType type) {
    switch (type) {
      case RowType.heavenlyStem:
        return '天干';
      case RowType.earthlyBranch:
        return '地支';
      case RowType.tenGod:
        return '十神';
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
      case PillarType.separator:
        return '|';
      default:
        return type.name;
    }
  }
}
