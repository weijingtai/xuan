import 'package:common/models/pillar_styles.dart';
import 'package:common/widgets/style_editor/widgets/box_style_config_editor.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:provider/provider.dart';

import '../../enums/layout_template_enums.dart';
import '../../themes/editable_four_zhu_card_theme.dart';
import '../../viewmodels/four_zhu_card_demo_viewmodel.dart';
import '../editable_fourzhu_card/models/base_style_config.dart';
import '../editable_fourzhu_card/models/pillar_style_config.dart';
import 'widgets/box_border_style_editor.dart';
import 'widgets/box_shadow_style_editor.dart';

/// FourZhuPillarStyleEditor
/// 独立的柱样式编辑器面板，用于编辑四柱卡片的柱样式配置。
///
/// 提供对柱的外边距、内边距、边框、背景色、阴影等样式的编辑控制，
/// 支持实时 `onChanged` 回调用于外部预览绑定。
class FourZhuPillarStyleEditor extends StatefulWidget {
  // final ValueNotifier<PillarStyleConfig> global;
  // final ValueNotifier<PillarStyleConfig> pillarStyleConfigNotifier;
  final PillarStyleConfig pillarStyleConfig;
  final ValueChanged<PillarStyleConfig>? onChanged;

  /// 创建柱样式编辑器面板。
  ///
  /// 参数：
  /// - [theme]: 初始的 `EditableFourZhuCardTheme` 主题对象
  /// - [onChanged]: 主题更新时的回调函数
  ///
  // final String pillarUUID;
  // final String pillarName;
  const FourZhuPillarStyleEditor({
    super.key,
    required this.pillarStyleConfig,
    required this.onChanged,
    // required this.pillarStyleConfigNotifier,
  });

  /// 当前编辑的主题状态
  // final RowType rowType;
  // final EditableFourZhuCardTheme theme;
  // final bool compact;

  /// 变更处理器，在任何编辑操作时调用
  // final ValueChanged<EditableFourZhuCardTheme> onChanged;

  @override
  State<FourZhuPillarStyleEditor> createState() =>
      _FourZhuPillarStyleEditorState();
}

class _FourZhuPillarStyleEditorState extends State<FourZhuPillarStyleEditor> {
  // late EditableFourZhuCardTheme _theme;

  late final ValueNotifier<BoxShadowStyle> _pillarShadowNotifier;
  late final ValueNotifier<BoxBorderStyle> _pillarBorderNotifier;
  late final ValueNotifier<PillarStyleConfig> _pillarStyleConfigNotifier;

  @override
  void initState() {
    super.initState();
    // _theme = widget.theme;
    _pillarStyleConfigNotifier = ValueNotifier(widget.pillarStyleConfig)
      ..addListener(() {
        widget.onChanged?.call(_pillarStyleConfigNotifier.value);
      });

    _pillarShadowNotifier =
        ValueNotifier(_pillarStyleConfigNotifier.value.shadow)
          ..addListener(() {
            _pillarStyleConfigNotifier.value = _pillarStyleConfigNotifier.value
                .copyWith(shadow: _pillarShadowNotifier.value);
          });
    _pillarBorderNotifier = ValueNotifier(BoxBorderStyle.defaultBorder)
      ..addListener(() {
        _pillarStyleConfigNotifier.value = _pillarStyleConfigNotifier.value
            .copyWith(border: _pillarBorderNotifier.value);
      });
  }

  @override
  void didUpdateWidget(covariant FourZhuPillarStyleEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pillarStyleConfig != widget.pillarStyleConfig) {
      _pillarStyleConfigNotifier.value = widget.pillarStyleConfig;
    }
  }

  // // 更新新的 pillar 样式配置 搭配ViewModel 中
  // void updateTheme(PillarStyleConfig newPillarStyle) {
  //   _pillarStyleConfigNotifier.value = newPillarStyle;
  // }

  @override
  void dispose() {
    _pillarShadowNotifier.dispose();
    _pillarBorderNotifier.dispose();
    _pillarStyleConfigNotifier.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _pillarStyleConfigNotifier,
      builder: (context, config, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 外边距、内边距控制
          BoxStyleConfigEditor(
            boxStyleConfigNotifier: _pillarStyleConfigNotifier,
          ),
          const SizedBox(height: 8),
          BoxBorderStyleEditor(
            borderNotifier: _pillarBorderNotifier,
            styleConfigNotifier: _pillarStyleConfigNotifier,
          ),
          const SizedBox(height: 8),
          ShadowEditorWidget(
            shadowNotifier: _pillarShadowNotifier,
            styleConfigNotifier: _pillarStyleConfigNotifier,
          ),
        ],
      ),
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
