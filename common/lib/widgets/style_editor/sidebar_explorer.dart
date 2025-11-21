import 'package:common/models/pillar_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/editable_four_zhu_card_theme.dart';
import '../../viewmodels/four_zhu_card_demo_viewmodel.dart';
import 'editable_four_zhu_style_editor_panel.dart';
import 'row_style_editor_panel.dart';
import 'cell_style_editor_panel.dart';
import 'four_zhu_pillar_style_editor.dart';
import 'widgets/sidebar_pillar_editor_section.dart';

class SidebarExplorer extends StatelessWidget {
  const SidebarExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final demoVm = Provider.of<FourZhuCardDemoViewModel>(context, listen: true);
    return SingleChildScrollView(
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
              valueListenable:
                  Provider.of<FourZhuCardDemoViewModel>(context, listen: false)
                      .themeNotifier,
              builder: (context, theme, child) => SidebarPillarEditorSection(
                  pillarSection: theme.pillar,
                  title: '柱样式',
                  icon: Icons.view_column,
                  onChanged: (config) {
                    Provider.of<FourZhuCardDemoViewModel>(context,
                            listen: false)
                        .updateEditableFourZhuCardTheme(
                            theme.copyWith(pillar: config));
                  }),
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
