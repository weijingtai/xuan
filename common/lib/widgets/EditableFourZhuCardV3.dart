import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'dart:ui' as ui;

import '../enums/enum_gender.dart';
import '../enums/enum_jia_zi.dart';
import '../enums/enum_tian_gan.dart';
import '../enums/enum_di_zhi.dart';

/// EditableFourZhuCardV3
/// 单视图、双轴拖拽：在同一个网格视图中完成行与列的重排，不再依赖两个 ReorderableListView。
@Deprecated('效果不佳，Use EditableFourZhuCardV2 instead')
class EditableFourZhuCardV3 extends StatefulWidget {
  final ValueNotifier<List<Tuple2<String, JiaZi>>> jiaZiNotifier;
  final ValueNotifier<List<String>> rowListNotifier;
  final ValueNotifier<EdgeInsets> paddingNotifier;
  final Gender gender;
  // Optional: decorate drag feedback (overlay proxy)
  final Widget Function(BuildContext context, Widget child)?
      dragFeedbackBuilder;
  // Optional: decorate insert indicators
  final Decoration Function(BuildContext context, bool isHover)?
      columnInsertDecorationBuilder;
  final Decoration Function(BuildContext context, bool isHover)?
      rowInsertDecorationBuilder;
  // Optional: visualize hysteresis boundaries for debugging
  final bool debugHysteresisOverlay;

  const EditableFourZhuCardV3({
    super.key,
    required this.jiaZiNotifier,
    required this.rowListNotifier,
    required this.paddingNotifier,
    required this.gender,
    this.dragFeedbackBuilder,
    this.columnInsertDecorationBuilder,
    this.rowInsertDecorationBuilder,
    this.debugHysteresisOverlay = false,
  });

  @override
  State<EditableFourZhuCardV3> createState() => _EditableFourZhuCardV3State();
}

enum _DragKind { row, column }

class _EditableFourZhuCardV3State extends State<EditableFourZhuCardV3> {
  // Root card key for global position checks
  final GlobalKey _cardKey = GlobalKey();
  // Metrics
  double pillarWidth = 64;
  double rowTitleWidth = 52;
  double columnTitleHeight = 24;
  double otherCellHeight = 32;

  Size get ganZhiCellSize => Size(pillarWidth, 48);

  // Size sync
  late final ValueNotifier<Size> _sizeNotifier;
  late final VoidCallback _pillarsListener;
  late final VoidCallback _rowsListener;

  // Drag state
  int? _draggingColumnIndex;
  int? _hoverColumnInsertIndex; // between 0..pillars.len
  // Drop animation state: fade-in the inserted column briefly
  int? _dropAnimatingColIndex;
  bool _dropColFadeActive = false;
  int? _draggingRowIndex; // absolute row index (skip header row 0)
  int? _hoverRowInsertIndex; // between 1..rows.len (skip header at 0)
  // Drop animation state: fade-in the inserted row briefly
  int? _dropAnimatingRowIndex;
  bool _dropRowFadeActive = false;
  // Throttle timestamps for continuous onMove updates
  DateTime? _lastColMoveAt;
  DateTime? _lastRowMoveAt;
  // Continuous hover positions (fractional), used for partial offsets
  double? _hoverColumnFloat; // range [0..pillars.length]
  double? _hoverRowFloat; // range [1..rows.length]
  // Smoothed floats to reduce jitter
  double? _hoverColumnFloatEff;
  double? _hoverRowFloatEff;
  // Last committed insert indices for hysteresis
  int? _lastColInsertIndex;
  int? _lastRowInsertIndex;

  // Drag feedback status notifiers: control dynamic "插入"/"删除" prompts on the dragged piece itself
  // When hovering a valid insert target inside the card, set insert=true, delete=false
  // When leaving card targets (outside card), set delete=true, insert=false
  final ValueNotifier<bool> _dragWantsInsert = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _dragWantsDelete = ValueNotifier<bool>(false);
  // Guard to prevent double-accept across overlapping DragTargets
  bool _rowAccepting = false;

  // Hysteresis margins to reduce jitter near boundaries
  static const double _colHysteresisFrac = 0.12; // fraction of pillarWidth
  static const double _rowHysteresisPx = 8.0; // pixels around row mid boundary

  double _smooth(double? prev, double next, [double alpha = 0.25]) {
    if (prev == null) return next;
    return prev + (next - prev) * alpha;
  }

  double _applyDeadzone(double v, [double dz = 0.08]) {
    return v.abs() < dz ? 0.0 : v;
  }

  int _commitColInsert(double eff, int draggingIdx, int n,
      [double threshold = 0.5]) {
    int target;
    if (eff > draggingIdx) {
      final hf = eff.floor();
      final frac = eff - hf; // [0,1)
      target = frac > threshold ? hf + 1 : hf;
    } else if (eff < draggingIdx) {
      final cf = eff.ceil();
      final frac = cf - eff; // (0,1]
      target = frac > threshold ? cf - 1 : cf;
    } else {
      target = draggingIdx;
    }
    return target.clamp(0, n);
  }

  int _commitRowInsert(double eff, int draggingIdx, int maxIndex,
      [double threshold = 0.5]) {
    int target;
    if (eff > draggingIdx) {
      final hf = eff.floor();
      final frac = eff - hf;
      target = frac > threshold ? hf + 1 : hf;
    } else if (eff < draggingIdx) {
      final cf = eff.ceil();
      final frac = cf - eff;
      target = frac > threshold ? cf - 1 : cf;
    } else {
      target = draggingIdx;
    }
    return target.clamp(1, maxIndex);
  }

  // Midpoint-based insert index from local dx for columns (gap in [0..n])
  int _computeColumnInsertIndexFromDx(double dx, int n) {
    // dx is measured from the start of the first column content (after row title)
    // Midpoint rule: index = floor(dx / pillarWidth + 0.5)
    final pos = (dx / pillarWidth);
    final idx = (pos + 0.5).floor();
    return idx.clamp(0, n);
  }

  @override
  void initState() {
    super.initState();
    _sizeNotifier = ValueNotifier<Size>(_computeSize());
    _pillarsListener = () => _sizeNotifier.value = _computeSize();
    _rowsListener = () => _sizeNotifier.value = _computeSize();
    widget.jiaZiNotifier.addListener(_pillarsListener);
    widget.rowListNotifier.addListener(_rowsListener);
  }

  @override
  void dispose() {
    widget.jiaZiNotifier.removeListener(_pillarsListener);
    widget.rowListNotifier.removeListener(_rowsListener);
    _sizeNotifier.dispose();
    _dragWantsInsert.dispose();
    _dragWantsDelete.dispose();
    super.dispose();
  }

  Size _computeSize() {
    final pillars = widget.jiaZiNotifier.value.length;
    final rows = widget.rowListNotifier.value.length;
    final width = rowTitleWidth + pillarWidth * pillars;
    final height = columnTitleHeight + // header row
        ganZhiCellSize.height * 2 + // 天干+地支（若存在）
        (rows - 3) * otherCellHeight; // 其他行（纳音等）
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Size>(
      valueListenable: _sizeNotifier,
      builder: (context, size, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          key: _cardKey,
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildGrid(size),
        );
      },
    );
  }

  Widget _buildGrid(Size size) {
    final pillars = widget.jiaZiNotifier.value;
    final rows = widget.rowListNotifier.value;
    final totalWidth = rowTitleWidth + pillarWidth * pillars.length;

    // Header row: gender + column titles; overlay a unified drag target for continuous index updates
    final headerRow = SizedBox(
      width: totalWidth,
      height: columnTitleHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _cell(Size(rowTitleWidth, columnTitleHeight),
                  _genderText(widget.gender)),
              ...(() {
                final d = _draggingColumnIndex;
                final t = _hoverColumnInsertIndex ?? _lastColInsertIndex;
                final List<Widget> children = [];
                for (int i = 0; i < pillars.length; i++) {
                  // 在每个列前插入一个可动画的幽灵占位，宽度在 0..pillarWidth 之间动画
                  final bool dragging = d != null;
                  children.add(AnimatedContainer(
                    duration: dragging
                        ? const Duration(milliseconds: 180)
                        : Duration.zero,
                    curve: Curves.easeOut,
                    width: dragging && t == i ? pillarWidth : 0,
                    height: columnTitleHeight,
                    color: dragging && t == i
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.08)
                        : Colors.transparent,
                  ));
                  if (d == i) continue; // 拖拽中的列不占原位置
                  final title = pillars[i].item1;
                  final childCell = Stack(
                    children: [
                      _cell(Size(pillarWidth, columnTitleHeight),
                          _dragHandle(_columnTitleText(title))),
                      if (dragging && t == i)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.35),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                  children.add(SizedBox(
                      width: pillarWidth,
                      height: columnTitleHeight,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        offset:
                            (_dropColFadeActive && _dropAnimatingColIndex == i)
                                ? const Offset(0.06, 0)
                                : Offset.zero,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          opacity: (_dropColFadeActive &&
                                  _dropAnimatingColIndex == i)
                              ? 0.0
                              : 1.0,
                          child: Draggable<Tuple2<_DragKind, int>>(
                            data: Tuple2(_DragKind.column, i),
                            onDragStarted: () {
                              setState(() => _draggingColumnIndex = i);
                              _dragWantsInsert.value = false;
                              _dragWantsDelete.value = false;
                            },
                            onDragEnd: (details) {
                              final at = details.offset;
                              final outside = !_isGlobalPointInsideCard(at);
                              final wantsDelete = _dragWantsDelete.value;
                              if (outside || wantsDelete) {
                                _deleteColumn(i);
                              }
                              setState(() {
                                _draggingColumnIndex = null;
                                _hoverColumnInsertIndex = null;
                                _lastColInsertIndex = null;
                              });
                              _dragWantsInsert.value = false;
                              _dragWantsDelete.value = false;
                            },
                            dragAnchorStrategy: pointerDragAnchorStrategy,
                            feedback: widget.dragFeedbackBuilder?.call(
                                  context,
                                  _buildFullColumnFeedback(
                                      title, pillars[i].item2, rows),
                                ) ??
                                _statusFeedback(
                                  _buildFullColumnFeedback(
                                      title, pillars[i].item2, rows),
                                ),
                            child: childCell,
                          ),
                        ),
                      )));
                }
                // 末尾插入位的可动画幽灵占位
                final bool dragging = d != null;
                children.add(AnimatedContainer(
                  duration: dragging
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  width: dragging && t == pillars.length ? pillarWidth : 0,
                  height: columnTitleHeight,
                  color: dragging && t == pillars.length
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                      : Colors.transparent,
                ));
                return children;
              })(),
            ],
          ),
          // 统一 DragTarget：填充在列标题区域之上，持续计算 hover 插入索引
          Positioned.fill(
            child: DragTarget<Tuple2<_DragKind, int>>(
              onWillAccept: (data) => data?.item1 == _DragKind.column,
              onMove: (details) {
                final data = details.data;
                if (data.item1 != _DragKind.column) return;
                // 轻节流：约 12ms 更新一次，避免过度重绘
                final now = DateTime.now();
                if (_lastColMoveAt != null &&
                    now.difference(_lastColMoveAt!).inMilliseconds < 12) {
                  return;
                }
                _lastColMoveAt = now;
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final local = box.globalToLocal(details.offset);
                final dx = local.dx - rowTitleWidth;
                final n = pillars.length;
                final d = _draggingColumnIndex;
                if (d == null) return;
                // Midpoint-based insert index with hysteresis near boundaries
                final candidate = _computeColumnInsertIndexFromDx(dx, n);
                final last = _hoverColumnInsertIndex ?? _lastColInsertIndex;
                if (last == null) {
                  setState(() {
                    _hoverColumnInsertIndex = candidate;
                    _lastColInsertIndex = candidate;
                  });
                  _dragWantsInsert.value = true;
                  _dragWantsDelete.value = false;
                  return;
                }
                if (candidate == last) {
                  return; // no change
                }
                final margin = pillarWidth * _colHysteresisFrac;
                final rightBoundary = (last + 0.5) * pillarWidth;
                final leftBoundary = (last - 0.5) * pillarWidth;
                bool allowUpdate = false;
                if (candidate > last) {
                  // moving right: must surpass right boundary + margin
                  allowUpdate = dx > rightBoundary + margin;
                } else {
                  // moving left: must pass left boundary - margin
                  allowUpdate = dx < leftBoundary - margin;
                }
                if (!allowUpdate) return;
                setState(() {
                  _hoverColumnInsertIndex = candidate;
                  _lastColInsertIndex = candidate;
                });
                _dragWantsInsert.value = true;
                _dragWantsDelete.value = false;
              },
              onLeave: (_) {
                setState(() {
                  _hoverColumnInsertIndex = null;
                  _lastColInsertIndex = null;
                });
                _dragWantsInsert.value = false;
                _dragWantsDelete.value = true;
              },
              onAccept: (payload) {
                final insertIndex = _hoverColumnInsertIndex ?? 0;
                setState(() {
                  _hoverColumnInsertIndex = null;
                  _lastColInsertIndex = null;
                  // 关键修复：接受插入后立即清除拖拽索引，避免被拖拽列被跳过而“消失”
                  _draggingColumnIndex = null;
                });
                _reorderColumns(payload.item2, insertIndex);
                _dragWantsInsert.value = false;
                _dragWantsDelete.value = false;
              },
              builder: (context, _, __) => const SizedBox.expand(),
            ),
          ),
          // Debug overlay: visualize column midpoint boundaries and hysteresis margins
          if (widget.debugHysteresisOverlay)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: CustomPaint(
                  painter: _ColumnHysteresisPainter(
                    columns: pillars.length,
                    rowTitleWidth: rowTitleWidth,
                    pillarWidth: pillarWidth,
                    margin: pillarWidth * _colHysteresisFrac,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.45),
                  ),
                ),
              ),
            ),
          // 插入位指示条：在当前 hover 的插入索引位置绘制细线，增强可视反馈
          if (_hoverColumnInsertIndex != null)
            Positioned(
              left: rowTitleWidth + pillarWidth * _hoverColumnInsertIndex! - 1,
              top: 0,
              width: 2,
              height: columnTitleHeight,
              child: Container(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
              ),
            ),
          // 移除卡片右上角删除提示，仅保留拖拽物上的动态徽标
        ],
      ),
    );

    // Left header column: row titles; overlay a unified drag target for continuous row index updates
    final leftHeader = SizedBox(
      width: rowTitleWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...(() {
                final d = _draggingRowIndex;
                final t = _hoverRowInsertIndex ?? _lastRowInsertIndex;
                final List<Widget> children = [];
                for (final entry in rows.asMap().entries.skip(1)) {
                  final absRowIdx = entry.key; // >=1
                  final rowName = entry.value;
                  final rowSize = _rowCellSize(rowName);
                  // 在每个行前插入一个可动画的幽灵占位，高度在 0..rowSize.height 之间动画
                  final bool draggingRow = d != null;
                  children.add(AnimatedContainer(
                    duration: draggingRow
                        ? const Duration(milliseconds: 180)
                        : Duration.zero,
                    curve: Curves.easeOut,
                    width: rowTitleWidth,
                    height: draggingRow && t == absRowIdx ? rowSize.height : 0,
                    color: draggingRow && t == absRowIdx
                        ? Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.08)
                        : Colors.transparent,
                  ));
                  if (d == absRowIdx) continue; // 拖拽中的行不占原位置
                  final cell = Stack(
                    children: [
                      _cell(
                        rowSize,
                        _dragHandle(_rowTitleText(rowName)),
                      ),
                      if (draggingRow && t == absRowIdx)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.35),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                  children.add(SizedBox(
                      height: rowSize.height,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        offset: (_dropRowFadeActive &&
                                _dropAnimatingRowIndex == absRowIdx)
                            ? const Offset(0, 0.06)
                            : Offset.zero,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          opacity: (_dropRowFadeActive &&
                                  _dropAnimatingRowIndex == absRowIdx)
                              ? 0.0
                              : 1.0,
                          child: Draggable<Tuple2<_DragKind, int>>(
                            data: Tuple2(_DragKind.row, absRowIdx),
                            onDragStarted: () {
                              setState(() => _draggingRowIndex = absRowIdx);
                              _dragWantsInsert.value = false;
                              _dragWantsDelete.value = false;
                            },
                            onDragEnd: (details) {
                              final at = details.offset;
                              final outside = !_isGlobalPointInsideCard(at);
                              final wantsDelete = _dragWantsDelete.value;
                              if (outside || wantsDelete) {
                                _deleteRow(absRowIdx);
                              }
                              setState(() {
                                _draggingRowIndex = null;
                                _hoverRowInsertIndex = null;
                                _lastRowInsertIndex = null;
                              });
                              _dragWantsInsert.value = false;
                              _dragWantsDelete.value = false;
                            },
                            dragAnchorStrategy: pointerDragAnchorStrategy,
                            feedback: widget.dragFeedbackBuilder?.call(
                                  context,
                                  _buildFullRowFeedback(rowName, pillars),
                                ) ??
                                _statusFeedback(
                                  _buildFullRowFeedback(rowName, pillars),
                                ),
                            child: cell,
                          ),
                        ),
                      )));
                }
                // 末尾插入位的可动画幽灵占位
                final draggedRowName =
                    (d != null && d < rows.length) ? rows[d] : null;
                final draggedSize = draggedRowName != null
                    ? _rowCellSize(draggedRowName)
                    : Size(rowTitleWidth, 0);
                final bool draggingRow = d != null;
                children.add(AnimatedContainer(
                  duration: draggingRow
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  width: rowTitleWidth,
                  height: draggingRow && (t == rows.length)
                      ? draggedSize.height
                      : 0,
                  color: draggingRow && (t == rows.length)
                      ? Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.08)
                      : Colors.transparent,
                ));
                return children;
              })(),
            ],
          ),
          Positioned.fill(
            child: DragTarget<Tuple2<_DragKind, int>>(
              onWillAccept: (data) => data?.item1 == _DragKind.row,
              onMove: (details) {
                final data = details.data;
                if (data.item1 != _DragKind.row) return;
                // 轻节流：约 12ms 更新一次，避免过度重绘
                final now = DateTime.now();
                if (_lastRowMoveAt != null &&
                    now.difference(_lastRowMoveAt!).inMilliseconds < 12) {
                  return;
                }
                _lastRowMoveAt = now;
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final local = box.globalToLocal(details.offset);
                final dy = local.dy;
                final d = _draggingRowIndex;
                if (d == null) return;
                // Midpoint-based insert index with hysteresis near boundaries
                final candidate =
                    _computeRowInsertIndexFromDyMidpoint(dy, rows);
                final last = _hoverRowInsertIndex ?? _lastRowInsertIndex;
                if (last == null) {
                  setState(() {
                    _hoverRowInsertIndex = candidate;
                    _lastRowInsertIndex = candidate;
                  });
                  return;
                }
                if (candidate == last) {
                  return; // no change
                }
                // 顶部插入位特殊处理：当目标为第一个可拖拽行（索引1）时立即更新，避免不让位
                if (candidate == 1) {
                  setState(() {
                    _hoverRowInsertIndex = 1;
                    _lastRowInsertIndex = 1;
                  });
                  return;
                }
                // compute boundary mid Y for last index (between last and last+1)
                final boundaryDown = _rowBoundaryMidY(last, rows);
                // boundary up is between last-1 and last; handle edge case at 1
                final boundaryUp =
                    last > 1 ? _rowBoundaryMidY(last - 1, rows) : 0.0;
                bool allowUpdate = false;
                if (candidate > last) {
                  // moving down: must surpass boundaryDown + margin
                  allowUpdate = dy > boundaryDown + _rowHysteresisPx;
                } else {
                  // moving up: must go above boundaryUp - margin
                  allowUpdate = dy < boundaryUp - _rowHysteresisPx;
                }
                if (!allowUpdate) return;
                setState(() {
                  _hoverRowInsertIndex = candidate;
                  _lastRowInsertIndex = candidate;
                });
              },
              onLeave: (_) => setState(() {
                _hoverRowInsertIndex = null;
                _lastRowInsertIndex = null;
              }),
              onAccept: (payload) {
                if (_rowAccepting) return;
                _rowAccepting = true;
                final insertIndex = _hoverRowInsertIndex ?? 1;
                setState(() {
                  _hoverRowInsertIndex = null;
                  _lastRowInsertIndex = null;
                  // 关键修复：接受插入后立即清除拖拽索引，避免被拖拽行被跳过而“消失”
                  _draggingRowIndex = null;
                });
                _reorderRows(payload.item2, insertIndex);
                Future.microtask(() {
                  if (!mounted) return;
                  setState(() {
                    _rowAccepting = false;
                  });
                });
              },
              builder: (context, _, __) => const SizedBox.expand(),
            ),
          ),
          // Debug overlay: visualize row midpoint boundaries and hysteresis margins
          if (widget.debugHysteresisOverlay)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: CustomPaint(
                  painter: _RowHysteresisPainter(
                    midYs: List<double>.generate(
                      rows.length - 1,
                      (i) => _rowBoundaryMidY(i + 1, rows),
                    ),
                    rowTitleWidth: rowTitleWidth,
                    marginPx: _rowHysteresisPx,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.45),
                  ),
                ),
              ),
            ),
          // 插入位指示条：在当前 hover 的行插入索引位置绘制横线，增强可视反馈
          if (_hoverRowInsertIndex != null)
            Positioned(
              left: 0,
              top: (_hoverRowInsertIndex == 1)
                  ? 0
                  : _computeRowInsertTopFromIndex(_hoverRowInsertIndex!, rows) -
                      1,
              width: rowTitleWidth,
              height: 2,
              child: Container(
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.35),
              ),
            ),
        ],
      ),
    );

    // Data grid: according to current row order
    final dataGrid = SizedBox(
      width: pillarWidth * pillars.length,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (() {
              final d = _draggingColumnIndex;
              final t = _hoverColumnInsertIndex ?? _lastColInsertIndex;
              final List<Widget> children = [];
              for (int i = 0; i < pillars.length; i++) {
                // 在每个列前插入一个可动画的幽灵列，占位宽度 0..pillarWidth
                final bool dragging = d != null;
                children.add(AnimatedContainer(
                  duration: dragging
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  width: dragging && t == i ? pillarWidth : 0,
                  color: dragging && t == i
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                      : Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: rows
                        .asMap()
                        .entries
                        .skip(1)
                        .map((r) => SizedBox(
                              width: pillarWidth,
                              height: (r.value == '天干' || r.value == '地支')
                                  ? ganZhiCellSize.height
                                  : otherCellHeight,
                            ))
                        .toList(),
                  ),
                ));
                if (d == i) continue; // 拖拽中的列不占原位置
                final tuple = pillars[i];
                final jz = tuple.item2;
                final columnContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...(() {
                      final dRow = _draggingRowIndex;
                      final tRow = _hoverRowInsertIndex ?? _lastRowInsertIndex;
                      final List<Widget> rowChildren = [];
                      for (final rEntry in rows.asMap().entries.skip(1)) {
                        final absRowIdx = rEntry.key;
                        final rowName = rEntry.value;
                        final rowSize = _rowCellSize(rowName);
                        // 在每个数据行前插入一个可动画的幽灵行，占位高度 0..rowSize.height
                        final bool draggingRow = dRow != null;
                        rowChildren.add(AnimatedContainer(
                          duration: draggingRow
                              ? const Duration(milliseconds: 180)
                              : Duration.zero,
                          curve: Curves.easeOut,
                          width: pillarWidth,
                          height: draggingRow && tRow == absRowIdx
                              ? rowSize.height
                              : 0,
                          color: draggingRow && tRow == absRowIdx
                              ? Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.08)
                              : Colors.transparent,
                        ));
                        if (dRow == absRowIdx) continue; // 拖拽中的行不占原位置
                        Widget cell;
                        if (rowName == '天干') {
                          cell =
                              _cell(ganZhiCellSize, _tianGanText(jz.tianGan));
                        } else if (rowName == '地支') {
                          cell = _cell(ganZhiCellSize, _diZhiText(jz.diZhi));
                        } else if (rowName == '纳音') {
                          cell = _cell(Size(pillarWidth, otherCellHeight),
                              _naYinText(jz.naYinStr));
                        } else {
                          cell = _cell(Size(pillarWidth, otherCellHeight),
                              _columnTitleText(tuple.item1));
                        }
                        rowChildren.add(AnimatedSlide(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          offset: (_dropRowFadeActive &&
                                  _dropAnimatingRowIndex == absRowIdx)
                              ? const Offset(0, 0.06)
                              : Offset.zero,
                          child: Stack(
                            children: [
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOutCubic,
                                opacity: (_dropRowFadeActive &&
                                        _dropAnimatingRowIndex == absRowIdx)
                                    ? 0.0
                                    : (_draggingRowIndex == absRowIdx
                                        ? 0.9
                                        : 1.0),
                                child: cell,
                              ),
                              if (draggingRow && tRow == absRowIdx)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.12),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.35),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ));
                      }
                      // 末尾插入：为最后一行之后增加可动画幽灵占位
                      final draggedRowName = (_draggingRowIndex != null &&
                              _draggingRowIndex! < rows.length)
                          ? rows[_draggingRowIndex!]
                          : null;
                      final draggedSize = draggedRowName != null
                          ? _rowCellSize(draggedRowName)
                          : Size(pillarWidth, 0);
                      final bool draggingRow = dRow != null;
                      rowChildren.add(AnimatedContainer(
                        duration: draggingRow
                            ? const Duration(milliseconds: 180)
                            : Duration.zero,
                        curve: Curves.easeOut,
                        width: pillarWidth,
                        height: draggingRow && (tRow == rows.length)
                            ? draggedSize.height
                            : 0,
                        color: draggingRow && (tRow == rows.length)
                            ? Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.08)
                            : Colors.transparent,
                      ));
                      return rowChildren;
                    })(),
                  ],
                );
                children.add(AnimatedSlide(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  offset: (_dropColFadeActive && _dropAnimatingColIndex == i)
                      ? const Offset(0.06, 0)
                      : Offset.zero,
                  child: Stack(
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        opacity:
                            (_dropColFadeActive && _dropAnimatingColIndex == i)
                                ? 0.0
                                : 1.0,
                        child: SizedBox(
                          width: pillarWidth,
                          child: columnContent,
                        ),
                      ),
                      if (dragging && t == i)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.35),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ));
              }
              // 末尾列插入位的可动画幽灵列
              final bool dragging = d != null;
              children.add(AnimatedContainer(
                duration: dragging
                    ? const Duration(milliseconds: 180)
                    : Duration.zero,
                curve: Curves.easeOut,
                width: dragging && t == pillars.length ? pillarWidth : 0,
                color: dragging && t == pillars.length
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                    : Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: rows
                      .asMap()
                      .entries
                      .skip(1)
                      .map((r) => SizedBox(
                            width: pillarWidth,
                            height: (r.value == '天干' || r.value == '地支')
                                ? ganZhiCellSize.height
                                : otherCellHeight,
                          ))
                      .toList(),
                ),
              ));
              return children;
            })(),
          ),
          // 覆盖数据网格区域的统一 DragTarget：在右侧也能持续计算行插入索引
          Positioned.fill(
            child: DragTarget<Tuple2<_DragKind, int>>(
              onWillAccept: (data) => data?.item1 == _DragKind.row,
              onMove: (details) {
                final data = details.data;
                if (data.item1 != _DragKind.row) return;
                // 轻节流：约 12ms 更新一次，避免过度重绘
                final now = DateTime.now();
                if (_lastRowMoveAt != null &&
                    now.difference(_lastRowMoveAt!).inMilliseconds < 12) {
                  return;
                }
                _lastRowMoveAt = now;
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final local = box.globalToLocal(details.offset);
                final dy = local.dy;
                final dRow = _draggingRowIndex;
                if (dRow == null) return;
                // Midpoint-based insert index with hysteresis near boundaries
                final candidate =
                    _computeRowInsertIndexFromDyMidpoint(dy, rows);
                final last = _hoverRowInsertIndex ?? _lastRowInsertIndex;
                if (last == null) {
                  setState(() {
                    _hoverRowInsertIndex = candidate;
                    _lastRowInsertIndex = candidate;
                  });
                  _dragWantsInsert.value = true;
                  _dragWantsDelete.value = false;
                  return;
                }
                if (candidate == last) {
                  return; // no change
                }
                // 顶部插入位特殊处理：当目标为第一个可拖拽行（索引1）时立即更新，避免不让位
                if (candidate == 1) {
                  setState(() {
                    _hoverRowInsertIndex = 1;
                    _lastRowInsertIndex = 1;
                  });
                  _dragWantsInsert.value = true;
                  _dragWantsDelete.value = false;
                  return;
                }
                // compute boundary mid Y for last index (between last and last+1)
                final boundaryDown = _rowBoundaryMidY(last, rows);
                // boundary up is between last-1 and last; handle edge case at 1
                final boundaryUp =
                    last > 1 ? _rowBoundaryMidY(last - 1, rows) : 0.0;
                bool allowUpdate = false;
                if (candidate > last) {
                  // moving down: must surpass boundaryDown + margin
                  allowUpdate = dy > boundaryDown + _rowHysteresisPx;
                } else {
                  // moving up: must go above boundaryUp - margin
                  allowUpdate = dy < boundaryUp - _rowHysteresisPx;
                }
                if (!allowUpdate) return;
                setState(() {
                  _hoverRowInsertIndex = candidate;
                  _lastRowInsertIndex = candidate;
                });
                _dragWantsInsert.value = true;
                _dragWantsDelete.value = false;
              },
              onLeave: (_) {
                setState(() {
                  _hoverRowInsertIndex = null;
                  _lastRowInsertIndex = null;
                });
                _dragWantsInsert.value = false;
                _dragWantsDelete.value = true;
              },
              onAccept: (payload) {
                if (_rowAccepting) return;
                _rowAccepting = true;
                final insertIndex = _hoverRowInsertIndex ?? 1;
                setState(() {
                  _hoverRowInsertIndex = null;
                  _lastRowInsertIndex = null;
                  _draggingRowIndex = null;
                });
                _reorderRows(payload.item2, insertIndex);
                Future.microtask(() {
                  if (!mounted) return;
                  setState(() {
                    _rowAccepting = false;
                  });
                });
                _dragWantsInsert.value = false;
                _dragWantsDelete.value = false;
              },
              builder: (context, _, __) => const SizedBox.expand(),
            ),
          ),
          // 行插入指示线（右侧数据网格覆盖）
          if (_hoverRowInsertIndex != null)
            Positioned(
              left: 0,
              top: (_hoverRowInsertIndex == 1)
                  ? 0
                  : _computeRowInsertTopFromIndex(_hoverRowInsertIndex!, rows) -
                      1,
              width: pillarWidth * pillars.length,
              height: 2,
              child: Container(
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.35),
              ),
            ),
          // 整行高亮：在目标插入位对应的整行显示提示（提升可见性）
          if (_hoverRowInsertIndex != null &&
              _hoverRowInsertIndex! >= 1 &&
              _hoverRowInsertIndex! < rows.length)
            Positioned(
              left: 0,
              top: _computeRowTopFromIndex(_hoverRowInsertIndex!, rows),
              width: pillarWidth * pillars.length,
              height: _rowCellSize(rows[_hoverRowInsertIndex!]).height,
              child: IgnorePointer(
                child: Container(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.06),
                ),
              ),
            ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerRow,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leftHeader,
            dataGrid,
          ],
        ),
      ],
    );
  }

  // 计算列位移：严格整步，让位区间内的每项平移一个完整宽度
  double _computeColumnShift(int i, int total) {
    final d = _draggingColumnIndex;
    final t = _hoverColumnInsertIndex ?? _lastColInsertIndex;
    if (d == null || t == null) return 0.0;
    if (t > d) {
      // 向右拖拽：区间 [d+1 .. t] 每项向后（右）平移一个单位
      if (i > d && i <= t) return 1.0;
    } else if (t < d) {
      // 向左拖拽：区间 [t .. d-1] 每项向后（左）平移一个单位（索引减小方向）
      if (i >= t && i < d) return -1.0;
    }
    return 0.0;
  }

  // --- Drag targets for column/row insert ---
  Widget _columnInsertTarget(int insertIndex, int max) {
    // insertIndex in [0..max], where 0 is after gender cell, >=1 between columns
    final isHover = _hoverColumnInsertIndex == insertIndex;
    return DragTarget<Tuple2<_DragKind, int>>(
      onWillAccept: (data) {
        if (data == null || data.item1 != _DragKind.column) return false;
        setState(() => _hoverColumnInsertIndex = insertIndex);
        return true;
      },
      onLeave: (_) => setState(() => _hoverColumnInsertIndex = null),
      onAccept: (payload) {
        setState(() => _hoverColumnInsertIndex = null);
        _reorderColumns(payload.item2, insertIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final decoration =
            widget.columnInsertDecorationBuilder?.call(context, isHover) ??
                BoxDecoration(
                  color: Colors.transparent,
                  border: isHover
                      ? Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.25),
                          width: 1.5,
                        )
                      : Border.all(color: Colors.transparent, width: 0),
                );
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
          width: isHover ? pillarWidth : 12, // 保持最小命中宽度
          height: columnTitleHeight, // 高度保持与标题一致
          decoration: decoration,
        );
      },
    );
  }

  Widget _rowInsertTarget(int insertIndex, int max) {
    // insertIndex in [1..max], skip header row 0
    final isHover = _hoverRowInsertIndex == insertIndex;
    // Height depends on the row to which the bar is adjacent; use a fixed small bar for simplicity
    return DragTarget<Tuple2<_DragKind, int>>(
      onWillAccept: (data) {
        if (data == null || data.item1 != _DragKind.row || data.item2 == 0) {
          return false; // skip header
        }
        setState(() => _hoverRowInsertIndex = insertIndex);
        return true;
      },
      onLeave: (_) => setState(() => _hoverRowInsertIndex = null),
      onAccept: (payload) {
        setState(() => _hoverRowInsertIndex = null);
        _reorderRows(payload.item2, insertIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final decoration =
            widget.rowInsertDecorationBuilder?.call(context, isHover) ??
                BoxDecoration(
                  color: Colors.transparent,
                  border: isHover
                      ? Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.25),
                          width: 1.5,
                        )
                      : Border.all(color: Colors.transparent, width: 0),
                );
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
          width: rowTitleWidth,
          height: isHover ? otherCellHeight : 12, // 保持最小命中高度
          decoration: decoration,
        );
      },
    );
  }

  // 计算行插入位的顶部位置（相对左侧标题区域），用于绘制指示条
  double _computeRowInsertTopFromIndex(int insertIndex, List<String> rows) {
    // insertIndex 取值 [1..rows.length]；当为 1 时表示在第一数据行之前
    double acc = 0.0;
    for (final entry in rows.asMap().entries) {
      final idx = entry.key;
      final name = entry.value;
      if (idx == 0) continue; // 跳过标题行
      if (idx >= insertIndex) break;
      final h = (name == '天干' || name == '地支')
          ? ganZhiCellSize.height
          : otherCellHeight;
      acc += h;
    }
    return acc;
  }

  // 计算目标行顶部位置（用于整行高亮覆盖）
  double _computeRowTopFromIndex(int index, List<String> rows) {
    // index 取值 [1..rows.length-1]；1 对应第一数据行，top=0
    double acc = 0.0;
    for (final entry in rows.asMap().entries) {
      final idx = entry.key;
      final name = entry.value;
      if (idx == 0) continue; // 跳过标题行
      if (idx == index) break;
      final h = (name == '天干' || name == '地支')
          ? ganZhiCellSize.height
          : otherCellHeight;
      acc += h;
    }
    return acc;
  }

  // 判断全局点是否在卡片容器内
  bool _isGlobalPointInsideCard(Offset global) {
    final ctx = _cardKey.currentContext;
    if (ctx == null) return true; // 默认为在内，避免误删
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return true;
    final origin = box.localToGlobal(Offset.zero);
    final size = box.size;
    final rect = Rect.fromLTWH(origin.dx, origin.dy, size.width, size.height);
    return rect.contains(global);
  }

  // 删除列
  void _deleteColumn(int index) {
    final list = List<Tuple2<String, JiaZi>>.of(widget.jiaZiNotifier.value);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    widget.jiaZiNotifier.value = list;
  }

  // 删除行（跳过标题行，索引>=1）
  void _deleteRow(int absIndex) {
    final rows = List<String>.of(widget.rowListNotifier.value);
    if (absIndex <= 0 || absIndex >= rows.length) return;
    rows.removeAt(absIndex);
    widget.rowListNotifier.value = rows;
  }

  // 已移除：卡片右上角删除提示徽标；仅保留拖拽物上的动态徽标

  // Default feedback wrapper used when no custom decorator provided
  Widget _defaultFeedback(Widget child) {
    return Material(
      color: Colors.transparent,
      elevation: 8,
      child: Transform.scale(
        scale: 1.02,
        child: child,
      ),
    );
  }

  // Status-aware feedback: overlay dynamic "插入" / "删除" prompts on the dragged piece itself
  Widget _statusFeedback(Widget child) {
    return Material(
      color: Colors.transparent,
      elevation: 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.scale(scale: 1.02, child: child),
          Positioned(
            right: 6,
            top: 4,
            child: ValueListenableBuilder<bool>(
              valueListenable: _dragWantsDelete,
              builder: (context, wantsDelete, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _dragWantsInsert,
                  builder: (context, wantsInsert, __) {
                    // Priority: 删除 > 插入；都为 false 时不显示
                    if (wantsDelete) {
                      return _statusBadge(
                        context,
                        text: '删除',
                        color: Theme.of(context).colorScheme.error,
                        bgOpacity: 0.12,
                      );
                    } else if (wantsInsert) {
                      return _statusBadge(
                        context,
                        text: '插入',
                        color: Theme.of(context).colorScheme.primary,
                        bgOpacity: 0.12,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context,
      {required String text, required Color color, double bgOpacity = 0.12}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(bgOpacity),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // --- Debug painters ---
  // Visualize column mid boundaries (k + 0.5) and hysteresis margins
  // Boundaries are measured from start of the first column content (after rowTitle)
  // We draw vertical lines at x = rowTitleWidth + pillarWidth * (k + 0.5)
  // and margin lines at x +/- margin
  static const double _debugStroke = 1.0;
  static const double _debugMarginStroke = 0.5;
// Keep class open; painter classes are defined at file end.

  void _reorderColumns(int fromIdx, int insertIndex) {
    // Current columns length
    final list = widget.jiaZiNotifier.value;
    if (fromIdx < 0 || fromIdx >= list.length) return;
    // Insert index refers to gap positions: 0..length
    // If dragging forward, remove then insert at adjusted index
    final item = list.removeAt(fromIdx);
    var target = insertIndex;
    if (insertIndex > fromIdx) {
      target = insertIndex - 1; // account for removal shift
    }
    target = target.clamp(0, list.length);
    list.insert(target, item);
    widget.jiaZiNotifier.value = List<Tuple2<String, JiaZi>>.of(list);
    // 统一清理拖拽状态 + 触发插入淡入动画
    setState(() {
      _draggingColumnIndex = null;
      _hoverColumnInsertIndex = null;
      _lastColInsertIndex = null;
      _dropAnimatingColIndex = target;
      _dropColFadeActive = true;
    });
    // 下一帧开始淡入
    Future.microtask(() {
      if (!mounted) return;
      setState(() {
        _dropColFadeActive = false;
      });
    });
    // 动画结束后清理索引
    Future.delayed(const Duration(milliseconds: 240), () {
      if (!mounted) return;
      setState(() {
        _dropAnimatingColIndex = null;
      });
    });
  }

  void _reorderRows(int fromAbsIdx, int insertIndex) {
    // Rows include header row at index 0; we only allow reordering for indices >=1
    final rows = widget.rowListNotifier.value;
    if (fromAbsIdx <= 0 || fromAbsIdx >= rows.length) return;
    // Insert index in [1..rows.length]
    final item = rows.removeAt(fromAbsIdx);
    var target = insertIndex;
    if (insertIndex > fromAbsIdx) {
      target = insertIndex - 1;
    }
    target = target.clamp(1, rows.length);
    rows.insert(target, item);
    widget.rowListNotifier.value = List<String>.of(rows);
    // 统一清理拖拽状态 + 触发插入淡入动画
    setState(() {
      _draggingRowIndex = null;
      _hoverRowInsertIndex = null;
      _lastRowInsertIndex = null;
      _dropAnimatingRowIndex = target;
      _dropRowFadeActive = true;
    });
    // 下一帧开始淡入
    Future.microtask(() {
      if (!mounted) return;
      setState(() {
        _dropRowFadeActive = false;
      });
    });
    // 动画结束后清理索引
    Future.delayed(const Duration(milliseconds: 240), () {
      if (!mounted) return;
      setState(() {
        _dropAnimatingRowIndex = null;
      });
    });
  }

  // --- UI helpers ---
  Size _rowCellSize(String rowName) {
    if (rowName == '天干' || rowName == '地支') return ganZhiCellSize;
    return Size(rowTitleWidth, otherCellHeight);
  }

  Widget _cell(Size size, Widget child) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        border: Border.all(color: Colors.black12, width: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(child: child),
    );
  }

  // Build full column feedback (title + all rows) for smoother whole-column drag perception
  Widget _buildFullColumnFeedback(String title, dynamic jz, List<String> rows) {
    // Compute total height: header + sum of each row height
    double totalHeight = columnTitleHeight;
    for (final rowName in rows.skip(1)) {
      if (rowName == '天干' || rowName == '地支') {
        totalHeight += ganZhiCellSize.height;
      } else {
        totalHeight += otherCellHeight;
      }
    }

    return Container(
      width: pillarWidth,
      height: totalHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cell(Size(pillarWidth, columnTitleHeight),
              _dragHandle(_columnTitleText(title))),
          ...rows.skip(1).map((rowName) {
            if (rowName == '天干') {
              return _cell(ganZhiCellSize, _tianGanText(jz.tianGan));
            } else if (rowName == '地支') {
              return _cell(ganZhiCellSize, _diZhiText(jz.diZhi));
            } else if (rowName == '纳音') {
              return _cell(
                  Size(pillarWidth, otherCellHeight), _naYinText(jz.naYinStr));
            } else {
              return _cell(
                  Size(pillarWidth, otherCellHeight), _columnTitleText(title));
            }
          }).toList(),
        ],
      ),
    );
  }

  // 计算行位移：严格整步，让位区间内的每项平移一个完整高度
  double _computeRowShift(int absRowIdx, int total) {
    final d = _draggingRowIndex;
    final t = _hoverRowInsertIndex ?? _lastRowInsertIndex;
    if (d == null || t == null) return 0.0;
    if (t > d) {
      // 向下拖拽：区间 [d+1 .. t] 每项向后（下）平移一个单位
      if (absRowIdx > d && absRowIdx <= t) return 1.0;
    } else if (t < d) {
      // 向上拖拽：区间 [t .. d-1] 每项向后（上）平移一个单位（索引减小方向）
      if (absRowIdx >= t && absRowIdx < d) return -1.0;
    }
    return 0.0;
  }

  // 根据左侧标题区域内的局部 y 坐标计算插入索引（范围 [1..rows.length]）
  int _computeRowInsertIndexFromDy(double dy, List<String> rows) {
    // 逐行累计高度，首行（索引0）为标题行，不参与重排
    double acc = 0.0;
    int insertIndex = 1; // 最小为 1
    for (final entry in rows.asMap().entries) {
      final idx = entry.key;
      final name = entry.value;
      if (idx == 0) continue;
      final h = (name == '天干' || name == '地支')
          ? ganZhiCellSize.height
          : otherCellHeight;
      final nextAcc = acc + h;
      if (dy < nextAcc) {
        // 落在当前行内部，插入索引为当前行索引
        insertIndex = idx;
        break;
      }
      acc = nextAcc;
      insertIndex = idx + 1; // 超过当前行底部，插入到其后
    }
    // 夹住到合法范围
    insertIndex = insertIndex.clamp(1, rows.length);
    return insertIndex;
  }

  // 根据局部 y 计算“分数插入位置”，用于行的连续让位插值（范围 [1..rows.length]）
  double _computeRowInsertFloatFromDy(double dy, List<String> rows) {
    double acc = 0.0;
    double floatPos = 1.0; // 最小为 1.0
    for (final entry in rows.asMap().entries) {
      final idx = entry.key;
      final name = entry.value;
      if (idx == 0) continue; // 跳过标题行
      final h = (name == '天干' || name == '地支')
          ? ganZhiCellSize.height
          : otherCellHeight;
      final nextAcc = acc + h;
      if (dy < nextAcc) {
        // 落在当前行内部：idx + 局部比例
        final frac = ((dy - acc) / h).clamp(0.0, 1.0);
        floatPos = idx + frac;
        break;
      }
      acc = nextAcc;
      floatPos = idx + 1.0; // 超过当前行底部：定位到其后一个插入位
    }
    // 夹住到合法范围
    floatPos = floatPos.clamp(1.0, rows.length.toDouble());
    return floatPos;
  }

  // Midpoint-based insert index from local dy for rows (gap in [1..rows.length])
  int _computeRowInsertIndexFromDyMidpoint(double dy, List<String> rows) {
    double acc = 0.0;
    int insertIndex = 1; // 最小为 1
    for (final entry in rows.asMap().entries) {
      final idx = entry.key;
      final name = entry.value;
      if (idx == 0) continue; // 跳过标题行
      final h = (name == '天干' || name == '地支')
          ? ganZhiCellSize.height
          : otherCellHeight;
      final mid = acc + h / 2;
      if (dy < mid) {
        insertIndex = idx; // 中点以上：插入到该行之前
        break;
      }
      acc += h;
      insertIndex = idx + 1; // 中点以下：插入到该行之后
    }
    return insertIndex.clamp(1, rows.length);
  }

  // 返回行索引 `idx` 的中点 Y（局部坐标），用于滞回判断
  // 索引范围为数据行索引（>=1），标题行 0 被跳过
  double _rowBoundaryMidY(int idx, List<String> rows) {
    double acc = 0.0;
    for (final entry in rows.asMap().entries) {
      final i = entry.key;
      final name = entry.value;
      if (i == 0) continue;
      final h = (name == '天干' || name == '地支')
          ? ganZhiCellSize.height
          : otherCellHeight;
      if (i == idx) {
        return acc + h / 2.0;
      }
      acc += h;
    }
    return acc; // fallback 到底部中点之外，理论上不应命中
  }

  // Build full row feedback (row title + cells across all columns)
  Widget _buildFullRowFeedback(
      String rowName, List<Tuple2<String, JiaZi>> pillars) {
    final isGan = rowName == '天干';
    final isZhi = rowName == '地支';
    final rowH = isGan || isZhi ? ganZhiCellSize.height : otherCellHeight;
    final totalW = rowTitleWidth + pillarWidth * pillars.length;

    return Container(
      width: totalW,
      height: rowH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cell(Size(rowTitleWidth, rowH), _dragHandle(_rowTitleText(rowName))),
          ...pillars.map((tuple) {
            final jz = tuple.item2;
            if (isGan) {
              return _cell(Size(pillarWidth, rowH), _tianGanText(jz.tianGan));
            } else if (isZhi) {
              return _cell(Size(pillarWidth, rowH), _diZhiText(jz.diZhi));
            } else if (rowName == '纳音') {
              return _cell(Size(pillarWidth, rowH), _naYinText(jz.naYinStr));
            } else {
              return _cell(
                  Size(pillarWidth, rowH), _columnTitleText(tuple.item1));
            }
          }).toList(),
        ],
      ),
    );
  }

  Widget _dragHandle(Widget title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(child: title),
      ],
    );
  }

  Text _genderText(Gender gender) => Text(
        gender == Gender.male ? '乾造' : '坤造',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );

  Text _rowTitleText(String s) => Text(
        s,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );

  Text _columnTitleText(String s) => Text(
        s,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );

  Text _tianGanText(TianGan t) => Text(
        t.name,
        style: const TextStyle(fontSize: 24, color: Colors.black87),
      );

  Text _diZhiText(DiZhi d) => Text(
        d.name,
        style: const TextStyle(fontSize: 24, color: Colors.black87),
      );

  Text _naYinText(String s) => const Text(
        '',
        // Placeholder; replace with actual NaYin display when available
        style: TextStyle(fontSize: 14, color: Colors.amber),
      );
}

// --- Debug Painters (defined outside of State class) ---
// Visualize column midpoint boundaries and hysteresis margins
class _ColumnHysteresisPainter extends CustomPainter {
  final int columns;
  final double rowTitleWidth;
  final double pillarWidth;
  final double margin;
  final Color color;

  const _ColumnHysteresisPainter({
    required this.columns,
    required this.rowTitleWidth,
    required this.pillarWidth,
    required this.margin,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midPaint = Paint()
      ..color = color
      ..strokeWidth = _EditableFourZhuCardV3State._debugStroke
      ..style = PaintingStyle.stroke;
    final marginPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = _EditableFourZhuCardV3State._debugMarginStroke
      ..style = PaintingStyle.stroke;

    for (int k = 0; k < columns; k++) {
      final midX = rowTitleWidth + pillarWidth * (k + 0.5);
      // Mid line
      canvas.drawLine(Offset(midX, 0), Offset(midX, size.height), midPaint);
      // Margin lines
      canvas.drawLine(
        Offset(midX - margin, 0),
        Offset(midX - margin, size.height),
        marginPaint,
      );
      canvas.drawLine(
        Offset(midX + margin, 0),
        Offset(midX + margin, size.height),
        marginPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ColumnHysteresisPainter oldDelegate) {
    return columns != oldDelegate.columns ||
        rowTitleWidth != oldDelegate.rowTitleWidth ||
        pillarWidth != oldDelegate.pillarWidth ||
        margin != oldDelegate.margin ||
        color != oldDelegate.color;
  }
}

// Visualize row midpoint boundaries and hysteresis margins
class _RowHysteresisPainter extends CustomPainter {
  final List<double> midYs; // authoritative midpoints for data rows (>=1)
  final double rowTitleWidth;
  final double marginPx; // hysteresis margin in pixels
  final Color color;

  const _RowHysteresisPainter({
    required this.midYs,
    required this.rowTitleWidth,
    required this.marginPx,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midPaint = Paint()
      ..color = color
      ..strokeWidth = _EditableFourZhuCardV3State._debugStroke
      ..style = PaintingStyle.stroke;
    final marginPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = _EditableFourZhuCardV3State._debugMarginStroke
      ..style = PaintingStyle.stroke;

    for (final midY in midYs) {
      // Mid line across the left header width
      canvas.drawLine(Offset(0, midY), Offset(rowTitleWidth, midY), midPaint);
      // Margin lines above and below midpoint
      canvas.drawLine(Offset(0, midY - marginPx),
          Offset(rowTitleWidth, midY - marginPx), marginPaint);
      canvas.drawLine(Offset(0, midY + marginPx),
          Offset(rowTitleWidth, midY + marginPx), marginPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RowHysteresisPainter oldDelegate) {
    return midYs != oldDelegate.midYs ||
        rowTitleWidth != oldDelegate.rowTitleWidth ||
        marginPx != oldDelegate.marginPx ||
        color != oldDelegate.color;
  }
}
