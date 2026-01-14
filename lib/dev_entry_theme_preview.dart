import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:common/database/app_database.dart';
import 'package:common/viewmodels/four_zhu_editor_view_model.dart';
import 'package:common/repositories/layout_template_repository_impl.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/domain/usecases/layout_templates/get_all_templates_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import 'package:common/domain/usecases/layout_templates/save_template_use_case.dart';
import 'package:common/domain/usecases/layout_templates/delete_template_use_case.dart';
import 'package:common/widgets/editor_sidebar_v2.dart';
import 'package:persistence_core/persistence_core.dart';

void main() {
  runApp(const DevThemePreviewApp());
}

class _FixedScopeProvider implements AuthScopeProvider {
  const _FixedScopeProvider(this._scopeUid);

  final String _scopeUid;

  @override
  Future<String> getScopeUid() async => _scopeUid;
}

class _InMemoryOutboxStore implements OutboxStore {
  final List<OutboxRecord> _backlog = <OutboxRecord>[];
  final Set<String> _dead = <String>{};

  @override
  Future<void> enqueue(OutboxRecord record) async {
    _backlog.add(record);
  }

  @override
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required int limit,
  }) async {
    final batch = _backlog
        .where((r) => r.scopeUid == scopeUid && !_dead.contains(r.operationId))
        .toList(growable: false)
      ..sort((a, b) => a.createdAtUtc.compareTo(b.createdAtUtc));

    if (batch.length <= limit) return batch;
    return batch.sublist(0, limit);
  }

  @override
  Future<void> markSuccess({
    required String operationId,
    required DateTime atUtc,
  }) async {
    _backlog.removeWhere((r) => r.operationId == operationId);
    _dead.remove(operationId);
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
    final index = _backlog.indexWhere((r) => r.operationId == operationId);
    if (index < 0) return;

    final existing = _backlog[index];
    _backlog[index] = existing.copyWith(attempt: attempt);

    if (isDead) {
      _dead.add(operationId);
    }
  }

  @override
  Future<int> backlogCount(String scopeUid) async {
    return _backlog
        .where((r) => r.scopeUid == scopeUid && !_dead.contains(r.operationId))
        .length;
  }

  @override
  Future<int> deadCount(String scopeUid) async {
    return _backlog
        .where((r) => r.scopeUid == scopeUid && _dead.contains(r.operationId))
        .length;
  }
}

class DevThemePreviewApp extends StatelessWidget {
  const DevThemePreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DevThemePreviewPage(),
    );
  }
}

class DevThemePreviewPage extends StatefulWidget {
  const DevThemePreviewPage({super.key});

  @override
  State<DevThemePreviewPage> createState() => _DevThemePreviewPageState();
}

class _DevThemePreviewPageState extends State<DevThemePreviewPage> {
  late final AppDatabase _db;
  late final FourZhuEditorViewModel _viewModel;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();

    _db = AppDatabase(null, false);

    final outboxStore = _InMemoryOutboxStore();
    final authScopeProvider = _FixedScopeProvider('dev_theme_preview');

    final repo = LayoutTemplateRepositoryImpl(
      LayoutTemplateLocalDataSource(_db, outboxStore: outboxStore),
      authScopeProvider: authScopeProvider,
    );

    _viewModel = FourZhuEditorViewModel(
      getAllTemplatesUseCase: GetAllTemplatesUseCase(repo),
      getTemplateByIdUseCase: GetTemplateByIdUseCase(repo),
      saveTemplateUseCase: SaveTemplateUseCase(repo),
      deleteTemplateUseCase: DeleteTemplateUseCase(repo),
    );

    _initFuture = _viewModel.initialize(collectionId: 'default');
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        return ChangeNotifierProvider<FourZhuEditorViewModel>.value(
          value: _viewModel,
          child: Scaffold(
            appBar: AppBar(title: const Text('侧栏：主题编辑与预览（开发入口）')),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const EditorSidebarV2(),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: Center(
                      child: Text(
                        '右侧为占位区。请在左侧栏使用“主题编辑与预览”。',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
