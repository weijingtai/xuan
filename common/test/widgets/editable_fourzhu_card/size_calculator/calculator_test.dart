import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:common/widgets/editable_fourzhu_card/size_calculator/calculator.dart';
import 'package:common/widgets/editable_fourzhu_card/size_calculator/metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardMetricsCalculator', () {
    late EditableFourZhuCardTheme theme;
    late CardPayload payload;

    setUp(() {
      theme = EditableCardThemeBuilder.createDefaultTheme();
    });

    test('Row height is determined by the tallest cell', () {
      // 1. Setup payload with 1 row and 2 columns
      final pillar0 =
          PillarPayload(uuid: 'pillar_0', pillarType: PillarType.year);
      final pillar1 =
          PillarPayload(uuid: 'pillar_1', pillarType: PillarType.month);

      final row0 = TextRowPayload(
          uuid: 'row_0000', rowType: RowType.heavenlyStem, titleInCell: false);

      payload = CardPayload(
        gender: Gender.male,
        pillarMap: {
          'pillar_0': pillar0,
          'pillar_1': pillar1,
        },
        pillarOrderUuid: ['pillar_0', 'pillar_1'],
        rowMap: {
          'row_0000': row0,
        },
        rowOrderUuid: ['row_0000'],
      );

      // 2. Define a large font size for the second cell (p1)
      // Normal row height is approx 14 * 1.4 = 19.6 (or similar depending on theme)
      // We set p1 to have a huge font size, e.g., 40.0
      final cellKeyP1 = 'row_0000|pillar_1';
      final cellSpecP1 = CellTextSpec(
        rowUuid: 'row_0000',
        pillarUuid: 'pillar_1',
        charCount: 1,
        fontSize: 40.0,
      );

      final calculator = CardMetricsCalculator(
        theme: theme,
        payload: payload,
        cellTextSpecMap: {
          cellKeyP1: cellSpecP1,
        },
      );

      // 3. Compute
      final snapshot = calculator.compute();
      final rowMetrics = snapshot.rows['row_0000']!;
      final cellMetricsP0 = snapshot.cells['row_0000|pillar_0']!;
      final cellMetricsP1 = snapshot.cells['row_0000|pillar_1']!;

      // 4. Verify
      // Expected height calculation: 40.0 * 1.4 = 56.0
      // The row height should be driven by p1, not p0 (which uses default theme font size)

      print('Row Content Height: ${rowMetrics.contentHeight}');
      print('Cell P0 Content Height: ${cellMetricsP0.contentHeight}');
      print('Cell P1 Content Height: ${cellMetricsP1.contentHeight}');

      expect(rowMetrics.contentHeight, greaterThan(30.0),
          reason: "Row height should be influenced by the large font cell");
      expect(cellMetricsP0.contentHeight, equals(rowMetrics.contentHeight),
          reason: "Small cell should stretch to row height");
      expect(cellMetricsP1.contentHeight, equals(rowMetrics.contentHeight),
          reason: "Large cell should match row height");
    });
  });
}
