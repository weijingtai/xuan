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
import 'package:common/widgets/template_editor_pane.dart';
import 'package:common/widgets/template_board_view.dart';
import 'package:common/widgets/template_gallery_view.dart';
import 'package:common/widgets/pillar_palette.dart';
import 'package:common/widgets/generic_pillar_card.dart';
import 'package:common/models/pillar_data.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:provider/provider.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/widgets/eight_chars_picker_bottom_sheet.dart';
import 'package:common/features/tai_yuan/tai_yuan_model.dart';
import 'package:common/viewmodels/four_zhu_editor_view_model.dart';
import 'package:flutter/material.dart';

import '../datasource/layout_template_local_data_source.dart';
import '../features/tai_yuan/enum_calculate_strategy.dart';
import '../widgets/card_row.dart';

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
            appBar: EditorTopBar(
              nameController: _templateNameController,
              onCreateTemplate: () =>
                  _showCreateTemplateDialog(context, viewModel),
              // Legacy gallery removed; action is a no-op now
              // onOpenGallery: () {},
              onDeleteTemplate: () => _confirmDelete(context, viewModel),
              onDuplicateTemplate: viewModel.duplicateCurrentTemplate,
              onSaveTemplate: () => _saveWithFeedback(context, viewModel),
              onUndoChanges: () => viewModel.revertChanges(),
              onNameChanged: viewModel.updateTemplateName,
            ),
            body: TemplateEditorPane(
              isLoading: viewModel.isLoading,
              header: Column(
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
                  if (viewModel.hasUnsavedChanges) const _UnsavedBanner(),
                ],
              ),
              sidebar: const EditorSidebarV2(), // 使用新的侧边栏组件
              workspace: _EditorWorkspace(
                isLoading: viewModel.isLoading,
                chartGroups: viewModel.chartGroups,
                cardStyle: viewModel.cardStyle,
                rowConfigs: viewModel.rowConfigs,
                onReorder: viewModel.reorderPillar,
              ),
              actionBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 将PillarPalette移到底部
                  const PillarPalette(),
                  const SizedBox(height: 12),
                  Row(
                children: [
                  FilledButton.icon(
                    onPressed: viewModel.canSave
                        ? () => _saveWithFeedback(context, viewModel)
                        : null,
                    icon: const Icon(Icons.save),
                    label: const Text('保存更改'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed:
                        viewModel.canRevert ? viewModel.revertChanges : null,
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
                    onPressed: () => _promptDeleteSelectedGroup(context),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('删除选中分组'),
                  ),
                ],
              ),
                ],
              ),
            ),
          ),
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

class _EditorSidebar extends StatelessWidget {
  const _EditorSidebar({
    required this.rowConfigs,
    required this.cardStyle,
    required this.onRowVisibilityChanged,
    required this.onRowTitleVisibilityChanged,
    required this.onRowOrderChanged,
    required this.onDividerTypeChanged,
    required this.onDividerColorChanged,
    required this.onDividerThicknessChanged,
  });

  final List<RowConfig> rowConfigs;
  final CardStyle? cardStyle;
  final void Function(RowType type, bool isVisible) onRowVisibilityChanged;
  final void Function(RowType type, bool isVisible) onRowTitleVisibilityChanged;
  final void Function({required int oldIndex, required int newIndex})
      onRowOrderChanged;
  final void Function(BorderType type) onDividerTypeChanged;
  final void Function(String hex) onDividerColorChanged;
  final void Function(double value) onDividerThicknessChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerType = cardStyle?.dividerType ?? BorderType.solid;
    final dividerColorHex = cardStyle?.dividerColorHex ?? '#FF334155';
    final dividerThickness = cardStyle?.dividerThickness ?? 1;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text('行显示配置', style: theme.textTheme.titleMedium),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rowConfigs.length,
                  onReorder: (oldIndex, newIndex) {
                    var target = newIndex;
                    if (newIndex > oldIndex) target -= 1;
                    onRowOrderChanged(oldIndex: oldIndex, newIndex: target);
                  },
                  itemBuilder: (context, index) {
                    final config = rowConfigs[index];
                    return _RowTile(
                      key: ValueKey('row-${config.type.name}-$index'),
                      type: config.type,
                      isVisible: config.isVisible,
                      isTitleVisible: config.isTitleVisible,
                      onVisibilityChanged: (value) =>
                          onRowVisibilityChanged(config.type, value),
                      onTitleVisibilityChanged: (value) =>
                          onRowTitleVisibilityChanged(config.type, value),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('重置行配置'),
                            content: const Text('将恢复为默认行配置，是否继续？'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: const Text('取消'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: const Text('重置'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          // 调用外层 ViewModel 的 resetRowConfigs
                          final vm = context.read<FourZhuEditorViewModel>();
                          vm.resetRowConfigs();
                        }
                      },
                      child: const Text('重置行配置'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('分隔线样式', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                DropdownButtonFormField<BorderType>(
                  value: dividerType,
                  items: BorderType.values
                      .map(
                        (type) => DropdownMenuItem<BorderType>(
                          value: type,
                          child: Text(_borderTypeLabel(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onDividerTypeChanged(value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text('分隔线粗细 ${dividerThickness.toStringAsFixed(1)}'),
                Slider(
                  min: 0.5,
                  max: 6,
                  value: dividerThickness,
                  onChanged: onDividerThicknessChanged,
                ),
                const SizedBox(height: 12),
                const Text('分隔线颜色'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final color = await _pickColor(context, dividerColorHex);
                    if (color != null) {
                      onDividerColorChanged(color);
                    }
                  },
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: _colorFromHex(dividerColorHex),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: theme.dividerColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _pickColor(BuildContext context, String initialHex) async {
    final controller = TextEditingController(text: initialHex);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('输入颜色 Hex 值'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '#FF334155'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result == null || result.isEmpty) {
      return null;
    }

    final upper = result.toUpperCase();
    final sanitized = upper.startsWith('#') ? upper : '#$upper';
    return sanitized;
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    super.key,
    required this.type,
    required this.isVisible,
    required this.isTitleVisible,
    required this.onVisibilityChanged,
    required this.onTitleVisibilityChanged,
  });

  final RowType type;
  final bool isVisible;
  final bool isTitleVisible;
  final ValueChanged<bool> onVisibilityChanged;
  final ValueChanged<bool> onTitleVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Container(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
        color: theme.colorScheme.surface,
      ),
      child: ListTile(
        leading: const Icon(Icons.drag_indicator),
        title: Row(
          children: [
            Text(_rowTypeLabel(type)),
            const SizedBox(width: 8),
            if (!isVisible)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '已隐藏',
                  style: theme.textTheme.labelSmall,
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Switch(
              value: isVisible,
              onChanged: onVisibilityChanged,
            ),
            const SizedBox(width: 8),
            Checkbox(
              value: isTitleVisible,
              onChanged: (value) => onTitleVisibilityChanged(value ?? true),
            ),
            const SizedBox(width: 4),
            const Text('显示标题'),
          ],
        ),
        trailing: IconButton(
          tooltip: '编辑样式',
          icon: const Icon(Icons.tune),
          onPressed: () async {
            await _openRowStyleSheet(context, type, isVisible, isTitleVisible);
          },
        ),
      ),
    );
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isVisible ? 1 : 0.6,
      child: content,
    );
  }

  Future<void> _openRowStyleSheet(
    BuildContext context,
    RowType type,
    bool isVisible,
    bool isTitleVisible,
  ) async {
    final vm = context.read<FourZhuEditorViewModel>();
    double fontSize = 14;
    String fontFamily = 'NotoSans';
    String colorHex = '#FF0F172A';
    RowTextAlign textAlign = RowTextAlign.left;
    double padding = 4;
    BorderType borderType = BorderType.solid;
    String borderColorHex = '#22334155';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('编辑样式 — ${_rowTypeLabel(type)}',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: fontFamily,
                    items: const [
                      DropdownMenuItem(
                          value: 'NotoSans', child: Text('NotoSans')),
                      DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                    ],
                    onChanged: (v) =>
                        setState(() => fontFamily = v ?? fontFamily),
                    decoration: const InputDecoration(labelText: '字体'),
                  ),
                  const SizedBox(height: 12),
                  Text('字号 ${fontSize.toStringAsFixed(0)}'),
                  Slider(
                    min: 10,
                    max: 24,
                    value: fontSize,
                    onChanged: (v) => setState(() => fontSize = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: colorHex,
                    decoration: const InputDecoration(labelText: '文字颜色 Hex'),
                    onChanged: (v) => setState(() => colorHex = v.trim()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<RowTextAlign>(
                    value: textAlign,
                    items: RowTextAlign.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(_rowTextAlignLabel(e)),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => textAlign = v ?? textAlign),
                    decoration: const InputDecoration(labelText: '对齐'),
                  ),
                  const SizedBox(height: 12),
                  Text('内边距 ${padding.toStringAsFixed(0)}'),
                  Slider(
                    min: 0,
                    max: 24,
                    value: padding,
                    onChanged: (v) => setState(() => padding = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<BorderType>(
                    value: borderType,
                    items: BorderType.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(_borderTypeLabel(e)),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => borderType = v ?? borderType),
                    decoration: const InputDecoration(labelText: '边框样式'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: borderColorHex,
                    decoration: const InputDecoration(labelText: '边框颜色 Hex'),
                    onChanged: (v) => setState(() => borderColorHex = v.trim()),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _colorFromHex(borderColorHex),
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('边框预览'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () {
                        vm.updateRowStyle(
                          type,
                          fontFamily: fontFamily,
                          fontSize: fontSize,
                          colorHex: colorHex,
                          textAlign: textAlign,
                          padding: padding,
                          borderType: borderType,
                          borderColorHex: borderColorHex,
                        );
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('应用'),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
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

class _EditorWorkspace extends StatelessWidget {
  const _EditorWorkspace({
    required this.isLoading,
    required this.chartGroups,
    required this.cardStyle,
    required this.rowConfigs,
    required this.onReorder,
  });

  final bool isLoading;
  final List<ChartGroup> chartGroups;
  final CardStyle? cardStyle;
  final List<RowConfig> rowConfigs;
  final void Function({
    required String groupId,
    required int oldIndex,
    required int newIndex,
  }) onReorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<FourZhuEditorViewModel>();

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chartGroups.isEmpty) {
      return Center(
        child: Text(
          '暂无模板内容',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final dividerType = cardStyle?.dividerType ?? BorderType.solid;
    final dividerColor =
        _colorFromHex(cardStyle?.dividerColorHex ?? '#FF334155');

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: chartGroups.length,
      itemBuilder: (context, index) {
        final group = chartGroups[index];
        final isSelected = viewModel.selectedGroupId == group.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Container(
            decoration: isSelected
                ? BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.05),
                        theme.colorScheme.primary.withValues(alpha: 0.02),
                      ],
                    ),
                  )
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  children: [
                    Text(group.title, style: theme.textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      ' 柱',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 合并视图模式 - 同时显示画布操作和预览Card
                Selector<FourZhuEditorViewModel, String?>(
                    selector: (_, vm) => vm.selectedGroupId,
                    builder: (ctx, selectedId, __) => TemplateBoardView(
                            groupId: group.id,
                            pillars: group.pillarOrder,
                            dividerType: dividerType,
                            dividerColor: dividerColor,
                            onReorder: onReorder,
                            onInsert: (
                                {required groupId, required index, required pillar}) {
                              context
                                  .read<FourZhuEditorViewModel>()
                                  .addPillarToGroupAtIndex(
                                    groupId: groupId,
                                    pillar: pillar,
                                    index: index,
                                  );
                            },
                            onRemove: ({required groupId, required index}) {
                              context
                                  .read<FourZhuEditorViewModel>()
                                  .removePillarFromGroup(
                                    groupId: groupId,
                                    index: index,
                                  );
                            },
                            onResetLayout: (gid) => context
                                .read<FourZhuEditorViewModel>()
                                .resetGroupLayout(groupId: gid),
                            onRename: (gid, title) => context
                                .read<FourZhuEditorViewModel>()
                                .setGroupTitle(groupId: gid, title: title),
                            onToggleLock: (gid, locked) => context
                                .read<FourZhuEditorViewModel>()
                                .setGroupLocked(groupId: gid, locked: locked),
                            onSetColor: (gid, colorHex) => context
                                .read<FourZhuEditorViewModel>()
                                .setGroupColor(groupId: gid, colorHex: colorHex),
                            onDeleteGroup: (gid) => context
                                .read<FourZhuEditorViewModel>()
                                .removeGroup(gid),
                            onInsertSeparator:
                                ({required groupId, required index}) => context
                                    .read<FourZhuEditorViewModel>()
                                    .insertSeparator(groupId: groupId, index: index),
                            onAlignPillars: (gid) => context
                                .read<FourZhuEditorViewModel>()
                                .alignPillars(gid),
                            locked: group.locked,
                            groupTitle: group.title,
                            groupColor: group.colorHex,
                            visibleRowCount:
                                rowConfigs.where((r) => r.isVisible).length,
                            expanded: group.expanded,
                            isSelected: selectedId == group.id,
                            onDuplicateGroup: () => context
                                .read<FourZhuEditorViewModel>()
                                .duplicateGroup(groupId: group.id),
                            onClearGroup: () => context
                                .read<FourZhuEditorViewModel>()
                                .clearGroup(groupId: group.id),
                            onSelect: () => context
                                .read<FourZhuEditorViewModel>()
                                .selectGroup(group.id),
                            onToggleExpanded: () => context
                                .read<FourZhuEditorViewModel>()
                                .toggleGroupExpanded(groupId: group.id),
                          )),
                // 在画布下方显示预览Card (仅在展开时渲染，减少性能开销)
                if (group.expanded) ...[
                  const SizedBox(height: 16),
                  _GroupPreviewCard(
                    group: group,
                    rows: rowConfigs,
                  ),
                ],
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}

// 预览数据 - 用于优化 Selector 性能
class _PreviewData {
  const _PreviewData({
    required this.eightChars,
    required this.taiYuan,
  });

  final EightChars eightChars;
  final TaiYuanModel taiYuan;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _PreviewData &&
        other.eightChars == eightChars &&
        other.taiYuan == taiYuan;
  }

  @override
  int get hashCode => Object.hash(eightChars, taiYuan);
}

class _GroupPreviewCard extends StatelessWidget {
  const _GroupPreviewCard({required this.group, required this.rows});
  final ChartGroup group;
  final List<RowConfig> rows;

  @override
  Widget build(BuildContext context) {
    final pillars = group.pillarOrder
        .map((p) => PillarData(
            pillarId: p.name, label: _pillarTypeLabel(p), jiaZi: JiaZi.JIA_ZI))
        .toList();

    bool _visible(RowType t) => rows.any((r) => r.type == t && r.isVisible);

    // 将 RowConfig 映射为 GenericPillarCard 可用的 rowStyles（使用 CardRow 常量作为键）
    final Map<String, RowConfig> styleMap = {};
    RowConfig? find(RowType t) => rows.firstWhere((r) => r.type == t,
        orElse: () => const RowConfig(
            type: RowType.heavenlyStem, isVisible: true, isTitleVisible: true));
    void put(String key, RowType t) {
      final cfg = rows.firstWhere((r) => r.type == t,
          orElse: () => const RowConfig(
              type: RowType.heavenlyStem,
              isVisible: true,
              isTitleVisible: true));
      styleMap[key] = cfg;
    }

    put(CardRow.pillarHeader, RowType.heavenlyStem);
    put(CardRow.tianGan, RowType.heavenlyStem);
    put(CardRow.tenGods, RowType.tenGod);
    put(CardRow.diZhi, RowType.earthlyBranch);
    put(CardRow.cangGanMain, RowType.hiddenStemsPrimary);
    put(CardRow.cangGanZhong, RowType.hiddenStemsSecondary);
    put(CardRow.cangGanYu, RowType.hiddenStemsTertiary);
    put(CardRow.cangGanMainTenGods, RowType.hiddenStemsPrimaryGods);
    put(CardRow.cangGanZhongTenGods, RowType.hiddenStemsSecondaryGods);
    put(CardRow.cangGanYuTenGods, RowType.hiddenStemsTertiaryGods);
    put(CardRow.xunShou, RowType.xunShou);
    put(CardRow.naYin, RowType.naYin);
    put(CardRow.kongWang, RowType.kongWang);

    // 优化: 使用 Selector 只监听 previewEightChars 和 previewTaiYuan，减少不必要的重建
    return Selector<FourZhuEditorViewModel, _PreviewData>(
      selector: (_, vm) => _PreviewData(
        eightChars: vm.previewEightChars ?? EightChars.defualtBaZi(),
        taiYuan: vm.previewTaiYuan ??
            TaiYuanModel(
              taiYuanGanZhi: JiaZi.JIA_ZI,
              taiYuanBeforeMonth: 0,
              calculateStrategy: TaiYuanCalculateStrategy.monthPillarMethod,
            ),
      ),
      builder: (context, previewData, _) {
        return RepaintBoundary(
          child: GenericPillarCard(
            title: group.title,
            pillars: pillars,
            dayMaster: previewData.eightChars.dayTianGan,
            isBenMing: false,
            gender: null,
            showTianGan:
                rows.any((r) => r.type == RowType.heavenlyStem && r.isVisible),
            showDiZhi:
                rows.any((r) => r.type == RowType.earthlyBranch && r.isVisible),
            showTenGods: _visible(RowType.tenGod),
            showCangGanMain: _visible(RowType.hiddenStemsPrimary),
            showCangGanMainTenGods: _visible(RowType.hiddenStemsPrimaryGods),
            showCangGanZhong: _visible(RowType.hiddenStemsSecondary),
            showCangGanZhongTenGods: _visible(RowType.hiddenStemsSecondaryGods),
            showCangGanYu: _visible(RowType.hiddenStemsTertiary),
            showCangGanYuTenGods: _visible(RowType.hiddenStemsTertiaryGods),
            showXunShou: _visible(RowType.xunShou),
            showNaYin: _visible(RowType.naYin),
            showKongWang: _visible(RowType.kongWang),
            isEditMode: false,
            isColumnReorderMode: false,
            onRowReorder: (a, b) {},
            onPillarReorder: (a, b) {},
            rowStyles: styleMap,
          ),
        );
      },
    );
  }
}

String _rowTypeLabel(RowType type) {
  switch (type) {
    case RowType.heavenlyStem:
      return '天干';
    case RowType.earthlyBranch:
      return '地支';
    case RowType.tenGod:
      return '十神';
    case RowType.naYin:
      return '纳音';
    case RowType.kongWang:
      return '空亡';
    case RowType.xunShou:
      return '旬首';
    case RowType.hiddenStems:
      return '藏干';
    case RowType.hiddenStemsTenGod:
      return '藏干十神';
    case RowType.hiddenStemsPrimary:
      return '藏干主气';
    case RowType.hiddenStemsSecondary:
      return '藏干中气';
    case RowType.hiddenStemsTertiary:
      return '藏干余气';
    case RowType.hiddenStemsPrimaryGods:
      return '藏干主神';
    case RowType.hiddenStemsSecondaryGods:
      return '藏干中神';
    case RowType.hiddenStemsTertiaryGods:
      return '藏干余神';
    case RowType.starYun:
      return '神煞';
    case RowType.selfSiting:
      return '命宫';
    case RowType.columnHeaderRow:
      return '表头行';
    case RowType.separator:
      return '分割线';
  }
}

String _pillarTypeLabel(PillarType type) {
  switch (type) {
    case PillarType.year:
      return '年柱';
    case PillarType.month:
      return '月柱';
    case PillarType.day:
      return '日柱';
    case PillarType.hour:
      return '时柱';
    case PillarType.ke:
      return '刻柱';
    case PillarType.taiMeta:
      return '胎命';
    case PillarType.taiMonth:
      return '胎月';
    case PillarType.taiDay:
      return '胎日';
    case PillarType.lifeHouse:
      return '命宫';
    case PillarType.luckCycle:
      return '大运';
    case PillarType.annual:
      return '流年';
    case PillarType.monthly:
      return '流月';
    case PillarType.daily:
      return '流日';
    case PillarType.hourly:
      return '流时';
    case PillarType.separator:
      return "分割线";
    case PillarType.rowTitleColumn:
      return "行标题列";
  }
}

String _borderTypeLabel(BorderType type) {
  switch (type) {
    case BorderType.solid:
      return '实线';
    case BorderType.dashed:
      return '虚线';
    case BorderType.dotted:
      return '点线';
    case BorderType.none:
      return '无';
  }
}

Color _colorFromHex(String hex) {
  final sanitized = hex.trim();
  final buffer = StringBuffer();
  if (sanitized.length == 6 || sanitized.length == 7) {
    buffer.write('FF');
  }
  buffer.write(sanitized.replaceFirst('#', ''));
  try {
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (_) {
    return const Color(0xFF334155);
  }
}
