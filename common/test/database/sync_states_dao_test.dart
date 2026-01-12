import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_drift/persistence_drift.dart';

void main() {
  late PersistenceDriftDatabase db;
  late SyncStatesDao dao;

  setUp(() {
    db = PersistenceDriftDatabase(NativeDatabase.memory());
    dao = db.syncStatesDao;
  });

  tearDown(() async {
    await db.close();
  });

  test('upsert and find isolate by scope+entityType', () async {
    final now = DateTime.utc(2026, 1, 10, 4, 0, 0);

    await dao.upsert(
      SyncStatesCompanion.insert(
        scopeUid: 'u1',
        entityType: 'layout_template',
        cursorType: 'timestamp',
        serverUpdatedAtUtc: Value(now),
        tieBreaker: const Value('op1'),
        cursorUpdatedAtUtc: now,
        lastPulledAtUtc: const Value(null),
        lastPushedAtUtc: const Value(null),
        revision: const Value(null),
      ),
    );

    await dao.upsert(
      SyncStatesCompanion.insert(
        scopeUid: 'u2',
        entityType: 'layout_template',
        cursorType: 'timestamp',
        serverUpdatedAtUtc: Value(now),
        tieBreaker: const Value('op2'),
        cursorUpdatedAtUtc: now,
        lastPulledAtUtc: const Value(null),
        lastPushedAtUtc: const Value(null),
        revision: const Value(null),
      ),
    );

    final u1 = await dao.find(scopeUid: 'u1', entityType: 'layout_template');
    final u2 = await dao.find(scopeUid: 'u2', entityType: 'layout_template');

    expect(u1, isNotNull);
    expect(u2, isNotNull);
    expect(u1!.tieBreaker, equals('op1'));
    expect(u2!.tieBreaker, equals('op2'));
  });

  test('clear removes the state row', () async {
    final now = DateTime.utc(2026, 1, 10, 5, 0, 0);

    await dao.upsert(
      SyncStatesCompanion.insert(
        scopeUid: 'u1',
        entityType: 'layout_template',
        cursorType: 'revision',
        revision: const Value(10),
        serverUpdatedAtUtc: const Value(null),
        tieBreaker: const Value(null),
        cursorUpdatedAtUtc: now,
        lastPulledAtUtc: const Value(null),
        lastPushedAtUtc: const Value(null),
      ),
    );

    expect(
      await dao.find(scopeUid: 'u1', entityType: 'layout_template'),
      isNotNull,
    );

    await dao.clear(scopeUid: 'u1', entityType: 'layout_template');
    expect(
      await dao.find(scopeUid: 'u1', entityType: 'layout_template'),
      isNull,
    );
  });

  test('setTimestampCursorIfNewer is idempotent and only moves forward',
      () async {
    final t1 = DateTime.utc(2026, 1, 10, 6, 0, 0);
    final t2 = DateTime.utc(2026, 1, 10, 6, 0, 1);

    await dao.setTimestampCursorIfNewer(
      scopeUid: 'u1',
      entityType: 'layout_template',
      serverUpdatedAtUtc: t2,
      tieBreaker: 'op2',
      atUtc: t2,
    );

    await dao.setTimestampCursorIfNewer(
      scopeUid: 'u1',
      entityType: 'layout_template',
      serverUpdatedAtUtc: t1,
      tieBreaker: 'op1',
      atUtc: t1,
    );

    final row1 = await dao.find(scopeUid: 'u1', entityType: 'layout_template');
    expect(row1, isNotNull);
    expect(row1!.cursorType, equals('timestamp'));
    expect(row1.serverUpdatedAtUtc!.toUtc(), equals(t2));
    expect(row1.tieBreaker, equals('op2'));

    await dao.setTimestampCursorIfNewer(
      scopeUid: 'u1',
      entityType: 'layout_template',
      serverUpdatedAtUtc: t2,
      tieBreaker: 'op1',
      atUtc: t2,
    );

    final row2 = await dao.find(scopeUid: 'u1', entityType: 'layout_template');
    expect(row2, isNotNull);
    expect(row2!.serverUpdatedAtUtc!.toUtc(), equals(t2));
    expect(row2.tieBreaker, equals('op2'));
  });

  test('setRevisionCursorIfNewer is idempotent and only moves forward',
      () async {
    final t1 = DateTime.utc(2026, 1, 10, 7, 0, 0);
    final t2 = DateTime.utc(2026, 1, 10, 7, 0, 1);

    await dao.setRevisionCursorIfNewer(
      scopeUid: 'u1',
      entityType: 'layout_template',
      revision: 10,
      atUtc: t1,
    );

    await dao.setRevisionCursorIfNewer(
      scopeUid: 'u1',
      entityType: 'layout_template',
      revision: 9,
      atUtc: t2,
    );

    final row1 = await dao.find(scopeUid: 'u1', entityType: 'layout_template');
    expect(row1, isNotNull);
    expect(row1!.cursorType, equals('revision'));
    expect(row1.revision, equals(10));

    await dao.setRevisionCursorIfNewer(
      scopeUid: 'u1',
      entityType: 'layout_template',
      revision: 11,
      atUtc: t2,
    );

    final row2 = await dao.find(scopeUid: 'u1', entityType: 'layout_template');
    expect(row2, isNotNull);
    expect(row2!.revision, equals(11));
  });

  test('markPulledAt and markPushedAt update only intended rows', () async {
    final now = DateTime.utc(2026, 1, 10, 8, 0, 0);

    await dao.upsert(
      SyncStatesCompanion.insert(
        scopeUid: 'u1',
        entityType: 'layout_template',
        cursorType: 'timestamp',
        serverUpdatedAtUtc: Value(now),
        tieBreaker: const Value('op1'),
        cursorUpdatedAtUtc: now,
        lastPulledAtUtc: const Value(null),
        lastPushedAtUtc: const Value(null),
        revision: const Value(null),
      ),
    );

    await dao.upsert(
      SyncStatesCompanion.insert(
        scopeUid: 'u1',
        entityType: 'other_entity',
        cursorType: 'timestamp',
        serverUpdatedAtUtc: Value(now),
        tieBreaker: const Value('op2'),
        cursorUpdatedAtUtc: now,
        lastPulledAtUtc: const Value(null),
        lastPushedAtUtc: const Value(null),
        revision: const Value(null),
      ),
    );

    final pulledAt = DateTime.utc(2026, 1, 10, 8, 0, 1);
    await dao.markPulledAt(
      scopeUid: 'u1',
      entityType: 'layout_template',
      atUtc: pulledAt,
    );

    final lt = await dao.find(scopeUid: 'u1', entityType: 'layout_template');
    final other = await dao.find(scopeUid: 'u1', entityType: 'other_entity');
    expect(lt, isNotNull);
    expect(other, isNotNull);
    expect(lt!.lastPulledAtUtc!.toUtc(), equals(pulledAt));
    expect(other!.lastPulledAtUtc, isNull);

    final pushedAt = DateTime.utc(2026, 1, 10, 8, 0, 2);
    await dao.markPushedAt(scopeUid: 'u1', atUtc: pushedAt);

    final lt2 = await dao.find(scopeUid: 'u1', entityType: 'layout_template');
    final other2 = await dao.find(scopeUid: 'u1', entityType: 'other_entity');
    expect(lt2!.lastPushedAtUtc!.toUtc(), equals(pushedAt));
    expect(other2!.lastPushedAtUtc!.toUtc(), equals(pushedAt));
  });
}
