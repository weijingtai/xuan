import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../editable_fourzhu_card/text_groups.dart';

// Sentinel RGB used to signal shadow follows character color
const int _kShadowFollowSentinelRGB = 0x00FEED;

// 颜色方案模式相关已移除，统一采用“纯色”模式展示

/// TextStyleEditorWidget
/// A reusable editor for adjusting a single `TextStyle` (font family, size,
/// weight, and color). Emits updated styles via `onChanged`.
///
/// Parameters:
/// - [label]: Display name of the style being edited.
/// - [initialStyle]: Optional starting style; falls back to defaults.
/// - [onChanged]: Callback invoked with updated `TextStyle` on any change.
class TextStyleEditorWidget extends StatefulWidget {
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

  const TextStyleEditorWidget({
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
  State<TextStyleEditorWidget> createState() => _TextStyleEditorWidgetState();
}

class _TextStyleEditorWidgetState extends State<TextStyleEditorWidget> {
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

  /// Initialize local editing state from `initialStyle`.
  @override
  void initState() {
    super.initState();
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
  void _emit() {
    widget.onChanged(TextStyle(
      fontFamily: _fontFamily.isEmpty ? null : _fontFamily,
      fontSize: _fontSize,
      fontWeight: _fontWeight,
      color: _color,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                // 颜色跟随字符已改为阴影颜色跟随字符颜色（移除文本颜色跟随），此处不再显示文本颜色跟随开关
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
                          child: Container(
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
  // 仅保留“纯色”模式，移除色彩模式切换
  // 所有字符（根据分组）
  late final List<String> _allChars;
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

  @override
  void initState() {
    super.initState();
    _allChars = _orderedChars(widget.group);
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
    // 为非逐字分组提供示例文本，避免空表导致 TableRow 异常
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
      switch (ch) {
        case '甲':
        case '乙':
          return Colors.green;
        case '丙':
        case '丁':
          return Colors.red;
        case '戊':
        case '己':
          return Colors.orange;
        case '庚':
        case '辛':
          return Colors.blue;
        case '壬':
        case '癸':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    } else {
      switch (ch) {
        case '子':
          return Colors.indigo;
        case '丑':
          return Colors.brown;
        case '寅':
          return Colors.teal;
        case '卯':
          return Colors.green;
        case '辰':
          return Colors.orange;
        case '巳':
          return Colors.red;
        case '午':
          return Colors.redAccent;
        case '未':
          return Colors.orangeAccent;
        case '申':
          return Colors.blueGrey;
        case '酉':
          return Colors.blue;
        case '戌':
          return Colors.brown;
        case '亥':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    }
  }

  // 色彩模式表格已移除，仅保留纯色预览表格

  /// 纯色两行预览表格。支持“全部颜色”批量更新：仅更新当前与“全部色块”一致的字符与色块。
  /// 布局为：顶部“全部颜色”控制，其次上行字符、下行色块，两行 N 列。
  Widget _pureColorTable(Brightness b) {
    final Color global =
        b == Brightness.dark ? _pureGlobalColorDark : _pureGlobalColorLight;
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
                  setState(() {
                    if (b == Brightness.dark) {
                      _pureGlobalColorDark = picked;
                    } else {
                      _pureGlobalColorLight = picked;
                    }
                  });
                  // 通知父层同步更新统一颜色并触发 onChanged
                  widget.onGlobalPureColorChanged?.call(picked);
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: global,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color:
                          Theme.of(context).dividerColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
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
                      // 仅展示纯色表格（Light）
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _pureColorTable(Brightness.light),
                          ],
                        ),
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
                      // 仅展示纯色表格（Dark）
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _pureColorTable(Brightness.dark),
                          ],
                        ),
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
// 此文件仅保留具体的 TextStyleEditorWidget 等实现，不再导出分组面板组件。
