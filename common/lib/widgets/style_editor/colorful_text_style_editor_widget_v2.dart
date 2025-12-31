import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/text_style_config.dart';
import '../../const_resources_mapper.dart';
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

  final String lable;

  ColorfulTextStyleEditorV2Enhanced({
    super.key,
    required this.type,
    required this.onChanged,
    required TextStyleConfig initialConfig,
    required this.lable,
    this.values,
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
  final ValueNotifier<Tuple2<Brightness, ColorPreviewMode>>
      charPreviewNotifier =
      ValueNotifier(Tuple2(Brightness.light, ColorPreviewMode.colorful));
  Color darkBackground = Colors.blueGrey.shade800;
  Color lightBackground = Colors.white;
  bool _bwStrengthLinked = true;

  @override
  void dispose() {
    charPreviewNotifier.dispose();
    shadowDataModelNotifier.dispose();
    _previewCharIndexNotifier.dispose();
    fontStyleDataModelNotifier.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fontStyleDataModelNotifier =
        ValueNotifier(widget.initialConfig.fontStyleDataModel)
          ..addListener(() => onFontChanged());

    shadowDataModelNotifier = ValueNotifier(
      widget.initialConfig.textShadowDataModel,
    )..addListener(() => onFontChanged());

    colorMapperDataModelNotifier = ValueNotifier(
      widget.initialConfig.colorMapperDataModel,
    )..addListener(() => onFontChanged());
  }

  Color _firstOrFallback(Map<String, Color> map, Color fallback) {
    if (map.isEmpty) return fallback;
    return map.entries.first.value;
  }

  void onFontChanged() {
    print('🔍 [onFontChanged] 开始传播样式变更到父组件');
    final config = TextStyleConfig(
      colorMapperDataModel: colorMapperDataModelNotifier.value,
      textShadowDataModel: shadowDataModelNotifier.value,
      fontStyleDataModel: fontStyleDataModelNotifier.value,
    );
    print(
        '🔍 [onFontChanged] 新 colorMapperDataModel.pureLightMapper 包含 ${config.colorMapperDataModel.pureLightMapper.length} 个颜色');
    print(
        '🔍 [onFontChanged] 新 colorMapperDataModel.colorfulLightMapper 包含 ${config.colorMapperDataModel.colorfulLightMapper.length} 个颜色');
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
            const SizedBox(height: 32),

            // 主题 Section
            ValueListenableBuilder<Tuple2<Brightness, ColorPreviewMode>>(
              valueListenable: charPreviewNotifier,
              builder: (context, value, child) {
                return _buildThemeSection(value.item1, value.item2);
              },
            ),
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
                        'NotoSansSC'
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
          ValueListenableBuilder(
              valueListenable: charPreviewNotifier,
              builder: (ctx, tuple2, _) {
                return ValueListenableBuilder(
                    valueListenable: colorMapperDataModelNotifier,
                    builder: (ctx, map, _) {
                      return ValueListenableBuilder(
                        valueListenable: fontStyleDataModelNotifier,
                        builder: (ctx, style, _) => _buildShadowPreview(
                            shadowDataModel, map, tuple2, style),
                      );
                    });
              }),
          // 收紧间距，减少布局压力
          const SizedBox(height: 16),

          // 阴影颜色
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Light 阴影颜色',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              GestureDetector(
                onTap: () =>
                    _pickLightShadowColor(shadowDataModel.lightShadowColor),
                child: Container(
                  width: 60,
                  height: 36,
                  decoration: BoxDecoration(
                    color: shadowDataModel.lightShadowColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dark 阴影颜色',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              GestureDetector(
                onTap: () =>
                    _pickDarkShadowColor(shadowDataModel.darkShadowColor),
                child: Container(
                  width: 60,
                  height: 36,
                  decoration: BoxDecoration(
                    color: shadowDataModel.darkShadowColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                  ),
                ),
              ),
            ],
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

          // 不透明度
          Row(
            children: [
              const Text(
                '透明度',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.grey.shade300,
                    thumbColor: Colors.blue.shade600,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),
                  child: Slider(
                    value: shadowDataModel.shadowOpacity,
                    min: 0,
                    max: 1,
                    divisions: 100,
                    onChanged: (value) {
                      shadowDataModelNotifier.value =
                          shadowDataModel.copyWith(shadowOpacity: value);
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
                  '${(shadowDataModel.shadowOpacity * 100).toInt()}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
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
      Tuple2<Brightness, ColorPreviewMode> previewInfo,
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
                  value: shadowDataModel.shadowOffsetX
                      .clamp(-5.0, 5.0)
                      .toDouble(),
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
                    duration: Duration(milliseconds: 300),
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      color: previewInfo.item1 == Brightness.light
                          ? lightBackground
                          : darkBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: ValueListenableBuilder(
                        valueListenable: _previewCharIndexNotifier,
                        builder: (ctx, index, _) {
                          Color shadowColor = shadowDataModel.lightShadowColor;
                          final hasValues =
                              (widget.values?.isNotEmpty ?? false);
                          final vals = widget.values ?? const <String>[];
                          final int safeIndex = vals.isNotEmpty
                              ? (index as int)
                                  .clamp(0, vals.length - 1)
                                  .toInt()
                              : 0;
                          String char = hasValues ? vals[safeIndex] : '甲';
                          final Color textColor = colorMapperDataModel.getBy(
                            theme: previewInfo.item1,
                            mode: previewInfo.item2,
                            content: char,
                          );
                          if (shadowDataModel.followTextColor) {
                            shadowColor = textColor;
                          }
                          shadowColor = shadowColor.withAlpha(
                              (shadowDataModel.shadowOpacity * 255).toInt());
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
                                        var next = ((index as int) - 1) % len;
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
                                            ((index as int) + 1) % len;
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
                                        '${(index as int) + 1} / ${vals.length}',
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

  Widget _buildThemeSection(Brightness currentTheme, ColorPreviewMode mode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主题标题
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Text(
                '当前: ${_getCurrentModeLabel(currentTheme, mode)}',
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

        // 浅色/深色主题卡片（使用 Wrap 保证在窄屏下自动换行，避免 Row 溢出）
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 320,
              child: _buildThemeCardV2(
                title: '浅色',
                isLight: true,
                isCurrentTheme: currentTheme == Brightness.light,
                mode: mode,
                onModeChanged: (m) {
                  charPreviewNotifier.value = Tuple2(Brightness.light, m);
                },
              ),
            ),
            SizedBox(
              width: 320,
              child: _buildThemeCardV2(
                title: '深色',
                isLight: false,
                isCurrentTheme: currentTheme == Brightness.dark,
                mode: mode,
                onModeChanged: (m) {
                  charPreviewNotifier.value = Tuple2(Brightness.dark, m);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (mode == ColorPreviewMode.blackwhite) _buildBlackwhiteStrengthEditor(),
        if (mode != ColorPreviewMode.blackwhite && widget.values != null)
          _buildGanZhiColorPicker(currentTheme),
      ],
    );
  }

  String _getCurrentModeLabel(Brightness currentTheme, ColorPreviewMode mode) {
    switch (mode) {
      case ColorPreviewMode.pure:
        return '纯色';
      case ColorPreviewMode.colorful:
        return '彩色';
      case ColorPreviewMode.blackwhite:
        return '黑白';
    }
  }

  Widget _buildThemeCard({
    required String title,
    required bool isLight,
    required bool isCurrentTheme,
    required ColorPreviewMode mode,
    required ValueChanged<ColorPreviewMode> onModeChanged,
  }) {
    final bgColor = isLight ? lightBackground : darkBackground;
    final textColor = isLight ? Colors.black87 : Colors.white;
    // 当前选中的主题卡片使用蓝色边框，否则使用灰色边框
    final borderColor = isCurrentTheme
        ? Colors.blue.shade600
        : Theme.of(context).colorScheme.outlineVariant;
    final borderWidth = isCurrentTheme ? 3.0 : 2.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: isCurrentTheme
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: isCurrentTheme ? 8 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (isCurrentTheme)
                Icon(
                  Icons.radio_button_checked,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 纯色选项
          _buildModeOption(
            label: '纯色',
            isSelected: mode == ColorPreviewMode.pure,
            textColor: isLight ? Colors.black87 : Colors.white, // 纯色选项文字
            circleColor: isLight ? Colors.black87 : Colors.white, // 纯色选项色块
            onTap: () => onModeChanged(ColorPreviewMode.pure),
          ),
          const SizedBox(height: 10),

          // 彩色选项
          _buildModeOption(
            label: '彩色',
            isSelected: mode == ColorPreviewMode.colorful,
            textColor: isLight
                ? _firstOrFallback(
                    colorMapperDataModelNotifier.value.pureLightMapper,
                    Colors.black87,
                  )
                : _firstOrFallback(
                    colorMapperDataModelNotifier.value.pureDarkMapper,
                    Colors.white,
                  ),
            circleColor: isLight
                ? _firstOrFallback(
                    colorMapperDataModelNotifier.value.colorfulLightMapper,
                    Colors.black87,
                  )
                : _firstOrFallback(
                    colorMapperDataModelNotifier.value.colorfulDarkMapper,
                    Colors.white,
                  ),
            onTap: () => onModeChanged(ColorPreviewMode.colorful),
          ),
          const SizedBox(height: 10),
          _buildModeOption(
            label: '黑白',
            isSelected: mode == ColorPreviewMode.blackwhite,
            textColor: colorMapperDataModelNotifier.value.getBy(
              theme: isLight ? Brightness.light : Brightness.dark,
              mode: ColorPreviewMode.blackwhite,
              content: null,
            ),
            circleColor: colorMapperDataModelNotifier.value.getBy(
              theme: isLight ? Brightness.light : Brightness.dark,
              mode: ColorPreviewMode.blackwhite,
              content: null,
            ),
            onTap: () => onModeChanged(ColorPreviewMode.blackwhite),
          ),
        ],
      ),
    );
  }

  /// 构建卡片样式的主题选择项（包装版）。
  /// 功能：为原有的 `_buildThemeCard` 增加 Card 外观（圆角、描边、阴影）
  /// 参数：
  /// - [title] 标题文案（如“浅色”、“深色”）
  /// - [isLight] 是否浅色主题预览
  /// - [isCurrentTheme] 是否为当前选中的主题，用于高亮
  /// - [mode] 当前颜色预览模式
  /// - [onModeChanged] 切换预览模式时的回调
  /// 返回：卡片样式的主题选择 Widget
  Widget _buildThemeCardV2({
    required String title,
    required bool isLight,
    required bool isCurrentTheme,
    required ColorPreviewMode mode,
    required ValueChanged<ColorPreviewMode> onModeChanged,
  }) {
    // 包装为卡片外观：圆角与主题描边，选中态提升层次
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentTheme
              ? Colors.blue.shade600
              : Theme.of(context).colorScheme.outlineVariant,
          width: isCurrentTheme ? 2 : 1,
        ),
      ),
      child: _buildThemeCard(
        title: title,
        isLight: isLight,
        isCurrentTheme: isCurrentTheme,
        mode: mode,
        onModeChanged: onModeChanged,
      ),
    );
  }

  Widget _buildModeOption({
    required String label,
    required bool isSelected,
    required Color textColor,
    required Color circleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Colors.blue.shade50.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        // 防溢出：当父约束过窄时整体按比例缩放；常规宽度保持原样
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle, color: Colors.blue.shade600, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlackwhiteStrengthEditor() {
    return ValueListenableBuilder<ColorMapperDataModel>(
      valueListenable: colorMapperDataModelNotifier,
      builder: (ctx, mapper, _) {
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
              slider(
                title: '浅色',
                value: light,
                preview: lightColor,
                onChanged: (v) {
                  final s = v.clamp(0.0, 1.0).toDouble();
                  write(nextLight: s, nextDark: _bwStrengthLinked ? s : dark);
                },
              ),
              const SizedBox(height: 12),
              slider(
                title: '深色',
                value: dark,
                preview: darkColor,
                onChanged: (v) {
                  final s = v.clamp(0.0, 1.0).toDouble();
                  write(nextLight: _bwStrengthLinked ? s : light, nextDark: s);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGanZhiColorPicker(Brightness currentTheme) {
    final List<String> list = widget.values!;

    final textColor =
        currentTheme == Brightness.light ? Colors.black87 : Colors.white;
    final borderColor = currentTheme == Brightness.light
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    return ValueListenableBuilder(
        valueListenable: colorMapperDataModelNotifier,
        builder: (ctx, mapper, _) {
          return ValueListenableBuilder(
              valueListenable: charPreviewNotifier,
              builder: (ctx, tuple2, _) {
                final bgColor = tuple2.item1 == Brightness.light
                    ? lightBackground
                    : darkBackground;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    alignment: WrapAlignment.start,
                    children: list
                        .map((char) {
                          final currentColor = mapper.getBy(
                            theme: tuple2.item1,
                            mode: tuple2.item2,
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
                              GestureDetector(
                                onTap: () => _pickGanColor(
                                  char,
                                  currentColor,
                                  tuple2.item1,
                                  tuple2.item2,
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
                            ],
                          );
                        })
                        .toList(),
                  ),
                );
              });
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
        .update(brightness: theme, mode: previewMode, char: char, color: result);
  }
}