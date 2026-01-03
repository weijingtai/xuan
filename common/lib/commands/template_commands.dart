import 'package:common/commands/editor_command.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/layout_template.dart';

/// 更新模板名称命令
class UpdateTemplateNameCommand extends EditorCommand {
  UpdateTemplateNameCommand({
    required this.oldName,
    required this.newName,
  });

  final String oldName;
  final String newName;

  @override
  String get description => '重命名模板: "$oldName" -> "$newName"';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(name: newName);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(name: oldName);
  }

  @override
  bool canMergeWith(EditorCommand other) {
    // 连续的重命名操作可以合并
    return other is UpdateTemplateNameCommand && other.oldName == newName;
  }

  @override
  EditorCommand mergeWith(EditorCommand other) {
    if (other is UpdateTemplateNameCommand) {
      return UpdateTemplateNameCommand(
        oldName: oldName,
        newName: other.newName,
      );
    }
    return this;
  }
}

class UpdateTemplateDescriptionCommand extends EditorCommand {
  UpdateTemplateDescriptionCommand({
    required this.oldDescription,
    required this.newDescription,
  });

  final String? oldDescription;
  final String? newDescription;

  @override
  String get description => '更新模板描述';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(description: newDescription);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(description: oldDescription);
  }

  @override
  bool canMergeWith(EditorCommand other) {
    return other is UpdateTemplateDescriptionCommand &&
        other.oldDescription == newDescription;
  }

  @override
  EditorCommand mergeWith(EditorCommand other) {
    if (other is UpdateTemplateDescriptionCommand) {
      return UpdateTemplateDescriptionCommand(
        oldDescription: oldDescription,
        newDescription: other.newDescription,
      );
    }
    return this;
  }
}

/// 添加柱位到分组命令
class AddPillarToGroupCommand extends EditorCommand {
  AddPillarToGroupCommand({
    required this.groupId,
    required this.pillar,
    required this.index,
  });

  final String groupId;
  final PillarType pillar;
  final int index;

  @override
  String get description => '添加柱位 ${pillar.name} 到分组 $groupId';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    final updatedGroups = currentTemplate.chartGroups.map((group) {
      if (group.id != groupId) return group;

      // 检查是否已存在
      if (group.pillarOrder.contains(pillar)) return group;

      final list = List<PillarType>.of(group.pillarOrder);
      final clamped = index.clamp(0, list.length);
      list.insert(clamped, pillar);
      return group.copyWith(pillarOrder: list);
    }).toList(growable: false);

    return currentTemplate.copyWith(chartGroups: updatedGroups);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    final updatedGroups = currentTemplate.chartGroups.map((group) {
      if (group.id != groupId) return group;

      final list = List<PillarType>.of(group.pillarOrder);
      // 找到并移除该柱位
      final pillarIndex = list.indexOf(pillar);
      if (pillarIndex >= 0) {
        list.removeAt(pillarIndex);
      }
      return group.copyWith(pillarOrder: list);
    }).toList(growable: false);

    return currentTemplate.copyWith(chartGroups: updatedGroups);
  }
}

/// 从分组移除柱位命令
class RemovePillarFromGroupCommand extends EditorCommand {
  RemovePillarFromGroupCommand({
    required this.groupId,
    required this.index,
    required this.removedPillar,
  });

  final String groupId;
  final int index;
  final PillarType removedPillar;

  @override
  String get description => '从分组 $groupId 移除柱位 ${removedPillar.name}';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    final updatedGroups = currentTemplate.chartGroups.map((group) {
      if (group.id != groupId) return group;

      final list = List<PillarType>.of(group.pillarOrder);
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
      }
      return group.copyWith(pillarOrder: list);
    }).toList(growable: false);

    return currentTemplate.copyWith(chartGroups: updatedGroups);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    final updatedGroups = currentTemplate.chartGroups.map((group) {
      if (group.id != groupId) return group;

      final list = List<PillarType>.of(group.pillarOrder);
      final clamped = index.clamp(0, list.length);
      list.insert(clamped, removedPillar);
      return group.copyWith(pillarOrder: list);
    }).toList(growable: false);

    return currentTemplate.copyWith(chartGroups: updatedGroups);
  }
}

/// 重排柱位命令
class ReorderPillarCommand extends EditorCommand {
  ReorderPillarCommand({
    required this.groupId,
    required this.oldIndex,
    required this.newIndex,
  });

  final String groupId;
  final int oldIndex;
  final int newIndex;

  @override
  String get description => '重排柱位: 位置 $oldIndex -> $newIndex';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return _reorder(currentTemplate, oldIndex, newIndex);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    // 撤销时反向操作
    return _reorder(currentTemplate, newIndex, oldIndex);
  }

  LayoutTemplate _reorder(
    LayoutTemplate template,
    int fromIndex,
    int toIndex,
  ) {
    final updatedGroups = template.chartGroups.map((group) {
      if (group.id != groupId) return group;

      final list = List<PillarType>.of(group.pillarOrder);
      if (fromIndex < 0 || fromIndex >= list.length) return group;

      final item = list.removeAt(fromIndex);
      final clamped = toIndex.clamp(0, list.length);
      list.insert(clamped, item);

      return group.copyWith(pillarOrder: list);
    }).toList(growable: false);

    return template.copyWith(chartGroups: updatedGroups);
  }
}

/// 添加分组命令
class AddGroupCommand extends EditorCommand {
  AddGroupCommand({
    required this.group,
  });

  final ChartGroup group;

  @override
  String get description => '添加分组: ${group.title}';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    final updated = List<ChartGroup>.of(currentTemplate.chartGroups)
      ..add(group);
    return currentTemplate.copyWith(chartGroups: updated);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    final updated = currentTemplate.chartGroups
        .where((g) => g.id != group.id)
        .toList();
    return currentTemplate.copyWith(chartGroups: updated);
  }
}

/// 移除分组命令
class RemoveGroupCommand extends EditorCommand {
  RemoveGroupCommand({
    required this.groupId,
    required this.removedGroup,
    required this.groupIndex,
  });

  final String groupId;
  final ChartGroup removedGroup;
  final int groupIndex;

  @override
  String get description => '删除分组: ${removedGroup.title}';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    final updated = currentTemplate.chartGroups
        .where((g) => g.id != groupId)
        .toList();
    return currentTemplate.copyWith(chartGroups: updated);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    final updated = List<ChartGroup>.of(currentTemplate.chartGroups);
    final clamped = groupIndex.clamp(0, updated.length);
    updated.insert(clamped, removedGroup);
    return currentTemplate.copyWith(chartGroups: updated);
  }
}

/// 更新分组标题命令
class UpdateGroupTitleCommand extends EditorCommand {
  UpdateGroupTitleCommand({
    required this.groupId,
    required this.oldTitle,
    required this.newTitle,
  });

  final String groupId;
  final String oldTitle;
  final String newTitle;

  @override
  String get description => '重命名分组: "$oldTitle" -> "$newTitle"';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return _updateTitle(currentTemplate, newTitle);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    return _updateTitle(currentTemplate, oldTitle);
  }

  LayoutTemplate _updateTitle(LayoutTemplate template, String title) {
    final updated = template.chartGroups
        .map((group) => group.id == groupId
            ? group.copyWith(title: title)
            : group)
        .toList(growable: false);
    return template.copyWith(chartGroups: updated);
  }

  @override
  bool canMergeWith(EditorCommand other) {
    // 连续的重命名操作可以合并
    return other is UpdateGroupTitleCommand &&
        other.groupId == groupId &&
        other.oldTitle == newTitle;
  }

  @override
  EditorCommand mergeWith(EditorCommand other) {
    if (other is UpdateGroupTitleCommand) {
      return UpdateGroupTitleCommand(
        groupId: groupId,
        oldTitle: oldTitle,
        newTitle: other.newTitle,
      );
    }
    return this;
  }
}

/// 更新行可见性命令
class UpdateRowVisibilityCommand extends EditorCommand {
  UpdateRowVisibilityCommand({
    required this.rowType,
    required this.oldVisibility,
    required this.newVisibility,
  });

  final RowType rowType;
  final bool oldVisibility;
  final bool newVisibility;

  @override
  String get description =>
      '${newVisibility ? "显示" : "隐藏"}行: ${rowType.name}';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return _updateVisibility(currentTemplate, newVisibility);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    return _updateVisibility(currentTemplate, oldVisibility);
  }

  LayoutTemplate _updateVisibility(LayoutTemplate template, bool isVisible) {
    final configs = template.rowConfigs
        .map((config) => config.type == rowType
            ? config.copyWith(isVisible: isVisible)
            : config)
        .toList(growable: false);
    return template.copyWith(rowConfigs: configs);
  }
}

/// 切换分组展开状态命令
class ToggleGroupExpandedCommand extends EditorCommand {
  ToggleGroupExpandedCommand({
    required this.groupId,
  });

  final String groupId;

  @override
  String get description => '切换分组展开状态';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return _toggle(currentTemplate);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    // 切换操作的撤销就是再次切换
    return _toggle(currentTemplate);
  }

  LayoutTemplate _toggle(LayoutTemplate template) {
    final updated = template.chartGroups.map((group) {
      if (group.id != groupId) return group;
      return group.copyWith(expanded: !group.expanded);
    }).toList(growable: false);
    return template.copyWith(chartGroups: updated);
  }
}
