import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'card_template_skill_usage_dao.g.dart';

@DriftAccessor(tables: [CardTemplateSkillUsages])
class CardTemplateSkillUsageDao extends DatabaseAccessor<AppDatabase>
    with _$CardTemplateSkillUsageDaoMixin {
  CardTemplateSkillUsageDao(this.db) : super(db);

  final AppDatabase db;

  SimpleSelectStatement<$CardTemplateSkillUsagesTable, CardTemplateSkillUsage>
      _baseSelect() {
    return select(db.cardTemplateSkillUsages)
      ..where((t) => t.deletedAt.isNull());
  }

  static String formatUsedAt(DateTime dateTime) {
    if (dateTime.isUtc) return dateTime.toIso8601String();
    final base = dateTime.toIso8601String();
    final offset = dateTime.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    final hh = abs.inHours.toString().padLeft(2, '0');
    final mm = (abs.inMinutes % 60).toString().padLeft(2, '0');
    return '$base$sign$hh:$mm';
  }

  Future<int> insertUsage({
    required String queryUuid,
    required String templateUuid,
    required int skillId,
    required String usedAt,
  }) {
    final now = DateTime.now();
    return into(db.cardTemplateSkillUsages).insert(
      CardTemplateSkillUsagesCompanion.insert(
        createdAt: now,
        lastUpdatedAt: now,
        deletedAt: const Value(null),
        queryUuid: queryUuid,
        templateUuid: templateUuid,
        skillId: skillId,
        usedAt: usedAt,
      ),
    );
  }

  Future<CardTemplateSkillUsage?> findLatestByQueryAndSkill({
    required String queryUuid,
    required int skillId,
  }) {
    return (_baseSelect()
          ..where((t) => t.queryUuid.equals(queryUuid) & t.skillId.equals(skillId))
          ..orderBy([(t) => OrderingTerm.desc(t.usedAt), (t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<CardTemplateSkillUsage>> findByTemplate({
    required String templateUuid,
    int? limit,
  }) {
    final stmt = _baseSelect()
      ..where((t) => t.templateUuid.equals(templateUuid))
      ..orderBy([(t) => OrderingTerm.desc(t.usedAt), (t) => OrderingTerm.desc(t.id)]);
    if (limit != null) {
      stmt.limit(limit);
    }
    return stmt.get();
  }
}

