import 'package:flutter/material.dart';
import '../../../models/drag_payloads.dart';
import '../../../models/text_style_config.dart';
import '../../../themes/editable_four_zhu_card_theme.dart';
import 'card_data_adapter.dart';
import 'card_decoration.dart';
import 'card_drag_handler.dart';
import 'card_size_manager.dart';

/// CardBuilders
///
/// 负责构建所有 UI 组件。
class CardBuilders {
  /// 构建主卡片
  static Widget buildCard({
    required BuildContext context,
    required CardSizeManager sizeManager,
    required CardDragHandler dragHandler,
    required GlobalKey cardKey,
    required Size size,
    required EditableFourZhuCardTheme theme,
    required CardPayload payload,
    required Brightness brightness,
    required ColorPreviewMode colorPreviewMode,
    required EdgeInsets padding,
    required bool showGripRows,
    required bool showGripColumns,
  }) {
    return Container(
      key: cardKey,
      width: size.width,
      height: size.height,
      padding: padding,
      decoration: _buildCardDecoration(theme, brightness),
      child: _buildCardContent(
        context: context,
        sizeManager: sizeManager,
        dragHandler: dragHandler,
        theme: theme,
        payload: payload,
        brightness: brightness,
        colorPreviewMode: colorPreviewMode,
        showGripRows: showGripRows,
        showGripColumns: showGripColumns,
      ),
    );
  }

  /// 构建卡片内容
  static Widget _buildCardContent({
    required BuildContext context,
    required CardSizeManager sizeManager,
    required CardDragHandler dragHandler,
    required EditableFourZhuCardTheme theme,
    required CardPayload payload,
    required Brightness brightness,
    required ColorPreviewMode colorPreviewMode,
    required bool showGripRows,
    required bool showGripColumns,
  }) {
    final children = <Widget>[];

    // 获取最新的 snapshot (可能包含拖拽状态)
    final snapshot = sizeManager.computeSnapshot();
    final pillarOrder = snapshot.pillarOrderUuid;
    final rowOrder = snapshot.rowOrderUuid;

    // 1. 构建顶部抓手行 (Grip Row)
    if (showGripRows) {
      children.add(_buildGripRow(
        context: context,
        sizeManager: sizeManager,
        payload: payload, // GripRow 内部也应该使用 snapshot, 但我们传入了 sizeManager
        pillarOrder: pillarOrder, // 传入排序后的列表
        showGripColumns: showGripColumns,
        dragHandler: dragHandler,
      ));
    }

    // 2. 构建表头行 (Header Row)
    // ...

    // 3. 遍历构建所有数据行
    for (int i = 0; i < rowOrder.length; i++) {
      final rowUuid = rowOrder[i];
      // 注意: payload.rowMap 仍然包含原始数据
      final rowPayload = payload.rowMap[rowUuid];
      if (rowPayload == null) continue;

      children.add(_buildDataRow(
        context: context,
        rowPayload: rowPayload,
        rowIndex: i,
        sizeManager: sizeManager,
        payload: payload,
        pillarOrder: pillarOrder, // 传入排序后的列表
        theme: theme,
        brightness: brightness,
        colorPreviewMode: colorPreviewMode,
        showGripColumns: showGripColumns,
        dragHandler: dragHandler,
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// 构建顶部抓手行
  static Widget _buildGripRow({
    required BuildContext context,
    required CardSizeManager sizeManager,
    required CardPayload payload,
    required List<String> pillarOrder,
    required bool showGripColumns,
    required CardDragHandler dragHandler,
  }) {
    final children = <Widget>[];

    // 左上角空白/抓手 (对应 Grip Column)
    if (showGripColumns) {
      children.add(SizedBox(
        width: sizeManager.dragHandleColWidth,
        height: sizeManager.dragHandleRowHeight,
      ));
    }

    // 行标题列顶部的空白 (对应 Row Title Column)
    if (sizeManager.theme.displayRowTitleColumn) {
      children.add(SizedBox(
        width: sizeManager.rowTitleWidth,
        height: sizeManager.dragHandleRowHeight,
      ));
    }

    // 各列的抓手
    for (int i = 0; i < pillarOrder.length; i++) {
      final colWidth = sizeManager.getColumnWidth(i);

      // 检查是否正在拖拽该列 (用于未来扩展，如显示不同样式)
      // final isDraggingThis = dragHandler.isDraggingColumn &&
      //    dragHandler.draggingColumnIndex == i;

      children.add(_buildColumnGrip(
        context: context,
        index: i,
        width: colWidth,
        height: sizeManager.dragHandleRowHeight,
        dragHandler: dragHandler,
        sizeManager: sizeManager,
      ));
    }

    return Row(children: children);
  }

  static Widget _buildColumnGrip({
    required BuildContext context,
    required int index,
    required double width,
    required double height,
    required CardDragHandler dragHandler,
    required CardSizeManager sizeManager,
  }) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => dragHandler.isDraggingColumn,
      onMove: (details) => dragHandler.onColumnHover(index),
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: index,
          axis: Axis.horizontal,
          maxSimultaneousDrags: 1,
          onDragStarted: () => dragHandler.onColumnDragStart(index),
          onDragEnd: (_) => dragHandler.onColumnDragEnd(),
          feedback: Material(
            elevation: 4,
            color: Colors.transparent,
            child: Container(
              width: width,
              height: height, // 应该显示整列的高度?
              // V3 中 feedback 是整列. sizeManager.calculator.getColumnGhostSize()
              // 但这里只构建 grip.
              // 我们暂且只显示 grip 作为 feedback, 或者构建一个简单的 ghost.
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.5),
                border: Border.all(color: Colors.blue),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.drag_handle, color: Colors.white),
            ),
          ),
          childWhenDragging: Container(
            width: width,
            height: height,
            color: Colors.grey.withValues(alpha: 0.2), // 占位样式
          ),
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            color: Colors.transparent, // 响应点击
            child: const Icon(Icons.drag_handle, size: 12, color: Colors.grey),
          ),
        );
      },
    );
  }

  static Widget _buildRowGrip({
    required BuildContext context,
    required int index,
    required double width,
    required double height,
    required CardDragHandler dragHandler,
  }) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => dragHandler.isDraggingRow,
      onMove: (details) => dragHandler.onRowHover(index),
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: index,
          axis: Axis.vertical,
          maxSimultaneousDrags: 1,
          onDragStarted: () => dragHandler.onRowDragStart(index),
          onDragEnd: (_) => dragHandler.onRowDragEnd(),
          feedback: Material(
            elevation: 4,
            color: Colors.transparent,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.5),
                border: Border.all(color: Colors.blue),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.drag_indicator, color: Colors.white),
            ),
          ),
          childWhenDragging: Container(
            width: width,
            height: height,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            color: Colors.transparent,
            child:
                const Icon(Icons.drag_indicator, size: 12, color: Colors.grey),
          ),
        );
      },
    );
  }

  /// 构建数据行
  static Widget _buildDataRow({
    required BuildContext context,
    required RowPayload rowPayload,
    required int rowIndex,
    required CardSizeManager sizeManager,
    required CardPayload payload,
    required List<String> pillarOrder,
    required EditableFourZhuCardTheme theme,
    required Brightness brightness,
    required ColorPreviewMode colorPreviewMode,
    required bool showGripColumns,
    required CardDragHandler dragHandler,
  }) {
    final children = <Widget>[];
    final rowHeight = sizeManager.getRowHeight(rowIndex);

    // 1. 左侧抓手列 (Grip Column)
    if (showGripColumns) {
      children.add(_buildRowGrip(
        context: context,
        index: rowIndex,
        width: sizeManager.dragHandleColWidth,
        height: rowHeight,
        dragHandler: dragHandler,
      ));
    }

    // 2. 行标题列 (Row Title Column)
    if (sizeManager.theme.displayRowTitleColumn) {
      String title = '';
      if (rowPayload is TextRowPayload) {
        if (rowPayload.rowLabel != null) {
          title = rowPayload.rowLabel!;
        }
      } else if (rowPayload is ColumnHeaderRowPayload) {
        title = rowPayload.genderLabel;
      }

      children.add(Container(
        width: sizeManager.rowTitleWidth,
        height: rowHeight,
        alignment: Alignment.center,
        child: Text(title, style: const TextStyle(fontSize: 12)), // 简单渲染
      ));
    }

    // 3. 数据单元格
    // 获取该行所有单元格的数据
    final rowValues = CardDataAdapter.getRowValues(
      rowType: rowPayload.rowType,
      payload: payload,
      rowStrategyMapper: sizeManager.rowStrategyMapper,
    );

    for (int i = 0; i < pillarOrder.length; i++) {
      final pillarUuid = pillarOrder[i];
      final colWidth = sizeManager.getColumnWidth(i);
      final text = rowValues[pillarUuid] ?? '';

      // 获取样式
      final style = CardDataAdapter.getCellStyle(
        rowType: rowPayload.rowType,
        content: text,
        theme: theme,
        brightness: brightness,
        colorPreviewMode: colorPreviewMode,
      );

      children.add(Container(
        width: colWidth,
        height: rowHeight,
        alignment: Alignment.center,
        decoration: CardDecoration.getCellDecoration(
          rowType: rowPayload.rowType,
          theme: theme,
          brightness: brightness,
        ),
        child: Text(text, style: style),
      ));
    }

    return Row(children: children);
  }

  /// 构建卡片装饰
  static BoxDecoration _buildCardDecoration(
    EditableFourZhuCardTheme theme,
    Brightness brightness,
  ) {
    final border = theme.card.border;
    final borderWidth =
        (border != null && border.enabled) ? border.width ?? 0.0 : 0.0;

    return BoxDecoration(
      color: brightness == Brightness.light
          ? theme.card.lightBackgroundColor
          : theme.card.darkBackgroundColor,
      border: borderWidth > 0
          ? Border.all(
              color: brightness == Brightness.light
                  ? theme.card.border!.lightColor
                  : theme.card.border!.darkColor,
              width: borderWidth,
            )
          : null,
      borderRadius: BorderRadius.circular(theme.card.border!.radius),
    );
  }
}
