import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/drag_payloads.dart';

/// 可测量对象的统一协议
///
/// 所有需要计算尺寸的对象都应实现此协议，确保尺寸计算逻辑的一致性。
abstract class Measurable {
  /// 根据给定的测量上下文计算自身尺寸
  ///
  /// 这是一个纯函数，不应该有副作用。
  double measure(MeasurementContext context);
}

/// 测量上下文：提供全局配置参数
///
/// 集中管理所有与尺寸计算相关的配置参数，避免参数传递混乱。
@immutable
class MeasurementContext {
  /// 默认柱宽（普通数据列）
  final double defaultPillarWidth;

  /// 默认普通单元格高度
  final double defaultOtherCellHeight;

  /// 干支单元格高度（天干/地支行）
  final double ganZhiCellHeight;

  /// 表头行高度
  final double columnTitleHeight;

  /// 行分割线有效高度（padding + thickness）
  final double rowDividerHeightEffective;

  /// 列分割线有效宽度（padding + thickness）
  final double colDividerWidthEffective;

  /// 列宽最小值
  final double minPillarWidth;

  /// 列宽最大值
  final double maxPillarWidth;

  /// 行标题列默认宽度
  final double rowTitleWidth;

  const MeasurementContext({
    required this.defaultPillarWidth,
    required this.defaultOtherCellHeight,
    required this.ganZhiCellHeight,
    required this.columnTitleHeight,
    required this.rowDividerHeightEffective,
    required this.colDividerWidthEffective,
    this.minPillarWidth = 40.0,
    this.maxPillarWidth = 160.0,
    this.rowTitleWidth = 52.0,
  });

  /// 从 State 的当前配置创建上下文
  factory MeasurementContext.fromStateConfig({
    required double pillarWidth,
    required double otherCellHeight,
    required double ganZhiHeight,
    required double columnTitleHeight,
    required double rowDividerHeightEffective,
    required double colDividerWidthEffective,
    required double rowTitleWidth,
    double minPillarWidth = 40.0,
    double maxPillarWidth = 160.0,
  }) {
    return MeasurementContext(
      defaultPillarWidth: pillarWidth,
      defaultOtherCellHeight: otherCellHeight,
      ganZhiCellHeight: ganZhiHeight,
      columnTitleHeight: columnTitleHeight,
      rowDividerHeightEffective: rowDividerHeightEffective,
      colDividerWidthEffective: colDividerWidthEffective,
      rowTitleWidth: rowTitleWidth,
      minPillarWidth: minPillarWidth,
      maxPillarWidth: maxPillarWidth,
    );
  }
}

/// 列的尺寸模型（不可变）
///
/// 封装列的索引、数据载荷和宽度覆盖信息。
/// 通过 [measure] 方法自动计算列宽，优先级：覆盖值 > payload解析 > 默认值。
@immutable
class ColumnDimension implements Measurable {
  /// 在列表中的索引（0-based）
  final int index;

  /// 数据载荷（包含柱类型、内容等）
  final PillarPayload payload;

  /// 用户自定义的宽度覆盖值
  ///
  /// 当用户手动调整列宽或外部拖入指定宽度的列时使用。
  final double? widthOverride;

  const ColumnDimension({
    required this.index,
    required this.payload,
    this.widthOverride,
  });

  @override
  double measure(MeasurementContext ctx) {
    // 1️⃣ 优先使用用户覆盖值
    if (widthOverride != null &&
        widthOverride!.isFinite &&
        !widthOverride!.isNaN) {
      return widthOverride!.clamp(ctx.minPillarWidth, ctx.maxPillarWidth);
    }

    // 2️⃣ 分隔列使用固定窄宽度
    if (payload.pillarType == PillarType.separator) {
      return ctx.colDividerWidthEffective;
    }

    // 3️⃣ 行标题列
    if (payload.pillarType == PillarType.rowTitleColumn) {
      return ctx.rowTitleWidth;
    }

    // 4️⃣ 使用 payload 解析宽度
    return ctx.defaultPillarWidth;
  }

  /// 创建覆盖了宽度的副本
  ///
  /// 用于用户手动调整列宽场景。
  ColumnDimension withWidthOverride(double width) {
    return ColumnDimension(
      index: index,
      payload: payload,
      widthOverride: width,
    );
  }

  /// 更新索引（用于重排后重建索引）
  ColumnDimension withIndex(int newIndex) {
    return ColumnDimension(
      index: newIndex,
      payload: payload,
      widthOverride: widthOverride,
    );
  }

  /// 清除宽度覆盖
  ColumnDimension clearWidthOverride() {
    return ColumnDimension(
      index: index,
      payload: payload,
      widthOverride: null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColumnDimension &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          payload == other.payload &&
          widthOverride == other.widthOverride;

  @override
  int get hashCode => Object.hash(index, payload, widthOverride);

  @override
  String toString() {
    return 'ColumnDimension(index: $index, type: ${payload.pillarType}, '
        'widthOverride: $widthOverride)';
  }
}

/// 行的尺寸模型（不可变）
///
/// 封装行的索引、数据载荷和高度覆盖信息。
/// 通过 [measure] 方法自动计算行高，优先级：覆盖值 > payload解析。
@immutable
class RowDimension implements Measurable {
  /// 在列表中的索引（0-based）
  final int index;

  /// 数据载荷（包含行类型、策略等）
  final RowPayload payload;

  const RowDimension({
    required this.index,
    required this.payload,
  });

  @override
  double measure(MeasurementContext ctx) {
    // 1. 分隔符特殊处理
    if (payload is RowSeparatorPayload) {
      return ctx.rowDividerHeightEffective;
    }

    // 2. 文本行处理：使用 payload 解析高度
    if (payload is TextRowPayload) {
      final textPayload = payload as TextRowPayload;
      final base = textPayload.resolveHeight(
        heavenlyAndEarthlyHeight: ctx.ganZhiCellHeight,
        otherHeight: ctx.defaultOtherCellHeight,
        dividerHeight: ctx.rowDividerHeightEffective,
        headerHeight: ctx.columnTitleHeight,
      );
      return base;
    }

    // 3. 默认兜底
    return ctx.defaultOtherCellHeight;
  }

  /// 更新索引（用于重排后重建索引）
  RowDimension withIndex(int newIndex) {
    return RowDimension(
      index: newIndex,
      payload: payload,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RowDimension &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          payload == other.payload;

  @override
  int get hashCode => Object.hash(index, payload);

  @override
  String toString() {
    return 'RowDimension(index: $index, type: ${payload.rowType})';
  }
}

/// Card 的完整布局模型（不可变，纯数据）
///
/// 这是整个尺寸管理系统的核心，集中管理所有列、行的尺寸信息。
/// 所有修改操作都返回新实例，确保不可变性。
@immutable
class CardLayoutModel {
  /// 所有列的尺寸模型
  final List<ColumnDimension> columns;

  /// 所有行的尺寸模型
  final List<RowDimension> rows;

  /// Card 内边距
  final EdgeInsets padding;

  /// 顶部拖拽抓手行高度
  final double dragHandleRowHeight;

  /// 右侧拖拽抓手列宽度
  final double dragHandleColWidth;

  const CardLayoutModel({
    required this.columns,
    required this.rows,
    required this.padding,
    this.dragHandleRowHeight = 20.0,
    this.dragHandleColWidth = 20.0,
  });

  // ==================== 核心计算方法 ====================

  /// 自动计算 Card 总尺寸
  ///
  /// 这是整个系统的核心方法，确保尺寸计算永远不会遗漏任何元素。
  Size computeSize(MeasurementContext ctx) {
    // 宽度 = leftGripColumn + 所有列宽之和 + rightGripColumn + padding
    final double totalColumnsWidth = columns.fold<double>(
      0.0,
      (sum, col) => sum + col.measure(ctx),
    );
    final width = totalColumnsWidth +
        padding.left +
        padding.right +
        (dragHandleColWidth * 2);

    // 高度 = padding.top + topGripRow + 所有行高之和 + bottomGripRow + padding.bottom
    final double totalRowsHeight = rows.fold<double>(
      0.0,
      (sum, row) => sum + row.measure(ctx),
    );
    final height = padding.top +
        dragHandleRowHeight +
        totalRowsHeight +
        dragHandleRowHeight +
        padding.bottom;

    return Size(width, height);
  }

  /// 获取指定列的宽度
  double columnWidth(int index, MeasurementContext ctx) {
    if (index < 0 || index >= columns.length) return 0.0;
    return columns[index].measure(ctx);
  }

  /// 获取指定行的高度
  double rowHeight(int index, MeasurementContext ctx) {
    if (index < 0 || index >= rows.length) return 0.0;
    return rows[index].measure(ctx);
  }

  /// 获取前 N 列的累计宽度
  ///
  /// 用于计算插入指示线位置、幽灵列位置等。
  double sumColumnWidthsUpTo(int count, MeasurementContext ctx) {
    final safeCount = count.clamp(0, columns.length);
    return columns.take(safeCount).fold<double>(
          0.0,
          (sum, col) => sum + col.measure(ctx),
        );
  }

  /// 获取前 N 行的累计高度
  ///
  /// 用于计算插入指示线位置、幽灵行位置等。
  double sumRowHeightsUpTo(int count, MeasurementContext ctx) {
    final safeCount = count.clamp(0, rows.length);
    return rows.take(safeCount).fold<double>(
          0.0,
          (sum, row) => sum + row.measure(ctx),
        );
  }

  /// 获取所有列的总宽度
  double totalColumnsWidth(MeasurementContext ctx) {
    return sumColumnWidthsUpTo(columns.length, ctx);
  }

  /// 获取所有行的总高度
  double totalRowsHeight(MeasurementContext ctx) {
    return sumRowHeightsUpTo(rows.length, ctx);
  }

  // ==================== 列操作方法 ====================

  /// 插入列（返回新模型）
  ///
  /// 自动处理索引重建，确保所有列的索引正确。
  CardLayoutModel insertColumn(int index, ColumnDimension column) {
    final newColumns = List<ColumnDimension>.from(columns);
    final safeIndex = index.clamp(0, newColumns.length);
    newColumns.insert(safeIndex, column);

    return CardLayoutModel(
      columns: _reindexColumns(newColumns),
      rows: rows,
      padding: padding,
      dragHandleRowHeight: dragHandleRowHeight,
      dragHandleColWidth: dragHandleColWidth,
    );
  }

  /// 删除列（返回新模型）
  ///
  /// 自动清理该列的覆盖信息，并重建后续列的索引。
  CardLayoutModel removeColumn(int index) {
    if (index < 0 || index >= columns.length) return this;

    final newColumns = List<ColumnDimension>.from(columns);
    newColumns.removeAt(index);

    return CardLayoutModel(
      columns: _reindexColumns(newColumns),
      rows: rows,
      padding: padding,
      dragHandleRowHeight: dragHandleRowHeight,
      dragHandleColWidth: dragHandleColWidth,
    );
  }

  /// 重排列（返回新模型）
  ///
  /// 宽度覆盖会自动跟随列移动到新位置。
  CardLayoutModel reorderColumn(int from, int to) {
    if (from < 0 || from >= columns.length) return this;

    final newColumns = List<ColumnDimension>.from(columns);
    final item = newColumns.removeAt(from);
    final target = to > from ? to - 1 : to;
    final safeTarget = target.clamp(0, newColumns.length);
    newColumns.insert(safeTarget, item);

    return CardLayoutModel(
      columns: _reindexColumns(newColumns),
      rows: rows,
      padding: padding,
      dragHandleRowHeight: dragHandleRowHeight,
      dragHandleColWidth: dragHandleColWidth,
    );
  }

  /// 更新列宽覆盖（返回新模型）
  CardLayoutModel updateColumnWidth(int index, double width) {
    if (index < 0 || index >= columns.length) return this;

    final newColumns = List<ColumnDimension>.from(columns);
    newColumns[index] = newColumns[index].withWidthOverride(width);

    return CardLayoutModel(
      columns: newColumns,
      rows: rows,
      padding: padding,
      dragHandleRowHeight: dragHandleRowHeight,
      dragHandleColWidth: dragHandleColWidth,
    );
  }

  /// 清除指定列的宽度覆盖
  CardLayoutModel clearColumnWidthOverride(int index) {
    if (index < 0 || index >= columns.length) return this;

    final newColumns = List<ColumnDimension>.from(columns);
    newColumns[index] = newColumns[index].clearWidthOverride();

    return CardLayoutModel(
      columns: newColumns,
      rows: rows,
      padding: padding,
      dragHandleRowHeight: dragHandleRowHeight,
      dragHandleColWidth: dragHandleColWidth,
    );
  }

  // ==================== 行操作方法 ====================

  /// 插入行（返回新模型）
  CardLayoutModel insertRow(int index, RowDimension row) {
    final newRows = List<RowDimension>.from(rows);
    final safeIndex = index.clamp(0, newRows.length);
    newRows.insert(safeIndex, row);

    return CardLayoutModel(
      columns: columns,
      rows: _reindexRows(newRows),
      padding: padding,
      dragHandleRowHeight: dragHandleRowHeight,
      dragHandleColWidth: dragHandleColWidth,
    );
  }

  /// 删除行（返回新模型）
  CardLayoutModel removeRow(int index) {
    if (index < 0 || index >= rows.length) return this;

    final newRows = List<RowDimension>.from(rows);
    newRows.removeAt(index);

    return CardLayoutModel(
      columns: columns,
      rows: _reindexRows(newRows),
      padding: padding,
      dragHandleRowHeight: dragHandleRowHeight,
      dragHandleColWidth: dragHandleColWidth,
    );
  }

  /// 重排行（返回新模型）
  CardLayoutModel reorderRow(int from, int to) {
    if (from < 0 || from >= rows.length) return this;

    final newRows = List<RowDimension>.from(rows);
    final item = newRows.removeAt(from);
    final target = to > from ? to - 1 : to;
    final safeTarget = target.clamp(0, newRows.length);
    newRows.insert(safeTarget, item);

    return CardLayoutModel(
      columns: columns,
      rows: _reindexRows(newRows),
      padding: padding,
      dragHandleRowHeight: dragHandleRowHeight,
      dragHandleColWidth: dragHandleColWidth,
    );
  }

  // ==================== 工具方法 ====================

  /// 更新 padding（返回新模型）
  CardLayoutModel withPadding(EdgeInsets newPadding) {
    return CardLayoutModel(
      columns: columns,
      rows: rows,
      padding: newPadding,
      dragHandleRowHeight: dragHandleRowHeight,
      dragHandleColWidth: dragHandleColWidth,
    );
  }

  /// 提取当前所有列宽覆盖
  ///
  /// 用于兼容旧系统或导出配置。
  Map<int, double> extractColumnWidthOverrides() {
    return {
      for (var col in columns)
        if (col.widthOverride != null) col.index: col.widthOverride!
    };
  }

  // ==================== 私有辅助方法 ====================

  /// 自动重建列索引（消除索引错位 bug）
  List<ColumnDimension> _reindexColumns(List<ColumnDimension> cols) {
    return cols.asMap().entries.map((e) {
      return e.value.withIndex(e.key);
    }).toList();
  }

  /// 自动重建行索引
  List<RowDimension> _reindexRows(List<RowDimension> rws) {
    return rws.asMap().entries.map((e) {
      return e.value.withIndex(e.key);
    }).toList();
  }

  // ==================== 工厂构造方法 ====================

  /// 从原有的 Payload Notifiers 构建模型（用于迁移）
  ///
  /// 这是新旧系统的桥接方法，允许从现有数据无缝构建新模型。
  static CardLayoutModel fromNotifiers({
    required List<PillarPayload> pillars,
    required List<RowPayload> rows,
    required EdgeInsets padding,
    Map<int, double>? columnWidthOverrides,
    double dragHandleRowHeight = 20.0,
    double dragHandleColWidth = 20.0,
  }) {
    final columns = pillars.asMap().entries.map((e) {
      return ColumnDimension(
        index: e.key,
        payload: e.value,
        widthOverride: columnWidthOverrides?[e.key],
      );
    }).toList();

    final rowDims = rows.asMap().entries.map((e) {
      return RowDimension(
        index: e.key,
        payload: e.value,
      );
    }).toList();

    return CardLayoutModel(
      columns: columns,
      rows: rowDims,
      padding: padding,
      dragHandleRowHeight: dragHandleRowHeight,
      dragHandleColWidth: dragHandleColWidth,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardLayoutModel &&
          runtimeType == other.runtimeType &&
          _listEquals(columns, other.columns) &&
          _listEquals(rows, other.rows) &&
          padding == other.padding &&
          dragHandleRowHeight == other.dragHandleRowHeight &&
          dragHandleColWidth == other.dragHandleColWidth;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(columns),
        Object.hashAll(rows),
        padding,
        dragHandleRowHeight,
        dragHandleColWidth,
      );

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'CardLayoutModel(columns: ${columns.length}, rows: ${rows.length}, '
        'padding: $padding)';
  }
}
