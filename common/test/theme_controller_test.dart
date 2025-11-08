import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:common/viewmodels/editable_four_zhu_theme_controller.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/enums/layout_template_enums.dart';

/// 主题控制器单元测试：验证字体回退顺序与参数非负校验
///
/// 覆盖点：
/// - 字体回退顺序：行局部 → 主题默认 → 偏好列表 → 系统默认
/// - 颜色十六进制格式转换（#AARRGGBB）
/// - ensureValidOrThrow 非负约束（边距/半径/宽度等）
/// - 柱外边距差异化解析
void main() {
  group('EditableFourZhuThemeController - font fallback', () {
    test('Row family overrides theme family', () {
      // 构造主题：提供主题默认字体与偏好列表
      final theme = EditableFourZhuCardTheme(
        typography: const TypographySection(
          globalFontFamily: 'ThemeFamily',
          globalFontSize: 16,
          preferredFamilies: ['PreferredA', 'PreferredB'],
        ),
      );
      final controller = EditableFourZhuThemeController(theme);

      // 行配置提供局部字体，应优先生效
      final row = const RowConfig(
        type: RowType.heavenlyStem,
        isVisible: true,
        isTitleVisible: true,
        fontFamily: 'RowFamily',
      );
      final (family, size, colorHex) = controller.resolveRowText(row);
      expect(family, 'RowFamily');
      expect(size, 16);
      expect(colorHex, isNull); // 未设置颜色时返回 null
    });

    test('Theme family used when row family is null', () {
      final theme = EditableFourZhuCardTheme(
        typography: const TypographySection(
          globalFontFamily: 'ThemeFamily',
          globalFontSize: 14,
          preferredFamilies: ['PreferredA', 'PreferredB'],
        ),
      );
      final controller = EditableFourZhuThemeController(theme);

      final (family, size, colorHex) = controller.resolveRowText(null);
      expect(family, 'ThemeFamily');
      expect(size, 14);
      expect(colorHex, isNull);
    });

    test('Preferred list used when theme family is null', () {
      final theme = EditableFourZhuCardTheme(
        typography: const TypographySection(
          globalFontFamily: null,
          globalFontSize: 12,
          preferredFamilies: ['PreferredA', 'PreferredB'],
        ),
      );
      final controller = EditableFourZhuThemeController(theme);

      final base = const CardStyle(
        dividerType: BorderType.solid,
        dividerColorHex: '#FF000000',
        dividerThickness: 1,
        globalFontFamily: 'BaseFamily',
        globalFontSize: 10,
        globalFontColorHex: '#FF111111',
      );
      final resolved = controller.resolveCardStyle(base);
      expect(resolved.globalFontFamily, 'PreferredA');
      expect(resolved.globalFontSize, 12);
    });

    test('Global color resolves to #AARRGGBB', () {
      final theme = EditableFourZhuCardTheme(
        typography: const TypographySection(
          globalFontColor: Color(0xFF112233),
        ),
      );
      final controller = EditableFourZhuThemeController(theme);

      final base = const CardStyle(
        dividerType: BorderType.solid,
        dividerColorHex: '#FF000000',
        dividerThickness: 1,
        globalFontFamily: 'BaseFamily',
        globalFontSize: 10,
        globalFontColorHex: '#FF111111',
      );
      final resolved = controller.resolveCardStyle(base);
      expect(resolved.globalFontColorHex, '#FF112233');
    });
  });

  group('EditableFourZhuCardTheme - non-negative validation', () {
    test('ensureValidOrThrow throws on negative card borderWidth', () {
      final theme = EditableFourZhuCardTheme(
        card: const CardSection(borderWidth: -1),
      );
      expect(() => EditableFourZhuThemeController(theme), throwsArgumentError);
    });

    test('ensureValidOrThrow passes on non-negative values', () {
      final theme = EditableFourZhuCardTheme(
        card: const CardSection(
          borderWidth: 1,
          elevation: 2,
          cornerRadius: 8,
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        ),
        pillar: const PillarSection(
          defaultMargin: const EdgeInsets.all(2),
          defaultPadding: const EdgeInsets.all(1),
          borderWidth: 0,
          cornerRadius: 0,
          perPillarMargin: const {
            PillarType.year: EdgeInsets.only(left: 10),
          },
        ),
      );

      expect(() => EditableFourZhuThemeController(theme), returnsNormally);
    });
  });

  group('EditableFourZhuThemeController - pillar margin resolution', () {
    test('resolvePillarMargin returns specific first then default', () {
      final theme = EditableFourZhuCardTheme(
        pillar: const PillarSection(
          defaultMargin: const EdgeInsets.all(8),
          perPillarMargin: const {
            PillarType.year: EdgeInsets.only(left: 12),
          },
        ),
      );
      final controller = EditableFourZhuThemeController(theme);
      final year = controller.resolvePillarMargin(PillarType.year);
      final month = controller.resolvePillarMargin(PillarType.month);
      expect(year, const EdgeInsets.only(left: 12));
      expect(month, const EdgeInsets.all(8));
    });
  });
}
