import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';
import '../enums/enum_tian_gan.dart' as tg;
import '../enums/enum_di_zhi.dart' as dz;
import '../enums/enum_jia_zi.dart' as jz;
import '../models/eight_chars.dart';
import '../models/layout_template.dart' show CardStyle, RowConfig;
import '../utils/style_resolver.dart';

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

  @override
  State<ColumnReorderableFourZhuCard> createState() => _ColumnReorderableFourZhuCardState();
}

class _ColumnReorderableFourZhuCardState extends State<ColumnReorderableFourZhuCard> {
  late List<PillarType> _pillars;
  late List<RowConfig> _rows;

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
      widget.rowConfigs ?? const [
        RowConfig(type: RowType.heavenlyStem, isVisible: true, isTitleVisible: true),
        RowConfig(type: RowType.earthlyBranch, isVisible: true, isTitleVisible: true),
        RowConfig(type: RowType.naYin, isVisible: true, isTitleVisible: true),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant ColumnReorderableFourZhuCard oldWidget) {
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
    final visibleRows = _rows.where((r) => r.isVisible).toList();
    final headerH = widget.metricsResolver.headerHeight(context, cardStyle: widget.cardStyle);
    final cellH = widget.metricsResolver.rowHeight(context, cardStyle: widget.cardStyle);

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
        final availableWidth = containerWidth - 72 - (widget.isEditable ? 48 : 0);
        final columnWidth = availableWidth / _pillars.length;

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
                    height: headerH + visibleRows.length * cellH + (widget.isEditable ? 32 : 0), // 增加底部👆的高度
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
                                final item = _pillars.removeAt(oldIndex);
                                _pillars.insert(newIndex, item);
                              });
                              widget.onPillarOrderChanged?.call(List<PillarType>.of(_pillars));
                            },
                            proxyDecorator: (child, index, animation) {
                              return AnimatedBuilder(
                                animation: animation,
                                builder: (context, child) {
                                  final t = Curves.easeInOut.transform(animation.value);
                                  return Transform.scale(
                                    scale: 1.0 + (0.05 * t),
                                    child: Transform.rotate(
                                      angle: 0.02 * t,
                                      child: Material(
                                        elevation: 8.0 + (8.0 * t),
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Theme.of(context).colorScheme.primary,
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
                              return SizedBox(
                                key: ValueKey(p),
                                width: columnWidth,
                                child: ReorderableDragStartListener(
                                  index: index,
                                  child: _buildColumn(p, headerH, cellH, labelStyle, visibleRows, true),
                                ),
                              );
                            },
                          )
                        : Row(
                            children: _pillars.map((p) {
                              return SizedBox(
                                width: columnWidth,
                                child: _buildColumn(p, headerH, cellH, labelStyle, visibleRows, false),
                              );
                            }).toList(),
                          ),
                  ),
                ),

                // 右侧占位
                if (widget.isEditable) const SizedBox(width: 48),
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
        SizedBox(width: 72, height: headerH), // 空白标题
        ...visibleRows.map((cfg) {
          final rLabel = widget.rowLabelResolver?.call(cfg.type) ?? _defaultRowLabel(cfg.type);
          return Container(
            width: 72,
            height: cellH,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Center(
              child: Text(rLabel, style: labelStyle, textAlign: TextAlign.center),
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
  ) {
    final pillarLabel = widget.pillarLabelResolver?.call(pillar) ?? _defaultPillarLabel(pillar);

    return MouseRegion(
      cursor: isEditable ? SystemMouseCursors.grab : SystemMouseCursors.basic,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 主体列
          Container(
            decoration: isEditable
                ? BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Container(
                  height: headerH,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: isEditable
                      ? BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
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
                  return Container(
                    height: cellH,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Center(
                      child: _buildCell(context, cfg.type, pillar, style),
                    ),
                  );
                }),
              ],
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

  Widget _buildCell(BuildContext context, RowType row, PillarType pillar, TextStyle style) {
    switch (row) {
      case RowType.heavenlyStem:
        final text = _tianGanForPillar(pillar).value;
        final color = widget.elementColorResolver.colorForGan(_tianGanForPillar(pillar), context);
        return Text(text, style: style.copyWith(color: color), textAlign: TextAlign.center);
      case RowType.earthlyBranch:
        final text = _diZhiForPillar(pillar).value;
        final color = widget.elementColorResolver.colorForZhi(_diZhiForPillar(pillar), context);
        return Text(text, style: style.copyWith(color: color), textAlign: TextAlign.center);
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
}
