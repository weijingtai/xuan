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
    required this.onDeleteTemplate,
    required this.onDuplicateTemplate,
    required this.onSaveTemplate,
    required this.onUndoChanges,
    required this.onNameChanged,
  });

  final TextEditingController nameController;
  final Future<void> Function() onCreateTemplate;
  final VoidCallback onDeleteTemplate;
  final VoidCallback onDuplicateTemplate;
  final VoidCallback onSaveTemplate;
  final VoidCallback onUndoChanges;
  final ValueChanged<String> onNameChanged;

  @override
  Size get preferredSize => const Size.fromHeight(72);

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
      // M4.3.3 - 命令级撤销 (Ctrl+Z)
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
          const _CommandUndoIntent(),
      LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyZ):
          const _CommandUndoIntent(),
      // M4.3.3 - 命令级重做 (Ctrl+Y 或 Ctrl+Shift+Z)
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY):
          const _CommandRedoIntent(),
      LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyY):
          const _CommandRedoIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyZ): const _CommandRedoIntent(),
      LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyZ): const _CommandRedoIntent(),
      // 原有的撤销所有未保存修改 (Ctrl+R)
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
          const _RevertIntent(),
      LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyR):
          const _RevertIntent(),
      const SingleActivator(LogicalKeyboardKey.keyN,
          control: true, shift: true): const _CreateTemplateIntent(),
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
          // M4.3.3 - 命令级撤销/重做
          _CommandUndoIntent:
              CallbackAction<_CommandUndoIntent>(onInvoke: (intent) {
            final vm = context.read<FourZhuEditorViewModel>();
            if (vm.canUndo) {
              vm.undoLastChange();
            }
            return null;
          }),
          _CommandRedoIntent:
              CallbackAction<_CommandRedoIntent>(onInvoke: (intent) {
            final vm = context.read<FourZhuEditorViewModel>();
            if (vm.canRedo) {
              vm.redoLastChange();
            }
            return null;
          }),
          // 原有的撤销所有未保存修改
          _RevertIntent: CallbackAction<_RevertIntent>(onInvoke: (intent) {
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
                onDeleteTemplate: onDeleteTemplate,
                onDuplicateTemplate: onDuplicateTemplate,
                onSaveTemplate: onSaveTemplate,
                onUndoChanges: onUndoChanges,
                onNameChanged: onNameChanged,
              ),
              // New TemplateGalleryView supersedes the old chip tab bar.
              // Removing the old _TemplateTabBar to avoid duplicate template UI.
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
    final currentName = currentTemplate?.name ?? '未命名模板';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左侧：当前模板名称（只读标签）
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              currentName,
              style: theme.textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        // 右侧：主操作 + 溢出菜单
        Flexible(
          child: FocusTraversalOrder(
            order: const NumericFocusOrder(3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: '保存模板 (Ctrl+S)',
                  child: FilledButton.icon(
                    onPressed:
                        uiState.canSave && !isBusy ? onSaveTemplate : null,
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
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: '更多',
                  icon: const Icon(Icons.more_horiz),
                  onSelected: (value) {
                    switch (value) {
                      case 'revert':
                        if (uiState.canRevert && !isBusy) onUndoChanges();
                        break;
                      case 'copy':
                        if (!isBusy) onDuplicateTemplate();
                        break;
                      case 'saveAs':
                        if (!isBusy) _showSaveAsDialog(context, viewModel);
                        break;
                      case 'delete':
                        if (!isBusy) onDeleteTemplate();
                        break;
                      case 'toggleDark':
                        if (!isBusy) viewModel.toggleTheme(!uiState.isDarkMode);
                        break;
                      case 'undo':
                        if (viewModel.canUndo && !isBusy) {
                          viewModel.undoLastChange();
                        }
                        break;
                      case 'redo':
                        if (viewModel.canRedo && !isBusy) {
                          viewModel.redoLastChange();
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'revert',
                      enabled: uiState.canRevert && !isBusy,
                      child: const ListTile(
                        leading: Icon(Icons.restore),
                        title: Text('还原'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'copy',
                      enabled: !isBusy,
                      child: const ListTile(
                        leading: Icon(Icons.copy_all),
                        title: Text('复制'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'saveAs',
                      enabled: !isBusy,
                      child: const ListTile(
                        leading: Icon(Icons.save_as),
                        title: Text('另存为'),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'undo',
                      enabled: viewModel.canUndo && !isBusy,
                      child: const ListTile(
                        leading: Icon(Icons.undo),
                        title: Text('撤销'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'redo',
                      enabled: viewModel.canRedo && !isBusy,
                      child: const ListTile(
                        leading: Icon(Icons.redo),
                        title: Text('重做'),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'toggleDark',
                      enabled: !isBusy,
                      child: ListTile(
                        leading: const Icon(Icons.dark_mode),
                        title: Text(uiState.isDarkMode ? '切换到浅色' : '切换到深色'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      enabled: !isBusy,
                      child: ListTile(
                        leading: Icon(Icons.delete_outline,
                            color: theme.colorScheme.error),
                        title: const Text('删除'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.6);

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

/// Task 2.2.1 - 模板下拉选择器组件
class _TemplateDropdownSelector extends StatelessWidget {
  const _TemplateDropdownSelector({
    required this.templates,
    required this.currentTemplate,
    required this.isEnabled,
    required this.onChanged,
  });

  final List<LayoutTemplate> templates;
  final LayoutTemplate? currentTemplate;
  final bool isEnabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 250),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentTemplate?.id,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          style: theme.textTheme.bodyMedium,
          items: templates.map((template) {
            return DropdownMenuItem<String>(
              value: template.id,
              child: Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: isEnabled ? onChanged : null,
        ),
      ),
    );
  }
}

/// Task 2.2.2 - 另存为对话框
void _showSaveAsDialog(
  BuildContext context,
  FourZhuEditorViewModel viewModel,
) {
  final controller = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.save_as, size: 20),
            SizedBox(width: 8),
            Text('另存为新模板'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('请输入新模板名称:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '模板名称',
                  hintText: '例如: 我的自定义模板',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.of(dialogContext).pop();
                    // Task 2.2.3 - 调用 ViewModel 方法
                    viewModel.saveTemplateAs(value.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已另存为: ${value.trim()}')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(dialogContext).pop();
                // Task 2.2.3 - 调用 ViewModel 方法
                viewModel.saveTemplateAs(name);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已另存为: $name')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      );
    },
  );
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
      style: const ButtonStyle(
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

// M4.3.3 - 命令级撤销Intent
class _CommandUndoIntent extends Intent {
  const _CommandUndoIntent();
}

// M4.3.3 - 命令级重做Intent
class _CommandRedoIntent extends Intent {
  const _CommandRedoIntent();
}

// 撤销所有未保存修改Intent
class _RevertIntent extends Intent {
  const _RevertIntent();
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
