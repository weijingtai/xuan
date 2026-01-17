import 'dart:async';

import 'package:common/database/app_database.dart';
import 'package:common/database/daos/card_template_meta_dao.dart';
import 'package:common/database/daos/card_template_skill_usage_dao.dart';
import 'package:common/database/daos/card_template_setting_dao.dart';
import 'package:common/database/daos/market_template_installs_dao.dart';
import 'package:common/datasource/layout_template_local_data_source.dart';
import 'package:common/domain/usecases/layout_templates/delete_template_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_all_templates_use_case.dart';
import 'package:common/domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import 'package:common/domain/usecases/layout_templates/save_template_use_case.dart';
import 'package:common/features/shared_card_template/market/market_gateway.dart';
import 'package:common/features/shared_card_template/usecase/install_market_template_usecase.dart';
import 'package:common/repositories/layout_template_repository_impl.dart';
import 'package:common/themes/editor_theme.dart';
import 'package:common/widgets/style_editor/sidebar_explorer.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:provider/provider.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/viewmodels/four_zhu_editor_view_model.dart';
import 'package:flutter/material.dart';

import '../widgets/four_zhu_card_editor_page/editor_workspace.dart';

const _defaultCollectionId = 'four_zhu_templates';

class FourZhuEditPage extends StatelessWidget {
  const FourZhuEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LayoutTemplateLocalDataSource>(
          create: (ctx) {
            OutboxStore? outboxStore;
            try {
              outboxStore = ctx.read<OutboxStore>();
            } catch (_) {
              outboxStore = null;
            }

            SyncLogger? logger;
            try {
              logger = ctx.read<SyncLogger>();
            } catch (_) {
              logger = null;
            }

            return LayoutTemplateLocalDataSource(
              ctx.read<AppDatabase>(),
              outboxStore: outboxStore,
              logger: logger,
            );
          },
        ),
        ChangeNotifierProvider<FourZhuEditorViewModel>(
          create: (ctx) {
            final localDataSource = ctx.read<LayoutTemplateLocalDataSource>();
            final repository = LayoutTemplateRepositoryImpl(
              localDataSource,
              authScopeProvider: ctx.read<AuthScopeProvider>(),
            );

            MarketGateway? marketGateway;
            try {
              marketGateway = ctx.read<MarketGateway>();
            } catch (_) {
              marketGateway = null;
            }

            final installMarketTemplateUseCase = marketGateway == null
                ? null
                : InstallMarketTemplateUseCase(
                    marketGateway: marketGateway,
                    localDataSource: localDataSource,
                    marketTemplateInstallsDao:
                        MarketTemplateInstallsDao(ctx.read<AppDatabase>()),
                    authScopeProvider: ctx.read<AuthScopeProvider>(),
                  );

            return FourZhuEditorViewModel(
              getAllTemplatesUseCase: GetAllTemplatesUseCase(repository),
              getTemplateByIdUseCase: GetTemplateByIdUseCase(repository),
              saveTemplateUseCase: SaveTemplateUseCase(repository),
              deleteTemplateUseCase: DeleteTemplateUseCase(repository),
              installMarketTemplateUseCase: installMarketTemplateUseCase,
              cardTemplateMetaDao: CardTemplateMetaDao(ctx.read<AppDatabase>()),
              cardTemplateSettingDao:
                  CardTemplateSettingDao(ctx.read<AppDatabase>()),
              cardTemplateSkillUsageDao:
                  CardTemplateSkillUsageDao(ctx.read<AppDatabase>()),
            )..initialize(collectionId: _defaultCollectionId);
          },
        ),
      ],
      child: const _FourZhuEditView(),
    );
  }
}

class _FourZhuEditView extends StatefulWidget {
  const _FourZhuEditView();

  @override
  State<_FourZhuEditView> createState() => _FourZhuEditViewState();
}

class _FourZhuEditViewState extends State<_FourZhuEditView> {
  StreamSubscription<SyncStatus>? _syncSub;
  StreamSubscription<SyncStatus>? _publicSyncSub;
  DateTime? _lastLayoutPullAtUtc;
  DateTime? _lastPublicLayoutPullAtUtc;

  SyncRuntime? _tryReadSyncRuntime() {
    try {
      return context.read<SyncRuntime>();
    } catch (_) {
      return null;
    }
  }

  PublicSyncRuntime? _tryReadPublicSyncRuntime() {
    try {
      return context.read<PublicSyncRuntime>();
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    final runtime = _tryReadSyncRuntime();
    if (runtime != null) {
      _syncSub = runtime.statusStream.listen((status) {
        if (!mounted) return;
        if (status.lastPullEntityType != 'layout_template') return;
        if (status.lastError != null) return;

        final at = status.lastPullAtUtc;
        if (at == null) return;
        if (_lastLayoutPullAtUtc == at) return;
        _lastLayoutPullAtUtc = at;

        final vm = context.read<FourZhuEditorViewModel>();
        unawaited(vm.refreshTemplates());
      });
    }

    final publicRuntime = _tryReadPublicSyncRuntime();
    if (publicRuntime != null) {
      _publicSyncSub = publicRuntime.runtime.statusStream.listen((status) {
        if (!mounted) return;
        if (status.lastPullEntityType != 'layout_template') return;
        if (status.lastError != null) return;

        final at = status.lastPullAtUtc;
        if (at == null) return;
        if (_lastPublicLayoutPullAtUtc == at) return;
        _lastPublicLayoutPullAtUtc = at;

        final vm = context.read<FourZhuEditorViewModel>();
        unawaited(vm.refreshTemplates());
      });
    }
  }

  @override
  void dispose() {
    unawaited(_syncSub?.cancel());
    unawaited(_publicSyncSub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FourZhuEditorViewModel>(
      builder: (context, viewModel, _) {
        final themeData = viewModel.isDarkMode
            ? EditorTheme.darkTheme
            : EditorTheme.lightTheme;

        return Theme(
          data: themeData,
          child: Scaffold(
              backgroundColor: themeData.scaffoldBackgroundColor,
              appBar: AppBar(
                title: const Text("卡片样式编辑"),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // appBar: EditorTopBar(
              //   nameController: _templateNameController,
              //   onCreateTemplate: () =>
              //       _showCreateTemplateDialog(context, viewModel),
              //   // Legacy gallery removed; action is a no-op now
              //   // onOpenGallery: () {},
              //   onDeleteTemplate: () => _confirmDelete(context, viewModel),
              //   onDuplicateTemplate: viewModel.duplicateCurrentTemplate,
              //   onSaveTemplate: () => _saveWithFeedback(context, viewModel),
              //   onUndoChanges: () => viewModel.revertChanges(),
              //   onNameChanged: viewModel.updateTemplateName,
              // ),
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: themeData.dividerColor.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const SidebarExplorer(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (viewModel.errorMessage != null)
                                _ErrorBanner(
                                  message: viewModel.errorMessage!,
                                  onDismissed: viewModel.clearError,
                                ),
                              if (viewModel.hasUnsavedChanges)
                                const _UnsavedBanner(),
                            ],
                          ),
                        ),
                        Expanded(
                          child: EditorWorkspace(
                            eightChars: EightChars(
                              year: JiaZi.JIA_ZI,
                              month: JiaZi.JIA_ZI,
                              day: JiaZi.JIA_ZI,
                              time: JiaZi.JIA_ZI,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onDismissed,
  });

  final String message;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.error.withValues(alpha: 0.08),
      child: ListTile(
        leading: Icon(
          Icons.warning_amber_rounded,
          color: theme.colorScheme.error,
        ),
        title: Text(message, style: theme.textTheme.bodyMedium),
        trailing: IconButton(
          onPressed: onDismissed,
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }
}

class _UnsavedBanner extends StatelessWidget {
  const _UnsavedBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.1),
      child: const ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('有未保存的更改，按 Ctrl/⌘+S 保存'),
      ),
    );
  }
}
