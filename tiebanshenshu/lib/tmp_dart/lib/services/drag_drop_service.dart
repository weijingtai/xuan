import 'package:flutter/material.dart';
import '../models/atom_operation.dart';
import '../models/flow_node.dart';

class DragDropService {
  static final DragDropService _instance = DragDropService._internal();
  factory DragDropService() => _instance;
  DragDropService._internal();

  // 当前拖拽的数据
  AtomOperation? _draggedOperation;
  Offset? _dragOffset;
  bool _isDragging = false;

  // 拖拽状态监听器
  final List<VoidCallback> _dragStartListeners = [];
  final List<VoidCallback> _dragEndListeners = [];
  final List<ValueChanged<Offset>> _dragUpdateListeners = [];

  // Getters
  AtomOperation? get draggedOperation => _draggedOperation;
  Offset? get dragOffset => _dragOffset;
  bool get isDragging => _isDragging;

  // 开始拖拽
  void startDrag(AtomOperation operation, Offset startOffset) {
    _draggedOperation = operation;
    _dragOffset = startOffset;
    _isDragging = true;

    // 通知监听器
    for (final listener in _dragStartListeners) {
      listener();
    }
  }

  // 更新拖拽位置
  void updateDragPosition(Offset newOffset) {
    if (!_isDragging) return;

    _dragOffset = newOffset;

    // 通知监听器
    for (final listener in _dragUpdateListeners) {
      listener(newOffset);
    }
  }

  // 结束拖拽
  FlowNode? endDrag(Offset dropOffset) {
    if (!_isDragging || _draggedOperation == null) {
      return null;
    }

    final operation = _draggedOperation!;
    final node = FlowNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      operation: operation,
      position: dropOffset,
    );

    // 清理拖拽状态
    _draggedOperation = null;
    _dragOffset = null;
    _isDragging = false;

    // 通知监听器
    for (final listener in _dragEndListeners) {
      listener();
    }

    return node;
  }

  // 取消拖拽
  void cancelDrag() {
    if (!_isDragging) return;

    _draggedOperation = null;
    _dragOffset = null;
    _isDragging = false;

    // 通知监听器
    for (final listener in _dragEndListeners) {
      listener();
    }
  }

  // 添加监听器
  void addDragStartListener(VoidCallback listener) {
    _dragStartListeners.add(listener);
  }

  void addDragEndListener(VoidCallback listener) {
    _dragEndListeners.add(listener);
  }

  void addDragUpdateListener(ValueChanged<Offset> listener) {
    _dragUpdateListeners.add(listener);
  }

  // 移除监听器
  void removeDragStartListener(VoidCallback listener) {
    _dragStartListeners.remove(listener);
  }

  void removeDragEndListener(VoidCallback listener) {
    _dragEndListeners.remove(listener);
  }

  void removeDragUpdateListener(ValueChanged<Offset> listener) {
    _dragUpdateListeners.remove(listener);
  }

  // 清理所有监听器
  void dispose() {
    _dragStartListeners.clear();
    _dragEndListeners.clear();
    _dragUpdateListeners.clear();
  }

  // 检查是否可以放置到指定位置
  bool canDropAt(Offset position, Size canvasSize) {
    // 检查是否在画布范围内
    if (position.dx < 0 ||
        position.dy < 0 ||
        position.dx > canvasSize.width - 224 || // 节点宽度
        position.dy > canvasSize.height - 80) {
      // 节点高度
      return false;
    }
    return true;
  }

  // 获取拖拽预览数据
  Map<String, dynamic> getDragPreviewData() {
    if (_draggedOperation == null) return {};

    return {
      'id': _draggedOperation!.id,
      'name': _draggedOperation!.name,
      'category': _draggedOperation!.category.toString(),
      'inputType': _draggedOperation!.input,
      'outputType': _draggedOperation!.output,
    };
  }
}

// 拖拽数据传输对象
class DragData {
  final AtomOperation operation;
  final Offset startPosition;
  final DateTime timestamp;

  const DragData({
    required this.operation,
    required this.startPosition,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'operation': {
        'id': operation.id,
        'name': operation.name,
        'description': operation.description,
        'category': operation.category.toString(),
        'inputType': operation.input,
        'outputType': operation.output,
      },
      'startPosition': {'dx': startPosition.dx, 'dy': startPosition.dy},
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  static DragData fromJson(Map<String, dynamic> json) {
    final operationData = json['operation'] as Map<String, dynamic>;
    final positionData = json['startPosition'] as Map<String, dynamic>;

    return DragData(
      operation: AtomOperation(
        id: operationData['id'] as String,
        name: operationData['name'] as String,
        description: operationData['description'] as String,
        category: AtomOperationCategory.values.firstWhere(
          (e) => e.toString() == operationData['category'],
        ),
        input: operationData['inputType'] as String,
        output: operationData['outputType'] as String,
        type: '',
        icon: '',
      ),
      startPosition: Offset(
        positionData['dx'] as double,
        positionData['dy'] as double,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }
}

// 拖拽区域检测器
class DropZoneDetector {
  final Rect dropZone;
  final String id;
  final bool isActive;

  const DropZoneDetector({
    required this.dropZone,
    required this.id,
    this.isActive = true,
  });

  bool containsPoint(Offset point) {
    return isActive && dropZone.contains(point);
  }

  bool overlaps(Rect other) {
    return isActive && dropZone.overlaps(other);
  }
}

// 拖拽手势识别器
class DragGestureRecognizer {
  static const double _kMinDragDistance = 10.0;
  static const Duration _kLongPressTimeout = Duration(milliseconds: 500);

  static bool shouldStartDrag(Offset startPosition, Offset currentPosition) {
    final distance = (currentPosition - startPosition).distance;
    return distance >= _kMinDragDistance;
  }

  static bool isLongPress(DateTime startTime, DateTime currentTime) {
    final duration = currentTime.difference(startTime);
    return duration >= _kLongPressTimeout;
  }
}
