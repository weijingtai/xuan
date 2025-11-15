import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../editable_fourzhu_card/models/base_style_config.dart';
import '../../editable_fourzhu_card/models/pillar_style_config.dart';
import 'title_slider_widget.dart';

class ShadowEditorWidget extends StatelessWidget {
  final ValueNotifier<BoxShadowStyle> shadowNotifier;
  final ValueNotifier<PillarStyleConfig> styleConfigNotifier;
  const ShadowEditorWidget(
      {super.key,
      required this.shadowNotifier,
      required this.styleConfigNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PillarStyleConfig>(
      valueListenable: styleConfigNotifier,
      builder: (context, config, child) =>
          ValueListenableBuilder<BoxShadowStyle>(
        valueListenable: shadowNotifier,
        builder: (context, value, child) => shadow(context, value, config),
      ),
    );
  }

  Widget shadow(
      BuildContext context, BoxShadowStyle shadow, PillarStyleConfig config) {
    final _pillarShadowEnabled = shadow.withShadow ?? false;
    final _pillarShadowFollowBackground =
        shadow.followCardBackgroundColor ?? false;
    final _pillarShadowLightColor = shadow.lightThemeColor ?? Colors.black54;
    final _pillarShadowDarkColor = shadow.darkThemeColor ?? Colors.white;
    final _pillarShadowOffsetX = (shadow.offset.dx ?? 0).toDouble();
    final _pillarShadowOffsetY = (shadow.offset.dy ?? 0).toDouble();
    final _pillarShadowBlur = (shadow.blurRadius ?? 0).toDouble();
    final _pillarShadowSpread = (shadow.spreadRadius ?? 0).toDouble();
    final _pillarShadowOpacity = (shadow.opacity ?? 0.35).toDouble();

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
        // 阴影跟随背景色
        if (_pillarShadowEnabled)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('阴影颜色跟随柱背景色'),
            value: _pillarShadowFollowBackground,
            onChanged: (v) {
              shadowNotifier.value = shadowNotifier.value
                  .copyWith(followCardBackgroundColor: v ?? false);
            },
          ),
        // 阴影颜色选择（仅当不跟随背景色时显示）
        if (_pillarShadowEnabled && !_pillarShadowFollowBackground)
          Row(
            children: [
              const Text('Light 阴影颜色'),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  final picked = await showColorPickerDialog(
                    context,
                    // _parseHexColor(_pillarShadowHex) ?? Colors.black54,
                    _pillarShadowFollowBackground
                        ? config.lightBackgroundColor ?? Colors.white
                        : _pillarShadowLightColor,

                    title: const Text('选择阴影颜色'),
                    pickersEnabled: const {
                      ColorPickerType.wheel: true,
                      ColorPickerType.accent: false,
                      ColorPickerType.primary: false,
                      ColorPickerType.custom: false,
                    },
                  );
                  shadowNotifier.value =
                      shadowNotifier.value.copyWith(lightThemeColor: picked);
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: lightPillarShadowColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color:
                          Theme.of(context).dividerColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text('选择颜色'),
            ],
          ),
        if (_pillarShadowEnabled && !_pillarShadowFollowBackground)
          Row(
            children: [
              const Text('Dark 阴影颜色'),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  final picked = await showColorPickerDialog(
                    context,
                    _pillarShadowFollowBackground
                        ? config.darkBackgroundColor ?? Colors.white
                        : _pillarShadowDarkColor,
                    title: const Text('选择阴影颜色'),
                    pickersEnabled: const {
                      ColorPickerType.wheel: true,
                      ColorPickerType.accent: false,
                      ColorPickerType.primary: false,
                      ColorPickerType.custom: false,
                    },
                  );
                  shadowNotifier.value =
                      shadowNotifier.value.copyWith(lightThemeColor: picked);
                  // setState(() {
                  //   _pillarShadowHex =
                  //       '#${picked.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                  // });
                  // _emit(_theme.copyWith(pillar: _composePillarSection()));
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: darkPillarShadowColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color:
                          Theme.of(context).dividerColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text('选择颜色'),
            ],
          ),
        // 偏移/模糊/扩散/透明度

        if (_pillarShadowEnabled)
          TitleSliderWidget(
            label: '阴影 Offset X (px)',
            value: _pillarShadowOffsetX,
            min: -24,
            max: 24,
            onChanged: (v) {
              shadowNotifier.value = shadowNotifier.value
                  .copyWith(offset: Offset(v, _pillarShadowOffsetY));
            },
          ),
        if (_pillarShadowEnabled)
          TitleSliderWidget(
            label: '阴影 Offset Y (px)',
            value: _pillarShadowOffsetY,
            min: -24,
            max: 24,
            onChanged: (v) {
              shadowNotifier.value = shadowNotifier.value
                  .copyWith(offset: Offset(_pillarShadowOffsetX, v));
            },
          ),
        if (_pillarShadowEnabled)
          TitleSliderWidget(
            label: '阴影模糊 (px)',
            value: _pillarShadowBlur,
            min: 0,
            max: 48,
            onChanged: (v) {
              shadowNotifier.value =
                  shadowNotifier.value.copyWith(blurRadius: v);
            },
          ),
        if (_pillarShadowEnabled)
          TitleSliderWidget(
            label: '阴影扩散 (px)',
            value: _pillarShadowSpread,
            min: 0,
            max: 48,
            onChanged: (v) {
              shadowNotifier.value =
                  shadowNotifier.value.copyWith(spreadRadius: v);
            },
          ),
        if (_pillarShadowEnabled)
          TitleSliderWidget(
            label: '阴影透明度',
            value: _pillarShadowOpacity,
            min: 0,
            max: 1,
            onChanged: (v) {
              shadowNotifier.value = shadowNotifier.value.copyWith(opacity: v);
            },
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
