import 'package:flutter/foundation.dart';

/// EditableCardDragController
/// 统一管理可编辑四柱卡片的拖拽事件节流（onMove）与运行时参数。
///
/// 功能描述：
/// - 列拖拽与行拖拽分别采用独立的轻节流窗口（毫秒级，默认 12ms）。
/// - 暴露便捷方法用于判断当前是否允许处理一次 onMove（返回布尔值）。
/// - 提供重置方法以在离开目标区域或拖拽完成后清理时间戳。
///
/// 使用方式：
/// - 在组件 state 中持有一个实例，并在 onMove 里调用相应的 allow*Move 方法。
/// - 根据需要调用 reset* 方法清理内部状态。
class EditableCardDragController {
  /// 列拖拽节流时间窗口（毫秒）
  final int columnMoveCooldownMs;

  /// 行拖拽节流时间窗口（毫秒）
  final int rowMoveCooldownMs;

  /// 列插入位切换的默认滞回占比（例如 0.12 表示 12% 的缓冲区）
  final double defaultColumnHysteresisFraction;

  /// 行插入位切换的默认滞回占比（例如 0.15 表示 15% 的缓冲区）
  final double defaultRowHysteresisFraction;

  DateTime? _lastColumnMoveAt;
  DateTime? _lastRowMoveAt;

  // 处理计数：用于验证节流是否生效（允许处理的 onMove 次数）
  int _columnMoveProcessedCount = 0;
  int _rowMoveProcessedCount = 0;

  /// 构造函数
  /// 参数：
  /// - columnMoveCooldownMs: 列拖拽 onMove 的节流窗口，单位毫秒。
  /// - rowMoveCooldownMs: 行拖拽 onMove 的节流窗口，单位毫秒。
  /// - defaultColumnHysteresisFraction: 列默认滞回占比，用于便捷 API。
  /// - defaultRowHysteresisFraction: 行默认滞回占比，用于便捷 API。
  EditableCardDragController({
    this.columnMoveCooldownMs = 12,
    this.rowMoveCooldownMs = 12,
    this.defaultColumnHysteresisFraction = 0.12,
    this.defaultRowHysteresisFraction = 0.15,
  });

  /// 判断是否允许处理一次“列 onMove”事件。
  /// 返回值：
  /// - true 表示当前事件应被处理；false 表示处于节流窗口内应被忽略。
  bool allowColumnMove() {
    final now = DateTime.now();
    if (_lastColumnMoveAt != null) {
      final diff = now.difference(_lastColumnMoveAt!).inMilliseconds;
      if (diff < columnMoveCooldownMs) {
        return false;
      }
    }
    _lastColumnMoveAt = now;
    _columnMoveProcessedCount++;
    return true;
  }

  /// 判断是否允许处理一次“行 onMove”事件。
  /// 返回值：
  /// - true 表示当前事件应被处理；false 表示处于节流窗口内应被忽略。
  bool allowRowMove() {
    final now = DateTime.now();
    if (_lastRowMoveAt != null) {
      final diff = now.difference(_lastRowMoveAt!).inMilliseconds;
      if (diff < rowMoveCooldownMs) {
        return false;
      }
    }
    _lastRowMoveAt = now;
    _rowMoveProcessedCount++;
    return true;
  }

  /// 重置列拖拽节流状态。
  /// 使用场景：onLeave、拖拽完成（onAccept）后清理时间戳。
  void resetColumnThrottle() {
    _lastColumnMoveAt = null;
  }

  /// 重置行拖拽节流状态。
  /// 使用场景：onLeave、拖拽完成（onAccept）后清理时间戳。
  void resetRowThrottle() {
    _lastRowMoveAt = null;
  }

  /// 获取当前处理计数（只读属性）
  int get columnMoveProcessedCount => _columnMoveProcessedCount;

  /// 获取当前处理计数（只读属性）
  int get rowMoveProcessedCount => _rowMoveProcessedCount;

  /// 重置 onMove 处理计数（列与行）
  /// 使用场景：一次交互结束后清零，为下一次交互采样做准备。
  void resetMoveCounts() {
    _columnMoveProcessedCount = 0;
    _rowMoveProcessedCount = 0;
  }

  /// 快照并清零处理计数，用于测试或调试日志
  /// 返回对象包含 `row` 与 `column` 两类处理次数
  MoveCounters snapshotAndResetMoveCounts() {
    final res = MoveCounters(
      row: _rowMoveProcessedCount,
      column: _columnMoveProcessedCount,
    );
    resetMoveCounts();
    return res;
  }
}

/// MoveCounters
/// 用于承载一次快照中的 onMove 处理计数（行与列）。
/// 功能描述：
/// - 在测试或调试日志中打印 `row/column` 的处理次数，验证节流是否生效。
/// 参数说明：
/// - row: 本次快照内允许处理的行 onMove 次数。
/// - column: 本次快照内允许处理的列 onMove 次数。
class MoveCounters {
  final int row;
  final int column;
  const MoveCounters({required this.row, required this.column});

  @override
  String toString() => 'MoveCounters(row=$row, column=$column)';
}

/// Index and hysteresis helpers
extension EditableCardDragControllerIndexing on EditableCardDragController {
  /// 计算插入索引（中点规则，支持不等宽/不等高）
  ///
  /// 功能描述：
  /// - 给定从内容起点测量的坐标 `coord`（如列的 dx 或行的 dy），以及每个单元的跨度列表 `spans`，
  ///   使用“中点规则”确定插入位：当 `coord` 小于第 i 项的中点时返回 i；否则继续累加，超出则返回末尾索引。
  /// 参数：
  /// - coord: 从内容起点测量的局部坐标（列为 dx，行为 dy）。
  /// - spans: 每个单元的宽度/高度列表（列为宽度，行为高度）。
  /// 返回值：
  /// - 插入索引，范围 [0..spans.length]。
  int computeInsertIndexByMidpoints(double coord, List<double> spans) {
    double acc = 0.0;
    for (int i = 0; i < spans.length; i++) {
      final w = spans[i];
      final mid = acc + w / 2;
      if (coord < mid) return i;
      acc += w;
    }
    return spans.length;
  }

  /// 滞回判定（基于最后一次提交的插入索引与中点距离）
  ///
  /// 功能描述：
  /// - 当候选索引 `candidate` 与上次索引 `last` 不同时，计算 `last` 边界的中点坐标与滞回缓冲区，
  ///   仅当越过中点 ± margin 时允许更新；否则保持当前索引以减少抖动。
  /// 参数：
  /// - candidate: 新的候选插入索引。
  /// - last: 上次已提交的插入索引（可等于 spans.length 表示末尾）。
  /// - coord: 当前局部坐标（列为 dx，行为 dy）。
  /// - spans: 每个单元的宽度/高度列表（列为宽度，行为高度）。
  /// - hysteresisFraction: 滞回缓冲占比（例如列为 0.12，行为 0.15）。
  /// - fallbackSpan: 当 last == spans.length（末尾边界）时使用的幽灵跨度（列为幽灵宽度，行为幽灵高度）。
  /// 返回值：
  /// - 当允许切换到 `candidate` 时返回 true，否则返回 false。
  bool allowHysteresisSwitch({
    required int candidate,
    required int last,
    required double coord,
    required List<double> spans,
    required double hysteresisFraction,
    required double fallbackSpan,
  }) {
    if (candidate == last) return false;

    final bool movingRightOrDown = candidate > last;
    // 计算 last 边界的跨度与中点坐标
    final double spanAtLast = (last < spans.length) ? spans[last] : fallbackSpan;
    double acc = 0.0;
    for (int i = 0; i < last && i < spans.length; i++) {
      acc += spans[i];
    }
    final double midCoord = acc + spanAtLast / 2;
    final double margin = spanAtLast * hysteresisFraction;

    if (movingRightOrDown) {
      // 向右/向下拖拽：越过中点 + margin 才允许切换
      return coord > midCoord + margin;
    } else {
      // 向左/向上拖拽：低于中点 - margin 才允许切换
      return coord < midCoord - margin;
    }
  }

  /// 便捷：按列默认滞回占比判定是否允许切换插入索引。
  ///
  /// 参数：
  /// - candidate/last/coord/spans/fallbackSpan：同 `allowHysteresisSwitch`。
  /// - fraction：可选覆盖默认占比；未提供时使用 `defaultColumnHysteresisFraction`。
  /// 返回值：
  /// - 当允许切换到 `candidate` 时返回 true，否则返回 false。
  bool allowColumnHysteresisSwitch({
    required int candidate,
    required int last,
    required double coord,
    required List<double> spans,
    required double fallbackSpan,
    double? fraction,
  }) {
    return allowHysteresisSwitch(
      candidate: candidate,
      last: last,
      coord: coord,
      spans: spans,
      hysteresisFraction: fraction ?? defaultColumnHysteresisFraction,
      fallbackSpan: fallbackSpan,
    );
  }

  /// 便捷：按行默认滞回占比判定是否允许切换插入索引。
  ///
  /// 参数：
  /// - candidate/last/coord/spans/fallbackSpan：同 `allowHysteresisSwitch`。
  /// - fraction：可选覆盖默认占比；未提供时使用 `defaultRowHysteresisFraction`。
  /// 返回值：
  /// - 当允许切换到 `candidate` 时返回 true，否则返回 false。
  bool allowRowHysteresisSwitch({
    required int candidate,
    required int last,
    required double coord,
    required List<double> spans,
    required double fallbackSpan,
    double? fraction,
  }) {
    return allowHysteresisSwitch(
      candidate: candidate,
      last: last,
      coord: coord,
      spans: spans,
      hysteresisFraction: fraction ?? defaultRowHysteresisFraction,
      fallbackSpan: fallbackSpan,
    );
  }
}

/// Coordinate normalization helpers
extension EditableCardDragControllerCoords on EditableCardDragController {
  /// 归一化列坐标 dx：扣除左侧抓手宽度与（可选）行标题列宽度。
  ///
  /// 参数：
  /// - localDx: 原始局部坐标（从 Stack/DragTarget 的左上角开始）。
  /// - gripWidth: 左侧列抓手的可见宽度（隐藏时可传 0）。
  /// - rowTitleWidth: 行标题列的宽度。
  /// - hasRowTitleColumnInGrid: 当前渲染网格是否包含行标题列（包含时无需再扣除）。
  /// 返回值：
  /// - 归一化后的列坐标 dx，映射到数据列内容的起始位置。
  double normalizeColumnDx({
    required double localDx,
    required double gripWidth,
    required double rowTitleWidth,
    required bool hasRowTitleColumnInGrid,
  }) {
    return localDx - gripWidth - (hasRowTitleColumnInGrid ? 0.0 : rowTitleWidth);
  }

  /// 归一化行坐标 dy：扣除顶部抓手行高度（当抓手显示时）。
  ///
  /// 参数：
  /// - localDy: 原始局部坐标（从 Stack/DragTarget 的左上角开始）。
  /// - topGripHeight: 顶部抓手行高度（隐藏时可传 0）。
  /// - gripVisible: 顶部抓手是否当前显示。
  /// 返回值：
  /// - 归一化后的行坐标 dy，映射到行内容区域的起始位置。
  double normalizeRowDy({
    required double localDy,
    required double topGripHeight,
    required bool gripVisible,
  }) {
    return localDy - (gripVisible ? topGripHeight : 0.0);
  }
}

/// Ghost sizing helpers
extension EditableCardDragControllerGhosts on EditableCardDragController {
  /// 解析列幽灵宽度：当外部悬停宽度有效（>0）时使用该值，否则回退到默认列宽。
  ///
  /// 参数：
  /// - hoveringExternalPillar: 是否处于外部柱悬停状态（仅外部悬停时需要扩展容器）。
  /// - externalHoverWidth: 外部载荷解析出的列宽（可能为 0）。
  /// - defaultWidth: 默认列宽（例如 `pillarWidth`）。
  /// 返回值：
  /// - 应用于幽灵列的宽度（像素）。
  double resolveGhostColumnWidth({
    required bool hoveringExternalPillar,
    required double externalHoverWidth,
    required double defaultWidth,
  }) {
    if (!hoveringExternalPillar) return 0.0;
    return externalHoverWidth > 0.0 ? externalHoverWidth : defaultWidth;
  }

  /// 解析行幽灵高度：当外部悬停高度有效（>0）时使用该值，否则回退到传入的默认高度。
  ///
  /// 参数：
  /// - hoveringExternalRow: 是否处于外部行悬停状态（仅外部悬停时需要扩展容器）。
  /// - externalHoverHeight: 外部载荷解析出的行高（可能为 0）。
  /// - fallbackHeight: 默认行高（如 `otherCellHeight` 或由网格行高解析获得）。
  /// 返回值：
  /// - 应用于幽灵行的高度（像素）。
  double resolveGhostRowHeight({
    required bool hoveringExternalRow,
    required double externalHoverHeight,
    required double fallbackHeight,
  }) {
    if (!hoveringExternalRow) return 0.0;
    return externalHoverHeight > 0.0 ? externalHoverHeight : fallbackHeight;
  }
}

/// Snap threshold helpers
extension EditableCardDragControllerSnapThreshold on EditableCardDragController {
  /// 解析插入目标索引（带吸附阈值），用于列/行通用场景。
  ///
  /// 功能描述：
  /// - 给定“有效索引坐标” `effectiveIndex`（可为小数，通常为当前位置在索引轴上的映射值），
  ///   与当前拖拽项索引 `draggingIndex` 及最大索引 `maxIndex`，按吸附阈值 `thresholdFraction`
  ///   执行向前/向后目标选择（越过中点 ± 阈值才切换）。
  /// 参数说明：
  /// - effectiveIndex: 当前坐标在索引轴上的有效位置（如 3.2，表示位于索引 3 和 4 之间）。
  /// - draggingIndex: 当前被拖拽项原始索引。
  /// - maxIndex: 可插入的最大索引（列为 n，行为行数上限）。
  /// - thresholdFraction: 吸附阈值占比，默认 0.5（中点规则）。
  /// 返回值说明：
  /// - 计算得到的目标插入索引，范围 [0..maxIndex]。
  int resolveInsertTargetWithThreshold({
    required double effectiveIndex,
    required int draggingIndex,
    required int maxIndex,
    double thresholdFraction = 0.5,
  }) {
    int target;
    if (effectiveIndex > draggingIndex) {
      final hf = effectiveIndex.floor();
      final frac = effectiveIndex - hf; // [0,1)
      target = frac > thresholdFraction ? hf + 1 : hf;
    } else if (effectiveIndex < draggingIndex) {
      final cf = effectiveIndex.ceil();
      final frac = cf - effectiveIndex; // (0,1]
      target = frac > thresholdFraction ? cf - 1 : cf;
    } else {
      target = draggingIndex;
    }
    return target.clamp(0, maxIndex);
  }

  /// 便捷：列插入目标解析（带吸附阈值）。
  /// 参数与返回同 `resolveInsertTargetWithThreshold`，仅语义化列场景。
  int resolveColumnInsertTargetWithThreshold({
    required double effectiveIndex,
    required int draggingIndex,
    required int maxIndex,
    double thresholdFraction = 0.5,
  }) {
    return resolveInsertTargetWithThreshold(
      effectiveIndex: effectiveIndex,
      draggingIndex: draggingIndex,
      maxIndex: maxIndex,
      thresholdFraction: thresholdFraction,
    );
  }

  /// 便捷：行插入目标解析（带吸附阈值）。
  /// 参数与返回同 `resolveInsertTargetWithThreshold`，仅语义化行场景。
  int resolveRowInsertTargetWithThreshold({
    required double effectiveIndex,
    required int draggingIndex,
    required int maxIndex,
    double thresholdFraction = 0.5,
  }) {
    return resolveInsertTargetWithThreshold(
      effectiveIndex: effectiveIndex,
      draggingIndex: draggingIndex,
      maxIndex: maxIndex,
      thresholdFraction: thresholdFraction,
    );
  }

  /// 统一宽度/高度的中点规则插入索引（快速路径）。
  ///
  /// 功能描述：
  /// - 当所有列宽（或行高）一致时，使用 `floor(coord / span + 0.5)` 计算插入索引，
  ///   并对结果进行 [0..count] 范围的钳制。
  /// 参数说明：
  /// - coord: 从内容起点测量的坐标（列为 dx，行为 dy）。
  /// - span: 单列宽度或单行高度（统一值）。
  /// - count: 当前列或行数量，用于钳制最大索引。
  /// 返回值说明：
  /// - 插入索引，范围 [0..count]。
  int computeUniformInsertIndexByMidpoint({
    required double coord,
    required double span,
    required int count,
  }) {
    final pos = coord / span;
    final idx = (pos + 0.5).floor();
    return idx.clamp(0, count);
  }
}

/// Intent helpers
extension EditableCardDragControllerIntent on EditableCardDragController {
  /// 判定“悬停更新后是否应显示插入意图”。
  ///
  /// 功能描述：
  /// - 在拖拽移动过程中，当候选插入索引发生变化（或首次赋值）时，显示插入意图；
  /// - 若无变化，则不更新插入意图，避免不必要重建。
  /// 参数说明：
  /// - candidate: 当前候选插入索引。
  /// - last: 上一次有效插入索引（可能为 null 表示首次）。
  /// 返回值：
  /// - true 表示需要显示插入意图；false 表示不需要。
  bool wantsInsertOnHoverChange({
    required int candidate,
    required int? last,
  }) {
    return last == null || candidate != last;
  }

  /// 离开拖拽接收区域后是否显示“删除意图”。
  ///
  /// 功能描述：
  /// - 当 onLeave 触发时，统一显示删除意图，用于提示当前拖拽会导致删除；
  /// - 具体删除操作仍由业务在 onAccept 或结束时确认。
  /// 返回值：
  /// - 始终返回 true（UI 层据此显示红色高亮边框等）。
  bool wantsDeleteOnLeave() => true;
}

/// Ghost visibility helpers
extension EditableCardDragControllerGhostVisibility on EditableCardDragController {
  /// 列幽灵是否需要扩展外层容器（只在外部柱悬停且未进行行拖拽时）。
  ///
  /// 参数：
  /// - hoveringExternalPillar: 是否处于外部柱悬停状态。
  /// - rowDraggingActive: 是否正在进行行拖拽。
  /// 返回值：
  /// - true 表示需要扩展容器以显示列幽灵；false 表示无需扩展。
  bool shouldExpandOuterForColumnGhost({
    required bool hoveringExternalPillar,
    required bool rowDraggingActive,
  }) {
    return hoveringExternalPillar && !rowDraggingActive;
  }

  /// 行幽灵是否需要扩展外层容器（只在外部行悬停时）。
  ///
  /// 参数：
  /// - hoveringExternalRow: 是否处于外部行悬停状态。
  /// 返回值：
  /// - true 表示需要扩展容器以显示行幽灵；false 表示无需扩展。
  bool shouldExpandOuterForRowGhost({
    required bool hoveringExternalRow,
  }) {
    return hoveringExternalRow;
  }
}
