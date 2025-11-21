import 'package:flutter/material.dart';
import '../drag_controller.dart';
import 'card_size_manager.dart';

/// CardDragHandler
///
/// 负责处理所有拖拽逻辑(行拖拽 + 列拖拽)。
class CardDragHandler {
  final VoidCallback onStateChanged;
  final CardSizeManager sizeManager;
  final EditableCardDragController dragController;

  // 拖拽状态
  int? _draggingColumnIndex;
  int? _draggingRowIndex;
  int? _hoverColumnIndex;
  int? _hoverRowIndex;

  CardDragHandler({
    required this.onStateChanged,
    required this.sizeManager,
    required this.dragController,
  });

  // 列拖拽
  void onColumnDragStart(int index) {
    _draggingColumnIndex = index;
    sizeManager.startColumnDrag(index);
    onStateChanged();
  }

  void onColumnHover(int hoverIndex) {
    if (_draggingColumnIndex == null) return;
    if (_hoverColumnIndex == hoverIndex) return;

    _hoverColumnIndex = hoverIndex;
    sizeManager.updateColumnDrag(hoverIndex);
    onStateChanged();
  }

  void onColumnDragEnd() {
    _draggingColumnIndex = null;
    _hoverColumnIndex = null;
    sizeManager.endColumnDrag();
    onStateChanged();
  }

  // 行拖拽
  void onRowDragStart(int index) {
    _draggingRowIndex = index;
    sizeManager.startRowDrag(index);
    onStateChanged();
  }

  void onRowHover(int hoverIndex) {
    if (_draggingRowIndex == null) return;
    if (_hoverRowIndex == hoverIndex) return;

    _hoverRowIndex = hoverIndex;
    sizeManager.updateRowDrag(hoverIndex);
    onStateChanged();
  }

  void onRowDragEnd() {
    _draggingRowIndex = null;
    _hoverRowIndex = null;
    sizeManager.endRowDrag();
    onStateChanged();
  }

  // 状态查询
  bool get isDraggingColumn => _draggingColumnIndex != null;
  bool get isDraggingRow => _draggingRowIndex != null;
  int? get draggingColumnIndex => _draggingColumnIndex;
  int? get draggingRowIndex => _draggingRowIndex;
}
