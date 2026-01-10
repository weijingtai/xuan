import 'dart:convert';

import '../database/app_database.dart';
import '../models/layout_template_dto.dart';

import '../database/daos/card_template_meta_dao.dart';
import '../database/daos/layout_templates_dao.dart';

class LayoutTemplateLocalDataSource {
  LayoutTemplateLocalDataSource(this._db)
      : _dao = LayoutTemplatesDao(_db),
        _metaDao = CardTemplateMetaDao(_db);

  final AppDatabase _db;
  final LayoutTemplatesDao _dao;
  final CardTemplateMetaDao _metaDao;

  Future<List<LayoutTemplateDto>> loadTemplates(String collectionId) async {
    final rows = await _dao.getAllByCollection(collectionId);
    return rows
        .map((row) => jsonDecode(row.templateJson))
        .whereType<Map<String, dynamic>>()
        .map(LayoutTemplateDto.fromJson)
        .toList(growable: false);
  }

  Future<void> persistTemplates(
    String collectionId,
    List<LayoutTemplateDto> templates,
  ) async {
    final domainTemplates =
        templates.map((dto) => dto.toDomain()).toList(growable: false);

    await _db.transaction(() async {
      await _dao.upsertAllTemplates(domainTemplates);
      for (final template in domainTemplates) {
        await _metaDao.touchModifiedAt(
          templateUuid: template.id,
          modifiedAt: template.updatedAt,
        );
      }
      await _dao.softDeleteMissing(
        collectionId,
        domainTemplates.map((t) => t.id).toSet(),
      );
    });
  }

  Future<void> removeCollection(String collectionId) async {
    await _dao.softDeleteByCollection(collectionId);
  }
}
