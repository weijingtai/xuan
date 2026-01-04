import 'package:common/database/app_database.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/domain/usecases/layout_templates/delete_template_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_all_templates_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import 'package:common/domain/usecases/layout_templates/save_template_use_case.dart';
import 'package:common/repositories/layout_template_repository_impl.dart';
import 'package:common/themes/editor_theme.dart';
import 'package:common/widgets/row_tag_bar.dart';
import 'package:common/widgets/style_editor/sidebar_explorer.dart';
import 'package:common/widgets/pillar_tag_bar.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:provider/provider.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/viewmodels/four_zhu_editor_view_model.dart';
import 'package:flutter/material.dart';

import '../widgets/four_zhu_card_editor_page/editor_workspace.dart';

const _defaultCollectionId = 'four_zhu_templates';

class FourZhuEditPage extends StatelessWidget {
  const FourZhuEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FourZhuEditorViewModel>(
          create: (ctx) {
            final repository = LayoutTemplateRepositoryImpl(
              LayoutTemplateLocalDataSource(ctx.read<AppDatabase>()),
            );
            return FourZhuEditorViewModel(
              getAllTemplatesUseCase: GetAllTemplatesUseCase(repository),
              getTemplateByIdUseCase: GetTemplateByIdUseCase(repository),
              saveTemplateUseCase: SaveTemplateUseCase(repository),
              deleteTemplateUseCase: DeleteTemplateUseCase(repository),
            )..initialize(collectionId: _defaultCollectionId);
          },
        ),
      ],
      child: const _FourZhuEditView(),
    );
  }
}

class _FourZhuEditView extends StatefulWidget {
  const _FourZhuEditView();

  @override
  State<_FourZhuEditView> createState() => _FourZhuEditViewState();
}

class _FourZhuEditViewState extends State<_FourZhuEditView> {
  final TextEditingController _templateNameController = TextEditingController();
  final TextEditingController _templateDescriptionController =
      TextEditingController();

  @override
  void dispose() {
    _templateNameController.dispose();
    _templateDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FourZhuEditorViewModel>(
      builder: (context, viewModel, _) {
        final themeData = viewModel.isDarkMode
            ? EditorTheme.darkTheme
            : EditorTheme.lightTheme;
        final currentTemplate = viewModel.currentTemplate;
        final templateName = currentTemplate?.name ?? '';
        final templateDescription = currentTemplate?.description ?? '';

        if (_templateNameController.text != templateName) {
          _templateNameController.value = TextEditingValue(
            text: templateName,
            selection: TextSelection.collapsed(offset: templateName.length),
          );
        }

        if (_templateDescriptionController.text != templateDescription) {
          _templateDescriptionController.value = TextEditingValue(
            text: templateDescription,
            selection:
                TextSelection.collapsed(offset: templateDescription.length),
          );
        }

        return Theme(
          data: themeData,
          child: Scaffold(
              backgroundColor: themeData.scaffoldBackgroundColor,
              appBar: AppBar(
                title: const Text("卡片样式编辑"),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () => _saveWithFeedback(context, viewModel),
                  ),
                  IconButton(
                    icon: const Icon(Icons.restart_alt),
                    onPressed: viewModel.isLoading
                        ? null
                        : () => _confirmResetTemplates(context, viewModel),
                  ),
                ],
              ),
              // appBar: EditorTopBar(
              //   nameController: _templateNameController,
              //   onCreateTemplate: () =>
              //       _showCreateTemplateDialog(context, viewModel),
              //   // Legacy gallery removed; action is a no-op now
              //   // onOpenGallery: () {},
              //   onDeleteTemplate: () => _confirmDelete(context, viewModel),
              //   onDuplicateTemplate: viewModel.duplicateCurrentTemplate,
              //   onSaveTemplate: () => _saveWithFeedback(context, viewModel),
              //   onUndoChanges: () => viewModel.revertChanges(),
              //   onNameChanged: viewModel.updateTemplateName,
              // ),
              body: Row(
                children: [
                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: themeData.dividerColor.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const SidebarExplorer(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: themeData
                                      .colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: themeData.dividerColor
                                        .withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child:
                                                DropdownButtonFormField<String>(
                                              key:
                                                  ValueKey(currentTemplate?.id),
                                              initialValue: currentTemplate?.id,
                                              items: viewModel.templates
                                                  .map(
                                                    (template) =>
                                                        DropdownMenuItem(
                                                      value: template.id,
                                                      child: Text(
                                                        template.name,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(growable: false),
                                              onChanged: viewModel.isLoading
                                                  ? null
                                                  : (id) {
                                                      if (id == null) return;
                                                      viewModel
                                                          .selectTemplate(id);
                                                    },
                                              decoration: const InputDecoration(
                                                labelText: '模板',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          OutlinedButton.icon(
                                            onPressed: viewModel.isLoading
                                                ? null
                                                : () =>
                                                    _showCreateTemplateDialog(
                                                        context, viewModel),
                                            icon: const Icon(Icons.add),
                                            label: const Text('新建'),
                                          ),
                                          const SizedBox(width: 8),
                                          OutlinedButton.icon(
                                            onPressed: viewModel.isLoading ||
                                                    currentTemplate == null
                                                ? null
                                                : viewModel
                                                    .duplicateCurrentTemplate,
                                            icon: const Icon(Icons.copy),
                                            label: const Text('复制'),
                                          ),
                                          const SizedBox(width: 8),
                                          OutlinedButton.icon(
                                            onPressed: viewModel.isLoading ||
                                                    currentTemplate == null
                                                ? null
                                                : () => _showSaveAsDialog(
                                                    context, viewModel),
                                            icon: const Icon(
                                                Icons.save_as_outlined),
                                            label: const Text('另存为'),
                                          ),
                                          const SizedBox(width: 8),
                                          OutlinedButton.icon(
                                            onPressed: viewModel.isLoading ||
                                                    currentTemplate == null
                                                ? null
                                                : () => _confirmDelete(
                                                    context, viewModel),
                                            icon: const Icon(
                                                Icons.delete_outline),
                                            label: const Text('删除'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  themeData.colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller:
                                                  _templateNameController,
                                              enabled: !viewModel.isLoading &&
                                                  currentTemplate != null,
                                              onChanged:
                                                  viewModel.updateTemplateName,
                                              decoration: const InputDecoration(
                                                labelText: '名称',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                                suffixIcon: Icon(
                                                  Icons.edit,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextField(
                                              controller:
                                                  _templateDescriptionController,
                                              enabled: !viewModel.isLoading &&
                                                  currentTemplate != null,
                                              onChanged: (value) => viewModel
                                                  .updateTemplateDescription(
                                                      value),
                                              maxLines: 2,
                                              decoration: const InputDecoration(
                                                labelText: '描述(可选)',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                                suffixIcon: Icon(
                                                  Icons.notes_outlined,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 移除旧的PillarPresetList,已被TemplateGalleryView替代
                            if (viewModel.errorMessage != null)
                              _ErrorBanner(
                                message: viewModel.errorMessage!,
                                onDismissed: viewModel.clearError,
                              ),
                            if (viewModel.hasUnsavedChanges)
                              const _UnsavedBanner(),
                          ],
                        ),
                        Expanded(
                          child: EditorWorkspace(
                            eightChars: EightChars(
                                year: JiaZi.JIA_ZI,
                                month: JiaZi.JIA_ZI,
                                day: JiaZi.JIA_ZI,
                                time: JiaZi.JIA_ZI),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 104),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: themeData
                                      .colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: themeData.dividerColor
                                        .withValues(alpha: 0.12),
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 28, child: RowTagBar()),
                                    SizedBox(height: 8),
                                    SizedBox(height: 28, child: PillarTagBar()),
                                    // 右侧柱样式面板已移除，避免挤压卡片区域
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: viewModel.canSave
                                      ? () =>
                                          _saveWithFeedback(context, viewModel)
                                      : null,
                                  icon: const Icon(Icons.save),
                                  label: const Text('保存更改'),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: viewModel.canRevert
                                      ? viewModel.revertChanges
                                      : null,
                                  icon: const Icon(Icons.undo),
                                  label: const Text('撤销更改'),
                                ),
                                const Spacer(),
                                OutlinedButton.icon(
                                  onPressed: () => _promptCreateGroup(context),
                                  icon: const Icon(Icons.add),
                                  label: const Text('新增分组'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _promptDeleteSelectedGroup(context),
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('删除选中分组'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        );
      },
    );
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
          title: const Text('Delete Template'),
          content: Text(
            'Are you sure you want to delete the template "${template.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.9),
              ),
              child: const Text('Delete'),
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

  Future<void> _saveWithFeedback(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
  ) async {
    // Fluttertoast.showToast(msg: '保存中...');
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
        title: const Text('新增分组'),
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
          title: const Text('Create Template'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter template name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Create'),
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
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onDismissed,
  });

  final String message;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.error.withValues(alpha: 0.08),
      child: ListTile(
        leading: Icon(
          Icons.warning_amber_rounded,
          color: theme.colorScheme.error,
        ),
        title: Text(message, style: theme.textTheme.bodyMedium),
        trailing: IconButton(
          onPressed: onDismissed,
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }
}

class _UnsavedBanner extends StatelessWidget {
  const _UnsavedBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.1),
      child: const ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('有未保存的更改，按 Ctrl/⌘+S 保存'),
      ),
    );
  }
}
