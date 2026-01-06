import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/widgets/editable_fourzhu_card.dart';
import 'package:common/widgets/pillar_tag_bar.dart';
import 'package:common/widgets/row_tag_bar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/layout_template_enums.dart';
import '../../models/eight_chars.dart';
import '../../models/layout_template.dart';
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

  Future<void> _selectTemplateWithGuard(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
    String templateId,
  ) async {
    if (viewModel.currentTemplate?.id == templateId) {
      return;
    }

    if (viewModel.hasUnsavedChanges) {
      final action = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('切换模板'),
            content: const Text('当前模板有未保存更改，是否先处理再切换？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop('cancel'),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop('revert'),
                child: const Text('重置并切换'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop('save'),
                child: const Text('保存并切换'),
              ),
            ],
          );
        },
      );

      if (!context.mounted) return;

      if (action == 'save') {
        await _saveWithFeedback(context, viewModel);
      } else if (action == 'revert') {
        viewModel.revertChanges();
      } else {
        return;
      }
    }

    await viewModel.selectTemplate(templateId);
  }

  Future<void> _openTemplateAlbum(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _TemplateAlbumPage(
          onOpenSheet: (sheetContext, template) => _showTemplateActionSheet(
            sheetContext,
            viewModel,
            template,
          ),
        ),
      ),
    );
  }

  Future<void> _showTemplateActionSheet(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
    LayoutTemplate template,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final isCurrent = viewModel.currentTemplate?.id == template.id;
        final isFav = viewModel.isFavorite(template.id);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  template.name,
                  style: Theme.of(sheetContext)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if ((template.description ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    template.description!,
                    style: Theme.of(sheetContext).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    await _selectTemplateWithGuard(
                      context,
                      viewModel,
                      template.id,
                    );
                  },
                  child: Text(isCurrent ? '已在使用' : '使用此模板'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    viewModel.toggleFavorite(template.id);
                    Navigator.of(sheetContext).pop();
                  },
                  icon: Icon(isFav ? Icons.star : Icons.star_border),
                  label: Text(isFav ? '取消最喜欢' : '标记为最喜欢'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemplateGalleryBar(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
  ) {
    final templates = viewModel.templates;
    final recentIds = viewModel.recentTemplateIds;
    final recentIndex = <String, int>{
      for (var i = 0; i < recentIds.length; i++) recentIds[i]: i,
    };

    final favorite = templates
        .where((t) => viewModel.isFavorite(t.id))
        .toList(growable: false)
      ..sort((a, b) {
        final ai = recentIndex[a.id];
        final bi = recentIndex[b.id];
        if (ai != null && bi != null) return ai.compareTo(bi);
        if (ai != null) return -1;
        if (bi != null) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });

    final favoriteSet = favorite.map((e) => e.id).toSet();
    final recent = recentIds
        .map((id) => templates.firstWhereOrNull((t) => t.id == id))
        .whereType<LayoutTemplate>()
        .where((t) => !favoriteSet.contains(t.id))
        .toList(growable: false);

    final recentSet = recent.map((e) => e.id).toSet();
    final other = templates
        .where((t) => !favoriteSet.contains(t.id) && !recentSet.contains(t.id))
        .toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final entries = <Widget>[];

    void addSection(String title, List<LayoutTemplate> items) {
      if (items.isEmpty) return;
      entries.add(_GalleryTag(title));
      for (final t in items) {
        entries.add(
          _TemplateGalleryChip(
            template: t,
            selected: viewModel.currentTemplate?.id == t.id,
            favorite: viewModel.isFavorite(t.id),
            onTap: () => _selectTemplateWithGuard(context, viewModel, t.id),
          ),
        );
      }
    }

    addSection('最喜欢', favorite);
    addSection('常用', recent);
    addSection('其他', other);

    return SafeArea(
      bottom: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) => entries[i],
              ),
            ),
            const SizedBox(width: 8),
            _HoverExpandActionButton(
              icon: Icons.grid_view,
              label: '更多',
              onPressed: viewModel.isLoading
                  ? null
                  : () => _openTemplateAlbum(context, viewModel),
            ),
          ],
        ),
      ),
    );
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
                      _buildTemplateGalleryBar(context, viewModel),
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
                                      label: '新建模板',
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () => _showCreateTemplateDialog(
                                                context,
                                                viewModel,
                                              ),
                                    ),
                                    const SizedBox(width: 8),
                                    _HoverExpandActionButton(
                                      icon: Icons.copy,
                                      label: '复制',
                                      onPressed: viewModel.isLoading ||
                                              currentTemplate == null
                                          ? null
                                          : viewModel.duplicateCurrentTemplate,
                                    ),
                                    const SizedBox(width: 8),
                                    _HoverExpandActionButton(
                                      icon: Icons.delete_outline,
                                      label: '删除',
                                      onPressed: viewModel.isLoading ||
                                              currentTemplate == null
                                          ? null
                                          : () => _confirmDelete(
                                                context,
                                                viewModel,
                                              ),
                                      destructive: true,
                                    ),
                                    const SizedBox(width: 8),
                                    _HoverExpandActionButton(
                                      icon: Icons.grid_view,
                                      label: '更多',
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () => _openTemplateAlbum(
                                                context,
                                                viewModel,
                                              ),
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

class _GalleryTag extends StatelessWidget {
  const _GalleryTag(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TemplateGalleryChip extends StatelessWidget {
  const _TemplateGalleryChip({
    required this.template,
    required this.selected,
    required this.favorite,
    required this.onTap,
  });

  final LayoutTemplate template;
  final bool selected;
  final bool favorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerHighest;
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.dividerColor.withValues(alpha: 0.12);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  template.name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (favorite) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.star,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateAlbumPage extends StatelessWidget {
  const _TemplateAlbumPage({required this.onOpenSheet});

  final Future<void> Function(BuildContext context, LayoutTemplate template)
      onOpenSheet;

  @override
  Widget build(BuildContext context) {
    return Consumer<FourZhuEditorViewModel>(
      builder: (context, viewModel, _) {
        final templates = viewModel.templates;
        final recentIds = viewModel.recentTemplateIds;
        final recentIndex = <String, int>{
          for (var i = 0; i < recentIds.length; i++) recentIds[i]: i,
        };

        final favorite = templates
            .where((t) => viewModel.isFavorite(t.id))
            .toList(growable: false)
          ..sort((a, b) {
            final ai = recentIndex[a.id];
            final bi = recentIndex[b.id];
            if (ai != null && bi != null) return ai.compareTo(bi);
            if (ai != null) return -1;
            if (bi != null) return 1;
            return b.updatedAt.compareTo(a.updatedAt);
          });

        final favoriteSet = favorite.map((e) => e.id).toSet();
        final recent = recentIds
            .map((id) => templates.firstWhereOrNull((t) => t.id == id))
            .whereType<LayoutTemplate>()
            .where((t) => !favoriteSet.contains(t.id))
            .toList(growable: false);

        final recentSet = recent.map((e) => e.id).toSet();
        final other = templates
            .where((t) =>
                !favoriteSet.contains(t.id) && !recentSet.contains(t.id))
            .toList(growable: false)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        final ordered = <LayoutTemplate>[...favorite, ...recent, ...other];

        return Scaffold(
          appBar: AppBar(
            title: const Text('模板'),
            actions: [
              IconButton(
                tooltip: '重置模板',
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('重置模板'),
                            content:
                                const Text('将删除本地所有模板并重建默认模板。此操作不可撤销。'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: const Text('取消'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      Colors.red.withValues(alpha: 0.9),
                                ),
                                child: const Text('重置'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await viewModel.resetTemplatesToDefault();
                        }
                      },
                icon: const Icon(Icons.restart_alt),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount =
                  (width / 220).floor().clamp(2, 6).toInt();
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.8,
                ),
                itemCount: ordered.length,
                itemBuilder: (context, index) {
                  final t = ordered[index];
                  final selected = viewModel.currentTemplate?.id == t.id;
                  final fav = viewModel.isFavorite(t.id);
                  return _TemplateAlbumTile(
                    template: t,
                    selected: selected,
                    favorite: fav,
                    onTap: () => onOpenSheet(context, t),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _TemplateAlbumTile extends StatelessWidget {
  const _TemplateAlbumTile({
    required this.template,
    required this.selected,
    required this.favorite,
    required this.onTap,
  });

  final LayoutTemplate template;
  final bool selected;
  final bool favorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerHighest;
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.dividerColor.withValues(alpha: 0.12);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      template.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (template.description ?? '—').trim().isEmpty
                          ? '—'
                          : template.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (favorite) ...[
                const SizedBox(width: 10),
                Icon(
                  Icons.star,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverExpandActionButton extends StatefulWidget {
  const _HoverExpandActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.emphasized = false,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool emphasized;
  final bool destructive;

  @override
  State<_HoverExpandActionButton> createState() => _HoverExpandActionButtonState();
}

class _HoverExpandActionButtonState extends State<_HoverExpandActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final theme = Theme.of(context);

    final fillColor = widget.destructive
        ? theme.colorScheme.error
        : (widget.emphasized
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest);
    final fgColor = widget.destructive
        ? theme.colorScheme.onError
        : (widget.emphasized
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -30,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _hovered ? 1 : 0,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  child: Material(
                    color: theme.colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        widget.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onInverseSurface,
                        ),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: enabled ? fillColor : fillColor.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: widget.onPressed,
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: enabled
                          ? fgColor
                          : fgColor.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -30,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _hovered ? 1 : 0,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  child: Material(
                    color: theme.colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        widget.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onInverseSurface,
                        ),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: enabled ? fillColor : fillColor.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: enabled ? _openMenu : null,
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: enabled
                          ? fgColor
                          : fgColor.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
