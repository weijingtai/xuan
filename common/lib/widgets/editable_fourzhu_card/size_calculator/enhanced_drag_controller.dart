import 'package:flutter/foundation.dart';
import '../drag_controller.dart';
import 'enhanced_calculator.dart';
import 'enhanced_snapshot.dart';

class EnhancedDragController extends EditableCardDragController {
  final EnhancedCardMetricsCalculator calculator;
  final ValueNotifier<EnhancedCardMetricsSnapshot> snapshotNotifier;

  EnhancedDragController({
    required this.calculator,
    required this.snapshotNotifier,
    super.columnMoveCooldownMs = 12,
    super.rowMoveCooldownMs = 12,
  });

  // 列拖拽
  void startColumnDrag(int index) {
    final newSnapshot = calculator.startColumnDrag(index);
    snapshotNotifier.value = newSnapshot;
  }

  void updateColumnDrag(int newIndex) {
    if (!allowColumnMove()) return;
    final newSnapshot = calculator.updateColumnDrag(newIndex);
    snapshotNotifier.value = newSnapshot;
  }

  void endColumnDrag() {
    final newSnapshot = calculator.endColumnDrag();
    snapshotNotifier.value = newSnapshot;
    resetColumnThrottle();
  }

  // 行拖拽
  void startRowDrag(int index) {
    final newSnapshot = calculator.startRowDrag(index);
    snapshotNotifier.value = newSnapshot;
  }

  void updateRowDrag(int newIndex) {
    if (!allowRowMove()) return;
    final newSnapshot = calculator.updateRowDrag(newIndex);
    snapshotNotifier.value = newSnapshot;
  }

  void endRowDrag() {
    final newSnapshot = calculator.endRowDrag();
    snapshotNotifier.value = newSnapshot;
    resetRowThrottle();
  }
}
