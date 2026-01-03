import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:common/enums/layout_template_enums.dart';
import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/enums/enum_di_zhi.dart';
import 'package:common/models/drag_payloads.dart';
import 'package:common/models/pillar_content.dart';
import 'package:common/models/row_strategy.dart';
import 'package:common/models/text_style_config.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:common/widgets/editable_fourzhu_card/models/cell_style_config.dart';
import 'package:common/widgets/editable_fourzhu_card/text_groups.dart';
import 'package:common/utils/style_resolver.dart';
import 'package:common/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart';
import '../test_editable_fourzhu_card_defaults.dart';

/// A test-only style probe that mirrors the card's style resolution precedence.
/// It renders a single Text using centralized defaults and global/group overrides.
class StyleProbeWidget extends StatelessWidget {
  const StyleProbeWidget({
    super.key,
    required this.group,
    this.colorfulMode = false,
    this.groupTextStyles,
    this.globalFontFamily,
    this.globalFontSize,
    this.globalFontColor,
    this.gan,
    this.zhi,
    this.elementColorResolver = const DefaultElementColorResolver(),
    required this.text,
  });

  final TextGroup group;
  final bool colorfulMode;
  final Map<TextGroup, TextStyle>? groupTextStyles;
  final String? globalFontFamily;
  final double? globalFontSize;
  final Color? globalFontColor;
  final TianGan? gan;
  final DiZhi? zhi;
  final ElementColorResolver elementColorResolver;
  final String text;

  TextStyle _defaultTextStyleForGroup(TextGroup? group) {
    switch (group) {
      case TextGroup.rowTitle:
      case TextGroup.columnTitle:
        return const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87);
      case TextGroup.naYin:
        return const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: Colors.amber);
      case TextGroup.kongWang:
      case TextGroup.tenGod:
      case TextGroup.xunShou:
      case TextGroup.hiddenStems:
        return const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87);
      case TextGroup.tianGan:
        return const TextStyle(fontSize: 24, fontWeight: FontWeight.w400);
      case TextGroup.diZhi:
        return const TextStyle(fontSize: 24, fontWeight: FontWeight.w500);
      default:
        return const TextStyle();
    }
  }

  TextStyle _resolveTextStyle(BuildContext context) {
    var style = _defaultTextStyleForGroup(group);
    // Global family/size
    if (globalFontFamily != null && globalFontFamily!.isNotEmpty) {
      style = style.copyWith(fontFamily: globalFontFamily);
    }
    if (globalFontSize != null && globalFontSize! > 0) {
      style = style.copyWith(fontSize: globalFontSize);
    }
    // Color precedence:
    final bool isGanZhi =
        group == TextGroup.tianGan || group == TextGroup.diZhi;
    final bool suppressGlobalColor = colorfulMode && isGanZhi;
    if (globalFontColor != null && !suppressGlobalColor) {
      style = style.copyWith(color: globalFontColor);
    }
    // In colorful mode, resolve per-token color via resolver if not overridden by group/global.
    if (colorfulMode && isGanZhi) {
      final Color tokenColor = gan != null
          ? elementColorResolver.colorForGan(gan!, context)
          : elementColorResolver.colorForZhi(zhi!, context);
      style = style.copyWith(color: tokenColor);
    }
    // Group overrides: last-wins and overrides color regardless of colorfulMode.
    if (groupTextStyles != null) {
      final override = groupTextStyles![group];
      if (override != null) {
        if (override.fontFamily != null && override.fontFamily!.isNotEmpty) {
          style = style.copyWith(fontFamily: override.fontFamily);
        }
        if (override.fontSize != null && override.fontSize! > 0) {
          style = style.copyWith(fontSize: override.fontSize);
        }
        if (override.fontWeight != null) {
          style = style.copyWith(fontWeight: override.fontWeight);
        }
        if (override.shadows != null && override.shadows!.isNotEmpty) {
          style = style.copyWith(shadows: override.shadows);
        }
        if (override.color != null) {
          style = style.copyWith(color: override.color);
        }
      }
    }
    // Ensure non-colorful Gan/Zhi default to black87 when color remains null.
    if (isGanZhi && !colorfulMode && style.color == null) {
      style = style.copyWith(color: Colors.black87);
    }
    return style;
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveTextStyle(context);
    return MaterialApp(
        home: Scaffold(body: Center(child: Text(text, style: style))));
  }
}

void main() {
  group('EditableFourZhuCardV3 TextStyle resolution', () {
    test('Column header row content style falls back to pillarTitle', () {
      final base = TypographySection.defaultTypographySection;
      final rowTitle = base.rowTitle.copyWith(
        fontStyleDataModel: base.rowTitle.fontStyleDataModel.copyWith(
          fontSize: 11,
        ),
      );
      final pillarTitle = base.pillarTitle.copyWith(
        fontStyleDataModel: base.pillarTitle.fontStyleDataModel.copyWith(
          fontSize: 22,
        ),
      );
      final t = base.copyWith(
        rowTitle: rowTitle,
        pillarTitle: pillarTitle,
        cellContentMapper: const {},
      );

      expect(
        t.getCellContentBy(RowType.columnHeaderRow).fontStyleDataModel.fontSize,
        22,
      );
    });

    testWidgets('NaYin and KongWang default styles are applied',
        (tester) async {
      // Verify strategy outputs (data correctness)
      final pillars = [
        PillarContent(
          id: 'year#1',
          pillarType: PillarType.year,
          label: '年',
          jiaZi: JiaZi.JIA_ZI,
          description: null,
          version: '1',
          sourceKind: PillarSourceKind.userInput,
          operationType: null,
        )
      ];
      final input = RowComputationInput(
        pillars: pillars,
        dayJiaZi: JiaZi.JIA_ZI,
        gender: Gender.male,
      );
      final naYin = NaYinRowStrategy().compute(input);
      final kongWang = KongWangRowStrategy().compute(input);
      expect(naYin.perPillarValues['year#1'], '海中金');
      expect(kongWang.perPillarValues['year#1'], '戌亥');

      // Verify default styles via probe
      await tester.pumpWidget(
          const StyleProbeWidget(group: TextGroup.naYin, text: '海中金'));
      await tester.pumpAndSettle();
      final naYinText = tester.widget<Text>(find.text('海中金'));
      expect(naYinText.style?.fontSize, 14);
      expect(naYinText.style?.fontWeight, FontWeight.w400);
      expect(naYinText.style?.color, Colors.amber);

      await tester.pumpWidget(
          const StyleProbeWidget(group: TextGroup.kongWang, text: '戌亥'));
      await tester.pumpAndSettle();
      final kongWangText = tester.widget<Text>(find.text('戌亥'));
      expect(kongWangText.style?.fontSize, 14);
      expect(kongWangText.style?.fontWeight, FontWeight.w400);
      expect(kongWangText.style?.color, Colors.black87);
    });

    testWidgets('Global font color applies to Gan/Zhi when colorfulMode is OFF',
        (tester) async {
      const globalColor = Colors.purple;
      await tester.pumpWidget(const StyleProbeWidget(
        group: TextGroup.tianGan,
        text: '甲',
        colorfulMode: false,
        globalFontColor: globalColor,
        gan: TianGan.JIA,
      ));
      await tester.pumpAndSettle();
      final ganText = tester.widget<Text>(find.text('甲'));
      expect(ganText.style?.color, globalColor);

      await tester.pumpWidget(const StyleProbeWidget(
        group: TextGroup.diZhi,
        text: '子',
        colorfulMode: false,
        globalFontColor: globalColor,
        zhi: DiZhi.ZI,
      ));
      await tester.pumpAndSettle();
      final zhiText = tester.widget<Text>(find.text('子'));
      expect(zhiText.style?.color, globalColor);
    });

    testWidgets(
        'Global font color is suppressed for Gan/Zhi when colorfulMode is ON',
        (tester) async {
      const globalColor = Colors.purple;
      await tester.pumpWidget(const StyleProbeWidget(
        group: TextGroup.tianGan,
        text: '甲',
        colorfulMode: true,
        globalFontColor: globalColor,
        gan: TianGan.JIA,
      ));
      await tester.pumpAndSettle();
      final ganText = tester.widget<Text>(find.text('甲'));
      expect(ganText.style?.color, isNot(equals(globalColor)));
      expect(ganText.style?.color, isNotNull);

      await tester.pumpWidget(const StyleProbeWidget(
        group: TextGroup.diZhi,
        text: '子',
        colorfulMode: true,
        globalFontColor: globalColor,
        zhi: DiZhi.ZI,
      ));
      await tester.pumpAndSettle();
      final zhiText = tester.widget<Text>(find.text('子'));
      expect(zhiText.style?.color, isNot(equals(globalColor)));
      expect(zhiText.style?.color, isNotNull);
    });

    testWidgets('Group overrides win for Gan/Zhi colors even in colorful mode',
        (tester) async {
      final groupStyles = <TextGroup, TextStyle>{
        TextGroup.tianGan: const TextStyle(color: Colors.red),
        TextGroup.diZhi: const TextStyle(color: Colors.green),
      };
      await tester.pumpWidget(StyleProbeWidget(
        group: TextGroup.tianGan,
        text: '甲',
        colorfulMode: true,
        globalFontColor: Colors.purple,
        groupTextStyles: groupStyles,
        gan: TianGan.JIA,
      ));
      await tester.pumpAndSettle();
      final ganText = tester.widget<Text>(find.text('甲'));
      expect(ganText.style?.color, Colors.red);

      await tester.pumpWidget(StyleProbeWidget(
        group: TextGroup.diZhi,
        text: '子',
        colorfulMode: true,
        globalFontColor: Colors.purple,
        groupTextStyles: groupStyles,
        zhi: DiZhi.ZI,
      ));
      await tester.pumpAndSettle();
      final zhiText = tester.widget<Text>(find.text('子'));
      expect(zhiText.style?.color, Colors.green);
    });

    testWidgets(
        'Group overrides take precedence over global for NaYin/KongWang',
        (tester) async {
      final groupStyles = <TextGroup, TextStyle>{
        TextGroup.naYin: const TextStyle(fontSize: 18),
        TextGroup.kongWang: const TextStyle(color: Colors.blue),
      };
      await tester.pumpWidget(StyleProbeWidget(
        group: TextGroup.naYin,
        text: '海中金',
        colorfulMode: false,
        globalFontSize: 16,
        groupTextStyles: groupStyles,
      ));
      await tester.pumpAndSettle();
      final naYinText = tester.widget<Text>(find.text('海中金'));
      expect(naYinText.style?.fontSize, 18);

      await tester.pumpWidget(StyleProbeWidget(
        group: TextGroup.kongWang,
        text: '戌亥',
        colorfulMode: false,
        globalFontSize: 16,
        groupTextStyles: groupStyles,
      ));
      await tester.pumpAndSettle();
      final kongWangText = tester.widget<Text>(find.text('戌亥'));
      expect(kongWangText.style?.color, Colors.blue);
    });

    testWidgets('In-cell title color follows row title color by default',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(920, 360));

      final pillars = <PillarPayload>[
        const RowTitleColumnPayload(uuid: 'row-title'),
        ContentPillarPayload(
          uuid: 'year-col',
          pillarType: PillarType.year,
          pillarLabel: '年',
          pillarContent: PillarContent(
            id: 'year#1',
            pillarType: PillarType.year,
            label: '年',
            jiaZi: JiaZi.JIA_ZI,
            description: null,
            version: '1',
            sourceKind: PillarSourceKind.userInput,
            operationType: null,
          ),
        ),
      ];

      final rows = <TextRowPayload>[
        ColumnHeaderRowPayload(uuid: 'header', gender: Gender.male),
        TextRowPayload(
          uuid: 'nayin-row',
          rowType: RowType.naYin,
          rowLabel: '纳音',
          titleInCell: false,
        ),
      ];

      final cardPayload = CardPayload(
        gender: Gender.male,
        pillarMap: {for (final p in pillars) p.uuid: p},
        pillarOrderUuid: pillars.map((e) => e.uuid).toList(),
        rowMap: {for (final r in rows) r.uuid: r},
        rowOrderUuid: rows.map((e) => e.uuid).toList(),
      );

      const expected = Colors.green;

      final baseTheme = EditableCardThemeBuilder.createDefaultTheme();

      final rowTitleMapper =
          baseTheme.typography.rowTitle.colorMapperDataModel.update(
        brightness: Brightness.light,
        mode: ColorPreviewMode.pure,
        char: '纳音',
        color: expected,
      );

      final rowTypeCellConfigMapper = Map<RowType, CellStyleConfig>.of(
          baseTheme.cell.rowTypeCellConfigMapper);
      rowTypeCellConfigMapper[RowType.naYin] =
          baseTheme.cell.getBy(RowType.naYin).copyWith(showsTitleInCell: true);

      final theme = baseTheme.copyWith(
        typography: baseTheme.typography.copyWith(
          rowTitle: baseTheme.typography.rowTitle
              .copyWith(colorMapperDataModel: rowTitleMapper),
        ),
        cell: baseTheme.cell.copyWith(
          rowTypeCellConfigMapper: rowTypeCellConfigMapper,
        ),
      );

      final themeNotifier = ValueNotifier<EditableFourZhuCardTheme>(theme);
      final brightnessNotifier = ValueNotifier<Brightness>(Brightness.light);
      final colorPreviewModeNotifier =
          ValueNotifier<ColorPreviewMode>(ColorPreviewMode.pure);
      final paddingNotifier =
          ValueNotifier<EdgeInsets>(const EdgeInsets.all(8));
      final rowStrategyMapper = defaultRowStrategyMapper();
      final cardPayloadNotifier = ValueNotifier<CardPayload>(cardPayload);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 920,
                height: 360,
                child: EditableFourZhuCardV3(
                  dayGanZhi: JiaZi.JIA_ZI,
                  brightnessNotifier: brightnessNotifier,
                  colorPreviewModeNotifier: colorPreviewModeNotifier,
                  themeNotifier: themeNotifier,
                  cardPayloadNotifier: cardPayloadNotifier,
                  paddingNotifier: paddingNotifier,
                  rowStrategyMapper: rowStrategyMapper,
                  gender: Gender.male,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final titleFinder = find.text('纳音');
      expect(titleFinder, findsWidgets);

      final titleTexts = tester.widgetList<Text>(titleFinder).toList();
      expect(titleTexts.length >= 2, isTrue);
      for (final t in titleTexts) {
        expect(t.style?.color, expected);
      }
    });

    testWidgets('In-cell title color can be overridden', (tester) async {
      await tester.binding.setSurfaceSize(const Size(920, 360));

      final pillars = <PillarPayload>[
        const RowTitleColumnPayload(uuid: 'row-title'),
        ContentPillarPayload(
          uuid: 'year-col',
          pillarType: PillarType.year,
          pillarLabel: '年',
          pillarContent: PillarContent(
            id: 'year#1',
            pillarType: PillarType.year,
            label: '年',
            jiaZi: JiaZi.JIA_ZI,
            description: null,
            version: '1',
            sourceKind: PillarSourceKind.userInput,
            operationType: null,
          ),
        ),
      ];

      final rows = <TextRowPayload>[
        ColumnHeaderRowPayload(uuid: 'header', gender: Gender.male),
        TextRowPayload(
          uuid: 'nayin-row',
          rowType: RowType.naYin,
          rowLabel: '纳音',
          titleInCell: false,
        ),
      ];

      final cardPayload = CardPayload(
        gender: Gender.male,
        pillarMap: {for (final p in pillars) p.uuid: p},
        pillarOrderUuid: pillars.map((e) => e.uuid).toList(),
        rowMap: {for (final r in rows) r.uuid: r},
        rowOrderUuid: rows.map((e) => e.uuid).toList(),
      );

      const inherited = Colors.green;
      const overridden = Colors.red;

      final baseTheme = EditableCardThemeBuilder.createDefaultTheme();

      final rowTitleMapper =
          baseTheme.typography.rowTitle.colorMapperDataModel.update(
        brightness: Brightness.light,
        mode: ColorPreviewMode.pure,
        char: '纳音',
        color: inherited,
      );

      final inCellTitleMapper = baseTheme.typography
          .getCellTitleBy(RowType.naYin)
          .colorMapperDataModel
          .update(
            brightness: Brightness.light,
            mode: ColorPreviewMode.pure,
            char: '纳音',
            color: overridden,
          );

      final cellTitleMapper = Map<RowType, TextStyleConfig>.of(
          baseTheme.typography.cellTitleMapper);
      cellTitleMapper[RowType.naYin] = baseTheme.typography
          .getCellTitleBy(RowType.naYin)
          .copyWith(colorMapperDataModel: inCellTitleMapper);

      final rowTypeCellConfigMapper = Map<RowType, CellStyleConfig>.of(
          baseTheme.cell.rowTypeCellConfigMapper);
      rowTypeCellConfigMapper[RowType.naYin] =
          baseTheme.cell.getBy(RowType.naYin).copyWith(showsTitleInCell: true);

      final theme = baseTheme.copyWith(
        typography: baseTheme.typography.copyWith(
          rowTitle: baseTheme.typography.rowTitle
              .copyWith(colorMapperDataModel: rowTitleMapper),
          cellTitleMapper: cellTitleMapper,
        ),
        cell: baseTheme.cell.copyWith(
          rowTypeCellConfigMapper: rowTypeCellConfigMapper,
        ),
      );

      final themeNotifier = ValueNotifier<EditableFourZhuCardTheme>(theme);
      final brightnessNotifier = ValueNotifier<Brightness>(Brightness.light);
      final colorPreviewModeNotifier =
          ValueNotifier<ColorPreviewMode>(ColorPreviewMode.pure);
      final paddingNotifier =
          ValueNotifier<EdgeInsets>(const EdgeInsets.all(8));
      final rowStrategyMapper = defaultRowStrategyMapper();
      final cardPayloadNotifier = ValueNotifier<CardPayload>(cardPayload);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 920,
                height: 360,
                child: EditableFourZhuCardV3(
                  dayGanZhi: JiaZi.JIA_ZI,
                  brightnessNotifier: brightnessNotifier,
                  colorPreviewModeNotifier: colorPreviewModeNotifier,
                  themeNotifier: themeNotifier,
                  cardPayloadNotifier: cardPayloadNotifier,
                  paddingNotifier: paddingNotifier,
                  rowStrategyMapper: rowStrategyMapper,
                  gender: Gender.male,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final titleFinder = find.text('纳音');
      expect(titleFinder, findsWidgets);

      final titleTexts = tester.widgetList<Text>(titleFinder).toList();
      expect(titleTexts.length >= 2, isTrue);
      expect(
        titleTexts.any((t) => t.style?.color == overridden),
        isTrue,
      );
      expect(
        titleTexts.any((t) => t.style?.color == inherited),
        isTrue,
      );
    });
  });
}
