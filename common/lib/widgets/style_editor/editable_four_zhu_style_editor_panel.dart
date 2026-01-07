import 'package:common/viewmodels/four_zhu_editor_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:provider/provider.dart';

import '../../features/four_zhu_card/widgets/editable_fourzhu_card/models/base_style_config.dart';
import '../../features/four_zhu_card/widgets/editable_fourzhu_card/models/card_style_config.dart';
import 'widgets/app_palette_picker_dialog.dart';

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
    // required this.theme,
    // required this.onChanged,
  });

  /// Current theme state displayed by the panel.
  // final EditableFourZhuCardTheme theme;

  /// Change handler invoked on any edit.
  // final ValueChanged<EditableFourZhuCardTheme> onChanged;

  @override
  State<EditableFourZhuStyleEditorPanel> createState() {
    return _EditableFourZhuStyleEditorPanelState();
  }
}

class _EditableFourZhuStyleEditorPanelState
    extends State<EditableFourZhuStyleEditorPanel> {
  _EditableFourZhuStyleEditorPanelState();
  late final ValueNotifier<CardStyleConfig> _cardStyleConfig;
  late final TextEditingController _preferredFamiliesController;
  late final VoidCallback _demoVmListener;

  // Cached scalar controls for convenience (uniform values)
  // double _cardPadding = 0;
  // double _cardCornerRadius = 8;
  // double _cardBorderWidth = 1;
  // String _cardBorderHex = '';
  // String _cardBackgroundHex = '';
  // Card shadow controls
  // String _cardShadowHex = '';
  // double _cardShadowOffsetX = 0;
  // double _cardShadowOffsetY = 0;
  // double _cardShadowBlur = 0;
  // bool _cardShadowEnabled = false;
  // bool _cardShadowFollowBackground = false;
  // Pillar controls - 已提取到独立的FourZhuPillarStyleEditorPanel组件
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
    warmupPaletteNameIndex();
    final editorVm = context.read<FourZhuEditorViewModel>();

    final typography = editorVm.editableThemeNotifier.value.typography;
    final font = typography.globalContent.fontStyleDataModel;
    _globalFontFamily = font.fontFamily == 'System' ? '' : font.fontFamily;
    _globalFontSize = font.fontSize;
    _preferredFamiliesController =
        TextEditingController(text: _preferredFamiliesText);

    _cardStyleConfig = ValueNotifier<CardStyleConfig>(
      editorVm.editableThemeNotifier.value.card,
    )..addListener(() {
        editorVm.updateEditableFourZhuCardTheme(
          editorVm.editableThemeNotifier.value
              .copyWith(card: _cardStyleConfig.value),
        );
        editorVm.updateCardContentInsets(_cardStyleConfig.value.padding);
      });

    _demoVmListener = () {
      final next = editorVm.editableThemeNotifier.value.card;
      if (_cardStyleConfig.value != next) {
        _cardStyleConfig.value = next;
      }
    };
    editorVm.addListener(_demoVmListener);
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

    // if (oldWidget.theme != widget.theme) {
    //   _cardStyleConfig.value = widget.theme.card;
    // }
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
    final editorVm = context.read<FourZhuEditorViewModel>();
    editorVm.updateEditableFourZhuCardTheme(next);
    editorVm.updateCardContentInsets(next.card.padding);

    final font = next.typography.globalContent.fontStyleDataModel;
    editorVm.updateGlobalFontFamily(font.fontFamily);
    editorVm.updateGlobalFontSize(font.fontSize);
  }

  @override
  void dispose() {
    context.read<FourZhuEditorViewModel>().removeListener(_demoVmListener);
    _preferredFamiliesController.dispose();
    _cardStyleConfig.dispose();
    super.dispose();
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
        const widgets.SizedBox(height: 8),
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
        ValueListenableBuilder<CardStyleConfig>(
          valueListenable: _cardStyleConfig,
          builder: (context, cardStyleConfig, child) {
            return _Section(
              title: '卡片样式',
              child: _buildCardStyleSection(context, cardStyleConfig),
            );
          },
        ),
        const widgets.SizedBox(height: 12),

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
                  final theme = context
                      .read<FourZhuEditorViewModel>()
                      .editableThemeNotifier
                      .value;
                  final typography = theme.typography;
                  final currentFont =
                      typography.globalContent.fontStyleDataModel;
                  final family =
                      _globalFontFamily.isEmpty ? 'System' : _globalFontFamily;
                  _emit(
                    theme.copyWith(
                      typography: typography.copyWith(
                        globalContent: typography.globalContent.copyWith(
                          fontStyleDataModel:
                              currentFont.copyWith(fontFamily: family),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const widgets.SizedBox(height: 8),
              _buildSlider(
                label: '全局字号',
                value: _globalFontSize,
                min: 8,
                max: 72,
                onChanged: (v) {
                  _globalFontSize = v;
                  final theme = context
                      .read<FourZhuEditorViewModel>()
                      .editableThemeNotifier
                      .value;
                  final typography = theme.typography;
                  final currentFont =
                      typography.globalContent.fontStyleDataModel;
                  _emit(
                    theme.copyWith(
                      typography: typography.copyWith(
                        globalContent: typography.globalContent.copyWith(
                          fontStyleDataModel:
                              currentFont.copyWith(fontSize: _globalFontSize),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const widgets.SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: '备选字体家族(逗号分隔)',
                  helperText: '优先级：行 → 全局 → 列表 → 系统默认',
                ),
                controller: _preferredFamiliesController,
                onChanged: (v) {
                  _preferredFamiliesText = v;
                  final theme = context
                      .read<FourZhuEditorViewModel>()
                      .editableThemeNotifier
                      .value;
                  _emit(theme);
                },
              ),
            ],
          ),
        ),
        const widgets.SizedBox(height: 12),
      ],
    );
  }

  /// 构建卡片样式分区控件 - 使用ValueListenableBuilder架构
  Widget _buildCardStyleSection(BuildContext context, CardStyleConfig config) {
    return Column(
      children: [
        // 内边距滑块
        _buildSlider(
          label: '内边距',
          value: config.padding.left ?? 0.0,
          min: 0,
          max: 48,
          onChanged: (v) {
            final newConfig = config.copyWith(
              padding: EdgeInsets.all(v),
            );
            _cardStyleConfig.value = newConfig;
            // _emit(applyCardStyleConfigToTheme(_theme, newConfig));
          },
        ),
        // 圆角滑块
        _buildSlider(
          label: '圆角',
          value: config.border?.radius ?? 0.0,
          min: 0,
          max: 32,
          onChanged: (v) {
            final newConfig = config.copyWith(
              border: config.border?.copyWith(radius: v),
            );
            _cardStyleConfig.value = newConfig;
            // _emit(applyCardStyleConfigToTheme(_theme, newConfig));
          },
        ),
        // 卡片背景色控件
        ValueListenableBuilder<Brightness>(
          valueListenable:
              context.read<FourZhuEditorViewModel>().cardBrightnessNotifier,
          builder: (context, brightness, child) {
            final isLight = brightness == Brightness.light;
            return _buildColorPickerRow2(
              label: '${isLight ? "Light" : "Dark"} 卡片背景色',
              color: isLight
                  ? config.lightBackgroundColor
                  : config.darkBackgroundColor,
              onColorChanged: (color) {
                final newConfig = config.copyWith(
                  lightBackgroundColor: isLight ? color : null,
                  darkBackgroundColor: isLight ? null : color,
                );
                // Preserve the other mode's color
                final preservedConfig = newConfig.copyWith(
                  lightBackgroundColor:
                      isLight ? color : config.lightBackgroundColor,
                  darkBackgroundColor:
                      isLight ? config.darkBackgroundColor : color,
                );
                _cardStyleConfig.value = preservedConfig;
              },
            );
          },
        ),
        // 边框分区标题
        const widgets.SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('边框', style: Theme.of(context).textTheme.titleMedium),
        ),
        const widgets.SizedBox(height: 8),
        const Divider(),
        CheckboxListTile(
          title: const Text('无边框'),
          value: !(config.border?.enabled ?? true),
          onChanged: (v) {
            final next = config.copyWith(
              border: (config.border ??
                      BoxBorderStyle(
                        enabled: true,
                        width: 0,
                        lightColor: Colors.transparent,
                        darkColor: Colors.transparent,
                        radius: 0,
                      ))
                  .copyWith(enabled: !(v ?? false)),
            );
            _cardStyleConfig.value = next;
          },
        ),
        // 边框粗细滑块
        _buildSlider(
          label: '边框粗细',
          value: config.border?.width ?? 0.0,
          min: 0,
          max: 8,
          onChanged: (v) {
            final currentBorder = config.border ?? BoxBorderStyle.defaultBorder;
            final newConfig = config.copyWith(
              border: currentBorder.copyWith(width: v),
            );
            _cardStyleConfig.value = newConfig;
            // _emit(applyCardStyleConfigToTheme(_theme, newConfig));
          },
        ),
        // 边框颜色控件
        ValueListenableBuilder<Brightness>(
          valueListenable:
              context.read<FourZhuEditorViewModel>().cardBrightnessNotifier,
          builder: (context, brightness, child) {
            final isLight = brightness == Brightness.light;
            return _buildColorPickerRow2(
              label: '${isLight ? "Light" : "Dark"} 边框颜色',
              color: isLight
                  ? config.border?.lightColor
                  : config.border?.darkColor,
              onColorChanged: (color) {
                final newConfig = config.copyWith(
                  border: config.border?.copyWith(
                    lightColor: isLight ? color : config.border?.lightColor,
                    darkColor: isLight ? config.border?.darkColor : color,
                  ),
                );
                _cardStyleConfig.value = newConfig;
              },
            );
          },
        ),

        // 阴影分区标题
        const widgets.SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('阴影', style: Theme.of(context).textTheme.titleMedium),
        ),
        const widgets.SizedBox(height: 8),
        const Divider(),
        SwitchListTile(
          title: const Text('启用阴影'),
          value: config.shadow.withShadow ?? false,
          onChanged: (v) {
            final next = config.copyWith(
              shadow: config.shadow.copyWith(withShadow: v),
            );
            _cardStyleConfig.value = next;
          },
        ),
        Visibility(
          visible: config.shadow?.withShadow ?? false,
          child: Column(
            children: [
              // 阴影偏移X滑块
              _buildSlider(
                label: '阴影X偏移',
                value: config.shadow?.offset.dx ?? 0.0,
                min: -20,
                max: 20,
                onChanged: (v) {
                  final newOffset = Offset(v, config.shadow?.offset.dy ?? 0.0);
                  final newConfig = config.copyWith(
                    shadow: config.shadow?.copyWith(offset: newOffset),
                  );
                  _cardStyleConfig.value = newConfig;
                  // _emit(applyCardStyleConfigToTheme(_theme, newConfig));
                },
              ),
              // 阴影偏移Y滑块
              _buildSlider(
                label: '阴影Y偏移',
                value: config.shadow?.offset.dy ?? 0.0,
                min: -20,
                max: 20,
                onChanged: (v) {
                  final newOffset = Offset(config.shadow?.offset.dx ?? 0.0, v);
                  final newConfig = config.copyWith(
                    shadow: config.shadow?.copyWith(offset: newOffset),
                  );
                  _cardStyleConfig.value = newConfig;
                  // _emit(applyCardStyleConfigToTheme(_theme, newConfig));
                },
              ),
              // 阴影模糊半径滑块
              _buildSlider(
                label: '阴影模糊',
                value: config.shadow?.blurRadius ?? 0.0,
                min: 0,
                max: 50,
                onChanged: (v) {
                  final newConfig = config.copyWith(
                    shadow: config.shadow?.copyWith(blurRadius: v),
                  );
                  _cardStyleConfig.value = newConfig;
                  // _emit(applyCardStyleConfigToTheme(_theme, newConfig));
                },
              ),
              // 阴影扩散半径滑块
              _buildSlider(
                label: '阴影扩散',
                value: config.shadow?.spreadRadius ?? 0.0,
                min: 0,
                max: 50,
                onChanged: (v) {
                  final newConfig = config.copyWith(
                    shadow: config.shadow?.copyWith(spreadRadius: v),
                  );
                  _cardStyleConfig.value = newConfig;
                },
              ),
              // 阴影颜色控件
              ValueListenableBuilder<Brightness>(
                valueListenable: context
                    .read<FourZhuEditorViewModel>()
                    .cardBrightnessNotifier,
                builder: (context, brightness, child) {
                  final isLight = brightness == Brightness.light;
                  return _buildColorPickerRow2(
                    label: '${isLight ? "Light" : "Dark"} 阴影颜色',
                    color: isLight
                        ? config.shadow?.lightThemeColor
                        : config.shadow?.darkThemeColor,
                    onColorChanged: (color) {
                      final newConfig = config.copyWith(
                        shadow: config.shadow?.copyWith(
                          lightThemeColor: isLight ? color : null,
                          darkThemeColor: isLight ? null : color,
                        ),
                      );
                      _cardStyleConfig.value = newConfig;
                      // _emit(applyCardStyleConfigToTheme(_theme, newConfig));
                    },
                  );
                },
              ),
              // 阴影跟随背景色复选框
              CheckboxListTile(
                title: const Text('阴影跟随背景色'),
                value: config.shadow?.followCardBackgroundColor ?? false,
                onChanged: (v) {
                  final checked = v ?? false;
                  final newConfig = config.copyWith(
                    shadow: (config.shadow ?? BoxShadowStyle.defaultShadow)
                        .copyWith(
                      followCardBackgroundColor: checked,
                    ),
                  );
                  _cardStyleConfig.value = newConfig;
                  // _emit(applyCardStyleConfigToTheme(_theme, newConfig));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建颜色选择器行（修复版）
  Widget _buildColorPickerRow2({
    required String label,
    required Color? color,
    required ValueChanged<Color> onColorChanged,
  }) {
    final displayColor = color ?? Theme.of(context).colorScheme.surface;
    return Row(
      children: [
        Text(label),
        const widgets.SizedBox(width: 8),
        InkWell(
          onTap: () async {
            final picked = await showAppPalettePickerDialog(
              context,
              initialColor: color ?? Theme.of(context).colorScheme.surface,
              title: '选择$label',
            );
            if (picked == null) return;
            onColorChanged(picked);
          },
          child: ValueListenableBuilder<int>(
            valueListenable: paletteNameIndexVersion,
            builder: (context, _, __) {
              final hex = displayColor.value
                  .toRadixString(16)
                  .padLeft(8, '0')
                  .toUpperCase();
              final a8 = (displayColor.a * 255.0).round().clamp(0, 255);
              final r8 = (displayColor.r * 255.0).round().clamp(0, 255);
              final g8 = (displayColor.g * 255.0).round().clamp(0, 255);
              final b8 = (displayColor.b * 255.0).round().clamp(0, 255);
              final aPct = (a8 / 255.0 * 100).round();
              final body = '#$hex · RGBA($r8, $g8, $b8, $aPct%)';
              final name = lookupPaletteName(displayColor);
              final tooltip =
                  (name == null || name.isEmpty) ? body : '$name\n$body';
              return Tooltip(
                message: tooltip,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: displayColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(context)
                          .dividerColor
                          .withValues(alpha: 100 / 255.0),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        TextButton(
          onPressed: () async {
            final picked = await showAppPalettePickerDialog(
              context,
              initialColor: color ?? Theme.of(context).colorScheme.surface,
              title: '选择$label',
            );
            if (picked == null) return;
            onColorChanged(picked);
          },
          child: const Text('选择颜色'),
        ),
      ],
    );
  }

  /// 构建颜色选择器行
  Widget _buildColorPickerRow({
    required String label,
    required Color? color,
    required ValueChanged<Color> onColorChanged,
  }) {
    final displayColor = color ?? Theme.of(context).colorScheme.surface;
    return Row(
      children: [
        Text(label),
        const widgets.SizedBox(width: 8),
        InkWell(
            onTap: () async {
              final picked = await showAppPalettePickerDialog(
                context,
                initialColor: color ?? Theme.of(context).colorScheme.surface,
                title: '选择$label',
              );
              if (picked == null) return;
              onColorChanged(picked);
            },
            child: ValueListenableBuilder<int>(
              valueListenable: paletteNameIndexVersion,
              builder: (context, _, __) {
                final hex = displayColor.value
                    .toRadixString(16)
                    .padLeft(8, '0')
                    .toUpperCase();
                final a8 = (displayColor.a * 255.0).round().clamp(0, 255);
                final r8 = (displayColor.r * 255.0).round().clamp(0, 255);
                final g8 = (displayColor.g * 255.0).round().clamp(0, 255);
                final b8 = (displayColor.b * 255.0).round().clamp(0, 255);
                final aPct = (a8 / 255.0 * 100).round();
                final body = '#$hex · RGBA($r8, $g8, $b8, $aPct%)';
                final name = lookupPaletteName(displayColor);
                final tooltip =
                    (name == null || name.isEmpty) ? body : '$name\n$body';
                return Tooltip(
                  message: tooltip,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: displayColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 100 / 255.0),
                      ),
                    ),
                  ),
                );
              },
            )),
        TextButton(
          onPressed: () async {
            final picked = await showAppPalettePickerDialog(
              context,
              initialColor: color ?? Theme.of(context).colorScheme.surface,
              title: '选择$label',
            );
            if (picked == null) return;
            onColorChanged(picked);
          },
          child: const Text('选择颜色'),
        ),
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
            const widgets.SizedBox(height: 8),
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
    return widgets.SizedBox(
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
