import 'package:common/models/pillar_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/editable_four_zhu_card_theme.dart';
import '../../models/text_style_config.dart';
import '../../viewmodels/four_zhu_editor_view_model.dart';
import 'editable_four_zhu_style_editor_panel.dart';
import 'row_style_editor_panel.dart';
import 'cell_style_editor_panel.dart';
import 'widgets/sidebar_pillar_editor_section.dart';

class SidebarExplorer extends StatelessWidget {
  const SidebarExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<FourZhuEditorViewModel>(
          builder: (context, viewModel, _) =>
              _buildPinnedBar(context, viewModel),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _section(
                    context,
                    icon: Icons.style,
                    title: '卡片样式',
                    child: const EditableFourZhuStyleEditorPanel(),
                  ),
                  const SizedBox(height: 12),
                  _section(
                    context,
                    icon: Icons.view_list,
                    title: '行样式',
                    child: const RowStyleEditorPanel(),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder(
                    valueListenable: context
                        .read<FourZhuEditorViewModel>()
                        .editableThemeNotifier,
                    builder: (context, theme, child) =>
                        SidebarPillarEditorSection(
                      pillarSection: theme.pillar,
                      title: '柱样式',
                      icon: Icons.view_column,
                      onChanged: (config) {
                        context
                            .read<FourZhuEditorViewModel>()
                            .updateEditableFourZhuCardTheme(
                              theme.copyWith(pillar: config),
                            );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _section(
                    context,
                    icon: Icons.grid_on,
                    title: '单元格样式',
                    child: const CellStyleEditorPanel(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinnedBar(
      BuildContext context, FourZhuEditorViewModel viewModel) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.12),
            ),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.brightness_6, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '明暗主题',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: viewModel.uiState.isDarkMode,
                  onChanged: viewModel.toggleTheme,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<ColorPreviewMode>(
              valueListenable: viewModel.colorPreviewModeNotifier,
              builder: (context, mode, _) {
                return Row(
                  children: [
                    const Icon(Icons.invert_colors, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '色彩模式',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    ToggleButtons(
                      isSelected: [
                        mode == ColorPreviewMode.pure,
                        mode == ColorPreviewMode.colorful,
                        mode == ColorPreviewMode.blackwhite,
                      ],
                      onPressed: (index) {
                        ColorPreviewMode next = mode;
                        if (index == 0) {
                          next = ColorPreviewMode.pure;
                        } else if (index == 1) {
                          next = ColorPreviewMode.colorful;
                        } else if (index == 2) {
                          next = ColorPreviewMode.blackwhite;
                        }
                        viewModel.colorPreviewModeNotifier.value = next;
                      },
                      constraints: const BoxConstraints(
                        minHeight: 32,
                        minWidth: 52,
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('纯色'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('色彩'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('黑白'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context,
      {required IconData icon, required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title, style: theme.textTheme.titleMedium),
        childrenPadding: const EdgeInsets.all(12),
        children: [child],
      ),
    );
  }
}
