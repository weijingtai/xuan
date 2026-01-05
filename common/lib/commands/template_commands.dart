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

      final list = List<PillarType>.of(group.pillarOrder);

      // 允许分隔符重复添加，或者是新元素
      if (pillar == PillarType.separator || !list.contains(pillar)) {
        // 使用 clamp 确保索引在有效范围内 [0, length]
        final target = index.clamp(0, list.length);
        list.insert(target, pillar);
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
      // 撤销插入：移除在插入位置的元素
      // 插入时使用了 index.clamp(0, oldLength)
      // 现在的 list 长度比插入前大 1，所以 oldLength = list.length - 1
      final target = index.clamp(0, list.length - 1);
      if (target >= 0 && target < list.length) {
        list.removeAt(target);
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
    this.index,
  });

  final ChartGroup group;
  final int? index;

  @override
  String get description => '添加分组: ${group.title}';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    final updated = List<ChartGroup>.of(currentTemplate.chartGroups);
    if (index != null) {
      final clamped = index!.clamp(0, updated.length);
      updated.insert(clamped, group);
    } else {
      updated.add(group);
    }
    return currentTemplate.copyWith(chartGroups: updated);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    final updated =
        currentTemplate.chartGroups.where((g) => g.id != group.id).toList();
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
    final updated =
        currentTemplate.chartGroups.where((g) => g.id != groupId).toList();
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
        .map((group) =>
            group.id == groupId ? group.copyWith(title: title) : group)
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
  String get description => '${newVisibility ? "显示" : "隐藏"}行: ${rowType.name}';

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

class UpdateRowTitleVisibilityCommand extends EditorCommand {
  UpdateRowTitleVisibilityCommand({
    required this.rowType,
    required this.oldVisibility,
    required this.newVisibility,
  });

  final RowType rowType;
  final bool oldVisibility;
  final bool newVisibility;

  @override
  String get description =>
      '${newVisibility ? "显示" : "隐藏"}行标题: ${rowType.name}';

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
            ? config.copyWith(isTitleVisible: isVisible)
            : config)
        .toList(growable: false);
    return template.copyWith(rowConfigs: configs);
  }
}

class ReorderRowConfigsCommand extends EditorCommand {
  ReorderRowConfigsCommand({
    required this.oldRowConfigs,
    required this.newRowConfigs,
  });

  final List<RowConfig> oldRowConfigs;
  final List<RowConfig> newRowConfigs;

  @override
  String get description => '重排行配置';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(rowConfigs: newRowConfigs);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(rowConfigs: oldRowConfigs);
  }
}

class UpdateDividerTypeCommand extends EditorCommand {
  UpdateDividerTypeCommand({
    required this.oldType,
    required this.newType,
  });

  final BorderType oldType;
  final BorderType newType;

  @override
  String get description => '更新分割线类型';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    final style = currentTemplate.cardStyle.copyWith(dividerType: newType);
    return currentTemplate.copyWith(cardStyle: style);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    final style = currentTemplate.cardStyle.copyWith(dividerType: oldType);
    return currentTemplate.copyWith(cardStyle: style);
  }
}

class UpdateDividerColorCommand extends EditorCommand {
  UpdateDividerColorCommand({
    required this.oldColorHex,
    required this.newColorHex,
  });

  final String oldColorHex;
  final String newColorHex;

  @override
  String get description => '更新分割线颜色';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    final style =
        currentTemplate.cardStyle.copyWith(dividerColorHex: newColorHex);
    return currentTemplate.copyWith(cardStyle: style);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    final style =
        currentTemplate.cardStyle.copyWith(dividerColorHex: oldColorHex);
    return currentTemplate.copyWith(cardStyle: style);
  }
}

class UpdateChartGroupsCommand extends EditorCommand {
  UpdateChartGroupsCommand({
    required this.oldGroups,
    required this.newGroups,
  });

  final List<ChartGroup> oldGroups;
  final List<ChartGroup> newGroups;

  @override
  String get description => '更新图表分组';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(chartGroups: newGroups);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(chartGroups: oldGroups);
  }
}

class ReorderRowCommand extends EditorCommand {
  ReorderRowCommand({
    required this.oldIndex,
    required this.newIndex,
  });

  final int oldIndex;
  final int newIndex;

  @override
  String get description => '重排行: $oldIndex -> $newIndex';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    final configs = List<RowConfig>.of(currentTemplate.rowConfigs);
    if (oldIndex < 0 || oldIndex >= configs.length) return currentTemplate;

    final item = configs.removeAt(oldIndex);
    final target = newIndex.clamp(0, configs.length);
    configs.insert(target, item);

    return currentTemplate.copyWith(rowConfigs: configs);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    final configs = List<RowConfig>.of(currentTemplate.rowConfigs);
    if (newIndex < 0 || newIndex >= configs.length) return currentTemplate;

    final item = configs.removeAt(newIndex);
    final target = oldIndex.clamp(0, configs.length);
    configs.insert(target, item);

    return currentTemplate.copyWith(rowConfigs: configs);
  }
}

class InsertRowCommand extends EditorCommand {
  InsertRowCommand({
    required this.rowConfig,
    required this.index,
  });

  final RowConfig rowConfig;
  final int index;

  @override
  String get description => '插入行: ${rowConfig.type.name}';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    final configs = List<RowConfig>.of(currentTemplate.rowConfigs);
    final target = index.clamp(0, configs.length);
    configs.insert(target, rowConfig);
    return currentTemplate.copyWith(rowConfigs: configs);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    final configs = List<RowConfig>.of(currentTemplate.rowConfigs);
    // Undo insertion: remove the item at the index where it was inserted.
    // Since currentTemplate has the item, length is greater by 1.
    // The insertion index was index.clamp(0, old_length).
    // old_length = configs.length - 1.
    final target = index.clamp(0, configs.length - 1);
    if (target >= 0 && target < configs.length) {
      configs.removeAt(target);
    }
    return currentTemplate.copyWith(rowConfigs: configs);
  }
}

class DeleteRowCommand extends EditorCommand {
  DeleteRowCommand({
    required this.index,
    required this.rowConfig,
  });

  final int index;
  final RowConfig rowConfig;

  @override
  String get description => '删除行: ${rowConfig.type.name}';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    final configs = List<RowConfig>.of(currentTemplate.rowConfigs);
    if (index >= 0 && index < configs.length) {
      configs.removeAt(index);
    }
    return currentTemplate.copyWith(rowConfigs: configs);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    final configs = List<RowConfig>.of(currentTemplate.rowConfigs);
    final target = index.clamp(0, configs.length);
    configs.insert(target, rowConfig);
    return currentTemplate.copyWith(rowConfigs: configs);
  }
}

class UpdateDividerThicknessCommand extends EditorCommand {
  UpdateDividerThicknessCommand({
    required this.oldThickness,
    required this.newThickness,
  });

  final double oldThickness;
  final double newThickness;

  @override
  String get description => '更新分割线粗细';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    final style = currentTemplate.cardStyle
        .copyWith(dividerThickness: newThickness.clamp(0.5, 8));
    return currentTemplate.copyWith(cardStyle: style);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    final style = currentTemplate.cardStyle
        .copyWith(dividerThickness: oldThickness.clamp(0.5, 8));
    return currentTemplate.copyWith(cardStyle: style);
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

/// 重排分组命令
class ReorderGroupsCommand extends EditorCommand {
  ReorderGroupsCommand({
    required this.oldIndex,
    required this.newIndex,
  });

  final int oldIndex;
  final int newIndex;

  @override
  String get description => '重排分组: $oldIndex -> $newIndex';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return _reorder(currentTemplate, oldIndex, newIndex);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    return _reorder(currentTemplate, newIndex, oldIndex);
  }

  LayoutTemplate _reorder(LayoutTemplate template, int from, int to) {
    final list = List<ChartGroup>.of(template.chartGroups);
    if (from < 0 || from >= list.length) return template;

    final item = list.removeAt(from);
    final target = to.clamp(0, list.length);
    list.insert(target, item);

    return template.copyWith(chartGroups: list);
  }
}

/// 更新行配置命令（通用）
class UpdateRowConfigCommand extends EditorCommand {
  UpdateRowConfigCommand({
    required this.rowType,
    required this.oldConfig,
    required this.newConfig,
  });

  final RowType rowType;
  final RowConfig oldConfig;
  final RowConfig newConfig;

  @override
  String get description => '更新行配置: ${rowType.name}';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return _update(currentTemplate, newConfig);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    return _update(currentTemplate, oldConfig);
  }

  LayoutTemplate _update(LayoutTemplate template, RowConfig config) {
    final updated = template.rowConfigs
        .map((c) => c.type == rowType ? config : c)
        .toList(growable: false);
    return template.copyWith(rowConfigs: updated);
  }
}

/// 更新卡片整体样式命令
class UpdateCardStyleCommand extends EditorCommand {
  UpdateCardStyleCommand({
    required this.oldStyle,
    required this.newStyle,
  });

  final CardStyle oldStyle;
  final CardStyle newStyle;

  @override
  String get description => '更新卡片样式';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(cardStyle: newStyle);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(cardStyle: oldStyle);
  }
}

/// 更新分组信息命令（通用）
class UpdateGroupCommand extends EditorCommand {
  UpdateGroupCommand({
    required this.groupId,
    required this.oldGroup,
    required this.newGroup,
    this.customDescription,
  });

  final String groupId;
  final ChartGroup oldGroup;
  final ChartGroup newGroup;
  final String? customDescription;

  @override
  String get description => customDescription ?? '更新分组信息';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    final updated = currentTemplate.chartGroups
        .map((g) => g.id == groupId ? newGroup : g)
        .toList(growable: false);
    return currentTemplate.copyWith(chartGroups: updated);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    final updated = currentTemplate.chartGroups
        .map((g) => g.id == groupId ? oldGroup : g)
        .toList(growable: false);
    return currentTemplate.copyWith(chartGroups: updated);
  }
}

/// 跨分组移动柱位命令
class MovePillarBetweenGroupsCommand extends EditorCommand {
  MovePillarBetweenGroupsCommand({
    required this.sourceGroupId,
    required this.targetGroupId,
    required this.sourceIndex,
    required this.targetIndex,
    required this.pillar,
  });

  final String sourceGroupId;
  final String targetGroupId;
  final int sourceIndex;
  final int targetIndex;
  final PillarType pillar;

  @override
  String get description => '移动柱位 ${pillar.name}';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return _move(currentTemplate, sourceGroupId, targetGroupId, sourceIndex,
        targetIndex);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    // 撤销：从目标移回源（注意索引可能需要反向计算，但这里我们尽量还原）
    // 简单起见，如果移动是：源移除 -> 目标插入
    // 撤销是：目标移除（新位置） -> 源插入（旧位置）
    // 注意 targetIndex 是插入位置。
    return _move(currentTemplate, targetGroupId, sourceGroupId, targetIndex,
        sourceIndex);
  }

  LayoutTemplate _move(
    LayoutTemplate template,
    String fromId,
    String toId,
    int fromIndex,
    int toIndex,
  ) {
    final groups = template.chartGroups.map((g) => g).toList();

    // 1. Remove from source
    final sourceGroupIndex = groups.indexWhere((g) => g.id == fromId);
    if (sourceGroupIndex == -1) return template;

    var sourceGroup = groups[sourceGroupIndex];
    var sourcePillars = List<PillarType>.from(sourceGroup.pillarOrder);

    // 如果 fromIndex 无效，可能无法移除，直接返回
    if (fromIndex < 0 || fromIndex >= sourcePillars.length) return template;

    final item = sourcePillars.removeAt(fromIndex);
    groups[sourceGroupIndex] = sourceGroup.copyWith(pillarOrder: sourcePillars);

    // 2. Insert to target
    final targetGroupIndex = groups.indexWhere((g) => g.id == toId);
    if (targetGroupIndex == -1) return template; // 应该不会发生，除非分组被删

    var targetGroup = groups[targetGroupIndex];
    var targetPillars = List<PillarType>.from(targetGroup.pillarOrder);

    // 目标位置 clamp
    final insertIdx = toIndex.clamp(0, targetPillars.length);
    targetPillars.insert(insertIdx, item);
    groups[targetGroupIndex] = targetGroup.copyWith(pillarOrder: targetPillars);

    return template.copyWith(chartGroups: groups);
  }
}

/// 应用预设命令
class ApplyPresetCommand extends EditorCommand {
  ApplyPresetCommand({
    required this.oldGroups,
    required this.newGroups,
    required this.oldRowConfigs,
    required this.newRowConfigs,
    required this.presetName,
  });

  final List<ChartGroup> oldGroups;
  final List<ChartGroup> newGroups;
  final List<RowConfig> oldRowConfigs;
  final List<RowConfig> newRowConfigs;
  final String presetName;

  @override
  String get description => '应用预设: $presetName';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(
      chartGroups: newGroups,
      rowConfigs: newRowConfigs,
    );
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(
      chartGroups: oldGroups,
      rowConfigs: oldRowConfigs,
    );
  }
}

/// 替换所有行配置命令
class ReplaceRowConfigsCommand extends EditorCommand {
  ReplaceRowConfigsCommand({
    required this.oldConfigs,
    required this.newConfigs,
  });

  final List<RowConfig> oldConfigs;
  final List<RowConfig> newConfigs;

  @override
  String get description => '重置/替换所有行配置';

  @override
  LayoutTemplate execute(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(rowConfigs: newConfigs);
  }

  @override
  LayoutTemplate undo(LayoutTemplate currentTemplate) {
    return currentTemplate.copyWith(rowConfigs: oldConfigs);
  }
}
