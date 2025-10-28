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

  const EditableFourZhuCardV3({
    super.key,
    required this.jiaZiNotifier,
    required this.rowListNotifier,
    required this.paddingNotifier,
    required this.gender,
  });

  @override
  State<EditableFourZhuCardV3> createState() => _EditableFourZhuCardV3State();
}

enum _DragKind { row, column }

class _EditableFourZhuCardV3State extends State<EditableFourZhuCardV3> {
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
  int? _draggingRowIndex; // absolute row index (skip header row 0)
  int? _hoverRowInsertIndex; // between 1..rows.len (skip header at 0)
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _cell(Size(rowTitleWidth, columnTitleHeight),
                  _genderText(widget.gender)),
              ...pillars.asMap().entries.map((entry) {
                final colIdx = entry.key;
                final title = entry.value.item1;
                final childCell = _cell(Size(pillarWidth, columnTitleHeight),
                    _dragHandle(_columnTitleText(title)));
                // 当正在拖拽该列时，将其在原布局中收缩为 0 宽度，以避免空白插槽
                final childWhenDragging = const SizedBox(width: 0, height: 0);
                return AnimatedSlide(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                  offset:
                      Offset(_computeColumnShift(colIdx, pillars.length), 0),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.fastOutSlowIn,
                    child: SizedBox(
                      width: _draggingColumnIndex == colIdx ? 0 : pillarWidth,
                      height: columnTitleHeight,
                      child: Draggable<Tuple2<_DragKind, int>>(
                        data: Tuple2(_DragKind.column, colIdx),
                        onDragStarted: () =>
                            setState(() => _draggingColumnIndex = colIdx),
                        onDragEnd: (_) => setState(() {
                          _draggingColumnIndex = null;
                          _hoverColumnInsertIndex = null;
                        }),
                        dragAnchorStrategy: pointerDragAnchorStrategy,
                        feedback: Material(
                          color: Colors.transparent,
                          elevation: 8,
                          child: Transform.scale(
                            scale: 1.02,
                            child: _buildFullColumnFeedback(
                                title, entry.value.item2, rows),
                          ),
                        ),
                        childWhenDragging: childWhenDragging,
                        child: childCell,
                      ),
                    ),
                  ),
                );
              }).toList(),
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
                // Midpoint-based insert index
                final target = _computeColumnInsertIndexFromDx(dx, n);
                setState(() {
                  _hoverColumnInsertIndex = target;
                  _lastColInsertIndex = target;
                });
              },
              onLeave: (_) => setState(() {
                _hoverColumnInsertIndex = null;
                _lastColInsertIndex = null;
              }),
              onAccept: (payload) {
                final insertIndex = _hoverColumnInsertIndex ?? 0;
                setState(() {
                  _hoverColumnInsertIndex = null;
                  _lastColInsertIndex = null;
                });
                _reorderColumns(payload.item2, insertIndex);
              },
              builder: (context, _, __) => const SizedBox.expand(),
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
        ],
      ),
    );

    // Left header column: row titles; overlay a unified drag target for continuous row index updates
    final leftHeader = SizedBox(
      width: rowTitleWidth,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...rows.asMap().entries.skip(1).map((entry) {
                final absRowIdx = entry.key; // >=1
                final rowName = entry.value;
                final cell = _cell(
                  _rowCellSize(rowName),
                  _dragHandle(_rowTitleText(rowName)),
                );
                return AnimatedSlide(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                  offset: Offset(0, _computeRowShift(absRowIdx, rows.length)),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.fastOutSlowIn,
                    child: SizedBox(
                      height: _draggingRowIndex == absRowIdx
                          ? 0
                          : _rowCellSize(rowName).height,
                      child: Draggable<Tuple2<_DragKind, int>>(
                        data: Tuple2(_DragKind.row, absRowIdx),
                        onDragStarted: () =>
                            setState(() => _draggingRowIndex = absRowIdx),
                        onDragEnd: (_) => setState(() {
                          _draggingRowIndex = null;
                          _hoverRowInsertIndex = null;
                        }),
                        dragAnchorStrategy: pointerDragAnchorStrategy,
                        feedback: Material(
                          color: Colors.transparent,
                          elevation: 8,
                          child: Transform.scale(
                            scale: 1.02,
                            child: _buildFullRowFeedback(rowName, pillars),
                          ),
                        ),
                        childWhenDragging: const SizedBox(width: 0, height: 0),
                        child: cell,
                      ),
                    ),
                  ),
                );
              }).toList(),
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
                // Midpoint-based insert index
                final target = _computeRowInsertIndexFromDyMidpoint(dy, rows);
                setState(() {
                  _hoverRowInsertIndex = target;
                  _lastRowInsertIndex = target;
                });
              },
              onLeave: (_) => setState(() {
                _hoverRowInsertIndex = null;
                _lastRowInsertIndex = null;
              }),
              onAccept: (payload) {
                final insertIndex = _hoverRowInsertIndex ?? 1;
                setState(() {
                  _hoverRowInsertIndex = null;
                  _lastRowInsertIndex = null;
                });
                _reorderRows(payload.item2, insertIndex);
              },
              builder: (context, _, __) => const SizedBox.expand(),
            ),
          ),
          // 插入位指示条：在当前 hover 的行插入索引位置绘制横线，增强可视反馈
          if (_hoverRowInsertIndex != null)
            Positioned(
              left: 0,
              top: _computeRowInsertTopFromIndex(_hoverRowInsertIndex!, rows) -
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: pillars.asMap().entries.map((entry) {
          final colIdx = entry.key;
          final tuple = entry.value;
          final jz = tuple.item2;
          // For each column, build vertical stack per row order, and dim when dragging this column
          final columnContent = Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...rows.asMap().entries.skip(1).map((rEntry) {
                final absRowIdx = rEntry.key;
                final rowName = rEntry.value;
                Widget cell;
                if (rowName == '天干') {
                  cell = _cell(ganZhiCellSize, _tianGanText(jz.tianGan));
                } else if (rowName == '地支') {
                  cell = _cell(ganZhiCellSize, _diZhiText(jz.diZhi));
                } else if (rowName == '纳音') {
                  cell = _cell(Size(pillarWidth, otherCellHeight),
                      _naYinText(jz.naYinStr));
                } else {
                  // Fallback: show title text cell
                  cell = _cell(Size(pillarWidth, otherCellHeight),
                      _columnTitleText(tuple.item1));
                }
                return AnimatedSlide(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                  offset: Offset(0, _computeRowShift(absRowIdx, rows.length)),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.fastOutSlowIn,
                    child: _draggingRowIndex == absRowIdx
                        ? const SizedBox.shrink()
                        : AnimatedOpacity(
                            duration: const Duration(milliseconds: 120),
                            opacity: _draggingRowIndex == absRowIdx ? 0.4 : 1.0,
                            child: cell,
                          ),
                  ),
                );
              }).toList(),
            ],
          );
          return AnimatedSlide(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            offset: Offset(_computeColumnShift(colIdx, pillars.length), 0),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.fastOutSlowIn,
              child: SizedBox(
                width: _draggingColumnIndex == colIdx ? 0 : pillarWidth,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: _draggingColumnIndex == colIdx ? 0.4 : 1.0,
                  child: columnContent,
                ),
              ),
            ),
          );
        }).toList(),
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
          width: isHover ? pillarWidth : 12, // 保持最小命中宽度
          height: columnTitleHeight, // 高度保持与标题一致
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: isHover
                ? Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.25),
                    width: 1.5,
                  )
                : Border.all(color: Colors.transparent, width: 0),
          ),
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
          width: rowTitleWidth,
          height: isHover ? otherCellHeight : 12, // 保持最小命中高度
          decoration: BoxDecoration(
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
          ),
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
