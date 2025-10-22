import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../enums/layout_template_enums.dart';
import '../models/pillar_data.dart';
import '../models/pillar_preset.dart';
import 'pillar_preset_card.dart';
import 'template_board_column.dart';

class TemplateBoardView extends StatelessWidget {
  const TemplateBoardView({
    super.key,
    required this.groupId,
    required this.pillars,
    required this.dividerType,
    required this.dividerColor,
    required this.onReorder,
    required this.onInsert,
    required this.onRemove,
    this.onRename,
    this.onToggleLock,
    this.onSetColor,
    this.onResetLayout,
    this.onDeleteGroup,
    this.locked = false,
    this.groupTitle,
    this.groupColor,
    this.visibleRowCount,
    this.expanded = true,
    this.onSelect,
    this.onToggleExpanded,
    this.onDuplicateGroup,
    this.onClearGroup,
    this.onInsertSeparator,
    this.onAlignPillars,
    this.isSelected = false,
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
  final void Function({
    required String groupId,
    required int index,
    required PillarType pillar,
  }) onInsert;
  final void Function({
    required String groupId,
    required int index,
  }) onRemove;
  final void Function(String groupId, String title)? onRename;
  final void Function(String groupId, bool locked)? onToggleLock;
  final void Function(String groupId, String colorHex)? onSetColor;
  final void Function(String groupId)? onResetLayout;
  final void Function(String groupId)? onDeleteGroup;
  final bool locked;
  final String? groupTitle;
  final String? groupColor;
  final int? visibleRowCount;
  final bool expanded;
  final VoidCallback? onSelect;
  final VoidCallback? onToggleExpanded;
  final VoidCallback? onDuplicateGroup;
  final VoidCallback? onClearGroup;
  final void Function({required String groupId, required int index})?
      onInsertSeparator;
  final void Function(String groupId)? onAlignPillars;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (pillars.isEmpty) {
      return DragTarget<Object>(
        onWillAccept: (data) => data != null,
        onAccept: (data) {
          if (data is PillarData) {
            final type = _mapPillarDataToType(data);
            if (type != null) {
              onInsert(groupId: groupId, index: 0, pillar: type);
            }
            return;
          }
          if (data is PillarPreset) {
            for (final id in data.pillarIds.reversed) {
              final type = _mapPillarIdToType(id);
              if (type != null) {
                onInsert(groupId: groupId, index: 0, pillar: type);
              }
            }
            return;
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            height: 140,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: _buildBorder(),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Text(candidateData.isNotEmpty ? '释放以插入列' : '拖入柱模板以创建列'),
          );
        },
      );
    }

    final shortcuts = <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.keyL): const _ToggleLockIntent(),
      const SingleActivator(LogicalKeyboardKey.keyR): const _RenameIntent(),
      const SingleActivator(LogicalKeyboardKey.keyC): const _ColorIntent(),
      const SingleActivator(LogicalKeyboardKey.keyX): const _ResetIntent(),
    };

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: {
          _ToggleLockIntent: CallbackAction<_ToggleLockIntent>(onInvoke: (i) {
            if (onToggleLock != null) onToggleLock!(groupId, !locked);
            return null;
          }),
          _RenameIntent: CallbackAction<_RenameIntent>(onInvoke: (i) {
            if (onRename != null) _promptRename(context);
            return null;
          }),
          _ColorIntent: CallbackAction<_ColorIntent>(onInvoke: (i) {
            if (onSetColor != null) _promptColor(context);
            return null;
          }),
          _ResetIntent: CallbackAction<_ResetIntent>(onInvoke: (i) {
            if (onResetLayout != null) onResetLayout!(groupId);
            return null;
          }),
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BoardHeader(
              title: groupTitle ?? '未命名分组',
              colorHex: groupColor,
              locked: locked,
              pillarCount: pillars.length,
              visibleRowCount: visibleRowCount,
              onRename: onRename == null ? null : () => _promptRename(context),
              onToggleLock: onToggleLock == null
                  ? null
                  : () => onToggleLock!(groupId, !locked),
              onSetColor:
                  onSetColor == null ? null : () => _promptColor(context),
              onReset:
                  onResetLayout == null ? null : () => onResetLayout!(groupId),
              // onDelete: onDeleteGroup == null
              //     ? null
              //     : () async {
              //         final ok = await _confirmDelete(context);
              //         if (ok) onDeleteGroup!(groupId);
              //       },
              onSelect: onSelect,
              onToggleExpanded: onToggleExpanded,
              onDuplicate: onDuplicateGroup,
              onClear: onClearGroup,
              onInsertSeparator: onInsertSeparator == null
                  ? null
                  : () => onInsertSeparator!(
                      groupId: groupId, index: pillars.length),
              onAlign: onAlignPillars == null
                  ? null
                  : () => onAlignPillars!(groupId),
              isSelected: isSelected,
            ),
            const SizedBox(height: 8),
            if (expanded)
              SizedBox(
              height: 140,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pillars.length,
                onReorder: (oldIndex, newIndex) {
                  if (locked) return;
                  var target = newIndex;
                  if (newIndex > oldIndex) target -= 1;
                  onReorder(
                      groupId: groupId, oldIndex: oldIndex, newIndex: target);
                },
                itemBuilder: (context, index) {
                  final pillar = pillars[index];
                  return DragTarget<Object>(
                    key: ValueKey('board-$groupId-$index-${pillar.name}'),
                    onWillAccept: (data) => !locked && data != null,
                    onAccept: (data) {
                        if (data is PillarData) {
                          final type = _mapPillarDataToType(data);
                          if (type != null) {
                            onInsert(
                                groupId: groupId, index: index, pillar: type);
                          }
                          return;
                        }
                        if (data is PillarPreset) {
                          for (final id in data.pillarIds.reversed) {
                            final type = _mapPillarIdToType(id);
                            if (type != null) {
                              onInsert(
                                  groupId: groupId, index: index, pillar: type);
                            }
                          }
                          return;
                        }
                      },
                    builder: (context, candidateData, rejectedData) {
                      final highlight = candidateData.isNotEmpty;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TemplateBoardColumn(
                              label: _pillarTypeLabel(pillar),
                              index: index,
                              locked: locked,
                              borderColor: groupColor != null
                                  ? _colorFromHex(groupColor!)
                                  : dividerColor,
                              onRemove: () =>
                                  onRemove(groupId: groupId, index: index),
                              highlight: highlight,
                            ),
                            IconButton(
                              key: ValueKey('insert-sep-$groupId-$index'),
                              icon: const Icon(Icons.more_vert),
                              tooltip: '在此后插入分隔符',
                              onPressed: locked
                                  ? null
                                  : () => onInsertSeparator?.call(
                                        groupId: groupId,
                                        index: index + 1,
                                      ),
                            ),
                          ],
                      );
                    },
                  );
                },
              ),
            )
            else
              Container(
                height: 44,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: _buildBorder(
                      color: groupColor != null
                          ? _colorFromHex(groupColor!)
                          : dividerColor),
                ),
                child: Text('已收起，点击左侧按钮展开'),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: locked ? null : () => onAlignPillars?.call(groupId),
                icon: const Icon(Icons.straighten),
                label: const Text('对齐列宽'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除分组'),
        content: const Text('确认删除该分组？该操作不可撤销。'),
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
    return res ?? false;
  }

  Future<void> _promptRename(BuildContext context) async {
    if (onRename == null) return;
    final controller = TextEditingController(text: groupTitle ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('重命名分组'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '输入分组名称'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
    if (newName != null && newName.isNotEmpty) {
      onRename!(groupId, newName);
    }
  }

  Future<void> _promptColor(BuildContext context) async {
    if (onSetColor == null) return;
    final controller = TextEditingController(
      text: groupColor ?? _colorToHex(dividerColor),
    );
    final newHex = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('设置分组颜色'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '#RRGGBB 或 #AARRGGBB'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
    if (newHex != null && newHex.isNotEmpty) {
      onSetColor!(groupId, newHex);
    }
  }

  BoxBorder _buildBorder({Color? color}) {
    final c = color ?? dividerColor;
    switch (dividerType) {
      case BorderType.dashed:
      case BorderType.dotted:
        return Border.all(color: c.withValues(alpha: 0.6));
      case BorderType.none:
        return Border.all(color: c.withValues(alpha: 0));
      case BorderType.solid:
        return Border.all(color: c);
    }
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
      return '分隔符';
  }
}

PillarType? _mapPillarDataToType(PillarData data) {
  switch (data.pillarId) {
    case 'year':
      return PillarType.year;
    case 'month':
      return PillarType.month;
    case 'day':
      return PillarType.day;
    case 'time':
      return PillarType.hour;
    case 'taiyuan':
      return PillarType.taiMeta;
    case 'dayun':
      return PillarType.luckCycle;
    case 'liunian':
      return PillarType.annual;
    case 'separator':
      return PillarType.separator;
    default:
      return null;
  }
}

PillarType? _mapPillarIdToType(String id) {
  switch (id) {
    case 'year':
      return PillarType.year;
    case 'month':
      return PillarType.month;
    case 'day':
      return PillarType.day;
    case 'time':
      return PillarType.hour;
    case 'taiyuan':
      return PillarType.taiMeta;
    case 'dayun':
      return PillarType.luckCycle;
    case 'liunian':
      return PillarType.annual;
    case 'separator':
      return PillarType.separator;
  }
  return null;
}

class _BoardHeader extends StatelessWidget {
  const _BoardHeader({
    required this.title,
    required this.locked,
    this.colorHex,
    this.pillarCount,
    this.visibleRowCount,
    this.onRename,
    this.onToggleLock,
    this.onSetColor,
    this.onReset,
    this.onSelect,
    this.onToggleExpanded,
    this.onDuplicate,
    this.onClear,
    this.isSelected = false,
    this.onInsertSeparator,
    this.onAlign,
  });

  final String title;
  final bool locked;
  final String? colorHex;
  final int? pillarCount;
  final int? visibleRowCount;
  final VoidCallback? onRename;
  final VoidCallback? onToggleLock;
  final VoidCallback? onSetColor;
  final VoidCallback? onReset;
  final VoidCallback? onSelect;
  final VoidCallback? onToggleExpanded;
  final VoidCallback? onDuplicate;
  final VoidCallback? onClear;
  final bool isSelected;
  final VoidCallback? onInsertSeparator;
  final VoidCallback? onAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.unfold_more),
          tooltip: '展开/收起',
          onPressed: onToggleExpanded,
        ),
        IconButton(
          icon: Icon(locked ? Icons.lock : Icons.lock_open),
          tooltip: locked ? '解锁' : '锁定',
          onPressed: onToggleLock,
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: colorHex != null
                ? _colorFromHex(colorHex!)
                : theme.dividerColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: onSelect,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.08)
                      : null,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
        if (pillarCount != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('柱位: $pillarCount', style: theme.textTheme.labelSmall),
          ),
        if (visibleRowCount != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('可见行: $visibleRowCount',
                style: theme.textTheme.labelSmall),
          ),
        PopupMenuButton<String>(
          tooltip: '更多操作',
          onSelected: (value) async {
            switch (value) {
              case 'rename':
                onRename?.call();
                break;
              case 'lock':
                onToggleLock?.call();
                break;
              case 'color':
                onSetColor?.call();
                break;
              case 'reset':
                onReset?.call();
                break;
              case 'duplicate':
                onDuplicate?.call();
                break;
              case 'clear':
                onClear?.call();
                break;
              case 'separator_end':
                onInsertSeparator?.call();
                break;
              case 'align':
                onAlign?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'rename', child: Text('重命名')),
            PopupMenuItem(value: 'lock', child: Text(locked ? '解锁' : '锁定')),
            const PopupMenuItem(value: 'color', child: Text('设置颜色')),
            const PopupMenuItem(value: 'reset', child: Text('重置布局')),
            const PopupMenuItem(value: 'duplicate', child: Text('复制分组')),
            const PopupMenuItem(value: 'clear', child: Text('清空分组')),
            const PopupMenuDivider(),
            const PopupMenuItem(
                value: 'separator_end', child: Text('在末尾插入分隔符')),
            const PopupMenuItem(value: 'align', child: Text('对齐列宽')),
          ],
        ),
      ],
    );
  }
}

class _ToggleLockIntent extends Intent {
  const _ToggleLockIntent();
}

class _RenameIntent extends Intent {
  const _RenameIntent();
}

class _ColorIntent extends Intent {
  const _ColorIntent();
}

class _ResetIntent extends Intent {
  const _ResetIntent();
}

// Top-level helpers referenced by both the board and header
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
    return const Color(0xFF9E9E9E); // fallback grey
  }
}

String _colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}
