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
  final TextStyle? initialStyle;
  final ValueChanged<TextStyle> onChanged;
  final TextStyleConfig? initialConfig;

  const ColorfulTextStyleEditorV2Enhanced({
    super.key,
    // required this.label,
    required this.type,
    this.initialStyle,
    required this.onChanged,
    this.initialConfig,
    required this.values,
  });

  @override
  State<ColorfulTextStyleEditorV2Enhanced> createState() =>
      _ColorfulTextStyleEditorV2EnhancedState();
}

class ColorMapperDataModel {
  late final Map<String, Color> pureLightMapper;
  late final Map<String, Color> colorfulLightMapper;
  late final Map<String, Color> pureDarkMapper;
  late final Map<String, Color> colorfulDarkMapper;

  ColorMapperDataModel({
    required this.pureLightMapper,
    required this.colorfulLightMapper,
    required this.pureDarkMapper,
    required this.colorfulDarkMapper,
  });
  Map<String, Color> getBy({
    required Brightness theme,
    required ColorPreviewMode mode,
  }) {
    switch (theme) {
      case Brightness.light:
        return mode == ColorPreviewMode.colorful
            ? colorfulLightMapper
            : pureLightMapper;
      case Brightness.dark:
        return mode == ColorPreviewMode.colorful
            ? colorfulDarkMapper
            : pureDarkMapper;
    }
  }

  ColorMapperDataModel update({
    required Brightness brightness,
    required ColorPreviewMode mode,
    required String char,
    required Color color,
  }) {
    // 根据 theme 和 mode 定位对应的 mapper
    final mapper = getBy(theme: brightness, mode: mode);
    // 创建新的 mapper 副本并更新指定 char 的颜色
    final updatedMapper = Map<String, Color>.from(mapper);
    updatedMapper[char] = color;

    // 根据 brightness 和 mode 决定返回哪个字段的新值
    final pureLight =
        brightness == Brightness.light && mode == ColorPreviewMode.pure
            ? updatedMapper
            : pureLightMapper;
    final colorfulLight =
        brightness == Brightness.light && mode == ColorPreviewMode.colorful
            ? updatedMapper
            : colorfulLightMapper;
    final pureDark =
        brightness == Brightness.dark && mode == ColorPreviewMode.pure
            ? updatedMapper
            : pureDarkMapper;
    final colorfulDark =
        brightness == Brightness.dark && mode == ColorPreviewMode.colorful
            ? updatedMapper
            : colorfulDarkMapper;

    return ColorMapperDataModel(
      pureLightMapper: pureLight,
      colorfulLightMapper: colorfulLight,
      pureDarkMapper: pureDark,
      colorfulDarkMapper: colorfulDark,
    );
  }
}

class TextShadowDataModel {
  bool shadowEnabled = false;
  bool followTextColor = false;
  double shadowBlurRadius = 10;
  Color shadowColor = Colors.black;
  double shadowOpacity = 0.65;
  double shadowOffsetX = 5.0; // 默认 X 轴偏移
  double shadowOffsetY = 5.0; // 默认 Y 轴偏移
  TextShadowDataModel({
    this.shadowEnabled = false,
    this.followTextColor = false,
    this.shadowBlurRadius = 10,
    this.shadowColor = Colors.black,
    this.shadowOpacity = 0.65,
    this.shadowOffsetX = 5.0,
    this.shadowOffsetY = 5.0,
  });
  TextShadowDataModel copyWith({
    bool? shadowEnabled,
    bool? followTextColor,
    double? shadowBlurRadius,
    Color? shadowColor,
    double? shadowOpacity,
    double? shadowOffsetX,
    double? shadowOffsetY,
  }) {
    return TextShadowDataModel(
      shadowEnabled: shadowEnabled ?? this.shadowEnabled,
      followTextColor: followTextColor ?? this.followTextColor,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowOpacity: shadowOpacity ?? this.shadowOpacity,
      shadowOffsetX: shadowOffsetX ?? this.shadowOffsetX,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
    );
  }
}

class _ColorfulTextStyleEditorV2EnhancedState
    extends State<ColorfulTextStyleEditorV2Enhanced> {
  // 字体属性
  late String _fontFamily;
  late double _fontSize;
  late FontWeight _fontWeight;
  Color _color = Colors.black87;

  // 阴影属性
  bool _shadowEnabled = false;
  double _shadowBlurRadius = 10;
  Color _shadowColor = Colors.black;
  double _shadowOpacity = 0.65;
  double _shadowOffsetX = 5.0; // 默认 X 轴偏移
  double _shadowOffsetY = 5.0; // 默认 Y 轴偏移

  // 预览字符索引（用于切换显示不同的字符）
  ValueNotifier<int> _previewCharIndexNotifier = ValueNotifier(0);
  // int _previewCharIndex = 0;
  late final ValueNotifier<TextShadowDataModel> shadowDataModelNotifier;
  final ValueNotifier<Tuple2<Brightness, ColorPreviewMode>>
      charPreviewNotifier =
      ValueNotifier(Tuple2(Brightness.light, ColorPreviewMode.colorful));
  // 主题模式
  ColorPreviewMode _lightMode = ColorPreviewMode.colorful;
  ColorPreviewMode _darkMode = ColorPreviewMode.colorful;
  Brightness _currentTheme = Brightness.light; // 改为可变，用于控制下方显示区域的主题

  Color darkBackground = Colors.blueGrey.shade800;
  Color lightBackground = Colors.white;

  // 天干颜色映射（亮色/暗色）
  // late Map<String, Color> _perCharColorsLight;
  // late Map<String, Color> _perCharColorsDark;

  // ==================== 颜色映射 Getters ====================

  @override
  void dispose() {
    charPreviewNotifier.dispose();
    shadowDataModelNotifier.dispose();
    _previewCharIndexNotifier.dispose();
    super.dispose();
  }

  late final ValueNotifier<ColorMapperDataModel> colorMapperDataModelNotifier;
  // late final ValueNotifier<Map<String, Color>> colorfulLightMapperNotifier;
  // late final ValueNotifier<Map<String, Color>> pureDarkMapperNotifier;
  // late final ValueNotifier<Map<String, Color>> colorfulDarkMapperNotifier;

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
    _initializeFromStyle();
    shadowDataModelNotifier = ValueNotifier(defaultShadow);
    colorMapperDataModelNotifier = ValueNotifier(
      ColorMapperDataModel(
        pureLightMapper: pureLightMapper,
        colorfulLightMapper: colorfulLightMapper,
        pureDarkMapper: pureDarkMapper,
        colorfulDarkMapper: colorfulDarkMapper,
      ),
    );
  }

  void _initializeFromStyle() {
    final s = widget.initialStyle ?? const TextStyle();
    _fontFamily = s.fontFamily ?? 'System';
    _fontSize = (s.fontSize ?? 21).clamp(8.0, 64.0);
    _fontWeight = s.fontWeight ?? FontWeight.w400;
    _color = s.color ?? Colors.black87;

    // 初始化阴影
    final sh = s.shadows;
    if (sh != null && sh.isNotEmpty) {
      _shadowEnabled = true;
      final shadow = sh.first;
      _shadowColor = shadow.color;
      _shadowBlurRadius = shadow.blurRadius;
      _shadowOpacity = shadow.color.a;
      // 直接提取 X/Y 偏移
      _shadowOffsetX = shadow.offset.dx;
      _shadowOffsetY = shadow.offset.dy;
    }
  }

  void _emit() {
    final style = TextStyle(
      fontFamily: _fontFamily == 'System' ? null : _fontFamily,
      fontSize: _fontSize,
      fontWeight: _fontWeight,
      color: _currentTheme == Brightness.light &&
              _lightMode == ColorPreviewMode.colorful
          ? null
          : (_currentTheme == Brightness.dark &&
                  _darkMode == ColorPreviewMode.colorful
              ? null
              : _color),
      shadows: _shadowEnabled
          ? [
              Shadow(
                color: _shadowColor.withValues(alpha: _shadowOpacity),
                offset: Offset(_shadowOffsetX, _shadowOffsetY),
                blurRadius: _shadowBlurRadius,
              ),
            ]
          : null,
    );

    widget.onChanged(style);
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
            _buildFontSection(),
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

  Widget _buildFontSection() {
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
                      value: _fontFamily,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['System', 'NotoSansSC-Regular', 'PingFang SC']
                          .map((font) => DropdownMenuItem(
                                value: font,
                                child: Text(font,
                                    style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _fontFamily = value);
                          _emit();
                        }
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
                    child: DropdownButton<FontWeight>(
                      value: _fontWeight,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        FontWeight.w300,
                        FontWeight.w400,
                        FontWeight.w500,
                        FontWeight.w600,
                        FontWeight.w700,
                      ]
                          .map((weight) => DropdownMenuItem(
                                value: weight,
                                child: Text(_fontWeightLabel(weight),
                                    style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _fontWeight = value);
                          _emit();
                        }
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
                  value: _fontSize,
                  min: 8,
                  max: 64,
                  divisions: 56,
                  onChanged: (value) {
                    setState(() => _fontSize = value);
                    _emit();
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
                _fontSize.toInt().toString(),
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
      FontWeight.w300: 'Light',
      FontWeight.w400: 'Regular',
      FontWeight.w500: 'Medium',
      FontWeight.w600: 'SemiBold',
      FontWeight.w700: 'Bold',
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
                  // shadowDataModel.shadowEnabled = value;
                  shadowDataModelNotifier.value =
                      shadowDataModel.copyWith(shadowEnabled: value);
                  // _emit();
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
                      return _buildShadowPreview(shadowDataModel, map, tuple2);
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
                      // setState(() => _shadowOpacity = value);
                      // _emit();
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
      Tuple2<Brightness, ColorPreviewMode> previewInfo) {
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
                    // setState(() => _shadowOffsetX = value);
                    // _emit();
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
                                    fontSize: 32,
                                    // fontWeight: FontWeight.bold,
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
                quarterTurns: 3,
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
                      // setState(() => _shadowOffsetY = value);
                      // _emit();
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
                    // setState(() => _shadowBlurRadius = value);
                    // _emit();
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
    shadowDataModelNotifier.value =
        shadowDataModelNotifier.value.copyWith(shadowColor: result);
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

        // 浅色/深色主题卡片
        Row(
          children: [
            // 浅色卡片
            Expanded(
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
            const SizedBox(width: 12),

            // 深色卡片
            Expanded(
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
        // const SizedBox(height: 20),
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
        : (isLight ? Colors.grey.shade300 : Colors.grey.shade700);
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
            textColor: isLight ? Colors.black87 : Colors.black12, // 纯色选项文字
            circleColor: isLight ? Colors.black87 : Colors.black12, // 纯色选项色块
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
    return Container(
      // elevation: isCurrentTheme ? 3 : 0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // border: BorderSide(
        //   color: isCurrentTheme
        //       ? Colors.blue.shade600
        //       : Theme.of(context).colorScheme.outlineVariant,
        //   width: isCurrentTheme ? 2 : 1,
        // ),
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
        child: Row(
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
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Icon(Icons.check_circle, color: Colors.blue.shade600, size: 18),
            ],
          ],
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

/// 颜色预览模式
enum ColorPreviewMode {
  pure, // 纯色
  colorful, // 彩色（五行颜色）
}
