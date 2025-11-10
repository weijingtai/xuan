import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/domain/usecases/layout_templates/delete_template_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_all_templates_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import 'package:common/domain/usecases/layout_templates/save_template_use_case.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/repositories/layout_template_repository_impl.dart';
import 'package:common/themes/editor_theme.dart';
import 'package:common/widgets/editor_top_bar.dart';
import 'package:common/widgets/editor_sidebar_v2.dart'; // 使用新的 Sidebar
import 'package:common/widgets/template_board_view.dart';
import 'package:common/widgets/template_gallery_view.dart';
import 'package:common/widgets/pillar_tag_bar.dart';
import 'package:common/widgets/generic_pillar_card.dart';
import 'package:common/models/pillar_data.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:day_night_themed_switcher/day_night_themed_switcher.dart';
import 'package:provider/provider.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/widgets/eight_chars_picker_bottom_sheet.dart';
import 'package:common/features/tai_yuan/tai_yuan_model.dart';
import 'package:common/viewmodels/four_zhu_editor_view_model.dart';
import 'package:flutter/material.dart';

import '../datasource/layout_template_local_data_source.dart';
import '../enums.dart';
import '../features/tai_yuan/enum_calculate_strategy.dart';
import '../models/drag_payloads.dart';
import '../models/pillar_content.dart';
import '../models/row_strategy.dart';
import '../widgets/card_row.dart';
import '../widgets/editable_fourzhu_card.dart';
import '../widgets/four_zhu_card_editor_page/editor_workspace.dart';

const _defaultCollectionId = 'four_zhu_templates';

class FourZhuEditPage extends StatelessWidget {
  const FourZhuEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FourZhuEditorViewModel>(
      create: (_) {
        final repository = LayoutTemplateRepositoryImpl(
          const LayoutTemplateLocalDataSource(),
        );
        return FourZhuEditorViewModel(
          getAllTemplatesUseCase: GetAllTemplatesUseCase(repository),
          getTemplateByIdUseCase: GetTemplateByIdUseCase(repository),
          saveTemplateUseCase: SaveTemplateUseCase(repository),
          deleteTemplateUseCase: DeleteTemplateUseCase(repository),
        )..initialize(collectionId: _defaultCollectionId);
      },
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

  @override
  void dispose() {
    _templateNameController.dispose();
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

        if (_templateNameController.text != templateName) {
          _templateNameController.value = TextEditingValue(
            text: templateName,
            selection: TextSelection.collapsed(offset: templateName.length),
          );
        }

        return Theme(
          data: themeData,
          child: Scaffold(
              backgroundColor: themeData.scaffoldBackgroundColor,
              appBar: AppBar(
                title: Text("卡片样式编辑"),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () => _saveWithFeedback(context, viewModel),
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
                    color: Colors.yellow,
                    child: const EditorSidebarV2(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const TemplateGalleryView(),
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
                            // 将底部入口改为小型可拖拽 Tag（带抓手图标）
                            const PillarTagBar(),
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

  // Legacy bottom-sheet template gallery removed; using TemplateGalleryView instead.

  Future<void> _openEightCharsPicker(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
  ) async {
    final result = await showEightCharsPickerBottomSheet(
      context: context,
      eightChars: viewModel.previewEightChars,
    );
    if (result is EightChars && context.mounted) {
      viewModel.updatePreviewData(eightChars: result);
    }
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
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('有未保存的更改，按 Ctrl/⌘+S 保存'),
      ),
    );
  }
}

String _rowTextAlignLabel(RowTextAlign value) {
  switch (value) {
    case RowTextAlign.left:
      return '左对齐';
    case RowTextAlign.center:
      return '居中';
    case RowTextAlign.right:
      return '右对齐';
  }
}
