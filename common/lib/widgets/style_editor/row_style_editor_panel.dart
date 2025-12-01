import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/layout_template.dart';
import '../../models/drag_payloads.dart';
import '../../models/text_style_config.dart';
import '../../themes/editable_four_zhu_card_theme.dart';
import '../../utils/constant_values_utils.dart';
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
        // final vm = Provider.of<FourZhuEditorViewModel>(context, listen: false);
        final all = payload.rowOrderUuid;
        if (all.isEmpty) {
          return const Text('暂无行配置');
        }
        final validRows = payload.rowOrderUuid
            .map((id) => payload.rowMap[id])
            .where((p) => p != null)
            .cast<RowPayload>()
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
        return ValueListenableBuilder<EditableFourZhuCardTheme>(
          valueListenable: demoVm.themeNotifier,
          builder: (ctx, theme, __) {
            return ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final newRows = List<RowPayload>.from(validRows);
                final item = newRows.removeAt(oldIndex);
                newRows.insert(newIndex, item);
                final newTypes = newRows.map((r) => r.rowType).toList();

                final editorVm =
                    Provider.of<FourZhuEditorViewModel>(context, listen: false);
                editorVm.reorderRowsByTypes(newTypes);
                demoVm.updateRowOrderFromTypes(newTypes);
              },
              children: [
                for (int i = 0; i < validRows.length; i++)
                  Container(
                    key: ValueKey(validRows[i].uuid),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: RowItem(
                      leading: ReorderableDragStartListener(
                        index: i,
                        child: const Icon(Icons.drag_handle),
                      ),
                      cfg: theme.cell.getBy(validRows[i].rowType),
                      txtCfg: theme.typography
                          .getCellContentBy(validRows[i].rowType),
                      inCellTitleTextCfg:
                          theme.typography.getCellTitleBy(validRows[i].rowType),
                      payload: validRows[i],
                      onTextStyleChanged: (newTextStyle) {
                        onTextStyleChanged(context, validRows[i].uuid,
                            validRows[i].rowType, newTextStyle);
                      },
                      onCellStyleChanged: (newCellStyle) {
                        onCellStyleChanged(context, validRows[i].uuid,
                            validRows[i].rowType, newCellStyle);
                      },
                      onInCellTitleTextStyleChanged: (newTextStyle) {
                        onInCellTitleTextStyleChanged(
                            context,
                            validRows[i].uuid,
                            validRows[i].rowType,
                            newTextStyle);
                      },
                    ),
                  )
              ],
            );
          },
        );
      },
    );
  }

  onInCellTitleTextStyleChanged(BuildContext context, String rowUUID,
      RowType type, TextStyleConfig newTextStyle) {
    final demoVm =
        Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
    final oldTheme = demoVm.themeNotifier.value;

    final mappr = Map.fromEntries(
        oldTheme.typography.cellTitleMapper.entries.map((e) => e));
    mappr[type] = newTextStyle;

    final newTheme = oldTheme.copyWith(
      typography: oldTheme.typography.copyWith(
        cellTitleMapper: mappr,
        // cellContentMapper: mappr,
      ),
    );
    demoVm.updateEditableFourZhuCardTheme(newTheme);
  }

  onTextStyleChanged(BuildContext context, String rowUUID, RowType type,
      TextStyleConfig newTextStyle) {
    final demoVm =
        Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
    final oldTheme = demoVm.themeNotifier.value;

    final mappr = Map.fromEntries(
        oldTheme.typography.cellContentMapper.entries.map((e) => e));
    mappr[type] = newTextStyle;

    var newTheme = oldTheme.copyWith(
      typography: oldTheme.typography.copyWith(
        cellContentMapper: mappr,
      ),
    );
    if (RowType.columnHeaderRow == type) {
      newTheme = newTheme.copyWith(
        typography: newTheme.typography.copyWith(
          pillarTitle: newTextStyle,
        ),
      );
    }
    demoVm.updateEditableFourZhuCardTheme(newTheme);
  }

  onCellStyleChanged(BuildContext context, String rowUUID, RowType type,
      CellStyleConfig newCellStyle) {
    final demoVm =
        Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
    final oldTheme = demoVm.themeNotifier.value;

    final rowTypeCellConfigMapper = Map.fromEntries(
        oldTheme.cell.rowTypeCellConfigMapper.entries.map((e) => e));
    rowTypeCellConfigMapper[type] = newCellStyle;

    var newCell = oldTheme.cell.copyWith(
      rowTypeCellConfigMapper: rowTypeCellConfigMapper,
    );
    if (RowType.columnHeaderRow == type) {
      newCell = newCell.copyWith(
        pillarTitleCellConfig: newCellStyle,
      );
    }

    var newTheme = oldTheme.copyWith(
      cell: newCell,
    );

    demoVm.updateEditableFourZhuCardTheme(newTheme);
  }
}

class RowItem extends StatelessWidget {
  // final RowConfig cfg;
  final CellStyleConfig cfg;
  final TextStyleConfig txtCfg;
  final TextStyleConfig inCellTitleTextCfg;
  final RowPayload payload;
  final ValueChanged<TextStyleConfig> onTextStyleChanged;
  final ValueChanged<TextStyleConfig> onInCellTitleTextStyleChanged;

  final ValueChanged<CellStyleConfig> onCellStyleChanged;
  final Widget? leading;

  // final FourZhuEditorViewModel vm;
  const RowItem(
      {required this.cfg,
      required this.txtCfg,
      required this.inCellTitleTextCfg,
      required this.payload,
      required this.onTextStyleChanged,
      required this.onCellStyleChanged,
      required this.onInCellTitleTextStyleChanged,
      this.leading});

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
        leading: leading,
        title: Text(getRowTypeLabel(payload.rowType),
            style: theme.textTheme.titleSmall),
        subtitle: (payload is TextRowPayload &&
                payload.rowType != RowType.columnHeaderRow &&
                payload.rowType != RowType.separator)
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: cfg.showsTitleInCell,
                    onChanged: (v) {
                      if (v == null) return;
                      onCellStyleChanged(
                        cfg.copyWith(showsTitleInCell: v),
                      );
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    '单元格内显示标题',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              )
            : null,
        childrenPadding: const EdgeInsets.all(12),
        children: [
          if (payload.rowType == RowType.separator) ...[
            Row(
              children: [
                const Expanded(child: Text('行高度 (px)')),
                Text('${cfg.separatorHeight?.toStringAsFixed(0) ?? 0}'),
              ],
            ),
            Slider(
              value: (cfg.separatorHeight ?? 0).toDouble(),
              min: 0,
              max: 64,
              onChanged: (v) {
                onCellStyleChanged(
                  cfg.copyWith(separatorHeight: v),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              const Expanded(child: Text('上下内边距 (px)')),
              Text('${cfg.padding.bottom.toStringAsFixed(0) ?? 0}'),
            ],
          ),
          Slider(
            value: (cfg.padding.bottom).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) {
              onCellStyleChanged(
                cfg.copyWith(
                    padding: EdgeInsets.fromLTRB(
                        cfg.padding.right, v, cfg.padding.right, v)),
              );
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
            value: (cfg.margin.top).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) {
              onCellStyleChanged(
                cfg.copyWith(
                    margin: EdgeInsets.fromLTRB(
                        cfg.margin.left, v, cfg.margin.right, v)),
              );
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
            value: (cfg.margin.left).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) {
              onCellStyleChanged(
                cfg.copyWith(
                    margin: EdgeInsets.fromLTRB(
                        v, cfg.margin.top, v, cfg.margin.bottom)),
              );
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
            value: (cfg.padding.left).toDouble(),
            min: 0,
            max: 32,
            onChanged: (v) {
              onCellStyleChanged(
                cfg.copyWith(
                    padding: EdgeInsets.fromLTRB(
                        v, cfg.padding.top, v, cfg.padding.bottom)),
              );
            },
          ),
          const SizedBox(height: 8),
          if (payload.rowType != RowType.separator)
            ColorfulTextStyleEditorV2Enhanced(
                lable: '字体',
                type: payload.rowType,
                initialConfig: txtCfg,
                values: payload.rowType == RowType.heavenlyStem
                    ? TianGan.values.take(10).map((e) => e.name).toList()
                    : DiZhi.values.take(12).map((e) => e.name).toList(),
                onChanged: onTextStyleChanged),
          if (cfg.showsTitleInCell) ...[
            const SizedBox(height: 8),
            ColorfulTextStyleEditorV2Enhanced(
                lable: '内标题字体',
                type: payload.rowType,
                initialConfig: inCellTitleTextCfg,
                onChanged: onInCellTitleTextStyleChanged),
          ]
        ],
      ),
    );
  }

  String getRowTypeLabel(RowType type) {
    return ConstantValuesUtils.labelForRowType(type);
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
            lable: '字体',
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
