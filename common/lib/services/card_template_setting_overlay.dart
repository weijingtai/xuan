import '../enums/layout_template_enums.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/models/cell_style_config.dart';
import '../models/card_template_setting.dart';
import '../models/text_style_config.dart';
import '../themes/editable_four_zhu_card_theme.dart';

class CardTemplateSettingOverlay {
  static EditableFourZhuCardTheme applyToTheme({
    required EditableFourZhuCardTheme baseTheme,
    required CardTemplateSetting setting,
    int? skillId,
  }) {
    final effective = _effectiveOverride(setting, skillId: skillId);

    var nextTheme = baseTheme;

    final showTitleColumn = effective.showTitleColumn;
    if (showTitleColumn != null &&
        showTitleColumn != nextTheme.displayRowTitleColumn) {
      nextTheme = nextTheme.copyWith(displayRowTitleColumn: showTitleColumn);
    }

    final showInCellGlobal = effective.showInCellTitleGlobal;
    final showInCellByRowType = effective.showInCellTitleByRowType;

    if (showInCellGlobal != null || showInCellByRowType != null) {
      final cell = nextTheme.cell;
      var nextCell = cell;

      if (showInCellGlobal != null &&
          showInCellGlobal != cell.globalCellConfig.showsTitleInCell) {
        nextCell = nextCell.copyWith(
          globalCellConfig:
              cell.globalCellConfig.copyWith(showsTitleInCell: showInCellGlobal),
        );
      }

      if (showInCellByRowType != null && showInCellByRowType.isNotEmpty) {
        final mapper = Map<RowType, CellStyleConfig>.of(
          nextCell.rowTypeCellConfigMapper,
        );
        showInCellByRowType.forEach((rt, v) {
          if (rt == RowType.columnHeaderRow || rt == RowType.separator) return;
          final baseCfg = mapper[rt] ?? nextCell.globalCellConfig;
          if (baseCfg.showsTitleInCell == v) return;
          mapper[rt] = baseCfg.copyWith(showsTitleInCell: v);
        });
        nextCell = nextCell.copyWith(rowTypeCellConfigMapper: mapper);
      }

      if (nextCell != cell) {
        nextTheme = nextTheme.copyWith(cell: nextCell);
      }
    }

    return nextTheme;
  }

  static ColorPreviewMode? effectiveColorMode({
    required CardTemplateSetting setting,
    int? skillId,
  }) {
    return _effectiveOverride(setting, skillId: skillId).activeColorMode;
  }

  static CardTemplateSettingOverride _effectiveOverride(
    CardTemplateSetting setting, {
    int? skillId,
  }) {
    final global = CardTemplateSettingOverride(
      showTitleColumn: setting.showTitleColumn,
      showInCellTitleGlobal: setting.showInCellTitleGlobal,
      showInCellTitleByRowType: setting.showInCellTitleByRowType,
      activeColorMode: setting.activeColorMode,
    );

    if (skillId == null) return global;

    final skillOverride = setting.overridesBySkillId?[skillId];
    if (skillOverride == null) return global;

    return CardTemplateSettingOverride(
      showTitleColumn: skillOverride.showTitleColumn ?? global.showTitleColumn,
      showInCellTitleGlobal:
          skillOverride.showInCellTitleGlobal ?? global.showInCellTitleGlobal,
      showInCellTitleByRowType: skillOverride.showInCellTitleByRowType ??
          global.showInCellTitleByRowType,
      activeColorMode: skillOverride.activeColorMode ?? global.activeColorMode,
    );
  }
}

