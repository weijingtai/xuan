import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/domain/usecases/layout_templates/delete_template_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_all_templates_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import 'package:common/domain/usecases/layout_templates/save_template_use_case.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/models/layout_template.dart';
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
  });
}
