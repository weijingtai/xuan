import 'package:common/database/app_database.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/domain/usecases/layout_templates/delete_template_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_all_templates_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import 'package:common/domain/usecases/layout_templates/save_template_use_case.dart';
import 'package:common/repositories/layout_template_repository_impl.dart';
import 'package:common/viewmodels/four_zhu_editor_view_model.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedScopeProvider implements AuthScopeProvider {
  const _FixedScopeProvider(this._scopeUid);

  final String _scopeUid;

  @override
  Future<String> getScopeUid() async {
    return _scopeUid;
  }
}

class _DiscardingOutboxStore implements OutboxStore {
  @override
  Future<int> backlogCount(String scopeUid) async {
    return 0;
  }

  @override
  Stream<int> watchBacklogCount(String scopeUid) {
    return const Stream<int>.empty();
  }

  @override
  Future<int> deadCount(String scopeUid) async {
    return 0;
  }

  @override
  Future<void> enqueue(OutboxRecord record) async {}

  @override
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required int limit,
  }) async {
    return const [];
  }

  @override
  Future<void> markFailed({
    required String operationId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  }) async {}

  @override
  Future<void> markSuccess({
    required String operationId,
    required DateTime atUtc,
  }) async {}
}

void main() {
  test('AppDatabase seeds public layout templates from assets', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await rootBundle.loadString('assets/templates/default_template.json');
    await rootBundle.loadString(
      'assets/templates/chinese/outbox_payload_ink_minimal.json',
    );
    await rootBundle.loadString(
      'assets/templates/chinese/outbox_payload_vermilion_palace.json',
    );
    await rootBundle.loadString(
      'assets/templates/chinese/outbox_payload_blue_porcelain.json',
    );
    await rootBundle.loadString(
      'assets/templates/chinese/outbox_payload_bamboo_green.json',
    );

    final db = AppDatabase(NativeDatabase.memory(), false);
    try {
      final templates = await db.layoutTemplatesDao.getAllByCollection(
        '__public_default__',
      );

      final names = templates.map((t) => t.name).toList(growable: false);
      expect(names, contains('默认模板'));
      expect(names, contains('中国风·水墨简雅'));
      expect(names, contains('中国风·朱砂宫廷'));
      expect(names, contains('中国风·青花瓷'));
      expect(names, contains('中国风·竹影青'));
    } finally {
      await db.close();
    }
  });

  test('ViewModel bootstraps seeded templates into user collection', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    await rootBundle.loadString('assets/templates/default_template.json');
    await rootBundle.loadString(
      'assets/templates/chinese/outbox_payload_ink_minimal.json',
    );
    await rootBundle.loadString(
      'assets/templates/chinese/outbox_payload_vermilion_palace.json',
    );
    await rootBundle.loadString(
      'assets/templates/chinese/outbox_payload_blue_porcelain.json',
    );
    await rootBundle.loadString(
      'assets/templates/chinese/outbox_payload_bamboo_green.json',
    );

    final db = AppDatabase(NativeDatabase.memory(), false);
    try {
      final outboxStore = _DiscardingOutboxStore();
      final localDataSource = LayoutTemplateLocalDataSource(
        db,
        outboxStore: outboxStore,
      );
      final repository = LayoutTemplateRepositoryImpl(
        localDataSource,
        authScopeProvider: const _FixedScopeProvider('u1'),
      );

      final viewModel = FourZhuEditorViewModel(
        getAllTemplatesUseCase: GetAllTemplatesUseCase(repository),
        getTemplateByIdUseCase: GetTemplateByIdUseCase(repository),
        saveTemplateUseCase: SaveTemplateUseCase(repository),
        deleteTemplateUseCase: DeleteTemplateUseCase(repository),
      );

      await viewModel.initialize(collectionId: 'user');

      final names =
          viewModel.templates.map((t) => t.name).toList(growable: false);
      expect(names, contains('默认模板'));
      expect(names, contains('中国风·水墨简雅'));
      expect(names, contains('中国风·朱砂宫廷'));
      expect(names, contains('中国风·青花瓷'));
      expect(names, contains('中国风·竹影青'));
      expect(viewModel.currentTemplate, isNotNull);
      expect(viewModel.currentTemplate?.collectionId, equals('user'));
    } finally {
      await db.close();
    }
  });
}
