import 'package:flutter/material.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/models/text_style_config.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import '../../../../../enums/layout_template_enums.dart';
import '../widgets/ghost_pillar_widget.dart';
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
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final gripW =
          (sizeManager.dragHandleColWidth * dpr).floorToDouble() / dpr;
      children.add(SizedBox(
        width: gripW,
        height: sizeManager.dragHandleRowHeight,
      ));
    }

    // 各列的抓手
    for (int i = 0; i < pillarOrder.length; i++) {
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final rawWidth = sizeManager.getColumnWidth(i);
      final colWidth = (rawWidth * dpr).floorToDouble() / dpr;

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
    return Builder(
      builder: (gripContext) {
        return DragTarget<int>(
          onWillAcceptWithDetails: (details) => dragHandler.isDraggingColumn,
          onMove: (details) {
            final box = gripContext.findRenderObject() as RenderBox?;
            if (box == null) return;
            final local = box.globalToLocal(details.offset);
            final insertionIndex = (local.dx < width / 2) ? index : index + 1;
            dragHandler.onColumnHover(insertionIndex);
          },
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
                child: GhostPillarWidget.column(
                  width: width,
                  height: height,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                  borderColor: Theme.of(context).primaryColor,
                ),
              ),
              childWhenDragging: GhostPillarWidget.column(
                width: width,
                height: height,
              ),
              child: Container(
                width: width,
                height: height,
                alignment: Alignment.center,
                color: Colors.transparent, // 响应点击
                child:
                    const Icon(Icons.drag_handle, size: 12, color: Colors.grey),
              ),
            );
          },
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
    required RowPayload rowPayload,
  }) {
    // 禁止拖拽表头行
    if (rowPayload.rowType == RowType.columnHeaderRow) {
      return Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        color: Colors.transparent,
      );
    }

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
            child: GhostPillarWidget.row(
              width: width,
              height: height,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              borderColor: Theme.of(context).primaryColor,
            ),
          ),
          childWhenDragging: GhostPillarWidget.row(
            width: width,
            height: height,
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
        rowPayload: rowPayload,
      ));
    }

    // 3. 数据单元格
    // 获取该行所有单元格的数据
    final rowValues = CardDataAdapter.getRowValues(
      rowType: rowPayload.rowType,
      payload: payload,
      rowStrategyMapper: sizeManager.rowStrategyMapper,
      pillarStrategyMapper: sizeManager.pillarStrategyMapper,
    );

    for (int i = 0; i < pillarOrder.length; i++) {
      final pillarUuid = pillarOrder[i];
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final rawWidth = sizeManager.getColumnWidth(i);
      final colWidth = (rawWidth * dpr).floorToDouble() / dpr;
      final text = rowValues[pillarUuid] ?? '';

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
      color: theme.card.resolveBackgroundColor(brightness),
      border: borderWidth > 0
          ? Border.all(
              color: theme.card.border!.resolveColor(brightness),
              width: borderWidth,
            )
          : null,
      borderRadius: BorderRadius.circular(theme.card.border!.radius),
    );
  }
}
