import 'package:common/enums.dart';
import 'package:common/enums/enum_twelve_zhang_sheng.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/drag_payloads.dart';
import '../../models/text_style_config.dart';
import '../../themes/editable_four_zhu_card_theme.dart';
import '../../utils/constant_values_utils.dart';
import '../../viewmodels/four_zhu_editor_view_model.dart';
import '../../features/four_zhu_card/widgets/editable_fourzhu_card/models/cell_style_config.dart';
import '../../enums/enum_tian_gan.dart';
import '../../enums/enum_di_zhi.dart';
import '../../enums/enum_jia_zi.dart';
import 'colorful_text_style_editor_widget_v2.dart';

class RowStyleEditorPanel extends StatelessWidget {
  const RowStyleEditorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final editorVm = context.read<FourZhuEditorViewModel>();
    return ValueListenableBuilder<CardPayload>(
      valueListenable: editorVm.cardPayloadNotifier,
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
        final orderMap = <RowType, int>{};
        for (int i = 0; i < payload.rowOrderUuid.length; i++) {
          final rp = payload.rowMap[payload.rowOrderUuid[i]];
          if (rp is TextRowPayload) {
            orderMap[rp.rowType] = i;
          }
        }

        return ValueListenableBuilder<EditableFourZhuCardTheme>(
          valueListenable: editorVm.editableThemeNotifier,
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

                editorVm.reorderRowsByTypes(newTypes);
                editorVm.updateRowOrderFromTypes(newTypes);
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
                      inCellTitleTextCfg: () {
                        final rt = validRows[i].rowType;
                        final base = theme.typography.getCellTitleBy(rt);
                        final hasCustom =
                            theme.typography.cellTitleMapper.containsKey(rt);
                        if (hasCustom) return base;
                        return base.copyWith(
                          colorMapperDataModel:
                              theme.typography.rowTitle.colorMapperDataModel,
                        );
                      }(),
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
                  ),
              ],
            );
          },
        );
      },
    );
  }

  onInCellTitleTextStyleChanged(BuildContext context, String rowUUID,
      RowType type, TextStyleConfig newTextStyle) {
    final editorVm = context.read<FourZhuEditorViewModel>();
    final oldTheme = editorVm.editableThemeNotifier.value;

    final mappr = Map.fromEntries(
        oldTheme.typography.cellTitleMapper.entries.map((e) => e));
    mappr[type] = newTextStyle;

    final newTheme = oldTheme.copyWith(
      typography: oldTheme.typography.copyWith(
        cellTitleMapper: mappr,
        // cellContentMapper: mappr,
      ),
    );
    editorVm.updateEditableFourZhuCardTheme(newTheme);
  }

  onTextStyleChanged(BuildContext context, String rowUUID, RowType type,
      TextStyleConfig newTextStyle) {
    final editorVm = context.read<FourZhuEditorViewModel>();
    final oldTheme = editorVm.editableThemeNotifier.value;

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
    editorVm.updateEditableFourZhuCardTheme(newTheme);
  }

  onCellStyleChanged(BuildContext context, String rowUUID, RowType type,
      CellStyleConfig newCellStyle) {
    final editorVm = context.read<FourZhuEditorViewModel>();
    final oldTheme = editorVm.editableThemeNotifier.value;

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

    editorVm.updateEditableFourZhuCardTheme(newTheme);
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

  List<String>? _valuesForRowType(CardPayload cardPayload, RowType type) {
    switch (type) {
      case RowType.columnHeaderRow:
        final out = <String>[];
        for (final uuid in cardPayload.pillarOrderUuid) {
          final p = cardPayload.pillarMap[uuid];
          if (p == null) continue;
          if (p.pillarType == PillarType.separator) continue;
          if (p.pillarType == PillarType.rowTitleColumn) continue;
          final name = p.pillarType.name;
          if (!out.contains(name)) out.add(name);
        }
        return out;
      case RowType.earthlyBranch:
        return DiZhi.values.take(12).map((e) => e.name).toList(growable: false);
      case RowType.heavenlyStem:
      case RowType.hiddenStems:
      case RowType.hiddenStemsPrimary:
      case RowType.hiddenStemsSecondary:
      case RowType.hiddenStemsTertiary:
        return TianGan.values
            .take(10)
            .map((e) => e.name)
            .toList(growable: false);
      case RowType.tenGod:
        return EnumTenGods.values.map((e) => e.name).toList(growable: true)
          ..add(FourZhuText.qianZao)
          ..add(FourZhuText.kunZao);
      case RowType.hiddenStemsTenGod:
      case RowType.hiddenStemsPrimaryGods:
      case RowType.hiddenStemsSecondaryGods:
        return EnumTenGods.values.map((e) => e.name).toList(growable: true);
      case RowType.xunShou:
        return const [
          JiaZi.JIA_ZI,
          JiaZi.JIA_XU,
          JiaZi.JIA_SHEN,
          JiaZi.JIA_WU,
          JiaZi.JIA_CHEN,
          JiaZi.JIA_YIN,
        ].map((e) => e.ganZhiStr).toList(growable: false);
      case RowType.naYin:
        return NaYinFiveXing.values.map((e) => e.name).toList(growable: false);
      case RowType.kongWang:
        return const ['戌亥', '申酉', '午未', '辰巳', '寅卯', '子丑'];
      case RowType.yiMa:
        return const ['寅', '申', '亥', '巳'];
      case RowType.selfSiting:
      case RowType.starYun:
        return TwelveZhangSheng.values
            .map((e) => e.name)
            .toList(growable: false);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editorVm = context.read<FourZhuEditorViewModel>();

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
              Text(cfg.padding.bottom.toStringAsFixed(0)),
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
              Text(cfg.margin.top.toStringAsFixed(0)),
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
              Text(cfg.margin.left.toStringAsFixed(0)),
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
              Text(cfg.padding.left.toStringAsFixed(0)),
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
              brightnessNotifier: editorVm.cardBrightnessNotifier,
              colorPreviewModeNotifier: editorVm.colorPreviewModeNotifier,
              values: _valuesForRowType(
                editorVm.cardPayloadNotifier.value,
                payload.rowType,
              ),
              showPureAllConsistentButton: false,
              onChanged: onTextStyleChanged,
            ),
          if (cfg.showsTitleInCell) ...[
            const SizedBox(height: 8),
            ColorfulTextStyleEditorV2Enhanced(
                lable: '内标题字体',
                type: payload.rowType,
                initialConfig: inCellTitleTextCfg,
                brightnessNotifier: editorVm.cardBrightnessNotifier,
                colorPreviewModeNotifier: editorVm.colorPreviewModeNotifier,
                values: [getRowTypeLabel(payload.rowType)],
                enableColorEditing: true,
                showPureAllConsistentButton: false,
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
