import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:common/widgets/editable_fourzhu_card/size_calculator/calculator.dart';
import 'package:common/widgets/editable_fourzhu_card/size_calculator/metrics.dart';
import 'package:flutter/material.dart';
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
      const pillar0 =
          PillarPayload(uuid: 'pillar_0', pillarType: PillarType.year);
      const pillar1 =
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
      const cellKeyP1 = 'row_0000|pillar_1';
      const cellSpecP1 = CellTextSpec(
        rowUuid: 'row_0000',
        pillarUuid: 'pillar_1',
        charCount: 1,
        fontSize: 40.0,
      );

      final calculator = CardMetricsCalculator(
        theme: theme,
        payload: payload,
        cellTextSpecMap: const {
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

      expect(rowMetrics.contentHeight, greaterThan(30.0),
          reason: "Row height should be influenced by the large font cell");
      expect(cellMetricsP0.contentHeight, equals(rowMetrics.contentHeight),
          reason: "Small cell should stretch to row height");
      expect(cellMetricsP1.contentHeight, equals(rowMetrics.contentHeight),
          reason: "Large cell should match row height");
    });

    test('computeFinalSize includes grips and padding without extra fudge', () {
      const pillar0 =
          PillarPayload(uuid: 'pillar_0', pillarType: PillarType.year);
      const pillar1 =
          PillarPayload(uuid: 'pillar_1', pillarType: PillarType.month);

      final row0 = TextRowPayload(
          uuid: 'row_0000', rowType: RowType.heavenlyStem, titleInCell: false);
      final row1 = TextRowPayload(
          uuid: 'row_0001', rowType: RowType.earthlyBranch, titleInCell: false);

      payload = CardPayload(
        gender: Gender.male,
        pillarMap: {
          'pillar_0': pillar0,
          'pillar_1': pillar1,
        },
        pillarOrderUuid: ['pillar_0', 'pillar_1'],
        rowMap: {
          'row_0000': row0,
          'row_0001': row1,
        },
        rowOrderUuid: ['row_0000', 'row_0001'],
      );

      final calculator = CardMetricsCalculator(
        theme: theme,
        payload: payload,
      );
      final snapshot = calculator.compute();

      const grip = 20.0;
      const pad = EdgeInsets.all(12);

      const opts = MetricsComputeOptions(
        includeGrip: true,
        showTitleRow: false,
        showTitleCol: false,
        cellShowsTitle: false,
        cardPadding: pad,
        withCardBorder: false,
        cardBorderWidth: 0,
        gripRowHeight: grip,
        gripColWidth: grip,
        columnTitleHeight: 24,
        rowTitleWidth: 52,
      );

      final size = calculator.computeFinalSize(opts);

      final expectedW = (snapshot.totals.totalWidth + grip * 2 + pad.horizontal)
          .ceilToDouble();
      final expectedH = (snapshot.totals.totalHeight + grip * 2 + pad.vertical)
          .ceilToDouble();

      expect(size.width, expectedW);
      expect(size.height, expectedH);
    });
  });
}
