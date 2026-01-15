import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  test('OutboxRecordsDao listRetryable/deleteByScope', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const scopeUid = 'u1';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    await db.outboxRecordsDao.enqueue(
      OutboxRecordsCompanion.insert(
        operationId: 'op_pending',
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't1',
        opType: 'upsert',
        payloadJson: '{"k":1}',
        createdAtUtc: now,
      ),
    );

    await db.outboxRecordsDao.enqueue(
      OutboxRecordsCompanion.insert(
        operationId: 'op_failed',
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't2',
        opType: 'upsert',
        payloadJson: '{"k":2}',
        createdAtUtc: now,
        status: const Value('failed'),
        attempt: const Value(1),
      ),
    );

    await db.outboxRecordsDao.enqueue(
      OutboxRecordsCompanion.insert(
        operationId: 'op_dead',
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't3',
        opType: 'upsert',
        payloadJson: '{"k":3}',
        createdAtUtc: now,
        status: const Value('dead'),
        attempt: const Value(9),
      ),
    );

    final rows = await db.outboxRecordsDao.listRetryable(scopeUid: scopeUid);
    expect(rows.map((r) => r.operationId).toSet(),
        equals({'op_pending', 'op_failed'}));

    await db.outboxRecordsDao.deleteByScope(scopeUid: scopeUid);
    expect(await db.outboxRecordsDao.listRetryable(scopeUid: scopeUid), isEmpty);
  });

  test('DriftOutboxStore enqueue/peek/mark transitions', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final sink = InMemoryLogSink();
    final logger = SyncLogger(sink: sink, minLevel: SyncLogLevel.trace);
    final store = DriftOutboxStore(dao: db.outboxRecordsDao, logger: logger);

    const scopeUid = 'u1';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    await store.enqueue(
      OutboxRecord(
        operationId: 'op1',
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't1',
        opType: 'upsert',
        payloadJson: '{"k":1}',
        createdAtUtc: now,
        attempt: 0,
      ),
    );

    expect(await store.backlogCount(scopeUid), equals(1));

    final batch1 = await store.peekBatch(scopeUid: scopeUid, limit: 10);
    expect(batch1, hasLength(1));
    expect(batch1.single.attempt, equals(0));

    await store.markFailed(
      operationId: 'op1',
      attempt: 1,
      errorCode: 'network',
      errorMessage: 'timeout',
      atUtc: now,
      isDead: false,
    );

    final batch2 = await store.peekBatch(scopeUid: scopeUid, limit: 10);
    expect(batch2, hasLength(1));
    expect(batch2.single.attempt, equals(1));

    await store.markFailed(
      operationId: 'op1',
      attempt: 2,
      errorCode: 'network',
      errorMessage: 'timeout',
      atUtc: now,
      isDead: true,
    );

    expect(await store.backlogCount(scopeUid), equals(0));
    expect(await store.deadCount(scopeUid), equals(1));

    final batch3 = await store.peekBatch(scopeUid: scopeUid, limit: 10);
    expect(batch3, isEmpty);

    expect(
      sink.records.any((r) => r.event == 'drift_outbox_enqueue_start'),
      isTrue,
    );
    expect(
      sink.records.any((r) => r.event == 'drift_outbox_mark_failed'),
      isTrue,
    );
    expect(
      sink.records.any((r) => r.data.containsKey('payloadJson')),
      isFalse,
    );
  });

  test('DriftSyncStateStore setCursorIfNewer for TimestampCursor', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final sink = InMemoryLogSink();
    final logger = SyncLogger(sink: sink, minLevel: SyncLogLevel.trace);
    final store = DriftSyncStateStore(dao: db.syncStatesDao, logger: logger);

    const scopeUid = 'u1';
    const entityType = 'layout_template';

    await store.setCursorIfNewer(
      scopeUid: scopeUid,
      entityType: entityType,
      cursor: TimestampCursor(
        serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 1, 0, 0),
        tieBreaker: 'a',
      ),
      atUtc: DateTime.utc(2026, 1, 10, 2, 0, 0),
    );

    await store.setCursorIfNewer(
      scopeUid: scopeUid,
      entityType: entityType,
      cursor: TimestampCursor(
        serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 0, 0, 0),
        tieBreaker: 'z',
      ),
      atUtc: DateTime.utc(2026, 1, 10, 3, 0, 0),
    );

    final cursor = await store.getCursor(scopeUid: scopeUid, entityType: entityType);
    expect(cursor, isA<TimestampCursor>());

    final ts = cursor as TimestampCursor;
    expect(ts.serverUpdatedAtUtc, equals(DateTime.utc(2026, 1, 10, 1, 0, 0)));
    expect(ts.tieBreaker, equals('a'));

    expect(
      sink.records.any((r) => r.event == 'drift_sync_state_set_cursor_if_newer'),
      isTrue,
    );
    expect(
      sink.records.any((r) => r.event == 'drift_sync_state_get_cursor'),
      isTrue,
    );
  });
}
