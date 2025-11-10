import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

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
  double _cardBorderWidth = 1;
  String _cardBorderHex = '';
  String _cardBackgroundHex = '';
  // Card shadow controls
  String _cardShadowHex = '';
  double _cardShadowOffsetX = 0;
  double _cardShadowOffsetY = 0;
  double _cardShadowBlur = 0;
  bool _cardShadowEnabled = false;
  bool _cardShadowFollowBackground = false;
  double _pillarDefaultMarginH = 0;
  double _pillarDefaultMarginV = 0;
  double _pillarDefaultPaddingH = 0;
  double _pillarDefaultPaddingV = 0;
  double _pillarBorderWidth = 0;
  double _pillarCornerRadius = 0;
  // Pillar shadow controls
  String _pillarShadowHex = '';
  double _pillarShadowOffsetX = 0;
  double _pillarShadowOffsetY = 0;
  double _pillarShadowBlur = 0;
  bool _pillarShadowEnabled = false;
  bool _pillarShadowFollowBackground = false;
  String _pillarBackgroundHex = '';
  String _pillarBorderHex = '';
  String _globalFontFamily = '';
  double _globalFontSize = 14;
  String _preferredFamiliesText = '';

  // 分组字符设计功能已移除

  @override

  /// 初始化状态：从外部传入的主题加载控件值并建立本地缓存。
  ///
  /// 返回：
  /// - `void`：完成初始加载并触发首帧渲染。
  void initState() {
    super.initState();
    _loadFromTheme(widget.theme);
  }

  @override

  /// 响应父组件更新：当传入的主题对象发生变化时重新加载控件状态。
  ///
  /// 参数：
  /// - [oldWidget]：旧的面板实例，用于比较变更。
  ///
  /// 返回：
  /// - `void`：若主题变更则刷新内部缓存并触发重建。
  void didUpdateWidget(covariant EditableFourZhuStyleEditorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme != widget.theme) {
      _loadFromTheme(widget.theme);
    }
  }

  /// 从主题加载滑块与文本控件的当前值。
  ///
  /// 功能：解析 `EditableFourZhuCardTheme` 中的 Card/Pillar/Typography 配置，
  /// 将其转换为本地状态（数值、颜色十六进制字符串等），并更新界面。
  ///
  /// 参数：
  /// - [theme]：当前编辑的主题对象。
  ///
  /// 返回：
  /// - `void`：更新内部状态并通过 `setState` 刷新 UI。
  void _loadFromTheme(EditableFourZhuCardTheme theme) {
    _theme = theme;
    _cardPadding = (_theme.card?.padding?.left ?? 0).toDouble();
    _cardCornerRadius = (_theme.card?.cornerRadius ?? 8).toDouble();
    _cardShadowHex = _theme.card?.shadowColor != null
        ? '#${_theme.card!.shadowColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
        : '';
    _cardShadowEnabled = (_theme.card?.shadowColor != null) ||
        (_theme.card?.shadowColorFollowsBackground == true);
    _cardShadowFollowBackground =
        _theme.card?.shadowColorFollowsBackground == true;
    _cardShadowOffsetX = (_theme.card?.shadowOffsetX ?? 0).toDouble();
    _cardShadowOffsetY = (_theme.card?.shadowOffsetY ?? 0).toDouble();
    _cardShadowBlur = (_theme.card?.shadowBlurRadius ?? 0).toDouble();
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
    _globalFontFamily = _theme.typography?.globalFontFamily ?? '';
    _globalFontSize = (_theme.typography?.globalFontSize ?? 14).toDouble();
    _preferredFamiliesText =
        (_theme.typography?.preferredFamilies ?? const []).join(',');
    // 分组字符设计功能已移除
    setState(() {});
  }

  /// 发出新主题并更新本地缓存。
  ///
  /// 功能：先更新 `_theme` 的本地副本，再调用 `widget.onChanged` 通知父组件绑定预览。
  ///
  /// 参数：
  /// - [next]：合成后的下一版主题对象。
  ///
  /// 返回：
  /// - `void`：触发回调与重建，无额外返回值。
  void _emit(EditableFourZhuCardTheme next) {
    setState(() => _theme = next);
    widget.onChanged(next);
  }

  /// 构建带标签的通用滑块组件。
  ///
  /// 参数：
  /// - [label]：滑块标题文本。
  /// - [value]：当前值。
  /// - [min]：取值下限。
  /// - [max]：取值上限。
  /// - [onChanged]：值变更回调。
  ///
  /// 返回：
  /// - `Widget`：包含标题、数值显示与 `Slider` 的纵向布局。
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

  /// 统一内边距辅助方法：生成四边一致的 `EdgeInsets`。
  ///
  /// 参数：
  /// - [v]：四边统一的像素值。
  ///
  /// 返回：
  /// - `EdgeInsets`：`left/top/right/bottom` 均为 `v`。
  EdgeInsets _edgeAll(double v) => EdgeInsets.only(
        left: v,
        top: v,
        right: v,
        bottom: v,
      );

  /// 内外向对称内边距辅助方法。
  ///
  /// 参数：
  /// - [h]：水平（左右）内边距像素值。
  /// - [v]：垂直（上下）内边距像素值。
  ///
  /// 返回：
  /// - `EdgeInsets`：对称的水平与垂直内边距。
  EdgeInsets _edgeHV(double h, double v) =>
      EdgeInsets.symmetric(horizontal: h, vertical: v);

  /// 解析十六进制颜色字符串（支持 `#RRGGBB` 与 `#AARRGGBB`）。
  ///
  /// 参数：
  /// - [input]：形如 `#RRGGBB` 或 `#AARRGGBB` 的颜色字符串，前导 `#` 可选。
  ///
  /// 返回：
  /// - `Color?`：解析成功返回 `Color`，非法字符串返回 `null`。
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

  /// 构建样式编辑面板主体：包含卡片与柱样式等分区的控件集合。
  ///
  /// 参数：
  /// - [context]：Flutter 构建上下文。
  ///
  /// 返回：
  /// - `Widget`：由多个分区与控件组成的编辑界面。
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
                label: '内边距',
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
                      shadowColor: _cardShadowEnabled
                          ? _parseHexColor(_cardShadowHex)
                          : null,
                      shadowOffsetX: _cardShadowOffsetX,
                      shadowOffsetY: _cardShadowOffsetY,
                      shadowBlurRadius: _cardShadowBlur,
                    ),
                  ));
                },
              ),
              _buildSlider(
                label: '圆角',
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
                      shadowColor: _cardShadowEnabled
                          ? _parseHexColor(_cardShadowHex)
                          : null,
                      shadowOffsetX: _cardShadowOffsetX,
                      shadowOffsetY: _cardShadowOffsetY,
                      shadowBlurRadius: _cardShadowBlur,
                    ),
                  ));
                },
              ),
              // 卡片背景色：色块 + 按钮
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('卡片背景色'),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showColorPickerDialog(
                        context,
                        _parseHexColor(_cardBackgroundHex) ??
                            Theme.of(context).colorScheme.surface,
                        title: const Text('选择颜色'),
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                          ColorPickerType.accent: false,
                          ColorPickerType.primary: false,
                          ColorPickerType.custom: false,
                        },
                      );
                      _cardBackgroundHex =
                          '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                      _emit(_theme.copyWith(
                        card: CardSection(
                          padding: _edgeAll(_cardPadding),
                          cornerRadius: _cardCornerRadius,
                          elevation: _theme.card?.elevation,
                          backgroundColor: picked,
                          margin: _theme.card?.margin,
                          shadowColor: _cardShadowEnabled
                              ? _parseHexColor(_cardShadowHex)
                              : null,
                          shadowOffsetX: _cardShadowOffsetX,
                          shadowOffsetY: _cardShadowOffsetY,
                          shadowBlurRadius: _cardShadowBlur,
                          borderWidth: _cardBorderWidth,
                          borderColor: _parseHexColor(_cardBorderHex),
                        ),
                      ));
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _parseHexColor(_cardBackgroundHex) ??
                            Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () async {
                      final picked = await showColorPickerDialog(
                        context,
                        _parseHexColor(_cardBackgroundHex) ??
                            Theme.of(context).colorScheme.surface,
                        title: const Text('选择颜色'),
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                          ColorPickerType.accent: false,
                          ColorPickerType.primary: false,
                          ColorPickerType.custom: false,
                        },
                      );
                      _cardBackgroundHex =
                          '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                      _emit(_theme.copyWith(
                        card: CardSection(
                          padding: _edgeAll(_cardPadding),
                          cornerRadius: _cardCornerRadius,
                          elevation: _theme.card?.elevation,
                          backgroundColor: picked,
                          margin: _theme.card?.margin,
                          shadowColor: _cardShadowEnabled
                              ? _parseHexColor(_cardShadowHex)
                              : null,
                          shadowOffsetX: _cardShadowOffsetX,
                          shadowOffsetY: _cardShadowOffsetY,
                          shadowBlurRadius: _cardShadowBlur,
                          borderWidth: _cardBorderWidth,
                          borderColor: _parseHexColor(_cardBorderHex),
                        ),
                      ));
                    },
                    child: const Text('选择颜色'),
                  ),
                ],
              ),
              // 边框分区标题
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child:
                    Text('边框', style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              const Divider(),
              // 边框粗细
              _buildSlider(
                label: '边框粗细',
                value: _cardBorderWidth,
                min: 0,
                max: 8,
                onChanged: (v) {
                  _cardBorderWidth = v;
                  _emit(_theme.copyWith(
                    card: CardSection(
                      padding: _edgeAll(_cardPadding),
                      cornerRadius: _cardCornerRadius,
                      elevation: _theme.card?.elevation,
                      backgroundColor: _parseHexColor(_cardBackgroundHex) ??
                          _theme.card?.backgroundColor,
                      margin: _theme.card?.margin,
                      shadowColor: _cardShadowEnabled
                          ? _parseHexColor(_cardShadowHex)
                          : null,
                      shadowOffsetX: _cardShadowOffsetX,
                      shadowOffsetY: _cardShadowOffsetY,
                      shadowBlurRadius: _cardShadowBlur,
                      borderWidth: _cardBorderWidth,
                      borderColor: _parseHexColor(_cardBorderHex) ??
                          _theme.card?.borderColor,
                    ),
                  ));
                },
              ),
              // 卡片边框颜色：色块 + 按钮
              Row(
                children: [
                  const Text('卡片边框颜色'),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showColorPickerDialog(
                        context,
                        _parseHexColor(_cardBorderHex) ??
                            Theme.of(context).dividerColor,
                        title: const Text('选择颜色'),
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                          ColorPickerType.accent: false,
                          ColorPickerType.primary: false,
                          ColorPickerType.custom: false,
                        },
                      );
                      _cardBorderHex =
                          '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                      _emit(_theme.copyWith(
                        card: CardSection(
                          padding: _edgeAll(_cardPadding),
                          cornerRadius: _cardCornerRadius,
                          elevation: _theme.card?.elevation,
                          backgroundColor: _parseHexColor(_cardBackgroundHex) ??
                              _theme.card?.backgroundColor,
                          margin: _theme.card?.margin,
                          shadowColor: _cardShadowEnabled
                              ? _parseHexColor(_cardShadowHex)
                              : null,
                          shadowOffsetX: _cardShadowOffsetX,
                          shadowOffsetY: _cardShadowOffsetY,
                          shadowBlurRadius: _cardShadowBlur,
                          borderWidth: _cardBorderWidth,
                          borderColor: picked,
                        ),
                      ));
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _parseHexColor(_cardBorderHex) ??
                            Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () async {
                      final picked = await showColorPickerDialog(
                        context,
                        _parseHexColor(_cardBorderHex) ??
                            Theme.of(context).dividerColor,
                        title: const Text('选择颜色'),
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                          ColorPickerType.accent: false,
                          ColorPickerType.primary: false,
                          ColorPickerType.custom: false,
                        },
                      );
                      _cardBorderHex =
                          '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                      _emit(_theme.copyWith(
                        card: CardSection(
                          padding: _edgeAll(_cardPadding),
                          cornerRadius: _cardCornerRadius,
                          elevation: _theme.card?.elevation,
                          backgroundColor: _parseHexColor(_cardBackgroundHex) ??
                              _theme.card?.backgroundColor,
                          margin: _theme.card?.margin,
                          shadowColor: _cardShadowEnabled
                              ? _parseHexColor(_cardShadowHex)
                              : null,
                          shadowOffsetX: _cardShadowOffsetX,
                          shadowOffsetY: _cardShadowOffsetY,
                          shadowBlurRadius: _cardShadowBlur,
                          borderWidth: _cardBorderWidth,
                          borderColor: picked,
                        ),
                      ));
                    },
                    child: const Text('选择'),
                  ),
                ],
              ),
              const Divider(),
              // 阴影启用开关
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('阴影'),
                value: _cardShadowEnabled,
                onChanged: (v) {
                  _cardShadowEnabled = v ?? false;
                  _emit(_theme.copyWith(
                    card: CardSection(
                      padding: _edgeAll(_cardPadding),
                      cornerRadius: _cardCornerRadius,
                      elevation: _theme.card?.elevation,
                      backgroundColor: _theme.card?.backgroundColor,
                      margin: _theme.card?.margin,
                      shadowColorFollowsBackground: _cardShadowEnabled
                          ? _cardShadowFollowBackground
                          : false,
                      shadowColor: _cardShadowEnabled
                          ? (_cardShadowFollowBackground
                              ? null
                              : _parseHexColor(_cardShadowHex.isEmpty
                                  ? '#55000000'
                                  : _cardShadowHex))
                          : null,
                      shadowOffsetX: _cardShadowOffsetX,
                      shadowOffsetY: _cardShadowOffsetY,
                      shadowBlurRadius: _cardShadowBlur,
                    ),
                  ));
                },
              ),
              // 阴影颜色跟随卡片背景颜色
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('阴影颜色跟随卡片背景颜色'),
                value: _cardShadowFollowBackground,
                onChanged: (v) {
                  _cardShadowFollowBackground = v ?? false;
                  _emit(_theme.copyWith(
                    card: CardSection(
                      padding: _edgeAll(_cardPadding),
                      cornerRadius: _cardCornerRadius,
                      elevation: _theme.card?.elevation,
                      backgroundColor: _theme.card?.backgroundColor,
                      margin: _theme.card?.margin,
                      shadowColorFollowsBackground: _cardShadowFollowBackground,
                      // When following background, ignore manual shadow color.
                      shadowColor: _cardShadowFollowBackground
                          ? null
                          : (_cardShadowEnabled
                              ? _parseHexColor(_cardShadowHex)
                              : null),
                      shadowOffsetX: _cardShadowOffsetX,
                      shadowOffsetY: _cardShadowOffsetY,
                      shadowBlurRadius: _cardShadowBlur,
                    ),
                  ));
                },
              ),
              // 阴影颜色选择：色块 + 按钮，点击弹出颜色选择对话框
              Row(
                children: [
                  const Text('颜色'),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      if (!_cardShadowEnabled) return;
                      final picked = await showColorPickerDialog(
                        context,
                        _parseHexColor(_cardShadowHex) ??
                            const Color(0x55000000),
                        title: const Text('选择颜色'),
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                          ColorPickerType.accent: false,
                          ColorPickerType.primary: false,
                          ColorPickerType.custom: false,
                        },
                      );
                      _cardShadowHex =
                          '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                      _cardShadowFollowBackground = false;
                      _emit(_theme.copyWith(
                        card: CardSection(
                          padding: _edgeAll(_cardPadding),
                          cornerRadius: _cardCornerRadius,
                          elevation: _theme.card?.elevation,
                          backgroundColor: _theme.card?.backgroundColor,
                          margin: _theme.card?.margin,
                          shadowColorFollowsBackground: false,
                          shadowColor: _cardShadowEnabled ? picked : null,
                          shadowOffsetX: _cardShadowOffsetX,
                          shadowOffsetY: _cardShadowOffsetY,
                          shadowBlurRadius: _cardShadowBlur,
                        ),
                      ));
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _cardShadowFollowBackground
                            ? (_parseHexColor(_cardBackgroundHex) ??
                                Theme.of(context).colorScheme.surface)
                            : (_parseHexColor(_cardShadowHex) ??
                                const Color(0x00000000)),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () async {
                      if (!_cardShadowEnabled) return;
                      final picked = await showColorPickerDialog(
                        context,
                        _parseHexColor(_cardShadowHex) ??
                            const Color(0x55000000),
                        title: const Text('选择颜色'),
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                          ColorPickerType.accent: false,
                          ColorPickerType.primary: false,
                          ColorPickerType.custom: false,
                        },
                      );
                      _cardShadowHex =
                          '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                      _emit(_theme.copyWith(
                        card: CardSection(
                          padding: _edgeAll(_cardPadding),
                          cornerRadius: _cardCornerRadius,
                          elevation: _theme.card?.elevation,
                          backgroundColor: _theme.card?.backgroundColor,
                          margin: _theme.card?.margin,
                          shadowColorFollowsBackground: false,
                          // 用户主动选择阴影颜色时，自动关闭跟随背景
                          // 并启用手动阴影颜色
                          shadowColor: _cardShadowEnabled ? picked : null,
                          shadowOffsetX: _cardShadowOffsetX,
                          shadowOffsetY: _cardShadowOffsetY,
                          shadowBlurRadius: _cardShadowBlur,
                        ),
                      ));
                    },
                    child: const Text('选择'),
                  ),
                ],
              ),
              // 不透明度 (%)
              Builder(builder: (context) {
                final alpha =
                    (_parseHexColor(_cardShadowHex)?.alpha ?? 0x55).toDouble();
                final percent = ((alpha / 255.0) * 100).round();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('不透明度')),
                        Text('$percent%'),
                      ],
                    ),
                    Slider(
                      value: alpha,
                      min: 0,
                      max: 255,
                      onChanged: (v) {
                        if (!_cardShadowEnabled) return;
                        final newAlpha = v.clamp(0, 255).round();
                        Color base = _cardShadowFollowBackground
                            ? (_parseHexColor(_cardBackgroundHex) ??
                                const Color(0x00000000))
                            : (_parseHexColor(_cardShadowHex) ??
                                const Color(0x55000000));
                        final updated = base.withAlpha(newAlpha);
                        _cardShadowHex =
                            '#${updated.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                        _cardShadowFollowBackground = false;
                        _emit(_theme.copyWith(
                          card: CardSection(
                            padding: _edgeAll(_cardPadding),
                            cornerRadius: _cardCornerRadius,
                            elevation: _theme.card?.elevation,
                            backgroundColor: _theme.card?.backgroundColor,
                            margin: _theme.card?.margin,
                            shadowColorFollowsBackground: false,
                            shadowColor: _cardShadowEnabled ? updated : null,
                            shadowOffsetX: _cardShadowOffsetX,
                            shadowOffsetY: _cardShadowOffsetY,
                            shadowBlurRadius: _cardShadowBlur,
                          ),
                        ));
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }),
              _buildSlider(
                label: '水平偏移 (px)',
                value: _cardShadowOffsetX,
                min: -32,
                max: 32,
                onChanged: (v) {
                  _cardShadowOffsetX = v;
                  _emit(_theme.copyWith(
                    card: CardSection(
                      padding: _edgeAll(_cardPadding),
                      cornerRadius: _cardCornerRadius,
                      elevation: _theme.card?.elevation,
                      backgroundColor: _theme.card?.backgroundColor,
                      margin: _theme.card?.margin,
                      shadowColorFollowsBackground: _cardShadowFollowBackground,
                      shadowColor: _cardShadowFollowBackground
                          ? null
                          : (_cardShadowEnabled
                              ? _parseHexColor(_cardShadowHex)
                              : null),
                      shadowOffsetX: _cardShadowOffsetX,
                      shadowOffsetY: _cardShadowOffsetY,
                      shadowBlurRadius: _cardShadowBlur,
                    ),
                  ));
                },
              ),
              _buildSlider(
                label: '垂直偏移 (px)',
                value: _cardShadowOffsetY,
                min: -32,
                max: 32,
                onChanged: (v) {
                  _cardShadowOffsetY = v;
                  _emit(_theme.copyWith(
                    card: CardSection(
                      padding: _edgeAll(_cardPadding),
                      cornerRadius: _cardCornerRadius,
                      elevation: _theme.card?.elevation,
                      backgroundColor: _theme.card?.backgroundColor,
                      margin: _theme.card?.margin,
                      shadowColorFollowsBackground: _cardShadowFollowBackground,
                      shadowColor: _cardShadowFollowBackground
                          ? null
                          : (_cardShadowEnabled
                              ? _parseHexColor(_cardShadowHex)
                              : null),
                      shadowOffsetX: _cardShadowOffsetX,
                      shadowOffsetY: _cardShadowOffsetY,
                      shadowBlurRadius: _cardShadowBlur,
                    ),
                  ));
                },
              ),
              _buildSlider(
                label: '模糊半径 (px)',
                value: _cardShadowBlur,
                min: 0,
                max: 64,
                onChanged: (v) {
                  _cardShadowBlur = v;
                  _emit(_theme.copyWith(
                    card: CardSection(
                      padding: _edgeAll(_cardPadding),
                      cornerRadius: _cardCornerRadius,
                      elevation: _theme.card?.elevation,
                      backgroundColor: _theme.card?.backgroundColor,
                      margin: _theme.card?.margin,
                      shadowColorFollowsBackground: _cardShadowFollowBackground,
                      shadowColor: _cardShadowFollowBackground
                          ? null
                          : (_cardShadowEnabled
                              ? _parseHexColor(_cardShadowHex)
                              : null),
                      shadowOffsetX: _cardShadowOffsetX,
                      shadowOffsetY: _cardShadowOffsetY,
                      shadowBlurRadius: _cardShadowBlur,
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
                      defaultPadding: _edgeHV(
                          _pillarDefaultPaddingH, _pillarDefaultPaddingV),
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
                      defaultPadding: _edgeHV(
                          _pillarDefaultPaddingH, _pillarDefaultPaddingV),
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
                      defaultPadding: _edgeHV(
                          _pillarDefaultPaddingH, _pillarDefaultPaddingV),
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
              // 柱背景色：色块 + 按钮
              Row(
                children: [
                  const Text('柱背景色'),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showColorPickerDialog(
                        context,
                        _parseHexColor(_pillarBackgroundHex) ??
                            Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
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
                          defaultMargin: _edgeHV(
                              _pillarDefaultMarginH, _pillarDefaultMarginV),
                          defaultPadding: _edgeHV(
                              _pillarDefaultPaddingH, _pillarDefaultPaddingV),
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
                            Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.4),
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
                            Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
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
                          defaultMargin: _edgeHV(
                              _pillarDefaultMarginH, _pillarDefaultMarginV),
                          defaultPadding: _edgeHV(
                              _pillarDefaultPaddingH, _pillarDefaultPaddingV),
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
              // 柱边框颜色：色块 + 按钮
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
                          defaultMargin: _edgeHV(
                              _pillarDefaultMarginH, _pillarDefaultMarginV),
                          defaultPadding: _edgeHV(
                              _pillarDefaultPaddingH, _pillarDefaultPaddingV),
                          borderWidth: _pillarBorderWidth,
                          borderColor: picked,
                          cornerRadius: _pillarCornerRadius,
                          backgroundColor:
                              _parseHexColor(_pillarBackgroundHex) ??
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
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.4),
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
                          defaultMargin: _edgeHV(
                              _pillarDefaultMarginH, _pillarDefaultMarginV),
                          defaultPadding: _edgeHV(
                              _pillarDefaultPaddingH, _pillarDefaultPaddingV),
                          borderWidth: _pillarBorderWidth,
                          borderColor: picked,
                          cornerRadius: _pillarCornerRadius,
                          backgroundColor:
                              _parseHexColor(_pillarBackgroundHex) ??
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
                ],
              ),
              const SizedBox(height: 8),
              // 阴影启用开关（柱）
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('启用阴影'),
                value: _pillarShadowEnabled,
                onChanged: (v) {
                  _pillarShadowEnabled = v ?? false;
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
                      shadowColorFollowsBackground: _pillarShadowEnabled
                          ? _pillarShadowFollowBackground
                          : false,
                      shadowColor: _pillarShadowEnabled
                          ? (_pillarShadowFollowBackground
                              ? null
                              : _parseHexColor(_pillarShadowHex.isEmpty
                                  ? '#55000000'
                                  : _pillarShadowHex))
                          : null,
                      shadowOffsetX: _pillarShadowOffsetX,
                      shadowOffsetY: _pillarShadowOffsetY,
                      shadowBlurRadius: _pillarShadowBlur,
                    ),
                  ));
                },
              ),
              // 阴影颜色跟随柱背景颜色
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('阴影颜色跟随柱背景颜色'),
                value: _pillarShadowFollowBackground,
                onChanged: (v) {
                  _pillarShadowFollowBackground = v ?? false;
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
                      shadowColorFollowsBackground:
                          _pillarShadowFollowBackground,
                      shadowColor: _pillarShadowFollowBackground
                          ? null
                          : (_pillarShadowEnabled
                              ? _parseHexColor(_pillarShadowHex)
                              : null),
                      shadowOffsetX: _pillarShadowOffsetX,
                      shadowOffsetY: _pillarShadowOffsetY,
                      shadowBlurRadius: _pillarShadowBlur,
                    ),
                  ));
                },
              ),
              // 阴影颜色选择（柱）：色块 + 按钮，点击弹出颜色选择对话框
              Row(
                children: [
                  const Text('阴影颜色'),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      if (!_pillarShadowEnabled) return;
                      final picked = await showColorPickerDialog(
                        context,
                        _parseHexColor(_pillarShadowHex) ??
                            const Color(0x55000000),
                        title: const Text('选择颜色'),
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                          ColorPickerType.accent: false,
                          ColorPickerType.primary: false,
                          ColorPickerType.custom: false,
                        },
                      );
                      _pillarShadowHex =
                          '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                      _pillarShadowFollowBackground = false;
                      _emit(_theme.copyWith(
                        pillar: PillarSection(
                          defaultMargin: _edgeHV(
                              _pillarDefaultMarginH, _pillarDefaultMarginV),
                          defaultPadding: _edgeHV(
                              _pillarDefaultPaddingH, _pillarDefaultPaddingV),
                          borderWidth: _pillarBorderWidth,
                          borderColor: _theme.pillar?.borderColor,
                          cornerRadius: _pillarCornerRadius,
                          backgroundColor: _parseHexColor(_pillarBackgroundHex),
                          perPillarMargin: Map<PillarType, EdgeInsets>.of(
                              _theme.pillar?.perPillarMargin ?? {}),
                          shadowColorFollowsBackground: false,
                          shadowColor: _pillarShadowEnabled ? picked : null,
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
                        color: _pillarShadowFollowBackground
                            ? (_parseHexColor(_pillarBackgroundHex) ??
                                Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest)
                            : (_parseHexColor(_pillarShadowHex) ??
                                const Color(0x00000000)),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () async {
                      if (!_pillarShadowEnabled) return;
                      final picked = await showColorPickerDialog(
                        context,
                        _parseHexColor(_pillarShadowHex) ??
                            const Color(0x55000000),
                        title: const Text('选择颜色'),
                        pickersEnabled: const {
                          ColorPickerType.wheel: true,
                          ColorPickerType.accent: false,
                          ColorPickerType.primary: false,
                          ColorPickerType.custom: false,
                        },
                      );
                      _pillarShadowHex =
                          '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                      _emit(_theme.copyWith(
                        pillar: PillarSection(
                          defaultMargin: _edgeHV(
                              _pillarDefaultMarginH, _pillarDefaultMarginV),
                          defaultPadding: _edgeHV(
                              _pillarDefaultPaddingH, _pillarDefaultPaddingV),
                          borderWidth: _pillarBorderWidth,
                          borderColor: _theme.pillar?.borderColor,
                          cornerRadius: _pillarCornerRadius,
                          backgroundColor: _parseHexColor(_pillarBackgroundHex),
                          perPillarMargin: Map<PillarType, EdgeInsets>.of(
                              _theme.pillar?.perPillarMargin ?? {}),
                          shadowColorFollowsBackground: false,
                          shadowColor: _pillarShadowEnabled ? picked : null,
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
              _buildSlider(
                label: '柱阴影颜色透明度 (0-255)',
                value: (() {
                  final c = _parseHexColor(_pillarShadowHex);
                  return (c?.alpha ?? 0x55).toDouble();
                })(),
                min: 0,
                max: 255,
                onChanged: (v) {
                  if (!_pillarShadowEnabled) return;
                  final newAlpha = v.clamp(0, 255).round();
                  Color base = _pillarShadowFollowBackground
                      ? (_parseHexColor(_pillarBackgroundHex) ??
                          const Color(0x00000000))
                      : (_parseHexColor(_pillarShadowHex) ??
                          const Color(0x55000000));
                  final updated = base.withAlpha(newAlpha);
                  _pillarShadowHex =
                      '#${updated.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                  _pillarShadowFollowBackground = false;
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
                      shadowColorFollowsBackground: false,
                      shadowColor: _pillarShadowEnabled ? updated : null,
                      shadowOffsetX: _pillarShadowOffsetX,
                      shadowOffsetY: _pillarShadowOffsetY,
                      shadowBlurRadius: _pillarShadowBlur,
                    ),
                  ));
                },
              ),
              _buildSlider(
                label: '柱阴影偏移X (px)',
                value: _pillarShadowOffsetX,
                min: -32,
                max: 32,
                onChanged: (v) {
                  _pillarShadowOffsetX = v;
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
                      shadowColorFollowsBackground:
                          _pillarShadowFollowBackground,
                      shadowColor: _pillarShadowFollowBackground
                          ? null
                          : (_pillarShadowEnabled
                              ? _parseHexColor(_pillarShadowHex)
                              : null),
                      shadowOffsetX: _pillarShadowOffsetX,
                      shadowOffsetY: _pillarShadowOffsetY,
                      shadowBlurRadius: _pillarShadowBlur,
                    ),
                  ));
                },
              ),
              _buildSlider(
                label: '柱阴影偏移Y (px)',
                value: _pillarShadowOffsetY,
                min: -32,
                max: 32,
                onChanged: (v) {
                  _pillarShadowOffsetY = v;
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
                      shadowColorFollowsBackground:
                          _pillarShadowFollowBackground,
                      shadowColor: _pillarShadowFollowBackground
                          ? null
                          : (_pillarShadowEnabled
                              ? _parseHexColor(_pillarShadowHex)
                              : null),
                      shadowOffsetX: _pillarShadowOffsetX,
                      shadowOffsetY: _pillarShadowOffsetY,
                      shadowBlurRadius: _pillarShadowBlur,
                    ),
                  ));
                },
              ),
              _buildSlider(
                label: '柱阴影模糊半径 (px)',
                value: _pillarShadowBlur,
                min: 0,
                max: 64,
                onChanged: (v) {
                  _pillarShadowBlur = v;
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
                      shadowColorFollowsBackground:
                          _pillarShadowFollowBackground,
                      shadowColor: _pillarShadowFollowBackground
                          ? null
                          : (_pillarShadowEnabled
                              ? _parseHexColor(_pillarShadowHex)
                              : null),
                      shadowOffsetX: _pillarShadowOffsetX,
                      shadowOffsetY: _pillarShadowOffsetY,
                      shadowBlurRadius: _pillarShadowBlur,
                    ),
                  ));
                },
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
