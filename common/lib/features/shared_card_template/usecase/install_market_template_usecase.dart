import 'package:persistence_core/persistence_core.dart';
import 'package:uuid/uuid.dart';

import '../../../database/daos/market_template_installs_dao.dart';
import '../../../datasource/layout_template_local_data_source.dart';
import '../../../features/shared_card_template/market/market_gateway.dart';
import '../../../models/layout_template.dart';

class InstallMarketTemplateUseCase {
  InstallMarketTemplateUseCase({
    required MarketGateway marketGateway,
    required LayoutTemplateLocalDataSource localDataSource,
    required MarketTemplateInstallsDao marketTemplateInstallsDao,
    required AuthScopeProvider authScopeProvider,
    bool enqueueOutbox = true,
    Uuid? uuid,
    DateTime Function()? now,
  })  : _marketGateway = marketGateway,
        _localDataSource = localDataSource,
        _marketTemplateInstallsDao = marketTemplateInstallsDao,
        _authScopeProvider = authScopeProvider,
        _enqueueOutbox = enqueueOutbox,
        _uuid = uuid ?? const Uuid(),
        _now = now ?? DateTime.now;

  final MarketGateway _marketGateway;
  final LayoutTemplateLocalDataSource _localDataSource;
  final MarketTemplateInstallsDao _marketTemplateInstallsDao;
  final AuthScopeProvider _authScopeProvider;
  final bool _enqueueOutbox;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<LayoutTemplate> call({
    required String collectionId,
    required String marketTemplateId,
    required String marketVersionId,
    String? nameOverride,
  }) async {
    final payload = await _marketGateway.getTemplatePayload(
      templateId: marketTemplateId,
      versionId: marketVersionId,
    );

    final now = _now();
    final localTemplateUuid = _uuid.v4();

    final base = payload.layoutTemplate.toDomain();
    final installed = base.copyWith(
      id: localTemplateUuid,
      collectionId: collectionId,
      name: (nameOverride == null || nameOverride.trim().isEmpty)
          ? base.name
          : nameOverride.trim(),
      updatedAt: now,
      version: 1,
    );

    final scopeUid =
        _enqueueOutbox ? await _authScopeProvider.getScopeUid() : null;

    await _localDataSource.upsertTemplate(
      installed,
      enqueueOutbox: _enqueueOutbox,
      scopeUid: scopeUid,
      isCustomized: false,
    );

    await _marketTemplateInstallsDao.upsertInstall(
      localTemplateUuid: localTemplateUuid,
      marketTemplateId: marketTemplateId,
      marketVersionId: marketVersionId,
      installedAt: now,
      lastCheckedAt: now,
    );

    return installed;
  }
}
