import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/four_zhu_card_demo_viewmodel.dart';
import 'editable_four_zhu_style_editor_panel.dart';
import 'row_style_editor_panel.dart';
import 'cell_style_editor_panel.dart';
import 'four_zhu_pillar_style_editor.dart';

class SidebarExplorer extends StatelessWidget {
  const SidebarExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final demoVm = Provider.of<FourZhuCardDemoViewModel>(context, listen: true);
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
            _pillarSecion(
              context,
              icon: Icons.view_column,
              title: '柱样式',
              child: FourZhuPillarStyleEditor(theme: demoVm.theme),
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

  Widget _pillarSecion(BuildContext context,
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
        children: [child, child],
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
