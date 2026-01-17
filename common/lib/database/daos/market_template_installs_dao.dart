import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'market_template_installs_dao.g.dart';

@DriftAccessor(tables: [MarketTemplateInstalls])
class MarketTemplateInstallsDao extends DatabaseAccessor<AppDatabase>
    with _$MarketTemplateInstallsDaoMixin {
  MarketTemplateInstallsDao(this.db) : super(db);

  final AppDatabase db;

  SimpleSelectStatement<$MarketTemplateInstallsTable, MarketTemplateInstall>
      _baseSelect() {
    return select(db.marketTemplateInstalls)
      ..where((t) => t.deletedAt.isNull());
  }

  Future<MarketTemplateInstall?> findByLocalTemplateUuid(
    String localTemplateUuid,
  ) {
    return (_baseSelect()
          ..where((t) => t.localTemplateUuid.equals(localTemplateUuid)))
        .getSingleOrNull();
  }

  Future<void> upsertInstall({
    required String localTemplateUuid,
    required String marketTemplateId,
    required String marketVersionId,
    DateTime? installedAt,
    DateTime? pinnedAt,
    DateTime? lastCheckedAt,
  }) {
    final now = DateTime.now();
    final resolvedInstalledAt = installedAt ?? now;

    return into(db.marketTemplateInstalls).insertOnConflictUpdate(
      MarketTemplateInstallsCompanion.insert(
        localTemplateUuid: localTemplateUuid,
        marketTemplateId: marketTemplateId,
        marketVersionId: marketVersionId,
        installedAt: resolvedInstalledAt,
        pinnedAt: Value(pinnedAt),
        lastCheckedAt: Value(lastCheckedAt),
        deletedAt: const Value(null),
      ),
    );
  }

  Future<int> softDeleteByLocalTemplateUuid(String localTemplateUuid) {
    final now = DateTime.now();
    return (update(db.marketTemplateInstalls)
          ..where((t) => t.localTemplateUuid.equals(localTemplateUuid)))
        .write(
      MarketTemplateInstallsCompanion(
        deletedAt: Value(now),
        lastCheckedAt: Value(now),
      ),
    );
  }

  Future<List<MarketTemplateInstall>> listByMarketTemplateId(
    String marketTemplateId, {
    int? limit,
  }) {
    final stmt = _baseSelect()
      ..where((t) => t.marketTemplateId.equals(marketTemplateId))
      ..orderBy([(t) => OrderingTerm.desc(t.installedAt)]);
    if (limit != null) {
      stmt.limit(limit);
    }
    return stmt.get();
  }
}
