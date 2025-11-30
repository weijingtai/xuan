import 'dart:convert';
import 'dart:ui';

import 'package:common/models/pillar_data.dart';
import 'package:common/models/text_style_config.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:common/models/pillar_content.dart'; // Changed from relative import
import 'package:common/widgets/editable_fourzhu_card/models/cell_style_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math' as math;

import '../../enums.dart';
import '../../enums/enum_di_zhi.dart';
import '../../enums/enum_tian_gan.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/drag_payloads.dart';
import '../../models/pillar_content.dart';
import '../../models/row_data.dart';
import '../../models/row_strategy.dart';
import '../../utils/style_resolver.dart';
import '../../palette/card_palette.dart';
import '../../viewmodels/four_zhu_card_demo_viewmodel.dart';
import 'card_grid_painter.dart';
import 'cells/multi_text_cell.dart';
import 'dimension_models.dart'; // 新增：尺寸管理模型
import 'widgets/ghost_pillar_widget.dart'; // 幽灵柱占位 Widget
import 'text_groups.dart';
import 'card_decorators.dart';
import 'card_debug_painters.dart';
// @Deprecated('旧的布局系统,将在 V4 中移除。请使用 size_calculator 系统')
import 'package:common/widgets/four_zhu/card_layout_model.dart'
    as BasicLayout; // 基础布局度量模型（有效分割线尺寸等）
import 'drag_controller.dart'; // 拖拽节流控制器
import 'models/pillar_style_config.dart';
import 'package:common/widgets/editable_fourzhu_card/cells/single_text_cell.dart';
import 'size_calculator/calculator.dart';
import 'size_calculator/metrics.dart';
import 'models/card_style_config.dart';

// Removed palette-based coloring; group font color applies when colorfulMode is enabled.
// Sentinel RGB used to indicate shadow follows the character color
const int _kShadowFollowSentinelRGB = 0x00FEED;

/// EditableFourZhuCardV3
/// 单视图、双轴拖拽：在同一个网格视图中完成行与列的重排，不再依赖两个 ReorderableListView。
///
/// 参数说明：
/// - [cardPayloadNotifier]: 统一的数据载荷通知器，包含列/行数据和顺序
/// - [theme]: 统一的主题配置接口，包含卡片/柱/单元格/字体样式
/// - [paddingNotifier]: 卡片内边距通知器
/// - [rowStrategyMapper]: 行计算策略映射
/// - [gender]: 性别枚举，用于显示乾造/坤造
///
/// 注意：已移除分离的 pillarSection、cellSection、typographySection 参数，
/// 统一使用 theme 参数进行样式配置

class EditableFourZhuCardV3 extends StatefulWidget {
  final JiaZi dayGanZhi;
  // final Map<RowType, RowComputationStrategy> rowStrategyMapper;
  final ValueNotifier<EditableFourZhuCardTheme> themeNotifier;
  final ValueNotifier<CardPayload> cardPayloadNotifier;

  final ValueNotifier<Brightness> brightnessNotifier;
  final ValueNotifier<ColorPreviewMode> colorPreviewModeNotifier;
  // final EditableFourZhuCardTheme? theme;

  final ValueNotifier<EdgeInsets> paddingNotifier;
  final Gender gender;
  final bool showGrip;
  final Widget Function(BuildContext context, Widget child)?
      dragFeedbackBuilder;
  final Decoration Function(BuildContext context, bool isHover)?
      columnInsertDecorationBuilder;
  final Decoration Function(BuildContext context, bool isHover)?
      rowInsertDecorationBuilder;
  // Optional: visualize hysteresis boundaries for debugging
  final bool debugHysteresisOverlay;
  // Card-level colorful mode: when true, use per-token palette colors
  // final bool colorfulMode;

  /// Resolves element colors (Gan/Zhi) via palette/theme strategies.
  // final ElementColorResolver elementColorResolver;

  /// 可选：行重排完成时回调通知。用于测试或外部状态同步。
  ///
  /// 参数：按当前顺序排列的行载荷列表。
  final void Function(List<RowPayload> rows)? onRowsReordered;

  EditableFourZhuCardV3({
    super.key,
    required this.dayGanZhi,
    required this.brightnessNotifier,
    required this.colorPreviewModeNotifier,
    required this.themeNotifier,
    required this.cardPayloadNotifier,
    required this.paddingNotifier,
    // required this.rowStrategyMapper,
    required this.gender,
    this.onRowsReordered,
    this.dragFeedbackBuilder,
    this.columnInsertDecorationBuilder,
    this.rowInsertDecorationBuilder,
    this.debugHysteresisOverlay = false,
    this.showGrip = true,
    ElementColorResolver? elementColorResolver,
  });
  // }) : elementColorResolver = elementColorResolver ??
  // PaletteElementColorResolver(CardPalette.defaultPalette());

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
      _basicLayoutModel.rowDividerHeightEffective;
  double get _colDividerWidthEffective =>
      _basicLayoutModel.colDividerWidthEffective;
  double get _effectiveDragHandleRowHeight =>
      _basicLayoutModel.effectiveGripHeight(isVisible: widget.showGrip);
  double get _effectiveDragHandleColWidth =>
      _basicLayoutModel.effectiveGripWidth(isVisible: widget.showGrip);

  // 批处理重建调度标记：避免频繁 setState 导致抖动与重建次数过多
  bool _rebuildScheduled = false;
  // 批处理重建采样：记录一次交互期间的重建次数与调度请求次数
  int _rebuildCount = 0;
  int _rebuildScheduleRequests = 0;

  Widget drag_icon = const Icon(
    Icons.drag_indicator,
    size: 16,
    color: Colors.black,
  );
  // 缓存：行插入索引计算所需的跨度列表（每行高度）。
  // 目的：减少 onMove 高频生成 List 与高度计算的开销，提升拖拽性能。
  List<double>? _rowSpansCache;

  Map<RowType, RowComputationStrategy> get rowStrategyMapper =>
      Provider.of<FourZhuCardDemoViewModel>(context, listen: false)
          .rowStrategyMapper;

  /// 批处理重建调度：在微任务中合并多次状态更新为一次 setState。
  ///
  /// 功能：将多处状态字段的快速变更（例如拖拽移动中的悬停宽度/插入索引更新）
  /// 汇聚到同一个微任务末尾统一触发一次 setState，从而降低重建次数、提升性能。
  /// 参数：无
  /// 返回：无
  void _scheduleRebuild() {
    if (_rebuildScheduled) return;
    _rebuildScheduled = true;
    _rebuildScheduleRequests++;
    scheduleMicrotask(() {
      if (!mounted) return;
      setState(() {
        _rebuildScheduled = false;
        _rebuildCount++;
      });
    });
  }

  /// 快照并重置重建计数
  /// 功能：用于测试或调试验证批处理是否生效（重建次数是否降低）。
  /// 返回：本次快照内的重建次数与调度请求次数（字符串形式）
  @visibleForTesting
  String takeAndResetRebuildSampling() {
    final res =
        'RebuildSampling(rebuilds=$_rebuildCount, requests=$_rebuildScheduleRequests)';
    _rebuildCount = 0;
    _rebuildScheduleRequests = 0;
    return res;
  }

  /// 快照并重置拖拽 onMove 计数（行/列），用于调试日志或测试断言
  @visibleForTesting
  MoveCounters takeAndResetDragMoveCounts() {
    return _dragController.snapshotAndResetMoveCounts();
  }

  /// 快照并重置 ValueNotifier 更新计数（插入/删除提示）
  /// 功能：用于评估基于 ValueNotifier 的提示更新是否过于频繁，从而影响重建
  /// 参数：无
  /// 返回：字符串形式 `NotifierSampling(insertUpdates=X, deleteUpdates=Y)`
  @visibleForTesting
  String takeAndResetNotifierSampling() {
    final res =
        'NotifierSampling(insertUpdates=$_dragInsertUpdatesCount, deleteUpdates=$_dragDeleteUpdatesCount)';
    _dragInsertUpdatesCount = 0;
    _dragDeleteUpdatesCount = 0;
    return res;
  }

  /// 计算当前行列表的每项高度，并返回跨度列表。
  /// 功能：用于行插入索引的中点规则计算，支持不等高行。
  /// 参数：无。
  /// 返回值：`List<double>`，长度等于当前行数，元素为对应行的高度（像素）。
  List<double> _computeCurrentRowSpans() {
    final rows = _currentRowLabels();
    return List<double>.generate(rows.length, (i) => _rowHeightByName(rows[i]));
  }

  late final ValueNotifier<PillarSection> _pillarSectionNotifier;
  late final ValueNotifier<CellSection> _cellSectionNotifier;
  late final ValueNotifier<TypographySection> _typographySectionNotifier;

  /// 重置行跨度缓存。
  /// 使用场景：拖拽离开或接受后，行集合可能发生变化，需清理旧缓存。
  /// 参数：无。
  /// 返回值：无。
  void _resetRowSpansCache() {
    _rowSpansCache = null;
  }

  // Test-only hook: programmatically reorder rows without drag gestures.
  // Useful for verifying reorder logic in tests when gesture hit-testing is unreliable.
  @visibleForTesting
  void reorderRowsForTest(int fromAbsIdx, int insertIndex) {
    assert(fromAbsIdx >= 0);
    assert(insertIndex >= 0);
    debugPrint('reorderRowsForTest from=$fromAbsIdx insert=$insertIndex');
    _reorderRows(fromAbsIdx, insertIndex);
  }

  // 动态柱装饰参数与派生尺寸
  /// 有效柱边距（优先使用传入的值，默认 8 全向）
  EdgeInsets get _pillarMarginEff =>
      _pillarSectionNotifier.value.defaultMargin!;

  /// 每列的有效边距：优先使用对应列的 `payload.columnMargin`，否则退回全局。
  EdgeInsets _pillarMarginAtIndex(int i) {
    final payloads = _currentPillars();
    if (i >= 0 && i < payloads.length) {
      final pType = payloads[i].pillarType;
      final cfg = _pillarSectionNotifier.value.getBy(pType);
      final m = cfg.margin;
      return m;
    }
    return _pillarMarginEff;
  }

  /// 有效柱内边距（优先使用传入的值，默认 16 全向）
  EdgeInsets get _pillarPaddingEff =>
      _pillarSectionNotifier.value.global.padding;

  EdgeInsets _pillarPaddingAtIndex(int i) {
    final payloads = _currentPillars();
    if (i >= 0 && i < payloads.length) {
      final p = payloads[i];
      return _pillarSectionNotifier.value.getBy(p.pillarType).padding;
    }
    // 如果没有得到则返回默认
    return _pillarSectionNotifier.value.global.padding;
  }

  /// 有效柱边框宽度（优先使用传入的值，默认 2）
  double get _pillarBorderWidthEff =>
      _pillarSectionNotifier.value.global.border?.enabled ?? false
          ? _pillarSectionNotifier.value.global.border!.width
          : 0;

  double _pillarBorderWidthAtIndex(int i) {
    final payloads = _currentPillars();
    if (i >= 0 && i < payloads.length) {
      final p = payloads[i];
      return _pillarSectionNotifier.value.getBy(p.pillarType).border!.width;
      // final bw = payloads[i].columnBorderWidth;
      // if (bw != null) return bw;
    }
    return _pillarBorderWidthEff;
  }

  /// 指定列的装饰总宽度（使用每列边距覆盖）
  double _pillarDecorationWidthAtIndex(int i) {
    final m = _pillarMarginAtIndex(i);
    final p = _pillarPaddingAtIndex(i);
    final bw = _pillarBorderWidthAtIndex(i);
    return m.left + m.right + p.left + p.right + bw * 2;
  }

  /// 指定列的装饰总高度（使用每列边距覆盖）
  double _pillarDecorationHeightAtIndex(int i) {
    final m = _pillarMarginAtIndex(i);
    final p = _pillarPaddingAtIndex(i);
    final bw = _pillarBorderWidthAtIndex(i);
    return m.top + m.bottom + p.top + p.bottom + bw * 2;
  }

  /// 顶部装饰偏移（取所有柱的 max(topMargin + topPadding + topBorder)）
  double get _pillarDecorationTopOffsetEff {
    final payloads = _currentPillars();
    final section = _pillarSectionNotifier.value;
    double maxTop = 0.0;
    for (int i = 0; i < payloads.length; i++) {
      final cfg = section.getBy(payloads[i].pillarType);
      final bw =
          (cfg.border?.enabled ?? false) ? (cfg.border?.width ?? 0.0) : 0.0;
      final top = cfg.margin.top + cfg.padding.top + bw;
      if (top > maxTop) maxTop = top;
    }
    return _pixelFloor(maxTop);
  }

  /// 底部装饰偏移（取所有柱的 max(bottomBorder + bottomPadding + bottomMargin)）
  double get _pillarDecorationBottomOffsetEff {
    final payloads = _currentPillars();
    final section = _pillarSectionNotifier.value;
    double maxBottom = 0.0;
    for (int i = 0; i < payloads.length; i++) {
      final cfg = section.getBy(payloads[i].pillarType);
      final bw =
          (cfg.border?.enabled ?? false) ? (cfg.border?.width ?? 0.0) : 0.0;
      final bottom = bw + cfg.padding.bottom + cfg.margin.bottom;
      if (bottom > maxBottom) maxBottom = bottom;
    }
    return _pixelFloor(maxBottom);
  }

  // 卡片边框厚度（水平/垂直）合计，用于在整体尺寸中加上边框占用的空间，避免内容被裁剪或溢出。
  double get _cardBorderHorizontalEff {
    final border = widget.themeNotifier.value.card.toBoxDecoration().border;
    if (border == null) return 0.0;
    final dimsGeo = border.dimensions; // EdgeInsetsGeometry
    final dims = dimsGeo is EdgeInsets
        ? dimsGeo
        : dimsGeo.resolve(Directionality.of(context));
    return dims.left + dims.right;
  }

  double get _cardBorderVerticalEff {
    final border = widget.themeNotifier.value.card.toBoxDecoration().border;
    if (border == null) return 0.0;
    final dimsGeo = border.dimensions; // EdgeInsetsGeometry
    final dims = dimsGeo is EdgeInsets
        ? dimsGeo
        : dimsGeo.resolve(Directionality.of(context));
    return dims.top + dims.bottom;
  }

  double _resolveUniformCardBorderWidth() {
    final border = widget.themeNotifier.value.card.toBoxDecoration().border;
    if (border == null) return 0.0;
    final dimsGeo = border.dimensions;
    final dims = dimsGeo is EdgeInsets
        ? dimsGeo
        : dimsGeo.resolve(Directionality.of(context));
    final values = [dims.left, dims.right, dims.top, dims.bottom];
    double maxW = 0.0;
    for (final v in values) {
      if (v > maxW) maxW = v;
    }
    return maxW;
  }

  CardMetricsSnapshot _computeMetricsSnapshot() {
    final cp = widget.cardPayloadNotifier.value;
    final CardPayload payload = cp;
    // 构建 cell 文本规格映射
    final specMap = _buildCellTextSpecMap();
    final calc = CardMetricsCalculator(
      theme: widget.themeNotifier.value,
      payload: payload,
      defaultPillarWidth: pillarWidth,
      lineHeightFactor: 1.4,
      cellTextSpecMap: specMap,
      avgGlyphWidthScale: 1.2,
      defaultSeparatorWidth: widget.themeNotifier.value.pillar
              .getBy(PillarType.separator)
              .separatorWidth ??
          8.0,
      rowTitleWidth: rowTitleWidth,
    );
    return calc.compute();
  }

  /// 构建 cell 文本规格映射
  /// 基于当前的 cardPayload、rowStrategyMapper 和 typography 计算每个 cell 的字符数
  Map<String, CellTextSpec> _buildCellTextSpecMap() {
    // print("DEBUG: _buildCellTextSpecMap called");
    final cp = widget.cardPayloadNotifier.value;
    final List<PillarPayload> pillars =
        cp.pillarOrderUuid.map((id) => cp.pillarMap[id]!).toList();
    final List<RowPayload> rowsLite =
        cp.rowOrderUuid.map((id) => cp.rowMap[id]!).toList();

    final Map<String, CellTextSpec> specMap = {};
    JiaZi? dayJiaZi;
    try {
      final dayPayload =
          pillars.firstWhere((p) => p.pillarType == PillarType.day);
      dayJiaZi = _pillarJiaZiFromPayload(dayPayload);
    } catch (_) {}

    for (final r in rowsLite) {
      final rt = r.rowType;
      for (final p in pillars) {
        int cc = 0;
        if (rt == RowType.columnHeaderRow) {
          final label = _pillarLabelFromPayload(p);
          cc = label.length;
        } else if (rt == RowType.heavenlyStem || rt == RowType.earthlyBranch) {
          cc = 1;
        } else if (rt != RowType.separator) {
          final pjz = _pillarJiaZiFromPayload(p);
          final text = rowStrategyMapper[rt]
              ?.computeSingleValue(pjz, dayJiaZi ?? pjz, widget.gender);
          cc = (text ?? '').length;
        }
        specMap['${r.uuid}|${p.uuid}'] = CellTextSpec(
          rowUuid: r.uuid,
          pillarUuid: p.uuid,
          charCount: cc,
          fontSize: _typographySectionNotifier.value
              .getCellContentBy(rt)
              .fontStyleDataModel
              .fontSize,
        );
        // print("Spec: ${r.uuid}|${p.uuid} -> fs: ${specMap['${r.uuid}|${p.uuid}']?.fontSize}");
      }
    }
    return specMap;
  }

  // 将逻辑尺寸向下对齐到物理像素，减少由于子像素导致的 RenderFlex 溢出告警
  double _pixelFloor(double logical) {
    final double dpr = ui.window.devicePixelRatio;
    final double physical = (logical * dpr).floorToDouble();
    return physical / dpr;
  }

  double _pixelCeil(double logical) {
    final double dpr = ui.window.devicePixelRatio;
    final double physical = (logical * dpr).ceilToDouble();
    return physical / dpr;
  }

  EdgeInsets _pixelFloorEdgeInsets(EdgeInsets e) {
    final double dpr = ui.window.devicePixelRatio;
    double f(double v) => (v * dpr).floorToDouble() / dpr;
    return EdgeInsets.fromLTRB(f(e.left), f(e.top), f(e.right), f(e.bottom));
  }

  // --- Column width helpers (support narrow separator columns) ---
  bool _isSeparatorTitle(String title) =>
      title == '分隔符' || title == '列分隔符' || title == '|';

  /// 判断指定列索引是否为“分隔符列”。
  ///
  /// 优先依据列的 `PillarPayload.pillarType == PillarType.separator` 识别，
  /// 兼容旧逻辑：在缺少载荷时退回到标题别名（如“分隔符/列分隔符/|”）。
  bool _isSeparatorColumnIndex(int i) {
    final payloads = _currentPillars();
    if (i >= 0 && i < payloads.length) {
      final p = payloads[i];
      if (p.pillarType == PillarType.separator) return true;
      final title = _pillarLabelFromPayload(p);
      return _isSeparatorTitle(title);
    }
    return false;
  }

  /// 判断当前渲染的数据网格（`pillars`）中是否包含“行标题列”。
  ///
  /// 仅当 `pillars` 中对应位置存在 `PillarPayload` 且其类型为
  /// `PillarType.rowTitleColumn` 时返回 true；避免仅存在于 payloads 中、
  /// 但未参与实际渲染网格的“幽灵行标题列”导致左侧标题误隐藏。
  bool _hasRowTitleColumnInGrid(List<PillarPayload> pillars) {
    final payloads = _currentPillars();
    for (int i = 0; i < pillars.length; i++) {
      if (i < payloads.length) {
        if (payloads[i].pillarType == PillarType.rowTitleColumn) {
          return true;
        }
      }
    }
    return false;
  }

  /// 判断指定绝对行索引是否为“分隔行”。
  ///
  /// 统一依据行 `payload.rowType == RowType.separator` 进行判断，彻底移除
  /// 逻辑层对中文标题字符串的依赖，以提升鲁棒性与可维护性。
  /// 参数：
  /// - absRowIdx: 当前渲染的行在 `cardPayloadNotifier.value.rowOrderUuid` 中的绝对索引。
  /// 返回值：
  /// - 当行类型为 `RowType.separator` 时返回 true，否则返回 false。
  bool _isSeparatorRowAtIndex(int absRowIdx) {
    final rows = _currentRows();
    if (absRowIdx >= 0 && absRowIdx < rows.length) {
      final r = rows[absRowIdx];
      return r is RowSeparatorPayload || r.rowType == RowType.separator;
    }
    return false;
  }

  // 显式列宽/行高覆盖映射：键为当前索引，值为覆盖尺寸
  final Map<int, double> _columnWidthOverrides = {};
  final Map<int, double> _rowHeightOverrides = {};

  late ValueNotifier<CardMetricsSnapshot> _metricsSnapshotNotifier;

  // 尺寸管理系统：集中管理所有尺寸计算，自动处理索引重映射
  @Deprecated('旧布局系统,V4 中将移除')
  late ValueNotifier<CardLayoutModel> _layoutNotifier;
  @Deprecated('旧度量系统,V4 中将移除')
  late MeasurementContext _measurementContext;
  late VoidCallback _layoutModelSyncListener; // 用于同步数据到布局模型
  late VoidCallback _basicLayoutVersionListener; // 监听基础布局模型版本变化，联动测量上下文与尺寸
  @Deprecated('旧布局系统,V4 中将移除')
  late BasicLayout.CardLayoutModel _basicLayoutModel; // 基础布局度量模型（分割线有效尺寸/抓手宽度等）

  // --- Mapping helpers from payloads to UI tuples/labels ---
  String _pillarLabelFromPayload(PillarPayload p) {
    if (p is ContentPillarPayload) {
      return p.pillarContent.label;
    }
    return p.pillarLabel ?? p.pillarType.name;
  }

  JiaZi _pillarJiaZiFromPayload(PillarPayload p) {
    if (p is ContentPillarPayload) {
      return p.pillarContent.jiaZi;
    }
    return JiaZi.JIA_ZI;
  }

  // List<Tuple2<String, JiaZi>> _effectivePillarsTuples() {
  //   final payloads = _currentPillars();
  //   return payloads
  //       .map((p) =>
  //           Tuple2(_pillarLabelFromPayload(p), _pillarJiaZiFromPayload(p)))
  //       .toList();
  // }

  /// 【方案A优化】确保所有 Pillar 的 GlobalKey 都已创建
  ///
  /// 这个方法在 build 开始时调用，确保 GlobalKeys 在抓手行构建之前就存在。
  /// 这样拖拽开始时就能找到对应的 GlobalKey。
  void _ensurePillarKeys() {
    final pillars = _currentPillars();
    for (int i = 0; i < pillars.length; i++) {
      _pillarGlobalKeys[i] ??= GlobalKey(debugLabel: 'pillar-$i');
    }
  }

  /// 为新插入的柱分配唯一 `id`，格式：`<type>#<序号>`，例如：`year#1`、`luckCycle#2`。
  /// 通过当前已存在的同类型柱数量确定下一个序号，确保在当前卡片内唯一。
  String _allocatePillarId(PillarType type) {
    final existingCount =
        _currentPillars().where((p) => p.pillarType == type).length;
    final nextIndex = existingCount + 1;
    return '${type.name}#$nextIndex';
  }

  List<String> _currentRowLabels() {
    final rows = _currentRows();
    return rows.map((r) {
      if (r is TextRowPayload) return r.rowLabel ?? r.rowType.name;
      return r.rowType.name;
    }).toList();
  }

  List<PillarPayload> _currentPillars() {
    final cp = widget.cardPayloadNotifier.value;
    return cp.pillarOrderUuid.map((id) => cp.pillarMap[id]!).toList();
  }

  List<RowPayload> _currentRows() {
    final cp = widget.cardPayloadNotifier.value;
    return cp.rowOrderUuid.map((id) => cp.rowMap[id]!).toList();
  }

  void _setRows(List<RowPayload> rows) {
    final cp = widget.cardPayloadNotifier.value;
    widget.cardPayloadNotifier.value = cp.copyWith(
      rowMap: {for (final r in rows) r.uuid: r},
      rowOrderUuid: rows.map((e) => e.uuid).toList(),
    );
  }

  void _setPillars(List<PillarPayload> list) {
    final cp = widget.cardPayloadNotifier.value;
    widget.cardPayloadNotifier.value = cp.copyWith(
      pillarMap: {for (final p in list) p.uuid: p},
      pillarOrderUuid: list.map((e) => e.uuid).toList(),
    );
  }

  double _colWidthAtIndex(int i, List<PillarPayload> pillars) {
    // 边界检查
    if (i < 0 || i >= pillars.length) {
      return _pixelFloor(pillarWidth);
    }

    final p = pillars[i];
    final snap = _metricsSnapshotNotifier.value;
    final pm = snap.pillars[p.uuid];

    if (pm != null) {
      // 使用 metrics 中计算好的总宽度（content + decoration）
      return _pixelFloor(pm.totalWidth);
    }

    // Fallback：如果 metrics 不可用
    return _pixelFloor(pillarWidth);
  }

  double _sumColWidthsUpTo(int idx, List<PillarPayload> pillars) {
    double acc = 0.0;
    for (int i = 0; i < idx; i++) {
      acc += _colWidthAtIndex(i, pillars);
    }
    return acc;
  }

  double _totalColsWidth(List<PillarPayload> pillars) {
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
  // 统一拖拽节流控制器
  late final EditableCardDragController _dragController;
  // Continuous hover positions (fractional), used for partial offsets
  // double? _hoverColumnFloat; // range [0..pillars.length]
  // double? _hoverRowFloat; // range [1..rows.length]
  // Smoothed floats to reduce jitter
  // double? _hoverColumnFloatEff;
  // double? _hoverRowFloatEff;
  // Last committed insert indices for hysteresis
  int? _lastColInsertIndex;
  int? _lastRowInsertIndex;

  // External hover flags to expand card size during drag-over (better UX)
  bool _hoveringExternalPillar = false;
  bool _hoveringExternalRow = false;
  double _externalRowHoverHeight = 0.0;
  double _externalColHoverWidth = 0.0;
  // Size? _cardNotragInSize;

  /// 当“抓手显示/隐藏”触发尺寸变化时，优先使用居中对齐以获得更顺滑的动画；
  /// 其他情况（如外部柱/行悬停导致容器扩展）则使用顶部起始对齐。
  bool _preferCenterAlignment = false;

  // Drag feedback status notifiers: control dynamic "插入"/"删除" prompts on the dragged piece itself
  // When hovering a valid insert target inside the card, set insert=true, delete=false
  // When leaving card targets (outside card), set delete=true, insert=false
  final ValueNotifier<bool> _dragWantsInsert = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _dragWantsDelete = ValueNotifier<bool>(false);
  // ValueNotifier 更新采样计数：用于验证批处理策略（减少 UI 重建）是否奏效
  int _dragInsertUpdatesCount = 0;
  int _dragDeleteUpdatesCount = 0;

  /// 监听器：插入提示更新次数统计
  /// 功能：当 `_dragWantsInsert` 的值发生变化（触发通知）时递增计数
  /// 参数：无
  /// 返回值：无
  void _onDragWantsInsertUpdated() {
    _dragInsertUpdatesCount++;
  }

  /// 监听器：删除提示更新次数统计
  /// 功能：当 `_dragWantsDelete` 的值发生变化（触发通知）时递增计数
  /// 参数：无
  /// 返回值：无
  void _onDragWantsDeleteUpdated() {
    _dragDeleteUpdatesCount++;
  }

  // 监听注册与移除在统一的 initState/dispose 中处理（见下方组件初始化/释放方法）
  // Guard to prevent double-accept across overlapping DragTargets
  bool _rowAccepting = false;

  // 【方案A优化】柱 Widget 的 GlobalKey 缓存，用于拖拽时复用已渲染的 Pillar
  // 键为柱索引，值为对应的 GlobalKey
  final Map<int, GlobalKey> _pillarGlobalKeys = {};

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
  double _rowHeightByPayload(RowPayload payload) {
    // 使用模型的统一解析方法，确保行为与外部载荷约定一致
    // 只返回内容高度，不包含 padding（与 CardMetricsCalculator 的设计一致）
    // padding 由 _cell 方法通过 Padding widget 统一处理
    if (payload is TextRowPayload) {
      final baseHeight = payload.resolveHeight(
        heavenlyAndEarthlyHeight: ganZhiCellSize.height,
        otherHeight: otherCellHeight,
        dividerHeight: _rowDividerHeightEffective,
        headerHeight: columnTitleHeight, // 传递表头行高度
      );
      return baseHeight;
    } else if (payload is RowSeparatorPayload) {
      return _rowDividerHeightEffective;
    }
    return otherCellHeight;
  }

  int _commitColInsert(double eff, int draggingIdx, int n,
      [double threshold = 0.5]) {
    // 使用控制器的吸附阈值逻辑进行目标解析，统一可配置与行为口径
    return _dragController.resolveColumnInsertTargetWithThreshold(
      effectiveIndex: eff,
      draggingIndex: draggingIdx,
      maxIndex: n,
      thresholdFraction: threshold,
    );
  }

  int _commitRowInsert(double eff, int draggingIdx, int maxIndex,
      [double threshold = 0.5]) {
    // 使用控制器的吸附阈值逻辑进行目标解析，统一可配置与行为口径
    return _dragController.resolveRowInsertTargetWithThreshold(
      effectiveIndex: eff,
      draggingIndex: draggingIdx,
      maxIndex: maxIndex,
      thresholdFraction: threshold,
    );
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
      double dx, List<PillarPayload> pillars) {
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

  /// 组件初始化：构建基础度量模型、测量上下文、布局模型与节流控制器。
  ///
  /// 功能描述：
  /// - 初始化基础布局度量模型（分割线有效尺寸、抓手显示配置）；
  /// - 依据当前 State 参数创建测量上下文；
  /// - 从数据通知器构建 CardLayoutModel（含覆盖映射与抓手有效尺寸）；
  /// - 初始化尺寸通知器并计算包含装饰的卡片尺寸；
  /// - 建立统一监听器与基础模型版本监听，确保联动刷新；
  /// - 初始化拖拽节流控制器（列/行分别 12ms 轻节流）。
  /// 参数说明：无。
  /// 返回值：无。
  void initState() {
    super.initState();

    // 使用主题构建器或默认值
    final theme = widget.themeNotifier.value;

    _pillarSectionNotifier =
        ValueNotifier(EditableCardThemeBuilder.buildPillarSection(theme))
          ..addListener(() {
            _sizeNotifier.value = _computeSizeWithDecorationsV2();
            _metricsSnapshotNotifier.value = _computeMetricsSnapshot();
            _scheduleRebuild();
          });

    // 监听字体样式配置变化
    _typographySectionNotifier =
        ValueNotifier(EditableCardThemeBuilder.buildTypographySection(theme))
          ..addListener(() {
            _sizeNotifier.value = _computeSizeWithDecorationsV2();
            _metricsSnapshotNotifier.value = _computeMetricsSnapshot();
            _scheduleRebuild();
          });

    _cellSectionNotifier =
        ValueNotifier(EditableCardThemeBuilder.buildCellSection(theme))
          ..addListener(() {
            _sizeNotifier.value = _computeSizeWithDecorationsV2();
            _metricsSnapshotNotifier.value = _computeMetricsSnapshot();
            _scheduleRebuild();
          });

    // 注册 ValueNotifier 监听以进行采样计数
    _dragWantsInsert.addListener(_onDragWantsInsertUpdated);
    _dragWantsDelete.addListener(_onDragWantsDeleteUpdated);
    // 初始化拖拽节流控制器（默认 12ms 轻节流）
    _dragController = EditableCardDragController(
      columnMoveCooldownMs: 12,
      rowMoveCooldownMs: 12,
    );
    // 初始化基础布局度量模型（分割线有效尺寸/抓手宽度按当前配置）
    _basicLayoutModel = BasicLayout.CardLayoutModel(
      padding: widget.paddingNotifier.value,
      // 与现有实现保持一致的抓手默认尺寸（宽/高同口径）
      gripVisibleWidth: dragHandleColWidth,
      gripHiddenWidth: 0.0,
      rowDividerPaddingTop: _rowDividerPaddingTop,
      rowDividerPaddingBottom: _rowDividerPaddingBottom,
      rowDividerThickness: _rowDividerThickness,
      colDividerPaddingLeft: _colDividerPaddingLeft,
      colDividerPaddingRight: _colDividerPaddingRight,
      colDividerThickness: _colDividerThickness,
    );
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
        pillars: _currentPillars(),
        rows: _currentRows(),
        padding: widget.paddingNotifier.value,
        columnWidthOverrides: _columnWidthOverrides,
        // rowHeightOverrides: _rowHeightOverrides,
        // 抓手尺寸统一使用“有效尺寸”，隐藏时为 0，显示时为可见宽度/高度
        dragHandleRowHeight: _effectiveDragHandleRowHeight,
        dragHandleColWidth: _effectiveDragHandleColWidth,
      ),
    );

    // 初始化尺寸通知器，使用包含装饰的尺寸计算
    _sizeNotifier = ValueNotifier<Size>(
      _computeSizeWithDecorationsV2(),
    );

    // 统一监听器：同步更新布局模型和尺寸
    _layoutModelSyncListener = () {
      _layoutNotifier.value = CardLayoutModel.fromNotifiers(
        pillars: _currentPillars(),
        rows: _currentRows(),
        padding: widget.paddingNotifier.value,
        columnWidthOverrides: _columnWidthOverrides,
        // rowHeightOverrides: _rowHeightOverrides,
        // 抓手尺寸按可见性进行“有效尺寸”置零，确保尺寸实时变化
        dragHandleRowHeight: _effectiveDragHandleRowHeight,
        dragHandleColWidth: _effectiveDragHandleColWidth,
      );
      // 同步基础布局模型的 padding
      _basicLayoutModel.updatePadding(widget.paddingNotifier.value);
      // 同步更新尺寸（包含装饰）
      _sizeNotifier.value = _computeSizeWithDecorationsV2();
      _metricsSnapshotNotifier.value = _computeMetricsSnapshot();
    };
    widget.cardPayloadNotifier.addListener(_layoutModelSyncListener);
    widget.paddingNotifier.addListener(_layoutModelSyncListener);

    // 监听基础布局模型的版本变化，确保分割线/抓手有效尺寸变更后测量上下文与整体尺寸同步刷新
    _basicLayoutVersionListener = _onBasicLayoutChanged;
    _basicLayoutModel.version.addListener(_basicLayoutVersionListener);

    _metricsSnapshotNotifier = ValueNotifier(_computeMetricsSnapshot());
    widget.themeNotifier.addListener(_onThemeChanged);
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

    if (oldWidget.themeNotifier != widget.themeNotifier) {
      oldWidget.themeNotifier.removeListener(_onThemeChanged);
      widget.themeNotifier.addListener(_onThemeChanged);
    }
    if (oldWidget.themeNotifier.value != widget.themeNotifier.value) {
      final newTheme = widget.themeNotifier.value;
      _pillarSectionNotifier.value =
          EditableCardThemeBuilder.buildPillarSection(newTheme);
      _cellSectionNotifier.value =
          EditableCardThemeBuilder.buildCellSection(newTheme);
      _typographySectionNotifier.value =
          EditableCardThemeBuilder.buildTypographySection(newTheme);
      _scheduleRebuild();
    }

    final bool rowsVisibilityChanged = oldWidget.showGrip != widget.showGrip;
    // final bool colsVisibilityChanged =
    //     oldWidget.showGripColumns != widget.showGripColumns;

    if (rowsVisibilityChanged) {
      // 抓手显示/隐藏时，切换为居中对齐以提升视觉过渡效果
      _preferCenterAlignment = true;
      // 重新构建布局模型，按可见性设置抓手“有效尺寸”
      _layoutNotifier.value = CardLayoutModel.fromNotifiers(
        pillars: _currentPillars(),
        rows: _currentRows(),
        padding: widget.paddingNotifier.value,
        columnWidthOverrides: _columnWidthOverrides,
        // rowHeightOverrides: _rowHeightOverrides,
        // 抓手尺寸统一使用“有效尺寸”，隐藏时为 0，显示时为可见宽度/高度
        dragHandleRowHeight: _effectiveDragHandleRowHeight,
        dragHandleColWidth: _effectiveDragHandleColWidth,
      );

      // 刷新尺寸（包含装饰），确保父级约束与布局实时更新
      _sizeNotifier.value = _computeSizeWithDecorationsV2();
    }
    // final oldBorder = oldWidget.cardDecoration?.border;
    // final newBorder = widget.cardDecoration?.border;
    // if (oldBorder != newBorder) {
    //   final oldGeo = oldBorder?.dimensions;
    //   final newGeo = newBorder?.dimensions;
    //   final EdgeInsets oldDims = oldGeo is EdgeInsets
    //       ? oldGeo
    //       : (oldGeo?.resolve(Directionality.of(context)) ?? EdgeInsets.zero);
    //   final EdgeInsets newDims = newGeo is EdgeInsets
    //       ? newGeo
    //       : (newGeo?.resolve(Directionality.of(context)) ?? EdgeInsets.zero);
    //   if (oldDims != newDims) {
    //     _sizeNotifier.value = _computeSizeWithDecorationsV2();
    //   }
    // }
  }

  @override
  void dispose() {
    // 清理监听器
    _dragWantsInsert.removeListener(_onDragWantsInsertUpdated);
    _dragWantsDelete.removeListener(_onDragWantsDeleteUpdated);
    _metricsSnapshotNotifier.dispose();
    widget.cardPayloadNotifier.removeListener(_layoutModelSyncListener);
    widget.paddingNotifier.removeListener(_layoutModelSyncListener);
    _basicLayoutModel.version.removeListener(_basicLayoutVersionListener);
    _layoutNotifier.dispose();
    _sizeNotifier.dispose();
    _dragWantsInsert.dispose();
    _dragWantsDelete.dispose();

    _pillarSectionNotifier.dispose();
    _cellSectionNotifier.dispose();
    _typographySectionNotifier.dispose();
    widget.themeNotifier.removeListener(_onThemeChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 【方案A优化】确保所有 Pillar 的 GlobalKey 在 build 开始前就已创建
    // 这样抓手行构建时就能找到对应的 GlobalKey
    _ensurePillarKeys();

    return ValueListenableBuilder<Size>(
      valueListenable: _sizeNotifier,
      builder: (context, size, child) {
        // final double minW = 64.0;
        // final double minH = 64.0;
        // final double safeW = size.width < minW ? minW : size.width;
        // final double safeH = size.height < minH ? minH : size.height;
        // Expand card size dynamically only when hovering an external pillar/row
        final pillars = _currentPillars();
        final rows = _currentRowLabels();
        // 列宽扩展策略：当外部柱悬停 或 当前插入索引位于末尾时扩展一列宽度
        final int? tCol = _hoverColumnInsertIndex ?? _lastColInsertIndex;
        // 行拖拽进行中时，强制屏蔽幽灵列，避免视觉干扰
        final bool rowDraggingActive =
            _draggingRowIndex != null || _hoveringExternalRow;
        // 列幽灵判定：使用控制器统一计算外层是否扩展
        final bool hasColGhost =
            _dragController.shouldExpandOuterForColumnGhost(
          hoveringExternalPillar: _hoveringExternalPillar,
          rowDraggingActive: rowDraggingActive,
        );
        // 行幽灵判定：使用控制器统一计算外层是否扩展
        final bool hasRowGhost = _dragController.shouldExpandOuterForRowGhost(
          hoveringExternalRow: _hoveringExternalRow,
        );
        // 卡片外部悬停时，幽灵列宽度使用控制器统一解析
        // final double ghostWidth = _dragController.resolveGhostColumnWidth(
        //   hoveringExternalPillar: _hoveringExternalPillar,
        //   externalHoverWidth: _externalColHoverWidth,
        //   defaultWidth: pillarWidth,
        // );
        final double extraColWidth = hasColGhost ? _externalColHoverWidth : 0.0;
        // 行幽灵高度：使用控制器统一解析（外部载荷高度优先，否则回退）
        // final double ghostHeight = _dragController.resolveGhostRowHeight(
        //   hoveringExternalRow: hasRowGhost,
        //   externalHoverHeight: _externalRowHoverHeight,
        //   fallbackHeight: otherCellHeight,
        // );
        final double extraRowHeight =
            hasRowGhost ? _externalRowHoverHeight : 0.0;
        final BoxDecoration? baseDeco =
            widget.themeNotifier.value.card.toBoxDecoration();
        BoxDecoration? effectiveDeco = baseDeco;
        if (baseDeco != null && baseDeco.borderRadius != null) {
          final br = baseDeco.borderRadius!.resolve(Directionality.of(context));
          final maxR = math.min(size.width, size.height) / 4.0;
          final clamped = BorderRadius.only(
            topLeft: Radius.circular(math.min(br.topLeft.x, maxR)),
            topRight: Radius.circular(math.min(br.topRight.x, maxR)),
            bottomLeft: Radius.circular(math.min(br.bottomLeft.x, maxR)),
            bottomRight: Radius.circular(math.min(br.bottomRight.x, maxR)),
          );
          effectiveDeco = baseDeco.copyWith(borderRadius: clamped);
        }
        // print("effectiveDeco: ${effectiveDeco?.boxShadow}");
        return Stack(
          children: [
            ValueListenableBuilder<EditableFourZhuCardTheme>(
              valueListenable: widget.themeNotifier,
              builder: (context, theme, child) {
                final padding = theme.card.padding;
                final borderWidth = (theme.card.border?.enabled ?? false)
                    ? _resolveUniformCardBorderWidth()
                    : 0.0;
                // print(
                // "size.width: ${size.width}, padding.left: ${padding.left}, padding.right: ${padding.right}, borderWidth: $borderWidth");
                // DEBUG: Print size info
                // print(
                //     "DEBUG: size=${size.width}x${size.height}, padding=${padding}, extraColWidth=$extraColWidth");

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubic,
                  key: _cardKey,
                  padding: padding,
                  width: _pixelCeil(size.width +
                      padding.left +
                      padding.right +
                      borderWidth * 2 +
                      extraColWidth),
                  height: _pixelCeil(size.height +
                      padding.top +
                      padding.bottom +
                      borderWidth * 2 +
                      extraRowHeight),
                  alignment: _preferCenterAlignment
                      ? Alignment.center
                      : AlignmentDirectional.topStart,
                  clipBehavior: Clip.none,
                  decoration: effectiveDeco,
                  child: _buildGrid(size),
                );
              },
            ),

            // 全卡列插入 DragTarget：在卡片任意位置悬停时计算列插入索引
            Positioned.fill(
              child: DragTarget<Object>(
                onWillAcceptWithDetails: (DragTargetDetails<Object> details) {
                  final data = details.data;
                  final ok = (data is Tuple2 &&
                          data.item1 is _DragKind &&
                          data.item1 == _DragKind.column) ||
                      (data is PillarPayload) ||
                      (data is PillarType) ||
                      (data is TitleColumnPayload) ||
                      (data is PillarData);
                  if (ok) {
                    // 外部悬停驱动的尺寸扩展：回到顶部起始对齐（批处理调度）
                    _preferCenterAlignment = false;
                    if (data is PillarPayload || data is PillarType) {
                      _hoveringExternalPillar = true;
                      // 设置默认插入索引为末尾，onMove 会更新为实际位置
                      final pillars = _currentPillars();
                      _hoverColumnInsertIndex = pillars.length;
                      _lastColInsertIndex = pillars.length;

                      // ✅ 方案 A：仅设置 _externalColHoverWidth，不修改 _sizeNotifier
                      // AnimatedContainer 会自动叠加 _externalColHoverWidth 到 size.width
                      if (data is PillarPayload) {
                        if (data.pillarType == PillarType.separator) {
                          _externalColHoverWidth = _colDividerWidthEffective;
                        } else if (data.pillarType ==
                            PillarType.rowTitleColumn) {
                          _externalColHoverWidth = rowTitleWidth;
                        } else {
                          _externalColHoverWidth = _metricsSnapshotNotifier
                              .value.defaultGlobalPillarMetric.totalWidth;
                        }
                      } else if (data is PillarType) {
                        if (data == PillarType.separator) {
                          _externalColHoverWidth = _colDividerWidthEffective;
                        } else if (data == PillarType.rowTitleColumn) {
                          _externalColHoverWidth = rowTitleWidth;
                        } else {
                          _externalColHoverWidth = pillarWidth;
                        }
                      }
                    }
                    // 进入列插入目标时，清理行插入提示状态，避免相互干扰
                    _hoverRowInsertIndex = null;
                    _lastRowInsertIndex = null;
                    _hoveringExternalRow = false;
                    _externalRowHoverHeight = 0.0;
                    _scheduleRebuild();
                  }
                  return ok;
                },
                onMove: (details) {
                  // 统一节流：避免过度重绘
                  if (!_dragController.allowColumnMove()) {
                    return;
                  }

                  final isExternal = details.data is PillarPayload ||
                      details.data is PillarType ||
                      details.data is PillarData;
                  if (_hoveringExternalPillar != isExternal) {
                    _hoveringExternalPillar = isExternal;
                    _scheduleRebuild();
                  }

                  // 外部柱悬停：更新幽灵列宽度（若载荷提供 columnWidth 则优先使用）
                  if (isExternal) {
                    double nextW = _metricsSnapshotNotifier
                        .value.defaultGlobalPillarMetric.totalWidth;
                    // double nextW = pillarWidth;
                    final data = details.data;
                    if (data is PillarPayload || data is PillarData) {
                      // nextW = _metricsSnapshotNotifier
                      // .value.defaultGlobalPillarMetric.totalWidth;

                      // nextW = (data.pillarType == PillarType.separator)
                      // ? _colDividerWidthEffective
                      // : (data.pillarType == PillarType.rowTitleColumn
                      // ? rowTitleWidth
                      // : pillarWidth);
                    } else if (data is PillarType) {
                      if (data == PillarType.separator) {
                        nextW = _colDividerWidthEffective;
                      } else if (data == PillarType.rowTitleColumn) {
                        nextW = rowTitleWidth;
                      }
                    }

                    if (_externalColHoverWidth != nextW) {
                      _externalColHoverWidth = nextW;
                      // _cardNotragInSize = _sizeNotifier.value;
                      // _sizeNotifier.value = Size(
                      // _externalColHoverWidth + size.width, size.height);
                      _scheduleRebuild();
                    }
                  }

                  final box =
                      _cardKey.currentContext?.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  final local = box.globalToLocal(details.offset);
                  // 统一使用控制器进行列坐标归一化（扣除抓手与可选标题列宽度）
                  final dx = _dragController.normalizeColumnDx(
                    localDx: local.dx,
                    gripWidth: _effectiveDragHandleColWidth,
                    rowTitleWidth: rowTitleWidth,
                    hasRowTitleColumnInGrid: _hasRowTitleColumnInGrid(pillars),
                  );
                  // 计算插入索引（中点规则，支持不等宽列）
                  final spans = List<double>.generate(
                    pillars.length,
                    (i) => _colWidthAtIndex(i, pillars),
                  );
                  final candidate =
                      _dragController.computeInsertIndexByMidpoints(dx, spans);
                  final last = _hoverColumnInsertIndex ?? _lastColInsertIndex;

                  if (last == null) {
                    _hoverColumnInsertIndex = candidate;
                    _lastColInsertIndex = candidate;
                    _scheduleRebuild();
                    final wi = _dragController.wantsInsertOnHoverChange(
                      candidate: candidate,
                      last: last,
                    );
                    _dragWantsInsert.value = wi;
                    _dragWantsDelete.value = false;
                    return;
                  }
                  if (candidate == last) return;

                  // 滞回判定：越过中点 ± margin 时允许切换
                  final bool allowUpdate =
                      _dragController.allowColumnHysteresisSwitch(
                    candidate: candidate,
                    last: last,
                    coord: dx,
                    spans: spans,
                    fallbackSpan: _getGhostColumnWidth(),
                    fraction: _colHysteresisFrac, // 可选覆盖默认值
                  );
                  if (!allowUpdate) return;
                  _hoverColumnInsertIndex = candidate;
                  _lastColInsertIndex = candidate;
                  _scheduleRebuild();
                  final wi = _dragController.wantsInsertOnHoverChange(
                    candidate: candidate,
                    last: last,
                  );
                  _dragWantsInsert.value = wi;
                  _dragWantsDelete.value = false;
                },
                onLeave: (_) {
                  _hoverColumnInsertIndex = null;
                  _lastColInsertIndex = null;
                  _hoveringExternalPillar = false;
                  _scheduleRebuild();
                  // if (_externalColHoverWidth != 0.0) {
                  //   _sizeNotifier.value = _cardNotragInSize!;
                  //   _cardNotragInSize = null;
                  // }
                  _externalColHoverWidth = 0.0;

                  _dragWantsInsert.value = false;
                  _dragWantsDelete.value = _dragController.wantsDeleteOnLeave();
                },
                onAccept: (payload) {
                  final insertIndex = _hoverColumnInsertIndex ?? 0;
                  _hoverColumnInsertIndex = null;
                  _lastColInsertIndex = null;
                  _draggingColumnIndex = null;
                  _hoveringExternalPillar = false;
                  _externalColHoverWidth = 0.0;
                  _scheduleRebuild();
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
                    _insertExternalPillar(insertIndex, payload);
                  } else if (payload is PillarData) {
                    final pillarId = Uuid().v4();
                    final pillarContent = PillarContent(
                      id: pillarId,
                      pillarType: payload.pillarType,
                      label: payload.label, // 使用 PillarData 的 label 字段
                      jiaZi: payload.jiaZi,
                      version: "1",
                      sourceKind: PillarSourceKind.userInput,
                    );
                    final contentPillarPayload = ContentPillarPayload(
                      uuid: pillarId,
                      pillarType: payload.pillarType,
                      pillarLabel: payload.label, // 使用 PillarData 的 label 字段
                      pillarContent: pillarContent,
                    );

                    _insertExternalPillar(insertIndex, contentPillarPayload);
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
                        decoration: CardDecorators.buildDeleteIntentDecoration(
                          context,
                          borderRadius: 12,
                          borderWidth: 2,
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
                final hasRowTitleCol = _hasRowTitleColumnInGrid(pillars);
                final left = dragHandleColWidth +
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
                    final rowPayloads = _currentRows();
                    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
                        rowPayloads[0].rowType == RowType.columnHeaderRow;

                    final List<double> midYs = [];
                    final List<double> rowHeights = [];

                    // 坐标系对齐：从整个卡片顶部开始计算
                    // acc 初始值 = topGripRow 高度（padding 由 Container 处理）
                    double acc = _effectiveDragHandleRowHeight;

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
                      painter: RowBoundaryPainter(
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

  bool get _rowDraggingActive =>
      _draggingRowIndex != null || _hoveringExternalRow;

  Widget _buildGrid(Size size) {
    final pillars = _currentPillars();
    final rows = _currentRowLabels();

    final metricsSnap = _metricsSnapshotNotifier.value;
    // print("===============");
    // metricsSnap.rows.forEach((key, value) {
    //   print("${value.rowType.name}: ${value.height}");
    // });
    // print("===============");

    // print(metricsSnap.rows.keys.length);
    // 检查是否存在行标题列（在方法开头统一定义，避免重复）
    final hasRowTitleColumn = _hasRowTitleColumnInGrid(pillars);
    // 仅在外部柱悬停时，为插入位预留一列的宽度（内部重排不扩展卡片）
    // 行拖拽进行中时，强制屏蔽网格内的幽灵列
    final bool rowDraggingActive =
        _draggingRowIndex != null || _hoveringExternalRow;
    final bool hasColGhost = _hoveringExternalPillar && !rowDraggingActive;
    double ghostWidth = _dragController.resolveGhostColumnWidth(
      hoveringExternalPillar: _hoveringExternalPillar,
      externalHoverWidth: _externalColHoverWidth,
      defaultWidth: pillarWidth,
    );
    // 统一列让位逻辑：内部拖拽（包括末尾）使用网格内 AnimatedContainer，不扩展容器
    final double extraColWidth = hasColGhost ? ghostWidth : 0.0;
    // 标题列仅通过 payload 参与度量；不再为缺省标题列预留固定宽度
    final totalWidth = _totalColsWidth(pillars) + extraColWidth;
    // print("DEBUG: _buildGrid totalWidth=$totalWidth, size.width=${size.width}");

    // Top Grip row: 顶部抓手行，用于拖拽列
    final topGripRow = _buildTopGripRow(
      pillars,
      rows,
      totalWidth,
    );
    // Bottom Grip row: 底部抓手行，用于拖拽列
    final gripRow = _buildBottomGripRow(
      pillars,
      rows,
      totalWidth,
    );
    // Left Grip column: 左侧抓手列，用于拖拽行
    // 叠加 DragTarget 覆盖整个抓手列区域，确保行拖拽经过此列也会持续更新插入索引，从而显示幽灵行
    final leftGripColumn = _buildLeftGripColumn(rows, pillars);
    // Right Grip column: 右侧抓手列，用于拖拽行
    // 叠加 DragTarget 覆盖整个抓手列区域，确保行拖拽经过此列也会持续更新插入索引，从而显示幽灵行
    final gripColumn = _buildRightGripColumn(rows, pillars);

    // Left header column: row titles; overlay a unified drag target for continuous row index updates
    // final leftHeader = _buildLeftHeader(rows);
    // Data grid: according to current row order
    final dataGrid = _buildDataGrid(pillars, rows, metricsSnap, extraColWidth);

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
              child: widget.showGrip ? topGripRow : const SizedBox.shrink(),
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
                  child: widget.showGrip
                      ? leftGripColumn
                      : const SizedBox.shrink(),
                ),
                // if (!hasRowTitleColumn) leftHeader, // 仅在无行标题列时渲染
                // 重绘边界：隔离数据网格的重绘，减少拖拽悬停状态下对外层的影响
                RepaintBoundary(child: dataGrid),
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
                  child: widget.showGrip ? gripColumn : const SizedBox.shrink(),
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
              child: widget.showGrip ? gripRow : const SizedBox.shrink(),
            ),
          ],
        ),
        // 统一的全区域行拖拽 DragTarget：覆盖整个网格（包括 topGripRow 和 bottomGripRow）
        Positioned.fill(
          child: Builder(
            builder: (builderContext) => DragTarget<Object>(
              onWillAcceptWithDetails: (DragTargetDetails<Object> details) {
                final data = details.data;
                assert(() {
                  debugPrint('RowDragTarget onWillAccept data=$data');
                  return true;
                }());
                final ok = (data is Tuple2 && data.item1 == _DragKind.row) ||
                    (data is TextRowPayload) ||
                    (data is RowData) ||
                    (data is TitleRowPayload) ||
                    (data is RowSeparatorPayload) ||
                    (data is RowType);
                if (ok) {
                  _hoverColumnInsertIndex = null;
                  _lastColInsertIndex = null;
                  _hoveringExternalPillar = false;
                  _scheduleRebuild();
                  _rowSpansCache = _computeCurrentRowSpans();
                  final rows = _currentRowLabels();
                  if (data is Tuple2 && data.item1 == _DragKind.row) {
                    _hoverRowInsertIndex = rows.length;
                    _lastRowInsertIndex = rows.length;
                    _scheduleRebuild();
                  } else if (data is TextRowPayload ||
                      data is RowData ||
                      data is RowSeparatorPayload ||
                      (data is RowType)) {
                    _hoveringExternalRow = true;
                    final bool isSeparator = (data is TextRowPayload &&
                            data.rowType == RowType.separator) ||
                        (data is RowData &&
                            data.rowType == RowType.separator) ||
                        (data is RowSeparatorPayload) ||
                        (data is RowType && data == RowType.separator);
                    final bool isTitle = (data is TextRowPayload &&
                            data.rowType == RowType.columnHeaderRow) ||
                        (data is RowType && data == RowType.columnHeaderRow);
                    _externalRowHoverHeight = isSeparator
                        ? _rowDividerHeightEffective
                        : (isTitle
                            ? columnTitleHeight
                            : _metricsSnapshotNotifier
                                .value.defaultGlobalRowMetric.totalHeight);
                    _hoverRowInsertIndex = rows.length;
                    _lastRowInsertIndex = rows.length;
                    _scheduleRebuild();
                  }
                }
                return ok;
              },
              onMove: (details) {
                assert(() {
                  debugPrint(
                      'RowDragTarget onMove dy=${details.offset.dy} data=${details.data}');
                  return true;
                }());
                final data = details.data;
                final isRowPayload =
                    (data is Tuple2 && data.item1 == _DragKind.row) ||
                        (data is TextRowPayload) ||
                        (data is RowData) ||
                        (data is TitleRowPayload) ||
                        (data is RowSeparatorPayload) ||
                        (data is RowType);
                if (!isRowPayload) return;
                if (!_dragController.allowRowMove()) {
                  return;
                }

                // 外部行悬停：更新幽灵行高度（区分分隔符与普通行）
                final bool isExternal = (data is TextRowPayload) ||
                    (data is RowData) ||
                    (data is RowSeparatorPayload) ||
                    (data is RowType);
                if (isExternal) {
                  final bool isSeparator = (data is TextRowPayload &&
                          data.rowType == RowType.separator) ||
                      (data is RowData && data.rowType == RowType.separator) ||
                      (data is RowSeparatorPayload) ||
                      (data is RowType && data == RowType.separator);
                  final double h = isSeparator
                      ? _rowDividerHeightEffective
                      : _metricsSnapshotNotifier
                          .value.defaultGlobalRowMetric.totalHeight;
                  if (_hoveringExternalRow != true ||
                      _externalRowHoverHeight != h) {
                    _hoveringExternalRow = true;
                    _externalRowHoverHeight = h;
                    _scheduleRebuild();
                  }
                }

                final box =
                    _cardKey.currentContext?.findRenderObject() as RenderBox?;
                if (box == null) {
                  return;
                }
                final local = box.globalToLocal(details.offset);
                // 统一使用控制器进行行坐标归一化（扣除顶部抓手行高度）
                final dy = _dragController.normalizeRowDy(
                  localDy: local.dy,
                  topGripHeight: _effectiveDragHandleRowHeight,
                  gripVisible: widget.showGrip,
                );
                // 现在 dy = 0 对应 leftGripColumn 顶部（行内容开始）
                // _computeRowInsertIndexFromDyMidpoint 的 acc 也从 0 开始（行内容开始）
                // 两者坐标系一致

                final rows = _currentRowLabels();
                // 计算插入索引（中点规则，支持不等高行）
                final spans = _rowSpansCache ?? _computeCurrentRowSpans();
                _rowSpansCache = spans;
                final candidate =
                    _dragController.computeInsertIndexByMidpoints(dy, spans);
                final last = _hoverRowInsertIndex ?? _lastRowInsertIndex;

                if (last == null) {
                  _hoverRowInsertIndex = candidate;
                  _lastRowInsertIndex = candidate;
                  _scheduleRebuild();
                  final wi = _dragController.wantsInsertOnHoverChange(
                    candidate: candidate,
                    last: last,
                  );
                  _dragWantsInsert.value = wi;
                  _dragWantsDelete.value = false;
                  return;
                }
                // 顶部插入位特殊处理：当目标为表头行之前（索引0）或第一个可拖拽行（索引1）时立即更新，避免不让位
                if (candidate == 0 || candidate == 1) {
                  _hoverRowInsertIndex = candidate;
                  _lastRowInsertIndex = candidate;
                  _scheduleRebuild();
                  final wi = _dragController.wantsInsertOnHoverChange(
                    candidate: candidate,
                    last: last,
                  );
                  _dragWantsInsert.value = wi;
                  _dragWantsDelete.value = false;
                  return;
                }
                if (candidate == last) return;

                // 滞回判定：越过中点 ± margin 时允许切换
                final bool allowUpdate =
                    _dragController.allowRowHysteresisSwitch(
                  candidate: candidate,
                  last: last,
                  coord: dy,
                  spans: spans,
                  fallbackSpan:
                      _getGhostRowHeight(fallbackHeight: otherCellHeight),
                  fraction: _rowHysteresisFrac, // 可选覆盖默认值
                );

                if (!allowUpdate) return; // 在滞回缓冲区内，不触发切换

                _hoverRowInsertIndex = candidate;
                _lastRowInsertIndex = candidate;
                _scheduleRebuild();
                final wi = _dragController.wantsInsertOnHoverChange(
                  candidate: candidate,
                  last: last,
                );
                _dragWantsInsert.value = wi;
                _dragWantsDelete.value = false;
              },
              onLeave: (_) {
                _hoverRowInsertIndex = null;
                _lastRowInsertIndex = null;
                _hoveringExternalRow = false;
                _externalRowHoverHeight = 0.0;
                // 调试：输出节流计数与重建采样（仅调试态）
                assert(() {
                  final counters = takeAndResetDragMoveCounts();
                  final sampling = takeAndResetRebuildSampling();
                  final notifier = takeAndResetNotifierSampling();
                  debugPrint(
                      'RowDragTarget onLeave counters=$counters, sampling=$sampling, notifier=$notifier');
                  return true;
                }());
                _resetRowSpansCache();
                _scheduleRebuild();
                _dragWantsInsert.value = false;
                _dragWantsDelete.value = _dragController.wantsDeleteOnLeave();
              },
              onAcceptWithDetails: (DragTargetDetails<Object> details) {
                final payload = details.data;

                print(
                    "onAcceptWithDetails ${payload.runtimeType} payload=$payload");
                assert(() {
                  debugPrint(
                      'RowDragTarget onAccept payload=$payload hoverIdx=$_hoverRowInsertIndex');
                  return true;
                }());
                if (_rowAccepting) return;
                _rowAccepting = true;
                final insertIndex = _hoverRowInsertIndex ?? 1;
                _hoverRowInsertIndex = null;
                _lastRowInsertIndex = null;
                _draggingRowIndex = null;
                _hoveringExternalRow = false;
                // ⚠️ 不在这里清零 _externalRowHoverHeight，在 _insertExternalRow 后清零
                // _externalRowHoverHeight = 0.0;
                // 调试：输出节流计数与重建采样（仅调试态）
                assert(() {
                  final counters = takeAndResetDragMoveCounts();
                  final sampling = takeAndResetRebuildSampling();
                  final notifier = takeAndResetNotifierSampling();
                  debugPrint(
                      'RowDragTarget onAccept counters=$counters, sampling=$sampling, notifier=$notifier');
                  return true;
                }());
                _resetRowSpansCache();
                _scheduleRebuild();
                if (payload is Tuple2) {
                  final kind = payload.item1;
                  final fromAbsIdx = payload.item2 as int;
                  if (kind == _DragKind.row) {
                    _reorderRows(fromAbsIdx, insertIndex);
                  }
                } else if (payload is TextRowPayload) {
                  _insertExternalRow(insertIndex, payload);
                } else if (payload is RowData) {
                  if (payload.rowType == RowType.separator) {
                    final p = RowSeparatorPayload(
                      uuid: const Uuid().v4(),
                    );
                    _insertExternalRow(insertIndex, p);
                  } else {
                    final p = TextRowPayload(
                      uuid: const Uuid().v4(),
                      rowType: payload.rowType,
                      rowLabel: payload.label,
                      titleInCell: widget.themeNotifier.value.displayCellTitle,
                    );
                    _insertExternalRow(insertIndex, p);
                  }
                } else if (payload is RowSeparatorPayload) {
                  final p = RowSeparatorPayload(
                    uuid: const Uuid().v4(),
                  );
                  _insertExternalRow(insertIndex, p);
                } else if (payload is RowType) {
                  final p = TextRowPayload(
                    uuid: const Uuid().v4(),
                    rowType: payload,
                    rowLabel: payload.name,
                    titleInCell: widget.themeNotifier.value.displayCellTitle,
                  );
                  _insertExternalRow(insertIndex, p);
                }
                Future.microtask(() {
                  if (!mounted) return;
                  _rowAccepting = false;
                  _scheduleRebuild();
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

  Widget _buildDataGrid(
    List<PillarPayload> pillars,
    List<String> rows,
    CardMetricsSnapshot metricsSnap,
    double extraColWidth,
  ) {
    // Use passed metricsSnap to ensure consistency with children
    final containerW = _pixelFloor(metricsSnap.totals.totalWidth +
        extraColWidth +
        1.0); // Add 1.0 buffer for rounding errors
    // print("DEBUG: DataGrid Container Width=$containerW");

    return Container(
      // 数据网格总宽按可变列宽总和计算（像素对齐，避免子像素溢出）
      width: containerW,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. 网格分隔线绘制（叠加层底部） separator
          // _buildGridLines(pillars, rows),

          // 2. 数据列（核心内容）
          _buildPillarsRow(pillars, rows, metricsSnap),

          // 3. 行插入指示线与高亮
          ..._buildRowInsertionOverlays(pillars, rows),

          // 4. 垂直分割线拖拽手柄
          _buildResizeHandles(pillars),
        ],
      ),
    );
  }

  Widget _buildGridLines(List<PillarPayload> pillars, List<String> rows) {
    return Builder(builder: (context) {
      final List<double> vXs = List.generate(pillars.length, (i) => i)
          // .where((i) => _isSeparatorColumnIndex(i))
          .where((i) => pillars[i].pillarType == PillarType.separator)
          .map((i) =>
              _sumColWidthsUpTo(i, pillars) +
              (widget.themeNotifier.value.pillar
                          .getBy(PillarType.separator)
                          .separatorWidth! +
                      widget.themeNotifier.value.pillar
                          .getBy(PillarType.separator)
                          .getDecorationWidth()) *
                  .5)
          .toList();
      // 计算水平分隔线的 Y 坐标
      final List<double> hYs = <double>[];
      for (int ri = 0; ri < rows.length; ri++) {
        if (_isSeparatorRowAtIndex(ri)) {
          final double top = _computeRowTopFromIndex(ri, rows);
          hYs.add(top + _rowDividerHeightEffective / 2);
        }
      }
      // 叠加层左内边距
      double painterLeftInset = 0;
      final payloads = _currentPillars();
      for (int i = 0; i < pillars.length && i < payloads.length; i++) {
        if (payloads[i].pillarType == PillarType.rowTitleColumn) {
          painterLeftInset = _colWidthAtIndex(i, pillars);
          break;
        }
      }
      return Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: CardGridPainter(
              verticalXs: vXs,
              horizontalYs: hYs,
              topInset: 0,
              leftInset: painterLeftInset,
              columnColor: Theme.of(context).dividerColor,
              columnThickness: _colDividerThickness,
              rowColor: Theme.of(context).dividerColor,
              rowThickness: _rowDividerThickness,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPillarsRow(
    List<PillarPayload> pillars,
    List<String> rows,
    CardMetricsSnapshot metricsSnap,
  ) {
    // final children = _buildPillarWidgets(pillars, rows, metricsSnap);
    // DEBUG: Sum children width (assuming they are RepaintBoundary->AnimatedSlide->Stack->...->Container(width))
    // We can't easily check widget width here, but we can check _calculatePillarContentWidth
    // double sumW = 0.0;
    // for (int i = 0; i < pillars.length; i++) {
    //   // bool isSep = _isSeparatorColumnIndex(i);
    //   bool isSep = pillars[i].pillarType ==
    //       PillarType.separator; // Check payload directly
    //   sumW += _calculatePillarContentWidth(i, pillars, isSep, metricsSnap);
    // }
    // print("DEBUG: _buildPillarsRow Sum(children)=$sumW");

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _buildPillarWidgets(pillars, rows, metricsSnap),
    );
  }

  List<Widget> _buildPillarWidgets(
    List<PillarPayload> pillars,
    List<String> rows,
    CardMetricsSnapshot metricsSnap,
  ) {
    final d = _draggingColumnIndex;
    final t = _hoverColumnInsertIndex ?? _lastColInsertIndex;
    final List<Widget> children = [];

    for (int i = 0; i < pillars.length; i++) {
      // 1. 插入幽灵列（拖拽占位）
      children.add(_buildGhostColumn(i, t, d, pillars));

      if (d == i) continue; // 拖拽中的列不占原位置

      // 2. 构建真实列
      children.add(_buildRealPillar(i, pillars, rows, metricsSnap));
    }

    // 3. 末尾幽灵列
    children.add(_buildEndGhostColumn(t, d, pillars));

    return children;
  }

  Widget _buildGhostColumn(int index, int? targetIndex, int? dragIndex,
      List<PillarPayload> pillars) {
    final bool dragging =
        (dragIndex != null || _hoveringExternalPillar) && !_rowDraggingActive;
    final double gridGhostWidth = (dragIndex != null)
        ? _colWidthAtIndex(dragIndex, pillars)
        : _pixelFloor(_getGhostColumnWidth());

    return AnimatedContainer(
      duration: dragging ? const Duration(milliseconds: 180) : Duration.zero,
      curve: Curves.easeOut,
      width: dragging && targetIndex == index ? gridGhostWidth : 0,
      color: Colors.red,
      child: dragging && targetIndex == index
          ? GhostPillarWidget.column(
              width: gridGhostWidth,
              height: _metricsSnapshotNotifier
                  .value.defaultGlobalPillarMetric.totalHeight,
              // height:
              //     _layoutNotifier.value.totalRowsHeight(_measurementContext),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildEndGhostColumn(
      int? targetIndex, int? dragIndex, List<PillarPayload> pillars) {
    final bool dragging =
        (dragIndex != null || _hoveringExternalPillar) && !_rowDraggingActive;
    final double endGhostWidth = (dragIndex != null)
        ? _colWidthAtIndex(dragIndex, pillars)
        : _getGhostColumnWidth();

    return AnimatedContainer(
      duration: dragging ? const Duration(milliseconds: 180) : Duration.zero,
      curve: Curves.easeOut,
      width: dragging && targetIndex == pillars.length ? endGhostWidth : 0,
      child: dragging && targetIndex == pillars.length
          ? GhostPillarWidget.column(
              width: endGhostWidth,
              height: _metricsSnapshotNotifier
                  .value.defaultGlobalPillarMetric.totalHeight,
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildRealPillar(
    int i,
    List<PillarPayload> pillars,
    List<String> rows,
    CardMetricsSnapshot metricsSnap,
  ) {
    final payload = pillars[i];
    final jz = _pillarJiaZiFromPayload(payload);
    final pillarPayloads = _currentPillars();
    final bool isSeparatorColumn = _isSeparatorColumnIndex(i);
    final isRowTitleCol = (i >= 0 && i < pillarPayloads.length) &&
        pillarPayloads[i].pillarType == PillarType.rowTitleColumn;

    final double colW = _calculatePillarContentWidth(
        i, pillarPayloads, isSeparatorColumn, metricsSnap);
    Widget columnContent = Column(
      children: _buildPillarCells(
        i,
        colW,
        rows,
        // pillarPayloads,
        isRowTitleCol,
        isSeparatorColumn,
        payload,
        jz,
        metricsSnap,
      ),
    );

    // 【方案A优化】为每个柱创建或复用 GlobalKey，用于拖拽时复用 Widget
    _pillarGlobalKeys[i] ??= GlobalKey(debugLabel: 'pillar-$i');

    // 【方案A优化】使用 RepaintBoundary 包装整个柱，使其渲染边界独立
    // 这样可以通过 GlobalKey 引用已渲染的 Widget 树
    return RepaintBoundary(
      key: _pillarGlobalKeys[i],
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        offset: (_dropColFadeActive && _dropAnimatingColIndex == i)
            ? const Offset(0, 0)
            : Offset.zero,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              opacity: (_dropColFadeActive && _dropAnimatingColIndex == i)
                  ? 0.0
                  : 1.0,
              child: _buildEachPillar(i, colW, columnContent),
            ),
            _buildPillarDragPlaceholder(i),
          ],
        ),
      ),
    );
  }

  double _calculatePillarContentWidth(
    int i,
    // List<Tuple2<String, JiaZi>> pillars,
    List<PillarPayload> pillarPayloads,
    bool isSeparatorColumn,
    CardMetricsSnapshot metricsSnap,
  ) {
    // Prioritize metrics from snapshot to ensure consistency with container width (totals.totalWidth)
    // and to fix gap issues (use totalWidth because _buildEachPillar subtracts margin).
    final pm = metricsSnap.pillars[pillarPayloads[i].uuid];
    if (pm != null) {
      return _pixelFloor(pm.totalWidth);
    }

    // Fallback: if metrics missing (e.g. stale during update), return 0 to avoid overflow
    // Previously we returned separatorWidth directly for separators, which caused overflow
    // when metricsSnap didn't include the separator yet.
    return 0.0;
  }

  List<Widget> _buildPillarCells(
    int pillarIndex,
    double colW,
    List<String> rows,
    bool isRowTitleCol,
    bool isSeparatorColumn,
    PillarPayload payload,
    JiaZi jz,
    CardMetricsSnapshot metricsSnap,
  ) {
    final dRow = _draggingRowIndex;
    final tRow = _hoverRowInsertIndex ?? _lastRowInsertIndex;
    final List<Widget> rowChildren = [];

    // Prepare computation input
    // final pillarContents = pillarPayloads
    //     .whereType<ContentPillarPayload>()
    //     .map((p) => p.pillarContent)
    //     .toList();
    final dayJiaZi = widget.dayGanZhi;

    final bool draggingRow = dRow != null || _hoveringExternalRow;

    for (final rEntry in rows.asMap().entries) {
      final absRowIdx = rEntry.key;
      final rowName = rEntry.value;
      final rowSize = _rowCellSize(rowName);

      // 1. 行幽灵占位
      rowChildren.add(
          _buildGhostRow(absRowIdx, tRow, draggingRow, colW, rowSize.height));

      if (dRow == absRowIdx) continue; // 拖拽中的行不占原位置

      // 2. 构建真实单元格
      Widget cell = _buildSingleCell(
        pillarIndex,
        absRowIdx,
        colW,
        rowSize,
        isRowTitleCol,
        isSeparatorColumn,
        payload,
        jz,
        metricsSnap,
        dayJiaZi,
      );

      rowChildren.add(_buildAnimatedCellWrapper(
          cell, absRowIdx, tRow, draggingRow, isRowTitleCol));
    }
    return rowChildren;
  }

  JiaZi _getDayJiaZi(List<PillarContent> pillarContents) {
    return widget.dayGanZhi;
    try {
      return pillarContents
          .firstWhere((c) => c.pillarType == PillarType.day)
          .jiaZi;
    } catch (_) {
      return pillarContents.isNotEmpty
          ? pillarContents.first.jiaZi
          : JiaZi.JIA_ZI;
    }
  }

  Widget _buildGhostRow(int absRowIdx, int? targetRowIdx, bool draggingRow,
      double colW, double rowHeight) {
    return AnimatedContainer(
      duration: draggingRow ? const Duration(milliseconds: 180) : Duration.zero,
      curve: Curves.easeOut,
      width: colW,
      height: draggingRow && targetRowIdx == absRowIdx
          ? _getGhostRowHeight(fallbackHeight: rowHeight)
          : 0,
      color: draggingRow && targetRowIdx == absRowIdx
          ? Theme.of(context).colorScheme.secondary.withOpacity(0.08)
          : Colors.transparent,
    );
  }

  Widget _buildSingleCell(
    int pillarIndex,
    int absRowIdx,
    double colW,
    Size rowSize,
    bool isRowTitleCol,
    bool isSeparatorColumn,
    PillarPayload payload,
    JiaZi jz,
    // List<PillarPayload> pillarPayloads,
    CardMetricsSnapshot metricsSnap,
    JiaZi dayJiaZi,
  ) {
    // print("~~~~~~~~~ $isSeparatorColumn");
    if (isRowTitleCol) {
      return _buildRowTitleCell(absRowIdx, rowSize);
    } else if (isSeparatorColumn) {
      // return _buildSeparatorCell(colW, rowSize.height);
      return SizedBox(
        width: colW,
        height: rowSize.height,
      );
    } else {
      return _buildDataCell(
        pillarIndex,
        absRowIdx,
        // pillarPayloads,
        payload as ContentPillarPayload,
        metricsSnap,
        jz,
        dayJiaZi,
      );
    }
  }

  /// 构建 Separator 单元格
  /// 显示竖直分割线或带背景色的色块
  Widget _buildSeparatorCell(double width, double height) {
    final separatorConfig =
        widget.themeNotifier.value.pillar.getBy(PillarType.separator);
    final brightness = widget.brightnessNotifier.value;
    final bgColor = brightness == Brightness.light
        ? separatorConfig.lightBackgroundColor
        : separatorConfig.darkBackgroundColor;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          // color: bgColor,
          // 可选：添加边框来模拟分割线效果
          // border: separatorConfig.border?.enabled ?? false
          //     ? Border(
          //         left: BorderSide(
          //           color: separatorConfig.border!.lightColor ??
          //               Colors.grey.shade400,
          //           width: 0.5,
          //         ),
          //         right: BorderSide(
          //           color: separatorConfig.border!.lightColor ??
          //               Colors.grey.shade400,
          //           width: 0.5,
          //         ),
          //       )
          //     : null,
          ),
    );
  }

  Widget _buildRowTitleCell(int absRowIdx, Size rowSize) {
    if (_isSeparatorRowAtIndex(absRowIdx)) {
      return Container(
        width: rowTitleWidth,
        height: rowSize.height,
        // decoration: CardDecorators.buildRowSeparatorDecoration(
        //   context,
        //   thickness: _rowDividerThickness,
        // ),
      );
    } else {
      final rowPayloads = _currentRows();
      RowPayload? rPayload;
      if (absRowIdx >= 0 && absRowIdx < rowPayloads.length) {
        rPayload = rowPayloads[absRowIdx];
      }

      if (rPayload is TextRowPayload) {
        final isHeaderRow = rPayload.rowType == RowType.columnHeaderRow;
        final titleWidget = isHeaderRow && rPayload is ColumnHeaderRowPayload
            ? _genderText(rPayload.gender)
            : _rowTitlePillarText(rPayload);
        return Center(child: titleWidget);
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildDataCell(
    int pillarIndex,
    int absRowIdx,
    ContentPillarPayload pillarPayload,
    // List<PillarPayload> pillarPayloads,
    CardMetricsSnapshot metricsSnap,
    JiaZi jz,
    JiaZi dayJiaZi,
  ) {
    final rowPayloads = _currentRows();
    final RowType? rowType = (absRowIdx >= 0 && absRowIdx < rowPayloads.length)
        ? rowPayloads[absRowIdx].rowType
        : null;
    final String rUuid = rowPayloads[absRowIdx].uuid;
    final String pUuid = pillarPayload.uuid;
    final cm = metricsSnap.cells['$rUuid|$pUuid'];

    return _buildPillarsEachCell(
      pillarType: pillarPayload.pillarType,
      rowType: rowType,
      size: cm!.size,
      absRowIdx: absRowIdx,
      rowPayloads: rowPayloads,
      pillarJiaZi: jz,
      gender: widget.gender,
      dayJiaZi: dayJiaZi,
    );
  }

  Widget _buildAnimatedCellWrapper(Widget cell, int absRowIdx, int? tRow,
      bool draggingRow, bool isRowTitleCol) {
    // Check if current row is header row
    final rowPayloads = _currentRows();
    final isCurrentRowHeaderRow = absRowIdx >= 0 &&
        absRowIdx < rowPayloads.length &&
        rowPayloads[absRowIdx].rowType == RowType.columnHeaderRow;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      offset: (_dropRowFadeActive && _dropAnimatingRowIndex == absRowIdx)
          ? const Offset(0, 0)
          : Offset.zero,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            opacity:
                ((_dropRowFadeActive && _dropAnimatingRowIndex == absRowIdx) &&
                        !isCurrentRowHeaderRow)
                    ? 0.0
                    : (_draggingRowIndex == absRowIdx ? 0.9 : 1.0),
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
    );
  }

  Widget _buildPillarDragPlaceholder(int index) {
    final t = _hoverColumnInsertIndex ?? _lastColInsertIndex;
    final d = _draggingColumnIndex;
    final bool dragging =
        (d != null || _hoveringExternalPillar) && !_rowDraggingActive;

    if (dragging && t == index) {
      return Positioned.fill(
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                width: 1,
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  List<Widget> _buildRowInsertionOverlays(
      List<PillarPayload> pillars, List<String> rows) {
    final List<Widget> overlays = [];
    if (_hoverRowInsertIndex == null) return overlays;

    // 1. 插入指示线
    overlays.add(Positioned(
      left: 0,
      top: (_hoverRowInsertIndex == 1)
          ? 0
          : _computeRowInsertTopFromIndex(_hoverRowInsertIndex!, rows) - 1,
      width: _totalColsWidth(pillars),
      height: 2,
      child: Container(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.35),
      ),
    ));

    // 2. 整行高亮
    if (_hoverRowInsertIndex! >= 1 && _hoverRowInsertIndex! < rows.length) {
      overlays.add(Positioned(
        left: 0,
        top: _computeRowTopFromIndex(_hoverRowInsertIndex!, rows),
        width: _totalColsWidth(pillars),
        height: _rowCellSize(rows[_hoverRowInsertIndex!]).height,
        child: IgnorePointer(
          child: Container(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.06),
          ),
        ),
      ));
    }

    // 3. 尾部插入的全宽幽灵行
    if ((_hoverRowInsertIndex ?? _lastRowInsertIndex) == rows.length) {
      overlays.add(Positioned(
        left: 0,
        top: _computeRowInsertTopFromIndex(rows.length, rows),
        width: _totalColsWidth(pillars),
        height: _getGhostRowHeight(fallbackHeight: otherCellHeight),
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.35),
                width: 1,
              ),
            ),
          ),
        ),
      ));
    }

    return overlays;
  }

  Widget _buildResizeHandles(List<PillarPayload> pillars) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Stack(
          children: [
            for (int i = 1; i < pillars.length; i++)
              _buildSingleResizeHandle(i, pillars),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleResizeHandle(int i, List<PillarPayload> pillars) {
    return Builder(builder: (context) {
      final left = _sumColWidthsUpTo(i, pillars) - 4;
      return Positioned(
        left: left,
        top: columnTitleHeight + _pillarDecorationTopOffsetEff,
        bottom: _pillarDecorationBottomOffsetEff,
        width: 8,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              _resizingDividerIndex = i;
              _initialPillarWidth = _colWidthAtIndex(i - 1, pillars) -
                  _pillarDecorationWidthAtIndex(i - 1);
              _scheduleRebuild();
            },
            onPanUpdate: (details) {
              final box =
                  _cardKey.currentContext?.findRenderObject() as RenderBox?;
              if (box == null) return;
              final idx = _resizingDividerIndex ?? i;
              if (idx <= 0) return;
              final targetCol = idx - 1;
              if (_isSeparatorColumnIndex(targetCol)) return;

              final local = box.globalToLocal(details.globalPosition);
              final hasRowTitleCol2 = _hasRowTitleColumnInGrid(pillars);
              final accLeft = hasRowTitleCol2 ? 0 : rowTitleWidth;
              final dx = local.dx - accLeft;

              final sumPrev = _sumColWidthsUpTo(targetCol, pillars);
              double newTotalW = dx - sumPrev;

              final decW = _pillarDecorationWidthAtIndex(targetCol);
              double newContentW =
                  (newTotalW - decW).clamp(_minPillarWidth, _maxPillarWidth);
              _columnWidthOverrides[targetCol] = newContentW;
              _scheduleRebuild();
            },
            onPanEnd: (_) {
              _resizingDividerIndex = null;
              _initialPillarWidth = null;
              _scheduleRebuild();
            },
          ),
        ),
      );
    });
  }

  // ========================================
// 从 _buildGrid 提取的 UI 构建方法
// 应插入到 _buildPillarsEachCell 方法之前（约 L3010）
// ========================================
  /// 构建顶部抓手行，用于拖拽列
  ///
  /// 参数：
  /// - [pillars]: 列数据列表
  /// - [rows]: 行标签列表
  /// - [totalWidth]: 数据网格总宽度
  Widget _buildTopGripRow(
    List<PillarPayload> pillars,
    List<String> rows,
    double totalWidth,
  ) {
    // print(
    //     "DEBUG: TopGripRow totalWidth=$totalWidth, gripWidth=$_effectiveDragHandleColWidth, SizedBox width=${_effectiveDragHandleColWidth * 2 + totalWidth}");
    // double sumChildren = _effectiveDragHandleColWidth * 2;
    // for (int i = 0; i < pillars.length; i++) {
    //   sumChildren += _colWidthAtIndex(i, pillars);
    // }
    // print("DEBUG: TopGripRow sumChildren=$sumChildren");

    return SizedBox(
      // Add a small buffer to avoid floating point rounding errors causing overflow
      width: _effectiveDragHandleColWidth * 2 + totalWidth + 1.0,
      height: _effectiveDragHandleRowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧空白单元格（对应 leftGripColumn）
          SizedBox(
            width: _effectiveDragHandleColWidth,
            height: _effectiveDragHandleRowHeight,
          ),
          ...List.generate(pillars.length, (i) {
            final bool isSeparatorCol = _isSeparatorColumnIndex(i);
            final double colBaseW = _colWidthAtIndex(i, pillars);
            if (isSeparatorCol) {
              // Separator: 显示抓手图标，但不显示标题
              return SizedBox(
                width: colBaseW,
                height: _effectiveDragHandleRowHeight,
                child: Center(
                  child: Draggable<Tuple2<_DragKind, int>>(
                    key: Key('top-col-grip-sep-$i'),
                    data: Tuple2(_DragKind.column, i),
                    onDragStarted: () {
                      _draggingColumnIndex = i;
                      _scheduleRebuild();
                      _dragWantsInsert.value = false;
                      _dragWantsDelete.value = false;
                    },
                    onDraggableCanceled: (velocity, offset) {
                      final outside = !_isGlobalPointInsideCard(offset);
                      if (outside) {
                        _deleteColumn(i);
                      }
                      _draggingColumnIndex = null;
                      _hoverColumnInsertIndex = null;
                      _lastColInsertIndex = null;
                      _scheduleRebuild();
                      _dragWantsInsert.value = false;
                      _dragWantsDelete.value = false;
                    },
                    onDragCompleted: () {
                      _draggingColumnIndex = null;
                      _hoverColumnInsertIndex = null;
                      _lastColInsertIndex = null;
                      _scheduleRebuild();
                      _dragWantsInsert.value = false;
                      _dragWantsDelete.value = false;
                    },
                    dragAnchorStrategy: pointerDragAnchorStrategy,
                    feedback: Material(
                      color: Colors.transparent,
                      child: drag_icon,
                    ),
                    child: drag_icon,
                  ),
                ),
              );
            }
            final title = _pillarLabelFromPayload(pillars[i]);
            final double colW = colBaseW;
            return SizedBox(
              width: colW,
              height: _effectiveDragHandleRowHeight,
              child: Center(
                child: Draggable<Tuple2<_DragKind, int>>(
                  key: Key('top-col-grip-$i'),
                  data: Tuple2(_DragKind.column, i),
                  onDragStarted: () {
                    _draggingColumnIndex = i;
                    _scheduleRebuild();
                    _dragWantsInsert.value = false;
                    _dragWantsDelete.value = false;
                  },
                  onDraggableCanceled: (velocity, offset) {
                    final outside = !_isGlobalPointInsideCard(offset);
                    if (outside) {
                      _deleteColumn(i);
                    }
                    _draggingColumnIndex = null;
                    _hoverColumnInsertIndex = null;
                    _lastColInsertIndex = null;
                    _scheduleRebuild();
                    _dragWantsInsert.value = false;
                    _dragWantsDelete.value = false;
                  },
                  onDragCompleted: () {
                    _draggingColumnIndex = null;
                    _hoverColumnInsertIndex = null;
                    _lastColInsertIndex = null;
                    _scheduleRebuild();
                    _dragWantsInsert.value = false;
                    _dragWantsDelete.value = false;
                  },
                  dragAnchorStrategy: pointerDragAnchorStrategy,
                  feedback: _buildReusedPillarFeedback(
                    i,
                    // 回退方案：如果无法复用，则使用原有的构建方法
                    () => _offsetFeedbackDown(
                      widget.dragFeedbackBuilder?.call(
                            context,
                            _buildFullColumnFeedback(
                              title,
                              _pillarJiaZiFromPayload(pillars[i]),
                              rows,
                              widthOverride: _isSeparatorColumnIndex(i)
                                  ? null
                                  : _colWidthAtIndex(i, pillars),
                            ),
                          ) ??
                          _statusFeedback(
                            _buildFullColumnFeedback(
                              title,
                              _pillarJiaZiFromPayload(pillars[i]),
                              rows,
                              widthOverride: _isSeparatorColumnIndex(i)
                                  ? null
                                  : _colWidthAtIndex(i, pillars),
                            ),
                          ),
                      _effectiveDragHandleRowHeight,
                    ),
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: drag_icon,
                  ),
                ),
              ),
            );
          }),
          // 右侧空白单元格（对应 rightGripColumn）
          SizedBox(
            width: _effectiveDragHandleColWidth,
            height: _effectiveDragHandleRowHeight,
          ),
        ],
      ),
    );
  }

  /// 构建底部抓手行，用于拖拽列
  ///
  /// 参数：
  /// - [pillars]: 列数据列表
  /// - [rows]: 行标签列表
  /// - [totalWidth]: 数据网格总宽度
  Widget _buildBottomGripRow(
    List<PillarPayload> pillars,
    List<String> rows,
    double totalWidth,
  ) {
    return SizedBox(
      width: _effectiveDragHandleColWidth * 2 + totalWidth,
      height: _effectiveDragHandleRowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧空白单元格（对应 leftGripColumn）
          SizedBox(
              width: _effectiveDragHandleColWidth,
              height: _effectiveDragHandleRowHeight),
          ...List.generate(pillars.length, (i) {
            final bool isSeparatorCol = _isSeparatorColumnIndex(i);
            final double colW = _colWidthAtIndex(i, pillars);
            if (isSeparatorCol) {
              // Separator: 显示抓手图标，但不显示标题
              return SizedBox(
                width: colW,
                height: _effectiveDragHandleRowHeight,
                child: Center(
                  child: Draggable<Tuple2<_DragKind, int>>(
                    key: Key('bottom-col-grip-sep-$i'),
                    data: Tuple2(_DragKind.column, i),
                    onDragStarted: () {
                      _draggingColumnIndex = i;
                      _scheduleRebuild();
                      _dragWantsInsert.value = false;
                      _dragWantsDelete.value = false;
                    },
                    onDraggableCanceled: (velocity, offset) {
                      final outside = !_isGlobalPointInsideCard(offset);
                      if (outside) {
                        _deleteColumn(i);
                      }
                      _draggingColumnIndex = null;
                      _hoverColumnInsertIndex = null;
                      _lastColInsertIndex = null;
                      _scheduleRebuild();
                      _dragWantsInsert.value = false;
                      _dragWantsDelete.value = false;
                    },
                    onDragCompleted: () {
                      _draggingColumnIndex = null;
                      _hoverColumnInsertIndex = null;
                      _lastColInsertIndex = null;
                      _scheduleRebuild();
                      _dragWantsInsert.value = false;
                      _dragWantsDelete.value = false;
                    },
                    dragAnchorStrategy: pointerDragAnchorStrategy,
                    feedback: Material(
                      color: Colors.transparent,
                      child: drag_icon,
                    ),
                    child: drag_icon,
                  ),
                ),
              );
            }
            final title = _pillarLabelFromPayload(pillars[i]);
            return SizedBox(
              width: colW,
              height: _effectiveDragHandleRowHeight,
              child: Center(
                child: Draggable<Tuple2<_DragKind, int>>(
                  key: Key('bottom-col-grip-$i'),
                  data: Tuple2(_DragKind.column, i),
                  onDragStarted: () {
                    _draggingColumnIndex = i;
                    _scheduleRebuild();
                    _dragWantsInsert.value = false;
                    _dragWantsDelete.value = false;
                  },
                  onDraggableCanceled: (velocity, offset) {
                    final outside = !_isGlobalPointInsideCard(offset);
                    if (outside) {
                      _deleteColumn(i);
                    }
                    _draggingColumnIndex = null;
                    _hoverColumnInsertIndex = null;
                    _lastColInsertIndex = null;
                    _scheduleRebuild();
                    _dragWantsInsert.value = false;
                    _dragWantsDelete.value = false;
                  },
                  onDragCompleted: () {
                    _draggingColumnIndex = null;
                    _hoverColumnInsertIndex = null;
                    _lastColInsertIndex = null;
                    _scheduleRebuild();
                    _dragWantsInsert.value = false;
                    _dragWantsDelete.value = false;
                  },
                  dragAnchorStrategy: pointerDragAnchorStrategy,
                  feedback: _buildReusedPillarFeedback(
                    i,
                    // 回退方案：如果无法复用，则使用原有的构建方法
                    () => _offsetFeedbackUp(
                      widget.dragFeedbackBuilder?.call(
                            context,
                            _buildFullColumnFeedback(
                              title,
                              _pillarJiaZiFromPayload(pillars[i]),
                              rows,
                              widthOverride: _isSeparatorColumnIndex(i)
                                  ? null
                                  : _colWidthAtIndex(i, pillars),
                            ),
                          ) ??
                          _statusFeedback(
                            _buildFullColumnFeedback(
                              title,
                              _pillarJiaZiFromPayload(pillars[i]),
                              rows,
                              widthOverride: _isSeparatorColumnIndex(i)
                                  ? null
                                  : _colWidthAtIndex(i, pillars),
                            ),
                          ),
                      _effectiveDragHandleRowHeight,
                    ),
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: drag_icon,
                  ),
                ),
              ),
            );
          }),
          // 为右侧的 gripColumn 预留空间
          SizedBox(
              width: _effectiveDragHandleColWidth,
              height: _effectiveDragHandleRowHeight),
        ],
      ),
    );
  }

  /// 构建左侧抓手列，用于拖拽行
  ///
  /// 参数：
  /// - [rows]: 行标签列表
  /// - [pillars]: 列数据列表（用于反馈构建）
  Widget _buildLeftGripColumn(
    List<String> rows,
    // List<Tuple2<String, JiaZi>> pillars,
    List<PillarPayload> pillarPayloads,
  ) {
    return SizedBox(
      width: _effectiveDragHandleColWidth,
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
                // 顶部占位：对齐 dataGrid 列装饰的顶部偏移
                children.add(
                  SizedBox(
                    width: _effectiveDragHandleColWidth,
                    height: _pillarDecorationTopOffsetEff,
                  ),
                );
                // 处理数据行
                for (final entry in rows.asMap().entries) {
                  final absRowIdx = entry.key;
                  final rowName = entry.value;
                  final rowSize = _rowCellSize(rowName);
                  final bool isSeparatorRow = _isSeparatorRowAtIndex(absRowIdx);
                  // 幽灵占位
                  children.add(
                    AnimatedContainer(
                      duration: draggingRow
                          ? const Duration(milliseconds: 180)
                          : Duration.zero,
                      curve: Curves.easeOut,
                      width: _effectiveDragHandleColWidth,
                      height: draggingRow && t == absRowIdx
                          ? _getGhostRowHeight(fallbackHeight: rowSize.height)
                          : 0,
                      color: draggingRow && t == absRowIdx
                          ? Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.08)
                          : Colors.transparent,
                    ),
                  );
                  if (d == absRowIdx) continue;
                  children.add(
                    SizedBox(
                      width: _effectiveDragHandleColWidth,
                      height: rowSize.height,
                      child: Center(
                        child: Draggable<Tuple2<_DragKind, int>>(
                          key: Key('left-row-grip-$absRowIdx'),
                          data: Tuple2(_DragKind.row, absRowIdx),
                          onDragStarted: () {
                            _draggingRowIndex = absRowIdx;
                            _hoverColumnInsertIndex = null;
                            _lastColInsertIndex = null;
                            _hoveringExternalPillar = false;
                            _scheduleRebuild();
                            _dragWantsInsert.value = false;
                            _dragWantsDelete.value = false;
                          },
                          onDraggableCanceled: (velocity, offset) {
                            final outside = !_isGlobalPointInsideCard(
                              offset,
                            );
                            _draggingRowIndex = null;
                            _hoverRowInsertIndex = null;
                            _lastRowInsertIndex = null;
                            _hoveringExternalRow = false;
                            _externalRowHoverHeight = 0.0;
                            _scheduleRebuild();
                            _dragWantsInsert.value = false;
                            _dragWantsDelete.value = false;
                            if (outside) {
                              _deleteRow(absRowIdx);
                            }
                          },
                          onDragCompleted: () {
                            _draggingRowIndex = null;
                            _hoverRowInsertIndex = null;
                            _lastRowInsertIndex = null;
                            _hoveringExternalRow = false;
                            _externalRowHoverHeight = 0.0;
                            _scheduleRebuild();
                            _dragWantsInsert.value = false;
                            _dragWantsDelete.value = false;
                          },
                          dragAnchorStrategy: pointerDragAnchorStrategy,
                          feedback: _offsetFeedbackRight(
                            widget.dragFeedbackBuilder?.call(
                                  context,
                                  _buildFullRowFeedback(
                                    rowName,
                                    pillarPayloads,
                                    absRowIndex: absRowIdx,
                                  ),
                                ) ??
                                _statusFeedback(
                                  _buildFullRowFeedback(
                                    rowName,
                                    pillarPayloads,
                                    absRowIndex: absRowIdx,
                                  ),
                                ),
                            _effectiveDragHandleColWidth,
                          ),
                          childWhenDragging: const SizedBox.shrink(),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            child: drag_icon,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                // 底部占位：对齐 dataGrid 列装饰的底部偏移
                children.add(
                  SizedBox(
                    width: _effectiveDragHandleColWidth,
                    height: _pillarDecorationBottomOffsetEff,
                  ),
                );
                return children;
              })(),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建右侧抓手列，用于拖拽行
  ///
  /// 参数：
  /// - [rows]: 行标签列表
  /// - [pillars]: 列数据列表（用于反馈构建）
  Widget _buildRightGripColumn(
    List<String> rows,
    List<PillarPayload> pillarPayloads,
  ) {
    return Container(
      width: _effectiveDragHandleColWidth,
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
                // 顶部占位
                children.add(
                  SizedBox(
                    width: _effectiveDragHandleColWidth,
                    height: _pillarDecorationTopOffsetEff,
                  ),
                );
                // 处理数据行
                for (final entry in rows.asMap().entries) {
                  final absRowIdx = entry.key;
                  final rowName = entry.value;
                  final rowSize = _rowCellSize(rowName);
                  final bool isSeparatorRow = _isSeparatorRowAtIndex(absRowIdx);
                  // 幽灵占位
                  children.add(
                    AnimatedContainer(
                      duration: draggingRow
                          ? const Duration(milliseconds: 180)
                          : Duration.zero,
                      curve: Curves.easeOut,
                      width: _effectiveDragHandleColWidth,
                      height: draggingRow && t == absRowIdx
                          ? _getGhostRowHeight(fallbackHeight: rowSize.height)
                          : 0,
                      color: draggingRow && t == absRowIdx
                          ? Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.08)
                          : Colors.transparent,
                    ),
                  );
                  if (d == absRowIdx) continue;
                  children.add(
                    SizedBox(
                      width: _effectiveDragHandleColWidth,
                      height: rowSize.height,
                      child: Center(
                        child: Draggable<Tuple2<_DragKind, int>>(
                          key: Key('right-row-grip-$absRowIdx'),
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
                            final outside = !_isGlobalPointInsideCard(
                              offset,
                            );
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
                                  _buildFullRowFeedback(
                                    rowName,
                                    pillarPayloads,
                                    absRowIndex: absRowIdx,
                                  ),
                                ) ??
                                _statusFeedback(
                                  _buildFullRowFeedback(
                                    rowName,
                                    pillarPayloads,
                                    absRowIndex: absRowIdx,
                                  ),
                                ),
                            _rowFeedbackTotalWidth(pillarPayloads),
                          ),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            child: drag_icon,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                // 末尾插入位幽灵占位
                children.add(
                  AnimatedContainer(
                    duration: draggingRow
                        ? const Duration(milliseconds: 180)
                        : Duration.zero,
                    curve: Curves.easeOut,
                    width: _effectiveDragHandleColWidth,
                    height: draggingRow && (t == rows.length)
                        ? (_draggingRowIndex != null
                            ? (_rowHeightOverrides[_draggingRowIndex!] ??
                                _rowHeightByName(rows[_draggingRowIndex!]))
                            : _externalRowHoverHeight)
                        : 0,
                    color: draggingRow && (t == rows.length)
                        ? Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.08)
                        : Colors.transparent,
                  ),
                );
                // 底部占位
                children.add(
                  SizedBox(
                    width: _effectiveDragHandleColWidth,
                    height: _pillarDecorationBottomOffsetEff,
                  ),
                );
                return children;
              })(),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建左侧标题列，显示行标题
  ///
  /// 参数：
  /// - [rows]: 行标签列表
  @Deprecated('Use cardpayload 中的pillar实现')
  Widget _buildLeftHeader(List<String> rows) {
    return SizedBox(
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
                // 顶部占位
                children.add(
                  SizedBox(
                    width: rowTitleWidth,
                    height: _pillarDecorationTopOffsetEff,
                  ),
                );
                for (final entry in rows.asMap().entries) {
                  final absRowIdx = entry.key;
                  final rowName = entry.value;
                  final rowSize = _rowCellSize(rowName);
                  // 幽灵占位
                  children.add(
                    AnimatedContainer(
                      duration: draggingRow
                          ? const Duration(milliseconds: 180)
                          : Duration.zero,
                      curve: Curves.easeOut,
                      width: rowTitleWidth,
                      height: draggingRow && t == absRowIdx
                          ? _getGhostRowHeight(fallbackHeight: rowSize.height)
                          : 0,
                      color: draggingRow && t == absRowIdx
                          ? Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.08)
                          : Colors.transparent,
                    ),
                  );
                  if (d == absRowIdx) continue;
                  final cell = Stack(
                    children: [
                      if (_isSeparatorRowAtIndex(absRowIdx))
                        Container(
                          width: rowTitleWidth,
                          height: rowSize.height,
                          decoration:
                              CardDecorators.buildRowSeparatorDecoration(
                            context,
                            thickness: _rowDividerThickness,
                          ),
                        )
                      else
                        (() {
                          final rowPayloads = _currentRows();
                          RowPayload? rPayload;
                          if (absRowIdx >= 0 &&
                              absRowIdx < rowPayloads.length) {
                            rPayload = rowPayloads[absRowIdx];
                          }
                          final isHeaderRow =
                              rPayload?.rowType == RowType.columnHeaderRow;
                          if (isHeaderRow &&
                              rPayload is ColumnHeaderRowPayload) {
                            final titleWidget = _genderText(rPayload.gender);
                            return _cell(
                              rowSize,
                              Center(child: titleWidget),
                              verticalPadding: _getRowPadding(rowName),
                              horizontalPadding: _getRowHorizontalPadding(
                                rowName,
                              ),
                            );
                          } else if (rPayload is TextRowPayload) {
                            return _rowTitlePillarText(rPayload);
                          } else {
                            final titleWidget = _rowTitleText(rowName);
                            return _cell(
                              rowSize,
                              Center(child: titleWidget),
                              verticalPadding: _getRowPadding(rowName),
                              horizontalPadding: _getRowHorizontalPadding(
                                rowName,
                              ),
                            );
                          }
                        })(),
                      if (draggingRow && t == absRowIdx)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary.withOpacity(0.12),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary.withOpacity(0.35),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                  children.add(
                    SizedBox(
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
                      ),
                    ),
                  );
                }
                // 末尾插入位幽灵占位
                final draggedRowName =
                    (d != null && d < rows.length) ? rows[d] : null;
                final draggedSize = draggedRowName != null
                    ? Size(
                        rowTitleWidth,
                        (_rowHeightOverrides[d] ??
                            _rowHeightByName(draggedRowName)),
                      )
                    : Size(rowTitleWidth, 0);
                children.add(
                  AnimatedContainer(
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
                        ? Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.08)
                        : Colors.transparent,
                  ),
                );
                // 底部占位
                children.add(
                  SizedBox(
                    width: rowTitleWidth,
                    height: _pillarDecorationBottomOffsetEff,
                  ),
                );
                return children;
              })(),
            ],
          ),
          // Debug 覆盖层
          if (widget.debugHysteresisOverlay)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: CustomPaint(
                  painter: RowHysteresisPainter(
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
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.08),
                  ),
                ),
              ),
            ),
          // 插入位指示条
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
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.35),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPillarsEachCell(
      {RowType? rowType,
      required PillarType pillarType,
      required Size size,
      required int absRowIdx,
      required List<RowPayload> rowPayloads,
      required Gender gender,
      required JiaZi dayJiaZi,
      required JiaZi pillarJiaZi}) {
    Widget cell;
    // print("${rowType?.name} width: ${size.width}, height: ${size.height}");
    if (_isSeparatorRowAtIndex(absRowIdx)) {
      // 分隔行：不在单元格内绘制横线，由数据网格叠加层统一绘制
      cell = SizedBox.fromSize(
        size: size,
      );
    } else if (rowType != null) {
      switch (rowType) {
        case RowType.columnHeaderRow:
          final theme = widget.themeNotifier.value;
          final cellStyleConfig = theme.cell.rowTitleCellConfig;
          final typography = theme.typography;
          cell = multiLineCell(
            size: Size(size.width, size.height),
            cellStyleConfig: cellStyleConfig,
            mainTextStyleConfig: typography.pillarTitle,
            content: pillarType.name,
          );

        case RowType.heavenlyStem:
          final textStyleConfig = widget.themeNotifier.value.typography
              .getCellContentBy(RowType.heavenlyStem);
          final cellStyleConfig =
              widget.themeNotifier.value.cell.getBy(RowType.heavenlyStem);
          // final textStyleConfig = _resolveGanZhiTextStyle(
          //     rowType: RowType.earthlyBranch, content: d.name);
          // 标题取行载荷中的标注（保持现状）
          final p = rowPayloads.firstWhere(
              (p) => p.rowType == RowType.heavenlyStem,
              orElse: () => rowPayloads.first);
          final titleLabel = (p is TextRowPayload ? p.rowLabel : null) ?? '天干';
          cell = multiLineCell(
            size: size,
            cellStyleConfig: cellStyleConfig,
            mainTextStyleConfig: textStyleConfig,
            titleTextStyleConfig:
                widget.themeNotifier.value.typography.getCellTitleBy(
              RowType.heavenlyStem,
            ),
            content: pillarJiaZi.tianGan.name,
            title: titleLabel,
          );
          // cell = _cell(size, _tianGanText(pillarJiaZi.tianGan),
          // verticalPadding: 0, horizontalPadding: 0);
          break;
        case RowType.earthlyBranch:
          final textStyleConfig = widget.themeNotifier.value.typography
              .getCellContentBy(RowType.earthlyBranch);
          final cellStyleConfig =
              widget.themeNotifier.value.cell.getBy(RowType.earthlyBranch);
          final p = rowPayloads.firstWhere(
              (p) => p.rowType == RowType.earthlyBranch,
              orElse: () => rowPayloads.first);
          final titleLabel = (p is TextRowPayload ? p.rowLabel : null) ?? '地支';
          cell = multiLineCell(
            size: size,
            cellStyleConfig: cellStyleConfig,
            mainTextStyleConfig: textStyleConfig,
            titleTextStyleConfig:
                widget.themeNotifier.value.typography.getCellTitleBy(
              RowType.earthlyBranch,
            ),
            content: pillarJiaZi.diZhi.name,
            title: titleLabel,
          );

          break;
        default:
          final text = rowStrategyMapper[rowType]
                  ?.computeSingleValue(pillarJiaZi, dayJiaZi, gender) ??
              "-";
          final theme = widget.themeNotifier.value;
          final cellStyleConfig = theme.cell.getBy(rowType);
          final typography = theme.typography;
          final p = rowPayloads.firstWhere((p) => p.rowType == rowType,
              orElse: () => rowPayloads.first);
          final titleLabel = (p is TextRowPayload ? p.rowLabel : null) ?? null;
          cell = multiLineCell(
            size: size,
            cellStyleConfig: cellStyleConfig,
            mainTextStyleConfig: typography.getCellContentBy(rowType),
            titleTextStyleConfig: typography.getCellTitleBy(rowType),
            content: text,
            title: titleLabel,
          );
          break;
      }
    } else {
      final theme = widget.themeNotifier.value;
      final typography = theme.typography;
      // widget.themeNotifier.value.typography.pillarTitle

      // title Cell
      cell = multiLineCell(
          size: Size(size.width, size.height),
          cellStyleConfig: theme.cell.globalCellConfig,
          mainTextStyleConfig: typography.pillarTitle,
          content: rowType?.name ?? "-");
    }
    return cell;
  }

  Widget multiLineCell({
    required Size size,
    required CellStyleConfig cellStyleConfig,
    required TextStyleConfig mainTextStyleConfig,
    TextStyleConfig? titleTextStyleConfig,
    required String content,
    String? title,
    double predictLineHeightConstant = 1.4,
  }) {
    // 计算cell width和height
    // double cellWidth = size.width;
    // 增加decorationWidth
    // cellWidth += cellStyleConfig.getDecorationWidth();
    // final cellHeight = size.height;
    // 1. content 预测高度
    double predictHeight = mainTextStyleConfig.fontStyleDataModel.fontSize *
        predictLineHeightConstant;
    double? titlePredicatHeight;
    final shouldShowTitle = cellStyleConfig.showsTitleInCell &&
        titleTextStyleConfig != null &&
        title != null &&
        title.isNotEmpty;
    if (shouldShowTitle) {
      titlePredicatHeight = titleTextStyleConfig!.fontStyleDataModel.fontSize *
          predictLineHeightConstant;
      predictHeight += titlePredicatHeight;
    }
    // 3. 增加padding 与 margin 以及border
    predictHeight += cellStyleConfig.getDecorationHeight();
    predictHeight = predictHeight.ceilToDouble();
    // print("width: ${size.width}, height: ${size.height}");
    return EditableMultiTextCell(
      size: size,
      cellStyleConfig: cellStyleConfig,
      content: Text(content,
          style: mainTextStyleConfig.toTextStyle(
            char: content,
            colorPreviewMode: widget.colorPreviewModeNotifier.value,
            brightness: widget.brightnessNotifier.value,
          ),
          strutStyle: StrutStyle(
              fontSize: mainTextStyleConfig.fontStyleDataModel.fontSize,
              height: mainTextStyleConfig.fontStyleDataModel.height,
              forceStrutHeight: true)),
      subChild: shouldShowTitle
          ? Text(title!,
              style: titleTextStyleConfig.toTextStyle(
                char: title,
                colorPreviewMode: widget.colorPreviewModeNotifier.value,
                brightness: widget.brightnessNotifier.value,
              ),
              strutStyle: StrutStyle(
                  fontSize: titleTextStyleConfig.fontStyleDataModel.fontSize,
                  height: titleTextStyleConfig.fontStyleDataModel.height,
                  forceStrutHeight: true))
          : SizedBox(),
      // subChild: shouldShowTitle
      //     ? Container(
      //         alignment: Alignment.center,
      //         height: titlePredicatHeight,
      //         child: Text(title!,
      //             style: titleTextStyleConfig.toTextStyle(
      //               char: title,
      //               colorPreviewMode: widget.colorPreviewModeNotifier.value,
      //               brightness: widget.brightnessNotifier.value,
      //             ),
      //             strutStyle: StrutStyle(
      //                 fontSize:
      //                     titleTextStyleConfig.fontStyleDataModel.fontSize,
      //                 height: titleTextStyleConfig.fontStyleDataModel.height,
      //                 forceStrutHeight: true)),
      //       )
      //     : Container(),
      // subChild: title != null
      //     ? Container(
      //         alignment: Alignment.center,
      //         height: titlePredicatHeight,
      //         child: Text(title, style: titleTextStyleConfig?.toTextStyle()),
      //       )
      //     : Container(),
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
      key: Key('col-insert-target-$insertIndex'),
      onWillAccept: (data) {
        // Accept internal column drag or external PillarPayload
        final ok = (data is Tuple2 &&
                data.item1 is _DragKind &&
                data.item1 == _DragKind.column) ||
            (data is PillarPayload) ||
            (data is TitleColumnPayload);
        if (!ok) return false;
        _hoverColumnInsertIndex = insertIndex;
        _scheduleRebuild();
        return true;
      },
      onLeave: (_) {
        _hoverColumnInsertIndex = null;
        _scheduleRebuild();
      },
      onAccept: (payload) {
        _hoverColumnInsertIndex = null;
        _scheduleRebuild();
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
                CardDecorators.buildColumnInsertDecoration(
                  context,
                  isHover: isHover,
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

  Widget _buildStyledPillarSegment(
      PillarStyleConfig config, Color bkColor, double width, Widget content) {
    return AnimatedContainer(
      // clipBehavior: Clip.hardEdge,
      clipBehavior: Clip.none,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
      margin: _pixelFloorEdgeInsets(config.margin),
      padding: _pixelFloorEdgeInsets(config.padding),
      width: _pixelFloor(width),
      decoration: BoxDecoration(
        color: bkColor,
        borderRadius: BorderRadius.circular(config.border!.radius),
        border: (config.border != null &&
                config.border!.enabled &&
                config.border!.width != 0)
            ? Border.all(
                color: config.border!.lightColor,
                width: config.border!.width,
              )
            : null,
        boxShadow: config.shadow.withShadow
            ? [
                BoxShadow(
                  color: config.shadow.followCardBackgroundColor
                      ? bkColor
                      : config.shadow.lightThemeColor,
                  offset: config.shadow.offset,
                  blurRadius: config.shadow.blurRadius,
                  spreadRadius: config.shadow.spreadRadius,
                )
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(config.border!.radius),
        child: content,
      ),
    );
  }

  Widget _buildEachPillar(int pillarIndex, double colW, Widget columnContent) {
    return ValueListenableBuilder(
        valueListenable: widget.cardPayloadNotifier,
        builder: (ctx, _, __) {
          final pillars = _currentPillars();
          final rowPayloads = _currentRows();

          return ValueListenableBuilder<PillarSection>(
              valueListenable: _pillarSectionNotifier,
              builder: (context, pillarConfig, __) {
                final pillarType = pillars[pillarIndex].pillarType;
                final PillarStyleConfig config = pillarConfig.getBy(pillarType);
                Color bkColor;
                if (pillarType == PillarType.separator) {
                  bkColor = config.lightBackgroundColor!;
                } else {
                  bkColor = config.lightBackgroundColor == Colors.transparent
                      ? widget.themeNotifier.value.card
                              .toBoxDecoration()
                              .color ??
                          Colors.white
                      : config.lightBackgroundColor ?? Colors.white;
                }

                // 使用与 CardMetricsCalculator 一致的宽度计算：contentWidth + decorationWidth
                // decorationWidth 包含 margin + padding + border*2
                // colW 是总宽度，_buildStyledPillarSegment 会设置 margin，所以传给它的 width 应为 colW - margin
                final marginW = config.margin.left + config.margin.right;
                double width = colW - marginW;
                if (width < 0) width = 0;

                if (columnContent is Column) {
                  final children = columnContent.children;
                  // 校验 children 数量是否为行数的两倍（GhostRow + Cell）
                  if (children.length == rowPayloads.length * 2) {
                    List<Widget> finalChildren = [];
                    List<Widget> currentSegmentChildren = [];

                    for (int i = 0; i < rowPayloads.length; i++) {
                      final row = rowPayloads[i];
                      // 获取该行对应的两个 Widget
                      final ghost = children[2 * i];
                      final cell = children[2 * i + 1];

                      if (row.rowType == RowType.separator) {
                        // 遇到分隔符：结束当前段落
                        if (currentSegmentChildren.isNotEmpty) {
                          finalChildren.add(_buildStyledPillarSegment(
                              config,
                              bkColor,
                              width,
                              Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [...currentSegmentChildren])));
                          currentSegmentChildren.clear();
                        }
                        // 添加分隔符行本身的 Widget（通常是占位或间隙），不包裹在样式容器中
                        finalChildren.add(Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [ghost, cell]));
                      } else {
                        currentSegmentChildren.add(ghost);
                        currentSegmentChildren.add(cell);
                      }
                    }
                    // 添加剩余段落
                    if (currentSegmentChildren.isNotEmpty) {
                      finalChildren.add(_buildStyledPillarSegment(
                          config,
                          bkColor,
                          width,
                          Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [...currentSegmentChildren])));
                    }

                    return SizedBox(
                      width: colW,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: finalChildren),
                    );
                  }
                }

                return _buildStyledPillarSegment(
                    config, bkColor, width, columnContent);
              });
        });
  }

  Widget _rowInsertTarget(int insertIndex, int max) {
    // insertIndex in [1..max], skip header row 0
    final isHover = _hoverRowInsertIndex == insertIndex;
    // Height depends on the row to which the bar is adjacent; use a fixed small bar for simplicity
    return DragTarget<Tuple2<_DragKind, int>>(
      key: Key('row-insert-target-$insertIndex'),
      onWillAccept: (data) {
        if (data == null || data.item1 != _DragKind.row || data.item2 == 0) {
          return false; // skip header
        }
        _hoverRowInsertIndex = insertIndex;
        _scheduleRebuild();
        return true;
      },
      onLeave: (_) {
        _hoverRowInsertIndex = null;
        _scheduleRebuild();
      },
      onAccept: (payload) {
        _hoverRowInsertIndex = null;
        _scheduleRebuild();
        _reorderRows(payload.item2, insertIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final decoration =
            widget.rowInsertDecorationBuilder?.call(context, isHover) ??
                CardDecorators.buildRowInsertDecoration(
                  context,
                  isHover: isHover,
                );
        // 悬停时的插入占位高度：内部拖拽取被拖行的覆盖/类型高度，外部拖拽取载荷解析高度
        double hoveredHeight = otherCellHeight;
        if (_draggingRowIndex != null && _draggingRowIndex! < max + 1) {
          final d = _draggingRowIndex!;
          final rowsPayload = _currentRows();
          if (d < rowsPayload.length) {
            final override = _rowHeightOverrides[d];
            final rp = rowsPayload[d];
            if (rp is TextRowPayload) {
              hoveredHeight = override ?? _rowHeightByPayload(rp);
            } else if (rp is RowSeparatorPayload) {
              // Handle separator height if dragged
              // Assuming separator has fixed height or similar logic
              // For now fallback to otherCellHeight or lookup theme
              hoveredHeight = override ?? otherCellHeight;
            }
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
    final rowPayloads = _currentRows();
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
    final rowPayloads = _currentRows();
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
    final list = List<PillarPayload>.of(_currentPillars());
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    _setPillars(list);
    _pillarGlobalKeys.clear();
    _scheduleRebuild();
  }

  // 删除行（允许删除标题行与任意索引）
  void _deleteRow(int absIndex) {
    final rows = List<RowPayload>.of(_currentRows());
    if (absIndex < 0 || absIndex >= rows.length) return;
    rows.removeAt(absIndex);
    _setRows(rows);

    if (_rowHeightOverrides.isNotEmpty) {
      final Map<int, double> next = {};
      for (final entry in _rowHeightOverrides.entries) {
        final k = entry.key;
        if (k == absIndex) continue;
        final nk = k > absIndex ? k - 1 : k;
        next[nk] = entry.value;
      }
      _rowHeightOverrides
        ..clear()
        ..addAll(next);
    }
  }

  // 接受外部行信息载荷并插入到指定位置（支持例如「空亡」行）
  void _insertExternalRow(int insertIndex, RowPayload payload) {
    var oldRowUUIDList =
        widget.cardPayloadNotifier.value.rowOrderUuid.map((s) => s).toList();
    var oldRowMapper = Map.fromEntries(
        widget.cardPayloadNotifier.value.rowMap.entries.map((e) => e));

    print("------- _insertExternalRow");
    print(payload.toJson());

    // final rows = List<RowPayload>.of(_currentRows());
    // 行插入索引范围：[0..rows.length]，允许插入到表头行之前
    final target = insertIndex.clamp(0, oldRowUUIDList.length);
    oldRowUUIDList.insert(target, payload.uuid);

    // 更新行映射
    oldRowMapper[payload.uuid] = payload;

    // rows.insert(target, payload);
    widget.cardPayloadNotifier.value =
        widget.cardPayloadNotifier.value.copyWith(
      rowOrderUuid: oldRowUUIDList,
      rowMap: oldRowMapper,
    );

    final rowTypeCellConfigMapper = Map.fromEntries(widget
        .themeNotifier.value.cell.rowTypeCellConfigMapper.entries
        .map((e) => e));
    rowTypeCellConfigMapper[payload.rowType] =
        widget.themeNotifier.value.cell.globalCellConfig;
    final cellContentMapper = Map.fromEntries(widget
        .themeNotifier.value.typography.cellContentMapper.entries
        .map((e) => e));
    cellContentMapper[payload.rowType] =
        widget.themeNotifier.value.typography.globalContent;

    widget.themeNotifier.value = widget.themeNotifier.value.copyWith(
      cell: widget.themeNotifier.value.cell
          .copyWith(rowTypeCellConfigMapper: rowTypeCellConfigMapper),
      typography: widget.themeNotifier.value.typography
          .copyWith(cellContentMapper: cellContentMapper),
    );

    _externalRowHoverHeight = 0.0;
    // 🔑 立即重新计算 metricsSnapshot，确保后续使用的是包含新行的最新数据
    _metricsSnapshotNotifier.value = _computeMetricsSnapshot();

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

    // 持久化行高覆盖：使用 NEW snapshot 的 defaultGlobalRowMetric.totalHeight
    // 注意：分隔符行 (RowSeparatorPayload) 不应应用默认行高覆盖，
    // 而是应由 _rowHeightByPayload 根据 _rowDividerHeightEffective 自动计算。
    if (payload is! RowSeparatorPayload) {
      final double overrideH =
          _metricsSnapshotNotifier.value.defaultGlobalRowMetric.totalHeight;
      updatedOverrides[target] = overrideH;
    }

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

      // 🔑 在插入完成后清零 _externalRowHoverHeight
      // 确保 AnimatedContainer 正确收缩到新的 size（已包含新行）
      _externalRowHoverHeight = 0.0;
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
  double _rowFeedbackTotalWidth(List<PillarPayload> pillars) {
    return rowTitleWidth + _totalColsWidth(pillars);
  }

  // Calculate full column feedback height: header + all row heights
  double _columnFeedbackTotalHeight(List<String> rows) {
    // 检查 rows[0] 是否为表头行
    final rowPayloads = _currentRows();
    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
        rowPayloads[0].rowType == RowType.columnHeaderRow;

    double total = 0.0;
    for (int i = 0; i < rows.length; i++) {
      final RowPayload? payload =
          (i >= 0 && i < rowPayloads.length) ? rowPayloads[i] : null;
      if (i == 0 && isRows0HeaderRow) {
        total += columnTitleHeight;
        continue;
      }
      if (payload != null) {
        final base = _rowHeightByPayload(payload);
        double vp = 0.0;
        if (payload is TextRowPayload) {
          final padInsets =
              _cellSectionNotifier.value.getBy(payload.rowType).padding;
          vp = ((padInsets.top + padInsets.bottom) / 2.0)
              .clamp(0.0, double.infinity);
        }
        total += base + (vp * 2);
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
    final list = List<PillarPayload>.of(_currentPillars());
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
    _setPillars(List<PillarPayload>.of(list));

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
    final list = List<PillarPayload>.of(_currentPillars());
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
    PillarPayload next = payload;
    if (payload is ContentPillarPayload) {
      // 保持已有内容；若未来支持空内容的 ContentPillarPayload，这里可补齐。
    } else if (payload.pillarType == PillarType.separator) {
      next = SeparatorPillarPayload(uuid: payload.uuid);
    } else if (payload.pillarType == PillarType.rowTitleColumn) {
      next = RowTitleColumnPayload(uuid: payload.uuid);
    } else {
      // final id = _allocatePillarId(payload.pillarType);
      // final label = _pillarLabelFromPayload(payload);
      final jz = _pillarJiaZiFromPayload(payload);
      final content = PillarContent(
        id: payload.uuid,
        pillarType: payload.pillarType,
        label: payload.pillarLabel!,
        jiaZi: jz,
        description: null,
        version: '1',
        sourceKind: PillarSourceKind.userInput,
        operationType: null,
      );
      next = ContentPillarPayload(
        uuid: payload.uuid,
        pillarType: payload.pillarType,
        pillarLabel: payload.pillarLabel,
        pillarContent: content,
      );
    }

    final list = List<PillarPayload>.of(_currentPillars());
    final target = insertIndex.clamp(0, list.length);
    list.insert(target, next);
    Map<String, PillarPayload> newPillarMap =
        Map.from(widget.cardPayloadNotifier.value.pillarMap);
    newPillarMap[next.uuid] = next;

    _setPillars(list);

    // 持久化列宽覆盖：非分隔列按载荷提供的宽度（若有）记录覆盖，用于重排反馈
    if (next.pillarType != PillarType.separator) {
      final double w = next.pillarType == PillarType.rowTitleColumn
          ? rowTitleWidth
          : pillarWidth;
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
    final list = List<PillarPayload>.of(_currentPillars());
    final target = insertIndex.clamp(0, list.length);
    // 直接根据类型创建基础 PillarContent，默认 JiaZi 使用甲子占位，确保策略可运行。
    PillarPayload created;
    if (type == PillarType.separator) {
      created = SeparatorPillarPayload(uuid: _allocatePillarId(type));
    } else if (type == PillarType.rowTitleColumn) {
      created = RowTitleColumnPayload(uuid: _allocatePillarId(type));
    } else {
      final content = PillarContent(
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
      created = ContentPillarPayload(
        uuid: content.id,
        pillarType: type,
        pillarLabel: label,
        pillarContent: content,
      );
    }
    list.insert(target, created);
    _setPillars(list);

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
    final rows = List<RowPayload>.of(_currentRows());
    if (fromAbsIdx < 0 || fromAbsIdx >= rows.length) return; // 允许索引0
    // Insert index in [0..rows.length]
    final item = rows.removeAt(fromAbsIdx);
    var target = insertIndex;
    if (insertIndex > fromAbsIdx) {
      target = insertIndex - 1;
    }
    target = target.clamp(0, rows.length); // 允许插入到索引0
    rows.insert(target, item);
    _setRows(rows);
    debugPrint(
        '[RowReorder] from=$fromAbsIdx -> insert=$insertIndex -> target=$target');
    final labels = _currentRows().map((e) => e.rowType.name).toList();
    debugPrint('[RowReorder] new order=${labels.join(' | ')}');
    // 通知外部行顺序更新（例如测试用例观察）
    if (widget.onRowsReordered != null) {
      widget.onRowsReordered!(_currentRows());
    }
    debugPrint('[RowReorder] onRowsReordered fired');

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
    final rows = List<RowPayload>.of(_currentRows());
    int fromAbsIdx = -1;
    for (int i = 0; i < rows.length; i++) {
      final rp = rows[i];
      if (rp is TextRowPayload) {
        final label = rp.rowLabel ?? rp.rowType.name;
        if (rp.rowType == t.rowType &&
            (t.rowLabel == null || t.rowLabel == label)) {
          fromAbsIdx = i;
          break;
        }
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
    final payload = _findRowPayloadByName(name);

    if (payload != null) {
      final snap = _metricsSnapshotNotifier.value;
      final rm = snap.rows[payload.uuid];

      if (rm != null) {
        return rm.height;
      }

      if (payload is TextRowPayload) {
        final baseHeight = payload.resolveHeight(
          heavenlyAndEarthlyHeight: ganZhiCellSize.height,
          otherHeight: otherCellHeight,
          dividerHeight: _rowDividerHeightEffective,
          headerHeight: columnTitleHeight,
        );
        final padInsets =
            _cellSectionNotifier.value.getBy(payload.rowType).padding;
        final rowPadding = (padInsets.top + padInsets.bottom) / 2.0;
        return baseHeight + (rowPadding * 2);
      } else if (payload is RowSeparatorPayload) {
        return _rowDividerHeightEffective;
      }
    }
    return otherCellHeight;
  }

  /// 根据行名称在当前行列表中查找对应的 `RowPayload`。
  /// 优先使用 `rowLabel` 匹配，其次回退到 `rowType.name`。
  RowPayload? _findRowPayloadByName(String name) {
    for (final p in _currentRows()) {
      String label;
      if (p is TextRowPayload) {
        label = p.rowLabel ?? p.rowType.name;
      } else {
        label = p.rowType.name;
      }
      if (label == name) return p;
    }
    return null;
  }

  /// 获取指定行的垂直内边距值
  double? _getRowPadding(String rowName) {
    final payload = _findRowPayloadByName(rowName);
    if (payload == null) return null;
    final cfg = _cellSectionNotifier.value.getBy(payload.rowType);
    final EdgeInsets pad = cfg.padding;
    return pad.top + pad.bottom;
  }

  double? _getRowVerticalPadding(String rowName) {
    final payload = _findRowPayloadByName(rowName);
    if (payload == null) return null;
    final cfg = _cellSectionNotifier.value.getBy(payload.rowType);
    final EdgeInsets pad = cfg.padding;
    return pad.top + pad.bottom;
  }

  double? _getRowHorizontalPadding(String rowName) {
    final payload = _findRowPayloadByName(rowName);
    if (payload == null) return null;
    final cfg = _cellSectionNotifier.value.getBy(payload.rowType);
    final EdgeInsets pad = cfg.padding;
    final double hp = (pad.left + pad.right) / 2.0;
    return hp > 0 ? hp : null;
  }

  /// 通过行索引获取行的垂直内边距值
  double? _getRowPaddingByIndex(int absRowIdx) {
    final rowPayloads = _currentRows();
    if (absRowIdx >= 0 && absRowIdx < rowPayloads.length) {
      final rt = rowPayloads[absRowIdx].rowType;
      final cfg = _cellSectionNotifier.value.getBy(rt);
      final EdgeInsets pad = cfg.padding;
      final double padding = pad.top + pad.bottom;
      return padding > 0 ? padding : null;
    }
    return null;
  }

  double? _getRowHorizontalPaddingByIndex(int absRowIdx) {
    final rowPayloads = _currentRows();
    if (absRowIdx >= 0 && absRowIdx < rowPayloads.length) {
      final rt = rowPayloads[absRowIdx].rowType;
      final cfg = _cellSectionNotifier.value.getBy(rt);
      final EdgeInsets pad = cfg.padding;
      final double hp = (pad.left + pad.right) / 2.0;
      return hp > 0 ? hp : null;
    }
    return null;
  }

  Size _rowCellSize(String rowName) {
    final h = _rowHeightByName(rowName);
    return Size(rowTitleWidth, h);
  }

  Widget _cell(Size size, Widget child,
      {double? verticalPadding,
      double? horizontalPadding,
      double? verticalMargin}) {
    // if (verticalPadding != null && verticalPadding > 0) {
    //   print(
    //       '🔍 [V3._cell] size.height=${size.height}, verticalPadding=$verticalPadding');
    // }

    return Container(
      width: size.width,
      height: size.height,
      // margin: verticalMargin != null
      //     ? EdgeInsets.symmetric(vertical: verticalMargin)
      //     : null,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        border: Border.all(color: Colors.black12, width: 0.5),
        borderRadius: BorderRadius.zero, // 移除圆角，消除单元格间的视觉间隙
      ),
      child: (verticalPadding != null && verticalPadding > 0) ||
              (horizontalPadding != null && horizontalPadding > 0)
          ? Padding(
              padding: EdgeInsets.symmetric(
                vertical: (verticalPadding ?? 0).clamp(0.0, double.infinity),
                horizontal:
                    (horizontalPadding ?? 0).clamp(0.0, double.infinity),
              ),
              child: Center(child: child),
            )
          : Center(child: child),
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
  @Deprecated('因为不能复用，所以废弃')
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
    final rowPayloads = _currentRows();
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
            final int absRowIdx = entry.key;
            final String rowName = entry.value;
            final RowType? rowType =
                (absRowIdx >= 0 && absRowIdx < rowPayloads.length)
                    ? rowPayloads[absRowIdx].rowType
                    : null;

            if (rowType == RowType.heavenlyStem) {
              return _cell(Size(feedbackWidth, ganZhiCellSize.height),
                  _tianGanText(jz.tianGan),
                  verticalPadding: _getRowPaddingByIndex(absRowIdx));
            } else if (rowType == RowType.earthlyBranch) {
              return _cell(Size(feedbackWidth, ganZhiCellSize.height),
                  _diZhiText(jz.diZhi),
                  verticalPadding: _getRowPaddingByIndex(absRowIdx));
            } else if (rowType == RowType.naYin) {
              // return _cell(
              //     Size(feedbackWidth, otherCellHeight), _naYinText(jz.naYinStr),
              //     verticalPadding: _getRowPaddingByIndex(absRowIdx));
              return multiLineCell(
                  size: Size(feedbackWidth, otherCellHeight),
                  cellStyleConfig: CellStyleConfig.defaultCellStyleConfig,
                  mainTextStyleConfig: TextStyleConfig.defaultConfig,
                  titleTextStyleConfig: TextStyleConfig.defaultConfig,
                  content: jz.naYinStr,
                  title: "纳音");
            } else if (rowType == RowType.kongWang) {
              final kw = jz.getKongWang();
              final text = '${kw.item1.value}${kw.item2.value}';
              return multiLineCell(
                  size: Size(feedbackWidth, otherCellHeight),
                  cellStyleConfig: CellStyleConfig.defaultCellStyleConfig,
                  mainTextStyleConfig: TextStyleConfig.defaultConfig,
                  titleTextStyleConfig: TextStyleConfig.defaultConfig,
                  content: text,
                  title: "空亡");
              // return _cell(
              //     Size(feedbackWidth, otherCellHeight), _kongWangText(text),
              //     verticalPadding: _getRowPaddingByIndex(absRowIdx));
            } else if (rowType == RowType.columnHeaderRow) {
              return _cell(Size(feedbackWidth, columnTitleHeight),
                  _columnTitleText(title),
                  verticalPadding: _getRowPaddingByIndex(absRowIdx));
            } else if (_isSeparatorRowAtIndex(absRowIdx)) {
              return Container(
                width: feedbackWidth,
                height: _rowDividerHeightEffective,
                decoration: CardDecorators.buildRowSeparatorDecoration(
                  context,
                  thickness: _rowDividerThickness,
                ),
              );
            } else {
              return _cell(
                  Size(feedbackWidth, otherCellHeight), _columnTitleText(title),
                  verticalPadding: _getRowPaddingByIndex(absRowIdx));
            }
          }).toList(),
        ],
      ),
    );
  }

  /// 【方案A优化】复用已渲染的 Pillar 作为拖拽反馈
  ///
  /// 通过 GlobalKey 引用已构建的 Pillar Widget，避免重复构建整个柱的 Widget 树。
  /// 这大幅提升了拖拽性能，减少了内存占用，并确保视觉一致性。
  ///
  /// 参数：
  /// - pillarIndex: 柱索引
  /// - fallbackBuilder: 当无法获取已渲染 Pillar 时的回退构建器
  ///
  /// 返回：拖拽反馈 Widget
  Widget _buildReusedPillarFeedback(
    int pillarIndex,
    Widget Function() fallbackBuilder,
  ) {
    // 获取 GlobalKey
    final key = _pillarGlobalKeys[pillarIndex];

    if (key == null) {
      // 如果 key 不存在，使用回退方案
      debugPrint(
          'Warning: Pillar GlobalKey not found for index $pillarIndex, using fallback');
      return fallbackBuilder();
    }

    // 尝试获取当前的 Widget 和 Context
    final context = key.currentContext;
    final widget = key.currentWidget;

    if (context == null || widget == null) {
      debugPrint(
          'Warning: Pillar Widget not available for index $pillarIndex, using fallback');
      return fallbackBuilder();
    }

    final element = context as Element;
    if (!element.mounted) {
      debugPrint(
          'Warning: Pillar Element inactive for index $pillarIndex, using fallback');
      return fallbackBuilder();
    }

    final renderBox = element.renderObject as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      debugPrint(
          'Warning: Pillar RenderBox not laid out for index $pillarIndex, using fallback');
      return fallbackBuilder();
    }

    final size = renderBox.size;

    // 获取柱配置以应用圆角等样式
    final pillars = _currentPillars();
    final pillarType = (pillarIndex >= 0 && pillarIndex < pillars.length)
        ? pillars[pillarIndex].pillarType
        : PillarType.year; // 默认值
    final borderRadius =
        _pillarSectionNotifier.value.getBy(pillarType).border?.radius ?? 0;

    // 构建反馈 Widget：复用已渲染的 Widget，添加视觉效果
    return Transform.translate(
      // 向下偏移，使 feedback 从抓手下方开始
      offset: Offset(0, _effectiveDragHandleRowHeight),
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Opacity(
          opacity: 0.85, // 稍微透明，表示拖拽状态
          child: Material(
            elevation: 8, // 添加阴影，增强拖拽感
            borderRadius: BorderRadius.circular(borderRadius),
            child: widget, // 直接复用已渲染的 Widget
          ),
        ),
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
      if (idx == 0) continue;
      final h = _rowHeightByIndex(idx);
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
      if (idx == 0) continue; // 跳过标题行
      final h = _rowHeightByIndex(idx);
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
    final rowPayloads = _currentRows();
    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
        rowPayloads[0].rowType == RowType.columnHeaderRow;

    // 累积高度从0开始，允许插入到表头行之前
    double acc = 0.0;
    int insertIndex = 0; // 最小为 0，允许插入到表头行之前

    for (final entry in rows.asMap().entries) {
      final idx = entry.key;
      final name = entry.value; // label 保留用于边界情况调试

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

      final h = _rowHeightByIndex(idx);
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
    final rowPayloads = _currentRows();
    final isRows0HeaderRow = rowPayloads.isNotEmpty &&
        rowPayloads[0].rowType == RowType.columnHeaderRow;

    // 累积高度从0开始，允许计算表头行的中点
    double acc = 0.0;

    for (final entry in rows.asMap().entries) {
      final i = entry.key;
      final name = entry.value; // label 保留用于边界情况调试

      // 当 i == 0 时，检查是否为表头行
      if (i == 0 && isRows0HeaderRow) {
        final h = columnTitleHeight;
        if (idx == 0) {
          return acc + h / 2.0; // 返回表头行的中点
        }
        acc += h;
        continue;
      }
      final h = _rowHeightByIndex(i);
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

  /// 依据当前行载荷（来自 `cardPayloadNotifier`）返回索引对应的行高。
  ///
  /// 参数：
  /// - idx: 行索引（>=0）。
  /// 返回：
  /// - double：该行的高度（像素）。当索引越界时返回 `otherCellHeight` 作为兜底。
  double _rowHeightByIndex(int idx) {
    final payloads = _currentRows();
    if (idx >= 0 && idx < payloads.length) {
      return _rowHeightByPayload(payloads[idx]);
    }
    return otherCellHeight;
  }

  /// 返回列索引 `idx` 的中点 X（局部坐标），用于边界滞回判断。
  ///
  /// 参数：
  /// - idx: 列索引（>=0）。
  /// - pillars: 列 (标题, JiaZi) 二元组列表。
  /// 返回：
  /// - double：该列中点的局部 x 值（像素），相对于数据列区域的起始位置。
  double _columnBoundaryMidX(int idx, List<PillarPayload> pillars) {
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

  Size _computeSizeWithDecorationsV2() {
    final pillars = _currentPillars();
    final rows = _currentRows();

    // 使用辅助方法构建 cellTextSpecMap
    final specMap = _buildCellTextSpecMap();

    final calc = CardMetricsCalculator(
      theme: widget.themeNotifier.value,
      payload: widget.cardPayloadNotifier.value,
      defaultPillarWidth: pillarWidth,
      lineHeightFactor: 1.4,
      cellTextSpecMap: specMap,
      avgGlyphWidthScale: 1.2,
      defaultSeparatorWidth: widget.themeNotifier.value.pillar
              .getBy(PillarType.separator)
              .separatorWidth ??
          8.0,
      rowTitleWidth: rowTitleWidth,
    );
    final opts = MetricsComputeOptions(
      includeGrip: widget.showGrip,
      showTitleRow: false,
      showTitleCol: false,
      cellShowsTitle: rows.any((r) {
        final rt = r.rowType;
        if (rt == RowType.columnHeaderRow || rt == RowType.separator) {
          return false;
        }
        return widget.themeNotifier.value.cell.getBy(rt).showsTitleInCell;
      }),
      cardPadding: widget.paddingNotifier.value,
      cardBorderWidth: widget.themeNotifier.value.card.border?.width ?? 0.0,
      gripRowHeight: _effectiveDragHandleRowHeight,
      gripColWidth: _effectiveDragHandleColWidth,
      columnTitleHeight: columnTitleHeight,
      rowTitleWidth: rowTitleWidth,
      withCardBorder: false,
    );
    final size = calc.computeFinalSize(opts);
    return Size(size.width, size.height);
  }

  /// 计算包含装饰的 Card 尺寸
  ///
  /// 基于 CardLayoutModel 的基础尺寸，添加每列装饰的额外尺寸：
  /// - 宽度：每个普通列添加装饰宽度 (margin 8*2 + padding 16*2 + border 2*2 = 52px)
  /// - 高度：装饰包裹整列，需要添加一次垂直装饰尺寸 (margin 8*2 + padding 16*2 + border 2*2 = 52px)
  @Deprecated('Use _computeSizeWithDecorationsV2 instead')
  Size _computeSizeWithDecorations() {
    final baseSize = _layoutNotifier.value.computeSize(_measurementContext);

    // 计算所有非分隔列的装饰宽度总和（按列覆盖）
    final payloads = _currentPillars();
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

  /// 当基础布局模型发生变化时，刷新测量上下文与整体尺寸。
  ///
  /// 功能描述：
  /// - 读取基础布局模型的分割线有效尺寸与抓手显示配置，重建 `MeasurementContext`；
  /// - 使用最新上下文重新计算卡片总尺寸（包含装饰），推动父级约束与布局更新；
  /// - 该方法通过监听 `BasicLayout.CardLayoutModel.version` 自动触发。
  /// 参数说明：无。
  /// 返回值：无（通过内部状态与通知器完成联动）。
  void _onBasicLayoutChanged() {
    // 重建测量上下文以反映最新的分割线有效尺寸与边界参数
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

    // 重要：同步更新布局模型中的抓手“有效尺寸”，避免 computeSize 使用旧值
    _layoutNotifier.value = CardLayoutModel.fromNotifiers(
      pillars: _currentPillars(),
      rows: _currentRows(),
      padding: widget.paddingNotifier.value,
      columnWidthOverrides: _columnWidthOverrides,
      // rowHeightOverrides: _rowHeightOverrides,
      dragHandleRowHeight: _effectiveDragHandleRowHeight,
      dragHandleColWidth: _effectiveDragHandleColWidth,
    );

    // 刷新整体尺寸（包含装饰），确保 UI 与度量数据一致
    _sizeNotifier.value = _computeSizeWithDecorationsV2();
    _metricsSnapshotNotifier.value = _computeMetricsSnapshot();
  }

  void _onThemeChanged() {
    final newTheme = widget.themeNotifier.value;
    _pillarSectionNotifier.value =
        EditableCardThemeBuilder.buildPillarSection(newTheme);
    _cellSectionNotifier.value =
        EditableCardThemeBuilder.buildCellSection(newTheme);
    _typographySectionNotifier.value =
        EditableCardThemeBuilder.buildTypographySection(newTheme);
    _scheduleRebuild();
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
  @Deprecated('因为不能复用，所以废弃')
  Widget _buildFullRowFeedback(
      String rowName, // List<Tuple2<String, JiaZi>> pillars,
      List<PillarPayload> pillarPayloads,
      {int? absRowIndex}) {
    // 推断行类型与载荷
    final rowPayloads = _currentRows();
    final RowPayload? payload = absRowIndex != null &&
            absRowIndex >= 0 &&
            absRowIndex < rowPayloads.length
        ? rowPayloads[absRowIndex]
        : _findRowPayloadByName(rowName);
    final RowType? rowType = payload?.rowType;

    // 分割线：仅显示水平细线（RowType 驱动）
    final bool isRowSeparator = absRowIndex != null
        ? _isSeparatorRowAtIndex(absRowIndex)
        : (payload?.rowType == RowType.separator);
    if (isRowSeparator) {
      final totalW = _totalColsWidth(pillarPayloads);
      return Container(
        width: totalW,
        height: _rowDividerHeightEffective,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      );
    }

    // 行高：优先使用覆盖 > payload 解析 > 名称兜底
    // 统一行高计算：当存在 payload 时，使用 `_rowHeightByPayload`（返回内容高度，不含 padding）；
    // 否则回退到 `_rowHeightByName(rowName)`。padding 由 _cell 方法统一处理。
    final double rowH =
        (absRowIndex != null && _rowHeightOverrides[absRowIndex] != null)
            ? _rowHeightOverrides[absRowIndex]!
            : (payload != null
                ? _rowHeightByPayload(payload)
                : _rowHeightByName(rowName));

    final totalW = rowTitleWidth + _totalColsWidth(pillarPayloads);

    // 标题文本：payload.label 优先，其次 RowType 默认，兜底 rowName
    String titleStr = rowName;
    if (payload is TextRowPayload) {
      titleStr = payload.rowLabel ??
          (rowType != null ? _labelForRowType(rowType) : rowName);
    } else if (rowType != null) {
      titleStr = _labelForRowType(rowType);
    }

    // 外层占位：应用行的上下外边距（仅占位，不影响内部内容测量）
    final double marginV = 0.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: marginV),
      child: SizedBox(
        width: totalW,
        height: rowH,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isRowSeparator)
              Container(
                width: rowTitleWidth,
                height: rowH,
                decoration: CardDecorators.buildRowSeparatorDecoration(
                  context,
                  thickness: _rowDividerThickness,
                ),
              )
            else
              _cell(Size(rowTitleWidth, rowH),
                  _dragHandle(_rowTitleText(titleStr)),
                  verticalPadding: _getRowPadding(rowName),
                  horizontalPadding: _getRowHorizontalPadding(rowName)),
            ...pillarPayloads.asMap().entries.map((entry) {
              final i = entry.key;
              final colW = _colWidthAtIndex(i, pillarPayloads);

              // 1. 特殊处理：行标题列 (RowTitleColumnPayload)
              // 它没有 JiaZi 数据，也不能作为 ContentPillarPayload 处理。
              // 直接渲染占位符以保持网格对齐。
              if (entry.value is RowTitleColumnPayload) {
                return _cell(Size(colW, rowH), const SizedBox.shrink(),
                    verticalPadding: _getRowPadding(rowName),
                    horizontalPadding: _getRowHorizontalPadding(rowName));
              }

              // 2. 获取内容数据
              ContentPillarPayload? tuple;
              JiaZi? jz;
              if (entry.value is ContentPillarPayload) {
                tuple = entry.value as ContentPillarPayload;
                jz = tuple.pillarContent.jiaZi;
              }

              // 3. 分割线处理
              if (isRowSeparator) {
                return Container(
                  width: colW,
                  height: rowH,
                  decoration: CardDecorators.buildRowSeparatorDecoration(
                    context,
                    thickness: _rowDividerThickness,
                  ),
                );
              }

              // 4. 数据依赖检查
              // 如果是需要 JiaZi 数据的行类型，但 jz 为空，则渲染空单元格，避免崩溃。
              final bool needsJiaZi = rowType == RowType.heavenlyStem ||
                  rowType == RowType.earthlyBranch ||
                  rowType == RowType.naYin ||
                  rowType == RowType.kongWang;

              if (needsJiaZi && jz == null) {
                return _cell(Size(colW, rowH), const SizedBox.shrink(),
                    verticalPadding: _getRowPadding(rowName),
                    horizontalPadding: _getRowHorizontalPadding(rowName));
              }

              if (rowType == RowType.heavenlyStem) {
                return _cell(Size(colW, rowH), _tianGanText(jz!.tianGan),
                    verticalPadding: _getRowPadding(rowName),
                    horizontalPadding: _getRowHorizontalPadding(rowName));
              } else if (rowType == RowType.earthlyBranch) {
                return _cell(Size(colW, rowH), _diZhiText(jz!.diZhi),
                    verticalPadding: _getRowPadding(rowName),
                    horizontalPadding: _getRowHorizontalPadding(rowName));
              } else if (rowType == RowType.naYin) {
                return _cell(Size(colW, rowH), Text("纳音"),
                    verticalPadding: _getRowPadding(rowName),
                    horizontalPadding: _getRowHorizontalPadding(rowName));
              } else if (rowType == RowType.kongWang) {
                final kw = jz!.getKongWang();
                // final text = '${kw.item1.value}${kw.item2.value}';
                return _cell(Size(colW, rowH), Text("空亡"),
                    verticalPadding: _getRowPadding(rowName),
                    horizontalPadding: _getRowHorizontalPadding(rowName));
              } else if (rowType == RowType.columnHeaderRow) {
                final pName = tuple?.pillarType.name ?? "";
                return _cell(Size(colW, rowH), _columnTitleText(pName),
                    verticalPadding: _getRowPadding(rowName),
                    horizontalPadding: _getRowHorizontalPadding(rowName));
              } else {
                final pName = tuple?.pillarType.name ?? "";
                return _cell(Size(colW, rowH), _columnTitleText(pName),
                    verticalPadding: _getRowPadding(rowName));
              }
            }).toList(),
          ],
        ),
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
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      );

  /// Builds row title text with optional global typography overrides.
  ///
  /// Parameters:
  /// - [s]: The title string.
  ///
  /// Returns: A `Text` widget styled by `_resolveTextStyle`.
  Widget _rowTitleText(String s) => EditableSingleTextCell(
      text: s, style: TextStyle(fontSize: 16, color: Colors.pink));
  Widget _rowTitlePillarText(TextRowPayload textRowPayload) {
    // return multiLineCell(size: , cellStyleConfig: widget.themeNotifier.value.typography.rowTitle, mainTextStyleConfig: mainTextStyleConfig, content: content)

    var row = _metricsSnapshotNotifier.value.rows.values
        .where((t) => t.rowType == textRowPayload.rowType)
        .first;
    var rowHeight = row.height;
    final theme = widget.themeNotifier.value;

    var mainTextStyleConfig = theme.typography.rowTitle;
    var cellStyleConfig = theme.cell.rowTitleCellConfig;

    return multiLineCell(
        size: Size(rowTitleWidth, rowHeight),
        cellStyleConfig: cellStyleConfig,
        mainTextStyleConfig: mainTextStyleConfig,
        content: _labelForRowType(textRowPayload.rowType));
  }

  /// Builds column title text with optional global typography overrides.
  ///
  /// Parameters:
  /// - [s]: The title string.
  ///
  /// Returns: A `Text` widget styled by `_resolveTextStyle`.
  Widget _columnTitleText(String s) => EditableSingleTextCell(
        text: s,
        style: TextStyle(fontSize: 16, color: Colors.amber),
      );

  /// Builds TianGan text.
  ///
  /// 参数：
  /// - [t]: 要渲染的天干。
  /// 返回：根据 `_resolveTextStyle` 样式渲染的 `Text` 组件。
  Widget _tianGanText(TianGan t) {
    // 当启用彩色模式时，天干按字符映射使用固定色彩方案；
    // 关闭彩色模式时，使用纯色（受全局/分组字体设置影响）。

    return EditableSingleTextCell(
        text: t.name,
        style: _resolveGanZhiTextStyle(
            rowType: RowType.heavenlyStem, content: t.name));
  }

  TextStyle _resolveGanZhiTextStyle(
      {required RowType rowType, required String content}) {
    final ts = widget.themeNotifier.value.typography.getCellContentBy(rowType);
    var tmp = ts.colorMapperDataModel.getMapperBy(
        theme: widget.brightnessNotifier.value,
        mode: widget.colorPreviewModeNotifier.value);
    // print("${rowType.name} $content,tmp: $tmp");
    final Color textColor = tmp[content]!;
    Color shadowColor = textColor;
    if (!ts.textShadowDataModel.followTextColor) {
      shadowColor = widget.brightnessNotifier.value == Brightness.light
          ? ts.textShadowDataModel.lightShadowColor
          : ts.textShadowDataModel.darkShadowColor;
    }

    TextStyle base = TextStyle(
      fontSize: ts.fontStyleDataModel.fontSize,
      fontWeight: ts.fontStyleDataModel.fontWeight,
      color: textColor,
      fontFamily: ts.fontStyleDataModel.fontFamily,
      shadows: [
        Shadow(
          color: shadowColor
              .withAlpha((ts.textShadowDataModel.shadowOpacity * 255).toInt()),
          offset: Offset(ts.textShadowDataModel.shadowOffsetX,
              ts.textShadowDataModel.shadowOffsetY),
          blurRadius: ts.textShadowDataModel.shadowBlurRadius,
        ),
      ],
    );
    return base;
  }

  /// Builds DiZhi text。
  ///
  /// 参数：
  /// - [d]: 要渲染的地支。
  /// 返回：根据 `_resolveTextStyle` 样式渲染的 `Text` 组件。
  Widget _diZhiText(DiZhi d) {
    // 当启用彩色模式时，地支按字符映射使用固定色彩方案；
    // 关闭彩色模式时，使用纯色（受全局/分组字体设置影响）。

    return EditableSingleTextCell(
        text: d.name,
        style: _resolveGanZhiTextStyle(
            rowType: RowType.earthlyBranch, content: d.name));
  }

  /// Maps a `RowType` to its default display label.
  ///
  /// Parameters:
  /// - [type]: The `RowType` enum.
  ///
  /// Returns: The localized default label for the given row type.
  String _labelForRowType(RowType type) {
    switch (type) {
      case RowType.heavenlyStem:
        return '天干';
      case RowType.earthlyBranch:
        return '地支';
      case RowType.tenGod:
        return '十神';
      case RowType.naYin:
        return '纳音';
      case RowType.kongWang:
        return '空亡';
      case RowType.xunShou:
        return '旬首';
      case RowType.hiddenStems:
        return '地支藏干';
      case RowType.hiddenStemsTenGod:
        return '藏干十神';
      case RowType.hiddenStemsPrimary:
        return '藏干主气';
      case RowType.hiddenStemsSecondary:
        return '藏干中气';
      case RowType.hiddenStemsTertiary:
        return '藏干余气';
      case RowType.hiddenStemsPrimaryGods:
        return '藏干主神';
      case RowType.hiddenStemsSecondaryGods:
        return '藏干中神';
      case RowType.hiddenStemsTertiaryGods:
        return '藏干余神';
      case RowType.starYun:
        return '神煞';
      case RowType.selfSiting:
        return '命宫';
      case RowType.columnHeaderRow:
        return '表头行';
      case RowType.separator:
        return '分割线';
    }
  }
}

// Debug painters moved to card_debug_painters.dart
