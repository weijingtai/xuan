library persistence_drift;

import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';

part 'persistence_drift.g.dart';

@DataClassName('OutboxRecordRow')
class OutboxRecords extends Table {
  @override
  String get tableName => 't_outbox';

  TextColumn get operationId => text().named('operation_id')();
  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  TextColumn get opType => text().named('op_type')();

  TextColumn get payloadJson => text().named('payload_json')();
  TextColumn get payloadSummary => text().nullable().named('payload_summary')();
  TextColumn get payloadHash => text().nullable().named('payload_hash')();

  DateTimeColumn get createdAtUtc => dateTime().named('created_at_utc')();
  IntColumn get attempt =>
      integer().withDefault(const Constant(0)).named('attempt')();
  TextColumn get status =>
      text().withDefault(const Constant('pending')).named('status')();

  TextColumn get lastErrorCode => text().nullable().named('last_error_code')();
  TextColumn get lastErrorMessage =>
      text().nullable().named('last_error_message')();
  DateTimeColumn get lastAttemptAtUtc =>
      dateTime().nullable().named('last_attempt_at_utc')();
  DateTimeColumn get succeededAtUtc =>
      dateTime().nullable().named('succeeded_at_utc')();

  @override
  Set<Column> get primaryKey => {operationId};

  @override
  List<Index> get indexes => [
        Index(
          'idx_outbox_scope_status_created',
          'CREATE INDEX idx_outbox_scope_status_created ON t_outbox (scope_uid, status, created_at_utc);',
        ),
        Index(
          'idx_outbox_scope_status',
          'CREATE INDEX idx_outbox_scope_status ON t_outbox (scope_uid, status);',
        ),
      ];
}

@DataClassName('SyncStateRow')
class SyncStates extends Table {
  @override
  String get tableName => 't_sync_state';

  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get entityType => text().named('entity_type')();

  TextColumn get cursorType => text().named('cursor_type')();
  IntColumn get revision => integer().nullable().named('revision')();
  DateTimeColumn get serverUpdatedAtUtc =>
      dateTime().nullable().named('server_updated_at_utc')();
  TextColumn get tieBreaker => text().nullable().named('tie_breaker')();

  DateTimeColumn get cursorUpdatedAtUtc =>
      dateTime().named('cursor_updated_at_utc')();
  DateTimeColumn get lastPulledAtUtc =>
      dateTime().nullable().named('last_pulled_at_utc')();
  DateTimeColumn get lastPushedAtUtc =>
      dateTime().nullable().named('last_pushed_at_utc')();

  @override
  Set<Column> get primaryKey => {scopeUid, entityType};

  @override
  List<Index> get indexes => [
        Index(
          'idx_sync_state_scope',
          'CREATE INDEX idx_sync_state_scope ON t_sync_state (scope_uid);',
        ),
      ];
}

@DriftAccessor(tables: [OutboxRecords])
class OutboxRecordsDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$OutboxRecordsDaoMixin {
  OutboxRecordsDao(this.db) : super(db);

  final PersistenceDriftDatabase db;

  Future<void> enqueue(OutboxRecordsCompanion companion) async {
    await into(db.outboxRecords).insertOnConflictUpdate(companion);
  }

  Future<List<OutboxRecordRow>> peekBatch({
    required String scopeUid,
    required int limit,
  }) {
    return (select(db.outboxRecords)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                (t.status.equals('pending') | t.status.equals('failed')),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAtUtc)])
          ..limit(limit))
        .get();
  }

  Future<int> backlogCount(String scopeUid) async {
    final row = await (selectOnly(db.outboxRecords)
          ..addColumns([db.outboxRecords.operationId.count()])
          ..where(
            db.outboxRecords.scopeUid.equals(scopeUid) &
                (db.outboxRecords.status.equals('pending') |
                    db.outboxRecords.status.equals('failed')),
          ))
        .getSingle();
    return row.read(db.outboxRecords.operationId.count()) ?? 0;
  }

  Future<int> deadCount(String scopeUid) async {
    final row = await (selectOnly(db.outboxRecords)
          ..addColumns([db.outboxRecords.operationId.count()])
          ..where(
            db.outboxRecords.scopeUid.equals(scopeUid) &
                db.outboxRecords.status.equals('dead'),
          ))
        .getSingle();
    return row.read(db.outboxRecords.operationId.count()) ?? 0;
  }

  Future<void> markSuccess({
    required String operationId,
    required DateTime atUtc,
  }) async {
    await (update(db.outboxRecords)
          ..where((t) => t.operationId.equals(operationId)))
        .write(
      OutboxRecordsCompanion(
        status: const Value('success'),
        succeededAtUtc: Value(atUtc),
        lastErrorCode: const Value(null),
        lastErrorMessage: const Value(null),
      ),
    );
  }

  Future<void> markFailed({
    required String operationId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  }) async {
    await (update(db.outboxRecords)
          ..where((t) => t.operationId.equals(operationId)))
        .write(
      OutboxRecordsCompanion(
        attempt: Value(attempt),
        status: Value(isDead ? 'dead' : 'failed'),
        lastErrorCode: Value(errorCode),
        lastErrorMessage: Value(errorMessage),
        lastAttemptAtUtc: Value(atUtc),
      ),
    );
  }
}

@DriftAccessor(tables: [SyncStates])
class SyncStatesDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$SyncStatesDaoMixin {
  SyncStatesDao(this.db) : super(db);

  final PersistenceDriftDatabase db;

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

@DriftDatabase(
  tables: [OutboxRecords, SyncStates],
  daos: [OutboxRecordsDao, SyncStatesDao],
)
class PersistenceDriftDatabase extends _$PersistenceDriftDatabase {
  PersistenceDriftDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;
}

class DriftOutboxStore implements OutboxStore {
  DriftOutboxStore({required OutboxRecordsDao dao}) : _dao = dao;

  final OutboxRecordsDao _dao;

  OutboxRecord _mapRow(OutboxRecordRow row) {
    return OutboxRecord(
      operationId: row.operationId,
      scopeUid: row.scopeUid,
      entityType: row.entityType,
      entityId: row.entityId,
      opType: row.opType,
      payloadJson: row.payloadJson,
      createdAtUtc: row.createdAtUtc,
      attempt: row.attempt,
    );
  }

  @override
  Future<void> enqueue(OutboxRecord record) async {
    await _dao.enqueue(
      OutboxRecordsCompanion.insert(
        operationId: record.operationId,
        scopeUid: record.scopeUid,
        entityType: record.entityType,
        entityId: record.entityId,
        opType: record.opType,
        payloadJson: record.payloadJson,
        createdAtUtc: record.createdAtUtc,
        attempt: Value(record.attempt),
        payloadSummary: const Value(null),
        payloadHash: const Value(null),
      ),
    );
  }

  @override
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required int limit,
  }) async {
    final rows = await _dao.peekBatch(scopeUid: scopeUid, limit: limit);
    return rows.map(_mapRow).toList(growable: false);
  }

  @override
  Future<void> markSuccess({
    required String operationId,
    required DateTime atUtc,
  }) {
    return _dao.markSuccess(operationId: operationId, atUtc: atUtc);
  }

  @override
  Future<void> markFailed({
    required String operationId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  }) {
    return _dao.markFailed(
      operationId: operationId,
      attempt: attempt,
      errorCode: errorCode,
      errorMessage: errorMessage,
      atUtc: atUtc,
      isDead: isDead,
    );
  }

  @override
  Future<int> backlogCount(String scopeUid) {
    return _dao.backlogCount(scopeUid);
  }

  @override
  Future<int> deadCount(String scopeUid) {
    return _dao.deadCount(scopeUid);
  }
}

class DriftSyncStateStore implements SyncStateStore {
  DriftSyncStateStore({required SyncStatesDao dao}) : _dao = dao;

  final SyncStatesDao _dao;

  @override
  Future<PullCursor?> getCursor({
    required String scopeUid,
    required String entityType,
  }) async {
    final row = await _dao.find(scopeUid: scopeUid, entityType: entityType);
    if (row == null) return null;

    if (row.cursorType == 'timestamp' &&
        row.serverUpdatedAtUtc != null &&
        row.tieBreaker != null) {
      return TimestampCursor(
        serverUpdatedAtUtc: row.serverUpdatedAtUtc!,
        tieBreaker: row.tieBreaker!,
      );
    }

    if (row.cursorType == 'revision' && row.revision != null) {
      return RevisionCursor(revision: row.revision!);
    }

    return null;
  }

  @override
  Future<void> setCursorIfNewer({
    required String scopeUid,
    required String entityType,
    required PullCursor cursor,
    required DateTime atUtc,
  }) {
    if (cursor is TimestampCursor) {
      return _dao.setTimestampCursorIfNewer(
        scopeUid: scopeUid,
        entityType: entityType,
        serverUpdatedAtUtc: cursor.serverUpdatedAtUtc,
        tieBreaker: cursor.tieBreaker,
        atUtc: atUtc,
      );
    }

    if (cursor is RevisionCursor) {
      return _dao.setRevisionCursorIfNewer(
        scopeUid: scopeUid,
        entityType: entityType,
        revision: cursor.revision,
        atUtc: atUtc,
      );
    }

    throw UnsupportedError('Unsupported cursor type: ${cursor.runtimeType}');
  }

  @override
  Future<void> clear({
    required String scopeUid,
    required String entityType,
  }) {
    return _dao.clear(scopeUid: scopeUid, entityType: entityType);
  }

  @override
  Future<void> markPulledAt({
    required String scopeUid,
    required String entityType,
    required DateTime atUtc,
  }) {
    return _dao.markPulledAt(scopeUid: scopeUid, entityType: entityType, atUtc: atUtc);
  }

  @override
  Future<void> markPushedAt({
    required String scopeUid,
    required DateTime atUtc,
  }) {
    return _dao.markPushedAt(scopeUid: scopeUid, atUtc: atUtc);
  }
}
