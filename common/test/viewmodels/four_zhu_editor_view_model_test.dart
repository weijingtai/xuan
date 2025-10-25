import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/domain/usecases/layout_templates/delete_template_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_all_templates_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import 'package:common/domain/usecases/layout_templates/save_template_use_case.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/repositories/layout_template_repository_impl.dart';
import 'package:common/viewmodels/four_zhu_editor_view_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  FourZhuEditorViewModel buildViewModel() {
    final repository = LayoutTemplateRepositoryImpl(
      const LayoutTemplateLocalDataSource(),
    );
    return FourZhuEditorViewModel(
      getAllTemplatesUseCase: GetAllTemplatesUseCase(repository),
      getTemplateByIdUseCase: GetTemplateByIdUseCase(repository),
      saveTemplateUseCase: SaveTemplateUseCase(repository),
      deleteTemplateUseCase: DeleteTemplateUseCase(repository),
    );
  }

  LayoutTemplateRepositoryImpl buildRepository() {
    return LayoutTemplateRepositoryImpl(
      const LayoutTemplateLocalDataSource(),
    );
  }

  const collectionId = 'view-model-tests';

  group('FourZhuEditorViewModel', () {
    test('initialize loads default template when storage empty', () async {
      final viewModel = buildViewModel();

      await viewModel.initialize(collectionId: collectionId);

      expect(viewModel.templates, hasLength(1));
      expect(viewModel.currentTemplate, isNotNull);
      expect(viewModel.currentTemplate?.collectionId, equals(collectionId));
      expect(viewModel.hasUnsavedChanges, isFalse);
    });

    test('updateTemplateName marks template dirty and save persists changes',
        () async {
      final repository = buildRepository();
      final viewModel = FourZhuEditorViewModel(
        getAllTemplatesUseCase: GetAllTemplatesUseCase(repository),
        getTemplateByIdUseCase: GetTemplateByIdUseCase(repository),
        saveTemplateUseCase: SaveTemplateUseCase(repository),
        deleteTemplateUseCase: DeleteTemplateUseCase(repository),
      );

      await viewModel.initialize(collectionId: collectionId);
      final originalTemplate = viewModel.currentTemplate!;

      viewModel.updateTemplateName('Brand New Layout');
      expect(viewModel.currentTemplate?.name, equals('Brand New Layout'));
      expect(viewModel.hasUnsavedChanges, isTrue);

      await viewModel.saveCurrentTemplate();

      expect(viewModel.hasUnsavedChanges, isFalse);
      final stored = await repository.getAllTemplates(collectionId);
      expect(stored.first.name, equals('Brand New Layout'));
      expect(stored.first.version, greaterThan(originalTemplate.version));
    });

    test('duplicateCurrentTemplate creates a copy with unique id', () async {
      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);

      final originalId = viewModel.currentTemplate!.id;
      final originalCount = viewModel.templates.length;

      await viewModel.duplicateCurrentTemplate();

      expect(viewModel.templates.length, originalCount + 1);
      final ids = viewModel.templates.map((template) => template.id).toSet();
      expect(ids.length, viewModel.templates.length);
      expect(viewModel.currentTemplate?.id, isNot(equals(originalId)));
    });

    test('deleteCurrentTemplate removes template and keeps fallback available',
        () async {
      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);
      await viewModel.duplicateCurrentTemplate();
      final initialCount = viewModel.templates.length;

      await viewModel.deleteCurrentTemplate();

      expect(viewModel.templates.length, equals(initialCount - 1));
      expect(viewModel.currentTemplate, isNotNull);
    });

    test('updateRowVisibility mutates current template configuration',
        () async {
      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);
      final targetRow = viewModel.rowConfigs.first.type;

      viewModel.updateRowVisibility(targetRow, false);

      expect(
        viewModel.currentTemplate?.rowConfigs
            .firstWhere((config) => config.type == targetRow)
            .isVisible,
        isFalse,
      );
      expect(viewModel.hasUnsavedChanges, isTrue);
    });
    test('revertChanges discards unsaved modifications', () async {
      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);
      final originalName = viewModel.currentTemplate!.name;

      viewModel.updateTemplateName('Temporary Name');
      expect(viewModel.hasUnsavedChanges, isTrue);

      await viewModel.revertChanges();

      expect(viewModel.currentTemplate?.name, equals(originalName));
      expect(viewModel.hasUnsavedChanges, isFalse);
    });

    test('selectTemplateByOffset navigates between templates', () async {
      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);
      await viewModel.duplicateCurrentTemplate();
      final templateIds =
          viewModel.templates.map((template) => template.id).toList();
      expect(templateIds.length, greaterThan(1));

      await viewModel.selectTemplate(templateIds.first);
      await viewModel.selectTemplateByOffset(1);
      final forwardId = viewModel.currentTemplate?.id;
      expect(forwardId, isNotNull);
      expect(forwardId, isNot(equals(templateIds.first)));
      expect(templateIds, contains(forwardId));

      await viewModel.selectTemplate(templateIds.last);
      await viewModel.selectTemplateByOffset(-1);
      final backwardId = viewModel.currentTemplate?.id;
      expect(backwardId, isNotNull);
      expect(backwardId, isNot(equals(templateIds.last)));
      expect(templateIds, contains(backwardId));
    });

    test('toggleTheme updates state and persists preference', () async {
      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);

      viewModel.toggleTheme(true);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.isDarkMode, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('four_zhu_editor:dark_mode'), isTrue);
    });

    test('uiState reflects current flags', () async {
      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);
      viewModel.updateTemplateName('Temporary Name?');

      final state = viewModel.uiState;
      expect(state.hasUnsavedChanges, isTrue);
      expect(state.canSave, isTrue);
      expect(state.canRevert, isTrue);
      expect(state.isDarkMode, isFalse);
    });

    test('updateSearchKeyword filters templates', () async {
      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);
      viewModel.updateTemplateName('Alpha Layout');
      await viewModel.saveCurrentTemplate();
      await viewModel.createTemplate(name: 'Beta Layout');

      viewModel.updateSearchKeyword('beta');

      expect(viewModel.filteredTemplates, hasLength(1));
      expect(viewModel.filteredTemplates.first.name, 'Beta Layout');
    });

    test('favorites category only returns starred templates', () async {
      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);
      await viewModel.createTemplate(name: 'Gamma Layout');
      final targetId = viewModel.templates.last.id;

      viewModel.toggleFavorite(targetId);
      viewModel.updateGalleryCategory(TemplateGalleryCategory.favorites);

      expect(viewModel.filteredTemplates, hasLength(1));
      expect(viewModel.filteredTemplates.first.id, targetId);

      viewModel.updateGalleryCategory(TemplateGalleryCategory.all);
    });

    test('updateSortOrder sorts templates by name', () async {
      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);
      viewModel.updateTemplateName('Bravo Layout');
      await viewModel.saveCurrentTemplate();
      await viewModel.createTemplate(name: 'Alpha Layout');

      viewModel.updateSortOrder(TemplateSortOrder.nameAsc);

      expect(viewModel.filteredTemplates.first.name, 'Alpha Layout');
    });

    test('initialize respects stored theme preference', () async {
      SharedPreferences.setMockInitialValues({
        'four_zhu_editor:dark_mode': true,
      });
      final viewModel = buildViewModel();

      await viewModel.initialize(collectionId: collectionId);

      expect(viewModel.isDarkMode, isTrue);
    });

    group('Group Management Tests (M3.3)', () {
      test('setGroupTitle updates group name and marks template dirty',
          () async {
        final viewModel = buildViewModel();
        await viewModel.initialize(collectionId: collectionId);

        final groupId = viewModel.chartGroups.first.id;
        final originalTitle = viewModel.chartGroups.first.title;

        viewModel.setGroupTitle(groupId: groupId, title: '自定义分组名称');

        expect(viewModel.hasUnsavedChanges, isTrue);
        final updatedGroup =
            viewModel.chartGroups.firstWhere((g) => g.id == groupId);
        expect(updatedGroup.title, equals('自定义分组名称'));
        expect(updatedGroup.title, isNot(equals(originalTitle)));
      });

      test('setGroupTitle ignores empty or whitespace-only names', () async {
        final viewModel = buildViewModel();
        await viewModel.initialize(collectionId: collectionId);

        final groupId = viewModel.chartGroups.first.id;
        final originalTitle = viewModel.chartGroups.first.title;

        viewModel.setGroupTitle(groupId: groupId, title: '   ');

        final group = viewModel.chartGroups.firstWhere((g) => g.id == groupId);
        expect(group.title, equals(originalTitle)); // 应该保持不变
      });

      test('duplicateGroup creates a copy with unique id and "(副本)" suffix',
          () async {
        final viewModel = buildViewModel();
        await viewModel.initialize(collectionId: collectionId);

        // 清空默认分组的柱位
        final defaultGroupId = viewModel.chartGroups.first.id;
        viewModel.clearGroup(groupId: defaultGroupId);

        // 添加一些柱位以便测试复制
        viewModel.addPillarToGroup(
            groupId: defaultGroupId, pillar: PillarType.year);
        viewModel.addPillarToGroup(
            groupId: defaultGroupId, pillar: PillarType.month);

        final originalGroupCount = viewModel.chartGroups.length;

        viewModel.duplicateGroup(groupId: defaultGroupId);

        expect(viewModel.chartGroups.length, equals(originalGroupCount + 1));
        expect(viewModel.hasUnsavedChanges, isTrue);

        // 查找复制的分组（应该在原分组后面）
        final originalIndex =
            viewModel.chartGroups.indexWhere((g) => g.id == defaultGroupId);
        final duplicatedGroup = viewModel.chartGroups[originalIndex + 1];

        expect(duplicatedGroup.id, isNot(equals(defaultGroupId)));
        expect(duplicatedGroup.title, contains('副本'));
        expect(duplicatedGroup.pillarOrder.length, equals(2));
        expect(duplicatedGroup.pillarOrder.first, equals(PillarType.year));
        expect(viewModel.selectedGroupId, equals(duplicatedGroup.id));
      });

      test('duplicateGroup handles multiple duplications with unique names',
          () async {
        final viewModel = buildViewModel();
        await viewModel.initialize(collectionId: collectionId);

        final groupId = viewModel.chartGroups.first.id;
        final originalTitle = viewModel.chartGroups.first.title;

        // 第一次复制
        viewModel.duplicateGroup(groupId: groupId);
        expect(viewModel.chartGroups.length, 2);
        final firstCopyTitle = viewModel.chartGroups[1].title;
        expect(firstCopyTitle, equals('$originalTitle (副本)'));

        // 第二次复制原始分组（会插入到原始分组后面，即索引1）
        viewModel.duplicateGroup(groupId: groupId);
        expect(viewModel.chartGroups.length, 3);
        // 第二次复制被插入到索引1，第一次复制被推到索引2
        final secondCopyTitle = viewModel.chartGroups[1].title;

        final titles = viewModel.chartGroups.map((g) => g.title).toList();
        final uniqueTitles = titles.toSet();
        expect(uniqueTitles.length,
            equals(viewModel.chartGroups.length)); // 所有标题应该唯一
        expect(secondCopyTitle, equals('$originalTitle (副本 2)'));
        expect(viewModel.chartGroups[2].title, equals('$originalTitle (副本)'));
      });

      test('toggleGroupExpanded flips expanded state', () async {
        final viewModel = buildViewModel();
        await viewModel.initialize(collectionId: collectionId);

        final groupId = viewModel.chartGroups.first.id;
        final originalExpanded = viewModel.chartGroups.first.expanded;

        viewModel.toggleGroupExpanded(groupId: groupId);

        expect(viewModel.hasUnsavedChanges, isTrue);
        final group = viewModel.chartGroups.firstWhere((g) => g.id == groupId);
        expect(group.expanded, equals(!originalExpanded));

        // 再切换一次应该恢复原状态
        viewModel.toggleGroupExpanded(groupId: groupId);
        final groupAfterSecondToggle =
            viewModel.chartGroups.firstWhere((g) => g.id == groupId);
        expect(groupAfterSecondToggle.expanded, equals(originalExpanded));
      });

      test('movePillarBetweenGroups moves pillar from source to target group',
          () async {
        final viewModel = buildViewModel();
        await viewModel.initialize(collectionId: collectionId);

        // 创建两个分组
        viewModel.addGroup(title: '源分组');
        final sourceGroupId = viewModel.chartGroups.last.id;
        viewModel.addGroup(title: '目标分组');
        final targetGroupId = viewModel.chartGroups.last.id;

        // 在源分组添加柱位
        viewModel.addPillarToGroup(
            groupId: sourceGroupId, pillar: PillarType.year);
        viewModel.addPillarToGroup(
            groupId: sourceGroupId, pillar: PillarType.month);
        viewModel.addPillarToGroup(
            groupId: sourceGroupId, pillar: PillarType.day);

        final sourceGroup =
            viewModel.chartGroups.firstWhere((g) => g.id == sourceGroupId);
        expect(sourceGroup.pillarOrder.length, equals(3));

        // 移动第二个柱位（月柱）到目标分组
        viewModel.movePillarBetweenGroups(
          sourceGroupId: sourceGroupId,
          sourceIndex: 1,
          targetGroupId: targetGroupId,
          targetIndex: 0,
        );

        final updatedSourceGroup =
            viewModel.chartGroups.firstWhere((g) => g.id == sourceGroupId);
        final updatedTargetGroup =
            viewModel.chartGroups.firstWhere((g) => g.id == targetGroupId);

        expect(updatedSourceGroup.pillarOrder.length, equals(2));
        expect(updatedSourceGroup.pillarOrder, contains(PillarType.year));
        expect(updatedSourceGroup.pillarOrder, contains(PillarType.day));
        expect(updatedSourceGroup.pillarOrder, isNot(contains(PillarType.month)));

        expect(updatedTargetGroup.pillarOrder.length, equals(1));
        expect(updatedTargetGroup.pillarOrder.first, equals(PillarType.month));
        expect(viewModel.hasUnsavedChanges, isTrue);
      });

      test('movePillarBetweenGroups handles duplicate pillars in target group',
          () async {
        final viewModel = buildViewModel();
        await viewModel.initialize(collectionId: collectionId);

        viewModel.addGroup(title: '源分组');
        final sourceGroupId = viewModel.chartGroups.last.id;
        viewModel.addGroup(title: '目标分组');
        final targetGroupId = viewModel.chartGroups.last.id;

        // 两个分组都添加年柱
        viewModel.addPillarToGroup(
            groupId: sourceGroupId, pillar: PillarType.year);
        viewModel.addPillarToGroup(
            groupId: targetGroupId, pillar: PillarType.year);

        // 尝试移动年柱到目标分组（已存在）
        viewModel.movePillarBetweenGroups(
          sourceGroupId: sourceGroupId,
          sourceIndex: 0,
          targetGroupId: targetGroupId,
          targetIndex: 0,
        );

        final sourceGroup =
            viewModel.chartGroups.firstWhere((g) => g.id == sourceGroupId);
        final targetGroup =
            viewModel.chartGroups.firstWhere((g) => g.id == targetGroupId);

        // 源分组应该移除年柱
        expect(sourceGroup.pillarOrder.isEmpty, isTrue);
        // 目标分组应该仍然只有一个年柱（去重）
        expect(targetGroup.pillarOrder.length, equals(1));
        expect(targetGroup.pillarOrder.first, equals(PillarType.year));
      });

      test('movePillarBetweenGroups uses reorderPillar when same group',
          () async {
        final viewModel = buildViewModel();
        await viewModel.initialize(collectionId: collectionId);

        final groupId = viewModel.chartGroups.first.id;
        // 清空默认柱位
        viewModel.clearGroup(groupId: groupId);

        viewModel.addPillarToGroup(groupId: groupId, pillar: PillarType.year);
        viewModel.addPillarToGroup(groupId: groupId, pillar: PillarType.month);
        viewModel.addPillarToGroup(groupId: groupId, pillar: PillarType.day);

        // 在同一分组内移动（从索引1移到索引0）
        viewModel.movePillarBetweenGroups(
          sourceGroupId: groupId,
          sourceIndex: 1,
          targetGroupId: groupId,
          targetIndex: 0,
        );

        final group = viewModel.chartGroups.firstWhere((g) => g.id == groupId);
        expect(group.pillarOrder.length, equals(3));
        expect(group.pillarOrder.first, equals(PillarType.month));
        expect(group.pillarOrder[1], equals(PillarType.year));
        expect(group.pillarOrder[2], equals(PillarType.day));
      });

      test('movePillarBetweenGroups validates source index bounds', () async {
        final viewModel = buildViewModel();
        await viewModel.initialize(collectionId: collectionId);

        viewModel.addGroup(title: '源分组');
        final sourceGroupId = viewModel.chartGroups.last.id;
        viewModel.addGroup(title: '目标分组');
        final targetGroupId = viewModel.chartGroups.last.id;

        viewModel.addPillarToGroup(
            groupId: sourceGroupId, pillar: PillarType.year);

        // 尝试使用无效索引（超出范围）
        viewModel.movePillarBetweenGroups(
          sourceGroupId: sourceGroupId,
          sourceIndex: 99, // 无效索引
          targetGroupId: targetGroupId,
          targetIndex: 0,
        );

        final sourceGroup =
            viewModel.chartGroups.firstWhere((g) => g.id == sourceGroupId);
        final targetGroup =
            viewModel.chartGroups.firstWhere((g) => g.id == targetGroupId);

        // 应该没有任何变化
        expect(sourceGroup.pillarOrder.length, equals(1));
        expect(targetGroup.pillarOrder.isEmpty, isTrue);
      });
    });
  });
}
