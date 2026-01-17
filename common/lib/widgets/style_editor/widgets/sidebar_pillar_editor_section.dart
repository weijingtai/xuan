import 'package:common/enums/layout_template_enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/four_zhu_editor_view_model.dart';
import '../../../models/drag_payloads.dart';

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
  bool _suppressOnChanged = false;

  @override
  void initState() {
    super.initState();
    _pillarStyleConfigNotifier = ValueNotifier(widget.pillarSection)
      ..addListener(() {
        if (_suppressOnChanged) return;
        widget.onChanged?.call(_pillarStyleConfigNotifier.value);
      });
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant SidebarPillarEditorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pillarSection != widget.pillarSection) {
      _suppressOnChanged = true;
      _pillarStyleConfigNotifier.value = widget.pillarSection;
      _suppressOnChanged = false;
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
    return ValueListenableBuilder(
        valueListenable: _pillarStyleConfigNotifier,
        builder: (context, config, child) {
          final editorVm = context.read<FourZhuEditorViewModel>();

          return ValueListenableBuilder<CardPayload>(
              valueListenable: editorVm.cardPayloadNotifier,
              builder: (context, payload, _) {
                final theme = Theme.of(context);
                final orderedUuids = payload.pillarOrderUuid.toList();

                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.12)),
                  ),
                  child: ExpansionTile(
                    leading: Icon(widget.icon),
                    title:
                        Text(widget.title, style: theme.textTheme.titleMedium),
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
                      ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        onReorder: (oldIndex, newIndex) {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }

                          final newUuids = List<String>.from(orderedUuids);
                          final item = newUuids.removeAt(oldIndex);
                          newUuids.insert(newIndex, item);

                        final newTypes = newUuids
                              .map((id) => payload.pillarMap[id]!.pillarType)
                              .toList();

                          final groupId = editorVm.selectedGroupId ??
                              editorVm
                                  .currentTemplate?.chartGroups.firstOrNull?.id;
                          if (groupId != null) {
                            editorVm.updatePillarOrderInGroup(groupId, newTypes);
                          }

                          editorVm.updatePillarOrderFromTypes(newTypes);
                        },
                        children: [
                          for (int i = 0; i < orderedUuids.length; i++)
                            Container(
                              key: ValueKey(orderedUuids[i]),
                              child: eachPillarEditor(
                                theme,
                                payload.pillarMap[orderedUuids[i]]!
                                            .pillarType ==
                                        PillarType.rowTitleColumn
                                    ? '标题列'
                                    : payload.pillarMap[orderedUuids[i]]!
                                        .pillarType.name,
                                FourZhuPillarStyleEditor(
                                  showSeparatorWidth: payload
                                          .pillarMap[orderedUuids[i]]!
                                          .pillarType ==
                                      PillarType.separator,
                                  showTitleColumnFontEditor: payload
                                          .pillarMap[orderedUuids[i]]!
                                          .pillarType ==
                                      PillarType.rowTitleColumn,
                                  pillarStyleConfig: config.getBy(payload
                                      .pillarMap[orderedUuids[i]]!.pillarType),
                                  onChanged: (pillar) {
                                    final type = payload
                                        .pillarMap[orderedUuids[i]]!.pillarType;
                                    if (type == PillarType.separator) {
                                      // 如果是 separator，更新 defaultSeparatorConfig
                                      // 同时清理 mapper 中的 separator 配置，防止覆盖
                                      final newMapper = Map<PillarType,
                                              PillarStyleConfig>.from(
                                          config.mapper);
                                      newMapper.remove(PillarType.separator);

                                      _pillarStyleConfigNotifier.value =
                                          config.copyWith(
                                        defaultSeparatorConfig: pillar,
                                        mapper: newMapper,
                                      );
                                    } else {
                                      final Map<PillarType, PillarStyleConfig>
                                          newMapper =
                                          Map<PillarType, PillarStyleConfig>.of(
                                              config.mapper);
                                      newMapper[type] = pillar;
                                      _pillarStyleConfigNotifier.value =
                                          config.copyWith(mapper: newMapper);
                                    }
                                  },
                                ),
                                leading: ReorderableDragStartListener(
                                  index: i,
                                  child: const Icon(Icons.drag_handle),
                                ),
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                );
              });
        });
  }

  Widget eachPillarEditor(ThemeData theme, String label, Widget content,
      {Widget? leading}) {
    return ExpansionTile(
      leading: leading,
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(label, style: theme.textTheme.titleMedium),
      ),
      childrenPadding: const EdgeInsets.all(12),
      children: [content],
    );
  }
}
