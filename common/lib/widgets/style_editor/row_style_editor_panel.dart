import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/layout_template.dart';
import '../../models/text_style_config.dart';
import '../../viewmodels/four_zhu_editor_view_model.dart';
import '../../viewmodels/four_zhu_card_demo_viewmodel.dart';
import '../../widgets/editable_fourzhu_card/models/cell_style_config.dart';
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
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
      ),
      child: ExpansionTile(
        title: Text(cfg.type.name, style: theme.textTheme.titleSmall),
        childrenPadding: const EdgeInsets.all(12),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('显示标题'),
            value: cfg.isTitleVisible,
            onChanged: (v) => vm.updateRowTitleVisibility(cfg.type, v),
          ),
          Row(
            children: [
              const Expanded(child: Text('上下内边距 (px)')),
              Text('${cfg.paddingVertical?.toStringAsFixed(0) ?? 0}'),
            ],
          ),
          Slider(
            value: (cfg.paddingVertical ?? 0).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) {
              vm.updateRowStyle(cfg.type, padding: v);
              final demoVm =
                  Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
              final theme = demoVm.themeNotifier.value;
              final cell = theme.cell;
              final mapper = Map<RowType, CellStyleConfig>.of(
                  cell.rowTypeCellConfigMapper);
              final base = mapper[cfg.type] ?? cell.globalCellConfig;
              final pad = EdgeInsets.fromLTRB(
                  base.padding.left, v, base.padding.right, v);
              mapper[cfg.type] = base.copyWith(padding: pad);
              demoVm.updateEditableFourZhuCardTheme(theme.copyWith(
                  cell: cell.copyWith(rowTypeCellConfigMapper: mapper)));
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('上下外边距 (px)')),
              Text('${cfg.marginVertical?.toStringAsFixed(0) ?? 0}'),
            ],
          ),
          Slider(
            value: (cfg.marginVertical ?? 0).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) {
              vm.updateRowStyle(cfg.type, marginVertical: v);
              final demoVm =
                  Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
              final theme = demoVm.themeNotifier.value;
              final cell = theme.cell;
              final mapper = Map<RowType, CellStyleConfig>.of(
                  cell.rowTypeCellConfigMapper);
              final base = mapper[cfg.type] ?? cell.globalCellConfig;
              final mar = EdgeInsets.fromLTRB(
                  base.margin.left, v, base.margin.right, v);
              mapper[cfg.type] = base.copyWith(margin: mar);
              demoVm.updateEditableFourZhuCardTheme(theme.copyWith(
                  cell: cell.copyWith(rowTypeCellConfigMapper: mapper)));
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('左右外边距 (px)')),
              Text('${cfg.marginHorizontal?.toStringAsFixed(0) ?? 0}'),
            ],
          ),
          Slider(
            value: (cfg.marginHorizontal ?? 0).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) {
              vm.updateRowStyle(cfg.type, marginHorizontal: v);
              final demoVm =
                  Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
              final theme = demoVm.themeNotifier.value;
              final cell = theme.cell;
              final mapper = Map<RowType, CellStyleConfig>.of(
                  cell.rowTypeCellConfigMapper);
              final base = mapper[cfg.type] ?? cell.globalCellConfig;
              final mar = EdgeInsets.fromLTRB(
                  v, base.margin.top, v, base.margin.bottom);
              mapper[cfg.type] = base.copyWith(margin: mar);
              demoVm.updateEditableFourZhuCardTheme(theme.copyWith(
                  cell: cell.copyWith(rowTypeCellConfigMapper: mapper)));
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('左右内边距 (px)')),
              Text('${cfg.paddingHorizontal?.toStringAsFixed(0) ?? 0}'),
            ],
          ),
          Slider(
            value: (cfg.paddingHorizontal ?? 0).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) {
              vm.updateRowStyle(cfg.type, paddingHorizontal: v);
              final demoVm =
                  Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
              final theme = demoVm.themeNotifier.value;
              final cell = theme.cell;
              final mapper = Map<RowType, CellStyleConfig>.of(
                  cell.rowTypeCellConfigMapper);
              final base = mapper[cfg.type] ?? cell.globalCellConfig;
              final pad = EdgeInsets.fromLTRB(
                  v, base.padding.top, v, base.padding.bottom);
              mapper[cfg.type] = base.copyWith(padding: pad);
              demoVm.updateEditableFourZhuCardTheme(theme.copyWith(
                  cell: cell.copyWith(rowTypeCellConfigMapper: mapper)));
            },
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
