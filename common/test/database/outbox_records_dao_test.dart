import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  late PersistenceDriftDatabase db;
  late OutboxRecordsDao dao;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    dao = db.outboxRecordsDao;
  });

  tearDown(() async {
    await db.close();
  });

  test('enqueue upserts; peekBatch returns pending in createdAt order', () async {
    const scopeUid = 'u1';

    final t1 = DateTime.utc(2026, 1, 10, 1, 0, 0);
    final t2 = DateTime.utc(2026, 1, 10, 1, 0, 1);

    await dao.enqueue(
      OutboxRecordsCompanion.insert(
        operationId: 'op2',
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't2',
        opType: 'upsert',
        payloadJson: '{"k":2}',
        createdAtUtc: t2,
      ),
    );
    await dao.enqueue(
      OutboxRecordsCompanion.insert(
        operationId: 'op1',
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't1',
        opType: 'upsert',
        payloadJson: '{"k":1}',
        createdAtUtc: t1,
      ),
    );

    final batch = await dao.peekBatch(scopeUid: scopeUid, limit: 10);
    expect(batch, hasLength(2));
    expect(batch[0].operationId, equals('op1'));
    expect(batch[1].operationId, equals('op2'));
  });

  test('markFailed increments attempt and can transition to dead', () async {
    const scopeUid = 'u1';
    final now = DateTime.utc(2026, 1, 10, 2, 0, 0);

    await dao.enqueue(
      OutboxRecordsCompanion.insert(
        operationId: 'op1',
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't1',
        opType: 'upsert',
        payloadJson: '{"k":1}',
        createdAtUtc: now,
      ),
    );

    await dao.markFailed(
      operationId: 'op1',
      attempt: 1,
      errorCode: 'network',
      errorMessage: 'timeout',
      atUtc: now,
      isDead: false,
    );

    final batch1 = await dao.peekBatch(scopeUid: scopeUid, limit: 10);
    expect(batch1.single.attempt, equals(1));
    expect(batch1.single.status, equals('failed'));
    expect(batch1.single.lastErrorCode, equals('network'));

    await dao.markFailed(
      operationId: 'op1',
      attempt: 2,
      errorCode: 'network',
      errorMessage: 'timeout',
      atUtc: now,
      isDead: true,
    );

    final batch2 = await dao.peekBatch(scopeUid: scopeUid, limit: 10);
    expect(batch2, isEmpty);
    final deadRow =
        await (db.select(db.outboxRecords)..where((t) => t.operationId.equals('op1')))
            .getSingle();
    expect(deadRow.status, equals('dead'));
  });

  test('markSuccess removes record from backlogCount', () async {
    const scopeUid = 'u1';
    final now = DateTime.utc(2026, 1, 10, 3, 0, 0);

    await dao.enqueue(
      OutboxRecordsCompanion.insert(
        operationId: 'op1',
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't1',
        opType: 'upsert',
        payloadJson: '{"k":1}',
        createdAtUtc: now,
      ),
    );

    expect(await dao.backlogCount(scopeUid), equals(1));
    await dao.markSuccess(operationId: 'op1', atUtc: now);
    expect(await dao.backlogCount(scopeUid), equals(0));
  });
}

