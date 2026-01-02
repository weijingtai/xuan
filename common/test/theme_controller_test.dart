import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:common/viewmodels/editable_four_zhu_theme_controller.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/text_style_config.dart';
import 'package:common/widgets/editable_fourzhu_card/models/pillar_style_config.dart';

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
      final baseTheme = EditableCardThemeBuilder.createDefaultTheme();
      final typography = baseTheme.typography.copyWith(
        globalContent: baseTheme.typography.globalContent.copyWith(
          fontStyleDataModel:
              baseTheme.typography.globalContent.fontStyleDataModel.copyWith(
            fontFamily: 'ThemeFamily',
            fontSize: 16,
          ),
        ),
      );

      final theme = baseTheme.copyWith(typography: typography);
      final controller = EditableFourZhuThemeController(theme);

      // 行配置提供局部字体，应优先生效
      final row = RowConfig(
          type: RowType.heavenlyStem,
          isVisible: true,
          isTitleVisible: true,
          textStyleConfig: typography.globalContent.copyWith(
            fontStyleDataModel: typography.globalContent.fontStyleDataModel
                .copyWith(fontFamily: 'RowFamily'),
          ));
      final (family, size, colorHex) = controller.resolveRowText(row);
      expect(family, 'RowFamily');
      expect(size, 16);
      expect(colorHex, isNull); // 未设置颜色时返回 null
    });

    test('Theme family used when row family is null', () {
      final baseTheme = EditableCardThemeBuilder.createDefaultTheme();
      final theme = baseTheme.copyWith(
        typography: baseTheme.typography.copyWith(
          globalContent: baseTheme.typography.globalContent.copyWith(
            fontStyleDataModel:
                baseTheme.typography.globalContent.fontStyleDataModel.copyWith(
              fontFamily: 'ThemeFamily',
              fontSize: 14,
            ),
          ),
        ),
      );
      final controller = EditableFourZhuThemeController(theme);

      final (family, size, colorHex) = controller.resolveRowText(null);
      expect(family, 'ThemeFamily');
      expect(size, 14);
      expect(colorHex, isNull);
    });

    test('Base family used when theme family is empty', () {
      final baseTheme = EditableCardThemeBuilder.createDefaultTheme();
      final theme = baseTheme.copyWith(
        typography: baseTheme.typography.copyWith(
          globalContent: baseTheme.typography.globalContent.copyWith(
            fontStyleDataModel:
                baseTheme.typography.globalContent.fontStyleDataModel.copyWith(
              fontFamily: '',
              fontSize: 12,
            ),
          ),
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
      expect(resolved.globalFontFamily, 'BaseFamily');
      expect(resolved.globalFontSize, 12);
    });

    test('Global color resolves to #AARRGGBB', () {
      final baseTheme = EditableCardThemeBuilder.createDefaultTheme();
      final oldMapper = baseTheme.typography.globalContent.colorMapperDataModel;
      final theme = baseTheme.copyWith(
        typography: baseTheme.typography.copyWith(
          globalContent: baseTheme.typography.globalContent.copyWith(
            colorMapperDataModel: ColorMapperDataModel(
              pureLightMapper: oldMapper.pureLightMapper,
              colorfulLightMapper: oldMapper.colorfulLightMapper,
              pureDarkMapper: oldMapper.pureDarkMapper,
              colorfulDarkMapper: oldMapper.colorfulDarkMapper,
              defaultColor: const Color(0xFF112233),
              blackwhiteLightStrength: oldMapper.blackwhiteLightStrength,
              blackwhiteDarkStrength: oldMapper.blackwhiteDarkStrength,
            ),
          ),
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
    test('ensureValidOrThrow throws on negative cell border width', () {
      final baseTheme = EditableCardThemeBuilder.createDefaultTheme();
      final cell = baseTheme.cell.copyWith(
        globalCellConfig: baseTheme.cell.globalCellConfig.copyWith(
          border: baseTheme.cell.globalCellConfig.border
              ?.copyWith(width: -1, enabled: true),
        ),
      );
      final theme = baseTheme.copyWith(cell: cell);
      expect(() => EditableFourZhuThemeController(theme), throwsArgumentError);
    });

    test('ensureValidOrThrow passes on non-negative values', () {
      final baseTheme = EditableCardThemeBuilder.createDefaultTheme();
      final theme = baseTheme.copyWith(
        cell: baseTheme.cell.copyWith(
          globalCellConfig: baseTheme.cell.globalCellConfig.copyWith(
            border: baseTheme.cell.globalCellConfig.border
                ?.copyWith(width: 1, enabled: true),
          ),
        ),
      );
      expect(() => EditableFourZhuThemeController(theme), returnsNormally);
    });
  });

  group('EditableFourZhuThemeController - pillar margin resolution', () {
    test('resolvePillarMargin returns specific first then default', () {
      final baseTheme = EditableCardThemeBuilder.createDefaultTheme();
      final global = PillarStyleConfig.defaultPillarStyleConfig.copyWith(
        margin: const EdgeInsets.all(8),
      );
      final year = PillarStyleConfig.defaultPillarStyleConfig.copyWith(
        margin: const EdgeInsets.only(left: 12),
      );
      final pillar = PillarSection(
        global: global,
        mapper: {PillarType.year: year},
        defaultSeparatorConfig: baseTheme.pillar.defaultSeparatorConfig,
      );
      final theme = baseTheme.copyWith(pillar: pillar);
      final controller = EditableFourZhuThemeController(theme);
      final yearMargin = controller.resolvePillarMargin(PillarType.year);
      final month = controller.resolvePillarMargin(PillarType.month);
      expect(yearMargin, const EdgeInsets.only(left: 12));
      expect(month, const EdgeInsets.all(8));
    });
  });
}
