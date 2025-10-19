import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/layout_template_enums.dart';
import '../models/layout_template.dart';
import '../viewmodels/four_zhu_editor_view_model.dart';

class TemplateGalleryView extends StatefulWidget {
  const TemplateGalleryView({super.key});

  @override
  State<TemplateGalleryView> createState() => _TemplateGalleryViewState();
}

class _TemplateGalleryViewState extends State<TemplateGalleryView> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final filter = context.read<FourZhuEditorViewModel>().filterState;
    _searchController = TextEditingController(text: filter.searchKeyword);
    _scrollController = ScrollController();
    _searchController.addListener(() {
      context
          .read<FourZhuEditorViewModel>()
          .updateSearchKeyword(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FourZhuEditorViewModel>();
    final contentHeight = switch (viewModel.viewMode) {
      EditorViewMode.table => 280.0,
      EditorViewMode.canvas => 340.0,
      EditorViewMode.preview => 380.0,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToolbar(context, viewModel),
            if (viewModel.hasSelection) ...[
              const SizedBox(height: 12),
              _SelectionBar(viewModel: viewModel),
            ],
            const SizedBox(height: 12),
            _CategorySelector(controller: _scrollController),
            const SizedBox(height: 12),
            _SortSelector(),
            const SizedBox(height: 12),
            SizedBox(
              height: contentHeight,
              child: _TemplateCollection(controller: _scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    FourZhuEditorViewModel viewModel,
  ) {
    final filter = viewModel.filterState;
    if (_searchController.text != filter.searchKeyword) {
      _searchController.value = TextEditingValue(
        text: filter.searchKeyword,
        selection: TextSelection.collapsed(
          offset: filter.searchKeyword.length,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final searchWidth =
            ((constraints.maxWidth.isFinite ? constraints.maxWidth : 420.0)
                    .clamp(240.0, 420.0))
                .toDouble();

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: searchWidth,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search templates',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Clear search',
              onPressed: () {
                _searchController.clear();
                context.read<FourZhuEditorViewModel>().updateSearchKeyword('');
              },
              icon: const Icon(Icons.close),
            ),
            SegmentedButton<EditorViewMode>(
              segments: const [
                ButtonSegment<EditorViewMode>(
                  value: EditorViewMode.table,
                  icon: Icon(Icons.view_list_outlined),
                  label: Text('List'),
                ),
                ButtonSegment<EditorViewMode>(
                  value: EditorViewMode.canvas,
                  icon: Icon(Icons.dashboard_customize_outlined),
                  label: Text('Cards'),
                ),
                ButtonSegment<EditorViewMode>(
                  value: EditorViewMode.preview,
                  icon: Icon(Icons.view_week_outlined),
                  label: Text('Preview'),
                ),
              ],
              selected: <EditorViewMode>{viewModel.viewMode},
              onSelectionChanged: (values) {
                if (values.isEmpty) {
                  return;
                }
                context
                    .read<FourZhuEditorViewModel>()
                    .setViewMode(values.first);
              },
            ),
            FilledButton.icon(
              onPressed: () async {
                await context.read<FourZhuEditorViewModel>().createTemplate();
              },
              icon: const Icon(Icons.add),
              label: const Text('New Template'),
            ),
          ],
        );
      },
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.viewModel});

  final FourZhuEditorViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final count = viewModel.selectedTemplateIds.length;
    return Material(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text('$count selected'),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await viewModel.duplicateSelectedTemplates();
              },
              icon: const Icon(Icons.copy),
              label: const Text('Duplicate'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Delete selected templates'),
                      content: Text(
                        'Delete ${viewModel.selectedTemplateIds.length} templates? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
                if (confirmed == true) {
                  await viewModel.deleteSelectedTemplates();
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
            const Spacer(),
            TextButton(
              onPressed: viewModel.clearSelection,
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<FourZhuEditorViewModel>().filterState;
    return SegmentedButton<TemplateGalleryCategory>(
      segments: const [
        ButtonSegment<TemplateGalleryCategory>(
          value: TemplateGalleryCategory.all,
          label: Text('All'),
        ),
        ButtonSegment<TemplateGalleryCategory>(
          value: TemplateGalleryCategory.favorites,
          label: Text('Favorites'),
        ),
        ButtonSegment<TemplateGalleryCategory>(
          value: TemplateGalleryCategory.recent,
          label: Text('Recent'),
        ),
      ],
      selected: <TemplateGalleryCategory>{filter.category},
      onSelectionChanged: (values) {
        if (values.isEmpty) {
          return;
        }
        context
            .read<FourZhuEditorViewModel>()
            .updateGalleryCategory(values.first);
        if (controller.hasClients) {
          controller.jumpTo(0);
        }
      },
    );
  }
}

class _SortSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FourZhuEditorViewModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Templates: ${viewModel.filteredTemplates.length}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        DropdownButton<TemplateSortOrder>(
          value: viewModel.filterState.sortOrder,
          onChanged: (value) {
            if (value != null) {
              context.read<FourZhuEditorViewModel>().updateSortOrder(value);
            }
          },
          items: const [
            DropdownMenuItem(
              value: TemplateSortOrder.updatedDesc,
              child: Text('Sort by Updated'),
            ),
            DropdownMenuItem(
              value: TemplateSortOrder.nameAsc,
              child: Text('Sort by Name'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TemplateCollection extends StatelessWidget {
  const _TemplateCollection({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FourZhuEditorViewModel>();
    final templates = viewModel.filteredTemplates;

    if (templates.isEmpty) {
      return const Center(
        child: Text('No templates match the current filters.'),
      );
    }

    switch (viewModel.viewMode) {
      case EditorViewMode.table:
        return _TemplateListView(
          templates: templates,
          controller: controller,
        );
      case EditorViewMode.canvas:
      case EditorViewMode.preview:
        return _TemplateCardGrid(
          templates: templates,
          controller: controller,
          mode: viewModel.viewMode,
        );
    }
  }
}

class _TemplateListView extends StatelessWidget {
  const _TemplateListView({
    required this.templates,
    required this.controller,
  });

  final List<LayoutTemplate> templates;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FourZhuEditorViewModel>();
    final currentTemplate = viewModel.currentTemplate;
    final isSelecting = viewModel.hasSelection;

    return ListView.separated(
      key: const PageStorageKey('template-gallery-list'),
      controller: controller,
      itemCount: templates.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final template = templates[index];
        final isCurrent = template.id == currentTemplate?.id;
        final isFavorite = viewModel.isFavorite(template.id);
        final isSelected = viewModel.isTemplateSelected(template.id);
        final details =
            '${template.rowConfigs.length} rows • ${template.chartGroups.length} groups';
        final updated =
            template.updatedAt.toLocal().toString().split('.').first;
        return ListTile(
          leading: Checkbox(
            value: isSelected,
            onChanged: (_) => context
                .read<FourZhuEditorViewModel>()
                .toggleTemplateSelection(template.id),
          ),
          title: Text(template.name),
          subtitle: Text('$details • Updated $updated'),
          selected: isCurrent,
          onTap: () {
            if (isSelecting) {
              context
                  .read<FourZhuEditorViewModel>()
                  .toggleTemplateSelection(template.id);
            } else {
              context
                  .read<FourZhuEditorViewModel>()
                  .selectTemplate(template.id);
            }
          },
          onLongPress: () {
            context
                .read<FourZhuEditorViewModel>()
                .toggleTemplateSelection(template.id);
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: isFavorite ? 'Remove favorite' : 'Mark as favorite',
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color:
                      isFavorite ? Theme.of(context).colorScheme.primary : null,
                ),
                onPressed: () => context
                    .read<FourZhuEditorViewModel>()
                    .toggleFavorite(template.id),
              ),
              _TemplateActionsButton(template: template),
            ],
          ),
        );
      },
    );
  }
}

class _TemplateCardGrid extends StatelessWidget {
  const _TemplateCardGrid({
    required this.templates,
    required this.controller,
    required this.mode,
  });

  final List<LayoutTemplate> templates;
  final ScrollController controller;
  final EditorViewMode mode;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FourZhuEditorViewModel>();
    final maxExtent = switch (mode) {
      EditorViewMode.canvas => 280.0,
      EditorViewMode.preview => 360.0,
      _ => 280.0,
    };
    final aspectRatio = mode == EditorViewMode.preview ? 1.25 : 1.05;

    return GridView.builder(
      key: const PageStorageKey('template-gallery-grid'),
      controller: controller,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxExtent,
        childAspectRatio: aspectRatio,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isCurrent = template.id == viewModel.currentTemplate?.id;
        final isFavorite = viewModel.isFavorite(template.id);
        final isSelected = viewModel.isTemplateSelected(template.id);
        final isSelecting = viewModel.hasSelection;
        return _TemplateCard(
          template: template,
          isCurrent: isCurrent,
          isFavorite: isFavorite,
          isSelected: isSelected,
          isSelecting: isSelecting,
          mode: mode,
          onTap: () {
            if (isSelecting) {
              context
                  .read<FourZhuEditorViewModel>()
                  .toggleTemplateSelection(template.id);
            } else {
              context
                  .read<FourZhuEditorViewModel>()
                  .selectTemplate(template.id);
            }
          },
          onLongPress: () {
            context
                .read<FourZhuEditorViewModel>()
                .toggleTemplateSelection(template.id);
          },
          onToggleFavorite: () => context
              .read<FourZhuEditorViewModel>()
              .toggleFavorite(template.id),
          onToggleSelection: () => context
              .read<FourZhuEditorViewModel>()
              .toggleTemplateSelection(template.id),
        );
      },
    );
  }
}

class _TemplateCard extends StatefulWidget {
  const _TemplateCard({
    required this.template,
    required this.isCurrent,
    required this.isFavorite,
    required this.isSelected,
    required this.isSelecting,
    required this.mode,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleFavorite,
    required this.onToggleSelection,
  });

  final LayoutTemplate template;
  final bool isCurrent;
  final bool isFavorite;
  final bool isSelected;
  final bool isSelecting;
  final EditorViewMode mode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleFavorite;
  final VoidCallback onToggleSelection;

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = _colorFromHex(widget.template.cardStyle.dividerColorHex);
    final gradient = LinearGradient(
      colors: [
        Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor,
        Color.lerp(baseColor, Colors.black, 0.1) ?? baseColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: _hovering || widget.isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : const [],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.template.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _TemplateActionsButton(template: widget.template),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _buildRowChips(widget.template, theme),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.template.updatedAt
                              .toLocal()
                              .toString()
                              .split('.')
                              .first,
                          style: theme.textTheme.bodySmall,
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: widget.isFavorite
                              ? 'Remove favorite'
                              : 'Mark as favorite',
                          icon: Icon(
                            widget.isFavorite ? Icons.star : Icons.star_border,
                            color: widget.isFavorite
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                          onPressed: widget.onToggleFavorite,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.isSelecting)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Checkbox(
                    value: widget.isSelected,
                    onChanged: (_) => widget.onToggleSelection(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRowChips(
    LayoutTemplate template,
    ThemeData theme,
  ) {
    final entries = template.rowConfigs.take(4).map((config) {
      return Chip(
        label: Text(
          _rowTypeLabel(config.type),
          style: theme.textTheme.bodySmall,
        ),
        visualDensity: VisualDensity.compact,
      );
    }).toList();
    if (template.rowConfigs.length > 4) {
      entries.add(
        Chip(
          label: Text('+${template.rowConfigs.length - 4}'),
          visualDensity: VisualDensity.compact,
        ),
      );
    }
    return entries;
  }
}

enum _TemplateAction { apply, rename, duplicate, delete, favorite, unfavorite }

class _TemplateActionsButton extends StatelessWidget {
  const _TemplateActionsButton({required this.template});

  final LayoutTemplate template;

  @override
  Widget build(BuildContext context) {
    return Consumer<FourZhuEditorViewModel>(
      builder: (context, viewModel, _) {
        final isFavorite = viewModel.isFavorite(template.id);
        return PopupMenuButton<_TemplateAction>(
          onSelected: (action) async {
            await _handleTemplateAction(context, template, action);
          },
          itemBuilder: (context) => <PopupMenuEntry<_TemplateAction>>[
            const PopupMenuItem(
              value: _TemplateAction.apply,
              child: Text('Apply'),
            ),
            const PopupMenuItem(
              value: _TemplateAction.rename,
              child: Text('Rename'),
            ),
            const PopupMenuItem(
              value: _TemplateAction.duplicate,
              child: Text('Duplicate'),
            ),
            PopupMenuItem(
              value: isFavorite
                  ? _TemplateAction.unfavorite
                  : _TemplateAction.favorite,
              child: Text(isFavorite ? 'Remove favorite' : 'Add favorite'),
            ),
            const PopupMenuItem(
              value: _TemplateAction.delete,
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _handleTemplateAction(
  BuildContext context,
  LayoutTemplate template,
  _TemplateAction action,
) async {
  final viewModel = context.read<FourZhuEditorViewModel>();
  switch (action) {
    case _TemplateAction.apply:
      await viewModel.selectTemplate(template.id);
      break;
    case _TemplateAction.rename:
      await _showRenameDialog(context, template);
      break;
    case _TemplateAction.duplicate:
      await viewModel.duplicateTemplateAsNew(template.id);
      break;
    case _TemplateAction.favorite:
      viewModel.toggleFavorite(template.id);
      break;
    case _TemplateAction.unfavorite:
      viewModel.toggleFavorite(template.id);
      break;
    case _TemplateAction.delete:
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Delete template'),
            content: Text(
              'Delete "${template.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
      if (confirm == true) {
        viewModel.selectTemplateForBulk(template.id);
        await viewModel.deleteSelectedTemplates();
      }
      break;
  }
}

Future<void> _showRenameDialog(
  BuildContext context,
  LayoutTemplate template,
) async {
  final controller = TextEditingController(text: template.name);
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Rename template'),
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
            child: const Text('Rename'),
          ),
        ],
      );
    },
  );
  if (result != null) {
    if (!context.mounted) {
      return;
    }
    await context
        .read<FourZhuEditorViewModel>()
        .renameTemplate(template.id, result);
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

String _rowTypeLabel(RowType type) {
  switch (type) {
    case RowType.heavenlyStem:
      return 'Heavenly Stem';
    case RowType.earthlyBranch:
      return 'Earthly Branch';
    case RowType.tenGod:
      return 'Ten God';
    case RowType.naYin:
      return 'Na Yin';
    case RowType.kongWang:
      return 'Void';
    case RowType.xunShou:
      return 'Leader';
    case RowType.hiddenStems:
      return 'Hidden Stems';
    case RowType.hiddenStemsTenGod:
      return 'Hidden Ten God';
    case RowType.hiddenStemsPrimary:
      return 'Primary Stem';
    case RowType.hiddenStemsSecondary:
      return 'Secondary Stem';
    case RowType.hiddenStemsTertiary:
      return 'Tertiary Stem';
    case RowType.hiddenStemsPrimaryGods:
      return 'Primary God';
    case RowType.hiddenStemsSecondaryGods:
      return 'Secondary God';
    case RowType.hiddenStemsTertiaryGods:
      return 'Tertiary God';
    case RowType.starYun:
      return 'Star Luck';
    case RowType.selfSiting:
      return 'Self Siting';
  }
}
