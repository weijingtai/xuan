import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';
import '../models/layout_template.dart';

/// 行样式编辑对话框
///
/// 允许用户自定义单行的样式：
/// - 字体家族和字号
/// - 文本颜色
/// - 对齐方式
/// - 边框样式和颜色
/// - 内边距
class RowStyleEditorDialog extends StatefulWidget {
  const RowStyleEditorDialog({
    super.key,
    required this.config,
    required this.onSave,
  });

  final RowConfig config;
  final ValueChanged<RowConfig> onSave;

  @override
  State<RowStyleEditorDialog> createState() => _RowStyleEditorDialogState();
}

class _RowStyleEditorDialogState extends State<RowStyleEditorDialog> {
  // 本地状态：暂存用户编辑
  late String? _selectedFontFamily;
  late double? _selectedFontSize;
  late String? _selectedTextColor;
  late RowTextAlign? _selectedTextAlign;
  late BorderType? _selectedBorderType;
  late String? _selectedBorderColor;
  late double? _selectedPadding;

  @override
  void initState() {
    super.initState();
    // 初始化为当前配置值
    _selectedFontFamily = widget.config.fontFamily;
    _selectedFontSize = widget.config.fontSize;
    _selectedTextColor = widget.config.textColorHex;
    _selectedTextAlign = widget.config.textAlign;
    _selectedBorderType = widget.config.borderType;
    _selectedBorderColor = widget.config.borderColorHex;
    _selectedPadding = widget.config.padding;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '编辑行样式 - ${_getRowTypeName(widget.config.type)}',
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 预览区域
              _PreviewSection(
                rowType: widget.config.type,
                fontFamily: _selectedFontFamily,
                fontSize: _selectedFontSize,
                textColor: _selectedTextColor,
                textAlign: _selectedTextAlign,
                borderType: _selectedBorderType,
                borderColor: _selectedBorderColor,
                padding: _selectedPadding,
              ),

              const Divider(height: 32),

              // Task 1.2.2 - 字体配置选项
              Text('字体设置', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _selectedFontFamily,
                decoration: const InputDecoration(
                  labelText: '字体家族',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('继承全局')),
                  DropdownMenuItem(value: 'NotoSansSC-Regular', child: Text('NotoSansSC-Regular')),
                  DropdownMenuItem(value: 'system', child: Text('系统默认')),
                ],
                onChanged: (value) => setState(() => _selectedFontFamily = value),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Text('字号：${_selectedFontSize?.toInt() ?? '继承'}'),
                  ),
                  if (_selectedFontSize != null)
                    TextButton(
                      onPressed: () => setState(() => _selectedFontSize = null),
                      child: const Text('重置', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
              Slider(
                value: _selectedFontSize ?? 14.0,
                min: 10,
                max: 32,
                divisions: 22,
                label: (_selectedFontSize ?? 14.0).toInt().toString(),
                onChanged: (value) => setState(() => _selectedFontSize = value),
              ),

              const SizedBox(height: 16),

              // Task 1.2.3 - 文本颜色选择器
              Text('文本颜色', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _parseColor(_selectedTextColor),
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: _selectedTextColor ?? ''),
                      decoration: const InputDecoration(
                        labelText: 'Hex 颜色值',
                        hintText: '#FF000000',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) => setState(() => _selectedTextColor = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_selectedTextColor != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      tooltip: '清除（继承全局）',
                      onPressed: () => setState(() => _selectedTextColor = null),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // 预设颜色快捷选择
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ColorChip(color: '#FF000000', label: '黑', onTap: () => setState(() => _selectedTextColor = '#FF000000')),
                  _ColorChip(color: '#FFDC2626', label: '红', onTap: () => setState(() => _selectedTextColor = '#FFDC2626')),
                  _ColorChip(color: '#FF16A34A', label: '绿', onTap: () => setState(() => _selectedTextColor = '#FF16A34A')),
                  _ColorChip(color: '#FF2563EB', label: '蓝', onTap: () => setState(() => _selectedTextColor = '#FF2563EB')),
                  _ColorChip(color: '#FFEAB308', label: '黄', onTap: () => setState(() => _selectedTextColor = '#FFEAB308')),
                ],
              ),

              const SizedBox(height: 16),

              // Task 1.2.4 - 对齐选项
              Text('文本对齐', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SegmentedButton<RowTextAlign>(
                segments: const [
                  ButtonSegment(
                    value: RowTextAlign.left,
                    icon: Icon(Icons.format_align_left, size: 18),
                    label: Text('居左'),
                  ),
                  ButtonSegment(
                    value: RowTextAlign.center,
                    icon: Icon(Icons.format_align_center, size: 18),
                    label: Text('居中'),
                  ),
                  ButtonSegment(
                    value: RowTextAlign.right,
                    icon: Icon(Icons.format_align_right, size: 18),
                    label: Text('居右'),
                  ),
                ],
                selected: {_selectedTextAlign ?? RowTextAlign.center},
                onSelectionChanged: (Set<RowTextAlign> selection) {
                  setState(() => _selectedTextAlign = selection.first);
                },
              ),

              const SizedBox(height: 16),

              // Task 1.2.5 - 边框样式
              Text('边框样式', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              DropdownButtonFormField<BorderType>(
                initialValue: _selectedBorderType ?? BorderType.none,
                decoration: const InputDecoration(
                  labelText: '边框类型',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: BorderType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getBorderTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedBorderType = value),
              ),

              if (_selectedBorderType != null && _selectedBorderType != BorderType.none) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: _selectedBorderColor ?? ''),
                  decoration: const InputDecoration(
                    labelText: '边框颜色 Hex',
                    hintText: '#FFD1D5DB',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _selectedBorderColor = value),
                ),
              ],

              const SizedBox(height: 16),

              // Task 1.2.6 - 内边距
              Text('内边距', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('${_selectedPadding?.toInt() ?? 8} px'),
                  ),
                ],
              ),
              Slider(
                value: _selectedPadding ?? 8.0,
                min: 0,
                max: 24,
                divisions: 24,
                label: (_selectedPadding ?? 8.0).toInt().toString(),
                onChanged: (value) => setState(() => _selectedPadding = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton.icon(
          onPressed: _handleSave,
          icon: const Icon(Icons.check, size: 18),
          label: const Text('保存'),
        ),
      ],
    );
  }

  // Task 1.2.7 - 保存逻辑（待完整实现）
  void _handleSave() {
    final updatedConfig = widget.config.copyWith(
      fontFamily: _selectedFontFamily,
      fontSize: _selectedFontSize,
      textColorHex: _selectedTextColor,
      textAlign: _selectedTextAlign,
      borderType: _selectedBorderType,
      borderColorHex: _selectedBorderColor,
      padding: _selectedPadding,
    );

    widget.onSave(updatedConfig);
    Navigator.of(context).pop();
  }

  String _getRowTypeName(RowType type) {
    switch (type) {
      case RowType.heavenlyStem:
        return '天干';
      case RowType.earthlyBranch:
        return '地支';
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

  Color _parseColor(String? hex) {
    if (hex == null) return Colors.black;
    try {
      final hexColor = hex.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
    } catch (e) {
      // Invalid color
    }
    return Colors.black;
  }
}

/// 颜色快捷选择芯片
class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.color,
    required this.label,
    required this.onTap,
  });

  final String color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          color: _parseColor(color),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: _isLightColor(color) ? Colors.black : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
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
      // Invalid
    }
    return Colors.black;
  }

  bool _isLightColor(String hex) {
    final color = _parseColor(hex);
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5;
  }
}

/// 预览区域 - 实时显示样式效果
class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.rowType,
    this.fontFamily,
    this.fontSize,
    this.textColor,
    this.textAlign,
    this.borderType,
    this.borderColor,
    this.padding,
  });

  final RowType rowType;
  final String? fontFamily;
  final double? fontSize;
  final String? textColor;
  final RowTextAlign? textAlign;
  final BorderType? borderType;
  final String? borderColor;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveFontSize = fontSize ?? 14.0;
    final effectivePadding = padding ?? 8.0;
    final effectiveAlign = _mapTextAlign(textAlign ?? RowTextAlign.center);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('预览效果', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(effectivePadding),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: _buildBorder(theme),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _getSampleText(rowType),
            textAlign: effectiveAlign,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: effectiveFontSize,
              color: _parseColor(textColor),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '示例：${_getSampleText(rowType)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Border? _buildBorder(ThemeData theme) {
    if (borderType == null || borderType == BorderType.none) return null;

    final color = borderColor != null ? _parseColor(borderColor) : theme.dividerColor;

    switch (borderType!) {
      case BorderType.solid:
        return Border.all(color: color);
      case BorderType.dashed:
        return Border.all(color: color, style: BorderStyle.solid); // Flutter 不支持虚线，用实线替代
      case BorderType.dotted:
        return Border.all(color: color, style: BorderStyle.solid);
      case BorderType.none:
        return null;
    }
  }

  TextAlign _mapTextAlign(RowTextAlign align) {
    switch (align) {
      case RowTextAlign.left:
        return TextAlign.left;
      case RowTextAlign.center:
        return TextAlign.center;
      case RowTextAlign.right:
        return TextAlign.right;
    }
  }

  Color _parseColor(String? hex) {
    if (hex == null) return Colors.black;
    try {
      final hexColor = hex.replaceAll('#', '');
      if (hexColor.length == 6) {
        return Color(int.parse('FF$hexColor', radix: 16));
      } else if (hexColor.length == 8) {
        return Color(int.parse(hexColor, radix: 16));
      }
    } catch (e) {
      // Invalid color
    }
    return Colors.black;
  }

  String _getSampleText(RowType type) {
    switch (type) {
      case RowType.heavenlyStem:
        return '甲 乙 丙 丁';
      case RowType.earthlyBranch:
        return '子 丑 寅 卯';
      case RowType.tenGod:
        return '比肩 劫财 食神';
      case RowType.naYin:
        return '海中金';
      case RowType.kongWang:
        return '子丑空';
      case RowType.xunShou:
        return '甲子';
      case RowType.hiddenStems:
        return '癸辛己';
      default:
        return '示例文本';
    }
  }
}
