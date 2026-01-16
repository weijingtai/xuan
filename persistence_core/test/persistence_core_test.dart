import 'dart:async';
import 'dart:io';

import 'package:persistence_core/persistence_core.dart';
import 'package:test/test.dart';

class _InMemoryOutboxStore implements OutboxStore {
  final Map<String, OutboxRecord> _recordsById = <String, OutboxRecord>{};
  final Map<String, String> _statusById = <String, String>{};
  final Map<String, StreamController<int>> _backlogControllersByScopeUid =
      <String, StreamController<int>>{};

  StreamController<int> _controllerFor(String scopeUid) {
    return _backlogControllersByScopeUid.putIfAbsent(
      scopeUid,
      () => StreamController<int>.broadcast(),
    );
  }

  Future<void> _emitBacklog(String scopeUid) async {
    if (!_backlogControllersByScopeUid.containsKey(scopeUid)) return;
    _controllerFor(scopeUid).add(await backlogCount(scopeUid));
  }

  @override
  Future<void> enqueue(OutboxRecord record) async {
    _recordsById[record.operationId] = record;
    _statusById.putIfAbsent(record.operationId, () => 'pending');
    await _emitBacklog(record.scopeUid);
  }

  @override
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required int limit,
  }) async {
    final batch =
        _recordsById.values.where((r) => r.scopeUid == scopeUid).where((r) {
      final status = _statusById[r.operationId];
      return status == 'pending' || status == 'failed';
    }).toList(growable: false)
          ..sort((a, b) => a.createdAtUtc.compareTo(b.createdAtUtc));

    if (limit <= 0) return const [];
    return batch.length <= limit ? batch : batch.sublist(0, limit);
  }

  @override
  Future<void> markSuccess({
    required String operationId,
    required DateTime atUtc,
  }) async {
    _statusById[operationId] = 'success';
    final r = _recordsById[operationId];
    if (r != null) await _emitBacklog(r.scopeUid);
  }

  @override
  Future<void> markFailed({
    required String operationId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  }) async {
    final existing = _recordsById[operationId];
    if (existing != null) {
      _recordsById[operationId] = existing.copyWith(attempt: attempt);
    }
    _statusById[operationId] = isDead ? 'dead' : 'failed';
    if (existing != null) await _emitBacklog(existing.scopeUid);
  }

  @override
  Future<int> backlogCount(String scopeUid) async {
    var count = 0;
    for (final r in _recordsById.values) {
      if (r.scopeUid != scopeUid) continue;
      final status = _statusById[r.operationId];
      if (status == 'pending' || status == 'failed') count += 1;
    }
    return count;
  }

  @override
  Stream<int> watchBacklogCount(String scopeUid) {
    return (() async* {
      yield await backlogCount(scopeUid);
      yield* _controllerFor(scopeUid).stream;
    })()
        .distinct();
  }

  @override
  Future<int> deadCount(String scopeUid) async {
    var count = 0;
    for (final r in _recordsById.values) {
      if (r.scopeUid != scopeUid) continue;
      final status = _statusById[r.operationId];
      if (status == 'dead') count += 1;
    }
    return count;
  }
}

class _FakeRemoteGateway implements RemoteGateway {
  _FakeRemoteGateway({
    required this.pushError,
    RemoteChangesPage Function(
      String scopeUid,
      String entityType,
      PullCursor? sinceCursor,
      int limit,
    )? listChangesFn,
  }) : _listChangesFn = listChangesFn;

  final SyncError? Function(OutboxRecord record) pushError;
  final RemoteChangesPage Function(
    String scopeUid,
    String entityType,
    PullCursor? sinceCursor,
    int limit,
  )? _listChangesFn;

  @override
  Future<SyncError?> push(OutboxRecord record) async {
    return pushError(record);
  }

  @override
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    final fn = _listChangesFn;
    if (fn == null) {
      return const RemoteChangesPage(
          changes: [], nextCursor: null, hasMore: false);
    }
    return fn(scopeUid, entityType, sinceCursor, limit);
  }
}

class _InMemorySyncStateStore implements SyncStateStore {
  final Map<String, PullCursor> _cursors = <String, PullCursor>{};

  String _key(String scopeUid, String entityType) => '$scopeUid|$entityType';

  int _compareTimestamp(TimestampCursor a, TimestampCursor b) {
    final tsCmp = a.serverUpdatedAtUtc.compareTo(b.serverUpdatedAtUtc);
    if (tsCmp != 0) return tsCmp;
    return a.tieBreaker.compareTo(b.tieBreaker);
  }

  @override
  Future<PullCursor?> getCursor({
    required String scopeUid,
    required String entityType,
  }) async {
    return _cursors[_key(scopeUid, entityType)];
  }

  @override
  Future<void> setCursorIfNewer({
    required String scopeUid,
    required String entityType,
    required PullCursor cursor,
    required DateTime atUtc,
  }) async {
    final k = _key(scopeUid, entityType);
    final existing = _cursors[k];

    if (existing is TimestampCursor && cursor is TimestampCursor) {
      if (_compareTimestamp(cursor, existing) <= 0) return;
    } else if (existing is RevisionCursor && cursor is RevisionCursor) {
      if (cursor.revision <= existing.revision) return;
    } else if (existing != null) {
      return;
    }

    _cursors[k] = cursor;
  }

  @override
  Future<void> clear({
    required String scopeUid,
    required String entityType,
  }) async {
    _cursors.remove(_key(scopeUid, entityType));
  }

  @override
  Future<void> markPulledAt({
    required String scopeUid,
    required String entityType,
    required DateTime atUtc,
  }) async {}

  @override
  Future<void> markPushedAt({
    required String scopeUid,
    required DateTime atUtc,
  }) async {}
}

class _FakeLocalApplier implements LocalApplier {
  _FakeLocalApplier({required this.apply});

  final LocalApplyResult Function(
    String scopeUid,
    String entityType,
    List<RemoteChange> changes,
  ) apply;

  @override
  Future<LocalApplyResult> applyRemoteChanges({
    required String scopeUid,
    required String entityType,
    required List<RemoteChange> changes,
  }) async {
    return apply(scopeUid, entityType, changes);
  }
}

void main() {
  test('pushOnce marks record dead after max attempts', () async {
    const scopeUid = 'u1';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    final outbox = _InMemoryOutboxStore();
    await outbox.enqueue(
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

    final coordinator = SyncCoordinator(
      outboxStore: outbox,
      remoteGateway: _FakeRemoteGateway(
        pushError: (_) => const SyncError(
          code: SyncErrorCode.network,
          message: 'timeout',
        ),
      ),
      nowUtc: () => now,
      maxAttemptsBeforeDead: 2,
      pushBatchSize: 10,
    );

    final r1 = await coordinator.pushOnce(scopeUid: scopeUid);
    expect(r1.processed, equals(1));
    expect(r1.failed, equals(1));
    expect(r1.dead, equals(0));
    expect(await outbox.backlogCount(scopeUid), equals(1));

    final r2 = await coordinator.pushOnce(scopeUid: scopeUid);
    expect(r2.processed, equals(1));
    expect(r2.failed, equals(1));
    expect(r2.dead, equals(1));
    expect(await outbox.backlogCount(scopeUid), equals(0));
  });

  test('SyncCoordinator updates status on success and failure', () async {
    const scopeUid = 'u1';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    final outbox = _InMemoryOutboxStore();
    await outbox.enqueue(
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

    var shouldFail = true;

    final coordinator = SyncCoordinator(
      outboxStore: outbox,
      remoteGateway: _FakeRemoteGateway(
        pushError: (_) => shouldFail
            ? const SyncError(code: SyncErrorCode.network, message: 'down')
            : null,
      ),
      nowUtc: () => now,
      maxAttemptsBeforeDead: 10,
      pushBatchSize: 10,
    );

    await coordinator.pushOnce(scopeUid: scopeUid);
    expect(coordinator.status.state, equals(SyncRunState.error));
    expect(coordinator.status.lastError?.code, equals(SyncErrorCode.network));

    shouldFail = false;
    await coordinator.pushOnce(scopeUid: scopeUid);
    expect(coordinator.status.state, equals(SyncRunState.idle));
    expect(coordinator.status.lastError, isNull);
  });

  test('pullOnce advances cursor only when apply succeeds', () async {
    const scopeUid = 'u1';
    const entityType = 'layout_template';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    final stateStore = _InMemorySyncStateStore();
    final remote = _FakeRemoteGateway(
      pushError: (_) => null,
      listChangesFn: (scope, type, since, limit) {
        expect(scope, equals(scopeUid));
        expect(type, equals(entityType));
        expect(since, isNull);

        return RemoteChangesPage(
          changes: [
            RemoteChange(
              operationId: 'op_remote_1',
              entityType: entityType,
              entityId: 't1',
              opType: 'upsert',
              cursor: TimestampCursor(
                serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
                tieBreaker: 'op_remote_1',
              ),
              payloadJson: '{"schemaVersion":1}',
              serverTimeUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
            ),
          ],
          nextCursor: TimestampCursor(
            serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
            tieBreaker: 'op_remote_1',
          ),
          hasMore: false,
        );
      },
    );

    final applier = _FakeLocalApplier(
      apply: (scope, type, changes) {
        expect(scope, equals(scopeUid));
        expect(type, equals(entityType));
        expect(changes, hasLength(1));
        return const LocalApplyResult(
          canAdvanceCursor: true,
          appliedCount: 1,
          outcomes: [
            ChangeApplyOutcome(
              operationId: 'op_remote_1',
              entityType: entityType,
              entityId: 't1',
              decision: ChangeApplyDecision.applied,
              reason: null,
              message: null,
            ),
          ],
          lastError: null,
        );
      },
    );

    final coordinator = SyncCoordinator(
      outboxStore: _InMemoryOutboxStore(),
      syncStateStore: stateStore,
      remoteGateway: remote,
      localApplier: applier,
      nowUtc: () => now,
      pullBatchSize: 10,
    );

    final r =
        await coordinator.pullOnce(scopeUid: scopeUid, entityType: entityType);
    expect(r.advanced, isTrue);
    expect(coordinator.status.state, equals(SyncRunState.idle));

    final cursor =
        await stateStore.getCursor(scopeUid: scopeUid, entityType: entityType);
    expect(cursor, isA<TimestampCursor>());
  });

  test('pullOnce does not advance cursor when apply fails', () async {
    const scopeUid = 'u1';
    const entityType = 'layout_template';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    final stateStore = _InMemorySyncStateStore();
    final remote = _FakeRemoteGateway(
      pushError: (_) => null,
      listChangesFn: (_, __, ___, ____) {
        return RemoteChangesPage(
          changes: [
            RemoteChange(
              operationId: 'op_remote_1',
              entityType: entityType,
              entityId: 't1',
              opType: 'upsert',
              cursor: TimestampCursor(
                serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
                tieBreaker: 'op_remote_1',
              ),
              payloadJson: '{"schemaVersion":1}',
              serverTimeUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
            ),
          ],
          nextCursor: TimestampCursor(
            serverUpdatedAtUtc: DateTime.utc(2026, 1, 10, 8, 0, 0),
            tieBreaker: 'op_remote_1',
          ),
          hasMore: false,
        );
      },
    );

    final applier = _FakeLocalApplier(
      apply: (_, __, ___) {
        return const LocalApplyResult(
          canAdvanceCursor: false,
          appliedCount: 0,
          outcomes: [],
          lastError: SyncError(code: SyncErrorCode.invalidData, message: 'bad'),
        );
      },
    );

    final coordinator = SyncCoordinator(
      outboxStore: _InMemoryOutboxStore(),
      syncStateStore: stateStore,
      remoteGateway: remote,
      localApplier: applier,
      nowUtc: () => now,
      pullBatchSize: 10,
    );

    final r =
        await coordinator.pullOnce(scopeUid: scopeUid, entityType: entityType);
    expect(r.advanced, isFalse);
    expect(r.lastError, isNotNull);
    expect(coordinator.status.state, equals(SyncRunState.error));

    final cursor =
        await stateStore.getCursor(scopeUid: scopeUid, entityType: entityType);
    expect(cursor, isNull);
  });

  test('SyncConfigurationManager loads defaults and can persist updates',
      () async {
    final storage = InMemorySyncConfigurationStorage();
    final manager = SyncConfigurationManager(storage: storage);

    final first = await manager.load(writeBackIfMissing: true);
    expect(first.pushBatchSize, equals(50));
    expect(first.pullBatchSize, equals(50));
    expect(first.pullEntityTypes, isEmpty);

    final rawAfterDefault = await storage.read();
    expect(rawAfterDefault, isNotNull);
    expect(rawAfterDefault, contains('"pushBatchSize"'));

    await manager.update(
      (c) => c.copyWith(
        pushBatchSize: 10,
        pullBatchSize: 20,
        pushInterval: const Duration(milliseconds: 1500),
        pullEntityTypes: const ['layout_template', 'skill'],
      ),
      persist: true,
    );

    final manager2 = SyncConfigurationManager(storage: storage);
    final loaded = await manager2.load(writeBackIfMissing: false);
    expect(loaded.pushBatchSize, equals(10));
    expect(loaded.pullBatchSize, equals(20));
    expect(loaded.pushInterval, equals(const Duration(milliseconds: 1500)));
    expect(loaded.pullEntityTypes,
        containsAll(<String>['layout_template', 'skill']));
  });

  test('SyncConfigurationManager can load and persist YAML config', () async {
    final dir = await Directory.systemTemp.createTemp('persistence_core_yaml_');
    try {
      final filePath = '${dir.path}/sync_configuration.yaml';
      final storage = YamlFileSyncConfigurationStorage(filePath: filePath);
      final manager = SyncConfigurationManager(
        storage: storage,
        codec: YamlSyncConfigurationCodec(),
      );

      final first = await manager.load(writeBackIfMissing: true);
      expect(first.pushBatchSize, equals(50));

      final rawAfterDefault = await File(filePath).readAsString();
      expect(rawAfterDefault, contains('sync:'));
      expect(rawAfterDefault, contains('  pushBatchSize: 50'));

      await manager.update(
        (c) => c.copyWith(
          pushBatchSize: 7,
          pullEntityTypes: const ['layout_template'],
        ),
        persist: true,
      );

      final rawAfterUpdate = await File(filePath).readAsString();
      expect(rawAfterUpdate, contains('  pushBatchSize: 7'));
      expect(rawAfterUpdate, contains('    - layout_template'));

      final manager2 = SyncConfigurationManager(
        storage: storage,
        codec: YamlSyncConfigurationCodec(),
      );
      final loaded = await manager2.load(writeBackIfMissing: false);
      expect(loaded.pushBatchSize, equals(7));
      expect(loaded.pullEntityTypes, equals(const ['layout_template']));
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('SyncConfigurationManager emits log events', () async {
    final sink = InMemoryLogSink();
    final logger = SyncLogger(sink: sink, minLevel: SyncLogLevel.debug);

    final storage = InMemorySyncConfigurationStorage();
    final manager = SyncConfigurationManager(
      storage: storage,
      logger: logger,
    );

    await manager.load(writeBackIfMissing: true);
    await manager.update((c) => c.copyWith(pushBatchSize: 9), persist: true);

    final events = sink.records.map((r) => r.event).toList(growable: false);
    expect(events, contains('sync_config_load_start'));
    expect(events, contains('sync_config_load_missing'));
    expect(events, contains('sync_config_save_success'));
    expect(events, contains('sync_config_update'));
  });

  test('SyncRuntime can disable push', () async {
    const scopeUid = 'public';
    final now = DateTime.utc(2026, 1, 10, 9, 0, 0);

    final outbox = _InMemoryOutboxStore();
    final coordinator = SyncCoordinator(
      outboxStore: outbox,
      remoteGateway: _FakeRemoteGateway(
        pushError: (_) => throw StateError('push should not be called'),
      ),
      nowUtc: () => now,
      maxAttemptsBeforeDead: 10,
      pushBatchSize: 10,
    );

    final runtime = SyncRuntime(
      coordinator: coordinator,
      enablePush: false,
      pushInterval: const Duration(milliseconds: 10),
      pullInterval: const Duration(milliseconds: 10),
      minBackoff: const Duration(milliseconds: 1),
      maxBackoff: const Duration(milliseconds: 10),
      nowUtc: () => now,
    );

    await runtime.start(scopeUid: scopeUid);
    await runtime.triggerPush();
    await runtime.setOnline(false);
    await runtime.setOnline(true);
    await runtime.stop();
    await runtime.dispose();
  });
}
