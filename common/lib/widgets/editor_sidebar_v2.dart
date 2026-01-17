import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/layout_template_enums.dart';
import '../models/layout_template.dart';
import '../models/text_style_config.dart';
import '../viewmodels/four_zhu_editor_view_model.dart';
import 'row_style_editor_form.dart';
import 'style_editor/theme_edit_preview_sidebar.dart';
import 'style_editor/colorful_text_style_editor_widget_v2.dart'; // 增强版 V2 编辑器
import '../themes/editable_four_zhu_card_theme.dart';
import '../utils/constant_values_utils.dart';

/// 编辑器左侧边栏 V2 - 完全连接到 ViewModel
///
/// 功能：
/// - 柱间分隔线配置
/// - 行信息管理（可见性、排序）
/// - 全局字体设置
class EditorSidebarV2 extends StatelessWidget {
  const EditorSidebarV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FourZhuEditorViewModel>(
      builder: (context, viewModel, _) {
        final cardStyle = viewModel.cardStyle;
        final rowConfigs = viewModel.rowConfigs;

        return Container(
          width: 320,
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
              ),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 行信息管理区
              _RowConfigSection(
                rowConfigs: rowConfigs,
                onRowVisibilityChanged: viewModel.updateRowVisibility,
                onRowTitleVisibilityChanged: viewModel.updateRowTitleVisibility,
                onInlineSave: (updatedConfig) {
                  viewModel.updateRowStyle(
                    updatedConfig.type,
                    textStyleConfig: updatedConfig.textStyleConfig,
                    textAlign: updatedConfig.textAlign,
                    padding: updatedConfig.paddingVertical,
                    borderType: updatedConfig.borderType,
                    borderColorHex: updatedConfig.borderColorHex,
                    // 阴影参数
                    // shadowColorHex: updatedConfig.shadowColorHex,
                    // shadowOffsetX: updatedConfig.shadowOffsetX,
                    // shadowOffsetY: updatedConfig.shadowOffsetY,
                    // shadowBlurRadius: updatedConfig.shadowBlurRadius,
                  );
                },
              ),
              const Divider(height: 24),
              const _HeaderRowStyleSection(),
              const Divider(height: 32),

              // 主题编辑与预览（替换原“全局字体设置部分”）
              const ThemeEditPreviewSidebar(),

              const Divider(height: 32),

              // 柱间分隔线配置区
              _DividerConfigSection(
                cardStyle: cardStyle,
                onDividerTypeChanged: viewModel.updateDividerType,
                onDividerColorChanged: viewModel.updateDividerColor,
                onDividerThicknessChanged: viewModel.updateDividerThickness,
              ),
            ],
          ),
        );
      },
    );
  }

  // 弹窗编辑已移除：统一通过行卡片内的“下拉展开”进行样式编辑。
}

// 原全局“行样式编辑（内嵌）”模块已移除，按最新规范采用按行展开的交互。

/// 柱间分隔线配置区域（支持下拉展开/收起）
class _DividerConfigSection extends StatefulWidget {
  const _DividerConfigSection({
    required this.cardStyle,
    required this.onDividerTypeChanged,
    required this.onDividerColorChanged,
    required this.onDividerThicknessChanged,
  });

  final CardStyle? cardStyle;
  final ValueChanged<BorderType> onDividerTypeChanged;
  final ValueChanged<String> onDividerColorChanged;
  final ValueChanged<double> onDividerThicknessChanged;

  @override
  State<_DividerConfigSection> createState() => _DividerConfigSectionState();
}

class _DividerConfigSectionState extends State<_DividerConfigSection> {
  bool _expanded = true;

  /// 构建“柱间分隔线”配置区域
  ///
  /// 参数：
  /// - context: BuildContext 上下文，用于读取主题与颜色配置。
  /// 返回：
  /// - Widget：包含标题、说明、以及在展开状态下的分隔线样式、颜色与粗细设置控件。
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerType = widget.cardStyle?.dividerType ?? BorderType.none;
    final dividerColorHex = widget.cardStyle?.dividerColorHex ?? '#D1D5DB';
    final dividerThickness = widget.cardStyle?.dividerThickness ?? 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '柱间分隔线',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              tooltip: _expanded ? '收起' : '下拉展开',
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '自定义柱与柱之间的分隔线样式',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        if (_expanded) ...[
          // 样式下拉框
          DropdownButtonFormField<BorderType>(
            value: dividerType,
            decoration: const InputDecoration(
              labelText: '样式',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: BorderType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getBorderTypeName(type)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) widget.onDividerTypeChanged(value);
            },
          ),

          const SizedBox(height: 16),

          // 颜色选择
          Row(
            children: [
              const Text('颜色'),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _parseColor(dividerColorHex),
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: dividerColorHex),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: widget.onDividerColorChanged,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 粗细输入
          TextField(
            controller: TextEditingController(
                text: dividerThickness.toStringAsFixed(0)),
            decoration: const InputDecoration(
              labelText: '粗细 (px)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              final thickness = double.tryParse(value);
              if (thickness != null) {
                widget.onDividerThicknessChanged(thickness);
              }
            },
          ),
        ],
      ],
    );
  }

  /// 获取分隔线样式中文名称
  ///
  /// 参数：
  /// - type: BorderType 分隔线样式枚举。
  /// 返回：
  /// - String：中文样式名称（实线/虚线/点状/无）。
  String _getBorderTypeName(BorderType type) {
    switch (type) {
      case BorderType.solid:
        return '实线';
      case BorderType.dashed:
        return '虚线';
      case BorderType.dotted:
        return '点状';
      case BorderType.none:
        return '无';
    }
  }

  /// 解析十六进制颜色字符串为 Color
  ///
  /// 参数：
  /// - hex: String 十六进制颜色字符串（支持 6 位或 8 位，含/不含 #）。
  /// 返回：
  /// - Color：解析成功返回颜色，否则返回默认灰色。
  Color _parseColor(String hex) {
    try {
      final hexColor = hex.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
    } catch (e) {
      // Invalid color, return default
    }
    return const Color(0xFFD1D5DB);
  }
}

class _HeaderRowStyleSection extends StatefulWidget {
  const _HeaderRowStyleSection({super.key});

  @override
  State<_HeaderRowStyleSection> createState() => _HeaderRowStyleSectionState();
}

class _HeaderRowStyleSectionState extends State<_HeaderRowStyleSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final viewModel =
        Provider.of<FourZhuEditorViewModel>(context, listen: false);
    return ValueListenableBuilder<EditableFourZhuCardTheme>(
      valueListenable: viewModel.editableThemeNotifier,
      builder: (ctx, theme, _) {
        final pillarTitleCfg = theme.typography.pillarTitle;
        final cellCfg = theme.cell.pillarTitleCellConfig;
        final displayHeader = theme.displayHeaderRow;
        final t = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '标题行',
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  tooltip: _expanded ? '收起' : '下拉展开',
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
            if (_expanded) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('显示标题行'),
                value: displayHeader,
                onChanged: (v) {
                  viewModel.updateEditableFourZhuCardTheme(
                    theme.copyWith(displayHeaderRow: v),
                  );
                },
              ),
              ColorfulTextStyleEditorV2Enhanced(
                type: RowType.columnHeaderRow,
                initialConfig: pillarTitleCfg,
                brightnessNotifier: viewModel.cardBrightnessNotifier,
                colorPreviewModeNotifier: viewModel.colorPreviewModeNotifier,
                values: PillarType.values
                    .where((p) =>
                        p != PillarType.separator &&
                        p != PillarType.rowTitleColumn)
                    .map((p) => p.name)
                    .toList(growable: false),
                onChanged: (TextStyleConfig style) {
                  viewModel.updateEditableFourZhuCardTheme(
                    theme.copyWith(
                      typography: theme.typography.copyWith(pillarTitle: style),
                    ),
                  );
                },
                lable: '字体',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(child: Text('上下内边距 (px)')),
                  Text('${cellCfg.padding.bottom.toStringAsFixed(0)}'),
                ],
              ),
              Slider(
                value: cellCfg.padding.bottom.toDouble(),
                min: 0,
                max: 32,
                divisions: 32,
                onChanged: (v) {
                  final nextCell = cellCfg.copyWith(
                    padding: EdgeInsets.fromLTRB(
                      cellCfg.padding.left,
                      v,
                      cellCfg.padding.right,
                      v,
                    ),
                  );
                  viewModel.updateEditableFourZhuCardTheme(
                    theme.copyWith(
                      cell:
                          theme.cell.copyWith(pillarTitleCellConfig: nextCell),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(child: Text('左右内边距 (px)')),
                  Text('${cellCfg.padding.left.toStringAsFixed(0)}'),
                ],
              ),
              Slider(
                value: cellCfg.padding.left.toDouble(),
                min: 0,
                max: 32,
                divisions: 32,
                onChanged: (v) {
                  final nextCell = cellCfg.copyWith(
                    padding: EdgeInsets.fromLTRB(
                      v,
                      cellCfg.padding.top,
                      v,
                      cellCfg.padding.bottom,
                    ),
                  );
                  viewModel.updateEditableFourZhuCardTheme(
                    theme.copyWith(
                      cell:
                          theme.cell.copyWith(pillarTitleCellConfig: nextCell),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(child: Text('上下外边距 (px)')),
                  Text('${cellCfg.margin.top.toStringAsFixed(0)}'),
                ],
              ),
              Slider(
                value: cellCfg.margin.top.toDouble(),
                min: 0,
                max: 32,
                divisions: 32,
                onChanged: (v) {
                  final nextCell = cellCfg.copyWith(
                    margin: EdgeInsets.fromLTRB(
                      cellCfg.margin.left,
                      v,
                      cellCfg.margin.right,
                      v,
                    ),
                  );
                  viewModel.updateEditableFourZhuCardTheme(
                    theme.copyWith(
                      cell:
                          theme.cell.copyWith(pillarTitleCellConfig: nextCell),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(child: Text('左右外边距 (px)')),
                  Text('${cellCfg.margin.left.toStringAsFixed(0)}'),
                ],
              ),
              Slider(
                value: cellCfg.margin.left.toDouble(),
                min: 0,
                max: 32,
                divisions: 32,
                onChanged: (v) {
                  final nextCell = cellCfg.copyWith(
                    margin: EdgeInsets.fromLTRB(
                      v,
                      cellCfg.margin.top,
                      v,
                      cellCfg.margin.bottom,
                    ),
                  );
                  viewModel.updateEditableFourZhuCardTheme(
                    theme.copyWith(
                      cell:
                          theme.cell.copyWith(pillarTitleCellConfig: nextCell),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

/// 行信息管理区域
class _RowConfigSection extends StatelessWidget {
  const _RowConfigSection({
    required this.rowConfigs,
    required this.onRowVisibilityChanged,
    required this.onRowTitleVisibilityChanged,
    required this.onInlineSave,
  });

  final List<RowConfig> rowConfigs;
  final void Function(RowType type, bool isVisible) onRowVisibilityChanged;
  final void Function(RowType type, bool isTitleVisible)
      onRowTitleVisibilityChanged;
  final ValueChanged<RowConfig> onInlineSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 分离核心行和可选行
    final coreRows = rowConfigs
        .where((config) =>
            config.type == RowType.heavenlyStem ||
            config.type == RowType.earthlyBranch)
        .toList();

    final optionalRows = rowConfigs
        .where((config) =>
            config.type != RowType.heavenlyStem &&
            config.type != RowType.earthlyBranch)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '行信息管理',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: '重置',
              onPressed: () {
                // TODO: 实现重置逻辑
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '勾选需要显示的信息行，并拖动调整顺序',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),

        // 核心行（锁定）- Task 1.1.3
        ...coreRows.map((config) => _CoreRowItem(
              config: config,
              onInlineSave: onInlineSave,
            )),

        const SizedBox(height: 8),

        // 可选行（不提供拖拽排序）
        if (optionalRows.isNotEmpty)
          ...optionalRows.map((config) => _OptionalRowItem(
                key: ValueKey(config.type),
                config: config,
                onVisibilityChanged: (value) =>
                    onRowVisibilityChanged(config.type, value),
                onTitleVisibilityChanged: (value) =>
                    onRowTitleVisibilityChanged(config.type, value),
                onInlineSave: onInlineSave,
              )),
      ],
    );
  }
}

/// 核心行 Item（锁定不可重排，但支持样式下拉编辑）
///
/// 说明：
/// - 保留锁头图标，强调“不可重排”的核心属性；
/// - 增加下拉展开编辑区（RowStyleEditorForm），支持样式编辑；
/// - 与可选行卡片保持一致的边框风格，以形成统一视觉语言。
class _CoreRowItem extends StatefulWidget {
  const _CoreRowItem({
    required this.config,
    required this.onInlineSave,
  });

  final RowConfig config;
  final ValueChanged<RowConfig> onInlineSave;

  @override
  State<_CoreRowItem> createState() => _CoreRowItemState();
}

class _CoreRowItemState extends State<_CoreRowItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          dense: true,
          leading: Icon(Icons.lock, size: 18, color: theme.disabledColor),
          title: Text(
            _getRowTypeName(widget.config.type),
            style: theme.textTheme.bodyMedium,
          ),
          subtitle: const Text('核心', style: TextStyle(fontSize: 11)),
          tileColor:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          trailing: IconButton(
            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                size: 18),
            onPressed: () => setState(() => _expanded = !_expanded),
            tooltip: _expanded ? '收起' : '下拉展开',
          ),
        ),
        if (_expanded)
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(6),
              ),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: _buildCoreRowEditor(),
          ),
      ],
    );
  }

  String _getRowTypeName(RowType type) {
    switch (type) {
      case RowType.heavenlyStem:
        return '天干';
      case RowType.earthlyBranch:
        return '地支';
      default:
        return type.name;
    }
  }

  /// 构建核心行样式编辑器：天干/地支使用彩色文本样式编辑器
  Widget _buildCoreRowEditor() {
    final label = _getRowTypeName(widget.config.type);
    // final initial = _configToTextStyle(widget.config);
    final viewModel =
        Provider.of<FourZhuEditorViewModel>(context, listen: false);
    return ColorfulTextStyleEditorV2Enhanced(
      // label: '$label - 字体和阴影设置',
      type: widget.config.type,

      // initialStyle: initial,
      initialConfig: widget.config.textStyleConfig,
      brightnessNotifier: viewModel.cardBrightnessNotifier,
      colorPreviewModeNotifier: viewModel.colorPreviewModeNotifier,
      values: widget.config.type == RowType.heavenlyStem
          ? TianGan.values.take(10).map((e) => e.name).toList()
          : DiZhi.values.take(12).map((e) => e.name).toList(),
      onChanged: (TextStyleConfig style) {
        // final updated = _applyTextStyleToConfig(widget.config, style);
        // widget.onInlineSave(updated);
        widget.onInlineSave(
          widget.config.copyWith(
            textStyleConfig: style,
          ),
        );
      },
      lable: '字体',
    );
  }

  // /// 将 `RowConfig` 转换为 `TextStyle`。
  // ///
  // /// 优先使用 `config.textStyleConfig.toTextStyle()`，若不存在则回退到旧字段
  // ///（`fontFamily`、`fontSize`、`textColorHex`、`fontWeight`）的组合。该方法
  // /// 保证新旧样式存储结构均可编辑和展示。
  // ///
  // /// 特殊处理：对于天干/地支行，不传递颜色（保持 null），以便默认使用五行颜色。
  // TextStyle _configToTextStyle(RowConfig config) {
  //   // 检查是否为天干/地支行（应该使用五行颜色）
  //   final isGanZhiRow = config.type == RowType.heavenlyStem ||
  //       config.type == RowType.earthlyBranch;

  //   if (config.textStyleConfig != null) {
  //     final style = config.textStyleConfig!.toTextStyle();
  //     // 如果是天干/地支行，去除颜色信息，让 V3 Card 使用五行颜色
  //     // 注意：copyWith(color: null) 不会真正设置为 null，需要创建新的 TextStyle
  //     if (isGanZhiRow) {
  //       return TextStyle(
  //         fontFamily: style.fontFamily,
  //         fontSize: style.fontSize,
  //         fontWeight: style.fontWeight,
  //         fontStyle: style.fontStyle,
  //         letterSpacing: style.letterSpacing,
  //         wordSpacing: style.wordSpacing,
  //         height: style.height,
  //         shadows: style.shadows,
  //         decoration: style.decoration,
  //         decorationColor: style.decorationColor,
  //         decorationThickness: style.decorationThickness,
  //         // color 明确不传递，保持 null
  //       );
  //     }
  //     return style;
  //   }

  //   // 从旧字段构造，天干/地支行不传递颜色
  //   return config.textStyleConfig!.toTextStyle();
  //   // return TextStyle(
  //   //   fontFamily: config.textStyleConfig!.fontStyleDataModel.fontFamily,
  //   //   fontSize: config.textStyleConfig!.fontStyleDataModel.fontSize,
  //   //   color: isGanZhiRow ? null : config.textStyleConfig!,
  //   //   fontWeight: config.textStyleConfig!.fontStyleDataModel.fontWeight,
  //   // );
  // }

  /// 将 `TextStyle` 应用到 `RowConfig` 并保持向后兼容。
  ///
  /// 行为说明：
  /// - 始终写入 `textStyleConfig`（通过 `TextStyleConfig.fromTextStyle`）。
  /// - 同步旧字段（字体、字号、颜色、字重、阴影相关），以兼容历史数据和 UI。
  /// - 若提供了阴影，提取首个阴影并写回旧阴影字段。
  @Deprecated("Use TextStyleConfig instead")
  RowConfig _applyTextStyleToConfig(RowConfig config, TextStyle style) {
    // 提取阴影信息（如果存在）
    String? shadowHex;
    double? shadowX, shadowY, shadowBlur;
    if (style.shadows != null && style.shadows!.isNotEmpty) {
      final shadow = style.shadows!.first;
      shadowHex = _colorToHex(shadow.color);
      shadowX = shadow.offset.dx;
      shadowY = shadow.offset.dy;
      shadowBlur = shadow.blurRadius;
    }

    return config.copyWith(
      // 同步新版 TextStyleConfig
      textStyleConfig: TextStyleConfig.fromTextStyle(style),
      // 阴影字段
      // shadowColorHex: shadowHex,
      // shadowOffsetX: shadowX,
      // shadowOffsetY: shadowY,
      // shadowBlurRadius: shadowBlur,
    );
  }

  /// 解析颜色字符串为 Color
  Color? _tryParseColor(String? hex) {
    if (hex == null) return null;
    try {
      final h = hex.replaceAll('#', '');
      if (h.length == 6) {
        return Color(int.parse('FF$h', radix: 16));
      } else if (h.length == 8) {
        return Color(int.parse(h, radix: 16));
      }
    } catch (_) {}
    return null;
  }

  /// 将 Color 转为 #AARRGGBB 字符串
  String? _colorToHex(Color? c) {
    if (c == null) return null;
    final a = c.alpha.toRadixString(16).padLeft(2, '0').toUpperCase();
    final r = c.red.toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = c.green.toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = c.blue.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$a$r$g$b';
  }

  /// 将 FontWeight 转为字符串（如 'w400', 'w700'）
  String? _fontWeightToString(FontWeight? weight) {
    if (weight == null) return null;
    // FontWeight.w400.value 返回 400
    return 'w${weight.value}';
  }

  /// 从字符串解析 FontWeight（如 'w400' -> FontWeight.w400）
  FontWeight? _stringToFontWeight(String? str) {
    if (str == null || str.isEmpty) return null;
    // 移除 'w' 前缀并解析数字
    final valueStr = str.replaceFirst('w', '');
    final value = int.tryParse(valueStr);
    if (value == null) return null;

    // 映射到对应的 FontWeight
    switch (value) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.w400; // 默认 normal
    }
  }
}

/// 可选行 Item（可见性开关 + 编辑按钮 + 拖拽句柄）
class _OptionalRowItem extends StatefulWidget {
  const _OptionalRowItem({
    super.key,
    required this.config,
    required this.onVisibilityChanged,
    required this.onTitleVisibilityChanged,
    required this.onInlineSave,
  });

  final RowConfig config;
  final ValueChanged<bool> onVisibilityChanged;
  final ValueChanged<bool> onTitleVisibilityChanged;
  final ValueChanged<RowConfig> onInlineSave;

  @override
  State<_OptionalRowItem> createState() => _OptionalRowItemState();
}

class _OptionalRowItemState extends State<_OptionalRowItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      elevation: 0,
      color: widget.config.isVisible
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            dense: true,
            // 需求：在「十神」「地支藏干」中添加可被拖拽的抓手 icon；同时移除第一个复选框（非“显示标题”）
            leading: _buildLeadingIcon(context, widget.config),
            // 标题行同时展示“显示标题”开关（仅在行可见时生效）
            title: _buildTitleWithSwitcher(widget.config),
            subtitle: null,
            // 仅保留下拉展开按钮，移除“编辑样式（弹窗）”铅笔图标。
            trailing: IconButton(
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 18,
              ),
              onPressed: widget.config.isVisible
                  ? () => setState(() => _expanded = !_expanded)
                  : null,
              tooltip: _expanded ? '收起' : '下拉展开',
            ),
          ),
          if (_expanded && widget.config.isVisible)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.06),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: _buildOptionalRowEditor(),
            ),
        ],
      ),
    );
  }

  String _getRowTypeName(RowType type) {
    switch (type) {
      case RowType.tenGod:
        return '十神';
      case RowType.naYin:
        return '纳音';
      case RowType.kongWang:
        return '空亡';
      case RowType.gu:
        return '孤';
      case RowType.xu:
        return '虚';
      case RowType.xunShou:
        return '旬首';
      case RowType.yiMa:
        return '驿马';
      case RowType.hiddenStems:
        return '地支藏干';
      case RowType.hiddenStemsTenGod:
        return '藏干十神';
      default:
        return type.name;
    }
  }

  /// 构建标题区域（与“显示标题”开关同一行）
  ///
  /// 行为说明：
  /// - 当该行处于可见状态（config.isVisible == true）时，标题右侧显示“显示标题”文案与 Switch；
  /// - 当该行不可见时，仅展示标题文本，不显示开关（避免无效交互）。
  /// - Switch 的状态绑定到 `config.isTitleVisible`，回调转发到 `onTitleVisibilityChanged`。
  Widget _buildTitleWithSwitcher(RowConfig config) {
    final titleWidget = Text(_getRowTypeName(config.type));
    if (!config.isVisible) return titleWidget;

    return Row(
      children: [
        Expanded(child: titleWidget),
        const SizedBox(width: 8),
        const Text('显示标题', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Switch.adaptive(
          value: config.isTitleVisible,
          onChanged: (value) => widget.onTitleVisibilityChanged(value),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  /// 构建可选行的 leading 区域
  ///
  /// - 十神、地支藏干：展示可拖拽抓手 icon（视觉引导，后续可接入排序）
  /// - 其他：保留可见性复选框
  Widget _buildLeadingIcon(BuildContext context, RowConfig config) {
    final type = config.type;
    if (type == RowType.tenGod || type == RowType.hiddenStems) {
      return const Icon(Icons.drag_handle);
    }
    return Checkbox(
      value: config.isVisible,
      onChanged: (value) => widget.onVisibilityChanged(value ?? false),
    );
  }

  /// 构建可选行样式编辑器：固定值行使用逐值颜色编辑器
  Widget _buildOptionalRowEditor() {
    final type = widget.config.type;
    final label = _getRowTypeName(type);

    final List<String>? values;
    if (type == RowType.tenGod) {
      values = const [
        '正印',
        '偏印',
        '正官',
        '七杀',
        '食神',
        '伤官',
        '比肩',
        '劫财',
        '正财',
        '偏财',
        FourZhuText.qianZao,
        FourZhuText.kunZao,
      ];
    } else if (type == RowType.hiddenStemsTenGod) {
      values = const [
        '正印',
        '偏印',
        '正官',
        '七杀',
        '食神',
        '伤官',
        '比肩',
        '劫财',
        '正财',
        '偏财',
      ];
    } else if (type == RowType.xunShou) {
      values = const [
        JiaZi.JIA_ZI,
        JiaZi.JIA_XU,
        JiaZi.JIA_SHEN,
        JiaZi.JIA_WU,
        JiaZi.JIA_CHEN,
        JiaZi.JIA_YIN,
      ].map((e) => e.ganZhiStr).toList(growable: false);
    } else if (type == RowType.naYin) {
      values = NaYinFiveXing.values.map((e) => e.name).toList(growable: false);
    } else if (type == RowType.kongWang) {
      values = const ['戌亥', '申酉', '午未', '辰巳', '寅卯', '子丑'];
    } else {
      values = null;
    }

    if (values != null) {
      final viewModel =
          Provider.of<FourZhuEditorViewModel>(context, listen: false);
      return ColorfulTextStyleEditorV2Enhanced(
        type: type,
        values: values,
        initialConfig: widget.config.textStyleConfig,
        brightnessNotifier: viewModel.cardBrightnessNotifier,
        colorPreviewModeNotifier: viewModel.colorPreviewModeNotifier,
        onChanged: (style) {
          widget.onInlineSave(
            widget.config.copyWith(
              textStyleConfig: style,
            ),
          );
        },
        lable: label,
      );
    }

    return RowStyleEditorForm(
      config: widget.config,
      onSave: widget.onInlineSave,
    );
  }

  /// 将 `RowConfig` 转换为 `TextStyle`（第二处）。
  ///
  /// 与前文逻辑保持一致：优先使用 `textStyleConfig` 转换，若为空则回退到
  /// 旧字段组合，确保新旧数据结构的编辑与展示一致性。
  // TextStyle _configToTextStyle(RowConfig config) {
  //   return config.textStyleConfig?.toTextStyle() ??
  //       TextStyle(
  //         fontFamily: config.fontFamily,
  //         fontSize: config.fontSize,
  //         color: _tryParseColor(config.textColorHex),
  //         fontWeight: _stringToFontWeight(config.fontWeight),
  //       );
  // }

  /// 将 `TextStyle` 应用到 `RowConfig` 并保持向后兼容（第二处）。
  ///
  /// 行为与前文一致：写入 `textStyleConfig` 并同步旧字段与阴影信息，避免旧
  /// 数据在 UI 或序列化路径中出现不一致。
  RowConfig _applyTextStyleToConfig(RowConfig config, TextStyle style) {
    // 提取阴影信息（如果存在）
    String? shadowHex;
    double? shadowX, shadowY, shadowBlur;
    if (style.shadows != null && style.shadows!.isNotEmpty) {
      final shadow = style.shadows!.first;
      shadowHex = _colorToHex(shadow.color);
      shadowX = shadow.offset.dx;
      shadowY = shadow.offset.dy;
      shadowBlur = shadow.blurRadius;
    }

    return config.copyWith(
      // 同步新版 TextStyleConfig
      textStyleConfig: TextStyleConfig.fromTextStyle(style),
      // // 阴影字段
      // shadowColorHex: shadowHex,
      // shadowOffsetX: shadowX,
      // shadowOffsetY: shadowY,
      // shadowBlurRadius: shadowBlur,
    );
  }

  Color? _tryParseColor(String? hex) {
    if (hex == null) return null;
    try {
      final h = hex.replaceAll('#', '');
      if (h.length == 6) {
        return Color(int.parse('FF$h', radix: 16));
      } else if (h.length == 8) {
        return Color(int.parse(h, radix: 16));
      }
    } catch (_) {}
    return null;
  }

  String? _colorToHex(Color? c) {
    if (c == null) return null;
    final a = c.alpha.toRadixString(16).padLeft(2, '0').toUpperCase();
    final r = c.red.toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = c.green.toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = c.blue.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$a$r$g$b';
  }

  /// 将 FontWeight 转为字符串（如 'w400', 'w700'）
  String? _fontWeightToString(FontWeight? weight) {
    if (weight == null) return null;
    return 'w${weight.value}';
  }

  /// 从字符串解析 FontWeight（如 'w400' -> FontWeight.w400）
  FontWeight? _stringToFontWeight(String? str) {
    if (str == null || str.isEmpty) return null;
    final valueStr = str.replaceFirst('w', '');
    final value = int.tryParse(valueStr);
    if (value == null) return null;

    switch (value) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }
}

/// 全局字体设置区域（支持下拉展开/收起）
class _GlobalFontSection extends StatefulWidget {
  const _GlobalFontSection({
    required this.cardStyle,
    required this.onFontFamilyChanged,
    required this.onFontSizeChanged,
    required this.onFontColorChanged,
  });

  final CardStyle? cardStyle;
  final ValueChanged<String> onFontFamilyChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<String> onFontColorChanged;

  @override
  State<_GlobalFontSection> createState() => _GlobalFontSectionState();
}

class _GlobalFontSectionState extends State<_GlobalFontSection> {
  bool _expanded = true;

  /// 构建“全局字体设置”区域
  ///
  /// 参数：
  /// - context: BuildContext 上下文，用于读取主题。
  /// 返回：
  /// - Widget：包含标题、说明、以及在展开状态下的字体家族、字号与颜色配置控件。
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontFamily =
        widget.cardStyle?.globalFontFamily ?? 'NotoSansSC-Regular';
    final fontSize = widget.cardStyle?.globalFontSize ?? 14.0;
    final fontColorHex = widget.cardStyle?.globalFontColorHex ?? '#FF000000';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '全局字体设置',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              tooltip: _expanded ? '收起' : '下拉展开',
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '设置默认字体样式',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        if (_expanded) ...[
          // 字体选择
          DropdownButtonFormField<String>(
            value: fontFamily == 'NotoSans' ? 'NotoSansSC-Regular' : fontFamily,
            decoration: const InputDecoration(
              labelText: '字体',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: '系统默认', child: Text('系统默认')),
              DropdownMenuItem(
                  value: 'NotoSansSC-Regular',
                  child: Text('NotoSansSC-Regular')),
              DropdownMenuItem(
                  value: 'PingFang SC', child: Text('PingFang SC')),
              DropdownMenuItem(
                  value: 'Hiragino Sans GB', child: Text('Hiragino Sans GB')),
              DropdownMenuItem(value: 'Noto Sans', child: Text('Noto Sans')),
              DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
              DropdownMenuItem(value: 'Segoe UI', child: Text('Segoe UI')),
              DropdownMenuItem(
                  value: 'Helvetica Neue', child: Text('Helvetica Neue')),
              DropdownMenuItem(value: 'Arial', child: Text('Arial')),
              DropdownMenuItem(
                  value: 'Microsoft YaHei', child: Text('Microsoft YaHei')),
              DropdownMenuItem(value: 'Ubuntu', child: Text('Ubuntu')),
              DropdownMenuItem(value: 'sans-serif', child: Text('sans-serif')),
            ],
            onChanged: (value) {
              if (value != null) widget.onFontFamilyChanged(value);
            },
          ),

          const SizedBox(height: 16),

          // 字号滑块
          Row(
            children: [
              Expanded(
                child: Text('字号', style: theme.textTheme.bodyMedium),
              ),
              Text('${fontSize.toInt()}', style: theme.textTheme.bodySmall),
            ],
          ),
          Slider(
            value: fontSize,
            min: 10,
            max: 24,
            divisions: 14,
            label: fontSize.toInt().toString(),
            onChanged: widget.onFontSizeChanged,
          ),

          const SizedBox(height: 8),

          // 颜色选择
          Row(
            children: [
              const Text('颜色'),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _parseColor(fontColorHex),
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: fontColorHex),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: widget.onFontColorChanged,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _parseColor(String hex) {
    try {
      final hexColor = hex.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
    } catch (e) {
      // Invalid color, return default
    }
    return Colors.black;
  }
}
