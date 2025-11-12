import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:provider/provider.dart';

import '../../enums/layout_template_enums.dart';
import '../../themes/editable_four_zhu_card_theme.dart';
import '../../viewmodels/four_zhu_card_demo_viewmodel.dart';

/// FourZhuPillarStyleEditorPanel
/// 独立的柱样式编辑器面板，用于编辑四柱卡片的柱样式配置。
///
/// 提供对柱的外边距、内边距、边框、背景色、阴影等样式的编辑控制，
/// 支持实时 `onChanged` 回调用于外部预览绑定。
class FourZhuPillarStyleEditorPanel extends StatefulWidget {
  /// 创建柱样式编辑器面板。
  ///
  /// 参数：
  /// - [theme]: 初始的 `EditableFourZhuCardTheme` 主题对象
  /// - [onChanged]: 主题更新时的回调函数
  const FourZhuPillarStyleEditorPanel({
    super.key,
    required this.theme,
    // required this.onChanged,
  });

  /// 当前编辑的主题状态
  final EditableFourZhuCardTheme theme;

  /// 变更处理器，在任何编辑操作时调用
  // final ValueChanged<EditableFourZhuCardTheme> onChanged;

  @override
  State<FourZhuPillarStyleEditorPanel> createState() =>
      _FourZhuPillarStyleEditorPanelState();
}

class _FourZhuPillarStyleEditorPanelState
    extends State<FourZhuPillarStyleEditorPanel> {
  late EditableFourZhuCardTheme _theme;

  // 柱样式控制变量
  double _pillarDefaultMarginH = 0;
  double _pillarDefaultMarginV = 0;
  double _pillarDefaultPaddingH = 0;
  double _pillarDefaultPaddingV = 0;
  double _pillarBorderWidth = 0;
  double _pillarCornerRadius = 0;
  // 柱阴影控制
  String _pillarShadowHex = '';
  double _pillarShadowOffsetX = 0;
  double _pillarShadowOffsetY = 0;
  double _pillarShadowBlur = 0;
  bool _pillarShadowEnabled = false;
  bool _pillarShadowFollowBackground = false;
  String _pillarBackgroundHex = '';
  String _pillarBorderHex = '';

  @override
  void initState() {
    super.initState();
    _loadFromTheme(widget.theme);
  }

  @override
  void didUpdateWidget(covariant FourZhuPillarStyleEditorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme != widget.theme) {
      _loadFromTheme(widget.theme);
    }
  }

  /// 从主题加载控件值
  void _loadFromTheme(EditableFourZhuCardTheme theme) {
    _theme = theme;
    _pillarDefaultMarginH =
        (_theme.pillar?.defaultMargin?.left ?? 0).toDouble();
    _pillarDefaultMarginV = (_theme.pillar?.defaultMargin?.top ?? 0).toDouble();
    _pillarDefaultPaddingH =
        (_theme.pillar?.defaultPadding?.left ?? 0).toDouble();
    _pillarDefaultPaddingV =
        (_theme.pillar?.defaultPadding?.top ?? 0).toDouble();
    _pillarBorderWidth = (_theme.pillar?.borderWidth ?? 0).toDouble();
    _pillarCornerRadius = (_theme.pillar?.cornerRadius ?? 0).toDouble();
    _pillarShadowHex = _theme.pillar?.shadowColor != null
        ? '#${_theme.pillar!.shadowColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
        : '';
    _pillarShadowEnabled = (_theme.pillar?.shadowColor != null) ||
        (_theme.pillar?.shadowColorFollowsBackground == true);
    _pillarShadowFollowBackground =
        _theme.pillar?.shadowColorFollowsBackground == true;
    _pillarShadowOffsetX = (_theme.pillar?.shadowOffsetX ?? 0).toDouble();
    _pillarShadowOffsetY = (_theme.pillar?.shadowOffsetY ?? 0).toDouble();
    _pillarShadowBlur = (_theme.pillar?.shadowBlurRadius ?? 0).toDouble();
    _pillarBackgroundHex = _theme.pillar?.backgroundColor?.value
                .toRadixString(16)
                .padLeft(8, '0')
                .toUpperCase()
                .startsWith('FF') ==
            true
        ? '#${_theme.pillar!.backgroundColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
        : (_theme.pillar?.backgroundColor != null
            ? '#${_theme.pillar!.backgroundColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
            : '');
    _pillarBorderHex = _theme.pillar?.borderColor?.value
                .toRadixString(16)
                .padLeft(8, '0')
                .toUpperCase()
                .startsWith('FF') ==
            true
        ? '#${_theme.pillar!.borderColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
        : (_theme.pillar?.borderColor != null
            ? '#${_theme.pillar!.borderColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
            : '');
    setState(() {});
  }

  /// 发出新主题
  void _emit(EditableFourZhuCardTheme next) {
    // setState(() => _theme = next);
    // widget.onChanged(next);
    Provider.of<FourZhuCardDemoViewModel>(context, listen: false)
        .updateEditableFourZhuCardTheme(next);
  }

  /// 构建滑块组件
  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(value.toStringAsFixed(0)),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
        const SizedBox(height: 8),
      ],
    );
  }

  /// 统一内边距辅助方法
  EdgeInsets _edgeAll(double v) => EdgeInsets.only(
        left: v,
        top: v,
        right: v,
        bottom: v,
      );

  /// 对称内边距辅助方法
  EdgeInsets _edgeHV(double h, double v) =>
      EdgeInsets.symmetric(horizontal: h, vertical: v);

  /// 解析十六进制颜色
  Color? _parseHexColor(String input) {
    final s = input.trim();
    if (s.isEmpty) return null;
    final hex = s.startsWith('#') ? s.substring(1) : s;
    if (hex.length == 6) {
      final v = int.tryParse(hex, radix: 16);
      if (v == null) return null;
      return Color(0xFF000000 | v);
    } else if (hex.length == 8) {
      final v = int.tryParse(hex, radix: 16);
      if (v == null) return null;
      return Color(v);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 外边距控制
        _buildSlider(
          label: '默认外边距-水平 (px)',
          value: _pillarDefaultMarginH,
          min: 0,
          max: 24,
          onChanged: (v) {
            _pillarDefaultMarginH = v;
            final nextPer = Map<PillarType, EdgeInsets>.of(
                _theme.pillar?.perPillarMargin ?? {});
            _emit(_theme.copyWith(
              pillar: PillarSection(
                defaultMargin:
                    _edgeHV(_pillarDefaultMarginH, _pillarDefaultMarginV),
                defaultPadding:
                    _edgeHV(_pillarDefaultPaddingH, _pillarDefaultPaddingV),
                borderWidth: _pillarBorderWidth,
                borderColor: _theme.pillar?.borderColor,
                cornerRadius: _pillarCornerRadius,
                backgroundColor: _parseHexColor(_pillarBackgroundHex),
                perPillarMargin: nextPer,
                shadowColor: _parseHexColor(_pillarShadowHex),
                shadowOffsetX: _pillarShadowOffsetX,
                shadowOffsetY: _pillarShadowOffsetY,
                shadowBlurRadius: _pillarShadowBlur,
              ),
            ));
          },
        ),
        _buildSlider(
          label: '默认外边距-垂直 (px)',
          value: _pillarDefaultMarginV,
          min: 0,
          max: 24,
          onChanged: (v) {
            _pillarDefaultMarginV = v;
            final nextPer = Map<PillarType, EdgeInsets>.of(
                _theme.pillar?.perPillarMargin ?? {});
            _emit(_theme.copyWith(
              pillar: PillarSection(
                defaultMargin:
                    _edgeHV(_pillarDefaultMarginH, _pillarDefaultMarginV),
                defaultPadding:
                    _edgeHV(_pillarDefaultPaddingH, _pillarDefaultPaddingV),
                borderWidth: _pillarBorderWidth,
                borderColor: _theme.pillar?.borderColor,
                cornerRadius: _pillarCornerRadius,
                backgroundColor: _parseHexColor(_pillarBackgroundHex),
                perPillarMargin: nextPer,
                shadowColor: _parseHexColor(_pillarShadowHex),
                shadowOffsetX: _pillarShadowOffsetX,
                shadowOffsetY: _pillarShadowOffsetY,
                shadowBlurRadius: _pillarShadowBlur,
              ),
            ));
          },
        ),
        // 内边距控制
        _buildSlider(
          label: '默认内边距-水平 (px)',
          value: _pillarDefaultPaddingH,
          min: 0,
          max: 24,
          onChanged: (v) {
            _pillarDefaultPaddingH = v;
            _emit(_theme.copyWith(
              pillar: PillarSection(
                defaultMargin:
                    _edgeHV(_pillarDefaultMarginH, _pillarDefaultMarginV),
                defaultPadding:
                    _edgeHV(_pillarDefaultPaddingH, _pillarDefaultPaddingV),
                borderWidth: _pillarBorderWidth,
                borderColor: _theme.pillar?.borderColor,
                cornerRadius: _pillarCornerRadius,
                backgroundColor: _parseHexColor(_pillarBackgroundHex),
                perPillarMargin: Map<PillarType, EdgeInsets>.of(
                    _theme.pillar?.perPillarMargin ?? {}),
                shadowColor: _parseHexColor(_pillarShadowHex),
                shadowOffsetX: _pillarShadowOffsetX,
                shadowOffsetY: _pillarShadowOffsetY,
                shadowBlurRadius: _pillarShadowBlur,
              ),
            ));
          },
        ),
        _buildSlider(
          label: '默认内边距-垂直 (px)',
          value: _pillarDefaultPaddingV,
          min: 0,
          max: 24,
          onChanged: (v) {
            _pillarDefaultPaddingV = v;
            _emit(_theme.copyWith(
              pillar: PillarSection(
                defaultMargin:
                    _edgeHV(_pillarDefaultMarginH, _pillarDefaultMarginV),
                defaultPadding:
                    _edgeHV(_pillarDefaultPaddingH, _pillarDefaultPaddingV),
                borderWidth: _pillarBorderWidth,
                borderColor: _theme.pillar?.borderColor,
                cornerRadius: _pillarCornerRadius,
                backgroundColor: _parseHexColor(_pillarBackgroundHex),
                perPillarMargin: Map<PillarType, EdgeInsets>.of(
                    _theme.pillar?.perPillarMargin ?? {}),
                shadowColor: _parseHexColor(_pillarShadowHex),
                shadowOffsetX: _pillarShadowOffsetX,
                shadowOffsetY: _pillarShadowOffsetY,
                shadowBlurRadius: _pillarShadowBlur,
              ),
            ));
          },
        ),
        // 边框控制
        _buildSlider(
          label: '边框宽度 (px)',
          value: _pillarBorderWidth,
          min: 0,
          max: 8,
          onChanged: (v) {
            _pillarBorderWidth = v;
            _emit(_theme.copyWith(
              pillar: PillarSection(
                defaultMargin:
                    _edgeHV(_pillarDefaultMarginH, _pillarDefaultMarginV),
                defaultPadding:
                    _edgeHV(_pillarDefaultPaddingH, _pillarDefaultPaddingV),
                borderWidth: v,
                borderColor: _theme.pillar?.borderColor,
                cornerRadius: _pillarCornerRadius,
                backgroundColor: _parseHexColor(_pillarBackgroundHex),
                perPillarMargin: Map<PillarType, EdgeInsets>.of(
                    _theme.pillar?.perPillarMargin ?? {}),
                shadowColor: _pillarShadowEnabled
                    ? _parseHexColor(_pillarShadowHex)
                    : null,
                shadowOffsetX: _pillarShadowOffsetX,
                shadowOffsetY: _pillarShadowOffsetY,
                shadowBlurRadius: _pillarShadowBlur,
              ),
            ));
          },
        ),
        _buildSlider(
          label: '柱圆角 (px)',
          value: _pillarCornerRadius,
          min: 0,
          max: 32,
          onChanged: (v) {
            _pillarCornerRadius = v;
            _emit(_theme.copyWith(
              pillar: PillarSection(
                defaultMargin:
                    _edgeHV(_pillarDefaultMarginH, _pillarDefaultMarginV),
                defaultPadding:
                    _edgeHV(_pillarDefaultPaddingH, _pillarDefaultPaddingV),
                borderWidth: _pillarBorderWidth,
                borderColor: _theme.pillar?.borderColor,
                cornerRadius: _pillarCornerRadius,
                backgroundColor: _parseHexColor(_pillarBackgroundHex),
                perPillarMargin: Map<PillarType, EdgeInsets>.of(
                    _theme.pillar?.perPillarMargin ?? {}),
                shadowColor: _pillarShadowEnabled
                    ? _parseHexColor(_pillarShadowHex)
                    : null,
                shadowOffsetX: _pillarShadowOffsetX,
                shadowOffsetY: _pillarShadowOffsetY,
                shadowBlurRadius: _pillarShadowBlur,
              ),
            ));
          },
        ),
        // 柱背景色控制
        Row(
          children: [
            const Text('柱背景色'),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                final picked = await showColorPickerDialog(
                  context,
                  _parseHexColor(_pillarBackgroundHex) ??
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  title: const Text('选择颜色'),
                  pickersEnabled: const {
                    ColorPickerType.wheel: true,
                    ColorPickerType.accent: false,
                    ColorPickerType.primary: false,
                    ColorPickerType.custom: false,
                  },
                );
                _pillarBackgroundHex =
                    '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                _emit(_theme.copyWith(
                  pillar: PillarSection(
                    defaultMargin:
                        _edgeHV(_pillarDefaultMarginH, _pillarDefaultMarginV),
                    defaultPadding:
                        _edgeHV(_pillarDefaultPaddingH, _pillarDefaultPaddingV),
                    borderWidth: _pillarBorderWidth,
                    borderColor: _parseHexColor(_pillarBorderHex) ??
                        _theme.pillar?.borderColor,
                    cornerRadius: _pillarCornerRadius,
                    backgroundColor: picked,
                    perPillarMargin: Map<PillarType, EdgeInsets>.of(
                        _theme.pillar?.perPillarMargin ?? {}),
                    shadowColor: _pillarShadowEnabled
                        ? _parseHexColor(_pillarShadowHex)
                        : null,
                    shadowOffsetX: _pillarShadowOffsetX,
                    shadowOffsetY: _pillarShadowOffsetY,
                    shadowBlurRadius: _pillarShadowBlur,
                  ),
                ));
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _parseHexColor(_pillarBackgroundHex) ??
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () async {
                final picked = await showColorPickerDialog(
                  context,
                  _parseHexColor(_pillarBackgroundHex) ??
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  title: const Text('选择颜色'),
                  pickersEnabled: const {
                    ColorPickerType.wheel: true,
                    ColorPickerType.accent: false,
                    ColorPickerType.primary: false,
                    ColorPickerType.custom: false,
                  },
                );
                _pillarBackgroundHex =
                    '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                _emit(_theme.copyWith(
                  pillar: PillarSection(
                    defaultMargin:
                        _edgeHV(_pillarDefaultMarginH, _pillarDefaultMarginV),
                    defaultPadding:
                        _edgeHV(_pillarDefaultPaddingH, _pillarDefaultPaddingV),
                    borderWidth: _pillarBorderWidth,
                    borderColor: _parseHexColor(_pillarBorderHex) ??
                        _theme.pillar?.borderColor,
                    cornerRadius: _pillarCornerRadius,
                    backgroundColor: picked,
                    perPillarMargin: Map<PillarType, EdgeInsets>.of(
                        _theme.pillar?.perPillarMargin ?? {}),
                    shadowColor: _pillarShadowEnabled
                        ? _parseHexColor(_pillarShadowHex)
                        : null,
                    shadowOffsetX: _pillarShadowOffsetX,
                    shadowOffsetY: _pillarShadowOffsetY,
                    shadowBlurRadius: _pillarShadowBlur,
                  ),
                ));
              },
              child: const Text('选择颜色'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 柱边框颜色控制
        Row(
          children: [
            const Text('柱边框颜色'),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                final picked = await showColorPickerDialog(
                  context,
                  _parseHexColor(_pillarBorderHex) ??
                      Theme.of(context).dividerColor,
                  title: const Text('选择颜色'),
                  pickersEnabled: const {
                    ColorPickerType.wheel: true,
                    ColorPickerType.accent: false,
                    ColorPickerType.primary: false,
                    ColorPickerType.custom: false,
                  },
                );
                _pillarBorderHex =
                    '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                _emit(_theme.copyWith(
                  pillar: PillarSection(
                    defaultMargin:
                        _edgeHV(_pillarDefaultMarginH, _pillarDefaultMarginV),
                    defaultPadding:
                        _edgeHV(_pillarDefaultPaddingH, _pillarDefaultPaddingV),
                    borderWidth: _pillarBorderWidth,
                    borderColor: picked,
                    cornerRadius: _pillarCornerRadius,
                    backgroundColor: _parseHexColor(_pillarBackgroundHex) ??
                        _theme.pillar?.backgroundColor,
                    perPillarMargin: Map<PillarType, EdgeInsets>.of(
                        _theme.pillar?.perPillarMargin ?? {}),
                    shadowColor: _pillarShadowEnabled
                        ? _parseHexColor(_pillarShadowHex)
                        : null,
                    shadowOffsetX: _pillarShadowOffsetX,
                    shadowOffsetY: _pillarShadowOffsetY,
                    shadowBlurRadius: _pillarShadowBlur,
                  ),
                ));
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _parseHexColor(_pillarBorderHex) ??
                      Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () async {
                final picked = await showColorPickerDialog(
                  context,
                  _parseHexColor(_pillarBorderHex) ??
                      Theme.of(context).dividerColor,
                  title: const Text('选择颜色'),
                  pickersEnabled: const {
                    ColorPickerType.wheel: true,
                    ColorPickerType.accent: false,
                    ColorPickerType.primary: false,
                    ColorPickerType.custom: false,
                  },
                );
                _pillarBorderHex =
                    '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                _emit(_theme.copyWith(
                  pillar: PillarSection(
                    defaultMargin:
                        _edgeHV(_pillarDefaultMarginH, _pillarDefaultMarginV),
                    defaultPadding:
                        _edgeHV(_pillarDefaultPaddingH, _pillarDefaultPaddingV),
                    borderWidth: _pillarBorderWidth,
                    borderColor: picked,
                    cornerRadius: _pillarCornerRadius,
                    backgroundColor: _parseHexColor(_pillarBackgroundHex) ??
                        _theme.pillar?.backgroundColor,
                    perPillarMargin: Map<PillarType, EdgeInsets>.of(
                        _theme.pillar?.perPillarMargin ?? {}),
                    shadowColor: _pillarShadowEnabled
                        ? _parseHexColor(_pillarShadowHex)
                        : null,
                    shadowOffsetX: _pillarShadowOffsetX,
                    shadowOffsetY: _pillarShadowOffsetY,
                    shadowBlurRadius: _pillarShadowBlur,
                  ),
                ));
              },
              child: const Text('选择颜色'),
            ),
          ],
        ),
      ],
    );
  }
}

/// 分区组件
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
