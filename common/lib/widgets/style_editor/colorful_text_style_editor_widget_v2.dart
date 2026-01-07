import 'package:flutter/material.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/text_style_config.dart';
import 'widgets/app_palette_picker_dialog.dart';

/// ColorfulTextStyleEditorV2Enhanced
///
/// 重新设计的文本样式编辑器（增强版），提供更直观的 UI 布局：
/// - 醒目的蓝色粗边框容器
/// - 紧凑的字体设置区域（字体、字重并排）
/// - 大的阴影预览区域，带可视化角度控制
/// - 清晰的主题切换（浅色/深色分列显示）
/// - 统一的天干地支颜色管理
class ColorfulTextStyleEditorV2Enhanced extends StatefulWidget {
  // final String label;
  final RowType type;
  final List<String>? values;
  final ValueChanged<TextStyleConfig> onChanged;
  final TextStyleConfig initialConfig;
  final ValueNotifier<Brightness>? brightnessNotifier;
  final ValueNotifier<ColorPreviewMode>? colorPreviewModeNotifier;
  final bool enableColorEditing;
  final bool showPureAllConsistentButton;

  final String lable;

  ColorfulTextStyleEditorV2Enhanced({
    super.key,
    required this.type,
    required this.onChanged,
    required TextStyleConfig initialConfig,
    required this.lable,
    this.values,
    this.brightnessNotifier,
    this.colorPreviewModeNotifier,
    this.enableColorEditing = true,
    this.showPureAllConsistentButton = true,
  }) : initialConfig = _normalizeInitialConfig(initialConfig, values);

  static TextStyleConfig _normalizeInitialConfig(
    TextStyleConfig base,
    List<String>? keys,
  ) {
    if (keys == null || keys.isEmpty) return base;
    return base.copyWith(
      colorMapperDataModel: _ensureColorMapperHasKeys(
        base.colorMapperDataModel,
        keys,
      ),
    );
  }

  static ColorMapperDataModel _ensureColorMapperHasKeys(
    ColorMapperDataModel base,
    List<String> keys,
  ) {
    Map<String, Color> ensurePure(
      Map<String, Color> src,
      Color fallback,
    ) {
      final out = Map<String, Color>.from(src);
      for (final k in keys) {
        out.putIfAbsent(k, () => fallback);
      }
      return out;
    }

    Map<String, Color> ensureColorful(
      Map<String, Color> src,
      Map<String, Color> pure,
      Color fallback,
    ) {
      final out = Map<String, Color>.from(src);
      for (final k in keys) {
        out.putIfAbsent(k, () => pure[k] ?? fallback);
      }
      return out;
    }

    final pureLight = ensurePure(base.pureLightMapper, Colors.black87);
    final pureDark = ensurePure(base.pureDarkMapper, Colors.white70);

    return ColorMapperDataModel(
      pureLightMapper: pureLight,
      colorfulLightMapper:
          ensureColorful(base.colorfulLightMapper, pureLight, Colors.black87),
      pureDarkMapper: pureDark,
      colorfulDarkMapper:
          ensureColorful(base.colorfulDarkMapper, pureDark, Colors.white70),
      defaultColor: base.defaultColor,
      blackwhiteLightStrength: base.blackwhiteLightStrength,
      blackwhiteDarkStrength: base.blackwhiteDarkStrength,
    );
  }

  @override
  State<ColorfulTextStyleEditorV2Enhanced> createState() =>
      _ColorfulTextStyleEditorV2EnhancedState();
}

class _ColorfulTextStyleEditorV2EnhancedState
    extends State<ColorfulTextStyleEditorV2Enhanced> {
  late final ValueNotifier<FontStyleDataModel> fontStyleDataModelNotifier;
  late final ValueNotifier<ColorMapperDataModel> colorMapperDataModelNotifier;

  // 预览字符索引（用于切换显示不同的字符）
  final ValueNotifier<int> _previewCharIndexNotifier = ValueNotifier(0);
  // int _previewCharIndex = 0;
  late final ValueNotifier<TextShadowDataModel> shadowDataModelNotifier;
  late final ValueNotifier<Brightness> selectedThemeNotifier;
  late final ValueNotifier<ColorPreviewMode> selectedModeNotifier;
  late final bool _ownsThemeNotifier;
  late final bool _ownsModeNotifier;
  bool _didInitThemeFromSystem = false;
  Color darkBackground = Colors.blueGrey.shade800;
  Color lightBackground = Colors.white;
  bool _bwStrengthLinked = true;

  Color? _pureBatchColorLight;
  Color? _pureBatchColorDark;

  int _chan(double v) => (v * 255.0).round().clamp(0, 255) & 0xff;

  String _hex2(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();

  String _formatHex(Color c) {
    final a = _chan(c.a);
    final r = _chan(c.r);
    final g = _chan(c.g);
    final b = _chan(c.b);
    return '#${_hex2(a)}${_hex2(r)}${_hex2(g)}${_hex2(b)}';
  }

  String _formatRgba(Color c) {
    final a8 = _chan(c.a);
    final r8 = _chan(c.r);
    final g8 = _chan(c.g);
    final b8 = _chan(c.b);
    final aPct = (a8 / 255.0 * 100).round();
    return 'RGBA($r8, $g8, $b8, $aPct%)';
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
        return Tooltip(
          message: _colorTooltip(c),
          child: child,
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ownsThemeNotifier) return;
    if (_didInitThemeFromSystem) return;
    _didInitThemeFromSystem = true;
    selectedThemeNotifier.value = MediaQuery.platformBrightnessOf(context);
  }

  @override
  void dispose() {
    if (_ownsThemeNotifier) {
      selectedThemeNotifier.dispose();
    }
    if (_ownsModeNotifier) {
      selectedModeNotifier.dispose();
    }
    shadowDataModelNotifier.dispose();
    _previewCharIndexNotifier.dispose();
    fontStyleDataModelNotifier.dispose();
    colorMapperDataModelNotifier.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    warmupPaletteNameIndex();
    fontStyleDataModelNotifier =
        ValueNotifier(widget.initialConfig.fontStyleDataModel)
          ..addListener(() => onFontChanged());

    shadowDataModelNotifier = ValueNotifier(
      widget.initialConfig.textShadowDataModel,
    )..addListener(() => onFontChanged());

    colorMapperDataModelNotifier = ValueNotifier(
      widget.initialConfig.colorMapperDataModel,
    )..addListener(() => onFontChanged());

    _ownsThemeNotifier = widget.brightnessNotifier == null;
    selectedThemeNotifier = widget.brightnessNotifier ??
        ValueNotifier<Brightness>(Brightness.light);

    _ownsModeNotifier = widget.colorPreviewModeNotifier == null;
    selectedModeNotifier = widget.colorPreviewModeNotifier ??
        ValueNotifier<ColorPreviewMode>(ColorPreviewMode.colorful);
  }

  Color _firstOrFallback(Map<String, Color> map, Color fallback) {
    if (map.isEmpty) return fallback;
    return map.entries.first.value;
  }

  void onFontChanged() {
    final config = TextStyleConfig(
      colorMapperDataModel: colorMapperDataModelNotifier.value,
      textShadowDataModel: shadowDataModelNotifier.value,
      fontStyleDataModel: fontStyleDataModelNotifier.value,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(config);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade700, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // 标题
            // Center(
            //   child: Text(
            //     widget.label,
            //     style: const TextStyle(
            //       fontSize: 24,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.black87,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 32),

            // 字体 Section
            ValueListenableBuilder<FontStyleDataModel>(
              valueListenable: fontStyleDataModelNotifier,
              builder: (context, fontStyleDataModel, child) {
                return _buildFontSection(fontStyleDataModel);
              },
            ),
            const SizedBox(height: 32),

            // 阴影 Section
            ValueListenableBuilder<TextShadowDataModel>(
              valueListenable: shadowDataModelNotifier,
              builder: (context, value, child) {
                return _buildShadowSection(value);
              },
            ),
            if (widget.enableColorEditing) ...[
              const SizedBox(height: 32),
              ValueListenableBuilder<Brightness>(
                valueListenable: selectedThemeNotifier,
                builder: (context, theme, child) {
                  return ValueListenableBuilder<ColorPreviewMode>(
                    valueListenable: selectedModeNotifier,
                    builder: (context, mode, child) {
                      return _buildThemeSection(theme, mode);
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFontSection(FontStyleDataModel fontStyleDataModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.lable,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // 字体和字重并排
        Row(
          children: [
            // 字体选择
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '字体',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButton<String>(
                      value: fontStyleDataModel.fontFamily,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        'System',
                        'NotoSansSC-Regular',
                        'PingFang SC',
                        'sans-serif',
                      ]
                          .map((font) => DropdownMenuItem(
                                value: font,
                                child: Text(font,
                                    style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        fontStyleDataModelNotifier.value =
                            fontStyleDataModel.copyWith(
                          fontFamily: value,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 字重选择
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '字重',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButton<FontWeight>(
                      value: fontStyleDataModel.fontWeight,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        FontWeight.w100,
                        FontWeight.w200,
                        FontWeight.w300,
                        FontWeight.w400,
                        FontWeight.w500,
                        FontWeight.w600,
                        FontWeight.w700,
                        FontWeight.w800,
                        FontWeight.w900,
                      ]
                          .map((weight) => DropdownMenuItem(
                                value: weight,
                                child: Text(_fontWeightLabel(weight),
                                    style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        fontStyleDataModelNotifier.value =
                            fontStyleDataModel.copyWith(
                          fontWeight: value,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 字号滑块
        Row(
          children: [
            const Text(
              '字号',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.grey.shade300,
                  thumbColor: Colors.blue.shade600,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
                child: Slider(
                  value: fontStyleDataModel.fontSize,
                  min: 8,
                  max: 64,
                  divisions: 56,
                  onChanged: (value) {
                    fontStyleDataModelNotifier.value =
                        fontStyleDataModel.copyWith(
                      fontSize: value,
                    );
                  },
                ),
              ),
            ),
            Container(
              width: 32,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                fontStyleDataModel.fontSize.toInt().toString(),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '行高',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.grey.shade300,
                  thumbColor: Colors.blue.shade600,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
                child: Slider(
                  value: fontStyleDataModel.height * 10,
                  min: 10,
                  max: 20,
                  divisions: 10,
                  onChanged: (value) {
                    fontStyleDataModelNotifier.value =
                        fontStyleDataModel.copyWith(
                      height: value * .1,
                    );
                  },
                ),
              ),
            ),
            Container(
              width: 32,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                fontStyleDataModel.height.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _fontWeightLabel(FontWeight weight) {
    final labels = {
      FontWeight.w100: 'Thin',
      FontWeight.w200: 'ExtraLight',
      FontWeight.w300: 'Light',
      FontWeight.w400: 'Regular',
      FontWeight.w500: 'Medium',
      FontWeight.w600: 'SemiBold',
      FontWeight.w700: 'Bold',
      FontWeight.w800: 'ExtraBold',
      FontWeight.w900: 'Black',
    };
    return labels[weight] ?? 'Regular';
  }

  /// 构建“阴影”设置区。
  /// 功能：开关阴影、展示预览、选择颜色与不透明度。
  /// 返回：用于渲染阴影设置的 Widget。
  Widget _buildShadowSection(TextShadowDataModel shadowDataModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 阴影标题和开关
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '阴影',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Transform.scale(
              scale: 1.2,
              child: Switch(
                value: shadowDataModel.shadowEnabled,
                activeTrackColor: Colors.blue.shade600,
                onChanged: (value) {
                  shadowDataModelNotifier.value =
                      shadowDataModel.copyWith(shadowEnabled: value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (shadowDataModel.shadowEnabled) ...[
          // 阴影预览框（简洁布局）
          ValueListenableBuilder<Brightness>(
            valueListenable: selectedThemeNotifier,
            builder: (ctx, previewTheme, _) {
              return ValueListenableBuilder<ColorPreviewMode>(
                valueListenable: selectedModeNotifier,
                builder: (ctx, previewMode, _) {
                  return ValueListenableBuilder(
                    valueListenable: colorMapperDataModelNotifier,
                    builder: (ctx, map, _) {
                      return ValueListenableBuilder(
                        valueListenable: fontStyleDataModelNotifier,
                        builder: (ctx, style, _) => _buildShadowPreview(
                          shadowDataModel,
                          map,
                          previewTheme,
                          previewMode,
                          style,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          // 收紧间距，减少布局压力
          const SizedBox(height: 16),

          // 阴影颜色
          ValueListenableBuilder<Brightness>(
            valueListenable: selectedThemeNotifier,
            builder: (ctx, theme, _) {
              final isLight = theme == Brightness.light;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '阴影颜色',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  GestureDetector(
                    onTap: () => isLight
                        ? _pickLightShadowColor(
                            shadowDataModel.lightShadowColor)
                        : _pickDarkShadowColor(shadowDataModel.darkShadowColor),
                    child: Container(
                      width: 60,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isLight
                            ? shadowDataModel.lightShadowColor
                            : shadowDataModel.darkShadowColor,
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: Colors.grey.shade400, width: 2),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                '与字体颜色同步',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: shadowDataModelNotifier,
                builder: (ctx, model, _) => Checkbox(
                  value: model.followTextColor,
                  onChanged: (value) {
                    shadowDataModelNotifier.value =
                        model.copyWith(followTextColor: value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  /// 阴影预览与 X/Y 轴控制区（简洁版）。
  /// 功能：顶部 X 轴滑块，中间大预览区域，右侧 Y 轴垂直滑块，底部模糊半径控制。
  /// 返回：用于渲染阴影预览的 Widget。
  Widget _buildShadowPreview(
      TextShadowDataModel shadowDataModel,
      ColorMapperDataModel colorMapperDataModel,
      Brightness previewTheme,
      ColorPreviewMode previewMode,
      FontStyleDataModel fontStyleDataModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部：X 轴滑块
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  activeTrackColor: Colors.grey.shade300,
                  thumbColor: Colors.blue.shade600,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
                child: Slider(
                  value:
                      shadowDataModel.shadowOffsetX.clamp(-5.0, 5.0).toDouble(),
                  min: -5,
                  max: 5,
                  divisions: 10,
                  onChanged: (value) {
                    shadowDataModelNotifier.value =
                        shadowDataModel.copyWith(shadowOffsetX: value);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 中部：预览区域 + Y 轴滑块
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 中间：大预览区域
            Expanded(
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      color: previewTheme == Brightness.light
                          ? lightBackground
                          : darkBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: ValueListenableBuilder(
                        valueListenable: _previewCharIndexNotifier,
                        builder: (ctx, index, _) {
                          final baseShadowColor =
                              previewTheme == Brightness.light
                                  ? shadowDataModel.lightShadowColor
                                  : shadowDataModel.darkShadowColor;
                          final hasValues =
                              (widget.values?.isNotEmpty ?? false);
                          final vals = widget.values ?? const <String>[];
                          final int safeIndex = vals.isNotEmpty
                              ? index.clamp(0, vals.length - 1).toInt()
                              : 0;
                          String char = hasValues ? vals[safeIndex] : '甲';
                          final Color textColor = colorMapperDataModel.getBy(
                            theme: previewTheme,
                            mode: previewMode,
                            content: char,
                          );
                          final shadowColor = shadowDataModel.followTextColor
                              ? textColor.withAlpha(baseShadowColor.a.round())
                              : baseShadowColor;
                          return Stack(
                            children: [
                              // 中间：预览文字
                              Center(
                                child: Text(
                                  hasValues ? vals[safeIndex] : '甲',
                                  style: TextStyle(
                                    fontSize: fontStyleDataModel.fontSize,
                                    // fontWeight: FontWeight.bold,
                                    fontWeight: fontStyleDataModel.fontWeight,
                                    fontFamily: fontStyleDataModel.fontFamily,
                                    color: textColor,
                                    shadows: [
                                      Shadow(
                                        color: shadowColor,
                                        offset: Offset(
                                            shadowDataModel.shadowOffsetX,
                                            shadowDataModel.shadowOffsetY),
                                        blurRadius:
                                            shadowDataModel.shadowBlurRadius,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // 左侧箭头按钮
                              if (hasValues && vals.length > 1)
                                Positioned(
                                  left: 8,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: InkWell(
                                      child: Icon(
                                        Icons.chevron_left,
                                        color: textColor,
                                        size: 28,
                                      ),
                                      onTap: () {
                                        final len = vals.length;
                                        var next = (index - 1) % len;
                                        if (next < 0) next = len - 1;
                                        _previewCharIndexNotifier.value = next;
                                      },
                                    ),
                                  ),
                                ),

                              // 右侧箭头按钮
                              if (hasValues && vals.length > 1)
                                Positioned(
                                  right: 8,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: InkWell(
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: textColor,
                                        size: 28,
                                      ),
                                      onTap: () {
                                        final len = vals.length;
                                        _previewCharIndexNotifier.value =
                                            (index + 1) % len;
                                      },
                                    ),
                                  ),
                                ),

                              // 底部：页码指示器
                              if (hasValues && vals.length > 1)
                                Positioned(
                                  bottom: 8,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: textColor.withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${index + 1} / ${vals.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }))),

            const SizedBox(width: 16),

            // 右侧：Y 轴垂直滑块
            SizedBox(
              height: 200,
              child: RotatedBox(
                quarterTurns: 1,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    activeTrackColor: Colors.grey.shade300,
                    thumbColor: Colors.blue.shade600,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),
                  child: Slider(
                    value: shadowDataModel.shadowOffsetY
                        .clamp(-5.0, 5.0)
                        .toDouble(),
                    min: -5,
                    max: 5,
                    divisions: 10,
                    onChanged: (value) {
                      shadowDataModelNotifier.value =
                          shadowDataModel.copyWith(shadowOffsetY: value);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 底部：模糊半径控制
        Row(
          children: [
            const Text(
              '模糊',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  activeTrackColor: Colors.grey.shade300,
                  thumbColor: Colors.blue.shade600,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
                child: Slider(
                  value: shadowDataModel.shadowBlurRadius
                      .clamp(0.0, 15.0)
                      .toDouble(),
                  min: 0,
                  max: 15,
                  divisions: 15,
                  onChanged: (value) {
                    shadowDataModelNotifier.value = shadowDataModel.copyWith(
                        shadowBlurRadius: value.toInt().toDouble());
                  },
                ),
              ),
            ),
            Container(
              width: 32,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                shadowDataModel.shadowBlurRadius.toInt().toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _pickLightShadowColor(Color color) async {
    final result = await showAppPalettePickerDialog(
      context,
      initialColor: color,
      title: '选择颜色',
    );
    if (result == null) return;
    shadowDataModelNotifier.value = shadowDataModelNotifier.value
        .copyWith(lightShadowColor: result, followTextColor: false);
  }

  void _pickDarkShadowColor(Color color) async {
    final result = await showAppPalettePickerDialog(
      context,
      initialColor: color,
      title: '选择颜色',
    );
    if (result == null) return;
    shadowDataModelNotifier.value = shadowDataModelNotifier.value
        .copyWith(darkShadowColor: result, followTextColor: false);
  }

  Widget _buildThemeSection(Brightness selectedTheme, ColorPreviewMode mode) {
    return ValueListenableBuilder<ColorMapperDataModel>(
      valueListenable: colorMapperDataModelNotifier,
      builder: (context, mapper, _) {
        final pureCircleColor = selectedTheme == Brightness.light
            ? _firstOrFallback(mapper.pureLightMapper, Colors.black87)
            : _firstOrFallback(mapper.pureDarkMapper, Colors.white70);
        final colorfulCircleColor = selectedTheme == Brightness.light
            ? _firstOrFallback(mapper.colorfulLightMapper, Colors.black87)
            : _firstOrFallback(mapper.colorfulDarkMapper, Colors.white70);
        final blackwhiteCircleColor = mapper.getBy(
          theme: selectedTheme,
          mode: ColorPreviewMode.blackwhite,
          content: null,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '主题',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Text(
                    '当前: ${selectedTheme == Brightness.light ? '浅色' : '深色'} · ${_getCurrentModeLabel(mode)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<ColorPreviewMode>(
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: [
                    ButtonSegment<ColorPreviewMode>(
                      value: ColorPreviewMode.pure,
                      icon: _buildModeDot(pureCircleColor),
                      label: const Text('纯色'),
                      tooltip: '纯色',
                    ),
                    ButtonSegment<ColorPreviewMode>(
                      value: ColorPreviewMode.colorful,
                      icon: _buildModeDot(colorfulCircleColor),
                      label: const Text('彩色'),
                      tooltip: '彩色',
                    ),
                    ButtonSegment<ColorPreviewMode>(
                      value: ColorPreviewMode.blackwhite,
                      icon: _buildModeDot(blackwhiteCircleColor),
                      label: const Text('黑白'),
                      tooltip: '黑白',
                    ),
                  ],
                  selected: <ColorPreviewMode>{mode},
                  onSelectionChanged: (values) {
                    if (values.isNotEmpty) {
                      selectedModeNotifier.value = values.first;
                    }
                  },
                ),
                if (_ownsThemeNotifier) ...[
                  const SizedBox(height: 12),
                  SegmentedButton<Brightness>(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: const [
                      ButtonSegment<Brightness>(
                        value: Brightness.light,
                        icon: Icon(Icons.wb_sunny_outlined, size: 16),
                        label: Text('浅色'),
                        tooltip: '浅色',
                      ),
                      ButtonSegment<Brightness>(
                        value: Brightness.dark,
                        icon: Icon(Icons.nightlight_round, size: 16),
                        label: Text('深色'),
                        tooltip: '深色',
                      ),
                    ],
                    selected: <Brightness>{selectedTheme},
                    onSelectionChanged: (values) {
                      if (values.isNotEmpty) {
                        selectedThemeNotifier.value = values.first;
                      }
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            if (mode == ColorPreviewMode.blackwhite)
              _buildBlackwhiteStrengthEditor(selectedTheme),
            if (mode != ColorPreviewMode.blackwhite && widget.values != null)
              _buildGanZhiColorPicker(selectedTheme, mode),
          ],
        );
      },
    );
  }

  Widget _buildModeDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  String _getCurrentModeLabel(ColorPreviewMode mode) {
    switch (mode) {
      case ColorPreviewMode.pure:
        return '纯色';
      case ColorPreviewMode.colorful:
        return '彩色';
      case ColorPreviewMode.blackwhite:
        return '黑白';
    }
  }

  Widget _buildBlackwhiteStrengthEditor(Brightness currentTheme) {
    return ValueListenableBuilder<ColorMapperDataModel>(
      valueListenable: colorMapperDataModelNotifier,
      builder: (ctx, mapper, _) {
        final isLight = currentTheme == Brightness.light;
        final light = mapper.blackwhiteLightStrength.clamp(0.0, 1.0).toDouble();
        final dark = mapper.blackwhiteDarkStrength.clamp(0.0, 1.0).toDouble();
        final lightColor = mapper.getBy(
          theme: Brightness.light,
          mode: ColorPreviewMode.blackwhite,
          content: null,
        );
        final darkColor = mapper.getBy(
          theme: Brightness.dark,
          mode: ColorPreviewMode.blackwhite,
          content: null,
        );

        void write({double? nextLight, double? nextDark}) {
          final nl = (nextLight ?? light).clamp(0.0, 1.0).toDouble();
          final nd = (nextDark ?? dark).clamp(0.0, 1.0).toDouble();
          colorMapperDataModelNotifier.value = ColorMapperDataModel(
            pureLightMapper: mapper.pureLightMapper,
            colorfulLightMapper: mapper.colorfulLightMapper,
            pureDarkMapper: mapper.pureDarkMapper,
            colorfulDarkMapper: mapper.colorfulDarkMapper,
            defaultColor: mapper.defaultColor,
            blackwhiteLightStrength: nl,
            blackwhiteDarkStrength: nd,
          );
        }

        Widget slider({
          required String title,
          required double value,
          required Color preview,
          required ValueChanged<double> onChanged,
        }) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: preview,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(value * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Slider(
                value: value,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                onChanged: onChanged,
              ),
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '黑白深浅（0=灰，1=黑/白）',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Switch(
                    value: _bwStrengthLinked,
                    onChanged: (v) => setState(() => _bwStrengthLinked = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isLight)
                slider(
                  title: '浅色',
                  value: light,
                  preview: lightColor,
                  onChanged: (v) {
                    final s = v.clamp(0.0, 1.0).toDouble();
                    write(nextLight: s, nextDark: _bwStrengthLinked ? s : dark);
                  },
                ),
              if (!isLight)
                slider(
                  title: '深色',
                  value: dark,
                  preview: darkColor,
                  onChanged: (v) {
                    final s = v.clamp(0.0, 1.0).toDouble();
                    write(
                        nextLight: _bwStrengthLinked ? s : light, nextDark: s);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGanZhiColorPicker(Brightness theme, ColorPreviewMode mode) {
    final List<String> list = widget.values!;

    final textColor = theme == Brightness.light ? Colors.black87 : Colors.white;
    final borderColor =
        theme == Brightness.light ? Colors.grey.shade700 : Colors.grey.shade300;

    return ValueListenableBuilder(
        valueListenable: colorMapperDataModelNotifier,
        builder: (ctx, mapper, _) {
          final bgColor =
              theme == Brightness.light ? lightBackground : darkBackground;

          final isPure = mode == ColorPreviewMode.pure;
          final pureBatchColor = !isPure
              ? null
              : (theme == Brightness.light
                  ? (_pureBatchColorLight ??
                      mapper.getBy(
                        theme: theme,
                        mode: ColorPreviewMode.pure,
                        content: null,
                      ))
                  : (_pureBatchColorDark ??
                      mapper.getBy(
                        theme: theme,
                        mode: ColorPreviewMode.pure,
                        content: null,
                      )));
          final hasMismatch = !isPure
              ? false
              : list.any(
                  (char) =>
                      mapper.getBy(
                        theme: theme,
                        mode: ColorPreviewMode.pure,
                        content: char,
                      ) !=
                      pureBatchColor,
                );
          final batchColor = pureBatchColor ?? Colors.transparent;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPure) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '选择色块',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      _withColorTooltip(
                        batchColor,
                        GestureDetector(
                          onTap: () async {
                            final result = await showAppPalettePickerDialog(
                              context,
                              initialColor: batchColor,
                              title: '选择色块',
                            );
                            if (result == null) return;

                            final oldColor = batchColor;
                            var next = mapper;
                            for (final char in list) {
                              final current = mapper.getBy(
                                theme: theme,
                                mode: ColorPreviewMode.pure,
                                content: char,
                              );
                              if (current == oldColor) {
                                next = next.update(
                                  brightness: theme,
                                  mode: ColorPreviewMode.pure,
                                  char: char,
                                  color: result,
                                );
                              }
                            }

                            setState(() {
                              if (theme == Brightness.light) {
                                _pureBatchColorLight = result;
                              } else {
                                _pureBatchColorDark = result;
                              }
                            });
                            colorMapperDataModelNotifier.value = next;
                          },
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: pureBatchColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (widget.showPureAllConsistentButton)
                        TextButton(
                          onPressed: !hasMismatch
                              ? null
                              : () {
                                  var next = mapper;
                                  for (final char in list) {
                                    next = next.update(
                                      brightness: theme,
                                      mode: ColorPreviewMode.pure,
                                      char: char,
                                      color: batchColor,
                                    );
                                  }
                                  colorMapperDataModelNotifier.value = next;
                                },
                          child: const Text('全部一致'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  alignment: WrapAlignment.start,
                  children: list.map((char) {
                    final currentColor = mapper.getBy(
                      theme: theme,
                      mode: mode,
                      content: char,
                    );
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          child: Text(
                            char,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _withColorTooltip(
                          currentColor,
                          GestureDetector(
                            onTap: () => _pickGanColor(
                              char,
                              currentColor,
                              theme,
                              mode,
                            ),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: currentColor,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        });
  }

  void _pickGanColor(String char, Color color, Brightness theme,
      ColorPreviewMode previewMode) async {
    final result = await showAppPalettePickerDialog(
      context,
      initialColor: color,
      title: '选择颜色',
    );

    if (result == null) return;

    colorMapperDataModelNotifier.value = colorMapperDataModelNotifier.value
        .update(
            brightness: theme, mode: previewMode, char: char, color: result);
  }
}
