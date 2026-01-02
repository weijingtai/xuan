import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:common/utils/style_resolver.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/models/text_style_config.dart';
import 'package:common/enums/layout_template_enums.dart';

/// Tests for DefaultStyleResolver and DefaultLayoutMetricsResolver
/// Focus: Text style priority and row height precedence.
void main() {
  group('DefaultStyleResolver.resolveTextStyle priority', () {
    testWidgets(
        'Override params beat TextStyleConfig, old fields, and cardStyle',
        (tester) async {
      final resolver = const DefaultStyleResolver();
      final card = const CardStyle(
        dividerType: BorderType.solid,
        dividerColorHex: '#FFFFFFFF',
        dividerThickness: 1.0,
        globalFontFamily: 'GlobalFam',
        globalFontSize: 12.0,
        globalFontColorHex: '#000000',
      );

      final row = RowConfig(
        type: RowType.heavenlyStem,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig(
          colorMapperDataModel: ColorMapperDataModel(
            pureLightMapper: const {},
            colorfulLightMapper: const {},
            pureDarkMapper: const {},
            colorfulDarkMapper: const {},
          ),
          textShadowDataModel: TextShadowDataModel(),
          fontStyleDataModel: FontStyleDataModel(
            fontFamily: 'Foo',
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      );

      late TextStyle resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = resolver.resolveTextStyle(
                context: context,
                rowType: RowType.heavenlyStem,
                cardStyle: card,
                rowConfig: row,
                overrideColor: Colors.red,
                fontWeight: FontWeight.w800,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.fontFamily, 'Foo');
      expect(resolved.fontSize, 18.0);
      expect(resolved.color, Colors.red);
      expect(resolved.fontWeight, FontWeight.w800);
    });

    testWidgets('Row config beats cardStyle when provided', (tester) async {
      final resolver = const DefaultStyleResolver();
      final card = const CardStyle(
        dividerType: BorderType.solid,
        dividerColorHex: '#FFFFFFFF',
        dividerThickness: 1.0,
        globalFontFamily: 'GlobalFam',
        globalFontSize: 10.0,
        globalFontColorHex: '#111111',
      );

      final row = RowConfig(
        type: RowType.earthlyBranch,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig(
          colorMapperDataModel: ColorMapperDataModel(
            pureLightMapper: const {},
            colorfulLightMapper: const {},
            pureDarkMapper: const {},
            colorfulDarkMapper: const {},
          ),
          textShadowDataModel: TextShadowDataModel(),
          fontStyleDataModel: FontStyleDataModel(
            fontFamily: 'RowFam',
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
      );

      late TextStyle resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = resolver.resolveTextStyle(
                context: context,
                rowType: RowType.earthlyBranch,
                cardStyle: card,
                rowConfig: row,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.fontFamily, 'RowFam');
      expect(resolved.fontSize, 16.0);
      expect(resolved.color, const Color(0xFF111111));
      expect(resolved.fontWeight, FontWeight.w400);
    });

    testWidgets('Fallback to cardStyle and theme when rowConfig is null',
        (tester) async {
      final resolver = const DefaultStyleResolver();
      final card = const CardStyle(
        dividerType: BorderType.solid,
        dividerColorHex: '#FFFFFFFF',
        dividerThickness: 1.0,
        globalFontFamily: 'GlobalFam',
        globalFontSize: 15.0,
        globalFontColorHex: '#101010',
      );

      late TextStyle resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(
              bodyMedium: TextStyle(fontSize: 13.0, color: Colors.blueGrey),
            ),
          ),
          home: Builder(
            builder: (context) {
              resolved = resolver.resolveTextStyle(
                context: context,
                rowType: RowType.naYin,
                cardStyle: card,
                rowConfig: null,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.fontFamily, 'GlobalFam');
      expect(resolved.fontSize, 15.0);
      expect(resolved.color, const Color(0xFF101010));
      expect(resolved.fontWeight, FontWeight.w400);
    });
  });

  group('DefaultLayoutMetricsResolver.rowHeight precedence', () {
    testWidgets('Uses TextStyleConfig.fontSize over legacy fontSize',
        (tester) async {
      final metrics = const DefaultLayoutMetricsResolver();
      final row = RowConfig(
        type: RowType.heavenlyStem,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig(
          colorMapperDataModel: ColorMapperDataModel(
            pureLightMapper: const {},
            colorfulLightMapper: const {},
            pureDarkMapper: const {},
            colorfulDarkMapper: const {},
          ),
          textShadowDataModel: TextShadowDataModel(),
          fontStyleDataModel: FontStyleDataModel(
            fontFamily: 'Foo',
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
      );

      late double h;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              h = metrics.rowHeight(context, rowConfig: row, cardStyle: null);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // 18 * 2 = 36, clamp upper bound 36
      expect(h, 36.0);
    });

    testWidgets('Uses TextStyleConfig.fontSize when configured',
        (tester) async {
      final metrics = const DefaultLayoutMetricsResolver();
      final row = RowConfig(
        type: RowType.earthlyBranch,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig(
          colorMapperDataModel: ColorMapperDataModel(
            pureLightMapper: const {},
            colorfulLightMapper: const {},
            pureDarkMapper: const {},
            colorfulDarkMapper: const {},
          ),
          textShadowDataModel: TextShadowDataModel(),
          fontStyleDataModel: FontStyleDataModel(
            fontFamily: 'Foo',
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
      );

      late double h;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              h = metrics.rowHeight(context, rowConfig: row, cardStyle: null);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // 12 * 2 = 24, clamp lower bound 24
      expect(h, 24.0);
    });

    testWidgets(
        'Falls back to cardStyle and theme bodyMedium when row config is empty',
        (tester) async {
      final metrics = const DefaultLayoutMetricsResolver();
      final card = const CardStyle(
        dividerType: BorderType.solid,
        dividerColorHex: '#FFFFFFFF',
        dividerThickness: 1.0,
        globalFontFamily: 'GlobalFam',
        globalFontSize: 15.0,
        globalFontColorHex: '#101010',
      );

      late double hCard;
      late double hTheme;

      // With cardStyle globalFontSize = 15 => 30
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              hCard =
                  metrics.rowHeight(context, rowConfig: null, cardStyle: card);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(hCard, 30.0);

      // When cardStyle is null, fallback to theme: bodyMedium.fontSize = 20 => clamp to 36
      await tester.pumpWidget(
        Theme(
          data: ThemeData(
            textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 20.0)),
          ),
          child: Builder(
            builder: (context) {
              hTheme =
                  metrics.rowHeight(context, rowConfig: null, cardStyle: null);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(hTheme, 36.0);
    });
  });
}
