import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';
import '../models/layout_template.dart';
import '../models/text_style_config.dart';

/// 行样式编辑表单（内嵌版）
///
/// 用途：在 EditorSidebarV2 内直接嵌入行样式编辑，而不是弹窗。
///
/// 功能与 RowStyleEditorDialog 基本一致：
/// - 字体家族与字号
/// - 文本颜色（Hex）与预设色块
/// - 文本对齐（居左/居中/居右）
/// - 边框类型与颜色
/// - 内边距
///
/// 参数：
/// - config: 要编辑的 RowConfig（当前行的样式配置）
/// - onSave: 保存时回调，返回更新后的 RowConfig
class RowStyleEditorForm extends StatefulWidget {
  const RowStyleEditorForm({
    super.key,
    required this.config,
    required this.onSave,
  });

  /// 目标行配置
  final RowConfig config;

  /// 保存回调：传出更新后的 RowConfig
  final ValueChanged<RowConfig> onSave;

  @override
  State<RowStyleEditorForm> createState() => _RowStyleEditorFormState();
}

class _RowStyleEditorFormState extends State<RowStyleEditorForm> {
  // 本地状态：用于在保存前暂存编辑值
  String? _selectedFontFamily;
  double? _selectedFontSize;
  String? _selectedTextColor;
  RowTextAlign? _selectedTextAlign;
  BorderType? _selectedBorderType;
  String? _selectedBorderColor;
  double? _selectedPadding;
  String? _selectedTenGodLabelType;

  @override
  void initState() {
    super.initState();
    _selectedTextAlign = widget.config.textAlign;
    _selectedBorderType = widget.config.borderType;
    _selectedBorderColor = widget.config.borderColorHex;
    _selectedPadding = widget.config.paddingVertical;
    _selectedTenGodLabelType = widget.config.tenGodLabelType;

    final style = widget.config.textStyleConfig;
    _selectedFontFamily = style.fontStyleDataModel.fontFamily;
    _selectedFontSize = style.fontStyleDataModel.fontSize;

    // 尝试解析初始颜色（优先从 Mapper 中获取）
    if (style.colorMapperDataModel.colorfulLightMapper.isNotEmpty) {
      _selectedTextColor = _colorToHex(
          style.colorMapperDataModel.colorfulLightMapper.values.first);
    } else if (style.colorMapperDataModel.pureLightMapper.isNotEmpty) {
      _selectedTextColor =
          _colorToHex(style.colorMapperDataModel.pureLightMapper.values.first);
    } else if (style.colorMapperDataModel.defaultColor != Colors.blueGrey) {
      _selectedTextColor = _colorToHex(style.colorMapperDataModel.defaultColor);
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  bool _isTenGodRow(RowType type) {
    return type == RowType.tenGod ||
        type == RowType.hiddenStemsTenGod ||
        type == RowType.hiddenStemsPrimaryGods ||
        type == RowType.hiddenStemsSecondaryGods ||
        type == RowType.hiddenStemsTertiaryGods;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 样式摘要（快速总览当前设置，未设置显示“继承”）
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryChip(
              icon: Icons.font_download,
              label: '字体',
              value: _selectedFontFamily ?? '继承',
            ),
            _SummaryChip(
              icon: Icons.format_size,
              label: '字号',
              value: _selectedFontSize != null
                  ? '${_selectedFontSize!.toInt()}'
                  : '继承',
            ),
            _SummaryChip(
              icon: Icons.color_lens,
              label: '颜色',
              value: _selectedTextColor ?? '继承',
              colorPreview: _selectedTextColor,
            ),
            _SummaryChip(
              icon: Icons.format_align_center,
              label: '对齐',
              value: _rowTextAlignLabel(_selectedTextAlign),
            ),
            _SummaryChip(
              icon: Icons.crop_square,
              label: '边框',
              value: _getBorderTypeName(_selectedBorderType ?? BorderType.none),
            ),
            _SummaryChip(
              icon: Icons.format_line_spacing,
              label: '内边距',
              value: _selectedPadding != null
                  ? '${_selectedPadding!.toInt()}px'
                  : '继承',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 预览区
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
        const Divider(height: 24),
        if (_isTenGodRow(widget.config.type)) ...[
          Text('标签设置', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'name',
                label: Text('全名(2字)'),
                icon: Icon(Icons.short_text),
              ),
              ButtonSegment(
                value: 'singleName',
                label: Text('简称(1字)'),
                icon: Icon(Icons.text_fields),
              ),
            ],
            selected: {_selectedTenGodLabelType ?? 'name'},
            onSelectionChanged: (s) =>
                setState(() => _selectedTenGodLabelType = s.first),
          ),
          const SizedBox(height: 12),
        ],
        Text('字体设置', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedFontFamily,
                decoration: const InputDecoration(
                  labelText: '字体家族',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('继承全局')),
                  DropdownMenuItem(
                      value: 'NotoSansSC-Regular',
                      child: Text('NotoSansSC-Regular')),
                  DropdownMenuItem(value: 'system', child: Text('系统默认')),
                ],
                onChanged: (v) => setState(() => _selectedFontFamily = v),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '字号：${_selectedFontSize?.toInt() ?? '继承'}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_selectedFontSize != null)
                        TextButton(
                          onPressed: () =>
                              setState(() => _selectedFontSize = null),
                          child:
                              const Text('重置', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  Slider(
                    value: _selectedFontSize ?? 14.0,
                    min: 10,
                    max: 32,
                    divisions: 22,
                    label: (_selectedFontSize ?? 14.0).toInt().toString(),
                    onChanged: (v) => setState(() => _selectedFontSize = v),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('文本颜色', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
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
                controller:
                    TextEditingController(text: _selectedTextColor ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Hex 颜色值',
                  hintText: '#FF000000',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _selectedTextColor = v),
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ColorChip(
                color: '#FFE040FB',
                label: '紫',
                onTap: () => setState(() => _selectedTextColor = '#FFE040FB')),
            _ColorChip(
                color: '#FF000000',
                label: '黑',
                onTap: () => setState(() => _selectedTextColor = '#FF000000')),
            _ColorChip(
                color: '#FFDC2626',
                label: '红',
                onTap: () => setState(() => _selectedTextColor = '#FFDC2626')),
            _ColorChip(
                color: '#FF16A34A',
                label: '绿',
                onTap: () => setState(() => _selectedTextColor = '#FF16A34A')),
            _ColorChip(
                color: '#FF2563EB',
                label: '蓝',
                onTap: () => setState(() => _selectedTextColor = '#FF2563EB')),
            _ColorChip(
                color: '#FFEAB308',
                label: '黄',
                onTap: () => setState(() => _selectedTextColor = '#FFEAB308')),
          ],
        ),
        const SizedBox(height: 12),
        Text('文本对齐', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<RowTextAlign>(
          segments: const [
            ButtonSegment(
                value: RowTextAlign.left,
                icon: Icon(Icons.format_align_left, size: 18),
                label: Text('居左')),
            ButtonSegment(
                value: RowTextAlign.center,
                icon: Icon(Icons.format_align_center, size: 18),
                label: Text('居中')),
            ButtonSegment(
                value: RowTextAlign.right,
                icon: Icon(Icons.format_align_right, size: 18),
                label: Text('居右')),
          ],
          selected: {_selectedTextAlign ?? RowTextAlign.center},
          onSelectionChanged: (s) =>
              setState(() => _selectedTextAlign = s.first),
        ),
        const SizedBox(height: 12),
        Text('边框样式', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<BorderType>(
          value: _selectedBorderType ?? BorderType.none,
          decoration: const InputDecoration(
            labelText: '边框类型',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: BorderType.values
              .map((t) => DropdownMenuItem(
                  value: t, child: Text(_getBorderTypeName(t))))
              .toList(),
          onChanged: (v) => setState(() => _selectedBorderType = v),
        ),
        if (_selectedBorderType != null &&
            _selectedBorderType != BorderType.none) ...[
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: _selectedBorderColor ?? ''),
            decoration: const InputDecoration(
              labelText: '边框颜色 Hex',
              hintText: '#FFD1D5DB',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _selectedBorderColor = v),
          ),
        ],
        const SizedBox(height: 12),
        Text('内边距', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Text('${_selectedPadding?.toInt() ?? 8} px'))
        ]),
        Slider(
          value: _selectedPadding ?? 8.0,
          min: 0,
          max: 24,
          divisions: 24,
          label: (_selectedPadding ?? 8.0).toInt().toString(),
          onChanged: (v) => setState(() => _selectedPadding = v),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: _handleReset,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('重置为继承'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _handleSave,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('保存'),
            ),
          ],
        ),
      ],
    );
  }

  /// 保存当前编辑结果到回调
  ///
  /// 参数：无（使用本地状态）
  /// 返回：void（通过 onSave 回调传递更新后的 RowConfig）
  void _handleSave() {
    final base = widget.config.textStyleConfig;
    final newTextStyleConfig = TextStyleConfig.fromLegacyRowConfig(
      fontFamily: _selectedFontFamily ?? base.fontStyleDataModel.fontFamily,
      fontSize: _selectedFontSize ?? base.fontStyleDataModel.fontSize,
      textColorHex: _selectedTextColor,
    );

    final updated = widget.config.copyWith(
      textStyleConfig: newTextStyleConfig,
      textAlign: _selectedTextAlign,
      borderType: _selectedBorderType,
      borderColorHex: _selectedBorderColor,
      padding: _selectedPadding,
      tenGodLabelType: _selectedTenGodLabelType,
    );
    widget.onSave(updated);
  }

  /// 重置当前编辑为“继承全局”
  ///
  /// 参数：无
  /// 返回：void（仅更新本地状态，不立即保存）
  void _handleReset() {
    setState(() {
      _selectedFontFamily = null;
      _selectedFontSize = null;
      _selectedTextColor = null;
      _selectedTextAlign = null;
      _selectedBorderType = null;
      _selectedBorderColor = null;
      _selectedPadding = null;
      _selectedTenGodLabelType = null;
    });
  }

  /// 将边框类型枚举映射为人类可读名称
  ///
  /// 参数：type 边框类型枚举
  /// 返回：String 对应的中文名称
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
  /// 参数：hex 支持 6 位或 8 位十六进制（可选 # 前缀）
  /// 返回：Color 颜色对象；解析失败时返回黑色
  Color _parseColor(String? hex) {
    if (hex == null) return Colors.black;
    try {
      final h = hex.replaceAll('#', '');
      if (h.length == 6) {
        return Color(int.parse('FF$h', radix: 16));
      } else if (h.length == 8) {
        return Color(int.parse(h, radix: 16));
      }
    } catch (_) {}
    return Colors.black;
  }

  /// 文本对齐枚举的标签映射（用于摘要显示）
  ///
  /// 参数：a 行文本对齐枚举或 null
  /// 返回：String 标签（未设置返回“继承”）
  String _rowTextAlignLabel(RowTextAlign? a) {
    if (a == null) return '继承';
    switch (a) {
      case RowTextAlign.left:
        return '居左';
      case RowTextAlign.center:
        return '居中';
      case RowTextAlign.right:
        return '居右';
    }
  }
}

/// 颜色快捷芯片（与弹窗版一致）
class _ColorChip extends StatelessWidget {
  const _ColorChip(
      {required this.color, required this.label, required this.onTap});
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
      final h = hex.replaceAll('#', '');
      if (h.length == 6) {
        return Color(int.parse('FF$h', radix: 16));
      } else if (h.length == 8) {
        return Color(int.parse(h, radix: 16));
      }
    } catch (_) {}
    return Colors.black;
  }

  bool _isLightColor(String hex) {
    final c = _parseColor(hex);
    final luminance = (0.299 * c.red + 0.587 * c.green + 0.114 * c.blue) / 255;
    return luminance > 0.5;
  }
}

/// 预览区域（与弹窗版一致）
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
    final c =
        borderColor != null ? _parseColor(borderColor) : theme.dividerColor;
    switch (borderType!) {
      case BorderType.solid:
        return Border.all(color: c);
      case BorderType.dashed:
        return Border.all(color: c, style: BorderStyle.solid);
      case BorderType.dotted:
        return Border.all(color: c, style: BorderStyle.solid);
      case BorderType.none:
        return null;
    }
  }

  TextAlign _mapTextAlign(RowTextAlign a) {
    switch (a) {
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
      final h = hex.replaceAll('#', '');
      if (h.length == 6) {
        return Color(int.parse('FF$h', radix: 16));
      } else if (h.length == 8) {
        return Color(int.parse(h, radix: 16));
      }
    } catch (_) {}
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

/// 样式摘要 Chip（用于在展开区域顶部快速展示当前选择）
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    this.colorPreview,
  });

  /// 图标
  final IconData icon;

  /// 标签标题
  final String label;

  /// 当前值（例如 “继承” 或具体数值）
  final String value;

  /// 如果是颜色值，提供一个预览色块
  final String? colorPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.iconTheme.color),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(width: 4),
          if (colorPreview != null)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _parseColor(colorPreview!),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: theme.dividerColor),
              ),
            ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 解析颜色预览值
  Color _parseColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      if (h.length == 6) {
        return Color(int.parse('FF$h', radix: 16));
      } else if (h.length == 8) {
        return Color(int.parse(h, radix: 16));
      }
    } catch (_) {}
    return Colors.black;
  }
}
