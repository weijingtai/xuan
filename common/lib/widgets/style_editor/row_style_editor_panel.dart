import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/layout_template.dart';
import '../../models/text_style_config.dart';
import '../../viewmodels/four_zhu_editor_view_model.dart';
import '../../enums/enum_tian_gan.dart';
import '../../enums/enum_di_zhi.dart';
import 'colorful_text_style_editor_widget_v2.dart';

class RowStyleEditorPanel extends StatelessWidget {
  const RowStyleEditorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FourZhuEditorViewModel>(
      builder: (context, vm, _) {
        final rows = vm.rowConfigs;
        if (rows.isEmpty) {
          return const Text('暂无行配置');
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, i) {
            final cfg = rows[i];
            return _RowItem(cfg: cfg, vm: vm);
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: rows.length,
        );
      },
    );
  }
}

class _RowItem extends StatelessWidget {
  final RowConfig cfg;
  final FourZhuEditorViewModel vm;
  const _RowItem({required this.cfg, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cfg.type.name, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('显示该行'),
            value: cfg.isVisible,
            onChanged: (v) => vm.updateRowVisibility(cfg.type, v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('显示标题'),
            value: cfg.isTitleVisible,
            onChanged: (v) => vm.updateRowTitleVisibility(cfg.type, v),
          ),
          Row(
            children: [
              const Expanded(child: Text('内边距 (px)')),
              Text('${cfg.padding?.toStringAsFixed(0) ?? 0}'),
            ],
          ),
          Slider(
            value: (cfg.padding ?? 0).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) => vm.updateRowStyle(cfg.type, padding: v),
          ),
          const SizedBox(height: 8),
          ColorfulTextStyleEditorV2Enhanced(
            type: cfg.type,
            initialConfig: cfg.textStyleConfig,
            values: cfg.type == RowType.heavenlyStem
                ? TianGan.values.take(10).map((e) => e.name).toList()
                : DiZhi.values.take(12).map((e) => e.name).toList(),
            onChanged: (TextStyleConfig style) {
              vm.updateRowStyle(cfg.type, textStyleConfig: style);
            },
          ),
        ],
      ),
    );
  }
}
