import 'package:common/enums/layout_template_enums.dart';
import 'package:flutter/material.dart';

import '../../../themes/editable_four_zhu_card_theme.dart';
import '../../editable_fourzhu_card/models/pillar_style_config.dart';
import '../four_zhu_pillar_style_editor.dart';

class SidebarPillarEditorSection extends StatefulWidget {
  final PillarSection pillarSection;
  final IconData icon;
  final String title;
  final ValueChanged<PillarSection>? onChanged;
  const SidebarPillarEditorSection(
      {super.key,
      required this.pillarSection,
      required this.icon,
      required this.title,
      this.onChanged});

  @override
  State<SidebarPillarEditorSection> createState() =>
      _SidebarPillarEditorSectionState();
}

class _SidebarPillarEditorSectionState extends State<SidebarPillarEditorSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late final ValueNotifier<PillarSection> _pillarStyleConfigNotifier;

  @override
  void initState() {
    super.initState();
    _pillarStyleConfigNotifier = ValueNotifier(widget.pillarSection)
      ..addListener(() {
        widget.onChanged?.call(_pillarStyleConfigNotifier.value);
      });
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant SidebarPillarEditorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pillarSection != widget.pillarSection) {
      _pillarStyleConfigNotifier.value = widget.pillarSection;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pillarStyleConfigNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder(
        valueListenable: _pillarStyleConfigNotifier,
        builder: (context, config, child) => Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
              ),
              child: ExpansionTile(
                leading: Icon(widget.icon),
                title: Text(widget.title, style: theme.textTheme.titleMedium),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  eachPillarEditor(
                      theme,
                      '全局',
                      FourZhuPillarStyleEditor(
                        pillarStyleConfig: config.global,
                        onChanged: (global) {
                          _pillarStyleConfigNotifier.value =
                              config.copyWith(global: global);
                        },
                      )),
                  ...[
                    PillarType.year,
                    PillarType.month,
                    PillarType.day,
                    PillarType.hour
                  ]
                      .map((e) => eachPillarEditor(
                          theme,
                          e.name,
                          FourZhuPillarStyleEditor(
                            pillarStyleConfig: config.getBy(e),
                            onChanged: (pillar) {
                              final Map<PillarType, PillarStyleConfig>
                                  newMapper = Map.fromEntries(config.mapper
                                      .map((k, v) => MapEntry(k, v))
                                      .entries);
                              _pillarStyleConfigNotifier.value =
                                  config.copyWith(mapper: newMapper);
                            },
                          )))
                      .toList(),
                ],
              ),
            ));
  }

  Widget eachPillarEditor(ThemeData theme, String label, Widget content) {
    return ExpansionTile(
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(label, style: theme.textTheme.titleMedium),
      ),
      childrenPadding: const EdgeInsets.all(12),
      children: [content],
    );
  }

  Widget _pillarSecion() {
    final theme = Theme.of(context);

    // final demoVm =
    //     Provider.of<FourZhuCardDemoViewModel>(context, listen: false);
    //     ValueNotifier<FouZhu> globalPillarStyleConfigNotifier = demoVm.pillarStyleConfigNotifier;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: ExpansionTile(
          leading: Icon(widget.icon),
          title: Text(widget.title, style: theme.textTheme.titleMedium),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
          children: [const Placeholder()]),
    );
  }
}
