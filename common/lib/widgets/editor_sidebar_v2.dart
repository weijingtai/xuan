import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/layout_template_enums.dart';
import '../models/layout_template.dart';
import '../viewmodels/four_zhu_editor_view_model.dart';
import 'row_style_editor_dialog.dart';

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
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
              ),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 柱间分隔线配置区
                _DividerConfigSection(
                  cardStyle: cardStyle,
                  onDividerTypeChanged: viewModel.updateDividerType,
                  onDividerColorChanged: viewModel.updateDividerColor,
                  onDividerThicknessChanged: viewModel.updateDividerThickness,
                ),

                const Divider(height: 32),

                // 行信息管理区
                _RowConfigSection(
                  rowConfigs: rowConfigs,
                  onRowVisibilityChanged: viewModel.updateRowVisibility,
                  onRowTitleVisibilityChanged:
                      viewModel.updateRowTitleVisibility,
                  onRowOrderChanged: (oldIndex, newIndex) {
                    viewModel.updateRowOrder(
                        oldIndex: oldIndex, newIndex: newIndex);
                  },
                  onRowStyleEdit: (config) =>
                      _showRowStyleDialog(context, config, viewModel),
                ),

                const Divider(height: 32),

                // 全局字体设置区
                _GlobalFontSection(
                  cardStyle: cardStyle,
                  onFontFamilyChanged: viewModel.updateGlobalFontFamily,
                  onFontSizeChanged: viewModel.updateGlobalFontSize,
                  onFontColorChanged: viewModel.updateGlobalFontColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRowStyleDialog(
    BuildContext context,
    RowConfig config,
    FourZhuEditorViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (_) => RowStyleEditorDialog(
        config: config,
        onSave: (updatedConfig) {
          // 调用 ViewModel 的 updateRowStyle 方法
          viewModel.updateRowStyle(
            updatedConfig.type,
            fontFamily: updatedConfig.fontFamily,
            fontSize: updatedConfig.fontSize,
            colorHex: updatedConfig.textColorHex,
            textAlign: updatedConfig.textAlign,
            padding: updatedConfig.padding,
            borderType: updatedConfig.borderType,
            borderColorHex: updatedConfig.borderColorHex,
          );
        },
      ),
    );
  }
}

/// 柱间分隔线配置区域
class _DividerConfigSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerType = cardStyle?.dividerType ?? BorderType.none;
    final dividerColorHex = cardStyle?.dividerColorHex ?? '#D1D5DB';
    final dividerThickness = cardStyle?.dividerThickness ?? 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '柱间分隔线',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '自定义柱与柱之间的分隔线样式',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),

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
            if (value != null) onDividerTypeChanged(value);
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
                onSubmitted: onDividerColorChanged,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 粗细输入
        TextField(
          controller:
              TextEditingController(text: dividerThickness.toStringAsFixed(0)),
          decoration: const InputDecoration(
            labelText: '粗细 (px)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          onSubmitted: (value) {
            final thickness = double.tryParse(value);
            if (thickness != null) {
              onDividerThicknessChanged(thickness);
            }
          },
        ),
      ],
    );
  }

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

/// 行信息管理区域
class _RowConfigSection extends StatelessWidget {
  const _RowConfigSection({
    required this.rowConfigs,
    required this.onRowVisibilityChanged,
    required this.onRowTitleVisibilityChanged,
    required this.onRowOrderChanged,
    required this.onRowStyleEdit,
  });

  final List<RowConfig> rowConfigs;
  final void Function(RowType type, bool isVisible) onRowVisibilityChanged;
  final void Function(RowType type, bool isTitleVisible)
      onRowTitleVisibilityChanged;
  final void Function(int oldIndex, int newIndex) onRowOrderChanged;
  final ValueChanged<RowConfig> onRowStyleEdit;

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
        ...coreRows.map((config) => _CoreRowItem(config: config)),

        const SizedBox(height: 8),

        // 可选行（可拖拽排序）- Task 1.1.4 + 1.1.5
        if (optionalRows.isNotEmpty)
          SizedBox(
            height: 300,
            child: ReorderableListView.builder(
              itemCount: optionalRows.length,
              onReorder: onRowOrderChanged,
              itemBuilder: (context, index) {
                final config = optionalRows[index];
                return _OptionalRowItem(
                  key: ValueKey(config.type),
                  config: config,
                  onVisibilityChanged: (value) =>
                      onRowVisibilityChanged(config.type, value),
                  onTitleVisibilityChanged: (value) =>
                      onRowTitleVisibilityChanged(config.type, value),
                  onEdit: () => onRowStyleEdit(config), // Task 1.1.6
                );
              },
            ),
          ),
      ],
    );
  }
}

/// 核心行 Item（锁定不可编辑）
class _CoreRowItem extends StatelessWidget {
  const _CoreRowItem({required this.config});

  final RowConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      leading: Icon(Icons.lock, size: 18, color: theme.disabledColor),
      title: Text(
        _getRowTypeName(config.type),
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: const Text('核心', style: TextStyle(fontSize: 11)),
      tileColor:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
}

/// 可选行 Item（可见性开关 + 编辑按钮 + 拖拽句柄）
class _OptionalRowItem extends StatelessWidget {
  const _OptionalRowItem({
    super.key,
    required this.config,
    required this.onVisibilityChanged,
    required this.onTitleVisibilityChanged,
    required this.onEdit,
  });

  final RowConfig config;
  final ValueChanged<bool> onVisibilityChanged;
  final ValueChanged<bool> onTitleVisibilityChanged;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      elevation: 0,
      color: config.isVisible
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      child: ListTile(
        dense: true,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_indicator, size: 18, color: theme.hintColor),
            const SizedBox(width: 4),
            Checkbox(
              value: config.isVisible,
              onChanged: (value) => onVisibilityChanged(value ?? false),
            ),
          ],
        ),
        title: Text(_getRowTypeName(config.type)),
        subtitle: config.isVisible
            ? Row(
                children: [
                  Checkbox(
                    value: config.isTitleVisible,
                    onChanged: (value) =>
                        onTitleVisibilityChanged(value ?? false),
                  ),
                  const Text('显示标题', style: TextStyle(fontSize: 11)),
                ],
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          onPressed: config.isVisible ? onEdit : null,
          tooltip: '编辑样式',
        ),
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
      case RowType.xunShou:
        return '旬首';
      case RowType.hiddenStems:
        return '地支藏干';
      case RowType.hiddenStemsTenGod:
        return '藏干十神';
      default:
        return type.name;
    }
  }
}

/// 全局字体设置区域
class _GlobalFontSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontFamily = cardStyle?.globalFontFamily ?? 'NotoSansSC-Regular';
    final fontSize = cardStyle?.globalFontSize ?? 14.0;
    final fontColorHex = cardStyle?.globalFontColorHex ?? '#FF000000';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '全局字体设置',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '设置默认字体样式',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),

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
                value: 'NotoSansSC-Regular', child: Text('NotoSansSC-Regular')),
          ],
          onChanged: (value) {
            if (value != null) onFontFamilyChanged(value);
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
          onChanged: onFontSizeChanged,
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
                onSubmitted: onFontColorChanged,
              ),
            ),
          ],
        ),
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
