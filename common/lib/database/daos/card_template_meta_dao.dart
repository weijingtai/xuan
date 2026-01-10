import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'card_template_meta_dao.g.dart';

@DriftAccessor(tables: [CardTemplateMetas])
class CardTemplateMetaDao extends DatabaseAccessor<AppDatabase>
    with _$CardTemplateMetaDaoMixin {
  CardTemplateMetaDao(this.db) : super(db);

  final AppDatabase db;

  Future<CardTemplateMeta?> findByTemplateUuid(String templateUuid) {
    return (select(db.cardTemplateMetas)
          ..where((t) => t.templateUuid.equals(templateUuid)))
        .getSingleOrNull();
  }

  Future<void> touchModifiedAt({
    required String templateUuid,
    required DateTime modifiedAt,
  }) async {
    final updated = await (update(db.cardTemplateMetas)
          ..where((t) => t.templateUuid.equals(templateUuid)))
        .write(
      CardTemplateMetasCompanion(
        modifiedAt: Value(modifiedAt),
        deletedAt: const Value(null),
      ),
    );

    if (updated > 0) return;

    await into(db.cardTemplateMetas).insert(
      CardTemplateMetasCompanion.insert(
        templateUuid: templateUuid,
        createdAt: modifiedAt,
        modifiedAt: modifiedAt,
        deletedAt: const Value(null),
        authorUuid: const Value(null),
        createFromCardUuid: const Value(null),
        isCustomized: const Value(null),
      ),
    );
  }
}

