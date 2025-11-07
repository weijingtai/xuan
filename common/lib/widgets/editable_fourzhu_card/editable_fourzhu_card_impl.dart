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
import 'widgets/ghost_pillar_widget.dart'; // 幽灵柱占位 Widget
import 'text_groups.dart';

// Removed palette-based coloring; group font color applies when colorfulMode is enabled.
// Sentinel RGB used to indicate shadow follows the character color
const int _kShadowFollowSentinelRGB = 0x00FEED;

/// EditableFourZhuCardV3
/// 单视图、双轴拖拽：在同一个网格视图中完成行与列的重排，不再依赖两个 ReorderableListView。
class EditableFourZhuCardV3 extends StatefulWidget {
  final ValueNotifier<List<PillarPayload>> pillarsNotifier;
  final ValueNotifier<List<RowInfoPayload>> rowListNotifier;
  final ValueNotifier<EdgeInsets> paddingNotifier;
  final Gender gender;
  // Optional: override root card decoration (background, radius, etc.)
  final BoxDecoration? cardDecoration;
  // Optional: global pillar decoration: margin/padding/border style
  // Used to compute dynamic decoration width/height and align grip/header columns
  final EdgeInsets? pillarMargin;
  final EdgeInsets? pillarPadding;
  final double? pillarBorderWidth;
  final Color? pillarBorderColor;
  final double? pillarCornerRadius;
  final Color? pillarBackgroundColor;
  // Optional: global typography overrides for V3 rendering
  // When provided, these values will override internal hard-coded TextStyles
  // Optional: per-group text style overrides; takes precedence over global typography.
  final Map<TextGroup, TextStyle>? groupTextStyles;
  final String? globalFontFamily;
  final double? globalFontSize;
  final Color? globalFontColor;
  // Optional: per-character color overrides (applied in pure color mode)
  // Keyed by the literal character, e.g., '甲', '乙', '子', '丑'.
  final Map<String, Color>? perCharColors;
  // New: toggle visibility of end grip rows and columns
  // When disabled, the visual grip rows/columns are hidden from the card.
  final bool showGripRows;
  final bool showGripColumns;
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
  // Card-level colorful mode: when true, use per-token palette colors
  final bool colorfulMode;

  /// Optional pillar container box shadows.
  final List<BoxShadow>? pillarBoxShadow;

  const EditableFourZhuCardV3({
    super.key,
    required this.pillarsNotifier,
    required this.rowListNotifier,
    required this.paddingNotifier,
    required this.gender,
    this.cardDecoration,
    this.pillarMargin,
    this.pillarPadding,
    this.pillarBorderWidth,
    this.pillarBorderColor,
    this.pillarCornerRadius,
    this.pillarBackgroundColor,
    this.pillarBoxShadow,
    this.groupTextStyles,
    this.globalFontFamily,
    this.globalFontSize,
    this.globalFontColor,
    this.perCharColors,
    this.dragFeedbackBuilder,
    this.columnInsertDecorationBuilder,
    this.rowInsertDecorationBuilder,
    this.debugHysteresisOverlay = false,
    this.colorfulMode = false,
    this.showGripRows = true,
    this.showGripColumns = true,
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

  // 动态柱装饰参数与派生尺寸
  /// 有效柱边距（优先使用传入的值，默认 8 全向）
  EdgeInsets get _pillarMarginEff =>
      widget.pillarMargin ?? const EdgeInsets.all(8.0);

  /// 每列的有效边距：优先使用对应列的 `payload.columnMargin`，否则退回全局。
  EdgeInsets _pillarMarginAtIndex(int i) {
    final payloads = widget.pillarsNotifier.value;
    if (i >= 0 && i < payloads.length) {
      final m = payloads[i].columnMargin;
      if (m != null) return m;
    }
    return _pillarMarginEff;
  }

  /// 有效柱内边距（优先使用传入的值，默认 16 全向）
  EdgeInsets get _pillarPaddingEff =>
      widget.pillarPadding ?? const EdgeInsets.all(16.0);

  /// 有效柱边框宽度（优先使用传入的值，默认 2）
  double get _pillarBorderWidthEff => widget.pillarBorderWidth ?? 2.0;

  /// 有效柱边框颜色（优先使用传入的值，默认 Colors.red）
  Color get _pillarBorderColorEff => widget.pillarBorderColor ?? Colors.red;

  /// 有效柱圆角（优先使用传入的值，默认 0）
  double get _pillarCornerRadiusEff => widget.pillarCornerRadius ?? 0.0;

  /// 有效柱背景色（优先使用传入的值，默认透明）
  Color get _pillarBackgroundColorEff =>
      widget.pillarBackgroundColor ?? Colors.transparent;

  /// 装饰总宽度（左右 margin + padding + border）
  double get _pillarDecorationWidthEff =>
      _pillarMarginEff.left +
      _pillarMarginEff.right +
      _pillarPaddingEff.left +
      _pillarPaddingEff.right +
      _pillarBorderWidthEff * 2;

  /// 指定列的装饰总宽度（使用每列边距覆盖）
  double _pillarDecorationWidthAtIndex(int i) {
    final m = _pillarMarginAtIndex(i);
    return m.left +
        m.right +
        _pillarPaddingEff.left +
        _pillarPaddingEff.right +
        _pillarBorderWidthEff * 2;
  }

  /// 指定列的装饰总高度（使用每列边距覆盖）
  double _pillarDecorationHeightAtIndex(int i) {
    final m = _pillarMarginAtIndex(i);
    return m.top +
        m.bottom +
        _pillarPaddingEff.top +
        _pillarPaddingEff.bottom +
        _pillarBorderWidthEff * 2;
  }

  /// 装饰总高度（上下 margin + padding + border）
  double get _pillarDecorationHeightEff =>
      _pillarMarginEff.top +
      _pillarMarginEff.bottom +
      _pillarPaddingEff.top +
      _pillarPaddingEff.bottom +
      _pillarBorderWidthEff * 2;

  /// 顶部装饰偏移（margin-top + padding-top + border-top）
  double get _pillarDecorationTopOffsetEff => _pixelFloor(
      _pillarMarginEff.top + _pillarPaddingEff.top + _pillarBorderWidthEff);

  /// 底部装饰偏移（border-bottom + padding-bottom + margin-bottom）
  double get _pillarDecorationBottomOffsetEff =>
      _pixelFloor(_pillarBorderWidthEff +
          _pillarPaddingEff.bottom +
          _pillarMarginEff.bottom);

  // 卡片边框厚度（水平/垂直）合计，用于在整体尺寸中加上边框占用的空间，避免内容被裁剪或溢出。
  double get _cardBorderHorizontalEff {
    final border = widget.cardDecoration?.border;
    if (border == null) return 0.0;
    final dimsGeo = border.dimensions; // EdgeInsetsGeometry
    final dims = dimsGeo is EdgeInsets
        ? dimsGeo
        : dimsGeo.resolve(Directionality.of(context));
    return dims.left + dims.right;
  }

  double get _cardBorderVerticalEff {
    final border = widget.cardDecoration?.border;
    if (border == null) return 0.0;
    final dimsGeo = border.dimensions; // EdgeInsetsGeometry
    final dims = dimsGeo is EdgeInsets
        ? dimsGeo
        : dimsGeo.resolve(Directionality.of(context));
    return dims.top + dims.bottom;
  }

  // 将逻辑尺寸向下对齐到物理像素，减少由于子像素导致的 RenderFlex 溢出告警
  double _pixelFloor(double logical) {
    final double dpr = ui.window.devicePixelRatio;
    final double physical = (logical * dpr).floorToDouble();
    return physical / dpr;
  }

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

  // 尺寸管理系统：集中管理所有尺寸计算，自动处理索引重映射
  late ValueNotifier<CardLayoutModel> _layoutNotifier;
  late MeasurementContext _measurementContext;
  late VoidCallback _layoutModelSyncListener; // 用于同步数据到布局模型

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
          return _pixelFloor(override.clamp(_minPillarWidth, _maxPillarWidth) +
              _pillarDecorationWidthAtIndex(i));
        }
        return _pixelFloor((p.columnWidth ?? rowTitleWidth) +
            _pillarDecorationWidthAtIndex(i));
      }
    }

    // 分隔列：统一使用分隔列的有效窄宽度（不添加装饰）
    if (_isSeparatorColumnIndex(i))
      return _pixelFloor(_colDividerWidthEffective);

    // 添加边界检查：避免访问幽灵列（i >= pillars.length）时发生索引越界
    if (i < 0 || i >= pillars.length) {
      // 幽灵列默认使用标准柱宽
      return _pixelFloor(pillarWidth + _pillarDecorationWidthAtIndex(i));
    }

    // 检查列宽度覆盖
    final override = _columnWidthOverrides[i];
    if (override != null && override.isFinite && !override.isNaN) {
      return _pixelFloor(override.clamp(_minPillarWidth, _maxPillarWidth) +
          _pillarDecorationWidthAtIndex(i));
    }
    // 当未设置显式覆盖时，优先依据对应列的载荷信息解析列宽
    // 以保证宽度来源统一由 payload 控制（如拖入外部列或预设列宽）。
    if (i >= 0 && i < payloads.length) {
      final p = payloads[i];
      return _pixelFloor(p.resolveWidth(
            defaultWidth: pillarWidth,
            minWidth: _minPillarWidth,
            maxWidth: _maxPillarWidth,
          ) +
          _pillarDecorationWidthAtIndex(i));
    }
    return _pixelFloor(pillarWidth + _pillarDecorationWidthAtIndex(i));
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
    return _pixelFloor(acc);
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

  /// 当“抓手显示/隐藏”触发尺寸变化时，优先使用居中对齐以获得更顺滑的动画；
  /// 其他情况（如外部柱/行悬停导致容器扩展）则使用顶部起始对齐。
  bool _preferCenterAlignment = false;

  // Drag feedback status notifiers: control dynamic "插入"/"删除" prompts on the dragged piece itself
  // When hovering a valid insert target inside the card, set insert=true, delete=false
  // When leaving card targets (outside card), set delete=true, insert=false
  final ValueNotifier<bool> _dragWantsInsert = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _dragWantsDelete = ValueNotifier<bool>(false);
  // Guard to prevent double-accept across overlapping DragTargets
  bool _rowAccepting = false;

  // Hysteresis margins to reduce jitter near boundaries
  static const double _colHysteresisFrac =
      0.12; // fraction of pillarWidth (12%)
  static const double _rowHysteresisFrac = 0.15; // fraction of row height (15%)

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

    // 从当前数据构建布局模型（保留现有覆盖值）
    _layoutNotifier = ValueNotifier(
      CardLayoutModel.fromNotifiers(
        pillars: widget.pillarsNotifier.value,
        rows: widget.rowListNotifier.value,
        padding: widget.paddingNotifier.value,
        columnWidthOverrides: _columnWidthOverrides,
        rowHeightOverrides: _rowHeightOverrides,
        // 抓手尺寸按可见性进行“有效尺寸”置零，确保尺寸实时变化
        dragHandleRowHeight: widget.showGripRows ? dragHandleRowHeight : 0.0,
        dragHandleColWidth: widget.showGripColumns ? dragHandleColWidth : 0.0,
      ),
    );

    // 初始化尺寸通知器，使用包含装饰的尺寸计算
    _sizeNotifier = ValueNotifier<Size>(
      _computeSizeWithDecorations(),
    );

    // 统一监听器：同步更新布局模型和尺寸
    _layoutModelSyncListener = () {
      _layoutNotifier.value = CardLayoutModel.fromNotifiers(
        pillars: widget.pillarsNotifier.value,
        rows: widget.rowListNotifier.value,
        padding: widget.paddingNotifier.value,
        columnWidthOverrides: _columnWidthOverrides,
        rowHeightOverrides: _rowHeightOverrides,
        // 抓手尺寸按可见性进行“有效尺寸”置零，确保尺寸实时变化
        dragHandleRowHeight: widget.showGripRows ? dragHandleRowHeight : 0.0,
        dragHandleColWidth: widget.showGripColumns ? dragHandleColWidth : 0.0,
      );
      // 同步更新尺寸（包含装饰）
      _sizeNotifier.value = _computeSizeWithDecorations();
    };
    widget.pillarsNotifier.addListener(_layoutModelSyncListener);
    widget.rowListNotifier.addListener(_layoutModelSyncListener);
    widget.paddingNotifier.addListener(_layoutModelSyncListener);
  }

  /// 在父组件传入的属性发生变化时同步更新布局模型与尺寸
  ///
  /// 功能描述：
  /// - 当 `showGripRows` 或 `showGripColumns` 开关变化时，实时将抓手的“有效尺寸”置零或恢复，
  ///   并刷新 `_layoutNotifier` 与 `_sizeNotifier`，使 Card 宽高与 UI 同步更新。
  /// 参数说明：
  /// - `oldWidget`: 旧的组件实例，用于对比属性变化。
  /// 返回值：
  /// - 无（方法用于触发内部状态与尺寸的同步更新）。
  @override
  void didUpdateWidget(covariant EditableFourZhuCardV3 oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool rowsVisibilityChanged =
        oldWidget.showGripRows != widget.showGripRows;
    final bool colsVisibilityChanged =
        oldWidget.showGripColumns != widget.showGripColumns;

    if (rowsVisibilityChanged || colsVisibilityChanged) {
      // 抓手显示/隐藏时，切换为居中对齐以提升视觉过渡效果
      _preferCenterAlignment = true;
      // 重新构建布局模型，按可见性设置抓手“有效尺寸”
      _layoutNotifier.value = CardLayoutModel.fromNotifiers(
        pillars: widget.pillarsNotifier.value,
        rows: widget.rowListNotifier.value,
        padding: widget.paddingNotifier.value,
        columnWidthOverrides: _columnWidthOverrides,
        rowHeightOverrides: _rowHeightOverrides,
        dragHandleRowHeight: widget.showGripRows ? dragHandleRowHeight : 0.0,
        dragHandleColWidth: widget.showGripColumns ? dragHandleColWidth : 0.0,
      );

      // 刷新尺寸（包含装饰），确保父级约束与布局实时更新
      _sizeNotifier.value = _computeSizeWithDecorations();
    }
  }

  @override
  void dispose() {
    // 清理监听器
    widget.pillarsNotifier.removeListener(_layoutModelSyncListener);
    widget.rowListNotifier.removeListener(_layoutModelSyncListener);
    widget.paddingNotifier.removeListener(_layoutModelSyncListener);
    _layoutNotifier.dispose();
    _sizeNotifier.dispose();
    _dragWantsInsert.dispose();
    _dragWantsDelete.dispose();

    super.dispose();
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
        // 列幽灵判定：仅外部柱悬停时扩展容器，内部拖拽统一使用网格内让位逻辑
        // 不再为 tCol == pillars.length 特殊扩展容器宽度，所有幽灵列通过 AnimatedContainer 实现
        final bool hasColGhost = _hoveringExternalPillar && !rowDraggingActive;
        // 行幽灵判定：统一使用内部让位逻辑，所有行（包括索引0）使用相同的让位机制
        // 不再需要为 t=0 特殊扩展容器高度，所有幽灵行通过 AnimatedContainer 实现
        final bool hasRowGhost = _hoveringExternalRow;
        // 卡片外部悬停时，幽灵列宽度使用统一计算方法
        final double ghostWidth = _getGhostColumnWidth();
        final double extraColWidth = hasColGhost ? ghostWidth : 0.0;
        // 行幽灵高度：外部行悬停时使用载荷解析高度，确保容器扩展以容纳幽灵行
        final double ghostHeight = hasRowGhost && _externalRowHoverHeight > 0
            ? _externalRowHoverHeight
            : otherCellHeight;
        final double extraRowHeight = hasRowGhost ? ghostHeight : 0.0;
        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOutCubic,
              key: _cardKey,
              width: size.width + extraColWidth,
              height: size.height + extraRowHeight,
              alignment: _preferCenterAlignment
                  ? Alignment.center
                  : AlignmentDirectional.topStart,
              clipBehavior: Clip.hardEdge,
              decoration: widget.cardDecoration ??
                  BoxDecoration(
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
                      // 外部悬停驱动的尺寸扩展：回到顶部起始对齐
                      _preferCenterAlignment = false;
                      if (data is PillarPayload || data is PillarType) {
                        _hoveringExternalPillar = true;
                        // 设置默认插入索引为末尾，onMove会更新为实际位置
                        final pillars = _effectivePillarsTuples();
                        _hoverColumnInsertIndex = pillars.length;
                        _lastColInsertIndex = pillars.length;
                        // 设置外部柱的宽度
                        if (data is PillarPayload) {
                          _externalColHoverWidth =
                              (data.pillarType == PillarType.separator)
                                  ? _colDividerWidthEffective
                                  : data.resolveWidth(
                                      defaultWidth: pillarWidth,
                                      minWidth: _minPillarWidth,
                                      maxWidth: _maxPillarWidth,
                                    );
                        } else if (data is PillarType) {
                          _externalColHoverWidth =
                              (data == PillarType.separator)
                                  ? _colDividerWidthEffective
                                  : pillarWidth;
                        }
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
                  final dx = local.dx -
                      dragHandleColWidth -
                      (hasRowTitleCol ? 0 : rowTitleWidth);
                  final candidate =
                      _computeColumnInsertIndexFromDxVariable(dx, pillars);
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

                  // 滞回判断：基于 last 列的实际宽度计算缓冲区
                  final lastColWidth = _colWidthAtIndex(last, pillars);
                  final margin = lastColWidth * _colHysteresisFrac;
                  final midX = _columnBoundaryMidX(last, pillars);

                  bool allowUpdate = false;
                  if (candidate > last) {
                    // 向右拖拽：必须超过 last 列中点 + margin
                    allowUpdate = dx > midX + margin;
                  } else {
                    // 向左拖拽：必须低于 last 列中点 - margin
                    allowUpdate = dx < midX - margin;
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
                final left = dragHandleColWidth +
                    (hasRowTitleCol ? 0 : rowTitleWidth) +
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
                    // 计算所有行的中点Y坐标和高度（包括表头行）
                    final rowPayloads = widget.rowListNotifier.value;
                    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
                        rowPayloads[0].rowType == RowType.columnHeaderRow;

                    final List<double> midYs = [];
                    final List<double> rowHeights = [];
                    final padding = widget.paddingNotifier.value;

                    // 坐标系对齐：从整个卡片顶部开始计算
                    // acc 初始值 = padding.top + topGripRow 高度
                    double acc = padding.top + dragHandleRowHeight;

                    // 添加所有行的中点和高度，表头行使用 columnTitleHeight
                    for (int i = 0; i < rows.length; i++) {
                      final h = (i == 0 && isRows0HeaderRow)
                          ? columnTitleHeight
                          : _rowHeightByName(rows[i]);
                      midYs.add(acc + h / 2);
                      rowHeights.add(h);
                      acc += h;
                    }

                    return CustomPaint(
                      painter: _RowBoundaryPainter(
                        midYs: midYs,
                        rowHeights: rowHeights,
                        cardWidth: size.width + extraColWidth,
                        color: Colors.red.withOpacity(0.08),
                        hysteresisFrac: _rowHysteresisFrac,
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
    double ghostWidth = _getGhostColumnWidth();
    // 统一列让位逻辑：内部拖拽（包括末尾）使用网格内 AnimatedContainer，不扩展容器
    final double extraColWidth = hasColGhost ? ghostWidth : 0.0;
    // 如果存在行标题列则不额外添加 rowTitleWidth（行标题列宽度已包含在 _totalColsWidth 中）
    final totalWidth = (hasRowTitleColumn ? 0 : rowTitleWidth) +
        _totalColsWidth(pillars) +
        extraColWidth;

    // Top Grip row: 顶部抓手行，用于拖拽列
    final topGripRow = SizedBox(
      width: dragHandleColWidth * 2 + totalWidth,
      height: dragHandleRowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧空白单元格（对应 leftGripColumn）
          SizedBox(
            width: dragHandleColWidth,
            height: dragHandleRowHeight,
          ),
          ...List.generate(pillars.length, (i) {
            final bool isSeparatorCol = _isSeparatorColumnIndex(i);
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
                  feedback: _offsetFeedbackDown(
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
                    // 向下偏移握手行高度，使反馈紧邻光标下方
                    dragHandleRowHeight,
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
          // 右侧空白单元格（对应 rightGripColumn）
          SizedBox(
            width: dragHandleColWidth,
            height: dragHandleRowHeight,
          ),
        ],
      ),
    );

    // Bottom Grip row: 底部抓手行，用于拖拽列
    final gripRow = SizedBox(
      width: dragHandleColWidth * 2 + totalWidth,
      height: dragHandleRowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧空白单元格（对应 leftGripColumn）
          SizedBox(
            width: dragHandleColWidth,
            height: dragHandleRowHeight,
          ),
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
                    // 向上偏移整列高度，使反馈完全显示在光标上方
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

    // Left Grip column: 左侧抓手列，用于拖拽行
    // 叠加 DragTarget 覆盖整个抓手列区域，确保行拖拽经过此列也会持续更新插入索引，从而显示幽灵行
    final leftGripColumn = SizedBox(
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

                // 顶部占位：对齐 dataGrid 列装饰的顶部偏移（margin-top + padding-top + border-top）
                children.add(SizedBox(
                  width: dragHandleColWidth,
                  height: _pillarDecorationTopOffsetEff,
                ));

                // 处理数据行（条件跳过表头行索引 0）
                for (final entry in rows.asMap().entries) {
                  final absRowIdx = entry.key;
                  final rowName = entry.value;

                  final rowSize = _rowCellSize(rowName);
                  final bool isSeparatorRow = _isSeparatorRowLabel(rowName);

                  // 统一让位逻辑：所有行（包括索引0）使用相同的让位机制
                  children.add(AnimatedContainer(
                    duration: draggingRow
                        ? const Duration(milliseconds: 180)
                        : Duration.zero,
                    curve: Curves.easeOut,
                    width: dragHandleColWidth,
                    height: draggingRow && t == absRowIdx
                        ? _getGhostRowHeight(fallbackHeight: rowSize.height)
                        : 0,
                    color: draggingRow && t == absRowIdx
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
                              feedback: _offsetFeedbackRight(
                                widget.dragFeedbackBuilder?.call(
                                      context,
                                      _buildFullRowFeedback(rowName, pillars,
                                          absRowIndex: absRowIdx),
                                    ) ??
                                    _statusFeedback(
                                      _buildFullRowFeedback(rowName, pillars,
                                          absRowIndex: absRowIdx),
                                    ),
                                // 向右偏移握手列宽度，使反馈紧邻光标右侧
                                (widget.showGripColumns
                                    ? dragHandleColWidth
                                    : 0.0),
                              ),
                              childWhenDragging: const SizedBox.shrink(),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: const Icon(Icons.drag_indicator,
                                    size: 14, color: Colors.black),
                              ),
                            ),
                          ),
                  ));
                }

                // 底部占位：对齐 dataGrid 列装饰的底部偏移（border-bottom + padding-bottom + margin-bottom）
                children.add(SizedBox(
                  width: dragHandleColWidth,
                  height: _pillarDecorationBottomOffsetEff,
                ));

                return children;
              })(),
            ],
          ),
        ],
      ),
    );

    // Right Grip column: 右侧抓手列，用于拖拽行
    // 叠加 DragTarget 覆盖整个抓手列区域，确保行拖拽经过此列也会持续更新插入索引，从而显示幽灵行
    final gripColumn = Container(
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

                // 顶部占位：对齐 dataGrid 列装饰的顶部偏移（margin-top + padding-top + border-top）
                children.add(SizedBox(
                  width: dragHandleColWidth,
                  height: _pillarDecorationTopOffsetEff,
                ));

                // 处理数据行（条件跳过表头行索引 0）
                for (final entry in rows.asMap().entries) {
                  final absRowIdx = entry.key;
                  final rowName = entry.value;

                  final rowSize = _rowCellSize(rowName);
                  final bool isSeparatorRow = _isSeparatorRowLabel(rowName);

                  // 统一让位逻辑：所有行（包括索引0）使用相同的让位机制
                  children.add(AnimatedContainer(
                    duration: draggingRow
                        ? const Duration(milliseconds: 180)
                        : Duration.zero,
                    curve: Curves.easeOut,
                    width: dragHandleColWidth,
                    height: draggingRow && t == absRowIdx
                        ? _getGhostRowHeight(fallbackHeight: rowSize.height)
                        : 0,
                    color: draggingRow && t == absRowIdx
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
                                // 向左偏移整行宽度，使反馈完全显示在光标左侧
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

                // 底部占位：对齐 dataGrid 列装饰的底部偏移（border-bottom + padding-bottom + margin-bottom）
                children.add(SizedBox(
                  width: dragHandleColWidth,
                  height: _pillarDecorationBottomOffsetEff,
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

                // 顶部占位：对齐 dataGrid 列装饰的顶部偏移（margin-top + padding-top + border-top）
                children.add(SizedBox(
                  width: rowTitleWidth,
                  height: _pillarDecorationTopOffsetEff,
                ));

                for (final entry in rows.asMap().entries) {
                  final absRowIdx = entry.key;
                  final rowName = entry.value;

                  final rowSize = _rowCellSize(rowName);

                  // 统一让位逻辑：所有行（包括索引0）使用相同的让位机制
                  children.add(AnimatedContainer(
                    duration: draggingRow
                        ? const Duration(milliseconds: 180)
                        : Duration.zero,
                    curve: Curves.easeOut,
                    width: rowTitleWidth,
                    height: draggingRow && t == absRowIdx
                        ? _getGhostRowHeight(fallbackHeight: rowSize.height)
                        : 0,
                    color: draggingRow && t == absRowIdx
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

                          // 表头行：显示性别文本（乾造/坤造），普通行：显示行名称
                          final titleWidget =
                              isHeaderRow && rPayload is ColumnHeaderRowPayload
                                  ? _genderText(rPayload.gender)
                                  : _rowTitleText(rowName);

                          // 统一渲染：所有行使用相同的渲染逻辑
                          return _cell(rowSize, Center(child: titleWidget));
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
                          child: cell,
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

                // 底部占位：对齐 dataGrid 列装饰的底部偏移（border-bottom + padding-bottom + margin-bottom）
                children.add(SizedBox(
                  width: rowTitleWidth,
                  height: _pillarDecorationBottomOffsetEff,
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
                    rowHeights: List<double>.generate(
                      rows.length - 1,
                      (i) => _rowHeightByName(rows[i + 1]),
                    ),
                    rowTitleWidth: rowTitleWidth,
                    hysteresisFrac: _rowHysteresisFrac,
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
      // 数据网格总宽按可变列宽总和计算（像素对齐，避免子像素溢出）
      width: _pixelFloor(_totalColsWidth(pillars) + extraColWidth),
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
                final double gridGhostWidth = (d != null)
                    ? _colWidthAtIndex(d, pillars)
                    : _pixelFloor(_getGhostColumnWidth());
                children.add(AnimatedContainer(
                  duration: dragging
                      ? const Duration(milliseconds: 180)
                      : Duration.zero,
                  curve: Curves.easeOut,
                  width: dragging && t == i ? gridGhostWidth : 0,
                  child: dragging && t == i
                      ? GhostPillarWidget.column(
                          width: gridGhostWidth,
                          height: _layoutNotifier.value
                              .totalRowsHeight(_measurementContext),
                        )
                      : const SizedBox.shrink(),
                ));
                if (d == i) continue; // 拖拽中的列不占原位置
                final tuple = pillars[i];
                final jz = tuple.item2;
                final bool isSeparatorColumn = _isSeparatorColumnIndex(i);
                final pillarPayloads = widget.pillarsNotifier.value;
                // 检查当前列是否为行标题列，确保外层宽度与内部单元格宽度一致
                final isRowTitleCol = (i >= 0 && i < pillarPayloads.length) &&
                    pillarPayloads[i].pillarType == PillarType.rowTitleColumn;

                // colW 是内容宽度（不含装饰），装饰会在外层 Container 中添加。
                // 为保持与顶/底部抓手行和总宽计算一致，这里统一通过 _colWidthAtIndex 获取“总列宽”（含装饰），
                // 非分隔列再减去装饰宽度得到内容宽度。这样普通列也能正确应用每列的覆盖宽度。
                final double colW = (() {
                  if (isSeparatorColumn) {
                    return _pixelFloor(_colDividerWidthEffective);
                  }
                  final totalColW = _colWidthAtIndex(i, pillars);
                  // 内容宽度 = 总宽 - 装饰宽度；行标题列与普通列均统一处理。
                  final contentW = totalColW - _pillarDecorationWidthAtIndex(i);
                  // 防御式：避免极端装饰宽度导致内容宽度非正值
                  return contentW > 0 ? _pixelFloor(contentW) : 0.0;
                })();
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
                      final bool draggingRow =
                          dRow != null || _hoveringExternalRow;

                      for (final rEntry in rows.asMap().entries) {
                        final absRowIdx = rEntry.key;
                        final rowName = rEntry.value;

                        final rowSize = _rowCellSize(rowName);
                        // 统一让位逻辑：所有行（包括索引0）使用相同的让位机制
                        rowChildren.add(AnimatedContainer(
                          duration: draggingRow
                              ? const Duration(milliseconds: 180)
                              : Duration.zero,
                          curve: Curves.easeOut,
                          // 行占位宽度使用外层计算的 colW，确保与单元格宽度一致
                          width: colW,
                          height: draggingRow && tRow == absRowIdx
                              ? _getGhostRowHeight(
                                  fallbackHeight: rowSize.height)
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
                            // 普通行与表头行：不允许拖拽，只显示标题
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

                            // 只显示标题，不允许拖拽
                            cell = _cell(
                              Size(colW, rowSize.height),
                              Center(child: titleWidget),
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
                              Size(colW, otherCellHeight), _kongWangText(text));
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
                        child: Container(
                          margin: _pillarMarginAtIndex(i),
                          child: Container(
                            padding: _pillarPaddingEff,
                            decoration: BoxDecoration(
                              color: _pillarBackgroundColorEff,
                              borderRadius:
                                  BorderRadius.circular(_pillarCornerRadiusEff),
                              border: Border.all(
                                color: _pillarBorderColorEff,
                                width: _pillarBorderWidthEff,
                              ),
                              boxShadow: widget.pillarBoxShadow,
                            ),
                            child: SizedBox(
                              width: colW,
                              child: columnContent,
                            ),
                          ),
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
              final double endGhostWidth = (d != null)
                  ? _colWidthAtIndex(d, pillars)
                  : _getGhostColumnWidth();
              children.add(AnimatedContainer(
                duration: dragging
                    ? const Duration(milliseconds: 180)
                    : Duration.zero,
                curve: Curves.easeOut,
                width: dragging && t == pillars.length ? endGhostWidth : 0,
                child: dragging && t == pillars.length
                    ? GhostPillarWidget.column(
                        width: endGhostWidth,
                        height: _layoutNotifier.value
                            .totalRowsHeight(_measurementContext),
                      )
                    : const SizedBox.shrink(),
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

          // 垂直分割线拖拽手柄：调整分割线左侧列的宽度覆盖（仅影响目标列）
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: Stack(
                children: [
                  for (int i = 1; i < pillars.length; i++)
                    Builder(builder: (context) {
                      // 当存在行标题列时，分割线位置不额外叠加 rowTitleWidth
                      final hasRowTitleCol = widget.pillarsNotifier.value.any(
                          (p) => p.pillarType == PillarType.rowTitleColumn);
                      final left = (hasRowTitleCol ? 0 : rowTitleWidth) +
                          _sumColWidthsUpTo(i, pillars) -
                          4;
                      return Positioned(
                        left: left,
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
                                _initialPillarWidth =
                                    _colWidthAtIndex(i - 1, pillars) -
                                        _pillarDecorationWidthAtIndex(i - 1);
                              });
                            },
                            onPanUpdate: (details) {
                              final box = _cardKey.currentContext
                                  ?.findRenderObject() as RenderBox?;
                              if (box == null) return;
                              final idx = _resizingDividerIndex ?? i;
                              if (idx <= 0) return;
                              // 分割线左侧目标列索引
                              final targetCol = idx - 1;
                              // 分隔列不参与宽度调整
                              if (_isSeparatorColumnIndex(targetCol)) return;

                              // 统一基准：全局坐标转卡片局部坐标
                              final local =
                                  box.globalToLocal(details.globalPosition);
                              final hasRowTitleCol2 =
                                  widget.pillarsNotifier.value.any((p) =>
                                      p.pillarType ==
                                      PillarType.rowTitleColumn);
                              final accLeft =
                                  hasRowTitleCol2 ? 0 : rowTitleWidth;
                              final dx = local.dx - accLeft;

                              // 新总宽度 = 当前指针 x 减去左侧列之前所有列宽度累积
                              final sumPrev =
                                  _sumColWidthsUpTo(targetCol, pillars);
                              double newTotalW = dx - sumPrev;

                              // 转换为内容宽度覆盖（扣除装饰宽度），并夹紧到最小/最大内容宽度范围
                              final decW =
                                  _pillarDecorationWidthAtIndex(targetCol);
                              double newContentW = (newTotalW - decW)
                                  .clamp(_minPillarWidth, _maxPillarWidth);

                              setState(() {
                                _columnWidthOverrides[targetCol] = newContentW;
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
        ],
      ),
    );

    // 包裹整个网格的 Stack，使行 DragTarget 覆盖所有区域（包括 topGripRow 和 bottomGripRow）
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部抓手行显示/隐藏动画（垂直尺寸过渡）
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                axis: Axis.vertical,
                child: child,
              ),
              child: widget.showGripRows ? topGripRow : const SizedBox.shrink(),
            ),
            // 行内容区域
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧抓手列显示/隐藏动画（水平尺寸过渡）
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder: (child, animation) => Align(
                    alignment: Alignment.centerLeft,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.horizontal,
                      child: child,
                    ),
                  ),
                  child: widget.showGripColumns
                      ? leftGripColumn
                      : const SizedBox.shrink(),
                ),
                if (!hasRowTitleColumn) leftHeader, // 仅在无行标题列时渲染
                dataGrid,
                // 右侧抓手列显示/隐藏动画（水平尺寸过渡）
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder: (child, animation) => Align(
                    alignment: Alignment.centerRight,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.horizontal,
                      child: child,
                    ),
                  ),
                  child: widget.showGripColumns
                      ? gripColumn
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            // 底部抓手行显示/隐藏动画（垂直尺寸过渡）
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                axis: Axis.vertical,
                child: child,
              ),
              child: widget.showGripRows ? gripRow : const SizedBox.shrink(),
            ),
          ],
        ),
        // 统一的全区域行拖拽 DragTarget：覆盖整个网格（包括 topGripRow 和 bottomGripRow）
        Positioned.fill(
          child: Builder(
            builder: (builderContext) => DragTarget<Object>(
              onWillAccept: (data) {
                final ok = (data is Tuple2 && data.item1 == _DragKind.row) ||
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
                    final rows = _currentRowLabels();
                    setState(() {
                      _hoveringExternalRow = true;
                      _externalRowHoverHeight = _rowHeightByPayload(data);
                      // 设置默认插入索引为末尾，onMove会更新为实际位置
                      _hoverRowInsertIndex = rows.length;
                      _lastRowInsertIndex = rows.length;
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
                // DragTarget 现在覆盖整个 Stack（包括 topGripRow），local.dy = 0 对应 topGripRow 顶部
                // 需要减去 topGripRow 的高度，使 dy 对应行内容区域的开始位置
                final dy = local.dy -
                    (widget.showGripRows ? dragHandleRowHeight : 0.0);
                // 现在 dy = 0 对应 leftGripColumn 顶部（行内容开始）
                // _computeRowInsertIndexFromDyMidpoint 的 acc 也从 0 开始（行内容开始）
                // 两者坐标系一致

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

                // 滞回判断：基于 last 行的高度计算 15% 缓冲区
                final lastRowHeight = _rowHeightByName(rows[last]);
                final margin = lastRowHeight * _rowHysteresisFrac;
                final midY = _rowBoundaryMidY(last, rows);

                bool allowUpdate = false;
                if (candidate > last) {
                  // 向下拖拽：必须超过 last 行中点 + margin
                  allowUpdate = dy > midY + margin;
                } else {
                  // 向上拖拽：必须低于 last 行中点 - margin
                  allowUpdate = dy < midY - margin;
                }

                if (!allowUpdate) return; // 在滞回缓冲区内，不触发切换

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

  // Offset feedback down by a given height so content appears below cursor
  Widget _offsetFeedbackDown(Widget child, double dy) {
    if (dy == 0) return child;
    return Transform.translate(
      offset: Offset(0, dy),
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
        headerHeight: columnTitleHeight, // 添加表头行高度参数
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
          // 渲染所有行，包括标题行
          ...rows.asMap().entries.map((entry) {
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

  /// 返回列索引 `idx` 的中点 X（局部坐标），用于边界滞回判断。
  ///
  /// 参数：
  /// - idx: 列索引（>=0）。
  /// - pillars: 列 (标题, JiaZi) 二元组列表。
  /// 返回：
  /// - double：该列中点的局部 x 值（像素），相对于数据列区域的起始位置。
  double _columnBoundaryMidX(int idx, List<Tuple2<String, JiaZi>> pillars) {
    // 返回的是相对于数据列区域起始位置的局部坐标
    // （已减去 dragHandleColWidth 和 rowTitleWidth）
    double acc = 0.0;

    for (int i = 0; i < pillars.length; i++) {
      final w = _colWidthAtIndex(i, pillars);
      if (i == idx) {
        return acc + w / 2.0; // 返回该列的中点
      }
      acc += w;
    }

    // 特殊处理：当 idx == pillars.length 时（表示在最后一列之后插入）
    // 返回最后一列右边缘 + 幽灵占位宽度的一半作为虚拟中点
    if (idx == pillars.length && pillars.isNotEmpty) {
      final lastIdx = pillars.length - 1;
      final lastColWidth = _colWidthAtIndex(lastIdx, pillars);
      return acc + lastColWidth / 2.0; // 虚拟中点：右边缘 + 半个列宽
    }

    return acc; // fallback
  }

  /// 获取幽灵列的宽度（统一计算逻辑）
  ///
  /// 优先级：
  /// 1. _externalColHoverWidth（如果 > 0）
  /// 2. 默认 pillarWidth（兜底）
  ///
  /// 返回：幽灵列的宽度（像素）
  double _getGhostColumnWidth() {
    // 优先使用 _externalColHoverWidth
    if (_externalColHoverWidth > 0) {
      return _externalColHoverWidth;
    }

    // 兜底：使用默认柱宽
    return pillarWidth;
  }

  /// 获取幽灵行的高度（统一计算逻辑）
  ///
  /// 优先级：
  /// 1. 内部行拖拽：使用 _rowHeightOverrides 或 _rowHeightByName
  /// 2. 外部行拖拽：使用 _externalRowHoverHeight
  /// 3. 兜底：使用 fallbackHeight 参数
  ///
  /// 参数：
  /// - fallbackHeight: 兜底高度（默认为 otherCellHeight）
  ///
  /// 返回：幽灵行的高度（像素）
  double _getGhostRowHeight({double? fallbackHeight}) {
    final rows = _currentRowLabels();
    final d = _draggingRowIndex;

    // 1. 内部行拖拽：优先使用 override，否则根据行名称计算
    if (d != null && d < rows.length) {
      final draggedName = rows[d];
      final override = _rowHeightOverrides[d];
      final byName = _rowHeightByName(draggedName);
      return override ?? byName;
    }

    // 2. 外部行拖拽：使用外部载荷解析的高度
    if (_hoveringExternalRow && _externalRowHoverHeight > 0) {
      return _externalRowHoverHeight;
    }

    // 3. 兜底：使用传入的 fallback 或默认高度
    return fallbackHeight ?? otherCellHeight;
  }

  /// 计算包含装饰的 Card 尺寸
  ///
  /// 基于 CardLayoutModel 的基础尺寸，添加每列装饰的额外尺寸：
  /// - 宽度：每个普通列添加装饰宽度 (margin 8*2 + padding 16*2 + border 2*2 = 52px)
  /// - 高度：装饰包裹整列，需要添加一次垂直装饰尺寸 (margin 8*2 + padding 16*2 + border 2*2 = 52px)
  Size _computeSizeWithDecorations() {
    final baseSize = _layoutNotifier.value.computeSize(_measurementContext);

    // 计算所有非分隔列的装饰宽度总和（按列覆盖）
    final payloads = widget.pillarsNotifier.value;
    double totalDecorationWidth = 0.0;
    double maxDecorationHeight = 0.0;
    for (int i = 0; i < payloads.length; i++) {
      if (!_isSeparatorColumnIndex(i)) {
        totalDecorationWidth += _pillarDecorationWidthAtIndex(i);
        final h = _pillarDecorationHeightAtIndex(i);
        if (h > maxDecorationHeight) maxDecorationHeight = h;
      }
    }

    // 宽度 = 基础宽度 + 所有列装饰宽度之和
    // 高度 = 基础高度 + 最大列装饰高度（按列覆盖）
    return Size(
      baseSize.width + totalDecorationWidth + _cardBorderHorizontalEff,
      baseSize.height + maxDecorationHeight + _cardBorderVerticalEff,
    );
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
              return _cell(Size(colW, rowH), _kongWangText(text));
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

  /// Builds gender label text with optional global typography overrides.
  ///
  /// Parameters:
  /// - [gender]: The `Gender` enum to display.
  ///
  /// Returns: A `Text` widget styled by `_resolveTextStyle`.
  Text _genderText(Gender gender) => Text(
        gender == Gender.male ? '乾造' : '坤造',
        style: _resolveTextStyle(
          fontSize: 14,
          weight: FontWeight.bold,
          color: Colors.black87,
        ),
      );

  /// Builds row title text with optional global typography overrides.
  ///
  /// Parameters:
  /// - [s]: The title string.
  ///
  /// Returns: A `Text` widget styled by `_resolveTextStyle`.
  Text _rowTitleText(String s) => Text(
        s,
        style: _resolveTextStyle(
          fontSize: 14,
          weight: FontWeight.bold,
          color: Colors.black87,
          group: TextGroup.rowTitle,
        ),
      );

  /// Builds column title text with optional global typography overrides.
  ///
  /// Parameters:
  /// - [s]: The title string.
  ///
  /// Returns: A `Text` widget styled by `_resolveTextStyle`.
  Text _columnTitleText(String s) => Text(
        s,
        style: _resolveTextStyle(
          fontSize: 14,
          weight: FontWeight.bold,
          color: Colors.black87,
          group: TextGroup.columnTitle,
        ),
      );

  /// Builds TianGan text.
  ///
  /// 参数：
  /// - [t]: 要渲染的天干。
  /// 返回：根据 `_resolveTextStyle` 样式渲染的 `Text` 组件。
  Widget _tianGanText(TianGan t) {
    // 当启用彩色模式时，天干按字符映射使用固定色彩方案；
    // 关闭彩色模式时，使用纯色（受全局/分组字体设置影响）。
    TextStyle base = _resolveTextStyle(
      fontSize: 24,
      // 颜色延后处理，避免被全局/分组覆盖（彩色模式下需要自定义颜色）
      color: widget.colorfulMode ? null : Colors.black87,
      weight: FontWeight.w400,
      group: TextGroup.tianGan,
    );
    if (widget.colorfulMode && base.color == null) {
      final Color c = _colorForTianGanChar(t.name);
      base = base.copyWith(color: c);
    }
    // Allow per-character overrides in both modes; overrides take precedence
    if (widget.perCharColors != null) {
      final Color? override = widget.perCharColors![t.name];
      if (override != null) {
        base = base.copyWith(color: override);
      }
    }
    // If shadow color signals follow-character, resolve it to final text color with opacity
    if (base.shadows != null && base.shadows!.isNotEmpty) {
      final Shadow sh = base.shadows!.first;
      final int rgb = sh.color.value & 0x00FFFFFF;
      if (rgb == _kShadowFollowSentinelRGB && base.color != null) {
        final int alpha = sh.color.alpha;
        final Color resolved = base.color!.withAlpha(alpha);
        base = base.copyWith(
          shadows: [
            Shadow(
                color: resolved, offset: sh.offset, blurRadius: sh.blurRadius),
          ],
        );
      }
    }
    return Text(t.name, style: base);
  }

  /// Builds DiZhi text。
  ///
  /// 参数：
  /// - [d]: 要渲染的地支。
  /// 返回：根据 `_resolveTextStyle` 样式渲染的 `Text` 组件。
  Widget _diZhiText(DiZhi d) {
    // 当启用彩色模式时，地支按字符映射使用固定色彩方案；
    // 关闭彩色模式时，使用纯色（受全局/分组字体设置影响）。
    TextStyle base = _resolveTextStyle(
      fontSize: 24,
      color: widget.colorfulMode ? null : Colors.black87,
      weight: FontWeight.w500,
      group: TextGroup.diZhi,
    );
    if (widget.colorfulMode && base.color == null) {
      final Color c = _colorForDiZhiChar(d.name);
      base = base.copyWith(color: c);
    }
    // Allow per-character overrides in both modes; overrides take precedence
    if (widget.perCharColors != null) {
      final Color? override = widget.perCharColors![d.name];
      if (override != null) {
        base = base.copyWith(color: override);
      }
    }
    // If shadow color signals follow-character, resolve it to final text color with opacity
    if (base.shadows != null && base.shadows!.isNotEmpty) {
      final Shadow sh = base.shadows!.first;
      final int rgb = sh.color.value & 0x00FFFFFF;
      if (rgb == _kShadowFollowSentinelRGB && base.color != null) {
        final int alpha = sh.color.alpha;
        final Color resolved = base.color!.withAlpha(alpha);
        base = base.copyWith(
          shadows: [
            Shadow(
                color: resolved, offset: sh.offset, blurRadius: sh.blurRadius),
          ],
        );
      }
    }
    return Text(d.name, style: base);
  }

  /// Builds NaYin text with optional global typography overrides.
  ///
  /// Parameters:
  /// - [s]: The NaYin string to render.
  ///
  /// Returns: A `Text` widget styled by `_resolveTextStyle`.
  Text _naYinText(String s) => Text(
        s,
        style: _resolveTextStyle(
          fontSize: 14,
          color: Colors.amber,
          weight: FontWeight.w400,
          group: TextGroup.naYin,
        ),
      );

  /// Builds KongWang text with optional global/group typography overrides.
  ///
  /// 参数：
  /// - [s]: 要渲染的空亡字符串。
  /// 返回：带样式的 `Text` 组件。
  Text _kongWangText(String s) => Text(
        s,
        style: _resolveTextStyle(
          fontSize: 14,
          color: Colors.black87,
          weight: FontWeight.w400,
          group: TextGroup.kongWang,
        ),
      );

  /// Resolves a `TextStyle` applying optional global typography overrides.
  ///
  /// Parameters:
  /// - [fontSize]: Base font size to start from; overridden by `globalFontSize` when provided.
  /// - [weight]: Desired font weight.
  /// - [color]: Fallback text color; overridden by `globalFontColor` when provided.
  ///
  /// Returns: A `TextStyle` merged with `globalFontFamily/globalFontSize/globalFontColor` if set.
  TextStyle _resolveTextStyle({
    double? fontSize,
    FontWeight? weight,
    Color? color,
    TextGroup? group,
  }) {
    var style = TextStyle(
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
    );
    if (widget.globalFontFamily != null &&
        widget.globalFontFamily!.isNotEmpty) {
      style = style.copyWith(fontFamily: widget.globalFontFamily);
    }
    if (widget.globalFontSize != null && widget.globalFontSize! > 0) {
      style = style.copyWith(fontSize: widget.globalFontSize);
    }
    // 彩色模式下的天干/地支不应用全局颜色，避免覆盖字符映射颜色。
    final bool isGanZhi =
        group == TextGroup.tianGan || group == TextGroup.diZhi;
    final bool suppressGlobalColor = widget.colorfulMode && isGanZhi;
    if (widget.globalFontColor != null && !suppressGlobalColor) {
      style = style.copyWith(color: widget.globalFontColor);
    }
    if (group != null && widget.groupTextStyles != null) {
      final override = widget.groupTextStyles![group];
      if (override != null) {
        // 按属性逐项合并：颜色仅在 colorfulMode 开启时应用；其他属性始终生效
        var merged = style;
        if (override.fontFamily != null && override.fontFamily!.isNotEmpty) {
          merged = merged.copyWith(fontFamily: override.fontFamily);
        }
        if (override.fontSize != null && override.fontSize! > 0) {
          merged = merged.copyWith(fontSize: override.fontSize);
        }
        if (override.fontWeight != null) {
          merged = merged.copyWith(fontWeight: override.fontWeight);
        }
        // 阴影：始终允许按分组覆盖（不受彩色模式限制）。
        if (override.shadows != null && override.shadows!.isNotEmpty) {
          merged = merged.copyWith(shadows: override.shadows);
        }
        // 若分组设置了颜色（表示未勾选“跟随字符”），则优先使用该颜色。
        if (override.color != null) {
          merged = merged.copyWith(color: override.color);
        }
        style = merged;
      }
    }
    return style;
  }

  /// Returns default color for a TianGan character under the colorful scheme.
  ///
  /// 参数：
  /// - [ch]: 天干汉字字符。
  /// 返回：彩色方案中的颜色，固定映射，不随亮暗变化。
  Color _colorForTianGanChar(String ch) {
    switch (ch) {
      case '甲':
      case '乙':
        return Colors.green;
      case '丙':
      case '丁':
        return Colors.red;
      case '戊':
      case '己':
        return Colors.orange;
      case '庚':
      case '辛':
        return Colors.blue;
      case '壬':
      case '癸':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Returns default color for a DiZhi character under the colorful scheme.
  ///
  /// 参数：
  /// - [ch]: 地支汉字字符。
  /// 返回：彩色方案中的颜色，固定映射，不随亮暗变化。
  Color _colorForDiZhiChar(String ch) {
    switch (ch) {
      case '子':
        return Colors.indigo;
      case '丑':
      case '戌':
        return Colors.brown;
      case '寅':
        return Colors.teal;
      case '卯':
        return Colors.green;
      case '辰':
        return Colors.orange;
      case '巳':
        return Colors.red;
      case '午':
        return Colors.redAccent;
      case '未':
        return Colors.orangeAccent;
      case '申':
        return Colors.blueGrey;
      case '酉':
        return Colors.blue;
      case '亥':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
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
  final List<double> rowHeights; // heights for corresponding rows
  final double rowTitleWidth;
  final double hysteresisFrac; // hysteresis fraction (e.g., 0.15)
  final Color color;

  const _RowHysteresisPainter({
    required this.midYs,
    required this.rowHeights,
    required this.rowTitleWidth,
    required this.hysteresisFrac,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midPaint = Paint()
      ..color = color
      ..strokeWidth = _EditableFourZhuCardV3State._debugStroke
      ..style = PaintingStyle.stroke;
    final marginPaint = Paint()
      ..color = Colors.orange.withOpacity(0.5)
      ..strokeWidth = _EditableFourZhuCardV3State._debugMarginStroke
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < midYs.length; i++) {
      final midY = midYs[i];
      final rowHeight = rowHeights[i];
      final marginPx = rowHeight * hysteresisFrac;

      // Mid line across the left header width
      canvas.drawLine(Offset(0, midY), Offset(rowTitleWidth, midY), midPaint);
      // Margin lines above and below midpoint (orange dashed)
      _drawDashedLine(canvas, Offset(0, midY - marginPx),
          Offset(rowTitleWidth, midY - marginPx), marginPaint);
      _drawDashedLine(canvas, Offset(0, midY + marginPx),
          Offset(rowTitleWidth, midY + marginPx), marginPaint);
    }
  }

  // 绘制虚线辅助方法
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final distance = (p2 - p1).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final t1 = i * (dashWidth + dashSpace) / distance;
      final t2 = (i * (dashWidth + dashSpace) + dashWidth) / distance;
      canvas.drawLine(
        Offset.lerp(p1, p2, t1)!,
        Offset.lerp(p1, p2, t2)!,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RowHysteresisPainter oldDelegate) {
    return midYs != oldDelegate.midYs ||
        rowHeights != oldDelegate.rowHeights ||
        rowTitleWidth != oldDelegate.rowTitleWidth ||
        hysteresisFrac != oldDelegate.hysteresisFrac ||
        color != oldDelegate.color;
  }
}

// Visualize row boundaries across the entire card (including header row)
class _RowBoundaryPainter extends CustomPainter {
  final List<double> midYs; // midpoints for all rows (including header)
  final List<double> rowHeights; // heights for all rows
  final double cardWidth;
  final Color color;
  final double
      hysteresisFrac; // hysteresis fraction for yielding trigger (e.g., 0.15)

  const _RowBoundaryPainter({
    required this.midYs,
    required this.rowHeights,
    required this.cardWidth,
    required this.color,
    this.hysteresisFrac = 0.15,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 中点线（红色实线）- 每行中心，作为让位触发基准
    final midPaint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 滞回边界虚线（橙色）- 标记 ±15% 缓冲区
    final marginPaint = Paint()
      ..color = Colors.orange.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < midYs.length; i++) {
      final midY = midYs[i];
      final rowHeight = rowHeights[i];
      final margin = rowHeight * hysteresisFrac;

      // 绘制中点参考线（红色实线）
      canvas.drawLine(Offset(0, midY), Offset(cardWidth, midY), midPaint);

      // 绘制滞回边界虚线（橙色）
      _drawDashedLine(canvas, Offset(0, midY - margin),
          Offset(cardWidth, midY - margin), marginPaint);
      _drawDashedLine(canvas, Offset(0, midY + margin),
          Offset(cardWidth, midY + margin), marginPaint);
    }
  }

  // 绘制虚线辅助方法
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final distance = (p2 - p1).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final t1 = i * (dashWidth + dashSpace) / distance;
      final t2 = (i * (dashWidth + dashSpace) + dashWidth) / distance;
      canvas.drawLine(
        Offset.lerp(p1, p2, t1)!,
        Offset.lerp(p1, p2, t2)!,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RowBoundaryPainter oldDelegate) {
    return midYs != oldDelegate.midYs ||
        rowHeights != oldDelegate.rowHeights ||
        cardWidth != oldDelegate.cardWidth ||
        color != oldDelegate.color ||
        hysteresisFrac != oldDelegate.hysteresisFrac;
  }
}
