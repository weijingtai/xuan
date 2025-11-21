import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:common/widgets/editable_fourzhu_card/size_calculator/enhanced_calculator.dart';
import 'package:common/widgets/editable_fourzhu_card/size_calculator/enhanced_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnhancedCardMetricsCalculator', () {
    late EditableFourZhuCardTheme theme;
    late CardPayload payload;
    late EnhancedCardMetricsCalculator calculator;

    setUp(() {
      theme = EditableCardThemeBuilder.createDefaultTheme();
      
      final pillar0 = PillarPayload(uuid: 'p0', pillarType: PillarType.year);
      final pillar1 = PillarPayload(uuid: 'p1', pillarType: PillarType.month);
      
      final row0 = TextRowPayload(uuid: 'r0', rowType: RowType.heavenlyStem, titleInCell: false);
      final row1 = TextRowPayload(uuid: 'r1', rowType: RowType.earthlyBranch, titleInCell: false);

      payload = CardPayload(
        gender: Gender.male,
        pillarMap: {
          'p0': pillar0,
          'p1': pillar1,
        },
        pillarOrderUuid: ['p0', 'p1'],
        rowMap: {
          'r0': row0,
          'r1': row1,
        },
        rowOrderUuid: ['r0', 'r1'],
      );

      calculator = EnhancedCardMetricsCalculator(
        theme: theme,
        payload: payload,
      );
    });

    test('compute returns EnhancedCardMetricsSnapshot', () {
      final snapshot = calculator.compute();
      expect(snapshot, isA<EnhancedCardMetricsSnapshot>());
      expect(snapshot.pillarOrderUuid, ['p0', 'p1']);
      expect(snapshot.rowOrderUuid, ['r0', 'r1']);
    });

    group('Column Operations', () {
      test('insertColumn adds a column and updates metrics', () {
        final newCol = PillarPayload(uuid: 'p2', pillarType: PillarType.day);
        final snapshot = calculator.insertColumn(1, newCol);

        expect(snapshot.pillarOrderUuid, ['p0', 'p2', 'p1']);
        expect(snapshot.pillars.containsKey('p2'), true);
        expect(snapshot.cells.keys.any((k) => k.endsWith('|p2')), true);
        expect(snapshot.totals.columnCount, 3);
      });

      test('removeColumn removes a column and updates metrics', () {
        final snapshot = calculator.removeColumn(0);

        expect(snapshot.pillarOrderUuid, ['p1']);
        expect(snapshot.pillars.containsKey('p0'), false);
        expect(snapshot.cells.keys.any((k) => k.endsWith('|p0')), false);
        expect(snapshot.totals.columnCount, 1);
      });

      test('reorderColumn changes order', () {
        final snapshot = calculator.reorderColumn(0, 2); // Move p0 to end

        expect(snapshot.pillarOrderUuid, ['p1', 'p0']);
      });
    });

    group('Row Operations', () {
      test('insertRow adds a row and updates metrics', () {
        final newRow = TextRowPayload(uuid: 'r2', rowType: RowType.tenGod, titleInCell: false);
        final snapshot = calculator.insertRow(1, newRow);

        expect(snapshot.rowOrderUuid, ['r0', 'r2', 'r1']);
        expect(snapshot.rows.containsKey('r2'), true);
        expect(snapshot.cells.keys.any((k) => k.startsWith('r2|')), true);
        expect(snapshot.totals.rowCount, 3);
      });

      test('removeRow removes a row and updates metrics', () {
        final snapshot = calculator.removeRow(0);

        expect(snapshot.rowOrderUuid, ['r1']);
        expect(snapshot.rows.containsKey('r0'), false);
        expect(snapshot.cells.keys.any((k) => k.startsWith('r0|')), false);
        expect(snapshot.totals.rowCount, 1);
      });

      test('reorderRow changes order', () {
        final snapshot = calculator.reorderRow(0, 2); // Move r0 to end

        expect(snapshot.rowOrderUuid, ['r1', 'r0']);
      });
    });

    group('Drag State', () {
      test('startColumnDrag sets drag state', () {
        final snapshot = calculator.startColumnDrag(0);
        expect(snapshot.dragState, isA<ColumnDragging>());
        expect((snapshot.dragState as ColumnDragging).pillarUuid, 'p0');
      });

      test('updateColumnDrag updates order', () {
        calculator.startColumnDrag(0);
        final snapshot = calculator.updateColumnDrag(1);
        
        expect(snapshot.pillarOrderUuid, ['p1', 'p0']);
        expect((snapshot.dragState as ColumnDragging).currentIndex, 1);
      });

      test('endColumnDrag clears drag state', () {
        calculator.startColumnDrag(0);
        final snapshot = calculator.endColumnDrag();
        expect(snapshot.dragState, isA<IdleDragState>());
      });
    });
  });
}
