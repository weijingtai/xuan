import 'package:flutter_test/flutter_test.dart';
import 'package:common/widgets/editable_fourzhu_card/drag_controller.dart';

void main() {
  group('EditableCardDragController throttle behavior', () {
    test('row throttle respects cooldown and counts processed moves', () async {
      // Arrange: 12ms cooldown for row moves
      final c = EditableCardDragController(columnMoveCooldownMs: 12, rowMoveCooldownMs: 12);

      // Act & Assert: first move allowed
      expect(c.allowRowMove(), isTrue);
      // Immediate second move blocked within cooldown
      expect(c.allowRowMove(), isFalse);

      // Wait slightly longer than cooldown
      await Future<void>.delayed(const Duration(milliseconds: 13));
      // Next move allowed
      expect(c.allowRowMove(), isTrue);

      // Snapshot and reset counts
      final snap = c.snapshotAndResetMoveCounts();
      expect(snap.row, 2);
      expect(snap.column, 0);

      // After reset, counts are zero
      expect(c.rowMoveProcessedCount, 0);
      expect(c.columnMoveProcessedCount, 0);
    });

    test('column throttle respects cooldown and counts processed moves', () async {
      // Arrange: 12ms cooldown for column moves
      final c = EditableCardDragController(columnMoveCooldownMs: 12, rowMoveCooldownMs: 12);

      // Act & Assert: first move allowed
      expect(c.allowColumnMove(), isTrue);
      // Immediate second move blocked within cooldown
      expect(c.allowColumnMove(), isFalse);

      // Wait slightly longer than cooldown
      await Future<void>.delayed(const Duration(milliseconds: 13));
      // Next move allowed
      expect(c.allowColumnMove(), isTrue);

      // Snapshot and reset counts
      final snap = c.snapshotAndResetMoveCounts();
      expect(snap.column, 2);
      expect(snap.row, 0);

      // After reset, counts are zero
      expect(c.rowMoveProcessedCount, 0);
      expect(c.columnMoveProcessedCount, 0);
    });

    test('reset throttle clears timestamps allowing immediate next move', () async {
      final c = EditableCardDragController(columnMoveCooldownMs: 12, rowMoveCooldownMs: 12);

      expect(c.allowRowMove(), isTrue);
      // Within cooldown, not allowed
      expect(c.allowRowMove(), isFalse);

      // Reset throttle and should allow immediately
      c.resetRowThrottle();
      expect(c.allowRowMove(), isTrue);
    });
  });
}