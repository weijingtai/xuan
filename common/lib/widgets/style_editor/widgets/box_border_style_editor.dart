import 'package:common/widgets/style_editor/widgets/title_slider_widget.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:common/widgets/style_editor/widgets/app_palette_picker_dialog.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../viewmodels/four_zhu_editor_view_model.dart';
import '../../../features/four_zhu_card/widgets/editable_fourzhu_card/models/base_style_config.dart';

class BoxBorderStyleEditor extends StatelessWidget {
  final ValueNotifier<BoxBorderStyle> borderNotifier;
  final ValueNotifier<BaseBoxStyleConfig> styleConfigNotifier;
  const BoxBorderStyleEditor(
      {super.key,
      required this.borderNotifier,
      required this.styleConfigNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BoxBorderStyle>(
      valueListenable: borderNotifier,
      builder: (context, value, child) => border(context, value),
    );
  }

  Widget border(BuildContext context, BoxBorderStyle border) {
    final _pillarBorderWidth = (border.width ?? 2).toDouble();
    final _pillarCornerRadius = (border.radius ?? 0).toDouble();
    final _pillarBorderColorLight = border.lightColor;
    final _pillarBorderColorDark = border.darkColor;
    return Column(
      children: [
        // 启用边框
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('启用边框'),
          value: border.enabled,
          onChanged: (v) {
            borderNotifier.value = border.copyWith(enabled: v);
          },
        ),
        ...(() {
          if (!(border.enabled ?? false)) return <Widget>[];
          final List<Widget> xs = [];
          xs.add(TitleSliderWidget(
            label: '边框宽度 (px)',
            value: _pillarBorderWidth,
            min: 0,
            max: 8,
            onChanged: (v) {
              borderNotifier.value = border.copyWith(width: v);
              // 清除CardSizeManager缓存，确保尺寸重新计算
              _clearCardSizeCache(context);
            },
          ));
          xs.add(TitleSliderWidget(
            label: '柱圆角 (px)',
            value: _pillarCornerRadius,
            min: 0,
            max: 32,
            onChanged: (v) {
              borderNotifier.value = border.copyWith(radius: v);
              // 清除CardSizeManager缓存，确保尺寸重新计算
              _clearCardSizeCache(context);
            },
          ));
          xs.add(ValueListenableBuilder<Brightness>(
            valueListenable:
                context.read<FourZhuEditorViewModel>().cardBrightnessNotifier,
            builder: (context, brightness, child) {
              final isLight = brightness == Brightness.light;
              return Row(
                children: [
                  Text('${isLight ? "Light" : "Dark"} 柱边框颜色'),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => isLight
                        ? updateLightBorderColor(context, border)
                        : updateDarkBorderColor(context, border),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isLight
                            ? _pillarBorderColorLight
                            : _pillarBorderColorDark,
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
                    onPressed: () => isLight
                        ? updateLightBorderColor(context, border)
                        : updateDarkBorderColor(context, border),
                    child: const Text('选择颜色'),
                  ),
                ],
              );
            },
          ));
          return xs;
        })(),
      ],
    );
  }

  void updateDarkBorderColor(
      BuildContext context, BoxBorderStyle border) async {
    final picked = await showAppPalettePickerDialog(
      context,
      initialColor: border.darkColor,
      title: '选择颜色',
    );
    borderNotifier.value = border.copyWith(
      darkColor: picked,
    );
    // 清除CardSizeManager缓存，确保尺寸重新计算
    _clearCardSizeCache(context);
  }

  void updateLightBorderColor(
      BuildContext context, BoxBorderStyle border) async {
    final picked = await showAppPalettePickerDialog(
      context,
      initialColor: border.lightColor,
      title: '选择颜色',
    );
    borderNotifier.value = border.copyWith(
      lightColor: picked,
    );
    // 清除CardSizeManager缓存，确保尺寸重新计算
    _clearCardSizeCache(context);
  }

  /// 清除CardSizeManager缓存，触发尺寸重新计算
  void _clearCardSizeCache(BuildContext context) {
    try {
      // 通过ViewModel访问CardSizeManager
      final viewModel = context.read<FourZhuEditorViewModel>();
      // 调用CardSizeManager的clearCache方法
      viewModel.cardSizeManager?.clearCache();
    } catch (e) {
      // 忽略错误，可能在某些上下文中不可用
    }
  }
}
