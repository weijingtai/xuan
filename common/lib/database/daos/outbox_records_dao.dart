import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'outbox_records_dao.g.dart';

@DriftAccessor(tables: [OutboxRecords])
class OutboxRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$OutboxRecordsDaoMixin {
  OutboxRecordsDao(this.db) : super(db);

  final AppDatabase db;

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
    await (update(db.outboxRecords)..where((t) => t.operationId.equals(operationId)))
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
    await (update(db.outboxRecords)..where((t) => t.operationId.equals(operationId)))
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

