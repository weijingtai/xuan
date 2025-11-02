import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'dart:ui' as ui;

import '../../enums.dart';
import '../../enums/enum_di_zhi.dart';
import '../../enums/enum_tian_gan.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/drag_payloads.dart';
import '../../models/pillar_content.dart';
import '../../models/row_strategy.dart';
import 'dimension_models.dart'; // 新增：尺寸管理模型

/// EditableFourZhuCardV3
/// 单视图、双轴拖拽：在同一个网格视图中完成行与列的重排，不再依赖两个 ReorderableListView。
class EditableFourZhuCardV3 extends StatefulWidget {
  final ValueNotifier<List<PillarPayload>> pillarsNotifier;
  final ValueNotifier<List<RowInfoPayload>> rowListNotifier;
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
    required this.pillarsNotifier,
    required this.rowListNotifier,
    required this.paddingNotifier,
    required this.gender,
    this.dragFeedbackBuilder,
    this.columnInsertDecorationBuilder,
    this.rowInsertDecorationBuilder,
    this.debugHysteresisOverlay = true,
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
  // 独立抓手行/列的尺寸
  double dragHandleRowHeight = 20;
  double dragHandleColWidth = 20;
  double dividerRowHeight = 8; // 旧的默认分割线高度（不再直接使用）
  // 分割线参数：按“padding + thickness”动态计算尺寸
  double _rowDividerPaddingTop = 4.0;
  double _rowDividerPaddingBottom = 4.0;
  double _rowDividerThickness = 0.8;
  double _colDividerPaddingLeft = 4.0;
  double _colDividerPaddingRight = 4.0;
  double _colDividerThickness = 1.6;

  double get _rowDividerHeightEffective =>
      _rowDividerPaddingTop + _rowDividerPaddingBottom + _rowDividerThickness;
  double get _colDividerWidthEffective =>
      _colDividerPaddingLeft + _colDividerPaddingRight + _colDividerThickness;

  // --- Column width helpers (support narrow separator columns) ---
  bool _isSeparatorTitle(String title) =>
      title == '分隔符' || title == '列分隔符' || title == '|';

  /// 判断指定列索引是否为“分隔符列”。
  ///
  /// 优先依据列的 `PillarPayload.pillarType == PillarType.separator` 识别，
  /// 兼容旧逻辑：在缺少载荷时退回到标题别名（如“分隔符/列分隔符/|”）。
  bool _isSeparatorColumnIndex(int i) {
    final payloads = widget.pillarsNotifier.value;
    if (i >= 0 && i < payloads.length) {
      final p = payloads[i];
      if (p.pillarType == PillarType.separator) return true;
      final title = _pillarLabelFromPayload(p);
      return _isSeparatorTitle(title);
    }
    return false;
  }

  /// 判断给定的行标签是否为“分隔行”。
  ///
  /// 统一分隔行标签的别名识别，避免由于不同别名导致高度计算与渲染不一致。
  /// 参数：
  /// - name: 行标签文本。
  /// 返回值：
  /// - 当标签属于分隔行（如“分割线/行分割线/行分割符/行分隔符”）时返回 true，否则返回 false。
  bool _isSeparatorRowLabel(String name) =>
      name == '分割线' || name == '行分割线' || name == '行分割符' || name == '行分隔符';

  // 显式列宽/行高覆盖映射：键为当前索引，值为覆盖尺寸
  final Map<int, double> _columnWidthOverrides = {};
  final Map<int, double> _rowHeightOverrides = {};

  // ==================== 新尺寸管理系统（并行运行，不影响旧代码） ====================
  // 新模型层：集中管理所有尺寸计算，自动处理索引重映射
  late ValueNotifier<CardLayoutModel> _layoutNotifier;
  late MeasurementContext _measurementContext;
  late VoidCallback _layoutModelSyncListener; // 用于同步旧数据到新模型
  bool _layoutSystemInitialized = false; // 标记新系统是否已初始化
  // ==================== 新尺寸管理系统结束 ====================

  // --- Mapping helpers from payloads to UI tuples/labels ---
  String _pillarLabelFromPayload(PillarPayload p) {
    return p.pillarContent?.label ?? p.pillarLabel ?? p.pillarType.name;
  }

  JiaZi _pillarJiaZiFromPayload(PillarPayload p) {
    final j = p.pillarContent?.jiaZi;
    if (j != null) return j;
    final tgStr = p.perRowValues[RowType.heavenlyStem];
    final dzStr = p.perRowValues[RowType.earthlyBranch];
    if (tgStr != null && dzStr != null) {
      final tg = TianGan.getFromValue(tgStr);
      final dz = DiZhi.getFromValue(dzStr);
      if (tg != null && dz != null) {
        return JiaZi.getFromGanZhiEnum(tg, dz);
      }
    }
    return JiaZi.getByNumber(1);
  }

  List<Tuple2<String, JiaZi>> _effectivePillarsTuples() {
    final payloads = widget.pillarsNotifier.value;
    return payloads
        .map((p) =>
            Tuple2(_pillarLabelFromPayload(p), _pillarJiaZiFromPayload(p)))
        .toList();
  }

  /// 为新插入的柱分配唯一 `id`，格式：`<type>#<序号>`，例如：`year#1`、`luckCycle#2`。
  /// 通过当前已存在的同类型柱数量确定下一个序号，确保在当前卡片内唯一。
  String _allocatePillarId(PillarType type) {
    final existingCount = widget.pillarsNotifier.value
        .map((p) => p.pillarContent?.id)
        .whereType<String>()
        .where((id) => id.startsWith('${type.name}#'))
        .length;
    final nextIndex = existingCount + 1;
    return '${type.name}#$nextIndex';
  }

  List<String> _currentRowLabels() {
    final rows = widget.rowListNotifier.value;
    return rows.map((r) => r.rowLabel ?? r.rowType.name).toList();
  }

  double _colWidthAtIndex(int i, List<Tuple2<String, JiaZi>> pillars) {
    final payloads = widget.pillarsNotifier.value;
    if (i >= 0 && i < payloads.length) {
      final p = payloads[i];
      // 特殊处理：行标题列
      if (p.pillarType == PillarType.rowTitleColumn) {
        final override = _columnWidthOverrides[i];
        if (override != null && override.isFinite && !override.isNaN) {
          return override.clamp(_minPillarWidth, _maxPillarWidth);
        }
        return p.columnWidth ?? rowTitleWidth;
      }
    }

    // 分隔列：统一使用分隔列的有效窄宽度
    if (_isSeparatorColumnIndex(i)) return _colDividerWidthEffective;
    final title = pillars[i].item1;
    final override = _columnWidthOverrides[i];
    if (override != null && override.isFinite && !override.isNaN) {
      return override.clamp(_minPillarWidth, _maxPillarWidth);
    }
    // 当未设置显式覆盖时，优先依据对应列的载荷信息解析列宽
    // 以保证宽度来源统一由 payload 控制（如拖入外部列或预设列宽）。
    if (i >= 0 && i < payloads.length) {
      final p = payloads[i];
      return p.resolveWidth(
        defaultWidth: pillarWidth,
        minWidth: _minPillarWidth,
        maxWidth: _maxPillarWidth,
      );
    }
    return pillarWidth;
  }

  double _sumColWidthsUpTo(int idx, List<Tuple2<String, JiaZi>> pillars) {
    double acc = 0.0;
    for (int i = 0; i < idx; i++) {
      acc += _colWidthAtIndex(i, pillars);
    }
    return acc;
  }

  double _totalColsWidth(List<Tuple2<String, JiaZi>> pillars) {
    double acc = 0.0;
    for (int i = 0; i < pillars.length; i++) {
      acc += _colWidthAtIndex(i, pillars);
    }
    return acc;
  }

  /// 列宽度拖拽的最小/最大范围（统一列宽策略）
  final double _minPillarWidth = 40.0;
  final double _maxPillarWidth = 160.0;

  /// 当前正在拖拽的垂直分割线索引（1..columns-1），用于计算列宽
  int? _resizingDividerIndex;

  /// 拖拽开始时的初始列宽，便于必要时实现相对调整（目前直接按定位计算）
  double? _initialPillarWidth;

  Size get ganZhiCellSize => Size(pillarWidth, 48);

  // Size sync
  late final ValueNotifier<Size> _sizeNotifier;
  late final VoidCallback _pillarsListener;
  late final VoidCallback _rowsListener;
  late final VoidCallback _paddingListener;

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

  // External hover flags to expand card size during drag-over (better UX)
  bool _hoveringExternalPillar = false;
  bool _hoveringExternalRow = false;
  double _externalRowHoverHeight = 0.0;
  double _externalColHoverWidth = 0.0;

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

  // 依据外部行载荷推断行高：优先使用 rowType，其次使用 rowLabel
  double _rowHeightByPayload(RowInfoPayload payload) {
    // 使用模型的统一解析方法，确保行为与外部载荷约定一致
    return payload.resolveHeight(
      heavenlyAndEarthlyHeight: ganZhiCellSize.height,
      otherHeight: otherCellHeight,
      dividerHeight: _rowDividerHeightEffective,
      headerHeight: columnTitleHeight, // 传递表头行高度
    );
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
    return target.clamp(0, maxIndex);
  }

  // Midpoint-based insert index from local dx for columns (gap in [0..n])
  int _computeColumnInsertIndexFromDx(double dx, int n) {
    // dx is measured from the start of the first column content (after row title)
    // Midpoint rule: index = floor(dx / pillarWidth + 0.5)
    final pos = (dx / pillarWidth);
    final idx = (pos + 0.5).floor();
    return idx.clamp(0, n);
  }

  // Variable width version: use accumulated widths and per-column midpoints
  int _computeColumnInsertIndexFromDxVariable(
      double dx, List<Tuple2<String, JiaZi>> pillars) {
    double acc = 0.0;
    for (int i = 0; i < pillars.length; i++) {
      final w = _colWidthAtIndex(i, pillars);
      final mid = acc + w / 2;
      if (dx < mid) return i;
      acc += w;
    }
    return pillars.length;
  }

  @override
  void initState() {
    super.initState();
    // ====== 旧尺寸管理系统（保持不变） ======
    _sizeNotifier = ValueNotifier<Size>(_computeSize());
    _pillarsListener = () => _sizeNotifier.value = _computeSize();
    _rowsListener = () => _sizeNotifier.value = _computeSize();
    _paddingListener = () => _sizeNotifier.value = _computeSize();
    widget.pillarsNotifier.addListener(_pillarsListener);
    widget.rowListNotifier.addListener(_rowsListener);
    widget.paddingNotifier.addListener(_paddingListener);

    // ====== 新尺寸管理系统（并行运行） ======
    // 初始化测量上下文
    _measurementContext = MeasurementContext.fromStateConfig(
      pillarWidth: pillarWidth,
      otherCellHeight: otherCellHeight,
      ganZhiHeight: ganZhiCellSize.height,
      columnTitleHeight: columnTitleHeight,
      rowDividerHeightEffective: _rowDividerHeightEffective,
      colDividerWidthEffective: _colDividerWidthEffective,
      rowTitleWidth: rowTitleWidth,
      minPillarWidth: _minPillarWidth,
      maxPillarWidth: _maxPillarWidth,
    );

    // 从旧数据构建新模型（保留现有覆盖值）
    _layoutNotifier = ValueNotifier(
      CardLayoutModel.fromNotifiers(
        pillars: widget.pillarsNotifier.value,
        rows: widget.rowListNotifier.value,
        padding: widget.paddingNotifier.value,
        columnWidthOverrides: _columnWidthOverrides,
        rowHeightOverrides: _rowHeightOverrides,
        dragHandleRowHeight: dragHandleRowHeight,
        dragHandleColWidth: dragHandleColWidth,
      ),
    );

    // 监听旧数据变化，同步更新新模型
    _layoutModelSyncListener = () {
      _layoutNotifier.value = CardLayoutModel.fromNotifiers(
        pillars: widget.pillarsNotifier.value,
        rows: widget.rowListNotifier.value,
        padding: widget.paddingNotifier.value,
        columnWidthOverrides: _columnWidthOverrides,
        rowHeightOverrides: _rowHeightOverrides,
        dragHandleRowHeight: dragHandleRowHeight,
        dragHandleColWidth: dragHandleColWidth,
      );
    };
    widget.pillarsNotifier.addListener(_layoutModelSyncListener);
    widget.rowListNotifier.addListener(_layoutModelSyncListener);
    widget.paddingNotifier.addListener(_layoutModelSyncListener);

    // 标记新系统已初始化
    _layoutSystemInitialized = true;
  }

  @override
  void dispose() {
    // ====== 旧系统清理 ======
    widget.pillarsNotifier.removeListener(_pillarsListener);
    widget.rowListNotifier.removeListener(_rowsListener);
    widget.paddingNotifier.removeListener(_paddingListener);
    _sizeNotifier.dispose();
    _dragWantsInsert.dispose();
    _dragWantsDelete.dispose();

    // ====== 新系统清理 ======
    widget.pillarsNotifier.removeListener(_layoutModelSyncListener);
    widget.rowListNotifier.removeListener(_layoutModelSyncListener);
    widget.paddingNotifier.removeListener(_layoutModelSyncListener);
    _layoutNotifier.dispose();

    super.dispose();
  }

  Size _computeSize() {
    final pillars = _effectivePillarsTuples();
    final rows = _currentRowLabels();
    final padding = widget.paddingNotifier.value;

    // 使用可变列宽的总和，确保分割柱按有效宽度计入卡片总宽
    // 加上左右 padding
    final width =
        rowTitleWidth + _totalColsWidth(pillars) + padding.left + padding.right;

    // 检查 rows[0] 是否为表头行
    final rowPayloads = widget.rowListNotifier.value;
    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
        rowPayloads[0].rowType == RowType.columnHeaderRow;

    // 计算高度
    double height = padding.top + padding.bottom;

    // 如果 rows[0] 是表头行，添加固定的 columnTitleHeight
    if (isRows0HeaderRow) {
      height += columnTitleHeight;
    }

    for (final entry in rows.asMap().entries) {
      final idx = entry.key;
      final name = entry.value;
      // 只有当 rows[0] 是表头行时才跳过它（已计入 columnTitleHeight）
      if (idx == 0 && isRows0HeaderRow) continue;
      final override = _rowHeightOverrides[idx];
      height += override ?? _rowHeightByName(name);
    }

    // 添加独立抓手行的高度，确保Card尺寸计算的一致性
    height += dragHandleRowHeight;

    final oldSize = Size(width, height);

    // ====== 新旧系统一致性验证（开发阶段） ======
    // 只有在新系统已初始化后才进行验证
    if (_layoutSystemInitialized) {
      // 使用新模型系统计算尺寸，并对比是否与旧系统一致
      final newSize = _layoutNotifier.value.computeSize(_measurementContext);

      // 允许 0.1 像素的浮点误差
      const tolerance = 0.1;
      final widthDiff = (oldSize.width - newSize.width).abs();
      final heightDiff = (oldSize.height - newSize.height).abs();

      assert(
        widthDiff < tolerance && heightDiff < tolerance,
        '⚠️ 新旧尺寸系统计算不一致！\n'
        '旧系统: ${oldSize.width.toStringAsFixed(2)} x ${oldSize.height.toStringAsFixed(2)}\n'
        '新系统: ${newSize.width.toStringAsFixed(2)} x ${newSize.height.toStringAsFixed(2)}\n'
        '差值: Δwidth=${widthDiff.toStringAsFixed(2)}, Δheight=${heightDiff.toStringAsFixed(2)}',
      );

      // 开发阶段输出对比信息（可选）
      if (widthDiff > 0.01 || heightDiff > 0.01) {
        debugPrint('📐 尺寸微小差异: Δwidth=$widthDiff, Δheight=$heightDiff');
      }
    }

    return oldSize;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Size>(
      valueListenable: _sizeNotifier,
      builder: (context, size, child) {
        // Expand card size dynamically only when hovering an external pillar/row
        final pillars = _effectivePillarsTuples();
        final rows = _currentRowLabels();
        // 列宽扩展策略：当外部柱悬停 或 当前插入索引位于末尾时扩展一列宽度
        final int? tCol = _hoverColumnInsertIndex ?? _lastColInsertIndex;
        // 行拖拽进行中时，强制屏蔽幽灵列，避免视觉干扰
        final bool rowDraggingActive =
            _draggingRowIndex != null || _hoveringExternalRow;
        final bool hasColGhost = (_hoveringExternalPillar ||
                (tCol != null && tCol == pillars.length)) &&
            !rowDraggingActive;
        // 行幽灵判定：仅在“外部行载荷”悬停时扩展卡片高度；
        // 内部重排不会改变行数，不应增加额外高度，否则会造成错判为插入场景。
        final bool hasRowGhost = _hoveringExternalRow;
        // 卡片外部悬停时，幽灵列宽度优先使用外部载荷提供值；分割柱使用有效分割宽度
        final double ghostWidth = hasColGhost && _externalColHoverWidth > 0
            ? _externalColHoverWidth
            : pillarWidth;
        final double extraColWidth = hasColGhost ? ghostWidth : 0.0;
        double extraRowHeight = 0.0;
        if (hasRowGhost) {
          // 外部行拖拽：使用载荷解析的行高作为预留高度
          extraRowHeight = _externalRowHoverHeight;
        }
        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOutCubic,
              key: _cardKey,
              width: size.width + extraColWidth + dragHandleColWidth,
              height: size.height + extraRowHeight,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ValueListenableBuilder<EdgeInsets>(
                valueListenable: widget.paddingNotifier,
                builder: (context, padding, child) {
                  return Padding(
                    padding: padding,
                    child: _buildGrid(size),
                  );
                },
              ),
            ),
            // 全卡列插入 DragTarget：在卡片任意位置悬停时计算列插入索引
            Positioned.fill(
              child: DragTarget<Object>(
                onWillAccept: (data) {
                  final ok = (data is Tuple2 &&
                          data.item1 is _DragKind &&
                          data.item1 == _DragKind.column) ||
                      (data is PillarPayload) ||
                      (data is PillarType) ||
                      (data is TitleColumnPayload);
                  if (ok) {
                    setState(() {
                      if (data is PillarPayload || data is PillarType) {
                        _hoveringExternalPillar = true;
                      }
                      // 进入列插入目标时，清理行插入提示状态，避免相互干扰
                      _hoverRowInsertIndex = null;
                      _lastRowInsertIndex = null;
                      _hoveringExternalRow = false;
                      _externalRowHoverHeight = 0.0;
                    });
                  }
                  return ok;
                },
                onMove: (details) {
                  // 轻节流，避免过度重绘
                  final now = DateTime.now();
                  if (_lastColMoveAt != null &&
                      now.difference(_lastColMoveAt!).inMilliseconds < 12) {
                    return;
                  }
                  _lastColMoveAt = now;

                  final isExternal = details.data is PillarPayload ||
                      details.data is PillarType;
                  if (_hoveringExternalPillar != isExternal) {
                    setState(() => _hoveringExternalPillar = isExternal);
                  }

                  // 外部柱悬停：更新幽灵列宽度（若载荷提供 columnWidth 则优先使用）
                  if (isExternal) {
                    double nextW = pillarWidth;
                    final data = details.data;
                    if (data is PillarPayload) {
                      nextW = (data.pillarType == PillarType.separator)
                          ? _colDividerWidthEffective
                          : data.resolveWidth(
                              defaultWidth: pillarWidth,
                              minWidth: _minPillarWidth,
                              maxWidth: _maxPillarWidth,
                            );
                    } else if (data is PillarType) {
                      nextW = (data == PillarType.separator)
                          ? _colDividerWidthEffective
                          : pillarWidth;
                    }
                    if (_externalColHoverWidth != nextW) {
                      setState(() => _externalColHoverWidth = nextW);
                    }
                  }

                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  final local = box.globalToLocal(details.offset);
                  // 当存在行标题列时，行标题列已在数据网格中，不需要减去 rowTitleWidth
                  final hasRowTitleCol = widget.pillarsNotifier.value
                      .any((p) => p.pillarType == PillarType.rowTitleColumn);
                  final dx = local.dx - (hasRowTitleCol ? 0 : rowTitleWidth);
                  final n = pillars.length;
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
                  if (candidate == last) return;

                  final margin = pillarWidth * _colHysteresisFrac;
                  final rightBoundary = (last + 0.5) * pillarWidth;
                  final leftBoundary = (last - 0.5) * pillarWidth;
                  bool allowUpdate = false;
                  if (candidate > last) {
                    allowUpdate = dx > rightBoundary + margin;
                  } else {
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
                    _hoveringExternalPillar = false;
                    _externalColHoverWidth = 0.0;
                  });
                  _dragWantsInsert.value = false;
                  _dragWantsDelete.value = true;
                },
                onAccept: (payload) {
                  final insertIndex = _hoverColumnInsertIndex ?? 0;
                  setState(() {
                    _hoverColumnInsertIndex = null;
                    _lastColInsertIndex = null;
                    _draggingColumnIndex = null;
                    _hoveringExternalPillar = false;
                    _externalColHoverWidth = 0.0;
                  });
                  if (payload is Tuple2) {
                    final kind = payload.item1;
                    final fromIdx = payload.item2 as int;
                    if (kind == _DragKind.column) {
                      _reorderColumns(fromIdx, insertIndex);
                    }
                  } else if (payload is PillarPayload) {
                    _insertExternalPillar(insertIndex, payload);
                  } else if (payload is PillarType) {
                    _insertExternalPillarFromType(insertIndex, payload);
                  } else if (payload is TitleColumnPayload) {
                    _reorderColumnsByType(payload.pillarType, insertIndex);
                  }
                  _dragWantsInsert.value = false;
                  _dragWantsDelete.value = false;
                },
                builder: (context, _, __) => const SizedBox.expand(),
              ),
            ),
            // 删除高亮边框：当拖拽意图为删除时显示红色边框
            Positioned.fill(
              child: IgnorePointer(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _dragWantsDelete,
                  builder: (context, wantsDelete, _) {
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 80),
                      curve: Curves.easeOutCubic,
                      opacity: wantsDelete ? 1.0 : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // 插入位指示条（全卡覆盖）：在当前 hover 的插入索引位置绘制纵向细线，增强可视反馈
            if (_hoverColumnInsertIndex != null) ...[
              Builder(builder: (context) {
                // 使用可变列宽累计，正确定位插入指示线
                // 当存在行标题列时，不需要加上 rowTitleWidth（行标题列已在 pillars 中）
                final hasRowTitleCol = widget.pillarsNotifier.value
                    .any((p) => p.pillarType == PillarType.rowTitleColumn);
                final left = (hasRowTitleCol ? 0 : rowTitleWidth) +
                    _sumColWidthsUpTo(_hoverColumnInsertIndex!, pillars) -
                    1;
                return Positioned(
                  left: left,
                  top: 0,
                  width: 2,
                  height: size.height + extraRowHeight,
                  child: IgnorePointer(
                    ignoring: true,
                    child: SizedBox(
                      height: size.height + extraRowHeight,
                      width: 2,
                      child: VerticalDivider(
                        width: 2,
                        thickness: 2,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.45),
                      ),
                    ),
                  ),
                );
              }),
            ],
            // Debug overlay: 行边界辅助线（显示每一行的中点位置）
            if (widget.debugHysteresisOverlay)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Builder(builder: (context) {
                    // 计算所有行的中点Y坐标（包括表头行）
                    final rowPayloads = widget.rowListNotifier.value;
                    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
                        rowPayloads[0].rowType == RowType.columnHeaderRow;

                    final List<double> midYs = [];
                    double acc = 0.0;

                    // 如果 rows[0] 是表头行，添加表头行的中点
                    if (isRows0HeaderRow) {
                      midYs.add(acc + columnTitleHeight / 2);
                      acc += columnTitleHeight;
                    }

                    // 添加所有数据行的中点
                    for (int i = 0; i < rows.length; i++) {
                      if (i == 0 && isRows0HeaderRow) continue; // 已处理
                      final h = _rowHeightByName(rows[i]);
                      midYs.add(acc + h / 2);
                      acc += h;
                    }

                    return CustomPaint(
                      painter: _RowBoundaryPainter(
                        midYs: midYs,
                        cardWidth:
                            size.width + extraColWidth + dragHandleColWidth,
                        color: Colors.red.withOpacity(0.08),
                        hysteresisPx: _rowHysteresisPx,
                      ),
                    );
                  }),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGrid(Size size) {
    final pillars = _effectivePillarsTuples();
    final rows = _currentRowLabels();
    // 检查是否存在行标题列（在方法开头统一定义，避免重复）
    final hasRowTitleColumn = widget.pillarsNotifier.value
        .any((payload) => payload.pillarType == PillarType.rowTitleColumn);
    // 仅在外部柱悬停时，为插入位预留一列的宽度（内部重排不扩展卡片）
    // 行拖拽进行中时，强制屏蔽网格内的幽灵列
    final bool rowDraggingActive =
        _draggingRowIndex != null || _hoveringExternalRow;
    final bool hasColGhost = _hoveringExternalPillar && !rowDraggingActive;
    double ghostWidth = hasColGhost && _externalColHoverWidth > 0
        ? _externalColHoverWidth
        : pillarWidth;
    // 若内部拖拽且目标为末尾插入位，则在网格内的幽灵列使用被拖拽列的实际宽度
    final int? dCol = _draggingColumnIndex;
    final int? tCol = _hoverColumnInsertIndex ?? _lastColInsertIndex;
    if (!hasColGhost && dCol != null && tCol == pillars.length) {
      ghostWidth = _colWidthAtIndex(dCol, pillars);
    }
    final double extraColWidth = hasColGhost ? ghostWidth : 0.0;
    // 如果存在行标题列则不额外添加 rowTitleWidth（行标题列宽度已包含在 _totalColsWidth 中）
    final totalWidth = (hasRowTitleColumn ? 0 : rowTitleWidth) +
        _totalColsWidth(pillars) +
        extraColWidth;

    // Grip row: standalone handles for columns (no long-press required)
    final gripRow = SizedBox(
      width: dragHandleColWidth + totalWidth,
      height: dragHandleRowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 只在没有行标题列时渲染左侧空白单元格
          if (!hasRowTitleColumn)
            _cell(Size(rowTitleWidth, dragHandleRowHeight),
                const SizedBox.shrink()),
          ...List.generate(pillars.length, (i) {
            final bool isSeparatorCol = _isSeparatorColumnIndex(i);
            // 使用可变列宽，与 totalWidth 计算保持一致
            final double colW = _colWidthAtIndex(i, pillars);
            if (isSeparatorCol) {
              return SizedBox(
                width: colW,
                height: dragHandleRowHeight,
              );
            }
            final title = pillars[i].item1;
            return SizedBox(
              width: colW,
              height: dragHandleRowHeight,
              child: Center(
                child: Draggable<Tuple2<_DragKind, int>>(
                  data: Tuple2(_DragKind.column, i),
                  onDragStarted: () {
                    setState(() => _draggingColumnIndex = i);
                    _dragWantsInsert.value = false;
                    _dragWantsDelete.value = false;
                  },
                  onDraggableCanceled: (velocity, offset) {
                    final outside = !_isGlobalPointInsideCard(offset);
                    if (outside) {
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
                  onDragCompleted: () {
                    setState(() {
                      _draggingColumnIndex = null;
                      _hoverColumnInsertIndex = null;
                      _lastColInsertIndex = null;
                    });
                    _dragWantsInsert.value = false;
                    _dragWantsDelete.value = false;
                  },
                  dragAnchorStrategy: pointerDragAnchorStrategy,
                  feedback: _offsetFeedbackUp(
                    widget.dragFeedbackBuilder?.call(
                          context,
                          _buildFullColumnFeedback(
                              title, pillars[i].item2, rows,
                              widthOverride: _isSeparatorColumnIndex(i)
                                  ? null
                                  : _colWidthAtIndex(i, pillars)),
                        ) ??
                        _statusFeedback(
                          _buildFullColumnFeedback(
                              title, pillars[i].item2, rows,
                              widthOverride: _isSeparatorColumnIndex(i)
                                  ? null
                                  : _colWidthAtIndex(i, pillars)),
                        ),
                    // 以整列反馈高度向上偏移，使反馈位于光标上方
                    _columnFeedbackTotalHeight(rows),
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: const Icon(Icons.drag_indicator,
                        size: 14, color: Colors.black),
                  ),
                ),
              ),
            );
          }),
          // 为右侧的 gripColumn 预留空间
          SizedBox(
            width: dragHandleColWidth,
            height: dragHandleRowHeight,
          ),
        ],
      ),
    );

    // Header row: gender + column titles; overlay a unified drag target for continuous index updates
    // 动态检查 rows[0] 是否为表头行，只有当它是表头行时才渲染
    final rowPayloads = widget.rowListNotifier.value;
    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
        rowPayloads[0].rowType == RowType.columnHeaderRow;
    final isDraggingHeaderRow = _draggingRowIndex == 0;

    // 只有当 rows[0] 是表头行且没有被拖拽时，才渲染 headerRow
    final shouldRenderHeaderRow = isRows0HeaderRow && !isDraggingHeaderRow;

    final headerRow = SizedBox(
      width: dragHandleColWidth + totalWidth,
      height: shouldRenderHeaderRow ? columnTitleHeight : 0,
      child: !shouldRenderHeaderRow
          ? const SizedBox.shrink()
          : Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 检查是否存在行标题列
                    // 如果存在，则不在这里渲染（会在循环中处理）
                    // 如果不存在，则渲染硬编码的性别单元格
                    ...(() {
                      final payloads = widget.pillarsNotifier.value;
                      final hasRowTitleColumn = payloads.any((payload) =>
                          payload.pillarType == PillarType.rowTitleColumn);

                      if (!hasRowTitleColumn) {
                        // 旧逻辑：没有行标题列，显示硬编码的性别
                        // 检查表头行是否正在被拖拽
                        final d = _draggingRowIndex;
                        final isDraggingHeaderRow = d == 0;

                        if (isDraggingHeaderRow) {
                          // 表头行正在被拖拽，显示空占位（由幽灵占位处理）
                          return <Widget>[];
                        } else {
                          // 显示性别单元格（不可拖拽，拖拽由右侧抓手处理）
                          return [
                            _cell(Size(rowTitleWidth, columnTitleHeight),
                                Center(child: _genderText(widget.gender)))
                          ];
                        }
                      }
                      return <Widget>[]; // 存在行标题列，稍后在循环中处理
                    })(),
                    ...(() {
                      final d = _draggingColumnIndex;
                      final t = _hoverColumnInsertIndex ?? _lastColInsertIndex;
                      final List<Widget> children = [];
                      for (int i = 0; i < pillars.length; i++) {
                        // 在每个列前插入一个可动画的幽灵占位，宽度在 0..pillarWidth 之间动画
                        // 行拖拽进行中时，禁止显示列拖拽的幽灵占位
                        final bool dragging =
                            (d != null || _hoveringExternalPillar) &&
                                !rowDraggingActive;
                        // 内部拖拽时，列间幽灵占位宽度使用被拖拽列的实际宽度
                        final double headerGhostWidth = (d != null)
                            ? _colWidthAtIndex(d, pillars)
                            : ghostWidth;
                        children.add(AnimatedContainer(
                          duration: dragging
                              ? const Duration(milliseconds: 180)
                              : Duration.zero,
                          curve: Curves.easeOut,
                          width: dragging && t == i ? headerGhostWidth : 0,
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
                        final bool isSeparatorCol = _isSeparatorColumnIndex(i);
                        final payloads = widget.pillarsNotifier.value;
                        final isRowTitleCol = (i >= 0 && i < payloads.length) &&
                            payloads[i].pillarType == PillarType.rowTitleColumn;

                        final double colW = isRowTitleCol
                            ? _colWidthAtIndex(i, pillars) // 行标题列使用实际宽度
                            : (isSeparatorCol
                                ? _colDividerWidthEffective
                                : pillarWidth);

                        final Widget headerInner = isRowTitleCol
                            ? Center(child: _genderText(widget.gender))
                            : (isSeparatorCol
                                ? SizedBox(
                                    width: _colDividerWidthEffective,
                                    height: columnTitleHeight * 0.6,
                                    child: Center(
                                      child: Container(
                                        width: _colDividerThickness,
                                        height: columnTitleHeight * 0.6,
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                  )
                                : (() {
                                    // 列标题不再作为拖拽抓手，改为独立“列首抓手”
                                    final payloads =
                                        widget.pillarsNotifier.value;
                                    final type = (i >= 0 && i < payloads.length)
                                        ? payloads[i].pillarType
                                        : null;
                                    final titleWidget = _columnTitleText(title);
                                    // 专用抓手：立即拖拽（非长按），用于可靠的排序交互
                                    final grip = Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Draggable<Tuple2<_DragKind, int>>(
                                        data: Tuple2(_DragKind.column, i),
                                        onDragStarted: () {
                                          setState(() {
                                            _draggingColumnIndex = i;
                                            // 列拖拽开始，清理行插入状态
                                            _hoverRowInsertIndex = null;
                                            _lastRowInsertIndex = null;
                                            _hoveringExternalRow = false;
                                            _externalRowHoverHeight = 0.0;
                                          });
                                          _dragWantsInsert.value = false;
                                          _dragWantsDelete.value = false;
                                        },
                                        onDraggableCanceled:
                                            (velocity, offset) {
                                          final outside =
                                              !_isGlobalPointInsideCard(offset);
                                          if (outside) {
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
                                        onDragCompleted: () {
                                          setState(() {
                                            _draggingColumnIndex = null;
                                            _hoverColumnInsertIndex = null;
                                            _lastColInsertIndex = null;
                                          });
                                          _dragWantsInsert.value = false;
                                          _dragWantsDelete.value = false;
                                        },
                                        dragAnchorStrategy:
                                            pointerDragAnchorStrategy,
                                        feedback: widget.dragFeedbackBuilder
                                                ?.call(
                                              context,
                                              _buildFullColumnFeedback(
                                                  title, pillars[i].item2, rows,
                                                  widthOverride:
                                                      _isSeparatorColumnIndex(i)
                                                          ? null
                                                          : _colWidthAtIndex(
                                                              i, pillars)),
                                            ) ??
                                            _statusFeedback(
                                              _buildFullColumnFeedback(
                                                  title, pillars[i].item2, rows,
                                                  widthOverride:
                                                      _isSeparatorColumnIndex(i)
                                                          ? null
                                                          : _colWidthAtIndex(
                                                              i, pillars)),
                                            ),
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.grab,
                                          child: const Icon(
                                              Icons.drag_indicator,
                                              size: 14,
                                              color: Colors.black),
                                        ),
                                      ),
                                    );
                                    final inner = Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        grip,
                                        Flexible(child: titleWidget),
                                      ],
                                    );
                                    return inner;
                                  })());
                        final childCell = Stack(
                          children: [
                            _cell(Size(colW, columnTitleHeight), headerInner),
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
                            width: colW,
                            height: columnTitleHeight,
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              offset: (_dropColFadeActive &&
                                      _dropAnimatingColIndex == i)
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
                                    setState(() {
                                      _draggingColumnIndex = i;
                                      // 列拖拽开始，清理行插入状态
                                      _hoverRowInsertIndex = null;
                                      _lastRowInsertIndex = null;
                                      _hoveringExternalRow = false;
                                      _externalRowHoverHeight = 0.0;
                                    });
                                    _dragWantsInsert.value = false;
                                    _dragWantsDelete.value = false;
                                  },
                                  onDraggableCanceled: (velocity, offset) {
                                    // 未被任何 DragTarget 接受，若释放点在卡片外则删除
                                    final outside =
                                        !_isGlobalPointInsideCard(offset);
                                    if (outside) {
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
                                  onDragCompleted: () {
                                    // 已被卡片内的插入目标接受，重置状态
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
                                            title, pillars[i].item2, rows,
                                            widthOverride:
                                                _isSeparatorColumnIndex(i)
                                                    ? null
                                                    : _colWidthAtIndex(
                                                        i, pillars)),
                                      ) ??
                                      _statusFeedback(
                                        _buildFullColumnFeedback(
                                            title, pillars[i].item2, rows,
                                            widthOverride:
                                                _isSeparatorColumnIndex(i)
                                                    ? null
                                                    : _colWidthAtIndex(
                                                        i, pillars)),
                                      ),
                                  child: childCell,
                                ),
                              ),
                            )));
                      }
                      // 末尾插入位的可动画幽灵占位
                      // 行拖拽进行中时，禁止显示列拖拽的幽灵占位
                      final bool dragging =
                          (d != null || _hoveringExternalPillar) &&
                              !rowDraggingActive;
                      final double endGhostWidth = (d != null)
                          ? _colWidthAtIndex(d, pillars)
                          : ghostWidth;
                      children.add(AnimatedContainer(
                        duration: dragging
                            ? const Duration(milliseconds: 180)
                            : Duration.zero,
                        curve: Curves.easeOut,
                        width:
                            dragging && t == pillars.length ? endGhostWidth : 0,
                        height: columnTitleHeight,
                        color: dragging && t == pillars.length
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.08)
                            : Colors.transparent,
                      ));
                      return children;
                    })(),
                    // 右侧行抓手列占位：仅当 rows[0] 是表头行时渲染抓手
                    (() {
                      final rowPayloads = widget.rowListNotifier.value;
                      final isRows0HeaderRow = rowPayloads.isNotEmpty &&
                          rowPayloads[0].rowType == RowType.columnHeaderRow;

                      if (!isRows0HeaderRow) {
                        // rows[0] 不是表头行，返回空占位以保持宽度
                        return SizedBox(
                          width: dragHandleColWidth,
                          height: columnTitleHeight,
                        );
                      }

                      // rows[0] 是表头行，渲染抓手
                      final d = _draggingRowIndex;
                      if (d == 0) {
                        // 表头行正在被拖拽，返回空占位
                        return SizedBox(
                          width: dragHandleColWidth,
                          height: columnTitleHeight,
                        );
                      }

                      return SizedBox(
                        width: dragHandleColWidth,
                        height: columnTitleHeight,
                        child: Center(
                          child: Draggable<Tuple2<_DragKind, int>>(
                            data: Tuple2(_DragKind.row, 0),
                            onDragStarted: () {
                              setState(() {
                                _draggingRowIndex = 0;
                                _hoverColumnInsertIndex = null;
                                _lastColInsertIndex = null;
                                _hoveringExternalPillar = false;
                              });
                              _dragWantsInsert.value = false;
                              _dragWantsDelete.value = false;
                            },
                            onDraggableCanceled: (velocity, offset) {
                              final outside = !_isGlobalPointInsideCard(offset);
                              setState(() {
                                _draggingRowIndex = null;
                                _hoverRowInsertIndex = null;
                                _lastRowInsertIndex = null;
                                _hoveringExternalRow = false;
                                _externalRowHoverHeight = 0.0;
                              });
                              _dragWantsInsert.value = false;
                              _dragWantsDelete.value = false;
                              if (outside) {
                                _deleteRow(0);
                              }
                            },
                            onDragCompleted: () {
                              setState(() {
                                _draggingRowIndex = null;
                                _hoverRowInsertIndex = null;
                                _lastRowInsertIndex = null;
                                _hoveringExternalRow = false;
                                _externalRowHoverHeight = 0.0;
                              });
                              _dragWantsInsert.value = false;
                              _dragWantsDelete.value = false;
                            },
                            dragAnchorStrategy: pointerDragAnchorStrategy,
                            feedback: _offsetFeedbackLeft(
                              widget.dragFeedbackBuilder?.call(
                                    context,
                                    _buildFullRowFeedback(
                                        rows[0], _effectivePillarsTuples(),
                                        absRowIndex: 0),
                                  ) ??
                                  _statusFeedback(
                                    _buildFullRowFeedback(
                                        rows[0], _effectivePillarsTuples(),
                                        absRowIndex: 0),
                                  ),
                              _rowFeedbackTotalWidth(_effectivePillarsTuples()),
                            ),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.grab,
                              child: const Icon(Icons.drag_indicator,
                                  size: 14, color: Colors.black),
                            ),
                          ),
                        ),
                      );
                    })(),
                  ],
                ),
                // 统一 DragTarget：填充在列标题区域之上，持续计算 hover 插入索引
                // 同时也处理行拖拽，允许插入到表头行之前
                Positioned.fill(
                  child: DragTarget<Object>(
                    onWillAccept: (data) {
                      // 接受列拖拽或行拖拽
                      final isColumnData = (data is Tuple2 &&
                              data.item1 is _DragKind &&
                              data.item1 == _DragKind.column) ||
                          (data is PillarPayload) ||
                          (data is PillarType) ||
                          (data is TitleColumnPayload);
                      final isRowData = (data is Tuple2 &&
                              data.item1 is _DragKind &&
                              data.item1 == _DragKind.row) ||
                          (data is RowInfoPayload) ||
                          (data is TitleRowPayload);

                      if (isColumnData) {
                        setState(() {
                          if (data is PillarPayload || data is PillarType) {
                            _hoveringExternalPillar = true;
                          }
                          // 列插入模式下，清理行插入状态
                          _hoverRowInsertIndex = null;
                          _lastRowInsertIndex = null;
                          _hoveringExternalRow = false;
                          _externalRowHoverHeight = 0.0;
                        });
                      }
                      if (isRowData) {
                        // 行拖拽开始，清理列插入状态
                        setState(() {
                          _hoverColumnInsertIndex = null;
                          _lastColInsertIndex = null;
                          _hoveringExternalPillar = false;
                        });
                        if (data is RowInfoPayload) {
                          setState(() {
                            _hoveringExternalRow = true;
                            _externalRowHoverHeight = _rowHeightByPayload(data);
                          });
                        }
                      }
                      return isColumnData || isRowData;
                    },
                    onMove: (details) {
                      // 优先处理行拖拽：允许插入到表头行之前
                      final isRowData = (details.data is Tuple2 &&
                              (details.data as Tuple2).item1 ==
                                  _DragKind.row) ||
                          details.data is RowInfoPayload ||
                          details.data is TitleRowPayload;

                      if (isRowData) {
                        // 行拖拽逻辑：根据 dy 判断插入到表头行之前（0）还是之后（1）
                        // 注意：此处不设置 _lastRowMoveAt，避免干扰统一行DragTarget的节流逻辑

                        // 外部行悬停：更新幽灵行高度
                        final isExternal = details.data is RowInfoPayload;
                        if (isExternal) {
                          final payload = details.data as RowInfoPayload;
                          final h = _rowHeightByPayload(payload);
                          if (_hoveringExternalRow != true ||
                              _externalRowHoverHeight != h) {
                            setState(() {
                              _hoveringExternalRow = true;
                              _externalRowHoverHeight = h;
                            });
                          }
                        }

                        final box = context.findRenderObject() as RenderBox?;
                        if (box == null) return;
                        final local = box.globalToLocal(details.offset);
                        final dy = local.dy;

                        // 根据 dy 判断插入位置：
                        // dy < columnTitleHeight / 2 → insertIndex = 0（表头行之前）
                        // dy >= columnTitleHeight / 2 → insertIndex = 1（表头行之后）
                        final candidate = dy < columnTitleHeight / 2 ? 0 : 1;

                        if (_hoverRowInsertIndex != candidate) {
                          setState(() {
                            _hoverRowInsertIndex = candidate;
                            _lastRowInsertIndex = candidate;
                          });
                          _dragWantsInsert.value = true;
                          _dragWantsDelete.value = false;
                        }
                        return; // 行拖拽处理完毕，不执行列拖拽逻辑
                      }

                      // 列拖拽逻辑（原有代码）
                      // 轻节流：约 12ms 更新一次，避免过度重绘
                      final now = DateTime.now();
                      if (_lastColMoveAt != null &&
                          now.difference(_lastColMoveAt!).inMilliseconds < 12) {
                        return;
                      }
                      _lastColMoveAt = now;
                      // 标记外部柱悬停，用于在未内部拖拽时仍显示幽灵列并扩展宽度
                      final isExternal = details.data is PillarPayload ||
                          details.data is PillarType;
                      if (_hoveringExternalPillar != isExternal) {
                        setState(() => _hoveringExternalPillar = isExternal);
                      }
                      // 外部柱悬停：更新幽灵列宽度（若载荷提供 columnWidth 则优先使用）
                      if (isExternal) {
                        double nextW = pillarWidth;
                        final data = details.data;
                        if (data is PillarPayload) {
                          // 分割柱载荷：占位宽度使用分隔列的有效宽度
                          nextW = (data.pillarType == PillarType.separator)
                              ? _colDividerWidthEffective
                              : data.resolveWidth(
                                  defaultWidth: pillarWidth,
                                  minWidth: _minPillarWidth,
                                  maxWidth: _maxPillarWidth,
                                );
                        } else if (data is PillarType) {
                          // 分割柱类型：占位宽度使用分隔列的有效宽度
                          nextW = (data == PillarType.separator)
                              ? _colDividerWidthEffective
                              : pillarWidth;
                        }
                        if (_externalColHoverWidth != nextW) {
                          setState(() => _externalColHoverWidth = nextW);
                        }
                      }
                      final box = context.findRenderObject() as RenderBox?;
                      if (box == null) return;
                      final local = box.globalToLocal(details.offset);
                      // 当存在行标题列时，行标题列已在数据网格中，不需要减去 rowTitleWidth
                      final hasRowTitleCol = widget.pillarsNotifier.value.any(
                          (p) => p.pillarType == PillarType.rowTitleColumn);
                      final dx =
                          local.dx - (hasRowTitleCol ? 0 : rowTitleWidth);
                      final n = pillars.length;
                      // 支持内部列拖拽与外部柱载荷的插入索引计算（变动列宽）
                      final candidate =
                          _computeColumnInsertIndexFromDxVariable(dx, pillars);
                      final last =
                          _hoverColumnInsertIndex ?? _lastColInsertIndex;

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
                      // 变动列宽的中点边界计算
                      final double totalColsW = _totalColsWidth(pillars);
                      final double rightBoundary = (last < n)
                          ? (_sumColWidthsUpTo(last, pillars) +
                              _colWidthAtIndex(last, pillars) / 2)
                          : totalColsW;
                      final double leftBoundary = (last > 0)
                          ? (_sumColWidthsUpTo(last - 1, pillars) +
                              _colWidthAtIndex(last - 1, pillars) / 2)
                          : 0.0;
                      bool allowUpdate = false;
                      if (candidate > last) {
                        // 向右移动：超过右边界+margin
                        allowUpdate = dx > rightBoundary + margin;
                      } else {
                        // 向左移动：低于左边界-margin
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
                    onLeave: (data) {
                      // 清理列插入状态
                      setState(() {
                        _hoverColumnInsertIndex = null;
                        _lastColInsertIndex = null;
                        _hoveringExternalPillar = false;
                      });
                      // 清理行插入状态
                      setState(() {
                        _hoverRowInsertIndex = null;
                        _lastRowInsertIndex = null;
                        _hoveringExternalRow = false;
                        _externalRowHoverHeight = 0.0;
                      });
                      _dragWantsInsert.value = false;
                      _dragWantsDelete.value = true;
                    },
                    onAccept: (payload) {
                      // 优先处理行拖拽
                      final isRowPayload = (payload is Tuple2 &&
                              payload.item1 == _DragKind.row) ||
                          payload is RowInfoPayload ||
                          payload is TitleRowPayload;

                      if (isRowPayload) {
                        if (_rowAccepting) return;
                        _rowAccepting = true;
                        final insertIndex = _hoverRowInsertIndex ?? 0;
                        setState(() {
                          _hoverRowInsertIndex = null;
                          _lastRowInsertIndex = null;
                          _draggingRowIndex = null;
                          _hoveringExternalRow = false;
                          _externalRowHoverHeight = 0.0;
                        });
                        if (payload is Tuple2) {
                          final fromAbsIdx = payload.item2 as int;
                          _reorderRows(fromAbsIdx, insertIndex);
                        } else if (payload is RowInfoPayload) {
                          _insertExternalRow(insertIndex, payload);
                        } else if (payload is TitleRowPayload) {
                          _reorderRowsByTitlePayload(payload, insertIndex);
                        }
                        Future.microtask(() {
                          if (!mounted) return;
                          setState(() {
                            _rowAccepting = false;
                          });
                        });
                        _dragWantsInsert.value = false;
                        _dragWantsDelete.value = false;
                        return;
                      }

                      // 列拖拽逻辑（原有代码）
                      final insertIndex = _hoverColumnInsertIndex ?? 0;
                      setState(() {
                        _hoverColumnInsertIndex = null;
                        _lastColInsertIndex = null;
                        _draggingColumnIndex = null;
                        _hoveringExternalPillar = false;
                      });
                      if (payload is Tuple2) {
                        final kind = payload.item1;
                        final fromIdx = payload.item2 as int;
                        if (kind == _DragKind.column) {
                          _reorderColumns(fromIdx, insertIndex);
                        }
                      } else if (payload is PillarPayload) {
                        _insertExternalPillar(insertIndex, payload);
                      } else if (payload is PillarType) {
                        _insertExternalPillarFromType(insertIndex, payload);
                      } else if (payload is TitleColumnPayload) {
                        _reorderColumnsByType(payload.pillarType, insertIndex);
                      }
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
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08),
                        ),
                      ),
                    ),
                  ),
                // Debug overlay: 行插入判定辅助线（表头行中点）- 静态参考线
                if (widget.debugHysteresisOverlay)
                  Positioned(
                    left: 0,
                    top: columnTitleHeight / 2 - 1,
                    right: 0,
                    height: 2,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.08),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.05),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 2,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.08),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '↑ insertIndex=0  ↓ insertIndex=1',
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // 行插入位指示条（表头行区域）
                if (_hoverRowInsertIndex != null &&
                    (_hoverRowInsertIndex == 0 || _hoverRowInsertIndex == 1))
                  Positioned(
                    left: 0,
                    top: _hoverRowInsertIndex == 0
                        ? -1 // insertIndex=0: 表头行顶部
                        : columnTitleHeight - 1, // insertIndex=1: 表头行底部
                    width: dragHandleColWidth + totalWidth,
                    height: 2,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        height: 2,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.45),
                      ),
                    ),
                  ),
                // 垂直分割线拖拽手柄：允许通过拖拽列间分割线来调整统一列宽
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: false,
                    child: Stack(
                      children: [
                        for (int i = 1; i < pillars.length; i++)
                          Builder(builder: (context) {
                            // 当存在行标题列时，不需要加上 rowTitleWidth
                            final hasRowTitleCol = widget.pillarsNotifier.value
                                .any((p) =>
                                    p.pillarType == PillarType.rowTitleColumn);
                            return Positioned(
                              // 分隔拖拽手柄位置按可变列宽累计定位
                              left: (hasRowTitleCol ? 0 : rowTitleWidth) +
                                  _sumColWidthsUpTo(i, pillars) -
                                  4,
                              top: columnTitleHeight,
                              bottom: 0,
                              width: 8,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.resizeColumn,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onPanStart: (details) {
                                    setState(() {
                                      _resizingDividerIndex = i;
                                      _initialPillarWidth = pillarWidth;
                                    });
                                  },
                                  onPanUpdate: (details) {
                                    final box = _cardKey.currentContext
                                        ?.findRenderObject() as RenderBox?;
                                    if (box == null) return;
                                    final idx = _resizingDividerIndex ?? i;
                                    if (idx <= 0) return;
                                    // 将全局坐标转换到卡片局部坐标，以统一基准
                                    final local = box
                                        .globalToLocal(details.globalPosition);
                                    // 当存在行标题列时，不需要减去 rowTitleWidth
                                    final hasRowTitleCol2 =
                                        widget.pillarsNotifier.value.any((p) =>
                                            p.pillarType ==
                                            PillarType.rowTitleColumn);
                                    final dx = local.dx -
                                        (hasRowTitleCol2 ? 0 : rowTitleWidth);
                                    // 依据分割线序号，将目标位置换算为统一列宽（所有列同宽）
                                    final computed = (dx / idx).clamp(
                                        _minPillarWidth, _maxPillarWidth);
                                    setState(() {
                                      pillarWidth = computed;
                                    });
                                  },
                                  onPanEnd: (_) {
                                    setState(() {
                                      _resizingDividerIndex = null;
                                      _initialPillarWidth = null;
                                    });
                                  },
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                // 已迁移：插入位指示条在外层Stack全局渲染，避免在局部被遮挡
                // 移除卡片右上角删除提示，仅保留拖拽物上的动态徽标
              ],
            ),
    );

    // Grip column: standalone handles for rows (no long-press required)
    // 叠加 DragTarget 覆盖整个抓手列区域，确保行拖拽经过此列也会持续更新插入索引，从而显示幽灵行
    final gripColumn = SizedBox(
      width: dragHandleColWidth,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...(() {
                final List<Widget> children = [];
                final d = _draggingRowIndex;
                final t = _hoverRowInsertIndex ?? _lastRowInsertIndex;
                final bool draggingRow = d != null || _hoveringExternalRow;

                // 第一个数据行（索引 1）之前的幽灵行占位
                children.add(AnimatedContainer(
                  duration: (_hoveringExternalRow && t == 1)
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  width: dragHandleColWidth,
                  height: (_hoveringExternalRow && t == 1)
                      ? _externalRowHoverHeight
                      : 0,
                  color: (_hoveringExternalRow && t == 1)
                      ? Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.08)
                      : Colors.transparent,
                ));

                // 处理数据行（条件跳过表头行索引 0）
                for (final entry in rows.asMap().entries) {
                  final absRowIdx = entry.key;
                  final rowName = entry.value;

                  // 只有当 rows[0] 是表头行时才跳过索引 0（表头行抓手已在 headerRow 中渲染）
                  if (absRowIdx == 0) {
                    final rowPayloads = widget.rowListNotifier.value;
                    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
                        rowPayloads[0].rowType == RowType.columnHeaderRow;
                    if (isRows0HeaderRow) continue;
                    // rows[0] 不是表头行，继续渲染其抓手
                  }

                  final rowSize = _rowCellSize(rowName);
                  final bool isSeparatorRow = _isSeparatorRowLabel(rowName);

                  // 幽灵占位（t==0 时由表头区统一渲染，这里跳过）
                  children.add(AnimatedContainer(
                    duration: draggingRow
                        ? const Duration(milliseconds: 180)
                        : Duration.zero,
                    curve: Curves.easeOut,
                    width: dragHandleColWidth,
                    height: draggingRow && t != 0 && t == absRowIdx
                        ? (() {
                            final d = _draggingRowIndex;
                            if (d != null && d < rows.length) {
                              final draggedName = rows[d];
                              final override = _rowHeightOverrides[d];
                              final byName = _rowHeightByName(draggedName);
                              final finalHeight = override ?? byName;
                              print('🔍 [幽灵行-gripColumn] t=$t, d=$d, draggedName=$draggedName, override=$override, byName=$byName, final=$finalHeight');
                              return finalHeight;
                            } else if (_hoveringExternalRow) {
                              print('🔍 [幽灵行-gripColumn] t=$t, external row, height=$_externalRowHoverHeight');
                              return _externalRowHoverHeight;
                            }
                            print('🔍 [幽灵行-gripColumn] t=$t, fallback to rowSize.height=${rowSize.height}');
                            return rowSize.height;
                          })()
                        : 0,
                    color: draggingRow && t != 0 && t == absRowIdx
                        ? Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.08)
                        : Colors.transparent,
                  ));
                  if (d == absRowIdx) continue;
                  children.add(SizedBox(
                    width: dragHandleColWidth,
                    height: rowSize.height,
                    child: isSeparatorRow
                        ? const SizedBox.shrink()
                        : Center(
                            child: Draggable<Tuple2<_DragKind, int>>(
                              data: Tuple2(_DragKind.row, absRowIdx),
                              onDragStarted: () {
                                setState(() {
                                  _draggingRowIndex = absRowIdx;
                                  // 行拖拽开始，清理列插入状态
                                  _hoverColumnInsertIndex = null;
                                  _lastColInsertIndex = null;
                                  _hoveringExternalPillar = false;
                                });
                                _dragWantsInsert.value = false;
                                _dragWantsDelete.value = false;
                              },
                              onDraggableCanceled: (velocity, offset) {
                                final outside =
                                    !_isGlobalPointInsideCard(offset);
                                setState(() {
                                  _draggingRowIndex = null;
                                  _hoverRowInsertIndex = null;
                                  _lastRowInsertIndex = null;
                                  _hoveringExternalRow = false;
                                  _externalRowHoverHeight = 0.0;
                                });
                                _dragWantsInsert.value = false;
                                _dragWantsDelete.value = false;
                                if (outside) {
                                  _deleteRow(absRowIdx);
                                }
                              },
                              onDragCompleted: () {
                                setState(() {
                                  _draggingRowIndex = null;
                                  _hoverRowInsertIndex = null;
                                  _lastRowInsertIndex = null;
                                  _hoveringExternalRow = false;
                                  _externalRowHoverHeight = 0.0;
                                });
                                _dragWantsInsert.value = false;
                                _dragWantsDelete.value = false;
                              },
                              dragAnchorStrategy: pointerDragAnchorStrategy,
                              feedback: _offsetFeedbackLeft(
                                widget.dragFeedbackBuilder?.call(
                                      context,
                                      _buildFullRowFeedback(rowName, pillars,
                                          absRowIndex: absRowIdx),
                                    ) ??
                                    _statusFeedback(
                                      _buildFullRowFeedback(rowName, pillars,
                                          absRowIndex: absRowIdx),
                                    ),
                                // 按整行反馈宽度左移，使内容整体位于光标左侧
                                _rowFeedbackTotalWidth(pillars),
                              ),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: const Icon(Icons.drag_indicator,
                                    size: 14, color: Colors.black),
                              ),
                            ),
                          ),
                  ));
                }
                // 末尾插入位幽灵占位
                children.add(AnimatedContainer(
                  duration: draggingRow
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  width: dragHandleColWidth,
                  height: draggingRow && (t == rows.length)
                      ? (_draggingRowIndex != null
                          ? (_rowHeightOverrides[_draggingRowIndex!] ??
                              _rowHeightByName(rows[_draggingRowIndex!]))
                          : _externalRowHoverHeight)
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

                final bool draggingRow = d != null || _hoveringExternalRow;

                // 第一行之前的幽灵行占位（当 _hoverRowInsertIndex == 1 时显示）
                children.add(AnimatedContainer(
                  duration: (_hoveringExternalRow && t == 1)
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  width: rowTitleWidth,
                  height: (_hoveringExternalRow && t == 1)
                      ? _externalRowHoverHeight
                      : 0,
                  color: (_hoveringExternalRow && t == 1)
                      ? Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.08)
                      : Colors.transparent,
                ));

                for (final entry in rows.asMap().entries) {
                  final absRowIdx = entry.key;
                  final rowName = entry.value;

                  // 只有当 rows[0] 是表头行时才跳过索引 0
                  // 如果 rows[0] 不是表头行（被拖拽到其他位置了），需要渲染它
                  if (absRowIdx == 0) {
                    final rowPayloads = widget.rowListNotifier.value;
                    final isHeaderRow = rowPayloads.isNotEmpty &&
                        rowPayloads[0].rowType == RowType.columnHeaderRow;
                    if (isHeaderRow) continue; // 跳过表头行
                    // 否则继续渲染 rows[0]
                  }

                  final rowSize = _rowCellSize(rowName);

                  // 在每个行前插入一个可动画的幽灵占位，高度在 0..rowSize.height 之间动画
                  // t==0 时由表头区统一渲染，这里跳过
                  // 特殊处理：当插入到第一行前（t == 1）且为外部拖拽时，第一行（absRowIdx == 1）不应该让位，避免双重让位
                  children.add(AnimatedContainer(
                    duration: draggingRow
                        ? const Duration(milliseconds: 180)
                        : Duration.zero,
                    curve: Curves.easeOut,
                    width: rowTitleWidth,
                    height: draggingRow &&
                            t != 0 &&
                            t == absRowIdx &&
                            !(t == 1 && absRowIdx == 1 && _hoveringExternalRow)
                        ? (() {
                            final dIdx = _draggingRowIndex;
                            if (dIdx != null && dIdx < rows.length) {
                              final draggedName = rows[dIdx];
                              final override = _rowHeightOverrides[dIdx];
                              final byName = _rowHeightByName(draggedName);
                              final finalHeight = override ?? byName;
                              print('🔍 [幽灵行-leftHeader] t=$t, d=$dIdx, draggedName=$draggedName, override=$override, byName=$byName, final=$finalHeight');
                              return finalHeight;
                            } else if (_hoveringExternalRow) {
                              // 外部行拖拽：使用外部载荷解析的悬停高度（分割线用有效高度）
                              print('🔍 [幽灵行-leftHeader] t=$t, external row, height=$_externalRowHoverHeight');
                              return _externalRowHoverHeight;
                            }
                            print('🔍 [幽灵行-leftHeader] t=$t, fallback to rowSize.height=${rowSize.height}');
                            return rowSize.height;
                          })()
                        : 0,
                    color: draggingRow &&
                            t != 0 &&
                            t == absRowIdx &&
                            !(t == 1 && absRowIdx == 1 && _hoveringExternalRow)
                        ? Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.08)
                        : Colors.transparent,
                  ));

                  // 拖拽中的行不占原位置，跳过实际单元格渲染（保留幽灵占位）
                  if (d == absRowIdx) continue;
                  final cell = Stack(
                    children: [
                      if (_isSeparatorRowLabel(rowName))
                        Container(
                          width: rowTitleWidth,
                          height: rowSize.height,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: _rowDividerThickness,
                              ),
                            ),
                          ),
                        )
                      else
                        (() {
                          // 行标题不再作为拖拽抓手，改为独立"行首抓手"
                          final rowPayloads = widget.rowListNotifier.value;
                          RowInfoPayload? rPayload;
                          if (absRowIdx >= 0 &&
                              absRowIdx < rowPayloads.length) {
                            rPayload = rowPayloads[absRowIdx];
                          }

                          // 检查是否为表头行（columnHeaderRow）
                          final isHeaderRow =
                              rPayload?.rowType == RowType.columnHeaderRow;

                          // 表头行：显示性别文本（乾造/坤造），而非rowType名称
                          final titleWidget =
                              isHeaderRow && rPayload is ColumnHeaderRowPayload
                                  ? _genderText(rPayload.gender)
                                  : _rowTitleText(rowName);

                          // 表头行：直接渲染性别文本，与headerRow保持一致
                          if (isHeaderRow) {
                            return Draggable<Tuple2<_DragKind, int>>(
                              data: Tuple2(_DragKind.row, absRowIdx),
                              onDragStarted: () {
                                setState(() {
                                  _draggingRowIndex = absRowIdx;
                                  _hoverColumnInsertIndex = null;
                                  _lastColInsertIndex = null;
                                  _hoveringExternalPillar = false;
                                });
                                _dragWantsInsert.value = false;
                                _dragWantsDelete.value = false;
                              },
                              onDraggableCanceled: (velocity, offset) {
                                final outside =
                                    !_isGlobalPointInsideCard(offset);
                                setState(() {
                                  _draggingRowIndex = null;
                                  _hoverRowInsertIndex = null;
                                  _lastRowInsertIndex = null;
                                  _hoveringExternalRow = false;
                                  _externalRowHoverHeight = 0.0;
                                });
                                _dragWantsInsert.value = false;
                                _dragWantsDelete.value = false;
                                if (outside) {
                                  _deleteRow(absRowIdx);
                                }
                              },
                              onDragCompleted: () {
                                setState(() {
                                  _draggingRowIndex = null;
                                  _hoverRowInsertIndex = null;
                                  _lastRowInsertIndex = null;
                                  _hoveringExternalRow = false;
                                  _externalRowHoverHeight = 0.0;
                                });
                                _dragWantsInsert.value = false;
                                _dragWantsDelete.value = false;
                              },
                              dragAnchorStrategy: pointerDragAnchorStrategy,
                              feedback: _offsetFeedbackUp(
                                _offsetFeedbackRight(
                                  widget.dragFeedbackBuilder?.call(
                                        context,
                                        _buildFullRowFeedback(rowName, pillars,
                                            absRowIndex: absRowIdx),
                                      ) ??
                                      _statusFeedback(
                                        _buildFullRowFeedback(rowName, pillars,
                                            absRowIndex: absRowIdx),
                                      ),
                                  0,
                                ),
                                (absRowIdx != null &&
                                        _rowHeightOverrides[absRowIdx] != null)
                                    ? _rowHeightOverrides[absRowIdx]! / 2
                                    : _rowHeightByName(rowName) / 2,
                              ),
                              child: _cell(rowSize, titleWidget),
                            );
                          }

                          // 普通行：使用grip + titleWidget布局
                          final grip = Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Draggable<Tuple2<_DragKind, int>>(
                              data: Tuple2(_DragKind.row, absRowIdx),
                              onDragStarted: () {
                                setState(() {
                                  _draggingRowIndex = absRowIdx;
                                  _hoverColumnInsertIndex = null;
                                  _lastColInsertIndex = null;
                                  _hoveringExternalPillar = false;
                                });
                                _dragWantsInsert.value = false;
                                _dragWantsDelete.value = false;
                              },
                              onDraggableCanceled: (velocity, offset) {
                                final outside =
                                    !_isGlobalPointInsideCard(offset);
                                setState(() {
                                  _draggingRowIndex = null;
                                  _hoverRowInsertIndex = null;
                                  _lastRowInsertIndex = null;
                                  _hoveringExternalRow = false;
                                  _externalRowHoverHeight = 0.0;
                                });
                                _dragWantsInsert.value = false;
                                _dragWantsDelete.value = false;
                                if (outside) {
                                  _deleteRow(absRowIdx);
                                }
                              },
                              onDragCompleted: () {
                                setState(() {
                                  _draggingRowIndex = null;
                                  _hoverRowInsertIndex = null;
                                  _lastRowInsertIndex = null;
                                  _hoveringExternalRow = false;
                                  _externalRowHoverHeight = 0.0;
                                });
                                _dragWantsInsert.value = false;
                                _dragWantsDelete.value = false;
                              },
                              dragAnchorStrategy: pointerDragAnchorStrategy,
                              feedback: _offsetFeedbackUp(
                                _offsetFeedbackRight(
                                  widget.dragFeedbackBuilder?.call(
                                        context,
                                        _buildFullRowFeedback(rowName, pillars,
                                            absRowIndex: absRowIdx),
                                      ) ??
                                      _statusFeedback(
                                        _buildFullRowFeedback(rowName, pillars,
                                            absRowIndex: absRowIdx),
                                      ),
                                  0,
                                ),
                                (absRowIdx != null &&
                                        _rowHeightOverrides[absRowIdx] != null)
                                    ? _rowHeightOverrides[absRowIdx]! / 2
                                    : _rowHeightByName(rowName) / 2,
                              ),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: const Icon(Icons.drag_indicator,
                                    size: 14, color: Colors.black),
                              ),
                            ),
                          );
                          // 普通行：使用 Stack 叠加布局，titleWidget 居中，grip 在左侧
                          return _cell(
                            rowSize,
                            Stack(
                              children: [
                                Center(child: titleWidget), // 居中显示标题
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(child: grip), // 左侧显示抓手
                                ),
                              ],
                            ),
                          );
                        })(),
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
                              setState(() {
                                _draggingRowIndex = absRowIdx;
                                // 行拖拽开始，清理列插入状态，避免误触发列调整
                                _hoverColumnInsertIndex = null;
                                _lastColInsertIndex = null;
                                _hoveringExternalPillar = false;
                              });
                              _dragWantsInsert.value = false;
                              _dragWantsDelete.value = false;
                            },
                            onDraggableCanceled: (velocity, offset) {
                              final outside = !_isGlobalPointInsideCard(offset);
                              // 先清理所有拖拽/悬停状态，避免高度计算在删除与状态切换之间出现一帧不一致（可能导致溢出）
                              setState(() {
                                _draggingRowIndex = null;
                                _hoverRowInsertIndex = null;
                                _lastRowInsertIndex = null;
                                _hoveringExternalRow = false;
                                _externalRowHoverHeight = 0.0;
                              });
                              _dragWantsInsert.value = false;
                              _dragWantsDelete.value = false;
                              if (outside) {
                                _deleteRow(absRowIdx);
                              }
                            },
                            onDragCompleted: () {
                              setState(() {
                                _draggingRowIndex = null;
                                _hoverRowInsertIndex = null;
                                _lastRowInsertIndex = null;
                                _hoveringExternalRow = false;
                                _externalRowHoverHeight = 0.0;
                              });
                              _dragWantsInsert.value = false;
                              _dragWantsDelete.value = false;
                            },
                            dragAnchorStrategy: pointerDragAnchorStrategy,
                            feedback: _offsetFeedbackUp(
                              _offsetFeedbackRight(
                                widget.dragFeedbackBuilder?.call(
                                      context,
                                      _buildFullRowFeedback(rowName, pillars,
                                          absRowIndex: absRowIdx),
                                    ) ??
                                    _statusFeedback(
                                      _buildFullRowFeedback(rowName, pillars,
                                          absRowIndex: absRowIdx),
                                    ),
                                // 取消横向偏移，使反馈紧贴光标
                                0,
                              ),
                              // 向上偏移行高的一半，防止底部溢出
                              // 优先使用覆盖高度，确保与实际显示高度一致
                              (absRowIdx != null &&
                                      _rowHeightOverrides[absRowIdx] != null)
                                  ? _rowHeightOverrides[absRowIdx]! / 2
                                  : _rowHeightByName(rowName) / 2,
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
                    ? Size(
                        rowTitleWidth,
                        (_rowHeightOverrides[d] ??
                            _rowHeightByName(draggedRowName)))
                    : Size(rowTitleWidth, 0);
                children.add(AnimatedContainer(
                  duration: draggingRow
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  width: rowTitleWidth,
                  height: draggingRow && (t == rows.length)
                      ? (d != null
                          ? draggedSize.height
                          : _externalRowHoverHeight)
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
                        .withOpacity(0.08),
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
              child: IgnorePointer(
                ignoring: true,
                child: SizedBox(
                  width: rowTitleWidth,
                  height: 2,
                  child: Divider(
                    height: 2,
                    thickness: 2,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.35),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // Data grid: according to current row order
    final dataGrid = SizedBox(
      // 数据网格总宽按可变列宽总和计算
      width: _totalColsWidth(pillars) + extraColWidth,
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
                // 行拖拽进行中时，禁止显示列拖拽的幽灵占位
                final bool dragging = (d != null || _hoveringExternalPillar) &&
                    !rowDraggingActive;
                final double gridGhostWidth =
                    (d != null) ? _colWidthAtIndex(d, pillars) : ghostWidth;
                children.add(AnimatedContainer(
                  duration: dragging
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  width: dragging && t == i ? gridGhostWidth : 0,
                  color: dragging && t == i
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                      : Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: (() {
                      final rowPayloads = widget.rowListNotifier.value;
                      final isRows0HeaderRow = rowPayloads.isNotEmpty &&
                          rowPayloads[0].rowType == RowType.columnHeaderRow;
                      return rows
                          .asMap()
                          .entries
                          .where((r) => !(r.key == 0 && isRows0HeaderRow))
                          .map((r) => SizedBox(
                                width: gridGhostWidth,
                                height: _rowHeightByName(r.value),
                              ))
                          .toList();
                    })(),
                  ),
                ));
                if (d == i) continue; // 拖拽中的列不占原位置
                final tuple = pillars[i];
                final jz = tuple.item2;
                final bool isSeparatorColumn = _isSeparatorColumnIndex(i);
                final pillarPayloads = widget.pillarsNotifier.value;
                // 检查当前列是否为行标题列，确保外层宽度与内部单元格宽度一致
                final isRowTitleCol = (i >= 0 && i < pillarPayloads.length) &&
                    pillarPayloads[i].pillarType == PillarType.rowTitleColumn;
                final double colW = isRowTitleCol
                    ? _colWidthAtIndex(i, pillars)
                    : (isSeparatorColumn
                        ? _colDividerWidthEffective
                        : pillarWidth);
                final columnContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...(() {
                      final dRow = _draggingRowIndex;
                      final tRow = _hoverRowInsertIndex ?? _lastRowInsertIndex;
                      final List<Widget> rowChildren = [];
                      // 构造一次行计算输入上下文，用于策略按需计算
                      // pillarPayloads 已在外层声明，直接使用
                      final pillarContents = pillarPayloads
                          .map((p) => p.pillarContent)
                          .whereType<PillarContent>()
                          .toList();
                      final dayJiaZi = (() {
                        try {
                          final day = pillarContents.firstWhere(
                              (c) => c.pillarType == PillarType.day);
                          return day.jiaZi;
                        } catch (_) {
                          return pillarContents.isNotEmpty
                              ? pillarContents.first.jiaZi
                              : JiaZi.JIA_ZI;
                        }
                      })();
                      final computationInput = RowComputationInput(
                        pillars: pillarContents,
                        dayJiaZi: dayJiaZi,
                        gender: widget.gender,
                      );
                      final rowPayloads = widget.rowListNotifier.value;

                      // 第一行之前的幽灵行占位（当 _hoverRowInsertIndex == 1 时显示）
                      final bool isDraggingRow =
                          dRow != null || _hoveringExternalRow;
                      rowChildren.add(AnimatedContainer(
                        duration: isDraggingRow
                            ? const Duration(milliseconds: 180)
                            : Duration.zero,
                        curve: Curves.easeOut,
                        width: colW,
                        height: (_hoveringExternalRow && tRow == 1)
                            ? _externalRowHoverHeight
                            : 0,
                        color: isDraggingRow && tRow == 1
                            ? Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.08)
                            : Colors.transparent,
                      ));

                      // 只有当 rows[0] 是表头行时才跳过索引 0
                      // rowPayloads 已在外层声明（第 2357 行），直接使用
                      final isRows0HeaderRow = rowPayloads.isNotEmpty &&
                          rowPayloads[0].rowType == RowType.columnHeaderRow;

                      for (final rEntry in rows.asMap().entries) {
                        final absRowIdx = rEntry.key;
                        final rowName = rEntry.value;

                        // 如果索引 0 是表头行，跳过它
                        if (absRowIdx == 0 && isRows0HeaderRow) continue;

                        final rowSize = _rowCellSize(rowName);
                        // 在每个数据行前插入一个可动画的幽灵行，占位高度 0..rowSize.height
                        // t==0 时由表头区统一渲染，这里跳过
                        final bool draggingRow =
                            dRow != null || _hoveringExternalRow;
                        rowChildren.add(AnimatedContainer(
                          duration: draggingRow
                              ? const Duration(milliseconds: 180)
                              : Duration.zero,
                          curve: Curves.easeOut,
                          // 行占位宽度使用外层计算的 colW，确保与单元格宽度一致
                          width: colW,
                          height: draggingRow &&
                                  tRow != 0 &&
                                  tRow == absRowIdx &&
                                  !(tRow == 1 &&
                                      absRowIdx == 1 &&
                                      _hoveringExternalRow)
                              ? (() {
                                  final d = _draggingRowIndex;
                                  if (d != null && d < rows.length) {
                                    final draggedName = rows[d];
                                    final override = _rowHeightOverrides[d];
                                    final byName = _rowHeightByName(draggedName);
                                    final finalHeight = override ?? byName;
                                    print('🔍 [幽灵行-dataGrid] col=$i, t=$tRow, d=$d, draggedName=$draggedName, override=$override, byName=$byName, final=$finalHeight');
                                    return finalHeight;
                                  } else if (_hoveringExternalRow) {
                                    // 外部行拖拽：使用外部载荷解析出的悬停高度（含分割线有效高度）
                                    print('🔍 [幽灵行-dataGrid] col=$i, t=$tRow, external row, height=$_externalRowHoverHeight');
                                    return _externalRowHoverHeight;
                                  }
                                  print('🔍 [幽灵行-dataGrid] col=$i, t=$tRow, fallback to rowSize.height=${rowSize.height}');
                                  return rowSize.height;
                                })()
                              : 0,
                          color: draggingRow &&
                                  tRow != 0 &&
                                  tRow == absRowIdx &&
                                  !(tRow == 1 &&
                                      absRowIdx == 1 &&
                                      _hoveringExternalRow)
                              ? Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.08)
                              : Colors.transparent,
                        ));
                        if (dRow == absRowIdx) continue; // 拖拽中的行不占原位置
                        Widget cell;

                        // isRowTitleCol 和 colW 已在外层声明，直接使用
                        final bool isSeparatorColumn =
                            _isSeparatorTitle(tuple.item1);

                        // 检测当前行是否为表头行（用于确定单元格高度）
                        final rowPayloadsForHeight =
                            widget.rowListNotifier.value;
                        final isCurrentRowHeaderRow = absRowIdx >= 0 &&
                            absRowIdx < rowPayloadsForHeight.length &&
                            rowPayloadsForHeight[absRowIdx].rowType ==
                                RowType.columnHeaderRow;

                        // 行标题列：显示行标签而非柱数据
                        if (isRowTitleCol) {
                          if (_isSeparatorRowLabel(rowName)) {
                            // 分隔行：显示水平分割线
                            cell = Container(
                              width: colW,
                              height: rowSize.height,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: _rowDividerThickness,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // 普通行与表头行：添加拖拽功能
                            // 获取当前行的payload以判断是否为表头行
                            final rowPayloads = widget.rowListNotifier.value;
                            RowInfoPayload? rPayload;
                            if (absRowIdx >= 0 &&
                                absRowIdx < rowPayloads.length) {
                              rPayload = rowPayloads[absRowIdx];
                            }

                            // 检查是否为表头行
                            final isHeaderRow =
                                rPayload?.rowType == RowType.columnHeaderRow;

                            // 表头行显示性别文本，普通行显示行标签
                            final titleWidget = isHeaderRow &&
                                    rPayload is ColumnHeaderRowPayload
                                ? _genderText(rPayload.gender)
                                : _rowTitleText(rowName);

                            // 创建拖拽抓手
                            final grip = Draggable<Tuple2<_DragKind, int>>(
                              data: Tuple2(_DragKind.row, absRowIdx),
                              onDragStarted: () {
                                setState(() {
                                  _draggingRowIndex = absRowIdx;
                                  _hoverColumnInsertIndex = null;
                                  _lastColInsertIndex = null;
                                  _hoveringExternalPillar = false;
                                });
                                _dragWantsInsert.value = false;
                                _dragWantsDelete.value = false;
                              },
                              onDraggableCanceled: (velocity, offset) {
                                final outside =
                                    !_isGlobalPointInsideCard(offset);
                                setState(() {
                                  _draggingRowIndex = null;
                                  _hoverRowInsertIndex = null;
                                  _lastRowInsertIndex = null;
                                  _hoveringExternalRow = false;
                                  _externalRowHoverHeight = 0.0;
                                });
                                _dragWantsInsert.value = false;
                                _dragWantsDelete.value = false;
                                if (outside) {
                                  _deleteRow(absRowIdx);
                                }
                              },
                              onDragCompleted: () {
                                setState(() {
                                  _draggingRowIndex = null;
                                  _hoverRowInsertIndex = null;
                                  _lastRowInsertIndex = null;
                                  _hoveringExternalRow = false;
                                  _externalRowHoverHeight = 0.0;
                                });
                                _dragWantsInsert.value = false;
                                _dragWantsDelete.value = false;
                              },
                              dragAnchorStrategy: pointerDragAnchorStrategy,
                              feedback: _offsetFeedbackUp(
                                _offsetFeedbackRight(
                                  widget.dragFeedbackBuilder?.call(
                                        context,
                                        _buildFullRowFeedback(rowName, pillars,
                                            absRowIndex: absRowIdx),
                                      ) ??
                                      _statusFeedback(
                                        _buildFullRowFeedback(rowName, pillars,
                                            absRowIndex: absRowIdx),
                                      ),
                                  0,
                                ),
                                rowSize.height / 2,
                              ),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: const Icon(Icons.drag_indicator,
                                    size: 14, color: Colors.black),
                              ),
                            );

                            // 使用 Stack 布局：titleWidget在整个单元格居中，grip浮在左侧
                            cell = _cell(
                              Size(colW, rowSize.height),
                              Stack(
                                children: [
                                  Center(child: titleWidget), // 在整个单元格居中显示文字
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(child: grip), // 拖拽图标固定在左侧
                                  ),
                                ],
                              ),
                            );
                          }
                        } else if (isSeparatorColumn) {
                          // 分隔符列：在单元格内不再绘制竖线，改为由数据网格叠加层统一绘制贯穿整列的竖线
                          cell = SizedBox(
                            width: colW,
                            height: rowSize.height,
                          );
                        } else if (rowName == '天干') {
                          cell = _cell(Size(colW, ganZhiCellSize.height),
                              _tianGanText(jz.tianGan));
                        } else if (rowName == '地支') {
                          cell = _cell(Size(colW, ganZhiCellSize.height),
                              _diZhiText(jz.diZhi));
                        } else if (rowName == '纳音') {
                          // 使用 RowInfoPayload 策略优先解析；缺省退回 JiaZi.naYinStr
                          final pillarContent = pillarPayloads[i].pillarContent;
                          String text = '';
                          if (pillarContent != null) {
                            final payload = rowPayloads[absRowIdx];
                            text = payload.valueFor(
                                    pillarContent, computationInput) ??
                                jz.naYinStr;
                          }
                          cell = _cell(
                              Size(colW, otherCellHeight), _naYinText(text));
                        } else if (rowName == '空亡') {
                          // 空亡行：使用嵌入策略计算，缺省退回 JiaZi.getKongWang()
                          final pillarContent = pillarPayloads[i].pillarContent;
                          String text = '';
                          if (pillarContent != null) {
                            final payload = rowPayloads[absRowIdx];
                            final fallbackKw = jz.getKongWang();
                            text = payload.valueFor(
                                    pillarContent, computationInput) ??
                                '${fallbackKw.item1.value}${fallbackKw.item2.value}';
                          }
                          cell = _cell(
                              Size(colW, otherCellHeight), _naYinText(text));
                        } else if (_isSeparatorRowLabel(rowName)) {
                          cell = SizedBox(
                            width: colW,
                            height: rowSize.height,
                            child: Center(
                              child: Divider(
                                height: _rowDividerHeightEffective,
                                thickness: _rowDividerThickness,
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          );
                        } else {
                          // 表头行的列标题单元格使用 columnTitleHeight，其他行使用 otherCellHeight
                          final cellHeight = isCurrentRowHeaderRow
                              ? columnTitleHeight
                              : otherCellHeight;
                          cell = _cell(Size(colW, cellHeight),
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
                          ? Size(
                              colW,
                              (_rowHeightOverrides[_draggingRowIndex!] ??
                                  _rowHeightByName(draggedRowName)))
                          : Size(colW, 0);
                      final bool draggingRow =
                          dRow != null || _hoveringExternalRow;
                      rowChildren.add(AnimatedContainer(
                        duration: draggingRow
                            ? const Duration(milliseconds: 180)
                            : Duration.zero,
                        curve: Curves.easeOut,
                        width: colW,
                        height: draggingRow && (tRow == rows.length)
                            ? (dRow != null
                                ? draggedSize.height
                                : _externalRowHoverHeight)
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
                          width: colW,
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
              // 行拖拽进行中时，禁止显示列拖拽的幽灵占位
              final bool dragging =
                  (d != null || _hoveringExternalPillar) && !rowDraggingActive;
              final double endGhostWidth =
                  (d != null) ? _colWidthAtIndex(d, pillars) : ghostWidth;
              children.add(AnimatedContainer(
                duration: dragging
                    ? const Duration(milliseconds: 180)
                    : Duration.zero,
                curve: Curves.easeOut,
                width: dragging && t == pillars.length ? endGhostWidth : 0,
                color: dragging && t == pillars.length
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                    : Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: (() {
                    final rowPayloads = widget.rowListNotifier.value;
                    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
                        rowPayloads[0].rowType == RowType.columnHeaderRow;
                    return rows
                        .asMap()
                        .entries
                        .where((r) => !(r.key == 0 && isRows0HeaderRow))
                        .map((r) => SizedBox(
                              width: endGhostWidth,
                              height: _rowHeightByName(r.value),
                            ))
                        .toList();
                  })(),
                ),
              ));
              return children;
            })(),
          ),
          // 行插入指示线（右侧数据网格覆盖）
          if (_hoverRowInsertIndex != null)
            Positioned(
              left: 0,
              top: (_hoverRowInsertIndex == 1)
                  ? 0
                  : _computeRowInsertTopFromIndex(_hoverRowInsertIndex!, rows) -
                      1,
              width: _totalColsWidth(pillars),
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
              width: _totalColsWidth(pillars),
              height: _rowCellSize(rows[_hoverRowInsertIndex!]).height,
              child: IgnorePointer(
                child: Container(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.06),
                ),
              ),
            ),
          // 分隔符列的整列贯穿竖线（叠加层）：统一依据 payload 判断，以避免标题别名导致的不一致
          ...List.generate(pillars.length, (i) => i).where((i) {
            return _isSeparatorColumnIndex(i);
          }).map((i) {
            final double left = _sumColWidthsUpTo(i, pillars);
            return Positioned(
              left: left,
              top: 0,
              bottom: 0,
              width: _colDividerWidthEffective,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    width: _colDividerThickness,
                    height: double.infinity,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );

    // 使用方法开头定义的 hasRowTitleColumn 判断是否渲染独立的 leftHeader
    final d = _draggingRowIndex;
    final t = _hoverRowInsertIndex ?? _lastRowInsertIndex;
    final bool draggingRow = d != null || _hoveringExternalRow;

    // 计算幽灵行+表头行的总高度
    final ghostHeight = (draggingRow && t == 0)
        ? (() {
            final dIdx = _draggingRowIndex;
            if (dIdx != null && dIdx < rows.length) {
              final draggedName = rows[dIdx];
              final override = _rowHeightOverrides[dIdx];
              final byName = _rowHeightByName(draggedName);
              final finalHeight = override ?? byName;
              print('🔍 [幽灵行-表头区] t=0, d=$dIdx, draggedName=$draggedName, override=$override, byName=$byName, final=$finalHeight');
              return finalHeight;
            } else if (_hoveringExternalRow) {
              print('🔍 [幽灵行-表头区] t=0, external row, height=$_externalRowHoverHeight');
              return _externalRowHoverHeight;
            }
            print('🔍 [幽灵行-表头区] t=0, fallback to columnTitleHeight=$columnTitleHeight');
            return columnTitleHeight;
          })()
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 表头行区域（包含幽灵行和headerRow，统一添加DragTarget）
        Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 表头行之前的幽灵行（t==0时显示）
                AnimatedContainer(
                  duration: (draggingRow && t == 0)
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  width: (hasRowTitleColumn ? 0 : rowTitleWidth) +
                      _totalColsWidth(pillars) +
                      dragHandleColWidth,
                  height: ghostHeight,
                  color: (draggingRow && t == 0)
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.08)
                      : Colors.transparent,
                ),
                headerRow,
              ],
            ),
            // DragTarget覆盖整个区域（幽灵行+headerRow）
            Positioned.fill(
              child: DragTarget<Object>(
                onWillAccept: (data) {
                  final isRowData = (data is Tuple2 && data.item1 == _DragKind.row) ||
                      data is RowInfoPayload ||
                      data is TitleRowPayload;
                  if (isRowData) {
                    setState(() {
                      _hoverColumnInsertIndex = null;
                      _lastColInsertIndex = null;
                      _hoveringExternalPillar = false;
                    });
                    if (data is RowInfoPayload) {
                      setState(() {
                        _hoveringExternalRow = true;
                        _externalRowHoverHeight = _rowHeightByPayload(data);
                      });
                    }
                  }
                  return isRowData;
                },
                onMove: (details) {
                  final isRowData = (details.data is Tuple2 &&
                          (details.data as Tuple2).item1 == _DragKind.row) ||
                      details.data is RowInfoPayload ||
                      details.data is TitleRowPayload;
                  if (!isRowData) return;

                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  final local = box.globalToLocal(details.offset);
                  final dy = local.dy;

                  // dy 相对于幽灵行+headerRow的顶部
                  // 计算总高度（幽灵行 + headerRow）
                  final totalHeight = ghostHeight + columnTitleHeight;
                  final midLine = totalHeight / 2;

                  // 根据 dy 判断插入位置
                  final candidate = dy < midLine ? 0 : 1;

                  if (_hoverRowInsertIndex != candidate) {
                    setState(() {
                      _hoverRowInsertIndex = candidate;
                      _lastRowInsertIndex = candidate;
                    });
                    _dragWantsInsert.value = true;
                    _dragWantsDelete.value = false;
                  }
                },
                onLeave: (_) {
                  // 不清理状态，让数据行区域的DragTarget接管
                },
                onAccept: (payload) {
                  if (_rowAccepting) return;
                  _rowAccepting = true;
                  final insertIndex = _hoverRowInsertIndex ?? 0;
                  setState(() {
                    _hoverRowInsertIndex = null;
                    _lastRowInsertIndex = null;
                    _draggingRowIndex = null;
                    _hoveringExternalRow = false;
                    _externalRowHoverHeight = 0.0;
                  });
                  if (payload is Tuple2) {
                    final fromAbsIdx = payload.item2 as int;
                    _reorderRows(fromAbsIdx, insertIndex);
                  } else if (payload is RowInfoPayload) {
                    _insertExternalRow(insertIndex, payload);
                  } else if (payload is TitleRowPayload) {
                    _reorderRowsByTitlePayload(payload, insertIndex);
                  }
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
          ],
        ),
        // 统一行拖拽目标：包裹整个数据行区域，确保在任意位置拖拽都能触发让位与插入提示
        Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasRowTitleColumn) leftHeader, // 仅在无行标题列时渲染
                dataGrid,
                gripColumn, // 始终显示右侧行拖拽列
              ],
            ),
            // 统一的全宽 DragTarget：覆盖整个行区域，持续计算行插入索引
            Positioned.fill(
              child: Builder(
                builder: (builderContext) => DragTarget<Object>(
                  onWillAccept: (data) {
                    final ok =
                        (data is Tuple2 && data.item1 == _DragKind.row) ||
                            (data is RowInfoPayload) ||
                            (data is TitleRowPayload);
                    if (ok) {
                      setState(() {
                        // 行拖拽开始，清理列插入状态以避免列幽灵遮挡
                        _hoverColumnInsertIndex = null;
                        _lastColInsertIndex = null;
                        _hoveringExternalPillar = false;
                      });
                      if (data is RowInfoPayload) {
                        setState(() {
                          _hoveringExternalRow = true;
                          _externalRowHoverHeight = _rowHeightByPayload(data);
                        });
                      }
                    }
                    return ok;
                  },
                  onMove: (details) {
                    final data = details.data;
                    final isRowPayload =
                        (data is Tuple2 && data.item1 == _DragKind.row) ||
                            data is RowInfoPayload ||
                            (data is TitleRowPayload);
                    if (!isRowPayload) return;
                    final now = DateTime.now();
                    if (_lastRowMoveAt != null &&
                        now.difference(_lastRowMoveAt!).inMilliseconds < 12) {
                      return;
                    }
                    _lastRowMoveAt = now;

                    // 外部行悬停：更新幽灵行高度
                    final isExternal = details.data is RowInfoPayload;
                    if (isExternal) {
                      final payload = details.data as RowInfoPayload;
                      final h = _rowHeightByPayload(payload);
                      if (_hoveringExternalRow != true ||
                          _externalRowHoverHeight != h) {
                        setState(() {
                          _hoveringExternalRow = true;
                          _externalRowHoverHeight = h;
                        });
                      }
                    }

                    final box = builderContext.findRenderObject() as RenderBox?;
                    if (box == null) {
                      return;
                    }
                    final local = box.globalToLocal(details.offset);
                    var dy = local.dy;

                    // 关键修正：调整 dy 使其相对于整个卡片（包括 headerRow）
                    // 因为统一 DragTarget 只覆盖数据行区域，dy=0 对应的是 headerRow 之后
                    // 需要向上偏移 headerRow 的高度，才能支持插入到 headerRow 之前
                    final rowPayloads = widget.rowListNotifier.value;
                    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
                        rowPayloads[0].rowType == RowType.columnHeaderRow;
                    if (isRows0HeaderRow) {
                      dy += columnTitleHeight; // 向上偏移表头行高度
                    }

                    final rows = _currentRowLabels();
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
                    // 顶部插入位特殊处理：当目标为表头行之前（索引0）或第一个可拖拽行（索引1）时立即更新，避免不让位
                    if (candidate == 0 || candidate == 1) {
                      setState(() {
                        _hoverRowInsertIndex = candidate;
                        _lastRowInsertIndex = candidate;
                      });
                      _dragWantsInsert.value = true;
                      _dragWantsDelete.value = false;
                      return;
                    }
                    if (candidate == last) return;

                    // candidate计算已经基于绿线，直接更新即可
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
                      _hoveringExternalRow = false;
                      _externalRowHoverHeight = 0.0;
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
                      _hoveringExternalRow = false;
                      _externalRowHoverHeight = 0.0;
                    });
                    if (payload is Tuple2) {
                      final kind = payload.item1;
                      final fromAbsIdx = payload.item2 as int;
                      if (kind == _DragKind.row) {
                        _reorderRows(fromAbsIdx, insertIndex);
                      }
                    } else if (payload is RowInfoPayload) {
                      _insertExternalRow(insertIndex, payload);
                    } else if (payload is TitleRowPayload) {
                      _reorderRowsByTitlePayload(payload, insertIndex);
                    }
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
            )
          ],
        ),
        gripRow,
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
    return DragTarget<Object>(
      onWillAccept: (data) {
        // Accept internal column drag or external PillarPayload
        final ok = (data is Tuple2 &&
                data.item1 is _DragKind &&
                data.item1 == _DragKind.column) ||
            (data is PillarPayload) ||
            (data is TitleColumnPayload);
        if (!ok) return false;
        setState(() => _hoverColumnInsertIndex = insertIndex);
        return true;
      },
      onLeave: (_) => setState(() => _hoverColumnInsertIndex = null),
      onAccept: (payload) {
        setState(() => _hoverColumnInsertIndex = null);
        if (payload is Tuple2) {
          // internal reorder
          final kind = payload.item1;
          final fromIdx = payload.item2 as int;
          if (kind == _DragKind.column) {
            _reorderColumns(fromIdx, insertIndex);
          }
        } else if (payload is PillarPayload) {
          _insertExternalPillar(insertIndex, payload);
        } else if (payload is TitleColumnPayload) {
          _reorderColumnsByType(payload.pillarType, insertIndex);
        }
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
        // 悬停时的插入占位高度：内部拖拽取被拖行的覆盖/类型高度，外部拖拽取载荷解析高度
        double hoveredHeight = otherCellHeight;
        if (_draggingRowIndex != null && _draggingRowIndex! < max + 1) {
          final d = _draggingRowIndex!;
          final rowsPayload = widget.rowListNotifier.value;
          if (d < rowsPayload.length) {
            final override = _rowHeightOverrides[d];
            hoveredHeight = override ?? _rowHeightByPayload(rowsPayload[d]);
          }
        } else if (_hoveringExternalRow) {
          hoveredHeight = _externalRowHoverHeight;
        }
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
          width: rowTitleWidth,
          height: isHover ? hoveredHeight : 12, // 保持最小命中高度
          decoration: decoration,
        );
      },
    );
  }

  // 计算行插入位的顶部位置（相对左侧标题区域），用于绘制指示条
  /// 计算插入指示条在左侧标题区域中的顶部位置。
  ///
  /// 参数：
  /// - insertIndex: 插入索引（范围 [0..rows.length]，0 表示在表头行之前，1 表示在表头行之后第一数据行之前）。
  /// - rows: 当前行名称列表（索引 0 可能为表头行）。
  /// 返回：
  /// - double：相对于左侧标题区域的顶部偏移量（像素）。
  double _computeRowInsertTopFromIndex(int insertIndex, List<String> rows) {
    // 检查 rows[0] 是否为表头行
    final rowPayloads = widget.rowListNotifier.value;
    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
        rowPayloads[0].rowType == RowType.columnHeaderRow;

    // 特殊处理：insertIndex == 0 表示在表头行之前插入，返回顶部位置 0.0
    if (insertIndex == 0) {
      return 0.0;
    }

    double acc = 0.0;
    for (final entry in rows.asMap().entries) {
      final idx = entry.key;
      final name = entry.value;

      // 当 idx == 0 时，检查是否为表头行
      if (idx == 0 && isRows0HeaderRow) {
        // 如果插入索引为 1（表头行之后第一个数据行之前），返回表头行高度
        if (insertIndex == 1) {
          return columnTitleHeight;
        }
        acc += columnTitleHeight;
        continue;
      }

      if (idx >= insertIndex) break;
      final h = _rowHeightByName(name);
      acc += h;
    }
    return acc;
  }

  // 计算目标行顶部位置（用于整行高亮覆盖）
  /// 计算目标行的顶部位置，用于整行高亮覆盖。
  ///
  /// 参数：
  /// - index: 数据行索引（范围 [1..rows.length-1]）。
  /// - rows: 行名称列表（索引 0 为标题行，跳过）。
  /// 返回：
  /// - double：相对于左侧标题区域的顶部偏移量（像素）。
  double _computeRowTopFromIndex(int index, List<String> rows) {
    // index 取值 [1..rows.length-1]；1 对应第一数据行，top=0
    // 检查 rows[0] 是否为表头行，决定是否跳过索引0
    final rowPayloads = widget.rowListNotifier.value;
    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
        rowPayloads[0].rowType == RowType.columnHeaderRow;

    double acc = 0.0;
    for (final entry in rows.asMap().entries) {
      final idx = entry.key;
      final name = entry.value;

      // 条件跳过索引0：仅当 rows[0] 是表头行时跳过
      if (idx == 0) {
        if (isRows0HeaderRow) continue;
        // rows[0] 不是表头行，继续累积其高度
      }

      if (idx == index) break;
      final h = _rowHeightOverrides[idx] ?? _rowHeightByName(name);
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
    final list = List<PillarPayload>.of(widget.pillarsNotifier.value);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    widget.pillarsNotifier.value = list;
  }

  // 删除行（跳过标题行，索引>=1）
  void _deleteRow(int absIndex) {
    final rows = List<RowInfoPayload>.of(widget.rowListNotifier.value);
    if (absIndex <= 0 || absIndex >= rows.length) return;
    rows.removeAt(absIndex);
    widget.rowListNotifier.value = rows;

    // 同步清理并重映射行高覆盖：
    // 1) 移除被删除索引的覆盖；
    // 2) 将其后的索引全部左移一位，保持与新行索引一致。
    if (_rowHeightOverrides.isNotEmpty) {
      final Map<int, double> next = {};
      for (final entry in _rowHeightOverrides.entries) {
        final k = entry.key;
        if (k == absIndex) continue; // 删除项的覆盖直接丢弃
        final nk = k > absIndex ? k - 1 : k; // 右侧条目左移一位
        next[nk] = entry.value;
      }
      _rowHeightOverrides
        ..clear()
        ..addAll(next);
    }
  }

  // 接受外部行信息载荷并插入到指定位置（支持例如「空亡」行）
  void _insertExternalRow(int insertIndex, RowInfoPayload payload) {
    final rows = List<RowInfoPayload>.of(widget.rowListNotifier.value);
    // 行插入索引范围：[0..rows.length]，允许插入到表头行之前
    final target = insertIndex.clamp(0, rows.length);
    rows.insert(target, payload);
    widget.rowListNotifier.value = rows;

    // 更新行高覆盖索引：插入新行后，所有后续行的索引都需要向后移动
    final Map<int, double> updatedOverrides = {};
    for (final entry in _rowHeightOverrides.entries) {
      final idx = entry.key;
      final height = entry.value;
      if (idx >= target) {
        // 后续行索引向后移动一位
        updatedOverrides[idx + 1] = height;
      } else {
        // 前面的行索引不变
        updatedOverrides[idx] = height;
      }
    }

    // 持久化行高覆盖：用于后续内部重排的反馈与占位高度一致性
    final double overrideH = _rowHeightByPayload(payload);
    updatedOverrides[target] = overrideH;

    _rowHeightOverrides
      ..clear()
      ..addAll(updatedOverrides);

    // 触发与内部重排一致的插入淡入动画
    setState(() {
      _draggingRowIndex = null;
      _hoverRowInsertIndex = null;
      _lastRowInsertIndex = null;
      _dropAnimatingRowIndex = target;
      _dropRowFadeActive = true;
    });
    // 下一帧关闭淡入标记
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

  // Offset feedback left by a given width so content appears to the left of cursor
  Widget _offsetFeedbackLeft(Widget child, double dx) {
    if (dx == 0) return child;
    return Transform.translate(
      offset: Offset(-dx, 0),
      child: child,
    );
  }

  // Offset feedback right by a given width so content appears to the right of cursor
  Widget _offsetFeedbackRight(Widget child, double dx) {
    if (dx == 0) return child;
    return Transform.translate(
      offset: Offset(dx, 0),
      child: child,
    );
  }

  /// 水平居中反馈：按给定宽度的一半向左平移，使反馈组件以光标为中心显示。
  ///
  /// 参数：
  /// - child: 需要居中的反馈组件。
  /// - dx: 反馈组件的总宽度，用于计算居中位移（dx/2）。
  /// 返回：
  /// - Widget：居中后的反馈组件。
  Widget _offsetFeedbackCenterX(Widget child, double dx) {
    if (dx == 0) return child;
    return Transform.translate(
      offset: Offset(-dx / 2, 0),
      child: child,
    );
  }

  /// 精确水平居中反馈：考虑抓手锚点（例如独立抓手的 `dragHandleColWidth/2`），
  /// 让反馈组件的几何中心与抓手中心对齐。
  ///
  /// 参数：
  /// - child: 需要居中的反馈组件。
  /// - totalWidth: 反馈组件的总宽度（用于计算其中心）。
  /// - anchorX: 抓手内光标相对 child 左上角的水平偏移（典型为抓手宽度的一半）。
  /// 返回：
  /// - Widget：居中后的反馈组件。
  Widget _offsetFeedbackCenterAt(
      Widget child, double totalWidth, double anchorX) {
    if (totalWidth == 0) return child;
    // 将反馈的中心对齐到光标处：左移 (反馈中心X - 抓手锚点X)
    final double shiftLeft = (totalWidth / 2) - anchorX;
    return Transform.translate(
      offset: Offset(-shiftLeft, 0),
      child: child,
    );
  }

  // Calculate full row feedback width: left title + all columns
  double _rowFeedbackTotalWidth(List<Tuple2<String, JiaZi>> pillars) {
    return rowTitleWidth + _totalColsWidth(pillars);
  }

  // Calculate full column feedback height: header + all row heights
  double _columnFeedbackTotalHeight(List<String> rows) {
    // 检查 rows[0] 是否为表头行
    final rowPayloads = widget.rowListNotifier.value;
    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
        rowPayloads[0].rowType == RowType.columnHeaderRow;

    double total = 0.0;
    for (int i = 0; i < rows.length; i++) {
      if (i == 0) {
        // 如果 rows[0] 是表头行，使用 columnTitleHeight，否则使用实际行高
        total +=
            isRows0HeaderRow ? columnTitleHeight : _rowHeightByName(rows[i]);
      } else {
        total += _rowHeightByName(rows[i]);
      }
    }
    return total;
  }

  // Offset feedback up by a given height so content appears above cursor
  Widget _offsetFeedbackUp(Widget child, double dy) {
    if (dy == 0) return child;
    return Transform.translate(
      offset: Offset(0, -dy),
      child: child,
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
            left: 6,
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
    final list = List<PillarPayload>.of(widget.pillarsNotifier.value);
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
    widget.pillarsNotifier.value = List<PillarPayload>.of(list);

    // 根据移动行为重映射列宽覆盖索引，保持覆盖与列位置一致
    _remapColumnOverridesOnMove(fromIdx, target);
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

  // 基于列 TitlePayload（按 PillarType）进行列重排
  void _reorderColumnsByType(PillarType type, int insertIndex) {
    final list = List<PillarPayload>.of(widget.pillarsNotifier.value);
    final fromIdx = list.indexWhere((p) => p.pillarType == type);
    if (fromIdx < 0) return;
    _reorderColumns(fromIdx, insertIndex);
  }

  /// 重映射列宽覆盖映射：在列重排时保持覆盖键与新索引同步。
  ///
  /// 参数：
  /// - fromIdx: 原始列索引。
  /// - targetIdx: 新的插入索引（已考虑移除后的偏移）。
  /// 返回：无；直接更新 `_columnWidthOverrides`。
  void _remapColumnOverridesOnMove(int fromIdx, int targetIdx) {
    final moved = _columnWidthOverrides[fromIdx];
    final Map<int, double> afterRemoval = {};
    for (final entry in _columnWidthOverrides.entries) {
      final k = entry.key;
      if (k == fromIdx) continue;
      final nk = k > fromIdx ? k - 1 : k;
      afterRemoval[nk] = entry.value;
    }
    final Map<int, double> finalMap = {};
    for (final entry in afterRemoval.entries) {
      final k = entry.key;
      final nk = k >= targetIdx ? k + 1 : k;
      finalMap[nk] = entry.value;
    }
    if (moved != null) {
      finalMap[targetIdx] = moved;
    }
    _columnWidthOverrides
      ..clear()
      ..addAll(finalMap);
  }

  void _insertExternalPillar(int insertIndex, PillarPayload payload) {
    // 若无核心 PillarContent，则补齐：生成唯一 id 与 JiaZi，确保参与行策略计算（如纳音）。
    if (payload.pillarContent == null &&
        payload.pillarType != PillarType.separator) {
      final id = _allocatePillarId(payload.pillarType);
      final label = _pillarLabelFromPayload(payload);
      final jz = _pillarJiaZiFromPayload(payload);
      final content = PillarContent(
        id: id,
        pillarType: payload.pillarType,
        label: label,
        jiaZi: jz,
        description: null,
        version: '1',
        sourceKind: PillarSourceKind.userInput,
        operationType: payload.pillarType == PillarType.luckCycle
            ? PillarOperationType.daYun
            : null,
      );
      payload = payload.copyWith(pillarContent: content);
    }

    final list = List<PillarPayload>.of(widget.pillarsNotifier.value);
    final target = insertIndex.clamp(0, list.length);
    list.insert(target, payload);
    widget.pillarsNotifier.value = list;

    // 持久化列宽覆盖：非分隔列按载荷提供的宽度（若有）记录覆盖，用于重排反馈
    if (payload.pillarType != PillarType.separator) {
      final double w = payload.resolveWidth(
        defaultWidth: pillarWidth,
        minWidth: _minPillarWidth,
        maxWidth: _maxPillarWidth,
      );
      _columnWidthOverrides[target] = w;
    }

    // Trigger drop animation similar to internal reorder
    setState(() {
      _draggingColumnIndex = null;
      _hoverColumnInsertIndex = null;
      _lastColInsertIndex = null;
      _dropAnimatingColIndex = target;
      _dropColFadeActive = true;
    });
    Future.microtask(() {
      if (!mounted) return;
      setState(() {
        _dropColFadeActive = false;
      });
    });
    Future.delayed(const Duration(milliseconds: 240), () {
      if (!mounted) return;
      setState(() {
        _dropAnimatingColIndex = null;
      });
    });
  }

  /// 根据 `PillarType` 插入外部柱（简单映射标签与默认甲子）。
  ///
  /// 参数：
  /// - insertIndex: 目标插入位置（0..当前列数）。
  /// - type: 外部拖拽传入的柱类型（如年、月、日、时等）。
  /// 返回：
  /// - 无返回值。函数会直接更新 `jiaZiNotifier` 并触发一次轻量的淡入动画。
  void _insertExternalPillarFromType(int insertIndex, PillarType type) {
    String label;
    switch (type) {
      case PillarType.year:
        label = '年';
        break;
      case PillarType.month:
        label = '月';
        break;
      case PillarType.day:
        label = '日';
        break;
      case PillarType.hour:
        label = '时';
        break;
      case PillarType.separator:
        label = '列分隔符';
        break;
      default:
        label = type.name;
        break;
    }
    final list = List<PillarPayload>.of(widget.pillarsNotifier.value);
    final target = insertIndex.clamp(0, list.length);
    // 直接根据类型创建基础 PillarContent，默认 JiaZi 使用甲子占位，确保策略可运行。
    final content = (type == PillarType.separator)
        ? null
        : PillarContent(
            id: _allocatePillarId(type),
            pillarType: type,
            label: label,
            jiaZi: JiaZi.JIA_ZI,
            description: null,
            version: '1',
            sourceKind: PillarSourceKind.userInput,
            operationType:
                type == PillarType.luckCycle ? PillarOperationType.daYun : null,
          );
    list.insert(
        target,
        PillarPayload(
          pillarType: type,
          pillarLabel: label,
          pillarContent: content,
        ));
    widget.pillarsNotifier.value = list;

    // 触发与内部重排一致的插入淡入动画
    setState(() {
      _draggingColumnIndex = null;
      _hoverColumnInsertIndex = null;
      _lastColInsertIndex = null;
      _dropAnimatingColIndex = target;
      _dropColFadeActive = true;
    });
    Future.microtask(() {
      if (!mounted) return;
      setState(() {
        _dropColFadeActive = false;
      });
    });
    Future.delayed(const Duration(milliseconds: 240), () {
      if (!mounted) return;
      setState(() {
        _dropAnimatingColIndex = null;
      });
    });
  }

  void _reorderRows(int fromAbsIdx, int insertIndex) {
    // Rows include header row at index 0; now allow reordering from index 0
    final rows = List<RowInfoPayload>.of(widget.rowListNotifier.value);
    if (fromAbsIdx < 0 || fromAbsIdx >= rows.length) return; // 允许索引0
    // Insert index in [0..rows.length]
    final item = rows.removeAt(fromAbsIdx);
    var target = insertIndex;
    if (insertIndex > fromAbsIdx) {
      target = insertIndex - 1;
    }
    target = target.clamp(0, rows.length); // 允许插入到索引0
    rows.insert(target, item);
    widget.rowListNotifier.value = List<RowInfoPayload>.of(rows);

    // 根据移动行为重映射行高覆盖索引，保持覆盖与行位置一致
    _remapRowOverridesOnMove(fromAbsIdx, target);
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

  /// 基于行标题载荷（按 RowType 与可选 label）进行行重排。
  ///
  /// 参数：
  /// - [t]: 标题行载荷（继承自 RowInfoPayload）。
  /// - [insertIndex]: 目标插入索引（>=1）。
  /// 返回：无；直接执行重排与状态更新。
  void _reorderRowsByTitlePayload(TitleRowPayload t, int insertIndex) {
    final rows = List<RowInfoPayload>.of(widget.rowListNotifier.value);
    int fromAbsIdx = -1;
    for (int i = 0; i < rows.length; i++) {
      final rp = rows[i];
      final label = rp.rowLabel ?? rp.rowType.name;
      if (rp.rowType == t.rowType &&
          (t.rowLabel == null || t.rowLabel == label)) {
        fromAbsIdx = i;
        break;
      }
    }
    if (fromAbsIdx < 0) return; // 未找到，直接返回
    _reorderRows(fromAbsIdx, insertIndex);
  }

  /// 重映射行高覆盖映射：在行重排时保持覆盖键与新索引同步。
  ///
  /// 参数：
  /// - fromAbsIdx: 原始行索引（绝对索引，>=1）。
  /// - targetIdx: 新的插入索引（>=1，已考虑移除后的偏移）。
  /// 返回：无；直接更新 `_rowHeightOverrides`。
  void _remapRowOverridesOnMove(int fromAbsIdx, int targetIdx) {
    final moved = _rowHeightOverrides[fromAbsIdx];
    final Map<int, double> afterRemoval = {};
    for (final entry in _rowHeightOverrides.entries) {
      final k = entry.key;
      if (k == fromAbsIdx) continue;
      final nk = k > fromAbsIdx ? k - 1 : k;
      afterRemoval[nk] = entry.value;
    }
    final Map<int, double> finalMap = {};
    for (final entry in afterRemoval.entries) {
      final k = entry.key;
      final nk = k >= targetIdx ? k + 1 : k;
      finalMap[nk] = entry.value;
    }
    if (moved != null) {
      finalMap[targetIdx] = moved;
    }
    _rowHeightOverrides
      ..clear()
      ..addAll(finalMap);
  }

  // --- UI helpers ---
  double _rowHeightByName(String name) {
    // 优先通过对应行的 payload 解析高度（行类型/label 有歧义时以 payload 行为为准）
    final payload = _findRowPayloadByName(name);
    if (payload != null) {
      return payload.resolveHeight(
        heavenlyAndEarthlyHeight: ganZhiCellSize.height,
        otherHeight: otherCellHeight,
        dividerHeight: _rowDividerHeightEffective,
      );
    }
    // 兜底：按名称语义进行高度推断
    if (name == '天干' || name == '地支') return ganZhiCellSize.height;
    if (_isSeparatorRowLabel(name)) return _rowDividerHeightEffective;
    return otherCellHeight;
  }

  /// 根据行名称在当前行列表中查找对应的 `RowInfoPayload`。
  /// 优先使用 `rowLabel` 匹配，其次回退到 `rowType.name`。
  RowInfoPayload? _findRowPayloadByName(String name) {
    for (final p in widget.rowListNotifier.value) {
      final label = p.rowLabel ?? p.rowType.name;
      if (label == name) return p;
    }
    return null;
  }

  Size _rowCellSize(String rowName) {
    final h = _rowHeightByName(rowName);
    return Size(rowTitleWidth, h);
  }

  Widget _cell(Size size, Widget child) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        border: Border.all(color: Colors.black12, width: 0.5),
        borderRadius: BorderRadius.zero, // 移除圆角，消除单元格间的视觉间隙
      ),
      child: Center(child: child),
    );
  }

  // Build full column feedback (title + all rows) for smoother whole-column drag perception
  /// 构建整列拖拽反馈视图（包含列标题与所有行单元格）。
  ///
  /// 参数：
  /// - title: 列标题文本。
  /// - jz: 列对应的甲子数据对象（动态类型，包含天干/地支等）。
  /// - rows: 行名称列表（包含标题行与数据行）。
  /// 返回：
  /// - Widget：用于 LongPressDraggable 的反馈组件。
  /// 构建整列拖拽反馈视图（包含列标题与所有行单元格）。
  ///
  /// 参数：
  /// - title: 列标题文本。
  /// - jz: 列对应的甲子数据对象。
  /// - rows: 行名称列表（包含标题行与数据行）。
  /// - widthOverride: 可选的列宽覆盖值，用于在拖拽反馈中体现实际列宽。
  /// 返回：
  /// - Widget：用于 LongPressDraggable 的反馈组件。
  Widget _buildFullColumnFeedback(String title, dynamic jz, List<String> rows,
      {double? widthOverride}) {
    // 当拖拽的是“列分隔符”，仅显示垂直细线作为反馈
    final bool isSeparatorColumn =
        title == '分隔符' || title == '列分隔符' || title == '|';
    if (isSeparatorColumn) {
      // 使用已修复的 _columnFeedbackTotalHeight
      double totalHeight = _columnFeedbackTotalHeight(rows);
      return Container(
        width: _colDividerThickness,
        height: totalHeight,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      );
    }

    // 检查 rows[0] 是否为表头行
    final rowPayloads = widget.rowListNotifier.value;
    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
        rowPayloads[0].rowType == RowType.columnHeaderRow;

    // Compute total height: header + sum of each row height
    double totalHeight = _columnFeedbackTotalHeight(rows);

    final double feedbackWidth = widthOverride ?? pillarWidth;
    return Container(
      width: feedbackWidth,
      height: totalHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 只有当 rows[0] 是表头行时才渲染列标题
          if (isRows0HeaderRow)
            _cell(Size(feedbackWidth, columnTitleHeight),
                _dragHandle(_columnTitleText(title))),
          // 渲染所有行（如果 rows[0] 不是表头行，也包括它）
          ...rows.asMap().entries.where((entry) {
            // 如果 rows[0] 是表头行，跳过它（已在上面渲染为列标题）
            return !(entry.key == 0 && isRows0HeaderRow);
          }).map((entry) {
            final rowName = entry.value;
            if (rowName == '天干') {
              return _cell(Size(feedbackWidth, ganZhiCellSize.height),
                  _tianGanText(jz.tianGan));
            } else if (rowName == '地支') {
              return _cell(Size(feedbackWidth, ganZhiCellSize.height),
                  _diZhiText(jz.diZhi));
            } else if (rowName == '纳音') {
              return _cell(Size(feedbackWidth, otherCellHeight),
                  _naYinText(jz.naYinStr));
            } else if (_isSeparatorRowLabel(rowName)) {
              return Container(
                width: feedbackWidth,
                height: _rowDividerHeightEffective,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: _rowDividerThickness,
                    ),
                  ),
                ),
              );
            } else {
              return _cell(Size(feedbackWidth, otherCellHeight),
                  _columnTitleText(title));
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
  /// 根据左侧标题区域的局部 y 坐标计算离散插入索引。
  ///
  /// 参数：
  /// - dy: 局部坐标系下的 y 值（像素）。
  /// - rows: 行名称列表（索引 0 为标题行，跳过）。
  /// 返回：
  /// - int：插入索引（范围 [1..rows.length]）。
  int _computeRowInsertIndexFromDy(double dy, List<String> rows) {
    // 逐行累计高度，首行（索引0）为标题行，不参与重排
    // 从 0 开始累积，因为 dy 是相对于不包含表头行的组件的局部坐标
    double acc = 0.0;
    int insertIndex = 1; // 最小为 1
    for (final entry in rows.asMap().entries) {
      final idx = entry.key;
      final name = entry.value;
      if (idx == 0) continue;
      final h = _rowHeightByName(name);
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
  /// 根据局部 y 计算“分数插入位置”，用于行的连续让位插值。
  ///
  /// 参数：
  /// - dy: 局部坐标系下的 y 值（像素）。
  /// - rows: 行名称列表（索引 0 为标题行，跳过）。
  /// 返回：
  /// - double：分数插入位（范围 [1.0..rows.length]）。
  double _computeRowInsertFloatFromDy(double dy, List<String> rows) {
    // 从 0 开始累积，因为 dy 是相对于不包含表头行的组件的局部坐标
    double acc = 0.0;
    double floatPos = 1.0; // 最小为 1.0
    for (final entry in rows.asMap().entries) {
      final idx = entry.key;
      final name = entry.value;
      if (idx == 0) continue; // 跳过标题行
      final h = _rowHeightByName(name);
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

  // Midpoint-based insert index from local dy for rows (gap in [0..rows.length])
  /// 基于行绿线/蓝线的插入索引计算，确保只有进入间隙才触发。
  ///
  /// 参数：
  /// - dy: 局部坐标系下的 y 值（像素）。
  /// - rows: 行名称列表（索引 0 可能为表头行）。
  /// 返回：
  /// - int：插入索引（范围 [0..rows.length]，0表示在表头行之前）。
  int _computeRowInsertIndexFromDyMidpoint(double dy, List<String> rows) {
    // dy 是相对于 gripColumn/leftHeader 的局部坐标
    // 检查 rows[0] 是否为表头行
    final rowPayloads = widget.rowListNotifier.value;
    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
        rowPayloads[0].rowType == RowType.columnHeaderRow;

    // 累积高度从0开始，允许插入到表头行之前
    double acc = 0.0;
    int insertIndex = 0; // 最小为 0，允许插入到表头行之前

    for (final entry in rows.asMap().entries) {
      final idx = entry.key;
      final name = entry.value;

      // 当 idx == 0 时，检查是否为表头行
      if (idx == 0 && isRows0HeaderRow) {
        final h = columnTitleHeight;
        final midLine = acc + h / 2; // 红线：中点
        if (dy < midLine) {
          insertIndex = 0; // 在表头行之前插入
          break;
        }
        acc += h;
        insertIndex = 1; // 默认在表头行之后
        continue;
      }

      final h = _rowHeightByName(name);
      final midLine = acc + h / 2; // 红线：中点
      if (dy < midLine) {
        insertIndex = idx; // 红线以上：插入到该行之前
        break;
      }
      acc += h;
      insertIndex = idx + 1; // 红线以下：默认插入到该行之后
    }
    return insertIndex.clamp(0, rows.length);
  }

  // 返回行索引 `idx` 的中点 Y（局部坐标），用于滞回判断
  // 索引范围为数据行索引（>=0），包含表头行
  /// 返回行索引 `idx` 的中点 Y（局部坐标），用于边界滞回判断。
  ///
  /// 参数：
  /// - idx: 行索引（>=0，包含表头行）。
  /// - rows: 行名称列表。
  /// 返回：
  /// - double：该行中点的局部 y 值（像素）。
  double _rowBoundaryMidY(int idx, List<String> rows) {
    // 返回的是相对于 gripColumn/leftHeader 的局部坐标
    // 检查 rows[0] 是否为表头行
    final rowPayloads = widget.rowListNotifier.value;
    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
        rowPayloads[0].rowType == RowType.columnHeaderRow;

    // 累积高度从0开始，允许计算表头行的中点
    double acc = 0.0;

    for (final entry in rows.asMap().entries) {
      final i = entry.key;
      final name = entry.value;

      // 当 i == 0 时，检查是否为表头行
      if (i == 0 && isRows0HeaderRow) {
        final h = columnTitleHeight;
        if (idx == 0) {
          return acc + h / 2.0; // 返回表头行的中点
        }
        acc += h;
        continue;
      }

      final h = _rowHeightByName(name);
      if (i == idx) {
        return acc + h / 2.0;
      }
      acc += h;
    }

    // 特殊处理：当 idx == rows.length 时（表示在最后一行之后插入）
    // 返回最后一行底部边缘 + 幽灵占位高度的一半作为虚拟中点
    if (idx == rows.length && rows.isNotEmpty) {
      final lastIdx = rows.length - 1;
      final lastRowHeight = _rowHeightByName(rows[lastIdx]);
      return acc + lastRowHeight / 2.0; // 虚拟中点：底部边缘 + 半个行高
    }

    return acc; // fallback 到底部中点之外，理论上不应命中
  }

  // Build full row feedback (row title + cells across all columns)
  /// 构建整行拖拽反馈视图（包含行标题与跨所有列的单元格）。
  ///
  /// 参数：
  /// - rowName: 行名称（如“天干”、“地支”、“分割线”等）。
  /// - pillars: 跨所有列的 (列标题, JiaZi) 二元组列表。
  /// 返回：
  /// - Widget：用于 Draggable 的反馈组件。
  /// 构建整行拖拽反馈视图（包含行标题与跨所有列的单元格）。
  ///
  /// 参数：
  /// - rowName: 行名称（如“天干”、“地支”、“分割线”等）。
  /// - pillars: 跨所有列的 (列标题, JiaZi) 二元组列表。
  /// - absRowIndex: 可选的行绝对索引（>=1），用于读取行高覆盖。
  /// 返回：
  /// - Widget：用于 Draggable 的反馈组件。
  Widget _buildFullRowFeedback(
      String rowName, List<Tuple2<String, JiaZi>> pillars,
      {int? absRowIndex}) {
    // 当拖拽的是“行分割线”，仅显示水平细线作为反馈
    final bool isRowSeparator = _isSeparatorRowLabel(rowName);
    if (isRowSeparator) {
      final totalW = _totalColsWidth(pillars);
      return Container(
        width: totalW,
        height: _rowDividerHeightEffective,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      );
    }
    final isGan = rowName == '天干';
    final isZhi = rowName == '地支';
    final double rowH =
        (absRowIndex != null && _rowHeightOverrides[absRowIndex] != null)
            ? _rowHeightOverrides[absRowIndex]!
            : _rowHeightByName(rowName);
    print('🎯 [反馈高度] rowName=$rowName, absRowIndex=$absRowIndex, override=${absRowIndex != null ? _rowHeightOverrides[absRowIndex] : 'N/A'}, byName=${_rowHeightByName(rowName)}, final=$rowH');
    final totalW = rowTitleWidth + _totalColsWidth(pillars);

    return Container(
      width: totalW,
      height: rowH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_isSeparatorRowLabel(rowName))
            Container(
              width: rowTitleWidth,
              height: rowH,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: _rowDividerThickness,
                  ),
                ),
              ),
            )
          else
            _cell(
                Size(rowTitleWidth, rowH), _dragHandle(_rowTitleText(rowName))),
          ...pillars.asMap().entries.map((entry) {
            final i = entry.key;
            final tuple = entry.value;
            final jz = tuple.item2;
            final colW = _colWidthAtIndex(i, pillars);
            if (isGan) {
              return _cell(Size(colW, rowH), _tianGanText(jz.tianGan));
            } else if (isZhi) {
              return _cell(Size(colW, rowH), _diZhiText(jz.diZhi));
            } else if (rowName == '纳音') {
              return _cell(Size(colW, rowH), _naYinText(jz.naYinStr));
            } else if (rowName == '空亡') {
              // 空亡行：显示空亡信息
              final kw = jz.getKongWang();
              final text = '${kw.item1.value}${kw.item2.value}';
              return _cell(Size(colW, rowH), _naYinText(text));
            } else if (_isSeparatorRowLabel(rowName)) {
              return Container(
                width: colW,
                height: rowH,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: _rowDividerThickness,
                    ),
                  ),
                ),
              );
            } else {
              return _cell(Size(colW, rowH), _columnTitleText(tuple.item1));
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

  Text _naYinText(String s) => Text(
        s,
        style: const TextStyle(fontSize: 14, color: Colors.amber),
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
      ..color = color.withOpacity(0.5)
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
      ..color = color.withOpacity(0.5)
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

// Visualize row boundaries across the entire card (including header row)
class _RowBoundaryPainter extends CustomPainter {
  final List<double> midYs; // midpoints for all rows (including header)
  final double cardWidth;
  final Color color;
  final double hysteresisPx; // hysteresis margin for yielding trigger

  const _RowBoundaryPainter({
    required this.midYs,
    required this.cardWidth,
    required this.color,
    this.hysteresisPx = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 中点线（红色实线）- 每行中心，作为让位触发边界
    final midPaint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (final midY in midYs) {
      // 绘制中点参考线（红色）- 直接作为插入位判定边界
      canvas.drawLine(Offset(0, midY), Offset(cardWidth, midY), midPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RowBoundaryPainter oldDelegate) {
    return midYs != oldDelegate.midYs ||
        cardWidth != oldDelegate.cardWidth ||
        color != oldDelegate.color ||
        hysteresisPx != oldDelegate.hysteresisPx;
  }
}
