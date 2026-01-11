import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/layout_template.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'layout_templates_dao.g.dart';

@DriftAccessor(tables: [LayoutTemplates])
class LayoutTemplatesDao extends DatabaseAccessor<AppDatabase>
    with _$LayoutTemplatesDaoMixin {
  LayoutTemplatesDao(this.db) : super(db);

  final AppDatabase db;

  SimpleSelectStatement<$LayoutTemplatesTable, LayoutTemplateRow> _baseSelect(
    String collectionId,
  ) {
    return select(db.layoutTemplates)
      ..where(
          (t) => t.collectionId.equals(collectionId) & t.deletedAt.isNull());
  }

  Future<List<LayoutTemplateRow>> getAllByCollection(String collectionId) {
    return (_baseSelect(collectionId)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  Future<LayoutTemplateRow?> getById(
    String collectionId,
    String templateId,
  ) {
    return (_baseSelect(collectionId)..where((t) => t.uuid.equals(templateId)))
        .getSingleOrNull();
  }

  Future<void> upsertTemplate(LayoutTemplate template) async {
    await into(db.layoutTemplates).insertOnConflictUpdate(
      LayoutTemplatesCompanion.insert(
        uuid: template.id,
        collectionId: template.collectionId,
        name: template.name,
        description: Value(template.description),
        templateJson: jsonEncode(template.toJson()),
        version: template.version,
        updatedAt: template.updatedAt,
        deletedAt: const Value(null),
      ),
    );
  }

  Future<void> upsertAllTemplates(List<LayoutTemplate> templates) async {
    if (templates.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.layoutTemplates,
        templates
            .map(
              (template) => LayoutTemplatesCompanion.insert(
                uuid: template.id,
                collectionId: template.collectionId,
                name: template.name,
                description: Value(template.description),
                templateJson: jsonEncode(template.toJson()),
                version: template.version,
                updatedAt: template.updatedAt,
                deletedAt: const Value(null),
              ),
            )
            .toList(growable: false),
      );
    });
  }

  Future<int> softDeleteById(String collectionId, String templateId) {
    return (update(db.layoutTemplates)
          ..where((t) =>
              t.collectionId.equals(collectionId) & t.uuid.equals(templateId)))
        .write(LayoutTemplatesCompanion(deletedAt: Value(DateTime.now())));
  }

  Future<int> softDeleteByIdAt(
    String collectionId,
    String templateId,
    DateTime deletedAt,
  ) {
    return (update(db.layoutTemplates)
          ..where((t) =>
              t.collectionId.equals(collectionId) & t.uuid.equals(templateId)))
        .write(LayoutTemplatesCompanion(deletedAt: Value(deletedAt)));
  }

  Future<int> softDeleteByCollection(String collectionId) {
    return (update(db.layoutTemplates)
          ..where((t) => t.collectionId.equals(collectionId)))
        .write(LayoutTemplatesCompanion(deletedAt: Value(DateTime.now())));
  }

  Future<int> softDeleteMissing(
    String collectionId,
    Set<String> keepTemplateIds,
  ) {
    if (keepTemplateIds.isEmpty) {
      return softDeleteByCollection(collectionId);
    }
    return (update(db.layoutTemplates)
          ..where((t) =>
              t.collectionId.equals(collectionId) &
              t.uuid.isNotIn(keepTemplateIds.toList())))
        .write(LayoutTemplatesCompanion(deletedAt: Value(DateTime.now())));
  }
}
