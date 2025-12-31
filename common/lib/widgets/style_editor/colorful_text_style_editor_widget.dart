import 'package:common/enums/enum_tian_gan.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../const_resources_mapper.dart';
import '../../models/text_style_config.dart';
import '../editable_fourzhu_card/text_groups.dart';
import 'widgets/app_palette_picker_dialog.dart';

// Sentinel RGB used to signal shadow follows character color
const int _kShadowFollowSentinelRGB = 0x00FEED;

// 颜色方案模式：纯色 / 色彩（顶层枚举，避免嵌套在类中）
// enum ColorPreviewMode { pure, colorful }

/// ColorfulTextStyleEditorWidget
/// A reusable editor for adjusting a single `TextStyle` (font family, size,
/// weight, and color). Emits updated styles via `onChanged`.
///
/// Parameters:
/// - [label]: Display name of the style being edited.
/// - [initialStyle]: Optional starting style; falls back to defaults.
/// - [onChanged]: Callback invoked with updated `TextStyle` on any change.
class ColorfulTextStyleEditorWidget extends StatefulWidget {
  final String label;
  final TextStyle? initialStyle;
  final ValueChanged<TextStyle> onChanged;
  // Which group this editor represents (used for per-character callbacks)
  final TextGroup? group;
  // Emit single-character pure color changes to parent for V3 overrides
  final void Function(String char, Color color)? onPerCharPureColorChanged;

  /// 是否仅展示自由色轮（隐藏弹窗按钮与附加信息）。
  final bool onlyWheel;

  /// 是否在“选择颜色”弹窗中启用 Primary/Accent 面板。
  /// 当为 `false` 时，弹窗仅显示色盘（wheel）。
  final bool dialogEnablePrimaryAccent;

  /// 是否在编辑面板中显示内联色盘（ColorPicker）。
  /// 当为 `false` 时，颜色仅通过“选择颜色”弹窗选择。
  final bool showInlineWheel;

  const ColorfulTextStyleEditorWidget({
    super.key,
    required this.label,
    this.initialStyle,
    required this.onChanged,
    this.group,
    this.onPerCharPureColorChanged,
    this.onlyWheel = false,
    this.dialogEnablePrimaryAccent = true,
    this.showInlineWheel = true,
  });

  @override
  State<ColorfulTextStyleEditorWidget> createState() =>
      _ColorfulTextStyleEditorWidgetState();
}

class _ColorfulTextStyleEditorWidgetState
    extends State<ColorfulTextStyleEditorWidget> {
  late String _fontFamily;
  late double _fontSize;
  late FontWeight _fontWeight;
  Color _color = Colors.black87;
  // Key to access the child preview state when present (天干/地支).
  final GlobalKey<_DualThemeColorPreviewState> _previewKey =
      GlobalKey<_DualThemeColorPreviewState>();
  // Shadow configuration state
  bool _shadowEnabled = false;
  Color _shadowColor = const Color(0x55000000);
  double _shadowOffsetX = 0;
  double _shadowOffsetY = 0;
  double _shadowBlurRadius = 0;
  // Shadow color follows character color
  bool _shadowFollowCharColor = false;
  double _shadowOpacity = 0.5;

  String _hex2(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();

  String _formatHex(Color c) {
    return '#${_hex2(c.alpha)}${_hex2(c.red)}${_hex2(c.green)}${_hex2(c.blue)}';
  }

  String _formatRgba(Color c) {
    final a = (c.alpha / 255.0 * 100).round();
    return 'RGBA(${c.red}, ${c.green}, ${c.blue}, ${a}%)';
  }

  String _colorTooltip(Color c) {
    final name = lookupPaletteName(c);
    final body = '${_formatHex(c)} · ${_formatRgba(c)}';
    if (name == null || name.isEmpty) return body;
    return '$name\n$body';
  }

  Widget _withColorTooltip(Color c, Widget child) {
    return ValueListenableBuilder<int>(
      valueListenable: paletteNameIndexVersion,
      builder: (context, _, __) {
        return Tooltip(message: _colorTooltip(c), child: child);
      },
    );
  }

  /// Initialize local editing state from `initialStyle`.
  @override
  void initState() {
    super.initState();
    warmupPaletteNameIndex();
    final s = widget.initialStyle ?? const TextStyle();
    _fontFamily = s.fontFamily ?? '';
    _fontSize = (s.fontSize ?? 14).clamp(8, 64).toDouble();
    _fontWeight = s.fontWeight ?? FontWeight.w400;
    _color = s.color ?? Colors.black87;
    // Initialize shadow state from initialStyle.shadows (single-layer extraction)
    final sh = s.shadows;
    if (sh != null && sh.isNotEmpty) {
      _shadowEnabled = true;
      _shadowColor = sh.first.color;
      _shadowOffsetX = sh.first.offset.dx;
      _shadowOffsetY = sh.first.offset.dy;
      _shadowBlurRadius = sh.first.blurRadius;
    }
    // Detect shadow follow-char sentinel
    final int rgb = _shadowColor.value & 0x00FFFFFF;
    if (rgb == _kShadowFollowSentinelRGB) {
      _shadowFollowCharColor = true;
      _shadowOpacity = _shadowColor.alpha / 255.0;
    } else {
      // 非跟随模式下，透明度与当前阴影颜色的 alpha 同步
      _shadowOpacity = _shadowColor.alpha / 255.0;
    }
  }

  /// Emit the latest edited `TextStyle` via `onChanged`.
  ///
  /// 当用户在 _DualThemeColorPreview 中选择"色彩"模式时，发送 `color: null`，
  /// 以便 V3 Card 使用内置的彩色模式（天干/地支五行颜色）。
  /// 当用户选择"纯色"模式时，发送具体的 `_color` 值。
  void _emit() {
    // 检查 preview 状态是否处于"色彩"模式
    // 注意：如果 previewState 是 null（初始化阶段），根据 initialStyle.color 判断
    // - 如果 initialStyle.color 是 null，默认为彩色模式
    // - 否则使用 _color
    final previewState = _previewKey.currentState;
    final bool isColorfulMode;
    if (previewState != null) {
      isColorfulMode = previewState.mode == ColorPreviewMode.colorful;
    } else {
      // 初始化阶段：如果 _color 是默认值（黑色）且没有明确设置，视为彩色模式
      // 这里我们检查 initialStyle 是否有 color
      final initialColor = widget.initialStyle?.color;
      isColorfulMode = initialColor == null;
    }

    widget.onChanged(TextStyle(
      fontFamily: _fontFamily.isEmpty ? null : _fontFamily,
      fontSize: _fontSize,
      fontWeight: _fontWeight,
      // 🔧 修复：色彩模式时发送 null，让 V3 Card 使用五行颜色
      color: isColorfulMode ? null : _color,
      shadows: _shadowEnabled
          ? [
              Shadow(
                color: _shadowFollowCharColor
                    ? Color((((_shadowOpacity * 255).round()) << 24) |
                        _kShadowFollowSentinelRGB)
                    : _shadowColor,
                offset: Offset(_shadowOffsetX, _shadowOffsetY),
                blurRadius: _shadowBlurRadius,
              ),
            ]
          : null,
    ));
  }

  /// 接收子纯色选择的通知，更新当前颜色并向外发射
  void _onPreviewGlobalPureColorChanged(Color picked) {
    setState(() => _color = picked);
    _emit();
  }

  /// Build the shadow configuration section with enable toggle, color picker,
  /// and sliders for offsetX/offsetY/blurRadius.
  /// Returns a Widget tree rendering the shadow controls.
  Widget _buildShadowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('启用阴影'),
          value: _shadowEnabled,
          onChanged: (v) {
            setState(() => _shadowEnabled = v);
            _emit();
          },
        ),
        if (_shadowEnabled) ...[
          const SizedBox(height: 8),
          // Follow character color for shadow
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('阴影颜色跟随字符颜色'),
            value: _shadowFollowCharColor,
            onChanged: (v) {
              setState(() => _shadowFollowCharColor = v ?? false);
              _emit();
            },
          ),
          if (!_shadowFollowCharColor) ...[
            Row(
              children: [
                const SizedBox(width: 100, child: Text('选择阴影颜色')),
                InkWell(
                  onTap: () async {
                    final picked = await showColorPickerDialog(
                      context,
                      _shadowColor,
                      title: const Text('选择阴影颜色'),
                      pickersEnabled: const {
                        ColorPickerType.wheel: true,
                        ColorPickerType.accent: false,
                        ColorPickerType.primary: false,
                        ColorPickerType.custom: false,
                      },
                    );
                    setState(() {
                      // 保留当前透明度，更新阴影颜色
                      _shadowColor =
                          picked.withAlpha((_shadowOpacity * 255).round());
                    });
                    _emit();
                  },
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _shadowColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          // 阴影透明度（始终可调）
          Row(
            children: [
              const SizedBox(width: 100, child: Text('阴影透明度')),
              Expanded(
                child: Slider(
                  value: _shadowOpacity,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  label: (_shadowOpacity * 100).round().toString(),
                  onChanged: (v) {
                    setState(() {
                      _shadowOpacity = v;
                      if (!_shadowFollowCharColor) {
                        // 非跟随模式下同步 alpha 到阴影颜色本身
                        _shadowColor =
                            _shadowColor.withAlpha((v * 255).round());
                      }
                    });
                    _emit();
                  },
                ),
              ),
              SizedBox(
                  width: 48,
                  child: Text('${(_shadowOpacity * 100).round()}%',
                      textAlign: TextAlign.right)),
            ],
          ),
          const SizedBox(height: 8),
          // Offset X slider
          Row(
            children: [
              const SizedBox(width: 100, child: Text('位移 X')),
              Expanded(
                child: Slider(
                  value: _shadowOffsetX,
                  min: -24,
                  max: 24,
                  onChanged: (v) {
                    setState(() => _shadowOffsetX = v);
                    _emit();
                  },
                ),
              ),
              SizedBox(
                  width: 48,
                  child: Text(_shadowOffsetX.toStringAsFixed(1),
                      textAlign: TextAlign.right)),
            ],
          ),
          // Offset Y slider
          Row(
            children: [
              const SizedBox(width: 100, child: Text('位移 Y')),
              Expanded(
                child: Slider(
                  value: _shadowOffsetY,
                  min: -24,
                  max: 24,
                  onChanged: (v) {
                    setState(() => _shadowOffsetY = v);
                    _emit();
                  },
                ),
              ),
              SizedBox(
                  width: 48,
                  child: Text(_shadowOffsetY.toStringAsFixed(1),
                      textAlign: TextAlign.right)),
            ],
          ),
          // Blur radius slider
          Row(
            children: [
              const SizedBox(width: 100, child: Text('模糊半径')),
              Expanded(
                child: Slider(
                  value: _shadowBlurRadius,
                  min: 0,
                  max: 24,
                  onChanged: (v) {
                    setState(() => _shadowBlurRadius = v);
                    _emit();
                  },
                ),
              ),
              SizedBox(
                  width: 48,
                  child: Text(_shadowBlurRadius.toStringAsFixed(1),
                      textAlign: TextAlign.right)),
            ],
          ),
        ],
      ],
    );
  }

  /// Convert hex string like `#RRGGBB` or `#AARRGGBB` to `Color`.
  /// Returns null if parsing fails.
  Color? _parseHexColor(String input) {
    final s = input.replaceAll('#', '').trim();
    if (s.length == 6) {
      final v = int.tryParse('FF$s', radix: 16);
      if (v != null) return Color(v);
    } else if (s.length == 8) {
      final v = int.tryParse(s, radix: 16);
      if (v != null) return Color(v);
    }
    return null;
  }

  /// 构建彩色文本样式编辑器主界面。
  /// 移除外层 Card 包裹，统一改为 Padding，
  /// 保持垂直间距与内容内边距，避免 Card 带来的溢出与视觉边框。
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                // 字体家族：改为下拉选择，提供“系统”和项目内置字体
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fontFamily.isEmpty ? '' : _fontFamily,
                    decoration: const InputDecoration(
                      labelText: '字体',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('系统')),
                      const DropdownMenuItem(
                          value: 'NotoSansSC-Regular',
                          child: Text('NotoSansSC-Regular')),
                      const DropdownMenuItem(
                          value: 'PingFang SC', child: Text('PingFang SC')),
                      const DropdownMenuItem(
                          value: 'Hiragino Sans GB',
                          child: Text('Hiragino Sans GB')),
                      const DropdownMenuItem(
                          value: 'Noto Sans', child: Text('Noto Sans')),
                      const DropdownMenuItem(
                          value: 'Roboto', child: Text('Roboto')),
                      const DropdownMenuItem(
                          value: 'Segoe UI', child: Text('Segoe UI')),
                      const DropdownMenuItem(
                          value: 'Helvetica Neue',
                          child: Text('Helvetica Neue')),
                      const DropdownMenuItem(
                          value: 'Arial', child: Text('Arial')),
                      const DropdownMenuItem(
                          value: 'Microsoft YaHei',
                          child: Text('Microsoft YaHei')),
                      const DropdownMenuItem(
                          value: 'Ubuntu', child: Text('Ubuntu')),
                      const DropdownMenuItem(
                          value: 'sans-serif', child: Text('sans-serif')),
                    ],
                    onChanged: (value) {
                      setState(() => _fontFamily = (value ?? ''));
                      _emit();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // 字号：改为滑块（8-72），右侧显示当前值
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('字号'),
                          const SizedBox(width: 8),
                          Text('${_fontSize.toInt()}'),
                        ],
                      ),
                      Slider(
                        value: _fontSize.clamp(8, 72),
                        min: 8,
                        max: 72,
                        divisions: 64,
                        label: _fontSize.toInt().toString(),
                        onChanged: (v) {
                          setState(() => _fontSize = v);
                          _emit();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 字重：直观效果展示，去除抽象的 wN00 文案
                DropdownButton<FontWeight>(
                  value: _fontWeight,
                  items: [
                    DropdownMenuItem(
                      value: FontWeight.w300,
                      child: Text('细',
                          style: const TextStyle(fontWeight: FontWeight.w300)),
                    ),
                    DropdownMenuItem(
                      value: FontWeight.w400,
                      child: Text('常规',
                          style: const TextStyle(fontWeight: FontWeight.w400)),
                    ),
                    DropdownMenuItem(
                      value: FontWeight.w500,
                      child: Text('中等',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    DropdownMenuItem(
                      value: FontWeight.w600,
                      child: Text('半粗',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    DropdownMenuItem(
                      value: FontWeight.w700,
                      child: Text('粗体',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                  onChanged: (w) {
                    if (w != null) {
                      setState(() => _fontWeight = w);
                      _emit();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 父类色块已删除，其他逻辑不变
                  ],
                ),
                // 当启用内联色盘时，显示内联色盘；禁用内联色盘时不再显示“文本颜色+选择颜色按钮”行
                if (widget.showInlineWheel) ...[
                  const SizedBox(height: 8),
                  ColorPicker(
                    color: _color,
                    onColorChanged: (Color c) {
                      setState(() => _color = c);
                      _emit();
                    },
                    width: 44,
                    height: 20,
                    borderRadius: 8,
                    wheelDiameter: 180,
                    enableShadesSelection: false,
                    showColorName: false,
                    showMaterialName: false,
                  ),
                  // Preset color palette for quick selection
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in const [
                        Colors.black,
                        Colors.white,
                        Colors.grey,
                        Colors.red,
                        Colors.orange,
                        Colors.yellow,
                        Colors.green,
                        Colors.teal,
                        Colors.blue,
                        Colors.indigo,
                        Colors.purple,
                        Colors.pink,
                        Colors.brown,
                        Colors.cyan,
                      ])
                        InkWell(
                          onTap: () {
                            setState(() => _color = c);
                            _emit();
                          },
                          child: _withColorTooltip(
                            c,
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: c,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                // 将 Light/Dark 预览嵌入对应字体设置卡片（所有分组均显示）
                const SizedBox(height: 12),
                _DualThemeColorPreview(
                  key: _previewKey,
                  group: widget.group ??
                      (() {
                        switch (widget.label) {
                          case '天干':
                            return TextGroup.tianGan;
                          case '地支':
                            return TextGroup.diZhi;
                          case '纳音':
                            return TextGroup.naYin;
                          case '空亡':
                            return TextGroup.kongWang;
                          case '柱标题':
                            return TextGroup.columnTitle;
                          case '行标题':
                          default:
                            return TextGroup.rowTitle;
                        }
                      })(),
                  uniformStyle: TextStyle(
                    fontFamily: _fontFamily.isEmpty ? null : _fontFamily,
                    fontSize: _fontSize,
                    fontWeight: _fontWeight,
                    color: _color,
                    shadows: _shadowEnabled
                        ? [
                            Shadow(
                              color: _shadowFollowCharColor
                                  ? Color(
                                      (((_shadowOpacity * 255).round()) << 24) |
                                          _kShadowFollowSentinelRGB)
                                  : _shadowColor,
                              offset: Offset(_shadowOffsetX, _shadowOffsetY),
                              blurRadius: _shadowBlurRadius,
                            ),
                          ]
                        : null,
                  ),
                  onGlobalPureColorChanged: _onPreviewGlobalPureColorChanged,
                  onPerCharPureColorChanged: widget.onPerCharPureColorChanged,
                ),
                const SizedBox(height: 12),
                // Shadow configuration section
                _buildShadowSection(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// _DualThemeColorPreview
/// Renders a side-by-side preview in Light/Dark themes for a given text group
/// with two bordered rows per area:
/// - Top: uniform color using the provided `uniformStyle`.
/// - Bottom: per-character colors demonstrating different hues per token.
///
/// Parameters:
/// - [group]: Which set of characters to preview (`天干` or `地支`).
/// - [uniformStyle]: The base uniform `TextStyle` to render on the top row.
class _DualThemeColorPreview extends StatefulWidget {
  final TextGroup group;
  final TextStyle uniformStyle;
  final ValueChanged<Color>? onGlobalPureColorChanged;
  final void Function(String char, Color color)? onPerCharPureColorChanged;

  const _DualThemeColorPreview({
    super.key,
    required this.group,
    required this.uniformStyle,
    this.onGlobalPureColorChanged,
    this.onPerCharPureColorChanged,
  });

  @override
  State<_DualThemeColorPreview> createState() => _DualThemeColorPreviewState();
}

class _DualThemeColorPreviewState extends State<_DualThemeColorPreview> {
  ColorPreviewMode _mode = ColorPreviewMode.colorful;
  // 所有字符（根据分组）
  late final List<String> _allChars;
  // 逐字颜色（分别维护 Light 与 Dark 的独立列表）
  late List<Color> _perCharColorsLight;
  late List<Color> _perCharColorsDark;
  // 纯色表格的选中状态（仅用于高亮显示，不改变纯色）
  final Set<int> _pureSelectedLight = <int>{};
  final Set<int> _pureSelectedDark = <int>{};
  // 纯色表格的方块颜色（每侧独立，可点击后修改；上行文本保持纯黑/纯白）
  late List<Color> _pureBlockColorsLight;
  late List<Color> _pureBlockColorsDark;
  // 纯色表格的字符颜色与全局色（每侧独立）。
  late List<Color> _pureCharColorsLight;
  late List<Color> _pureCharColorsDark;
  late Color _pureGlobalColorLight;
  late Color _pureGlobalColorDark;

  String _hex2(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();

  String _formatHex(Color c) {
    return '#${_hex2(c.alpha)}${_hex2(c.red)}${_hex2(c.green)}${_hex2(c.blue)}';
  }

  String _formatRgba(Color c) {
    final a = (c.alpha / 255.0 * 100).round();
    return 'RGBA(${c.red}, ${c.green}, ${c.blue}, ${a}%)';
  }

  String _colorTooltip(Color c) {
    final name = lookupPaletteName(c);
    final body = '${_formatHex(c)} · ${_formatRgba(c)}';
    if (name == null || name.isEmpty) return body;
    return '$name\n$body';
  }

  Widget _withColorTooltip(Color c, Widget child) {
    return ValueListenableBuilder<int>(
      valueListenable: paletteNameIndexVersion,
      builder: (context, _, __) {
        return Tooltip(message: _colorTooltip(c), child: child);
      },
    );
  }

  /// 公开当前颜色模式（纯色/色彩），供父组件访问
  ColorPreviewMode get mode => _mode;

  @override
  void initState() {
    super.initState();
    warmupPaletteNameIndex();
    _allChars = _orderedChars(widget.group);
    final defaults = _allChars.map((ch) => _defaultColorForChar(ch)).toList();
    _perCharColorsLight = List<Color>.from(defaults);
    _perCharColorsDark = List<Color>.from(defaults);
    _pureGlobalColorLight = Colors.black;
    _pureGlobalColorDark = Colors.white;
    _pureBlockColorsLight = List<Color>.filled(
        _allChars.length, _pureGlobalColorLight,
        growable: false);
    _pureBlockColorsDark = List<Color>.filled(
        _allChars.length, _pureGlobalColorDark,
        growable: false);
    _pureCharColorsLight = List<Color>.filled(
        _allChars.length, _pureGlobalColorLight,
        growable: false);
    _pureCharColorsDark = List<Color>.filled(
        _allChars.length, _pureGlobalColorDark,
        growable: false);
  }

  /// Apply a new global pure color from the parent control.
  ///
  /// This updates both Light and Dark sides' global pure colors and
  /// batch-updates any character or block colors that currently match
  /// the respective global color.
  ///
  /// Parameters:
  /// - [picked]: The new color selected from the parent.
  ///
  /// Returns: void
  void applyGlobalPureColorFromParent(Color picked) {
    setState(() {
      // Update Light side
      final Color oldLight = _pureGlobalColorLight;
      for (int i = 0; i < _allChars.length; i++) {
        if (_pureCharColorsLight[i] == oldLight) {
          _pureCharColorsLight[i] = picked;
        }
        if (_pureBlockColorsLight[i] == oldLight) {
          _pureBlockColorsLight[i] = picked;
          _pureSelectedLight.add(i);
        }
      }
      _pureGlobalColorLight = picked;

      // Update Dark side
      final Color oldDark = _pureGlobalColorDark;
      for (int i = 0; i < _allChars.length; i++) {
        if (_pureCharColorsDark[i] == oldDark) {
          _pureCharColorsDark[i] = picked;
        }
        if (_pureBlockColorsDark[i] == oldDark) {
          _pureBlockColorsDark[i] = picked;
          _pureSelectedDark.add(i);
        }
      }
      _pureGlobalColorDark = picked;
    });
  }

  /// Characters by group.
  List<String> _orderedChars(TextGroup g) {
    if (g == TextGroup.tianGan) {
      return const ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    }
    if (g == TextGroup.diZhi) {
      return const ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    }
    // 为其他分组提供简短示例文本，避免空表导致 TableRow 异常
    if (g == TextGroup.naYin) {
      return const ['纳音'];
    }
    if (g == TextGroup.kongWang) {
      return const ['空亡'];
    }
    if (g == TextGroup.columnTitle) {
      return const ['柱标题'];
    }
    if (g == TextGroup.rowTitle) {
      return const ['行标题'];
    }
    return const ['示例'];
  }

  /// Default demo color mapping per character（不随亮暗变化，颜色即为所见）。
  Color _defaultColorForChar(String ch) {
    if (widget.group == TextGroup.tianGan) {
      return ConstResourcesMapper.zodiacGanColors[TianGan.getFromValue(ch)!] ??
          Colors.grey;
    } else {
      return ConstResourcesMapper.zodiacZhiColors[ch] ?? Colors.grey;
    }
  }

  /// 构建两行 N 列表格：上行为文字，下行为色块；每列对应一个字符。
  Widget _twoRowTable(Brightness b) {
    final List<Color> colors =
        b == Brightness.dark ? _perCharColorsDark : _perCharColorsLight;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 使用 Table 保持两行 N 列，不随宽度折行。
          return Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // 上行：文字，颜色与下方色块一致，字体家族与粗细来自 uniformStyle
              TableRow(
                children: [
                  for (int i = 0; i < _allChars.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 4),
                      child: Center(
                        child: Builder(builder: (context) {
                          // Resolve per-character style with shadow color following character color when enabled.
                          TextStyle st = widget.uniformStyle.copyWith(
                            color: colors[i],
                          );
                          if (widget.uniformStyle.shadows != null &&
                              widget.uniformStyle.shadows!.isNotEmpty) {
                            final Shadow sh =
                                widget.uniformStyle.shadows!.first;
                            final int rgb = sh.color.value & 0x00FFFFFF;
                            if (rgb == _kShadowFollowSentinelRGB &&
                                st.color != null) {
                              final int alpha = sh.color.alpha;
                              st = st.copyWith(
                                shadows: [
                                  Shadow(
                                    color: st.color!.withAlpha(alpha),
                                    offset: sh.offset,
                                    blurRadius: sh.blurRadius,
                                  ),
                                ],
                              );
                            }
                          }
                          return Text(_allChars[i], style: st);
                        }),
                      ),
                    ),
                ],
              ),
              // 下行：方形色块，可点击弹出颜色选择器，设置后文字与色块同步更新
              TableRow(
                children: [
                  for (int i = 0; i < _allChars.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 4),
                      child: Center(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showColorPickerDialog(
                              context,
                              colors[i],
                              title: Text('选择颜色 - ${_allChars[i]}'),
                              pickersEnabled: const {
                                ColorPickerType.wheel: true,
                                ColorPickerType.accent: true,
                                ColorPickerType.primary: true,
                                ColorPickerType.custom: false,
                              },
                            );
                            setState(() {
                              if (b == Brightness.dark) {
                                _perCharColorsDark[i] = picked;
                              } else {
                                _perCharColorsLight[i] = picked;
                              }
                            });
                            // 通知父层：彩色模式下某个字符颜色已更新
                            widget.onPerCharPureColorChanged
                                ?.call(_allChars[i], picked);
                          },
                          child: _withColorTooltip(
                            colors[i],
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: colors[i],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// 纯色两行预览表格。支持“全部颜色”批量更新：仅更新当前与“全部色块”一致的字符与色块。
  /// 布局为：顶部“全部颜色”控制，其次上行字符、下行色块，两行 N 列。
  Widget _pureColorTable(Brightness b) {
    final Set<int> selected =
        b == Brightness.dark ? _pureSelectedDark : _pureSelectedLight;
    final List<Color> charColors =
        b == Brightness.dark ? _pureCharColorsDark : _pureCharColorsLight;
    final List<Color> blockColors =
        b == Brightness.dark ? _pureBlockColorsDark : _pureBlockColorsLight;
    final Color global =
        b == Brightness.dark ? _pureGlobalColorDark : _pureGlobalColorLight;
    final bool hasMismatch = charColors.any((c) => c != global) ||
        blockColors.any((c) => c != global);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('纯色：'),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  final picked = await showColorPickerDialog(
                    context,
                    global,
                    title: const Text('选择纯色'),
                    pickersEnabled: const {
                      ColorPickerType.wheel: true,
                      ColorPickerType.accent: true,
                      ColorPickerType.primary: true,
                      ColorPickerType.custom: false,
                    },
                  );
                  // 记录将被更新的索引（旧全局纯色匹配的项）
                  final List<int> changed = <int>[];
                  for (int i = 0; i < _allChars.length; i++) {
                    if (charColors[i] == global || blockColors[i] == global) {
                      changed.add(i);
                    }
                  }
                  setState(() {
                    // 仅批量更新与当前“纯色”一致的项
                    for (int i = 0; i < _allChars.length; i++) {
                      if (charColors[i] == global) {
                        charColors[i] = picked;
                      }
                      if (blockColors[i] == global) {
                        blockColors[i] = picked;
                        selected.add(i);
                      }
                    }
                    if (b == Brightness.dark) {
                      _pureGlobalColorDark = picked;
                    } else {
                      _pureGlobalColorLight = picked;
                    }
                  });
                  // 通知父层同步更新统一颜色并触发 onChanged
                  widget.onGlobalPureColorChanged?.call(picked);
                  // 批量通知父层：所有匹配旧全局纯色的字符更新为新纯色
                  for (final i in changed) {
                    widget.onPerCharPureColorChanged
                        ?.call(_allChars[i], picked);
                  }
                },
                child: _withColorTooltip(
                  global,
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: global,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: hasMismatch
                    ? () {
                        setState(() {
                          for (int i = 0; i < _allChars.length; i++) {
                            charColors[i] = global;
                            blockColors[i] = global;
                            selected.add(i);
                          }
                        });
                        // 批量通知父层：所有字符设为全局纯色
                        for (int i = 0; i < _allChars.length; i++) {
                          widget.onPerCharPureColorChanged
                              ?.call(_allChars[i], global);
                        }
                      }
                    : null,
                child: const Text('强制设置'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  for (int i = 0; i < _allChars.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 4),
                      child: Center(
                        child: Builder(builder: (context) {
                          // Resolve per-character style with shadow color following character color when enabled.
                          TextStyle st = widget.uniformStyle.copyWith(
                            color: charColors[i],
                          );
                          if (widget.uniformStyle.shadows != null &&
                              widget.uniformStyle.shadows!.isNotEmpty) {
                            final Shadow sh =
                                widget.uniformStyle.shadows!.first;
                            final int rgb = sh.color.value & 0x00FFFFFF;
                            if (rgb == _kShadowFollowSentinelRGB &&
                                st.color != null) {
                              final int alpha = sh.color.alpha;
                              st = st.copyWith(
                                shadows: [
                                  Shadow(
                                    color: st.color!.withAlpha(alpha),
                                    offset: sh.offset,
                                    blurRadius: sh.blurRadius,
                                  ),
                                ],
                              );
                            }
                          }
                          return Text(_allChars[i], style: st);
                        }),
                      ),
                    ),
                ],
              ),
              TableRow(
                children: [
                  for (int i = 0; i < _allChars.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 4),
                      child: Center(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showColorPickerDialog(
                              context,
                              blockColors[i],
                              title: Text('选择颜色 - ${_allChars[i]}'),
                              pickersEnabled: const {
                                ColorPickerType.wheel: true,
                                ColorPickerType.accent: true,
                                ColorPickerType.primary: true,
                                ColorPickerType.custom: false,
                              },
                            );
                            setState(() {
                              // 更新该字符的色块与上行字符颜色
                              blockColors[i] = picked;
                              charColors[i] = picked;
                              selected.add(i);
                            });
                            // 通知父层：某个字符的纯色已更新
                            widget.onPerCharPureColorChanged
                                ?.call(_allChars[i], picked);
                          },
                          child: _withColorTooltip(
                            blockColors[i],
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: blockColors[i],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  width: selected.contains(i) ? 2 : 1,
                                  color: selected.contains(i)
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .dividerColor
                                          .withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '系统主题演示（Light / Dark）',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        // 顶部当前选择指示（移除滑块/Tab，采用并排展示）
        Row(
          children: [
            Text(
              '当前选择：${_mode == ColorPreviewMode.pure ? '纯色' : '色彩'}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Row(
          children: [
            // Light 区域
            Expanded(
              child: Theme(
                data: ThemeData.light(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeData.light().colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          Theme.of(context).dividerColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Light',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      // 上下展示两种模式（Light）
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 纯色区块（含边框与选中勾圈）
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (_mode != ColorPreviewMode.pure) {
                                    setState(() {
                                      _mode = ColorPreviewMode.pure;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _mode == ColorPreviewMode.pure
                                          ? Colors.green
                                          : Theme.of(context)
                                              .dividerColor
                                              .withValues(alpha: 0.4),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      _pureColorTable(Brightness.light),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: (_mode == ColorPreviewMode.pure)
                                    ? Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withValues(alpha: 0.4),
                                            width: 2,
                                          ),
                                          color: Colors.transparent,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 色彩区块（含边框与选中勾圈）
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (_mode != ColorPreviewMode.colorful) {
                                    setState(() {
                                      _mode = ColorPreviewMode.colorful;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _mode == ColorPreviewMode.colorful
                                          ? Colors.green
                                          : Theme.of(context)
                                              .dividerColor
                                              .withValues(alpha: 0.4),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      _twoRowTable(Brightness.light),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: (_mode == ColorPreviewMode.colorful)
                                    ? Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withValues(alpha: 0.4),
                                            width: 2,
                                          ),
                                          color: Colors.transparent,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Dark 区域
            Expanded(
              child: Theme(
                data: ThemeData.dark(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeData.dark().colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          Theme.of(context).dividerColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dark',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      // 上下展示两种模式（Dark）
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 纯色区块（含边框与选中勾圈）
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (_mode != ColorPreviewMode.pure) {
                                    setState(() {
                                      _mode = ColorPreviewMode.pure;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _mode == ColorPreviewMode.pure
                                          ? Colors.green
                                          : Theme.of(context)
                                              .dividerColor
                                              .withValues(alpha: 0.4),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      _pureColorTable(Brightness.dark),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: (_mode == ColorPreviewMode.pure)
                                    ? Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withValues(alpha: 0.4),
                                            width: 2,
                                          ),
                                          color: Colors.transparent,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 色彩区块（含边框与选中勾圈）
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (_mode != ColorPreviewMode.colorful) {
                                    setState(() {
                                      _mode = ColorPreviewMode.colorful;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _mode == ColorPreviewMode.colorful
                                          ? Colors.green
                                          : Theme.of(context)
                                              .dividerColor
                                              .withValues(alpha: 0.4),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      _twoRowTable(Brightness.dark),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: (_mode == ColorPreviewMode.colorful)
                                    ? Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withValues(alpha: 0.4),
                                            width: 2,
                                          ),
                                          color: Colors.transparent,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 迁移说明：
// GroupTextStyleEditorPanel 已统一迁移至
// common/lib/widgets/text_style/group_text_style_editor_panel.dart。
// 此文件仅保留具体的 ColorfulTextStyleEditorWidget 等实现，不再导出分组面板组件。
