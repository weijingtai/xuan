import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  test('DriftOutboxStore enqueue/peek/mark transitions', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final store = DriftOutboxStore(dao: db.outboxRecordsDao);

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
  });

  test('DriftSyncStateStore setCursorIfNewer for TimestampCursor', () async {
    final db = PersistenceDriftDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final store = DriftSyncStateStore(dao: db.syncStatesDao);

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
  });
}
