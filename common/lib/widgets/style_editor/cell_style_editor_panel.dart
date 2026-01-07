import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/four_zhu_card/widgets/editable_fourzhu_card/models/base_style_config.dart';
import '../../themes/editable_four_zhu_card_theme.dart';
import '../../viewmodels/four_zhu_editor_view_model.dart';
import '../../models/drag_payloads.dart';
import '../../enums/layout_template_enums.dart';
import '../editable_fourzhu_card/models/cell_style_config.dart';
import 'widgets/box_style_config_editor.dart';
import 'widgets/box_border_style_editor.dart';
import 'widgets/box_shadow_style_editor.dart';

class CellStyleEditorPanel extends StatelessWidget {
  const CellStyleEditorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final editorVm = context.read<FourZhuEditorViewModel>();
    return ValueListenableBuilder<CardPayload>(
      valueListenable: editorVm.cardPayloadNotifier,
      builder: (context, payload, _) {
        return ValueListenableBuilder<EditableFourZhuCardTheme>(
          valueListenable: editorVm.editableThemeNotifier,
          builder: (context, theme, __) {
            final cell = theme.cell;
            final activeRowTypes = payload.rowOrderUuid
                .map((id) => payload.rowMap[id])
                .whereType<TextRowPayload>()
                .map((r) => r.rowType)
                .where((t) => t != RowType.separator)
                .toList();

            final List<Widget> items = [];

            items.add(_eachEditor(context, '全局', cell.globalCellConfig, (cfg) {
              editorVm.updateEditableFourZhuCardTheme(
                theme.copyWith(cell: cell.copyWith(globalCellConfig: cfg)),
              );
            }));

            items.add(_eachEditor(context, '列标题单元格', cell.pillarTitleCellConfig,
                (cfg) {
              editorVm.updateEditableFourZhuCardTheme(
                theme.copyWith(cell: cell.copyWith(pillarTitleCellConfig: cfg)),
              );
            }));

            items.add(
                _eachEditor(context, '行标题单元格', cell.rowTitleCellConfig, (cfg) {
              editorVm.updateEditableFourZhuCardTheme(
                theme.copyWith(cell: cell.copyWith(rowTitleCellConfig: cfg)),
              );
            }));

            for (final rt in activeRowTypes) {
              final initial = cell.getBy(rt);
              items.add(_eachEditor(context, rt.name, initial, (cfg) {
                final mapper = Map<RowType, CellStyleConfig>.of(
                    cell.rowTypeCellConfigMapper);
                mapper[rt] = cfg;
                editorVm.updateEditableFourZhuCardTheme(
                  theme.copyWith(
                    cell: cell.copyWith(rowTypeCellConfigMapper: mapper),
                  ),
                );
              }));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items
                  .map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: w,
                      ))
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _eachEditor(BuildContext context, String title, CellStyleConfig config,
      ValueChanged<CellStyleConfig> onChanged) {
    final theme = Theme.of(context);
    final cfgNotifier = ValueNotifier<CellStyleConfig>(config);
    cfgNotifier.addListener(() => onChanged(cfgNotifier.value));

    final borderNotifier = ValueNotifier<BoxBorderStyle>(
        config.border ?? BoxBorderStyle.defaultBorder);
    borderNotifier.addListener(() {
      cfgNotifier.value =
          cfgNotifier.value.copyWith(border: borderNotifier.value);
    });

    final shadowNotifier = ValueNotifier<BoxShadowStyle>(config.shadow);
    shadowNotifier.addListener(() {
      cfgNotifier.value =
          cfgNotifier.value.copyWith(shadow: shadowNotifier.value);
    });

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.08),
        ),
      ),
      child: ExpansionTile(
        title: Text(title, style: theme.textTheme.titleMedium),
        childrenPadding: const EdgeInsets.all(12),
        children: [
          BoxStyleConfigEditor(boxStyleConfigNotifier: cfgNotifier),
          const SizedBox(height: 8),
          BoxBorderStyleEditor(
            borderNotifier: borderNotifier,
            styleConfigNotifier: cfgNotifier,
          ),
          const SizedBox(height: 8),
          ShadowEditorWidget(
            shadowNotifier: shadowNotifier,
            styleConfigNotifier: cfgNotifier,
          ),
        ],
      ),
    );
  }
}
