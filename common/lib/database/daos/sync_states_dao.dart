import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'sync_states_dao.g.dart';

@DriftAccessor(tables: [SyncStates])
class SyncStatesDao extends DatabaseAccessor<AppDatabase>
    with _$SyncStatesDaoMixin {
  SyncStatesDao(this.db) : super(db);

  final AppDatabase db;

  int _compareTimestampCursor({
    required DateTime serverUpdatedAtUtcA,
    required String tieBreakerA,
    required DateTime serverUpdatedAtUtcB,
    required String tieBreakerB,
  }) {
    final tsCmp = serverUpdatedAtUtcA.compareTo(serverUpdatedAtUtcB);
    if (tsCmp != 0) return tsCmp;
    return tieBreakerA.compareTo(tieBreakerB);
  }

  Future<void> setTimestampCursorIfNewer({
    required String scopeUid,
    required String entityType,
    required DateTime serverUpdatedAtUtc,
    required String tieBreaker,
    required DateTime atUtc,
  }) async {
    await db.transaction(() async {
      final existing = await find(scopeUid: scopeUid, entityType: entityType);
      if (existing != null &&
          existing.cursorType == 'timestamp' &&
          existing.serverUpdatedAtUtc != null &&
          existing.tieBreaker != null) {
        final cmp = _compareTimestampCursor(
          serverUpdatedAtUtcA: serverUpdatedAtUtc,
          tieBreakerA: tieBreaker,
          serverUpdatedAtUtcB: existing.serverUpdatedAtUtc!,
          tieBreakerB: existing.tieBreaker!,
        );
        if (cmp <= 0) return;
      }

      await upsert(
        SyncStatesCompanion.insert(
          scopeUid: scopeUid,
          entityType: entityType,
          cursorType: 'timestamp',
          serverUpdatedAtUtc: Value(serverUpdatedAtUtc),
          tieBreaker: Value(tieBreaker),
          cursorUpdatedAtUtc: atUtc,
          revision: const Value(null),
          lastPulledAtUtc: const Value(null),
          lastPushedAtUtc: const Value(null),
        ),
      );
    });
  }

  Future<void> setRevisionCursorIfNewer({
    required String scopeUid,
    required String entityType,
    required int revision,
    required DateTime atUtc,
  }) async {
    await db.transaction(() async {
      final existing = await find(scopeUid: scopeUid, entityType: entityType);
      if (existing != null &&
          existing.cursorType == 'revision' &&
          existing.revision != null) {
        if (revision <= existing.revision!) return;
      }

      await upsert(
        SyncStatesCompanion.insert(
          scopeUid: scopeUid,
          entityType: entityType,
          cursorType: 'revision',
          revision: Value(revision),
          serverUpdatedAtUtc: const Value(null),
          tieBreaker: const Value(null),
          cursorUpdatedAtUtc: atUtc,
          lastPulledAtUtc: const Value(null),
          lastPushedAtUtc: const Value(null),
        ),
      );
    });
  }

  Future<SyncStateRow?> find({
    required String scopeUid,
    required String entityType,
  }) {
    return (select(db.syncStates)
          ..where(
            (t) => t.scopeUid.equals(scopeUid) & t.entityType.equals(entityType),
          ))
        .getSingleOrNull();
  }

  Future<void> upsert(SyncStatesCompanion companion) async {
    await into(db.syncStates).insertOnConflictUpdate(companion);
  }

  Future<void> clear({
    required String scopeUid,
    required String entityType,
  }) async {
    await (delete(db.syncStates)
          ..where(
            (t) => t.scopeUid.equals(scopeUid) & t.entityType.equals(entityType),
          ))
        .go();
  }

  Future<void> markPulledAt({
    required String scopeUid,
    required String entityType,
    required DateTime atUtc,
  }) async {
    await (update(db.syncStates)
          ..where(
            (t) => t.scopeUid.equals(scopeUid) & t.entityType.equals(entityType),
          ))
        .write(SyncStatesCompanion(lastPulledAtUtc: Value(atUtc)));
  }

  Future<void> markPushedAt({
    required String scopeUid,
    required DateTime atUtc,
  }) async {
    await (update(db.syncStates)..where((t) => t.scopeUid.equals(scopeUid)))
        .write(SyncStatesCompanion(lastPushedAtUtc: Value(atUtc)));
  }
}
