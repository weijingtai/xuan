import 'package:flutter_test/flutter_test.dart';
import 'package:common/commands/commands.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/models/text_style_config.dart';

void main() {
  group('CommandHistory', () {
    test('初始状态不能撤销和重做', () {
      final history = CommandHistory();

      expect(history.canUndo, isFalse);
      expect(history.canRedo, isFalse);
      expect(history.undoCount, equals(0));
      expect(history.redoCount, equals(0));
    });

    test('执行命令后可以撤销', () {
      final history = CommandHistory();
      final template = _createTestTemplate();

      final command = UpdateTemplateNameCommand(
        oldName: template.name,
        newName: '新名称',
      );

      history.executeCommand(command, template);

      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);
      expect(history.undoCount, equals(1));
    });

    test('撤销后可以重做', () {
      final history = CommandHistory();
      final template = _createTestTemplate();

      final command = UpdateTemplateNameCommand(
        oldName: template.name,
        newName: '新名称',
      );

      final newTemplate = history.executeCommand(command, template);
      final undoneTemplate = history.undo(newTemplate);

      expect(undoneTemplate, isNotNull);
      expect(history.canUndo, isFalse);
      expect(history.canRedo, isTrue);
      expect(history.redoCount, equals(1));
    });

    test('重做后状态恢复', () {
      final history = CommandHistory();
      final template = _createTestTemplate();

      final command = UpdateTemplateNameCommand(
        oldName: template.name,
        newName: '新名称',
      );

      final newTemplate = history.executeCommand(command, template);
      final undoneTemplate = history.undo(newTemplate)!;
      final redoneTemplate = history.redo(undoneTemplate);

      expect(redoneTemplate, isNotNull);
      expect(redoneTemplate!.name, equals('新名称'));
      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);
    });

    test('新操作清空重做栈', () {
      final history = CommandHistory();
      final template = _createTestTemplate();

      final command1 = UpdateTemplateNameCommand(
        oldName: template.name,
        newName: '名称1',
      );
      final command2 = UpdateTemplateNameCommand(
        oldName: '名称1',
        newName: '名称2',
      );

      final template1 = history.executeCommand(command1, template);
      final undoneTemplate = history.undo(template1)!;

      expect(history.canRedo, isTrue);

      // 执行新操作应该清空重做栈
      history.executeCommand(command2, undoneTemplate);

      expect(history.canRedo, isFalse);
      expect(history.redoCount, equals(0));
    });

    test('历史记录限制在maxHistorySize', () {
      final history = CommandHistory(maxHistorySize: 3);
      var template = _createTestTemplate();
      final groupId = template.chartGroups.first.id;

      for (var i = 0; i < 5; i++) {
        template = history.executeCommand(
          ToggleGroupExpandedCommand(groupId: groupId),
          template,
        );
      }

      expect(history.undoCount, equals(3));
    });

    test('清空历史记录', () {
      final history = CommandHistory();
      final template = _createTestTemplate();

      final command = UpdateTemplateNameCommand(
        oldName: template.name,
        newName: '新名称',
      );

      history.executeCommand(command, template);
      expect(history.canUndo, isTrue);

      history.clear();

      expect(history.canUndo, isFalse);
      expect(history.canRedo, isFalse);
      expect(history.undoCount, equals(0));
      expect(history.redoCount, equals(0));
    });
  });

  group('UpdateTemplateNameCommand', () {
    test('执行命令更新模板名称', () {
      final template = _createTestTemplate();
      final command = UpdateTemplateNameCommand(
        oldName: template.name,
        newName: '新名称',
      );

      final result = command.execute(template);

      expect(result.name, equals('新名称'));
    });

    test('撤销命令恢复原名称', () {
      final template = _createTestTemplate();
      final command = UpdateTemplateNameCommand(
        oldName: template.name,
        newName: '新名称',
      );

      final executed = command.execute(template);
      final undone = command.undo(executed);

      expect(undone.name, equals(template.name));
    });

    test('连续重命名命令可以合并', () {
      final command1 = UpdateTemplateNameCommand(
        oldName: '原名称',
        newName: '名称1',
      );
      final command2 = UpdateTemplateNameCommand(
        oldName: '名称1',
        newName: '名称2',
      );

      expect(command1.canMergeWith(command2), isTrue);

      final merged = command1.mergeWith(command2);
      expect(merged, isA<UpdateTemplateNameCommand>());

      final mergedCmd = merged as UpdateTemplateNameCommand;
      expect(mergedCmd.oldName, equals('原名称'));
      expect(mergedCmd.newName, equals('名称2'));
    });
  });

  group('AddPillarToGroupCommand', () {
    test('执行命令添加柱位', () {
      final template = _createTestTemplate();
      final groupId = template.chartGroups.first.id;
      final command = AddPillarToGroupCommand(
        groupId: groupId,
        pillar: PillarType.month,
        index: 0,
      );

      final result = command.execute(template);
      final group = result.chartGroups.first;

      expect(group.pillarOrder.first, equals(PillarType.month));
    });

    test('撤销命令移除添加的柱位', () {
      final template = _createTestTemplate();
      final groupId = template.chartGroups.first.id;
      final command = AddPillarToGroupCommand(
        groupId: groupId,
        pillar: PillarType.month,
        index: 0,
      );

      final executed = command.execute(template);
      final undone = command.undo(executed);
      final group = undone.chartGroups.first;

      expect(group.pillarOrder, isNot(contains(PillarType.month)));
    });
  });

  group('RemovePillarFromGroupCommand', () {
    test('执行命令移除柱位', () {
      final template = _createTestTemplateWithPillars();
      final groupId = template.chartGroups.first.id;
      final command = RemovePillarFromGroupCommand(
        groupId: groupId,
        index: 0,
        removedPillar: PillarType.year,
      );

      final result = command.execute(template);
      final group = result.chartGroups.first;

      expect(group.pillarOrder, isNot(contains(PillarType.year)));
    });

    test('撤销命令恢复移除的柱位', () {
      final template = _createTestTemplateWithPillars();
      final groupId = template.chartGroups.first.id;
      final command = RemovePillarFromGroupCommand(
        groupId: groupId,
        index: 0,
        removedPillar: PillarType.year,
      );

      final executed = command.execute(template);
      final undone = command.undo(executed);
      final group = undone.chartGroups.first;

      expect(group.pillarOrder.first, equals(PillarType.year));
    });
  });

  group('ReorderPillarCommand', () {
    test('执行命令重排柱位', () {
      final template = _createTestTemplateWithPillars();
      final groupId = template.chartGroups.first.id;
      final command = ReorderPillarCommand(
        groupId: groupId,
        oldIndex: 0,
        newIndex: 2,
      );

      final result = command.execute(template);
      final group = result.chartGroups.first;

      // 年柱从位置0移到位置2
      expect(group.pillarOrder[2], equals(PillarType.year));
    });

    test('撤销命令恢复原顺序', () {
      final template = _createTestTemplateWithPillars();
      final groupId = template.chartGroups.first.id;
      final command = ReorderPillarCommand(
        groupId: groupId,
        oldIndex: 0,
        newIndex: 2,
      );

      final executed = command.execute(template);
      final undone = command.undo(executed);
      final group = undone.chartGroups.first;

      expect(group.pillarOrder.first, equals(PillarType.year));
    });
  });

  group('UpdateRowVisibilityCommand', () {
    test('执行命令更新行可见性', () {
      final template = _createTestTemplate();
      final command = UpdateRowVisibilityCommand(
        rowType: RowType.heavenlyStem,
        oldVisibility: true,
        newVisibility: false,
      );

      final result = command.execute(template);
      final config = result.rowConfigs.firstWhere(
        (c) => c.type == RowType.heavenlyStem,
      );

      expect(config.isVisible, isFalse);
    });

    test('撤销命令恢复原可见性', () {
      final template = _createTestTemplate();
      final command = UpdateRowVisibilityCommand(
        rowType: RowType.heavenlyStem,
        oldVisibility: true,
        newVisibility: false,
      );

      final executed = command.execute(template);
      final undone = command.undo(executed);
      final config = undone.rowConfigs.firstWhere(
        (c) => c.type == RowType.heavenlyStem,
      );

      expect(config.isVisible, isTrue);
    });
  });

  group('ToggleGroupExpandedCommand', () {
    test('执行命令切换展开状态', () {
      final template = _createTestTemplate();
      final groupId = template.chartGroups.first.id;
      final originalExpanded = template.chartGroups.first.expanded;

      final command = ToggleGroupExpandedCommand(groupId: groupId);

      final result = command.execute(template);
      final group = result.chartGroups.first;

      expect(group.expanded, equals(!originalExpanded));
    });

    test('撤销命令再次切换状态', () {
      final template = _createTestTemplate();
      final groupId = template.chartGroups.first.id;
      final originalExpanded = template.chartGroups.first.expanded;

      final command = ToggleGroupExpandedCommand(groupId: groupId);

      final executed = command.execute(template);
      final undone = command.undo(executed);
      final group = undone.chartGroups.first;

      expect(group.expanded, equals(originalExpanded));
    });
  });

  group('多步操作测试', () {
    test('连续执行多个命令并全部撤销', () {
      final history = CommandHistory();
      var template = _createTestTemplate();
      final groupId = template.chartGroups.first.id;

      // 操作1: 重命名
      final cmd1 = UpdateTemplateNameCommand(
        oldName: template.name,
        newName: '新名称',
      );
      template = history.executeCommand(cmd1, template);
      expect(template.name, equals('新名称'));

      // 操作2: 添加柱位
      final cmd2 = AddPillarToGroupCommand(
        groupId: groupId,
        pillar: PillarType.month,
        index: 0,
      );
      template = history.executeCommand(cmd2, template);
      expect(template.chartGroups.first.pillarOrder, contains(PillarType.month));

      // 操作3: 切换展开
      final cmd3 = ToggleGroupExpandedCommand(groupId: groupId);
      template = history.executeCommand(cmd3, template);

      expect(history.undoCount, equals(3));

      // 撤销所有操作
      template = history.undo(template)!; // 撤销展开
      template = history.undo(template)!; // 撤销添加柱位
      template = history.undo(template)!; // 撤销重命名

      expect(history.canUndo, isFalse);
      expect(template.name, equals('默认模板'));
      expect(template.chartGroups.first.pillarOrder, isNot(contains(PillarType.month)));
    });
  });
}

// 辅助方法创建测试模板
LayoutTemplate _createTestTemplate() {
  return LayoutTemplate(
    id: 'test-id',
    name: '默认模板',
    collectionId: 'test-collection',
    cardStyle: const CardStyle(
      dividerType: BorderType.solid,
      dividerColorHex: '#FF334155',
      dividerThickness: 1.0,
      globalFontFamily: 'NotoSans',
      globalFontSize: 14,
      globalFontColorHex: '#FF0F172A',
    ),
    chartGroups: [
      ChartGroup(
        id: 'group-1',
        title: '测试分组',
        pillarOrder: const [],
        locked: false,
        expanded: true,
      ),
    ],
    rowConfigs: [
      RowConfig(
        type: RowType.heavenlyStem,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig.defaultConfig,
      ),
      RowConfig(
        type: RowType.earthlyBranch,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig.defaultConfig,
      ),
    ],
    version: 1,
    updatedAt: DateTime.now(),
  );
}

LayoutTemplate _createTestTemplateWithPillars() {
  return LayoutTemplate(
    id: 'test-id',
    name: '默认模板',
    collectionId: 'test-collection',
    cardStyle: const CardStyle(
      dividerType: BorderType.solid,
      dividerColorHex: '#FF334155',
      dividerThickness: 1.0,
      globalFontFamily: 'NotoSans',
      globalFontSize: 14,
      globalFontColorHex: '#FF0F172A',
    ),
    chartGroups: [
      ChartGroup(
        id: 'group-1',
        title: '测试分组',
        pillarOrder: const [
          PillarType.year,
          PillarType.month,
          PillarType.day,
        ],
        locked: false,
        expanded: true,
      ),
    ],
    rowConfigs: [
      RowConfig(
        type: RowType.heavenlyStem,
        isVisible: true,
        isTitleVisible: true,
        textStyleConfig: TextStyleConfig.defaultConfig,
      ),
    ],
    version: 1,
    updatedAt: DateTime.now(),
  );
}
