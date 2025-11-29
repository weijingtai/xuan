import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/layout_template.dart';
import '../../models/drag_payloads.dart';
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
    final demoVm =
        Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
    return ValueListenableBuilder<CardPayload>(
      valueListenable: demoVm.cardPayloadNotifier,
      builder: (context, payload, _) {
        final vm = Provider.of<FourZhuEditorViewModel>(context, listen: false);
        final all = payload.rowOrderUuid;
        if (all.isEmpty) {
          return const Text('暂无行配置');
        }
        final activeTypes = payload.rowOrderUuid
            .map((id) => payload.rowMap[id])
            .whereType<TextRowPayload>()
            .map((p) => p.rowType)
            .where((t) => t != RowType.separator)
            .toList();
        // final missing =
        // activeTypes.where((t) => !all.any((c) => c.type == t)).toList();
        // if (missing.isNotEmpty) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     for (final t in missing) {
        //       vm.ensureRowConfig(t);
        //     }
        //   });
        // }
        // final rows =
        // vm.rowConfigs.where((c) => activeTypes.contains(c.type)).toList();
        final orderMap = <RowType, int>{};
        for (int i = 0; i < payload.rowOrderUuid.length; i++) {
          final rp = payload.rowMap[payload.rowOrderUuid[i]];
          if (rp is TextRowPayload) {
            orderMap[rp.rowType] = i;
          }
        }

        // rows.sort((a, b) =>
        // (orderMap[a.type] ?? 999).compareTo(orderMap[b.type] ?? 999));
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, i) {
            RowType type = activeTypes[i];
            final rp = payload.rowMap[payload.rowOrderUuid[i]];
            final cfg = demoVm.themeNotifier.value.cell.getBy(type);
            final txtCfg =
                demoVm.themeNotifier.value.typography.getCellContentBy(
              type,
            );
            return RowItem(
              cfg: cfg,
              txtCfg: txtCfg,
              payload: rp!,
            );
            // return _RowItem(cfg: cfg, vm: vm);
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: activeTypes.length,
        );
      },
    );
  }
}

class RowItem extends StatelessWidget {
  // final RowConfig cfg;
  final CellStyleConfig cfg;
  final TextStyleConfig txtCfg;
  final RowPayload payload;
  // final FourZhuEditorViewModel vm;
  const RowItem(
      {required this.cfg, required this.txtCfg, required this.payload});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // print(cfg.type);
    // if (cfg.type == RowType.earthlyBranch) {
    //   print(json.encode(cfg
    //       .textStyleConfig.colorMapperDataModel.colorfulLightMapper
    //       .map((k, v) => MapEntry(k, v.toString()))));
    // }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
      ),
      child: ExpansionTile(
        title: Text(getRowTypeLabel(payload.rowType),
            style: theme.textTheme.titleSmall),
        childrenPadding: const EdgeInsets.all(12),
        children: [
          if (payload is TextRowPayload)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('显示标题'),
              value: (payload as TextRowPayload).titleInCell,
              onChanged: (v) {
                // vm.updateRowTitleVisibility(payload.rowType, v);
              },
              // onChanged: (v) => vm.updateRowTitleVisibility(payload.rowType, v),
            ),
          Row(
            children: [
              const Expanded(child: Text('上下内边距 (px)')),
              Text('${cfg.padding.bottom.toStringAsFixed(0) ?? 0}'),
            ],
          ),
          Slider(
            value: (cfg.padding.bottom ?? 0).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) {
              // vm.updateRowStyle(cfg.type, padding: v);
              // final demoVm =
              //     Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
              // final theme = demoVm.themeNotifier.value;
              // final cell = theme.cell;
              // final mapper = Map<RowType, CellStyleConfig>.of(
              //     cell.rowTypeCellConfigMapper);
              // final base = mapper[cfg.type] ?? cell.globalCellConfig;
              // final pad = EdgeInsets.fromLTRB(
              //     base.padding.left, v, base.padding.right, v);
              // mapper[cfg.type] = base.copyWith(padding: pad);
              // demoVm.updateEditableFourZhuCardTheme(theme.copyWith(
              //     cell: cell.copyWith(rowTypeCellConfigMapper: mapper)));
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('上下外边距 (px)')),
              Text('${cfg.margin.top.toStringAsFixed(0) ?? 0}'),
            ],
          ),
          Slider(
            value: (cfg.margin.top ?? 0).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) {
              // vm.updateRowStyle(cfg.type, marginVertical: v);
              // final demoVm =
              //     Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
              // final theme = demoVm.themeNotifier.value;
              // final cell = theme.cell;
              // final mapper = Map<RowType, CellStyleConfig>.of(
              //     cell.rowTypeCellConfigMapper);
              // final base = mapper[cfg.type] ?? cell.globalCellConfig;
              // final mar = EdgeInsets.fromLTRB(
              //     base.margin.left, v, base.margin.right, v);
              // mapper[cfg.type] = base.copyWith(margin: mar);
              // demoVm.updateEditableFourZhuCardTheme(theme.copyWith(
              //     cell: cell.copyWith(rowTypeCellConfigMapper: mapper)));
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('左右外边距 (px)')),
              Text('${cfg.margin.left.toStringAsFixed(0) ?? 0}'),
            ],
          ),
          Slider(
            value: (cfg.margin.left ?? 0).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) {
              // // vm.updateRowStyle(cfg.type, marginHorizontal: v);ddd
              // final demoVm =
              //     Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
              // final theme = demoVm.themeNotifier.value;
              // final cell = theme.cell;
              // final mapper = Map<RowType, CellStyleConfig>.of(
              //     cell.rowTypeCellConfigMapper);
              // final base = mapper[cfg.type] ?? cell.globalCellConfig;
              // final mar = EdgeInsets.fromLTRB(
              //     v, base.margin.top, v, base.margin.bottom);
              // mapper[cfg.type] = base.copyWith(margin: mar);
              // demoVm.updateEditableFourZhuCardTheme(theme.copyWith(
              //     cell: cell.copyWith(rowTypeCellConfigMapper: mapper)));
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('左右内边距 (px)')),
              Text('${cfg.padding.left.toStringAsFixed(0) ?? 0}'),
            ],
          ),
          Slider(
            value: (cfg.padding.left ?? 0).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) {
              // vm.updateRowStyle(cfg.type, paddingHorizontal: v);
              // final demoVm =
              //     Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
              // final theme = demoVm.themeNotifier.value;
              // final cell = theme.cell;
              // final mapper = Map<RowType, CellStyleConfig>.of(
              //     cell.rowTypeCellConfigMapper);
              // final base = mapper[cfg.type] ?? cell.globalCellConfig;
              // final pad = EdgeInsets.fromLTRB(
              //     v, base.padding.top, v, base.padding.bottom);
              // mapper[cfg.type] = base.copyWith(padding: pad);
              // demoVm.updateEditableFourZhuCardTheme(theme.copyWith(
              //     cell: cell.copyWith(rowTypeCellConfigMapper: mapper)));
            },
          ),
          const SizedBox(height: 8),
          ColorfulTextStyleEditorV2Enhanced(
            type: payload.rowType,
            initialConfig: txtCfg,
            values: payload.rowType == RowType.heavenlyStem
                ? TianGan.values.take(10).map((e) => e.name).toList()
                : DiZhi.values.take(12).map((e) => e.name).toList(),
            onChanged: (TextStyleConfig style) {
              // vm.updateRowStyle(cfg.type, textStyleConfig: style);
              // final demoVm =
              //     Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
              // final theme = demoVm.themeNotifier.value;
              // final typo = theme.typography;
              // final mapper =
              //     Map<RowType, TextStyleConfig>.of(typo.cellContentMapper);
              // mapper[cfg.type] = style;
              // demoVm.updateEditableFourZhuCardTheme(
              //   theme.copyWith(
              //     typography: typo.copyWith(cellContentMapper: mapper),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }

  String getRowTypeLabel(RowType type) {
    switch (type) {
      case RowType.columnHeaderRow: // 列标题行
        return '标题行';
      case RowType.heavenlyStem: // 天干
        return '天干';
      case RowType.earthlyBranch: // 地支
        return '地支';
      case RowType.tenGod: // 十神
        return '十神';
      case RowType.naYin: // 纳音
        return '纳音';
      case RowType.kongWang: // 空亡
        return '空亡';
      case RowType.xunShou: // 旬首
        return '旬首';
      case RowType.hiddenStems: // 藏干
        return '藏干';

      case RowType.hiddenStemsPrimary: // 藏干主气
        return '藏干·主气';
      case RowType.hiddenStemsSecondary: // 藏干中气
        return '藏干·中气';
      case RowType.hiddenStemsTertiary: // 藏干余气
        return '藏干·余气';
      case RowType.hiddenStemsTenGod: // 藏干十神
        return '';
      case RowType.hiddenStemsPrimaryGods: // 藏干主气 十神
        return '十神·藏干主气';
      case RowType.hiddenStemsSecondaryGods: // 藏干中气 十神
        return '十神·藏干中气';
      case RowType.hiddenStemsTertiaryGods: // 藏干余气 十神
        return '十神·藏干余气';
      case RowType.starYun: // 星运
        return '星运';
      case RowType.selfSiting: // 自坐
        return '自坐';
      case RowType.separator: // UI 分隔行：仅用于渲染水平分割线，不包含数据内容
        return '分隔行';
    }
  }
}

class _RowItem extends StatelessWidget {
  final RowConfig cfg;
  final FourZhuEditorViewModel vm;
  const _RowItem({required this.cfg, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    print(cfg.type);
    if (cfg.type == RowType.earthlyBranch) {
      print(json.encode(cfg
          .textStyleConfig.colorMapperDataModel.colorfulLightMapper
          .map((k, v) => MapEntry(k, v.toString()))));
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
      ),
      child: ExpansionTile(
        title:
            Text(getRowTypeLabel(cfg.type), style: theme.textTheme.titleSmall),
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
              final demoVm =
                  Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
              final theme = demoVm.themeNotifier.value;
              final typo = theme.typography;
              final mapper =
                  Map<RowType, TextStyleConfig>.of(typo.cellContentMapper);
              mapper[cfg.type] = style;
              demoVm.updateEditableFourZhuCardTheme(
                theme.copyWith(
                  typography: typo.copyWith(cellContentMapper: mapper),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String getRowTypeLabel(RowType type) {
    switch (type) {
      case RowType.columnHeaderRow: // 列标题行
        return '标题行';
      case RowType.heavenlyStem: // 天干
        return '天干';
      case RowType.earthlyBranch: // 地支
        return '地支';
      case RowType.tenGod: // 十神
        return '十神';
      case RowType.naYin: // 纳音
        return '纳音';
      case RowType.kongWang: // 空亡
        return '空亡';
      case RowType.xunShou: // 旬首
        return '旬首';
      case RowType.hiddenStems: // 藏干
        return '藏干';

      case RowType.hiddenStemsPrimary: // 藏干主气
        return '藏干·主气';
      case RowType.hiddenStemsSecondary: // 藏干中气
        return '藏干·中气';
      case RowType.hiddenStemsTertiary: // 藏干余气
        return '藏干·余气';
      case RowType.hiddenStemsTenGod: // 藏干十神
        return '';
      case RowType.hiddenStemsPrimaryGods: // 藏干主气 十神
        return '十神·藏干主气';
      case RowType.hiddenStemsSecondaryGods: // 藏干中气 十神
        return '十神·藏干中气';
      case RowType.hiddenStemsTertiaryGods: // 藏干余气 十神
        return '十神·藏干余气';
      case RowType.starYun: // 星运
        return '星运';
      case RowType.selfSiting: // 自坐
        return '自坐';
      case RowType.separator: // UI 分隔行：仅用于渲染水平分割线，不包含数据内容
        return '分隔行';
    }
  }
}
