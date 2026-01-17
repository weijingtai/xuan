import 'dart:async';

import 'package:common/models/text_style_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistence_core/persistence_core.dart';

import 'package:common/database/app_database.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/database/daos/card_template_setting_dao.dart';
import 'package:common/database/daos/market_template_installs_dao.dart';
import 'package:common/domain/usecases/layout_templates/delete_template_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_all_templates_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import 'package:common/domain/usecases/layout_templates/save_template_use_case.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/features/shared_card_template/market/market_dtos.dart';
import 'package:common/features/shared_card_template/market/market_gateway.dart';
import 'package:common/features/shared_card_template/usecase/install_market_template_usecase.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/models/layout_template_dto.dart';
import 'package:common/repositories/layout_template_repository_impl.dart';
import 'package:common/viewmodels/four_zhu_editor_view_model.dart';

class _FakeMarketGateway implements MarketGateway {
  _FakeMarketGateway(this._payload);

  final MarketTemplatePayloadDto _payload;

  @override
  Future<MarketTemplatesPageDto> listTemplates({
    String? cursor,
    int limit = 20,
    String? query,
    List<String>? tags,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MarketTemplateDetailDto> getTemplateDetail({
    required String templateId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MarketTemplatePayloadDto> getTemplatePayload({
    required String templateId,
    required String versionId,
  }) async {
    return _payload;
  }

  @override
  Future<MarketTemplateDetailDto> publishTemplate({
    required PublishMarketTemplateRequestDto request,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  late AppDatabase db;
  late LayoutTemplateLocalDataSource localDataSource;
  late LayoutTemplateRepositoryImpl repository;
  late OutboxStore outboxStore;

  const collectionId = 'view-model-tests';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory(), false);
    outboxStore = _InMemoryOutboxStore();
    localDataSource =
        LayoutTemplateLocalDataSource(db, outboxStore: outboxStore);
    repository = LayoutTemplateRepositoryImpl(
      localDataSource,
      authScopeProvider: _FixedScopeProvider('test_app_user_id'),
    );

    await localDataSource.upsertTemplate(
      LayoutTemplate(
        id: 'seed-1',
        name: 'Seed Layout',
        collectionId: collectionId,
        cardStyle: const CardStyle(
          dividerType: BorderType.none,
          dividerColorHex: '#DD000000',
          dividerThickness: 1.0,
          globalFontFamily: 'NotoSansSC-Regular',
          globalFontSize: 14,
          globalFontColorHex: '#FF0F172A',
          contentPadding: EdgeInsets.all(16.0),
        ),
        chartGroups: [
          ChartGroup(
            id: 'seed-group-1',
            title: '流年盘',
            pillarOrder: const [
              PillarType.rowTitleColumn,
              PillarType.year,
              PillarType.month,
              PillarType.day,
              PillarType.hour,
            ],
          ),
        ],
        rowConfigs: [
          RowConfig(
            type: RowType.columnHeaderRow,
            isVisible: true,
            isTitleVisible: false,
            textStyleConfig: TextStyleConfig.defaultConfig,
          ),
          RowConfig(
            type: RowType.tenGod,
            isVisible: true,
            isTitleVisible: true,
            textStyleConfig: TextStyleConfig.defaultTenGodsConfig,
          ),
          RowConfig(
            type: RowType.heavenlyStem,
            isVisible: true,
            isTitleVisible: true,
            textStyleConfig: TextStyleConfig.defaultGanConfig,
          ),
          RowConfig(
            type: RowType.earthlyBranch,
            isVisible: true,
            isTitleVisible: true,
            textStyleConfig: TextStyleConfig.defaultZhiConfig,
          ),
          RowConfig(
            type: RowType.xunShou,
            isVisible: true,
            isTitleVisible: true,
            textStyleConfig: TextStyleConfig.defaultConfig,
          ),
          RowConfig(
            type: RowType.kongWang,
            isVisible: true,
            isTitleVisible: true,
            textStyleConfig: TextStyleConfig.defaultConfig,
          ),
          RowConfig(
            type: RowType.naYin,
            isVisible: true,
            isTitleVisible: true,
            textStyleConfig: TextStyleConfig.defaultConfig,
          ),
          RowConfig(
            type: RowType.hiddenStems,
            isVisible: true,
            isTitleVisible: true,
            textStyleConfig: TextStyleConfig.defaultConfig,
          ),
        ],
        version: 1,
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
      enqueueOutbox: false,
    );
  });

  tearDown(() async {
    await db.close();
  });

  FourZhuEditorViewModel buildViewModel() {
    return FourZhuEditorViewModel(
      getAllTemplatesUseCase: GetAllTemplatesUseCase(repository),
      getTemplateByIdUseCase: GetTemplateByIdUseCase(repository),
      saveTemplateUseCase: SaveTemplateUseCase(repository),
      deleteTemplateUseCase: DeleteTemplateUseCase(repository),
      cardTemplateSettingDao: CardTemplateSettingDao(db),
    );
  }

  group('FourZhuEditorViewModel', () {
    test('initialize imports public templates when user storage empty',
        () async {
      await localDataSource.removeCollection(collectionId);

      await localDataSource.upsertTemplate(
        LayoutTemplate(
          id: 'public-1',
          name: '公共模板A',
          collectionId: '__public_default__',
          cardStyle: const CardStyle(
            dividerType: BorderType.none,
            dividerColorHex: '#DD000000',
            dividerThickness: 1.0,
            globalFontFamily: 'NotoSansSC-Regular',
            globalFontSize: 14,
            globalFontColorHex: '#FF0F172A',
            contentPadding: EdgeInsets.all(16.0),
          ),
          chartGroups: [
            ChartGroup(
              id: 'public-group-1',
              title: '流年盘',
              pillarOrder: const [
                PillarType.rowTitleColumn,
                PillarType.year,
                PillarType.month,
                PillarType.day,
                PillarType.hour,
              ],
            ),
          ],
          rowConfigs: [
            RowConfig(
              type: RowType.columnHeaderRow,
              isVisible: true,
              isTitleVisible: false,
              textStyleConfig: TextStyleConfig.defaultConfig,
            ),
          ],
          version: 1,
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        enqueueOutbox: false,
      );

      final viewModel = buildViewModel();

      await viewModel.initialize(collectionId: collectionId);

      expect(viewModel.templates, hasLength(1));
      expect(viewModel.currentTemplate, isNotNull);
      expect(viewModel.currentTemplate?.collectionId, equals(collectionId));
      expect(viewModel.currentTemplate?.name, equals('公共模板A'));
      expect(viewModel.hasUnsavedChanges, isFalse);
      expect(viewModel.isLoading, isFalse);
    });

    test('initialize keeps card padding consistent with template', () async {
      final viewModel = buildViewModel();

      await viewModel.initialize(collectionId: collectionId);

      final template = viewModel.currentTemplate;
      expect(template, isNotNull);
      expect(
          viewModel.paddingNotifier.value, template!.cardStyle.contentPadding);
      expect(viewModel.paddingNotifier.value, const EdgeInsets.all(16.0));
    });

    test('installMarketTemplate installs template and refreshes list',
        () async {
      final installsDao = MarketTemplateInstallsDao(db);
      final now = DateTime.utc(2026, 1, 15, 12, 0, 0);

      final remoteTemplate = LayoutTemplate(
        id: 'remote-template-uuid',
        name: 'Market Theme',
        description: 'From market',
        collectionId: 'remote-collection',
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
            title: '基础分组',
            pillarOrder: [PillarType.year, PillarType.month],
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
        updatedAt: DateTime.utc(2024, 1, 1),
        version: 1,
      );

      final payload = MarketTemplatePayloadDto(
        schemaVersion: 1,
        templateId: 'mkt-1',
        versionId: 'ver-1',
        layoutTemplate: LayoutTemplateDto.fromDomain(remoteTemplate),
      );

      const scopeUid = 'test_app_user_id';

      final installUseCase = InstallMarketTemplateUseCase(
        marketGateway: _FakeMarketGateway(payload),
        localDataSource: localDataSource,
        marketTemplateInstallsDao: installsDao,
        authScopeProvider: _FixedScopeProvider(scopeUid),
        now: () => now,
      );

      final viewModel = FourZhuEditorViewModel(
        getAllTemplatesUseCase: GetAllTemplatesUseCase(repository),
        getTemplateByIdUseCase: GetTemplateByIdUseCase(repository),
        saveTemplateUseCase: SaveTemplateUseCase(repository),
        deleteTemplateUseCase: DeleteTemplateUseCase(repository),
        installMarketTemplateUseCase: installUseCase,
        cardTemplateSettingDao: CardTemplateSettingDao(db),
      );

      await viewModel.initialize(collectionId: collectionId);
      expect(viewModel.templates, hasLength(1));

      await viewModel.installMarketTemplate(
        marketTemplateId: 'mkt-1',
        marketVersionId: 'ver-1',
      );

      expect(viewModel.templates, hasLength(2));
      final installed =
          viewModel.templates.firstWhere((t) => t.name == 'Market Theme');
      expect(installed.collectionId, equals(collectionId));

      final mapping =
          await installsDao.findByLocalTemplateUuid(installed.id);
      expect(mapping, isNotNull);
      expect(mapping!.marketTemplateId, equals('mkt-1'));
      expect(mapping.marketVersionId, equals('ver-1'));

      final batch = await outboxStore.peekBatch(scopeUid: scopeUid, limit: 10);
      expect(batch, hasLength(1));
      expect(batch.single.entityType, equals('layout_template'));
      expect(batch.single.entityId, equals(installed.id));
      expect(batch.single.opType, equals('upsert'));
    });

    test('CardStyle.fromJson defaults contentPadding to 16 when missing',
        () async {
      final style = CardStyle.fromJson(const <String, dynamic>{});
      expect(style.contentPadding, const EdgeInsets.all(16.0));
    });

    test('resetTemplatesToDefault clears user templates and re-imports public',
        () async {
      await localDataSource.upsertTemplate(
        LayoutTemplate(
          id: 'public-1',
          name: '公共模板A',
          collectionId: '__public_default__',
          cardStyle: const CardStyle(
            dividerType: BorderType.none,
            dividerColorHex: '#DD000000',
            dividerThickness: 1.0,
            globalFontFamily: 'NotoSansSC-Regular',
            globalFontSize: 14,
            globalFontColorHex: '#FF0F172A',
            contentPadding: EdgeInsets.all(16.0),
          ),
          chartGroups: [
            ChartGroup(
              id: 'public-group-1',
              title: '流年盘',
              pillarOrder: const [
                PillarType.rowTitleColumn,
                PillarType.year,
                PillarType.month,
                PillarType.day,
                PillarType.hour,
              ],
            ),
          ],
          rowConfigs: [
            RowConfig(
              type: RowType.columnHeaderRow,
              isVisible: true,
              isTitleVisible: false,
              textStyleConfig: TextStyleConfig.defaultConfig,
            ),
          ],
          version: 1,
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        enqueueOutbox: false,
      );

      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);

      viewModel.updateCardContentInsets(EdgeInsets.zero);
      await viewModel.saveCurrentTemplate();
      expect(viewModel.currentTemplate?.cardStyle.contentPadding,
          equals(EdgeInsets.zero));

      await viewModel.resetTemplatesToDefault();

      expect(viewModel.templates, hasLength(1));
      expect(viewModel.currentTemplate, isNotNull);
      expect(viewModel.currentTemplate?.name, equals('公共模板A'));
      expect(viewModel.currentTemplate?.cardStyle.contentPadding,
          const EdgeInsets.all(16.0));
      expect(viewModel.paddingNotifier.value, const EdgeInsets.all(16.0));
    });

    test('updateTemplateName marks template dirty and save persists changes',
        () async {
      final viewModel = FourZhuEditorViewModel(
        getAllTemplatesUseCase: GetAllTemplatesUseCase(repository),
        getTemplateByIdUseCase: GetTemplateByIdUseCase(repository),
        saveTemplateUseCase: SaveTemplateUseCase(repository),
        deleteTemplateUseCase: DeleteTemplateUseCase(repository),
        cardTemplateSettingDao: CardTemplateSettingDao(db),
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

    test('undo/redo supports divider style updates', () async {
      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);

      final originalType = viewModel.currentTemplate!.cardStyle.dividerType;
      viewModel.updateDividerType(BorderType.dashed);

      expect(viewModel.currentTemplate!.cardStyle.dividerType,
          equals(BorderType.dashed));
      expect(viewModel.canUndo, isTrue);

      viewModel.undoLastChange();
      expect(viewModel.currentTemplate!.cardStyle.dividerType,
          equals(originalType));
      expect(viewModel.canRedo, isTrue);

      viewModel.redoLastChange();
      expect(viewModel.currentTemplate!.cardStyle.dividerType,
          equals(BorderType.dashed));
    });

    test('undo reverts reorderRowsByTypes', () async {
      final viewModel = buildViewModel();
      await viewModel.initialize(collectionId: collectionId);

      final original = viewModel.currentTemplate!.rowConfigs
          .map((e) => e.type)
          .toList(growable: false);
      final reordered = original.reversed.toList(growable: false);

      viewModel.reorderRowsByTypes(reordered);
      expect(viewModel.currentTemplate!.rowConfigs.map((e) => e.type).toList(),
          equals(reordered));
      expect(viewModel.canUndo, isTrue);

      viewModel.undoLastChange();
      expect(viewModel.currentTemplate!.rowConfigs.map((e) => e.type).toList(),
          equals(original));
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
        expect(
            updatedSourceGroup.pillarOrder, isNot(contains(PillarType.month)));

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

class _FixedScopeProvider implements AuthScopeProvider {
  _FixedScopeProvider(this._scopeUid);

  final String _scopeUid;

  @override
  Future<String> getScopeUid() async {
    return _scopeUid;
  }
}

class _InMemoryOutboxStore implements OutboxStore {
  final List<OutboxRecord> _records = [];
  final Map<String, StreamController<int>> _backlogControllersByScopeUid =
      <String, StreamController<int>>{};

  StreamController<int> _controllerFor(String scopeUid) {
    return _backlogControllersByScopeUid.putIfAbsent(
      scopeUid,
      () => StreamController<int>.broadcast(),
    );
  }

  Future<void> _emitBacklog(String scopeUid) async {
    if (!_backlogControllersByScopeUid.containsKey(scopeUid)) return;
    _controllerFor(scopeUid).add(await backlogCount(scopeUid));
  }

  @override
  Future<void> enqueue(OutboxRecord record) async {
    _records.add(record);
    await _emitBacklog(record.scopeUid);
  }

  @override
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required int limit,
  }) async {
    return _records.where((r) => r.scopeUid == scopeUid).take(limit).toList();
  }

  @override
  Future<void> markSuccess({
    required String operationId,
    required DateTime atUtc,
  }) async {
    final removed =
        _records.where((r) => r.operationId == operationId).toList();
    _records.removeWhere((r) => r.operationId == operationId);
    if (removed.isNotEmpty) await _emitBacklog(removed.first.scopeUid);
  }

  @override
  Future<void> markFailed({
    required String operationId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  }) async {
    final index = _records.indexWhere((r) => r.operationId == operationId);
    if (index < 0) return;
    final existing = _records[index];
    _records[index] = existing.copyWith(
      attempt: attempt,
    );
    await _emitBacklog(existing.scopeUid);
  }

  @override
  Future<int> backlogCount(String scopeUid) async {
    return _records.where((r) => r.scopeUid == scopeUid).length;
  }

  @override
  Stream<int> watchBacklogCount(String scopeUid) {
    return (() async* {
      yield await backlogCount(scopeUid);
      yield* _controllerFor(scopeUid).stream;
    })()
        .distinct();
  }

  @override
  Future<int> deadCount(String scopeUid) async {
    return 0;
  }
}
