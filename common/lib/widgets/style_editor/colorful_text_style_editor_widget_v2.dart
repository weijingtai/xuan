import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/text_style_config.dart';
import '../../const_resources_mapper.dart';

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
  final List<String> values;
  // final TextStyle? initialStyle;
  final ValueChanged<TextStyleConfig> onChanged;
  final TextStyleConfig? initialConfig;

  const ColorfulTextStyleEditorV2Enhanced({
    super.key,
    // required this.label,
    required this.type,
    // this.initialStyle,
    required this.onChanged,
    this.initialConfig,
    required this.values,
  });

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

  @override
  void dispose() {
    charPreviewNotifier.dispose();
    shadowDataModelNotifier.dispose();
    _previewCharIndexNotifier.dispose();
    fontStyleDataModelNotifier.dispose();

    super.dispose();
  }

  TextShadowDataModel get defaultShadow => TextShadowDataModel(
        shadowEnabled: false,
        followTextColor: false,
        shadowBlurRadius: 10,
        shadowColor: Colors.black,
        shadowOpacity: 0.65,
        shadowOffsetX: 5.0,
        shadowOffsetY: 5.0,
      );

  /// 纯色模式 - 亮色主题：所有天干都使用黑色
  Map<String, Color> get pureLightMapper {
    return Map.fromEntries(List.generate(
      widget.values.length,
      (i) => MapEntry(widget.values[i], Colors.black87),
    ));
  }

  /// 彩色模式 - 亮色主题：从 ConstResourcesMapper 获取天干颜色
  Map<String, Color> get colorfulLightMapper {
    switch (widget.type) {
      case RowType.heavenlyStem:
        return ConstResourcesMapper.zodiacGanColors.map(
          (key, value) => MapEntry(key.name, value),
        );
      case RowType.earthlyBranch:
        return ConstResourcesMapper.zodiacZhiColors.map(
          (key, value) => MapEntry(key.name, value),
        );
      default:
        return pureLightMapper;
    }
  }

  /// 纯色模式 - 暗色主题：所有天干都使用浅灰色
  Map<String, Color> get pureDarkMapper {
    return Map.fromEntries(List.generate(
      widget.values.length,
      (i) => MapEntry(widget.values[i], Colors.white70),
    ));
  }

  /// 彩色模式 - 暗色主题：从 ConstResourcesMapper 获取天干颜色（与亮色相同）
  Map<String, Color> get colorfulDarkMapper {
    switch (widget.type) {
      case RowType.heavenlyStem:
        return ConstResourcesMapper.zodiacGanColors.map(
          (key, value) => MapEntry(key.name, value),
        );
      case RowType.earthlyBranch:
        return ConstResourcesMapper.zodiacZhiColors.map(
          (key, value) => MapEntry(key.name, value),
        );
      default:
        return pureDarkMapper;
    }
  }

  @override
  void initState() {
    super.initState();
    fontStyleDataModelNotifier = ValueNotifier(FontStyleDataModel(
      fontFamily: 'sans-serif',
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ))
      ..addListener(() => onFontChanged());
    shadowDataModelNotifier = ValueNotifier(defaultShadow)
      ..addListener(() => onFontChanged());
    colorMapperDataModelNotifier = ValueNotifier(
      ColorMapperDataModel(
        pureLightMapper: pureLightMapper,
        colorfulLightMapper: colorfulLightMapper,
        pureDarkMapper: pureDarkMapper,
        colorfulDarkMapper: colorfulDarkMapper,
      ),
    )..addListener(() => onFontChanged());
  }

  void onFontChanged() {
    widget.onChanged(
      TextStyleConfig(
        colorMapperDataModel: colorMapperDataModelNotifier.value,
        textShadowDataModel: shadowDataModelNotifier.value,
        fontStyleDataModel: fontStyleDataModelNotifier.value,
      ),
    );
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
        const Text(
          '字体',
          style: TextStyle(
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
                        'sans-serif'
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
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                fontStyleDataModel.fontSize.toInt().toString(),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                '阴影颜色',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              GestureDetector(
                onTap: () => _pickShadowColor(shadowDataModel.shadowColor),
                child: Container(
                  width: 60,
                  height: 36,
                  decoration: BoxDecoration(
                    color: shadowDataModel.shadowColor,
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
                '不透明度',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  '${(shadowDataModel.shadowOpacity * 100).toInt()}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
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
                  value: shadowDataModel.shadowOffsetX.clamp(-15.0, 15.0),
                  min: -15,
                  max: 15,
                  divisions: 60,
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
                      // gradient: LinearGradient(
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      //   colors: [
                      //     Colors.grey.shade100,
                      //     Colors.grey.shade50,
                      //   ],
                      // ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: ValueListenableBuilder(
                        valueListenable: _previewCharIndexNotifier,
                        builder: (ctx, index, _) {
                          Color shadowColor = shadowDataModel.shadowColor;
                          String char = widget.values.isNotEmpty
                              ? widget.values[index]
                              : '甲';
                          Color textColor = colorMapperDataModel.getBy(
                                  theme: previewInfo.item1,
                                  mode: previewInfo.item2)[char] ??
                              Colors.black87;
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
                                  widget.values.isNotEmpty
                                      ? widget.values[index]
                                      : '甲',
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
                              if (widget.values.isNotEmpty &&
                                  widget.values.length > 1)
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
                                        _previewCharIndexNotifier.value =
                                            (index - 1) % widget.values.length;
                                        if (_previewCharIndexNotifier.value <
                                            0) {
                                          _previewCharIndexNotifier.value =
                                              widget.values.length;
                                        }
                                      },
                                    ),
                                  ),
                                ),

                              // 右侧箭头按钮
                              if (widget.values.isNotEmpty &&
                                  widget.values.length > 1)
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
                                        _previewCharIndexNotifier.value =
                                            (index + 1) % widget.values.length;
                                      },
                                    ),
                                  ),
                                ),

                              // 底部：页码指示器
                              if (widget.values.isNotEmpty &&
                                  widget.values.length > 1)
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
                                        '${index + 1} / ${widget.values.length}',
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
                    value: shadowDataModel.shadowOffsetY.clamp(-15.0, 15.0),
                    min: -15,
                    max: 15,
                    divisions: 60,
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
              '模糊半径',
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
                  value: shadowDataModel.shadowBlurRadius.clamp(0.0, 30.0),
                  min: 0,
                  max: 30,
                  divisions: 60,
                  onChanged: (value) {
                    shadowDataModelNotifier.value =
                        shadowDataModel.copyWith(shadowBlurRadius: value);
                  },
                ),
              ),
            ),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  void _pickShadowColor(Color color) async {
    final result = await showColorPickerDialog(
      context,
      color,
      title: const Text('选择颜色'),
      pickersEnabled: {
        ColorPickerType.wheel: true,
        // ColorPickerType.accent: widget,
        // ColorPickerType.primary: widget.dialogEnablePrimaryAccent,
        ColorPickerType.custom: false,
      },
    );
    shadowDataModelNotifier.value = shadowDataModelNotifier.value
        .copyWith(shadowColor: result, followTextColor: false);
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
        // 天干地支颜色选择
        _buildGanZhiColorPicker(currentTheme),
      ],
    );
  }

  String _getCurrentModeLabel(Brightness currentTheme, ColorPreviewMode mode) {
    // final mode = currentTheme == Brightness.light ? mode : mode;
    return mode == ColorPreviewMode.pure ? '纯色' : '彩色';
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
                ? colorfulLightMapper.entries.first.value // 浅色主题使用"甲"的颜色
                : colorfulDarkMapper.entries.first.value, // 深色主题使用"甲"的颜色
            circleColor: isLight
                ? colorfulLightMapper.entries.first.value // 浅色主题使用"甲"的颜色
                : colorfulDarkMapper.entries.first.value, // 深色主题使用"甲"的颜色
            onTap: () => onModeChanged(ColorPreviewMode.colorful),
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

  Widget _buildGanZhiColorPicker(Brightness currentTheme) {
    List<String> list = widget.values;

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
                Map<String, Color> textColorMapper =
                    mapper.getBy(theme: tuple2.item1, mode: tuple2.item2);
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
                        .map((char) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 天干字符
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
                                // 颜色块
                                GestureDetector(
                                  onTap: () => _pickGanColor(
                                      char,
                                      textColorMapper[char]!,
                                      tuple2.item1,
                                      tuple2.item2),
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: textColorMapper[char],
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: Colors.grey.shade400,
                                          width: 1.5),
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
                            ))
                        .toList(),
                  ),
                );
              });
        });
  }

  void _pickGanColor(String char, Color color, Brightness theme,
      ColorPreviewMode previewMode) async {
    // 简化版颜色选择器
    // final currentColor = (_currentTheme == Brightness.light
    //     ? _perCharColorsLight
    //     : _perCharColorsDark)[char];

    final result = await showColorPickerDialog(
      context,
      color,
      title: const Text('选择颜色'),
      pickersEnabled: {
        ColorPickerType.wheel: true,
        // ColorPickerType.accent: widget,
        // ColorPickerType.primary: widget.dialogEnablePrimaryAccent,
        ColorPickerType.custom: false,
      },
    );
    colorMapperDataModelNotifier.value = colorMapperDataModelNotifier.value
        .update(
            brightness: theme, mode: previewMode, char: char, color: result);
  }
}
