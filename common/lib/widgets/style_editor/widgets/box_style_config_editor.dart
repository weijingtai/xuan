import 'package:common/widgets/style_editor/widgets/title_slider_widget.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:common/widgets/style_editor/widgets/app_palette_picker_dialog.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../viewmodels/four_zhu_editor_view_model.dart';
import '../../../features/four_zhu_card/widgets/editable_fourzhu_card/models/base_style_config.dart';

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
                    margin: EdgeInsets.only(
                      left: v,
                      right: v,
                      top: config.margin.top,
                      bottom: config.margin.bottom,
                    ),
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
                    margin: EdgeInsets.only(
                      left: config.margin.left,
                      right: config.margin.right,
                      top: v,
                      bottom: v,
                    ),
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
                    padding: EdgeInsets.only(
                      left: v,
                      right: v,
                      top: config.padding.top,
                      bottom: config.padding.bottom,
                    ),
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
                    padding: EdgeInsets.only(
                      left: config.padding.left,
                      right: config.padding.right,
                      top: v,
                      bottom: v,
                    ),
                  );
                },
              ),
              // 柱背景色控制
              ValueListenableBuilder<Brightness>(
                valueListenable: context
                    .read<FourZhuEditorViewModel>()
                    .cardBrightnessNotifier,
                builder: (context, brightness, child) {
                  final isLight = brightness == Brightness.light;
                  return Row(
                    children: [
                      Text('${isLight ? "Light" : "Dark"} 柱背景色'),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => isLight
                            ? updateLightBackgroundColor(context, config)
                            : updateDarkBackgroundolor(context, config),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isLight
                                ? (config.lightBackgroundColor ??
                                    Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest)
                                : (config.darkBackgroundColor ??
                                    Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLowest),
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
                            ? updateLightBackgroundColor(context, config)
                            : updateDarkBackgroundolor(context, config),
                        child: const Text('选择颜色'),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        });
  }

  void updateDarkBackgroundolor(
      BuildContext context, BaseBoxStyleConfig config) async {
    final picked = await showAppPalettePickerDialog(
      context,
      initialColor: config.darkBackgroundColor ??
          Theme.of(context).colorScheme.surfaceContainerLowest,
      title: '选择颜色',
    );
    boxStyleConfigNotifier.value = config.copyWith(
      darkBackgroundColor: picked,
    );
  }

  void updateLightBackgroundColor(
      BuildContext context, BaseBoxStyleConfig config) async {
    final picked = await showAppPalettePickerDialog(
      context,
      initialColor: config.lightBackgroundColor ??
          Theme.of(context).colorScheme.surfaceContainerHighest,
      title: '选择颜色',
    );
    boxStyleConfigNotifier.value = config.copyWith(
      lightBackgroundColor: picked,
    );
  }
}
