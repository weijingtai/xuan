import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/layout_template.dart';
import '../viewmodels/four_zhu_editor_view_model.dart';

class EditorTopBar extends StatelessWidget implements PreferredSizeWidget {
  const EditorTopBar({
    super.key,
    required this.nameController,
    required this.onCreateTemplate,
    required this.onOpenGallery,
    required this.onDeleteTemplate,
    required this.onDuplicateTemplate,
    required this.onSaveTemplate,
    required this.onUndoChanges,
    required this.onNameChanged,
  });

  final TextEditingController nameController;
  final Future<void> Function() onCreateTemplate;
  final VoidCallback onOpenGallery;
  final VoidCallback onDeleteTemplate;
  final VoidCallback onDuplicateTemplate;
  final VoidCallback onSaveTemplate;
  final VoidCallback onUndoChanges;
  final ValueChanged<String> onNameChanged;

  @override
  Size get preferredSize => const Size.fromHeight(148);

  @override
  Widget build(BuildContext context) {
    final uiState = context.select((FourZhuEditorViewModel vm) => vm.uiState);
    final templates =
        context.select((FourZhuEditorViewModel vm) => vm.templates);
    final currentTemplate =
        context.select((FourZhuEditorViewModel vm) => vm.currentTemplate);

    final shortcuts = <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true):
          const _PreviousTemplateIntent(),
      const SingleActivator(LogicalKeyboardKey.arrowRight, alt: true):
          const _NextTemplateIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
          const _SaveIntent(),
      LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS):
          const _SaveIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
          const _UndoIntent(),
      LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyZ):
          const _UndoIntent(),
      const SingleActivator(LogicalKeyboardKey.keyN, control: true, shift: true):
          const _CreateTemplateIntent(),
      const SingleActivator(LogicalKeyboardKey.keyN, meta: true, shift: true):
          const _CreateTemplateIntent(),
    };

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: {
          _SaveIntent: CallbackAction<_SaveIntent>(onInvoke: (intent) {
            if (uiState.canSave) {
              onSaveTemplate();
            }
            return null;
          }),
          _UndoIntent: CallbackAction<_UndoIntent>(onInvoke: (intent) {
            if (uiState.canRevert) {
              onUndoChanges();
            }
            return null;
          }),
          _NextTemplateIntent:
              CallbackAction<_NextTemplateIntent>(onInvoke: (intent) {
            context.read<FourZhuEditorViewModel>().selectTemplateByOffset(1);
            return null;
          }),
          _PreviousTemplateIntent:
              CallbackAction<_PreviousTemplateIntent>(onInvoke: (intent) {
            context.read<FourZhuEditorViewModel>().selectTemplateByOffset(-1);
            return null;
          }),
          _CreateTemplateIntent:
              CallbackAction<_CreateTemplateIntent>(onInvoke: (intent) {
            onCreateTemplate();
            return null;
          }),
        },
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: _EditorTopBarBody(
            uiState: uiState,
            templates: templates,
            currentTemplate: currentTemplate,
            nameController: nameController,
            onCreateTemplate: onCreateTemplate,
            onOpenGallery: onOpenGallery,
            onDeleteTemplate: onDeleteTemplate,
            onDuplicateTemplate: onDuplicateTemplate,
            onSaveTemplate: onSaveTemplate,
            onUndoChanges: onUndoChanges,
            onNameChanged: onNameChanged,
          ),
        ),
      ),
    );
  }
}

class _EditorTopBarBody extends StatelessWidget {
  const _EditorTopBarBody({
    required this.uiState,
    required this.templates,
    required this.currentTemplate,
    required this.nameController,
    required this.onCreateTemplate,
    required this.onOpenGallery,
    required this.onDeleteTemplate,
    required this.onDuplicateTemplate,
    required this.onSaveTemplate,
    required this.onUndoChanges,
    required this.onNameChanged,
  });

  final EditorUiState uiState;
  final List<LayoutTemplate> templates;
  final LayoutTemplate? currentTemplate;
  final TextEditingController nameController;
  final Future<void> Function() onCreateTemplate;
  final VoidCallback onOpenGallery;
  final VoidCallback onDeleteTemplate;
  final VoidCallback onDuplicateTemplate;
  final VoidCallback onSaveTemplate;
  final VoidCallback onUndoChanges;
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = uiState.isLoading;
    return Material(
      color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
      elevation: isBusy ? 4 : (theme.appBarTheme.elevation ?? 0),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBarControls(
                uiState: uiState,
                templates: templates,
                currentTemplate: currentTemplate,
                nameController: nameController,
                onOpenGallery: onOpenGallery,
                onDeleteTemplate: onDeleteTemplate,
                onDuplicateTemplate: onDuplicateTemplate,
                onSaveTemplate: onSaveTemplate,
                onUndoChanges: onUndoChanges,
                onNameChanged: onNameChanged,
              ),
              const SizedBox(height: 16),
              _TemplateTabBar(
                templates: templates,
                currentTemplate: currentTemplate,
                isBusy: isBusy,
                onCreateTemplate: onCreateTemplate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBarControls extends StatelessWidget {
  const _TopBarControls({
    required this.uiState,
    required this.templates,
    required this.currentTemplate,
    required this.nameController,
    required this.onOpenGallery,
    required this.onDeleteTemplate,
    required this.onDuplicateTemplate,
    required this.onSaveTemplate,
    required this.onUndoChanges,
    required this.onNameChanged,
  });

  final EditorUiState uiState;
  final List<LayoutTemplate> templates;
  final LayoutTemplate? currentTemplate;
  final TextEditingController nameController;
  final VoidCallback onOpenGallery;
  final VoidCallback onDeleteTemplate;
  final VoidCallback onDuplicateTemplate;
  final VoidCallback onSaveTemplate;
  final VoidCallback onUndoChanges;
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = uiState.isLoading;
    final viewModel = context.read<FourZhuEditorViewModel>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.space_dashboard_outlined, size: 24),
              const SizedBox(width: 16),
              SizedBox(
                width: 220,
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(1),
                  child: DropdownButtonFormField<String>(
                    value: currentTemplate?.id,
                    decoration: const InputDecoration(
                      labelText: '模板集合',
                      isDense: true,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    items: templates
                        .map(
                          (template) => DropdownMenuItem<String>(
                            value: template.id,
                            child: Text(
                              template.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: isBusy
                        ? null
                        : (value) {
                            if (value != null) {
                              viewModel.selectTemplateByTab(value);
                            }
                          },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(2),
                  child: Semantics(
                    label: '模板名称输入',
                    textField: true,
                    child: TextField(
                      controller: nameController,
                      enabled: !isBusy,
                      onChanged: onNameChanged,
                      decoration: const InputDecoration(
                        labelText: '模板名称',
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        FocusTraversalOrder(
          order: const NumericFocusOrder(3),
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              _ViewModeSelector(
                mode: uiState.viewMode,
                onChanged: isBusy
                    ? null
                    : (mode) => viewModel.setViewMode(mode),
              ),
              Tooltip(
                message: '打开模板库 (Alt+G)',
                child: IconButton(
                  icon: const Icon(Icons.collections_bookmark_outlined),
                  onPressed: isBusy ? null : onOpenGallery,
                ),
              ),
              Tooltip(
                message: '切换深色模式',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('夜间', style: TextStyle(fontSize: 12)),
                    Switch.adaptive(
                      value: uiState.isDarkMode,
                      onChanged: isBusy
                          ? null
                          : (value) => viewModel.toggleTheme(value),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: '撤销未保存修改 (Ctrl+Z)',
                child: FilledButton.icon(
                  onPressed: uiState.canRevert && !isBusy ? onUndoChanges : null,
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('撤销'),
                ),
              ),
              Tooltip(
                message: '保存模板 (Ctrl+S)',
                child: FilledButton.icon(
                  onPressed: uiState.canSave && !isBusy ? onSaveTemplate : null,
                  icon: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined, size: 16),
                  label: const Text('保存'),
                ),
              ),
              Tooltip(
                message: '复制模板',
                child: OutlinedButton.icon(
                  onPressed: isBusy ? null : onDuplicateTemplate,
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('复制'),
                ),
              ),
              Tooltip(
                message: '删除模板',
                child: IconButton(
                  onPressed: isBusy ? null : onDeleteTemplate,
                  icon: Icon(Icons.delete_outline,
                      color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TemplateTabBar extends StatelessWidget {
  const _TemplateTabBar({
    required this.templates,
    required this.currentTemplate,
    required this.isBusy,
    required this.onCreateTemplate,
  });

  final List<LayoutTemplate> templates;
  final LayoutTemplate? currentTemplate;
  final bool isBusy;
  final Future<void> Function() onCreateTemplate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...templates.map(
            (template) => _TemplateTabChip(
              template: template,
              isActive: template.id == currentTemplate?.id,
              disabled: isBusy,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Tooltip(
              message: '新建模板 (Ctrl+Shift+N)',
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : onCreateTemplate,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('新建模板'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateTabChip extends StatefulWidget {
  const _TemplateTabChip({
    required this.template,
    required this.isActive,
    required this.disabled,
  });

  final LayoutTemplate template;
  final bool isActive;
  final bool disabled;

  @override
  State<_TemplateTabChip> createState() => _TemplateTabChipState();
}

class _TemplateTabChipState extends State<_TemplateTabChip> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.7);
    final backgroundColor = widget.isActive
        ? theme.colorScheme.primary.withOpacity(0.16)
        : (_focused || _hovered)
            ? theme.colorScheme.primary.withOpacity(0.08)
            : theme.colorScheme.surfaceVariant.withOpacity(0.6);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FocusableActionDetector(
        enabled: !widget.disabled,
        onShowHoverHighlight: (value) {
          setState(() => _hovered = value);
        },
        onShowFocusHighlight: (value) {
          setState(() => _focused = value);
        },
        child: Semantics(
          button: true,
          selected: widget.isActive,
          label: widget.isActive
              ? '${widget.template.name}，当前模板'
              : widget.template.name,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: widget.disabled
                  ? null
                  : () async {
                      await context
                          .read<FourZhuEditorViewModel>()
                          .selectTemplateByTab(widget.template.id);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isActive
                        ? theme.colorScheme.primary
                        : _focused
                            ? theme.colorScheme.primary.withOpacity(0.6)
                            : theme.dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  widget.template.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: baseColor,
                    fontWeight:
                        widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewModeSelector extends StatelessWidget {
  const _ViewModeSelector({
    required this.mode,
    required this.onChanged,
  });

  final EditorViewMode mode;
  final ValueChanged<EditorViewMode>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onChanged == null;
    return SegmentedButton<EditorViewMode>(
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
      segments: const [
        ButtonSegment<EditorViewMode>(
          value: EditorViewMode.canvas,
          icon: Icon(Icons.view_quilt_outlined, size: 16),
          tooltip: '画布模式',
        ),
        ButtonSegment<EditorViewMode>(
          value: EditorViewMode.table,
          icon: Icon(Icons.view_list_outlined, size: 16),
          tooltip: '列表模式',
        ),
        ButtonSegment<EditorViewMode>(
          value: EditorViewMode.preview,
          icon: Icon(Icons.visibility_outlined, size: 16),
          tooltip: '预览模式',
        ),
      ],
      selected: <EditorViewMode>{mode},
      onSelectionChanged: isDisabled
          ? null
          : (values) {
              if (values.isNotEmpty) {
                onChanged!(values.first);
              }
            },
    );
  }
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _UndoIntent extends Intent {
  const _UndoIntent();
}

class _NextTemplateIntent extends Intent {
  const _NextTemplateIntent();
}

class _PreviousTemplateIntent extends Intent {
  const _PreviousTemplateIntent();
}

class _CreateTemplateIntent extends Intent {
  const _CreateTemplateIntent();
}
