import 'package:common/widgets/style_editor/widgets/title_slider_widget.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

import '../../editable_fourzhu_card/models/base_style_config.dart';

class BoxStyleConfigEditor extends StatelessWidget {
  final ValueNotifier<BaseBoxStyleConfig> boxStyleConfigNotifier;
  const BoxStyleConfigEditor({super.key, required this.boxStyleConfigNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: boxStyleConfigNotifier,
        builder: (ctx, config, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 外边距控制
              TitleSliderWidget(
                label: '默认外边距-水平 (px)',
                value: config.margin.left,
                min: 0,
                max: 48,
                onChanged: (v) {
                  boxStyleConfigNotifier.value = config.copyWith(
                    margin: EdgeInsets.symmetric(
                        horizontal: v, vertical: config.margin.top),
                  );
                },
              ),
              TitleSliderWidget(
                label: '默认外边距-垂直 (px)',
                value: config.margin.top,
                min: 0,
                max: 48,
                onChanged: (v) {
                  boxStyleConfigNotifier.value = config.copyWith(
                    margin: EdgeInsets.symmetric(
                        horizontal: config.margin.left, vertical: v),
                  );
                },
              ),
              // 内边距控制
              TitleSliderWidget(
                label: '默认内边距-水平 (px)',
                value: config.padding.left,
                min: 0,
                max: 48,
                onChanged: (v) {
                  boxStyleConfigNotifier.value = config.copyWith(
                    padding: EdgeInsets.symmetric(
                        horizontal: v, vertical: config.padding.top),
                  );
                },
              ),
              TitleSliderWidget(
                label: '默认内边距-垂直 (px)',
                value: config.padding.top,
                min: 0,
                max: 48,
                onChanged: (v) {
                  boxStyleConfigNotifier.value = config.copyWith(
                    padding: EdgeInsets.symmetric(
                        horizontal: config.padding.left, vertical: v),
                  );
                },
              ),
              // 柱背景色控制
              Row(
                children: [
                  const Text('light 柱背景色'),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => updateLightBackgroundColor(context, config),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: config.lightBackgroundColor ??
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
                    onPressed: () =>
                        updateLightBackgroundColor(context, config),
                    child: const Text('选择颜色'),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              // 柱背景色控制
              Row(
                children: [
                  const Text('dark 柱背景色'),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => updateDarkBackgroundolor(context, config),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: config.darkBackgroundColor ??
                            Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest,
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
                    onPressed: () => updateDarkBackgroundolor(context, config),
                    child: const Text('选择颜色'),
                  ),
                ],
              ),
            ],
          );
        });
  }

  void updateDarkBackgroundolor(
      BuildContext context, BaseBoxStyleConfig config) async {
    final picked = await showColorPickerDialog(
      context,
      config.darkBackgroundColor ??
          Theme.of(context).colorScheme.surfaceContainerLowest,
      title: const Text('选择颜色'),
      pickersEnabled: const {
        ColorPickerType.wheel: true,
        ColorPickerType.accent: false,
        ColorPickerType.primary: false,
        ColorPickerType.custom: false,
      },
    );
    boxStyleConfigNotifier.value = config.copyWith(
      darkBackgroundColor: picked,
    );
  }

  void updateLightBackgroundColor(
      BuildContext context, BaseBoxStyleConfig config) async {
    final picked = await showColorPickerDialog(
      context,
      config.lightBackgroundColor ??
          Theme.of(context).colorScheme.surfaceContainerHighest,
      title: const Text('选择颜色'),
      pickersEnabled: const {
        ColorPickerType.wheel: true,
        ColorPickerType.accent: false,
        ColorPickerType.primary: false,
        ColorPickerType.custom: false,
      },
    );
    boxStyleConfigNotifier.value = config.copyWith(
      lightBackgroundColor: picked,
    );
  }
}
