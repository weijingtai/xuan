import 'package:common/commands/editor_command.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/models/text_style_config.dart';
import 'package:common/themes/editable_four_zhu_card_theme.dart';
import 'package:flutter/widgets.dart';

/// Command to update the card theme (styles).
///
/// This command maps runtime [EditableFourZhuCardTheme] changes back to the
/// persistent [LayoutTemplate] model. It handles:
/// - Card Style (padding, global font settings)
/// - Row Configs (text styles for each row type)
class UpdateThemeCommand extends EditorCommand {
  final EditableFourZhuCardTheme newTheme;

  CardStyle? _oldCardStyle;
  List<RowConfig>? _oldRowConfigs;
  Map<String, dynamic>? _oldEditableTheme;
  bool _hasCapturedEditableTheme = false;

  UpdateThemeCommand(this.newTheme);

  @override
  String get description => '更新主题';

  @override
  bool canMergeWith(EditorCommand other) {
    // Merge consecutive theme updates (e.g. from sliders or color pickers)
    return other is UpdateThemeCommand;
  }

  @override
  EditorCommand mergeWith(EditorCommand other) {
    if (other is UpdateThemeCommand) {
      final merged = UpdateThemeCommand(other.newTheme);
      merged._oldCardStyle = _oldCardStyle;
      merged._oldRowConfigs = _oldRowConfigs;
      merged._oldEditableTheme = _oldEditableTheme;
      merged._hasCapturedEditableTheme = _hasCapturedEditableTheme;
      return merged;
    }
    return this;
  }

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    if (_oldCardStyle == null) {
      _oldCardStyle = currentTemplate.cardStyle;
    }
    if (_oldRowConfigs == null) {
      _oldRowConfigs = currentTemplate.rowConfigs;
    }
    if (!_hasCapturedEditableTheme) {
      _oldEditableTheme = currentTemplate.editableTheme;
      _hasCapturedEditableTheme = true;
    }

    // 1. Update CardStyle (Padding & Global Font)
    var nextCardStyle = currentTemplate.cardStyle;

    // Sync Padding
    if (nextCardStyle.contentPadding != newTheme.card.padding) {
      nextCardStyle =
          nextCardStyle.copyWith(contentPadding: newTheme.card.padding);
    }

    // Sync Global Font
    final globalFont = newTheme.typography.globalContent.fontStyleDataModel;
    // Note: We only sync if they differ, to avoid unnecessary updates.
    // We assume the theme's global font reflects what should be in the template.
    if (nextCardStyle.globalFontFamily != globalFont.fontFamily ||
        nextCardStyle.globalFontSize != globalFont.fontSize) {
      nextCardStyle = nextCardStyle.copyWith(
        globalFontFamily: globalFont.fontFamily,
        globalFontSize: globalFont.fontSize,
      );
    }

    // Sync Global Font Color (if applicable)
    final globalColor =
        newTheme.typography.globalContent.colorMapperDataModel.defaultColor;
    if (globalColor != null) {
      // Convert Color to Hex string (#AARRGGBB)
      final hex =
          '#${globalColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
      if (nextCardStyle.globalFontColorHex != hex) {
        nextCardStyle = nextCardStyle.copyWith(globalFontColorHex: hex);
      }
    }

    // Sync Divider Styles (Border)
    final border = newTheme.card.border;
    if (border != null) {
      if (nextCardStyle.dividerThickness != border.width) {
        nextCardStyle = nextCardStyle.copyWith(dividerThickness: border.width);
      }

      // Map lightColor to dividerColorHex for persistence
      final colorHex =
          '#${border.lightColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
      if (nextCardStyle.dividerColorHex != colorHex) {
        nextCardStyle = nextCardStyle.copyWith(dividerColorHex: colorHex);
      }

      // Map enabled to dividerType (simple mapping)
      // If enabled is false, use none. If true, use solid (as BoxBorderStyle doesn't have type yet)
      final expectedType = border.enabled ? BorderType.solid : BorderType.none;
      if (nextCardStyle.dividerType != expectedType) {
        nextCardStyle = nextCardStyle.copyWith(dividerType: expectedType);
      }
    }

    // 2. Update RowConfigs
    final mapper = newTheme.typography.cellContentMapper;
    final nextRowConfigs = <RowConfig>[];
    bool rowsChanged = false;

    for (final row in currentTemplate.rowConfigs) {
      final newStyle = mapper[row.type];
      if (newStyle != null && newStyle != row.textStyleConfig) {
        nextRowConfigs.add(row.copyWith(textStyleConfig: newStyle));
        rowsChanged = true;
      } else {
        nextRowConfigs.add(row);
      }
    }

    return currentTemplate.copyWith(
      cardStyle: nextCardStyle,
      rowConfigs: rowsChanged ? nextRowConfigs : null,
      editableTheme: newTheme.toJson(),
    );
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(
      cardStyle: _oldCardStyle ?? currentTemplate.cardStyle,
      rowConfigs: _oldRowConfigs ?? currentTemplate.rowConfigs,
      editableTheme:
          _hasCapturedEditableTheme ? _oldEditableTheme : currentTemplate.editableTheme,
    );
  }
}
