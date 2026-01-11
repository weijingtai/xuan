import 'package:common/database/app_database.dart';
import 'package:common/database/daos/outbox_records_dao.dart';
import 'package:common/database/daos/sync_states_dao.dart';
import 'package:common/persistence/outbox_pusher.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late OutboxRecordsDao outboxDao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), false);
    outboxDao = OutboxRecordsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('runOnce marks success and records no backlog', () async {
    const scopeUid = 'u1';
    final now = DateTime.utc(2026, 1, 10, 6, 0, 0);

    await outboxDao.enqueue(
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

    final pusher = OutboxPusher(
      outboxDao: outboxDao,
      remotePush: (_) async => null,
      nowUtc: () => now,
      batchSize: 10,
      maxAttemptsBeforeDead: 3,
    );

    final result = await pusher.runOnce(scopeUid: scopeUid);
    expect(result.processed, equals(1));
    expect(result.succeeded, equals(1));
    expect(result.failed, equals(0));
    expect(result.dead, equals(0));
    expect(result.lastError, isNull);
    expect(await outboxDao.backlogCount(scopeUid), equals(0));
  });

  test('runOnce retries and marks dead after max attempts', () async {
    const scopeUid = 'u1';
    final now = DateTime.utc(2026, 1, 10, 7, 0, 0);

    await outboxDao.enqueue(
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

    final pusher = OutboxPusher(
      outboxDao: outboxDao,
      remotePush: (_) async => const SyncError(
        code: SyncErrorCode.network,
        message: 'timeout',
      ),
      nowUtc: () => now,
      batchSize: 10,
      maxAttemptsBeforeDead: 2,
    );

    final r1 = await pusher.runOnce(scopeUid: scopeUid);
    expect(r1.processed, equals(1));
    expect(r1.failed, equals(1));
    expect(await outboxDao.backlogCount(scopeUid), equals(1));

    final r2 = await pusher.runOnce(scopeUid: scopeUid);
    expect(r2.processed, equals(1));
    expect(r2.dead, equals(1));
    expect(await outboxDao.backlogCount(scopeUid), equals(0));

    final row = await (db.select(db.outboxRecords)
          ..where((t) => t.operationId.equals('op1')))
        .getSingle();
    expect(row.status, equals('dead'));
    expect(row.attempt, equals(2));
  });

  test('SyncCoordinator updates status on success and failure', () async {
    const scopeUid = 'u1';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    await outboxDao.enqueue(
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

    var shouldFail = true;
    final coordinator = SyncCoordinator(
      outboxDao: outboxDao,
      remotePush: (_) async {
        if (!shouldFail) return null;
        return const SyncError(code: SyncErrorCode.network, message: 'timeout');
      },
      nowUtc: () => now,
      pushBatchSize: 10,
      maxAttemptsBeforeDead: 3,
    );

    await coordinator.pushOnce(scopeUid: scopeUid);
    expect(coordinator.status.scopeUid, equals(scopeUid));
    expect(coordinator.status.state, equals(SyncRunState.error));
    expect(coordinator.status.lastError?.code, equals(SyncErrorCode.network));
    expect(coordinator.status.deadCount, equals(0));
    expect(await outboxDao.backlogCount(scopeUid), equals(1));

    shouldFail = false;
    await coordinator.pushOnce(scopeUid: scopeUid);
    expect(coordinator.status.state, equals(SyncRunState.idle));
    expect(coordinator.status.lastError, isNull);
    expect(await outboxDao.backlogCount(scopeUid), equals(0));
  });

  test('pullOnce bootstraps from null cursor and advances across pages',
      () async {
    const scopeUid = 'u1';
    const entityType = 'layout_template';

    final now = DateTime.utc(2026, 1, 10, 10, 0, 0);
    final syncStatesDao = SyncStatesDao(db);

    final calls = <PullCursor?>[];
    final t1 = DateTime.utc(2026, 1, 10, 10, 0, 1);
    final t2 = DateTime.utc(2026, 1, 10, 10, 0, 2);

    final coordinator = SyncCoordinator(
      outboxDao: outboxDao,
      syncStatesDao: syncStatesDao,
      remotePush: (_) async => null,
      remoteListChanges: ({
        required String scopeUid,
        required String entityType,
        required PullCursor? sinceCursor,
        required int limit,
      }) async {
        calls.add(sinceCursor);

        if (sinceCursor == null) {
          return RemoteChangesPage(
            changes: [
              RemoteChange(
                operationId: 'op1',
                entityType: entityType,
                entityId: 't1',
                opType: 'upsert',
                cursor: TimestampCursor(serverUpdatedAtUtc: t1, tieBreaker: 'op2'),
                payloadJson: '{"k":1}',
                serverTimeUtc: t1,
              ),
              RemoteChange(
                operationId: 'op2',
                entityType: entityType,
                entityId: 't2',
                opType: 'upsert',
                cursor: TimestampCursor(serverUpdatedAtUtc: t1, tieBreaker: 'op2'),
                payloadJson: '{"k":2}',
                serverTimeUtc: t1,
              ),
            ],
            nextCursor: TimestampCursor(serverUpdatedAtUtc: t1, tieBreaker: 'op2'),
            hasMore: true,
          );
        }

        return RemoteChangesPage(
          changes: [
            RemoteChange(
              operationId: 'op3',
              entityType: entityType,
              entityId: 't3',
              opType: 'upsert',
              cursor: TimestampCursor(serverUpdatedAtUtc: t2, tieBreaker: 'op3'),
              payloadJson: '{"k":3}',
              serverTimeUtc: t2,
            ),
          ],
          nextCursor: TimestampCursor(serverUpdatedAtUtc: t2, tieBreaker: 'op3'),
          hasMore: false,
        );
      },
      localApply: ({
        required String scopeUid,
        required String entityType,
        required List<RemoteChange> changes,
      }) async {
        return LocalApplyResult(
          canAdvanceCursor: true,
          appliedCount: changes.length,
          outcomes: const [],
          lastError: null,
        );
      },
      nowUtc: () => now,
      pullBatchSize: 2,
    );

    final result = await coordinator.pullOnce(
      scopeUid: scopeUid,
      entityType: entityType,
    );

    expect(result.hasError, isFalse);
    expect(calls, hasLength(2));
    expect(calls.first, isNull);
    expect(calls.last, isA<TimestampCursor>());

    final stored = await syncStatesDao.find(scopeUid: scopeUid, entityType: entityType);
    expect(stored, isNotNull);
    expect(stored!.cursorType, equals('timestamp'));
    expect(stored.serverUpdatedAtUtc!.toUtc(), equals(t2));
    expect(stored.tieBreaker, equals('op3'));
  });

  test('pullOnce resumes from stored cursor when interrupted', () async {
    const scopeUid = 'u1';
    const entityType = 'layout_template';

    final now = DateTime.utc(2026, 1, 10, 11, 0, 0);
    final syncStatesDao = SyncStatesDao(db);

    final calls = <PullCursor?>[];
    final t1 = DateTime.utc(2026, 1, 10, 11, 0, 1);
    final t2 = DateTime.utc(2026, 1, 10, 11, 0, 2);

    final coordinator = SyncCoordinator(
      outboxDao: outboxDao,
      syncStatesDao: syncStatesDao,
      remotePush: (_) async => null,
      remoteListChanges: ({
        required String scopeUid,
        required String entityType,
        required PullCursor? sinceCursor,
        required int limit,
      }) async {
        calls.add(sinceCursor);

        if (sinceCursor == null) {
          return RemoteChangesPage(
            changes: [
              RemoteChange(
                operationId: 'op1',
                entityType: entityType,
                entityId: 't1',
                opType: 'upsert',
                cursor: TimestampCursor(serverUpdatedAtUtc: t1, tieBreaker: 'op1'),
                payloadJson: '{"k":1}',
                serverTimeUtc: t1,
              ),
            ],
            nextCursor: TimestampCursor(serverUpdatedAtUtc: t1, tieBreaker: 'op1'),
            hasMore: true,
          );
        }

        return RemoteChangesPage(
          changes: [
            RemoteChange(
              operationId: 'op2',
              entityType: entityType,
              entityId: 't2',
              opType: 'upsert',
              cursor: TimestampCursor(serverUpdatedAtUtc: t2, tieBreaker: 'op2'),
              payloadJson: '{"k":2}',
              serverTimeUtc: t2,
            ),
          ],
          nextCursor: TimestampCursor(serverUpdatedAtUtc: t2, tieBreaker: 'op2'),
          hasMore: false,
        );
      },
      localApply: ({
        required String scopeUid,
        required String entityType,
        required List<RemoteChange> changes,
      }) async {
        return LocalApplyResult(
          canAdvanceCursor: true,
          appliedCount: changes.length,
          outcomes: const [],
          lastError: null,
        );
      },
      nowUtc: () => now,
      pullBatchSize: 1,
    );

    final r1 = await coordinator.pullOnce(
      scopeUid: scopeUid,
      entityType: entityType,
      maxPages: 1,
    );
    expect(r1.pages, equals(1));

    final stored1 = await syncStatesDao.find(scopeUid: scopeUid, entityType: entityType);
    expect(stored1, isNotNull);
    expect(stored1!.serverUpdatedAtUtc!.toUtc(), equals(t1));

    final r2 = await coordinator.pullOnce(
      scopeUid: scopeUid,
      entityType: entityType,
    );
    expect(r2.hasError, isFalse);

    final stored2 = await syncStatesDao.find(scopeUid: scopeUid, entityType: entityType);
    expect(stored2, isNotNull);
    expect(stored2!.serverUpdatedAtUtc!.toUtc(), equals(t2));

    expect(calls.first, isNull);
    expect(calls.any((c) => c is TimestampCursor), isTrue);
  });

  test('pullOnce returns skipped outcomes for diagnosis without logs', () async {
    const scopeUid = 'u1';
    const entityType = 'layout_template';

    final now = DateTime.utc(2026, 1, 10, 11, 30, 0);
    final syncStatesDao = SyncStatesDao(db);

    final t1 = DateTime.utc(2026, 1, 10, 11, 30, 1);

    final coordinator = SyncCoordinator(
      outboxDao: outboxDao,
      syncStatesDao: syncStatesDao,
      remotePush: (_) async => null,
      remoteListChanges: ({
        required String scopeUid,
        required String entityType,
        required PullCursor? sinceCursor,
        required int limit,
      }) async {
        return RemoteChangesPage(
          changes: [
            RemoteChange(
              operationId: 'op1',
              entityType: entityType,
              entityId: 't1',
              opType: 'upsert',
              cursor: TimestampCursor(serverUpdatedAtUtc: t1, tieBreaker: 'op1'),
              payloadJson: '{"k":1}',
              serverTimeUtc: t1,
            ),
            RemoteChange(
              operationId: 'op2',
              entityType: entityType,
              entityId: 't2',
              opType: 'upsert',
              cursor: TimestampCursor(serverUpdatedAtUtc: t1, tieBreaker: 'op2'),
              payloadJson: '{"k":2}',
              serverTimeUtc: t1,
            ),
          ],
          nextCursor: TimestampCursor(serverUpdatedAtUtc: t1, tieBreaker: 'op2'),
          hasMore: false,
        );
      },
      localApply: ({
        required String scopeUid,
        required String entityType,
        required List<RemoteChange> changes,
      }) async {
        return const LocalApplyResult(
          canAdvanceCursor: true,
          appliedCount: 1,
          outcomes: [
            ChangeApplyOutcome(
              operationId: 'op1',
              entityType: entityType,
              entityId: 't1',
              decision: ChangeApplyDecision.applied,
              reason: null,
              message: null,
            ),
            ChangeApplyOutcome(
              operationId: 'op2',
              entityType: entityType,
              entityId: 't2',
              decision: ChangeApplyDecision.skipped,
              reason: SkipReasonCode.olderThanLocal,
              message: null,
            ),
          ],
          lastError: null,
        );
      },
      nowUtc: () => now,
      pullBatchSize: 10,
    );

    final result = await coordinator.pullOnce(
      scopeUid: scopeUid,
      entityType: entityType,
    );

    expect(result.hasError, isFalse);
    expect(result.applied, equals(1));
    expect(result.skipped, equals(1));
    expect(result.outcomes, hasLength(2));
    expect(
      result.outcomes.where((o) => o.decision == ChangeApplyDecision.skipped).single.reason,
      equals(SkipReasonCode.olderThanLocal),
    );
  });

  test('pullOnce writes diagnosis info into status and caps outcomes', () async {
    const scopeUid = 'u1';
    const entityType = 'layout_template';

    final now = DateTime.utc(2026, 1, 10, 12, 10, 0);
    final syncStatesDao = SyncStatesDao(db);
    final t1 = DateTime.utc(2026, 1, 10, 12, 10, 1);

    final coordinator = SyncCoordinator(
      outboxDao: outboxDao,
      syncStatesDao: syncStatesDao,
      remotePush: (_) async => null,
      remoteListChanges: ({
        required String scopeUid,
        required String entityType,
        required PullCursor? sinceCursor,
        required int limit,
      }) async {
        return RemoteChangesPage(
          changes: [
            RemoteChange(
              operationId: 'op1',
              entityType: entityType,
              entityId: 't1',
              opType: 'upsert',
              cursor: TimestampCursor(serverUpdatedAtUtc: t1, tieBreaker: 'op1'),
              payloadJson: '{"k":1}',
              serverTimeUtc: t1,
            ),
          ],
          nextCursor: TimestampCursor(serverUpdatedAtUtc: t1, tieBreaker: 'op1'),
          hasMore: false,
        );
      },
      localApply: ({
        required String scopeUid,
        required String entityType,
        required List<RemoteChange> changes,
      }) async {
        final outcomes = List<ChangeApplyOutcome>.generate(
          250,
          (i) => ChangeApplyOutcome(
            operationId: 'op$i',
            entityType: entityType,
            entityId: 't$i',
            decision: ChangeApplyDecision.skipped,
            reason: SkipReasonCode.unknown,
            message: null,
          ),
        );

        return LocalApplyResult(
          canAdvanceCursor: true,
          appliedCount: 0,
          outcomes: outcomes,
          lastError: null,
        );
      },
      nowUtc: () => now,
      pullBatchSize: 10,
    );

    expect(coordinator.status.lastPullEntityType, isNull);
    expect(coordinator.status.lastPullOutcomes, isNull);

    final result = await coordinator.pullOnce(
      scopeUid: scopeUid,
      entityType: entityType,
    );

    expect(result.hasError, isFalse);

    expect(coordinator.status.lastPullEntityType, equals(entityType));
    expect(coordinator.status.lastPullOutcomes, isNotNull);
    expect(coordinator.status.lastPullOutcomes, hasLength(200));
  });

  test('pullOnce does not advance cursor when apply fails', () async {
    const scopeUid = 'u1';
    const entityType = 'layout_template';

    final now = DateTime.utc(2026, 1, 10, 12, 0, 0);
    final syncStatesDao = SyncStatesDao(db);

    final t1 = DateTime.utc(2026, 1, 10, 12, 0, 1);

    final coordinator = SyncCoordinator(
      outboxDao: outboxDao,
      syncStatesDao: syncStatesDao,
      remotePush: (_) async => null,
      remoteListChanges: ({
        required String scopeUid,
        required String entityType,
        required PullCursor? sinceCursor,
        required int limit,
      }) async {
        return RemoteChangesPage(
          changes: [
            RemoteChange(
              operationId: 'op1',
              entityType: entityType,
              entityId: 't1',
              opType: 'upsert',
              cursor: TimestampCursor(serverUpdatedAtUtc: t1, tieBreaker: 'op1'),
              payloadJson: '{"k":1}',
              serverTimeUtc: t1,
            ),
          ],
          nextCursor: TimestampCursor(serverUpdatedAtUtc: t1, tieBreaker: 'op1'),
          hasMore: false,
        );
      },
      localApply: ({
        required String scopeUid,
        required String entityType,
        required List<RemoteChange> changes,
      }) async {
        return const LocalApplyResult(
          canAdvanceCursor: false,
          appliedCount: 0,
          outcomes: [],
          lastError: SyncError(code: SyncErrorCode.invalidData, message: 'bad'),
        );
      },
      nowUtc: () => now,
      pullBatchSize: 10,
    );

    final result = await coordinator.pullOnce(
      scopeUid: scopeUid,
      entityType: entityType,
    );

    expect(result.hasError, isTrue);
    expect(coordinator.status.state, equals(SyncRunState.error));

    final stored = await syncStatesDao.find(scopeUid: scopeUid, entityType: entityType);
    expect(stored, isNull);
  });
}

