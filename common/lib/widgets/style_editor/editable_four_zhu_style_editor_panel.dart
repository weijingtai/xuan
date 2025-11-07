import 'package:flutter/material.dart';

import '../../enums/layout_template_enums.dart';
import '../../themes/editable_four_zhu_card_theme.dart';

/// EditableFourZhuStyleEditorPanel
/// Lightweight editor panel for `EditableFourZhuCardTheme`.
///
/// Provides grouped controls to edit Card, Pillar, and Typography sections,
/// with real-time `onChanged` emissions for external preview binding.
class EditableFourZhuStyleEditorPanel extends StatefulWidget {
  /// Creates an editor panel for the given theme.
  ///
  /// Parameters:
  /// - [theme]: Initial `EditableFourZhuCardTheme` to edit.
  /// - [onChanged]: Callback invoked whenever the theme is updated.
  const EditableFourZhuStyleEditorPanel({
    super.key,
    required this.theme,
    required this.onChanged,
  });

  /// Current theme state displayed by the panel.
  final EditableFourZhuCardTheme theme;

  /// Change handler invoked on any edit.
  final ValueChanged<EditableFourZhuCardTheme> onChanged;

  @override
  State<EditableFourZhuStyleEditorPanel> createState() =>
      _EditableFourZhuStyleEditorPanelState();
}

class _EditableFourZhuStyleEditorPanelState
    extends State<EditableFourZhuStyleEditorPanel> {
  late EditableFourZhuCardTheme _theme;

  // Cached scalar controls for convenience (uniform values)
  double _cardPadding = 0;
  double _cardCornerRadius = 8;
  double _pillarDefaultMarginH = 0;
  double _pillarDefaultMarginV = 0;
  double _pillarDefaultPaddingH = 0;
  double _pillarDefaultPaddingV = 0;
  double _pillarBorderWidth = 0;
  double _pillarCornerRadius = 0;
  String _pillarBackgroundHex = '';
  String _globalFontFamily = '';
  double _globalFontSize = 14;
  String _preferredFamiliesText = '';

  // 分组字符设计功能已移除

  @override
  void initState() {
    super.initState();
    _loadFromTheme(widget.theme);
  }

  @override
  void didUpdateWidget(covariant EditableFourZhuStyleEditorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme != widget.theme) {
      _loadFromTheme(widget.theme);
    }
  }

  /// Loads slider/textfield states from the theme.
  void _loadFromTheme(EditableFourZhuCardTheme theme) {
    _theme = theme;
    _cardPadding = (_theme.card?.padding?.left ?? 0).toDouble();
    _cardCornerRadius = (_theme.card?.cornerRadius ?? 8).toDouble();
    _pillarDefaultMarginH =
        (_theme.pillar?.defaultMargin?.left ?? 0).toDouble();
    _pillarDefaultMarginV = (_theme.pillar?.defaultMargin?.top ?? 0).toDouble();
    _pillarDefaultPaddingH =
        (_theme.pillar?.defaultPadding?.left ?? 0).toDouble();
    _pillarDefaultPaddingV =
        (_theme.pillar?.defaultPadding?.top ?? 0).toDouble();
    _pillarBorderWidth = (_theme.pillar?.borderWidth ?? 0).toDouble();
    _pillarCornerRadius = (_theme.pillar?.cornerRadius ?? 0).toDouble();
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
    _globalFontFamily = _theme.typography?.globalFontFamily ?? '';
    _globalFontSize = (_theme.typography?.globalFontSize ?? 14).toDouble();
    _preferredFamiliesText =
        (_theme.typography?.preferredFamilies ?? const []).join(',');
    // 分组字符设计功能已移除
    setState(() {});
  }

  /// Emits new theme to the parent and updates local state.
  void _emit(EditableFourZhuCardTheme next) {
    setState(() => _theme = next);
    widget.onChanged(next);
  }

  /// Builds a labeled slider with given range and handler.
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

  /// Uniform EdgeInsets helper for sliders.
  EdgeInsets _edgeAll(double v) => EdgeInsets.only(
        left: v,
        top: v,
        right: v,
        bottom: v,
      );

  EdgeInsets _edgeHV(double h, double v) =>
      EdgeInsets.symmetric(horizontal: h, vertical: v);

  /// Parses a hex color string like `#RRGGBB` or `#AARRGGBB`.
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
        // Card section
        _Section(
          title: '卡片样式',
          child: Column(
            children: [
              _buildSlider(
                label: '内边距 (uniform)',
                value: _cardPadding,
                min: 0,
                max: 48,
                onChanged: (v) {
                  _cardPadding = v;
                  _emit(_theme.copyWith(
                    card: CardSection(
                      padding: _edgeAll(v),
                      cornerRadius: _cardCornerRadius,
                      elevation: _theme.card?.elevation,
                      backgroundColor: _theme.card?.backgroundColor,
                      margin: _theme.card?.margin,
                    ),
                  ));
                },
              ),
              _buildSlider(
                label: '圆角 (px)',
                value: _cardCornerRadius,
                min: 0,
                max: 32,
                onChanged: (v) {
                  _cardCornerRadius = v;
                  _emit(_theme.copyWith(
                    card: CardSection(
                      cornerRadius: v,
                      padding: _edgeAll(_cardPadding),
                      elevation: _theme.card?.elevation,
                      backgroundColor: _theme.card?.backgroundColor,
                      margin: _theme.card?.margin,
                    ),
                  ));
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Pillar section
        _Section(
          title: '柱样式',
          child: Column(
            children: [
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
                      defaultPadding: _edgeHV(
                          _pillarDefaultPaddingH, _pillarDefaultPaddingV),
                      borderWidth: _pillarBorderWidth,
                      borderColor: _theme.pillar?.borderColor,
                      cornerRadius: _pillarCornerRadius,
                      backgroundColor: _parseHexColor(_pillarBackgroundHex),
                      perPillarMargin: nextPer,
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
                      defaultPadding: _edgeHV(
                          _pillarDefaultPaddingH, _pillarDefaultPaddingV),
                      borderWidth: _pillarBorderWidth,
                      borderColor: _theme.pillar?.borderColor,
                      cornerRadius: _pillarCornerRadius,
                      backgroundColor: _parseHexColor(_pillarBackgroundHex),
                      perPillarMargin: nextPer,
                    ),
                  ));
                },
              ),
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
                      defaultPadding: _edgeHV(
                          _pillarDefaultPaddingH, _pillarDefaultPaddingV),
                      borderWidth: _pillarBorderWidth,
                      borderColor: _theme.pillar?.borderColor,
                      cornerRadius: _pillarCornerRadius,
                      backgroundColor: _parseHexColor(_pillarBackgroundHex),
                      perPillarMargin: Map<PillarType, EdgeInsets>.of(
                          _theme.pillar?.perPillarMargin ?? {}),
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
                      defaultPadding: _edgeHV(
                          _pillarDefaultPaddingH, _pillarDefaultPaddingV),
                      borderWidth: _pillarBorderWidth,
                      borderColor: _theme.pillar?.borderColor,
                      cornerRadius: _pillarCornerRadius,
                      backgroundColor: _parseHexColor(_pillarBackgroundHex),
                      perPillarMargin: Map<PillarType, EdgeInsets>.of(
                          _theme.pillar?.perPillarMargin ?? {}),
                    ),
                  ));
                },
              ),
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
                      defaultPadding: _edgeHV(
                          _pillarDefaultPaddingH, _pillarDefaultPaddingV),
                      borderWidth: v,
                      borderColor: _theme.pillar?.borderColor,
                      cornerRadius: _pillarCornerRadius,
                      backgroundColor: _parseHexColor(_pillarBackgroundHex),
                      perPillarMargin: Map<PillarType, EdgeInsets>.of(
                          _theme.pillar?.perPillarMargin ?? {}),
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
                      defaultPadding: _edgeHV(
                          _pillarDefaultPaddingH, _pillarDefaultPaddingV),
                      borderWidth: _pillarBorderWidth,
                      borderColor: _theme.pillar?.borderColor,
                      cornerRadius: _pillarCornerRadius,
                      backgroundColor: _parseHexColor(_pillarBackgroundHex),
                      perPillarMargin: Map<PillarType, EdgeInsets>.of(
                          _theme.pillar?.perPillarMargin ?? {}),
                    ),
                  ));
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: '柱背景色 (#AARRGGBB 或 #RRGGBB，留空透明)',
                ),
                controller: TextEditingController(text: _pillarBackgroundHex),
                onChanged: (v) {
                  _pillarBackgroundHex = v;
                  _emit(_theme.copyWith(
                    pillar: PillarSection(
                      defaultMargin:
                          _edgeHV(_pillarDefaultMarginH, _pillarDefaultMarginV),
                      defaultPadding: _edgeHV(
                          _pillarDefaultPaddingH, _pillarDefaultPaddingV),
                      borderWidth: _pillarBorderWidth,
                      borderColor: _theme.pillar?.borderColor,
                      cornerRadius: _pillarCornerRadius,
                      backgroundColor: _parseHexColor(_pillarBackgroundHex),
                      perPillarMargin: Map<PillarType, EdgeInsets>.of(
                          _theme.pillar?.perPillarMargin ?? {}),
                    ),
                  ));
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in const [
                    PillarType.year,
                    PillarType.month,
                    PillarType.day,
                    PillarType.hour,
                    PillarType.luckCycle,
                  ])
                    _PerPillarMarginVHEditor(
                      type: t,
                      getHorizontal: () =>
                          (_theme.pillar?.perPillarMargin?[t]?.left ??
                              _pillarDefaultMarginH),
                      getVertical: () =>
                          (_theme.pillar?.perPillarMargin?[t]?.top ??
                              _pillarDefaultMarginV),
                      onChanged: (h, v) {
                        final map = Map<PillarType, EdgeInsets>.of(
                            _theme.pillar?.perPillarMargin ?? {});
                        map[t] = _edgeHV(h, v);
                        _emit(_theme.copyWith(
                          pillar: PillarSection(
                            defaultMargin: _edgeHV(
                                _pillarDefaultMarginH, _pillarDefaultMarginV),
                            defaultPadding: _edgeHV(
                                _pillarDefaultPaddingH, _pillarDefaultPaddingV),
                            borderWidth: _pillarBorderWidth,
                            borderColor: _theme.pillar?.borderColor,
                            cornerRadius: _pillarCornerRadius,
                            backgroundColor:
                                _parseHexColor(_pillarBackgroundHex),
                            perPillarMargin: map,
                          ),
                        ));
                      },
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Typography section
        _Section(
          title: '字体设置',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '全局字体家族',
                  helperText: '选择系统/常见字体；系统默认不会强制设置 family。',
                ),
                value: _globalFontFamily.isEmpty ? '' : _globalFontFamily,
                items: const [
                  DropdownMenuItem(value: '', child: Text('系统默认')),
                  DropdownMenuItem(
                      value: 'NotoSansSC-Regular',
                      child: Text('NotoSansSC-Regular')),
                  DropdownMenuItem(
                      value: 'PingFang SC', child: Text('PingFang SC')),
                  DropdownMenuItem(
                      value: 'Hiragino Sans GB',
                      child: Text('Hiragino Sans GB')),
                  DropdownMenuItem(
                      value: 'Noto Sans', child: Text('Noto Sans')),
                  DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                  DropdownMenuItem(value: 'Segoe UI', child: Text('Segoe UI')),
                  DropdownMenuItem(
                      value: 'Helvetica Neue', child: Text('Helvetica Neue')),
                  DropdownMenuItem(value: 'Arial', child: Text('Arial')),
                  DropdownMenuItem(
                      value: 'Microsoft YaHei', child: Text('Microsoft YaHei')),
                  DropdownMenuItem(value: 'Ubuntu', child: Text('Ubuntu')),
                  DropdownMenuItem(
                      value: 'sans-serif', child: Text('sans-serif')),
                ],
                onChanged: (v) {
                  _globalFontFamily = (v ?? '').trim();
                  _emit(_theme.copyWith(
                    typography: TypographySection(
                      globalFontFamily:
                          _globalFontFamily.isEmpty ? null : _globalFontFamily,
                      globalFontSize: _globalFontSize,
                      globalFontColor: _theme.typography?.globalFontColor,
                      preferredFamilies: _preferredFamiliesText
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                    ),
                  ));
                },
              ),
              const SizedBox(height: 8),
              _buildSlider(
                label: '全局字号',
                value: _globalFontSize,
                min: 8,
                max: 72,
                onChanged: (v) {
                  _globalFontSize = v;
                  _emit(_theme.copyWith(
                    typography: TypographySection(
                      globalFontFamily:
                          _globalFontFamily.isEmpty ? null : _globalFontFamily,
                      globalFontSize: v,
                      globalFontColor: _theme.typography?.globalFontColor,
                      preferredFamilies: _preferredFamiliesText
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                    ),
                  ));
                },
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: '备选字体家族(逗号分隔)',
                  helperText: '优先级：行 → 全局 → 列表 → 系统默认',
                ),
                controller: TextEditingController(text: _preferredFamiliesText),
                onChanged: (v) {
                  _preferredFamiliesText = v;
                  _emit(_theme.copyWith(
                    typography: TypographySection(
                      globalFontFamily:
                          _globalFontFamily.isEmpty ? null : _globalFontFamily,
                      globalFontSize: _globalFontSize,
                      globalFontColor: _theme.typography?.globalFontColor,
                      preferredFamilies: v
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                    ),
                  ));
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}

/// Section wrapper with a title and padding.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

/// Per-pillar uniform margin editor control.
class _PerPillarMarginVHEditor extends StatelessWidget {
  const _PerPillarMarginVHEditor({
    required this.type,
    required this.getHorizontal,
    required this.getVertical,
    required this.onChanged,
  });

  final PillarType type;
  final double Function() getHorizontal;
  final double Function() getVertical;
  final void Function(double h, double v) onChanged;

  String _labelFor(PillarType t) {
    switch (t) {
      case PillarType.year:
        return '年柱';
      case PillarType.month:
        return '月柱';
      case PillarType.day:
        return '日柱';
      case PillarType.hour:
        return '时柱';
      case PillarType.luckCycle:
        return '大运';
      case PillarType.separator:
        return '分隔符';
      case PillarType.ke:
        return '克';
      case PillarType.taiMeta:
        return '太乙元';
      case PillarType.taiMonth:
        return '太乙月';
      case PillarType.taiDay:
        return '太乙日';
      case PillarType.lifeHouse:
        return '命宫';
      case PillarType.annual:
        return '流年';
      case PillarType.monthly:
        return '流月';
      case PillarType.daily:
        return '流日';
      case PillarType.hourly:
        return '流时';
      case PillarType.rowTitleColumn:
        return '行标题';
      default:
        return t.toString().split('.').last;
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = getHorizontal();
    final v = getVertical();
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_labelFor(type)),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: h,
                      min: 0,
                      max: 24,
                      onChanged: (val) => onChanged(val, v),
                    ),
                  ),
                  Text(h.toStringAsFixed(0)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: v,
                      min: 0,
                      max: 24,
                      onChanged: (val) => onChanged(h, val),
                    ),
                  ),
                  Text(v.toStringAsFixed(0)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
