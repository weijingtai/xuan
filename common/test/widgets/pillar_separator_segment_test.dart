import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/models/pillar_content.dart';
import 'package:common/models/text_style_config.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:common/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart';
import '../test_editable_fourzhu_card_defaults.dart';

void main() {
  testWidgets('pillar segmented rendering inserts gap between sections',
      (tester) async {
    final pillars = <PillarPayload>[
      const RowTitleColumnPayload(uuid: 'col_title'),
      ContentPillarPayload(
        uuid: 'col_year',
        pillarType: PillarType.year,
        pillarLabel: '年',
        pillarContent: PillarContent(
          id: 'year#1',
          pillarType: PillarType.year,
          label: '年',
          jiaZi: JiaZi.JIA_ZI,
          version: '1',
          sourceKind: PillarSourceKind.userInput,
        ),
      ),
      ContentPillarPayload(
        uuid: 'col_month',
        pillarType: PillarType.month,
        pillarLabel: '月',
        pillarContent: PillarContent(
          id: 'month#1',
          pillarType: PillarType.month,
          label: '月',
          jiaZi: JiaZi.JIA_ZI,
          version: '1',
          sourceKind: PillarSourceKind.userInput,
        ),
      ),
    ];

    final rows = <RowPayload>[
      ColumnHeaderRowPayload(gender: Gender.male, uuid: 'row_header'),
      TextRowPayload(
          rowType: RowType.heavenlyStem,
          uuid: 'row_gan',
          rowLabel: '天干',
          titleInCell: true),
      RowSeparatorPayload(uuid: 'row_sep'),
      TextRowPayload(
          rowType: RowType.earthlyBranch,
          uuid: 'row_zhi',
          rowLabel: '地支',
          titleInCell: true),
    ];

    final cardPayload = CardPayload(
      gender: Gender.male,
      pillarMap: {for (final p in pillars) p.uuid: p},
      rowMap: {for (final r in rows) r.uuid: r},
      pillarOrderUuid: pillars.map((p) => p.uuid).toList(),
      rowOrderUuid: rows.map((r) => r.uuid).toList(),
    );

    final theme = EditableCardThemeBuilder.createDefaultTheme();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 300,
            child: EditableFourZhuCardV3(
              dayGanZhi: JiaZi.JIA_ZI,
              brightnessNotifier: ValueNotifier(Brightness.light),
              colorPreviewModeNotifier: ValueNotifier(ColorPreviewMode.pure),
              themeNotifier: ValueNotifier(theme),
              cardPayloadNotifier: ValueNotifier(cardPayload),
              paddingNotifier: ValueNotifier(EdgeInsets.zero),
              rowStrategyMapper: defaultRowStrategyMapper(),
              gender: Gender.male,
              showGrip: false,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pillar-segment-gap-1-0')), findsOneWidget);
    expect(find.byKey(const Key('pillar-segment-gap-2-0')), findsOneWidget);
  });
}
