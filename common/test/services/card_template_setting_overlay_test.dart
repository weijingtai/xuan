import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/card_template_setting.dart';
import 'package:common/models/text_style_config.dart';
import 'package:common/services/card_template_setting_overlay.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('applyToTheme applies global switches and row overrides', () async {
    final base = EditableCardThemeBuilder.createDefaultTheme();

    final now = DateTime.utc(2026, 1, 8, 0, 0, 0);
    final setting = CardTemplateSetting(
      createdAt: now,
      modifiedAt: now,
      deletedAt: null,
      templateUuid: 't1',
      showTitleColumn: false,
      showInCellTitleGlobal: true,
      showInCellTitleByRowType: const {
        RowType.tenGod: false,
        RowType.naYin: true,
      },
      activeColorMode: ColorPreviewMode.blackwhite,
    );

    final themed = CardTemplateSettingOverlay.applyToTheme(
      baseTheme: base,
      setting: setting,
    );

    expect(themed.displayRowTitleColumn, isFalse);
    expect(themed.cell.globalCellConfig.showsTitleInCell, isTrue);
    expect(themed.cell.getBy(RowType.tenGod).showsTitleInCell, isFalse);
    expect(themed.cell.getBy(RowType.naYin).showsTitleInCell, isTrue);

    final mode = CardTemplateSettingOverlay.effectiveColorMode(setting: setting);
    expect(mode, equals(ColorPreviewMode.blackwhite));
  });

  test('skill override wins over global', () async {
    final base = EditableCardThemeBuilder.createDefaultTheme();
    final now = DateTime.utc(2026, 1, 8, 0, 0, 0);

    final setting = CardTemplateSetting(
      createdAt: now,
      modifiedAt: now,
      deletedAt: null,
      templateUuid: 't1',
      showTitleColumn: false,
      showInCellTitleGlobal: false,
      activeColorMode: ColorPreviewMode.pure,
      overridesBySkillId: const {
        7: CardTemplateSettingOverride(
          showTitleColumn: true,
          showInCellTitleGlobal: true,
          activeColorMode: ColorPreviewMode.colorful,
        ),
      },
    );

    final themed = CardTemplateSettingOverlay.applyToTheme(
      baseTheme: base,
      setting: setting,
      skillId: 7,
    );

    expect(themed.displayRowTitleColumn, isTrue);
    expect(themed.cell.globalCellConfig.showsTitleInCell, isTrue);

    final mode = CardTemplateSettingOverlay.effectiveColorMode(
      setting: setting,
      skillId: 7,
    );
    expect(mode, equals(ColorPreviewMode.colorful));
  });
}

