import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:common/widgets/style_editor/widgets/app_palette_picker_dialog.dart';

import 'package:provider/provider.dart';
import '../../../viewmodels/four_zhu_editor_view_model.dart';
import '../../../features/four_zhu_card/widgets/editable_fourzhu_card/models/base_style_config.dart';
import 'title_slider_widget.dart';

class ShadowEditorWidget extends StatelessWidget {
  final ValueNotifier<BoxShadowStyle> shadowNotifier;
  final ValueNotifier<BaseBoxStyleConfig> styleConfigNotifier;
  const ShadowEditorWidget(
      {super.key,
      required this.shadowNotifier,
      required this.styleConfigNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BaseBoxStyleConfig>(
      valueListenable: styleConfigNotifier,
      builder: (context, config, child) =>
          ValueListenableBuilder<BoxShadowStyle>(
        valueListenable: shadowNotifier,
        builder: (context, value, child) => shadow(context, value, config),
      ),
    );
  }

  Widget shadow(
      BuildContext context, BoxShadowStyle shadow, BaseBoxStyleConfig config) {
    final _pillarShadowEnabled = shadow.withShadow ?? false;
    final _pillarShadowFollowBackground =
        shadow.followCardBackgroundColor ?? false;
    final _pillarShadowLightColor = shadow.lightThemeColor ?? Colors.black54;
    final _pillarShadowDarkColor = shadow.darkThemeColor ?? Colors.white;
    final _pillarShadowOffsetX = (shadow.offset.dx ?? 0).toDouble();
    final _pillarShadowOffsetY = (shadow.offset.dy ?? 0).toDouble();
    final _pillarShadowBlur = (shadow.blurRadius ?? 0).toDouble();
    final _pillarShadowSpread = (shadow.spreadRadius ?? 0).toDouble();

    final lightPillarShadowColor = _pillarShadowFollowBackground
        ? Colors.transparent
        : _pillarShadowLightColor;
    final darkPillarShadowColor = _pillarShadowFollowBackground
        ? Colors.transparent
        : _pillarShadowDarkColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 阴影启用
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('启用柱阴影'),
          value: _pillarShadowEnabled ?? false,
          onChanged: (v) {
            shadowNotifier.value = shadowNotifier.value.copyWith(withShadow: v);
          },
        ),
        ...(() {
          if (!_pillarShadowEnabled) return <Widget>[];
          final List<Widget> xs = [];
          xs.add(CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('阴影颜色跟随柱背景色'),
            value: _pillarShadowFollowBackground,
            onChanged: (v) {
              shadowNotifier.value = shadowNotifier.value
                  .copyWith(followCardBackgroundColor: v ?? false);
            },
          ));
          if (!_pillarShadowFollowBackground) {
            xs.add(ValueListenableBuilder<Brightness>(
              valueListenable:
                  context.read<FourZhuEditorViewModel>().cardBrightnessNotifier,
              builder: (context, brightness, child) {
                final isLight = brightness == Brightness.light;
                return Row(
                  children: [
                    Text('${isLight ? "Light" : "Dark"} 阴影颜色'),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showAppPalettePickerDialog(
                          context,
                          initialColor: _pillarShadowFollowBackground
                              ? (isLight
                                  ? (config.lightBackgroundColor ??
                                      Colors.white)
                                  : (config.darkBackgroundColor ??
                                      Colors.black))
                              : (isLight
                                  ? _pillarShadowLightColor
                                  : _pillarShadowDarkColor),
                          title: '选择阴影颜色',
                        );
                        if (picked != null) {
                          shadowNotifier.value = shadowNotifier.value.copyWith(
                            lightThemeColor: isLight
                                ? picked
                                : shadowNotifier.value.lightThemeColor,
                            darkThemeColor: isLight
                                ? shadowNotifier.value.darkThemeColor
                                : picked,
                          );
                        }
                      },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isLight
                              ? lightPillarShadowColor
                              : darkPillarShadowColor,
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
                    const Text('选择颜色'),
                  ],
                );
              },
            ));
          }
          xs.add(TitleSliderWidget(
            label: '阴影 Offset X (px)',
            value: _pillarShadowOffsetX,
            min: -24,
            max: 24,
            onChanged: (v) {
              shadowNotifier.value = shadowNotifier.value
                  .copyWith(offset: Offset(v, _pillarShadowOffsetY));
            },
          ));
          xs.add(TitleSliderWidget(
            label: '阴影 Offset Y (px)',
            value: _pillarShadowOffsetY,
            min: -24,
            max: 24,
            onChanged: (v) {
              shadowNotifier.value = shadowNotifier.value
                  .copyWith(offset: Offset(_pillarShadowOffsetX, v));
            },
          ));
          xs.add(TitleSliderWidget(
            label: '阴影模糊 (px)',
            value: _pillarShadowBlur,
            min: 0,
            max: 48,
            onChanged: (v) {
              shadowNotifier.value =
                  shadowNotifier.value.copyWith(blurRadius: v);
            },
          ));
          xs.add(TitleSliderWidget(
            label: '阴影扩散 (px)',
            value: _pillarShadowSpread,
            min: 0,
            max: 48,
            onChanged: (v) {
              shadowNotifier.value =
                  shadowNotifier.value.copyWith(spreadRadius: v);
            },
          ));
          return xs;
        })(),
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
