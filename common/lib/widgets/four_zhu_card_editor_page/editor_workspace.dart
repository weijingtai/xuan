import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/widgets/editable_fourzhu_card.dart';
import 'package:common/widgets/pillar_tag_bar.dart';
import 'package:common/widgets/row_tag_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/layout_template_enums.dart';
import '../../models/eight_chars.dart';
import '../../models/text_style_config.dart';
import '../../viewmodels/four_zhu_editor_view_model.dart';

class EditorWorkspace extends StatefulWidget {
  /// 组件内部展示的八字数据，用于填充四柱内容。
  /// 参数：
  /// - eightChars：四柱八字（年、月、日、时）数据。
  /// 返回值：无（Widget组件）。
  const EditorWorkspace({super.key, required this.eightChars});

  final EightChars eightChars;

  @override
  State<EditorWorkspace> createState() => EditorWorkspaceState();
}

class EditorWorkspaceState extends State<EditorWorkspace> {
  /// 本地主题开关：true 为 Dark，false 为 Light。
  bool _didInitWorkspaceBrightness = false;

  final ValueNotifier<bool> _showGripNotifier = ValueNotifier<bool>(true);
  // final ValueNotifier<bool> _showGripColumnsNotifier =
  // ValueNotifier<bool>(true);

  /// 初始化卡片数据源（不访问 Theme）
  /// 参数：无
  /// 返回：无
  @override
  void initState() {
    super.initState();
    // 注意：不要在 initState 中调用 Theme.of(context)
  }

  /// 在依赖可用后初始化一次本地主题开关
  /// 参数：无
  /// 返回：无
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitWorkspaceBrightness) return;
    _didInitWorkspaceBrightness = true;
    final brightness = Theme.of(context).brightness;
    final editorVm = context.read<FourZhuEditorViewModel>();
    editorVm.cardBrightnessNotifier.value = brightness;
  }

  /// 响应外部八字数据变化，更新柱载荷
  /// 参数：oldWidget 旧组件实例
  /// 返回：无
  @override
  void didUpdateWidget(covariant EditorWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.eightChars != widget.eightChars) {
    //   _pillarsNotifier.value = _buildPillars(widget.eightChars);
    // }
  }

  /// 释放 Notifier 资源
  /// 参数：无
  /// 返回：无
  @override
  void dispose() {
    // 释放 Notifier 资源
    // _pillarsNotifier.dispose();
    _showGripNotifier.dispose();
    // _showGripColumnsNotifier.dispose();
    super.dispose();
  }

  Future<void> _saveWithFeedback(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
  ) async {
    await viewModel.saveCurrentTemplate();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('模板已保存')),
    );
    await viewModel.refreshRowConfigs();
  }

  Future<void> _promptCreateGroup(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('创建分组'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入分组名称'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('确定')),
        ],
      ),
    );
    if (!context.mounted) return;
    if (name != null) {
      context.read<FourZhuEditorViewModel>().addGroup(title: name);
    }
  }

  Future<void> _promptDeleteSelectedGroup(BuildContext context) async {
    final vm = context.read<FourZhuEditorViewModel>();
    final groups = vm.currentTemplate?.chartGroups ?? const [];
    if (groups.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('至少需要保留一个分组')),
      );
      return;
    }
    final selectedId = vm.selectedGroupId ?? groups.first.id;
    final selected = groups.firstWhere((g) => g.id == selectedId,
        orElse: () => groups.first);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除分组'),
        content: Text('确认删除分组“${selected.title}”？该操作不可撤销。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('删除')),
        ],
      ),
    );
    if (ok == true) {
      vm.removeGroup(selected.id);
    }
  }

  Future<void> _showCreateTemplateDialog(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
  ) async {
    final controller = TextEditingController();
    final createdName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('新建模板'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '输入模板名称',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
    if (!context.mounted || createdName == null) {
      return;
    }
    await viewModel.createTemplate(
      name: createdName.isEmpty ? null : createdName,
    );
  }

  Future<void> _showSaveAsDialog(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
  ) async {
    final controller = TextEditingController();
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('另存为新模板'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '输入新模板名称',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || newName == null) {
      return;
    }
    await viewModel.saveTemplateAs(newName);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
  ) async {
    final template = viewModel.currentTemplate;
    if (template == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('删除模板'),
          content: Text(
            '确认删除模板“${template.name}”？该操作不可撤销。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.9),
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await viewModel.deleteCurrentTemplate();
    }
  }

  Future<void> _confirmResetTemplates(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('重置模板'),
          content: const Text('将删除本地所有模板并重建默认模板。此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.9),
              ),
              child: const Text('重置'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await viewModel.resetTemplatesToDefault();
    }
  }

  /// 构建工作区：顶部 DayNightSwitch 切换本地主题，内容区使用单视图重叠显示
  /// 参数：context 构建上下文
  /// 返回：组件树
  @override
  Widget build(BuildContext context) {
    return Consumer<FourZhuEditorViewModel>(
      builder: (context, viewModel, _) {
        return ValueListenableBuilder<Brightness>(
          valueListenable: viewModel.cardBrightnessNotifier,
          builder: (context, workspaceBrightness, _) {
            final workspaceLocalTheme = workspaceBrightness == Brightness.dark
                ? ThemeData.dark()
                : ThemeData.light();

            final currentTemplate = viewModel.currentTemplate;

            return SizedBox.expand(
              child: Theme(
                data: workspaceLocalTheme,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  color: workspaceLocalTheme.colorScheme.surface,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 240,
                                alignment: Alignment.topCenter,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.brightness_6),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '工作区明暗',
                                            style: workspaceLocalTheme
                                                .textTheme.bodyMedium,
                                          ),
                                        ),
                                        Switch(
                                          value: workspaceBrightness ==
                                              Brightness.dark,
                                          onChanged: (v) {
                                            viewModel
                                                    .cardBrightnessNotifier
                                                    .value =
                                                v
                                                    ? Brightness.dark
                                                    : Brightness.light;
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ValueListenableBuilder<ColorPreviewMode>(
                                      valueListenable:
                                          viewModel.colorPreviewModeNotifier,
                                      builder: (context, mode, _) {
                                        return Row(
                                          children: [
                                            const Icon(Icons.invert_colors),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '颜色预览模式',
                                                style: workspaceLocalTheme
                                                    .textTheme.bodyMedium,
                                              ),
                                            ),
                                            ToggleButtons(
                                              isSelected: [
                                                mode == ColorPreviewMode.pure,
                                                mode ==
                                                    ColorPreviewMode.colorful,
                                                mode ==
                                                    ColorPreviewMode.blackwhite,
                                              ],
                                              onPressed: (index) {
                                                ColorPreviewMode next = mode;
                                                if (index == 0) {
                                                  next =
                                                      ColorPreviewMode.pure;
                                                } else if (index == 1) {
                                                  next = ColorPreviewMode
                                                      .colorful;
                                                } else if (index == 2) {
                                                  next = ColorPreviewMode
                                                      .blackwhite;
                                                }
                                                viewModel
                                                    .colorPreviewModeNotifier
                                                    .value = next;
                                              },
                                              constraints: const BoxConstraints(
                                                minHeight: 32,
                                                minWidth: 52,
                                              ),
                                              children: const [
                                                Padding(
                                                  padding: EdgeInsets
                                                      .symmetric(
                                                          horizontal: 10),
                                                  child: Text('纯色'),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets
                                                      .symmetric(
                                                          horizontal: 10),
                                                  child: Text('色彩'),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets
                                                      .symmetric(
                                                          horizontal: 10),
                                                  child: Text('黑白'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.drag_handle),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '显示抓手行列',
                                            style: workspaceLocalTheme
                                                .textTheme.bodyMedium,
                                          ),
                                        ),
                                        Switch(
                                          value: _showGripNotifier.value,
                                          onChanged: (v) => setState(() =>
                                              _showGripNotifier.value = v),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 156),
                              child: Center(
                                child: EditableFourZhuCardV3(
                                  dayGanZhi: JiaZi.JIA_ZI,
                                  brightnessNotifier:
                                      viewModel.cardBrightnessNotifier,
                                  colorPreviewModeNotifier:
                                      viewModel.colorPreviewModeNotifier,
                                  cardPayloadNotifier:
                                      viewModel.cardPayloadNotifier,
                                  showGrip: _showGripNotifier.value,
                                  paddingNotifier: viewModel.paddingNotifier,
                                  themeNotifier: viewModel.editableThemeNotifier,
                                  rowStrategyMapper: viewModel.rowStrategyMapper,
                                  gender: Gender.male,
                                  onReorderRow: viewModel.reorderRow,
                                  onInsertRow: viewModel.insertRow,
                                  onDeleteRow: viewModel.deleteRow,
                                  onReorderPillar:
                                      viewModel.reorderPillarGlobal,
                                  onInsertPillar:
                                      viewModel.insertPillarGlobal,
                                  onDeletePillar:
                                      viewModel.deletePillarGlobal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxHeight: 104),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: workspaceLocalTheme
                                        .colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: workspaceLocalTheme.dividerColor
                                          .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: 28, child: RowTagBar()),
                                      SizedBox(height: 8),
                                      SizedBox(
                                          height: 28, child: PillarTagBar()),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 44,
                                child: Row(
                                  children: [
                                    _HoverExpandActionButton(
                                      icon: Icons.undo,
                                      label: '撤销',
                                      onPressed: viewModel.canUndo
                                          ? viewModel.undoLastChange
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    _HoverExpandActionButton(
                                      icon: Icons.redo,
                                      label: '重做',
                                      onPressed: viewModel.canRedo
                                          ? viewModel.redoLastChange
                                          : null,
                                    ),
                                    const Spacer(),
                                    _HoverExpandActionButton(
                                      icon: Icons.save,
                                      label: '保存',
                                      onPressed: viewModel.canSave
                                          ? () => _saveWithFeedback(
                                                context,
                                                viewModel,
                                              )
                                          : null,
                                      emphasized: true,
                                    ),
                                    const SizedBox(width: 8),
                                    _HoverExpandActionButton(
                                      icon: Icons.save_as_outlined,
                                      label: '另存为',
                                      onPressed: viewModel.isLoading ||
                                              currentTemplate == null
                                          ? null
                                          : () => _showSaveAsDialog(
                                                context,
                                                viewModel,
                                              ),
                                    ),
                                    const Spacer(),
                                    _HoverExpandActionButton(
                                      icon: Icons.restart_alt,
                                      label: '重置',
                                      onPressed: viewModel.canRevert
                                          ? viewModel.revertChanges
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    _HoverExpandActionButton(
                                      icon: Icons.add,
                                      label: '创建',
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () => _promptCreateGroup(context),
                                    ),
                                    const SizedBox(width: 8),
                                    _HoverExpandActionButton(
                                      icon: Icons.delete_outline,
                                      label: '删除分组',
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () =>
                                              _promptDeleteSelectedGroup(
                                                  context),
                                    ),
                                    const SizedBox(width: 8),
                                    _HoverExpandMenuButton(
                                      icon: Icons.more_horiz,
                                      label: '更多',
                                      enabled: !viewModel.isLoading,
                                      onSelected: (value) {
                                        if (value == 'create_template') {
                                          _showCreateTemplateDialog(
                                              context, viewModel);
                                          return;
                                        }
                                        if (currentTemplate == null) return;
                                        if (value == 'duplicate_template') {
                                          viewModel.duplicateCurrentTemplate();
                                        } else if (value == 'delete_template') {
                                          _confirmDelete(context, viewModel);
                                        } else if (value == 'reset_templates') {
                                          _confirmResetTemplates(
                                              context, viewModel);
                                        }
                                      },
                                      items: (context) => [
                                        const PopupMenuItem(
                                          value: 'create_template',
                                          child: Text('新建模板'),
                                        ),
                                        PopupMenuItem(
                                          enabled: currentTemplate != null,
                                          value: 'duplicate_template',
                                          child: const Text('复制模板'),
                                        ),
                                        PopupMenuItem(
                                          enabled: currentTemplate != null,
                                          value: 'delete_template',
                                          child: Text(
                                            '删除模板',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'reset_templates',
                                          child: Text('重置模板'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HoverExpandActionButton extends StatefulWidget {
  const _HoverExpandActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool emphasized;

  @override
  State<_HoverExpandActionButton> createState() => _HoverExpandActionButtonState();
}

class _HoverExpandActionButtonState extends State<_HoverExpandActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final theme = Theme.of(context);

    final fillColor = widget.emphasized
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final fgColor = widget.emphasized
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return MouseRegion(
      onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        width: _hovered ? 120 : 44,
        height: 44,
        child: Material(
          color: enabled ? fillColor : fillColor.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 20,
                    color: enabled ? fgColor : fgColor.withValues(alpha: 0.55),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 140),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _hovered
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              widget.label,
                              key: ValueKey(widget.label),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: enabled
                                    ? fgColor
                                    : fgColor.withValues(alpha: 0.55),
                              ),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverExpandMenuButton extends StatefulWidget {
  const _HoverExpandMenuButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.items,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final List<PopupMenuEntry<String>> Function(BuildContext context) items;
  final ValueChanged<String> onSelected;

  @override
  State<_HoverExpandMenuButton> createState() => _HoverExpandMenuButtonState();
}

class _HoverExpandMenuButtonState extends State<_HoverExpandMenuButton> {
  bool _hovered = false;

  Future<void> _openMenu() async {
    final box = context.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      items: widget.items(context),
    );

    if (selected != null) {
      widget.onSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final theme = Theme.of(context);
    final fillColor = theme.colorScheme.surfaceContainerHighest;
    final fgColor = theme.colorScheme.onSurface;

    return MouseRegion(
      onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        width: _hovered ? 120 : 44,
        height: 44,
        child: Material(
          color: enabled ? fillColor : fillColor.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: enabled ? _openMenu : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 20,
                    color: enabled ? fgColor : fgColor.withValues(alpha: 0.55),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 140),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _hovered
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              widget.label,
                              key: ValueKey(widget.label),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: enabled
                                    ? fgColor
                                    : fgColor.withValues(alpha: 0.55),
                              ),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
