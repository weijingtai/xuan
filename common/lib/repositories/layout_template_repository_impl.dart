import 'package:collection/collection.dart';
import 'package:persistence_core/persistence_core.dart';

import '../datasource/layout_template_local_data_source.dart';
import '../models/layout_template.dart';
import '../models/layout_template_dto.dart';
import 'layout_template_repository.dart';

class LayoutTemplateRepositoryImpl implements LayoutTemplateRepository {
  LayoutTemplateRepositoryImpl(
    this._localDataSource, {
    required AuthScopeProvider authScopeProvider,
  }) : _authScopeProvider = authScopeProvider;

  final LayoutTemplateLocalDataSource _localDataSource;
  final AuthScopeProvider _authScopeProvider;

  @override
  Future<List<LayoutTemplate>> getAllTemplates(String collectionId) async {
    final dtos = await _localDataSource.loadTemplates(collectionId);
    return dtos.map((dto) => dto.toDomain()).toList(growable: false);
  }

  @override
  Future<LayoutTemplate?> getTemplateById(
    String collectionId,
    String templateId,
  ) async {
    final dtos = await _localDataSource.loadTemplates(collectionId);
    final target = dtos
        .map((dto) => dto.toDomain())
        .firstWhereOrNull((template) => template.id == templateId);
    return target;
  }

  @override
  Future<void> saveTemplate(LayoutTemplate template) async {
    final collectionId = template.collectionId;
    final existingDtos = await _localDataSource.loadTemplates(collectionId);
    final index = existingDtos.indexWhere((dto) => dto.template.id == template.id);
    final originalVersion = index >= 0 ? existingDtos[index].template.version : 0;
    final updatedTemplate = template.copyWith(
      version: originalVersion + 1,
      updatedAt: DateTime.now(),
    );

    final scopeUid = await _authScopeProvider.getScopeUid();

    await _localDataSource.upsertTemplate(
      updatedTemplate,
      enqueueOutbox: true,
      scopeUid: scopeUid,
    );
  }

  @override
  Future<void> deleteTemplate(String collectionId, String templateId) async {
    final scopeUid = await _authScopeProvider.getScopeUid();
    await _localDataSource.softDeleteTemplate(
      collectionId,
      templateId,
      enqueueOutbox: true,
      scopeUid: scopeUid,
    );
  }
}
