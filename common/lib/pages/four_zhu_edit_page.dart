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
import 'package:common/widgets/template_gallery_view.dart';
import 'package:common/viewmodels/four_zhu_editor_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
              onOpenGallery: () => _openTemplateGallery(context, viewModel),
              onDeleteTemplate: () => _confirmDelete(context, viewModel),
              onDuplicateTemplate: viewModel.duplicateCurrentTemplate,
              onSaveTemplate: viewModel.saveCurrentTemplate,
              onUndoChanges: () => viewModel.revertChanges(),
              onNameChanged: viewModel.updateTemplateName,
            ),
            body: Column(
              children: [
                const TemplateGalleryView(),
                const SizedBox(height: 8),
                if (viewModel.errorMessage != null)
                  _ErrorBanner(
                    message: viewModel.errorMessage!,
                    onDismissed: viewModel.clearError,
                  ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _EditorSidebar(
                        rowConfigs: viewModel.rowConfigs,
                        cardStyle: viewModel.cardStyle,
                        onRowVisibilityChanged: viewModel.updateRowVisibility,
                        onRowTitleVisibilityChanged:
                            viewModel.updateRowTitleVisibility,
                        onDividerTypeChanged: viewModel.updateDividerType,
                        onDividerColorChanged: viewModel.updateDividerColor,
                        onDividerThicknessChanged:
                            viewModel.updateDividerThickness,
                      ),
                      Expanded(
                        child: _EditorWorkspace(
                          isLoading: viewModel.isLoading,
                          chartGroups: viewModel.chartGroups,
                          cardStyle: viewModel.cardStyle,
                          onReorder: viewModel.reorderPillar,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  Future<void> _openTemplateGallery(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _TemplateGallerySheet(
          templates: viewModel.templates,
          currentTemplateId: viewModel.currentTemplate?.id,
          onApply: (templateId) async {
            await viewModel.applyTemplate(templateId);
            if (sheetContext.mounted) {
              Navigator.of(sheetContext).pop();
            }
          },
          onDuplicate: (templateId) async {
            await viewModel.duplicateTemplateAsNew(templateId);
          },
        );
      },
    );
  }
}

class _TemplateGallerySheet extends StatelessWidget {
  const _TemplateGallerySheet({
    required this.templates,
    required this.currentTemplateId,
    required this.onApply,
    required this.onDuplicate,
  });

  final List<LayoutTemplate> templates;
  final String? currentTemplateId;
  final Future<void> Function(String templateId) onApply;
  final Future<void> Function(String templateId) onDuplicate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Template Gallery',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Material(
                  color: theme.colorScheme.surface,
                  child: ListView.separated(
                    itemCount: templates.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      final isCurrent = template.id == currentTemplateId;
                      final updatedText = template.updatedAt
                          .toLocal()
                          .toString()
                          .split('.')
                          .first;
                      return ListTile(
                        title: Text(template.name),
                        subtitle: Text(
                          'Updated $updatedText',
                          style: theme.textTheme.bodySmall,
                        ),
                        selected: isCurrent,
                        trailing: Wrap(
                          spacing: 12,
                          children: [
                            TextButton(
                              onPressed: () async {
                                await onApply(template.id);
                              },
                              child: const Text('Apply'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await onDuplicate(template.id);
                              },
                              child: const Text('Duplicate'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    required this.onDividerTypeChanged,
    required this.onDividerColorChanged,
    required this.onDividerThicknessChanged,
  });

  final List<RowConfig> rowConfigs;
  final CardStyle? cardStyle;
  final void Function(RowType type, bool isVisible) onRowVisibilityChanged;
  final void Function(RowType type, bool isVisible) onRowTitleVisibilityChanged;
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
                ...rowConfigs.map(
                  (config) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_rowTypeLabel(config.type)),
                        value: config.isVisible,
                        onChanged: (value) =>
                            onRowVisibilityChanged(config.type, value),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Row(
                          children: [
                            Checkbox(
                              value: config.isTitleVisible,
                              onChanged: (value) => onRowTitleVisibilityChanged(
                                config.type,
                                value ?? true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('显示标题'),
                          ],
                        ),
                      ),
                      Divider(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('分隔线样式', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                DropdownButtonFormField<BorderType>(
                  initialValue: dividerType,
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

    final sanitized = result.startsWith('#') ? result : '#';
    return sanitized.toUpperCase();
  }
}

class _EditorWorkspace extends StatelessWidget {
  const _EditorWorkspace({
    required this.isLoading,
    required this.chartGroups,
    required this.cardStyle,
    required this.onReorder,
  });

  final bool isLoading;
  final List<ChartGroup> chartGroups;
  final CardStyle? cardStyle;
  final void Function({
    required String groupId,
    required int oldIndex,
    required int newIndex,
  }) onReorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
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
                _PillarReorderList(
                  groupId: group.id,
                  pillars: group.pillarOrder,
                  dividerType: dividerType,
                  dividerColor: dividerColor,
                  onReorder: onReorder,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PillarReorderList extends StatelessWidget {
  const _PillarReorderList({
    required this.groupId,
    required this.pillars,
    required this.dividerType,
    required this.dividerColor,
    required this.onReorder,
  });

  final String groupId;
  final List<PillarType> pillars;
  final BorderType dividerType;
  final Color dividerColor;
  final void Function({
    required String groupId,
    required int oldIndex,
    required int newIndex,
  }) onReorder;

  @override
  Widget build(BuildContext context) {
    if (pillars.isEmpty) {
      return const Text('暂无柱位');
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pillars.length,
      onReorder: (oldIndex, newIndex) {
        var targetIndex = newIndex;
        if (newIndex > oldIndex) {
          targetIndex -= 1;
        }
        onReorder(
          groupId: groupId,
          oldIndex: oldIndex,
          newIndex: targetIndex,
        );
      },
      itemBuilder: (context, index) {
        final pillar = pillars[index];
        return Container(
          key: ValueKey('pillar-$groupId-$index-${pillar.name}'),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: _buildBorder(),
            color: Theme.of(context).cardColor,
          ),
          child: ListTile(
            leading: const Icon(Icons.drag_indicator),
            title: Text(_pillarTypeLabel(pillar)),
          ),
        );
      },
    );
  }

  BoxBorder _buildBorder() {
    switch (dividerType) {
      case BorderType.dashed:
      case BorderType.dotted:
        return Border.all(color: dividerColor.withValues(alpha: 0.6));
      case BorderType.none:
        return Border.all(color: dividerColor.withValues(alpha: 0));
      case BorderType.solid:
        return Border.all(color: dividerColor);
    }
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
