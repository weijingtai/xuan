import 'ports.dart';
import 'types.dart';

class OutboxPusher {
  OutboxPusher({
    required OutboxStore outboxStore,
    required RemoteGateway remoteGateway,
    required DateTime Function() nowUtc,
    int batchSize = 50,
    int maxAttemptsBeforeDead = 10,
  })  : _outboxStore = outboxStore,
        _remoteGateway = remoteGateway,
        _nowUtc = nowUtc,
        _batchSize = batchSize,
        _maxAttemptsBeforeDead = maxAttemptsBeforeDead;

  final OutboxStore _outboxStore;
  final RemoteGateway _remoteGateway;
  final DateTime Function() _nowUtc;
  final int _batchSize;
  final int _maxAttemptsBeforeDead;

  Future<OutboxPushRunResult> runOnce({required String scopeUid}) async {
    final batch = await _outboxStore.peekBatch(
      scopeUid: scopeUid,
      limit: _batchSize,
    );

    var processed = 0;
    var succeeded = 0;
    var failed = 0;
    var dead = 0;
    SyncError? lastError;

    for (final record in batch) {
      final nextAttempt = record.attempt + 1;
      final atUtc = _nowUtc();
      final error = await _remoteGateway.push(record);

      if (error == null) {
        await _outboxStore.markSuccess(
          operationId: record.operationId,
          atUtc: atUtc,
        );
        succeeded += 1;
      } else {
        lastError = error;
        failed += 1;

        final isDead = nextAttempt >= _maxAttemptsBeforeDead;
        if (isDead) dead += 1;

        await _outboxStore.markFailed(
          operationId: record.operationId,
          attempt: nextAttempt,
          errorCode: error.code.name,
          errorMessage: error.message,
          atUtc: atUtc,
          isDead: isDead,
        );
      }

      processed += 1;
    }

    return OutboxPushRunResult(
      processed: processed,
      succeeded: succeeded,
      failed: failed,
      dead: dead,
      lastError: lastError,
    );
  }
}

class SyncCoordinator {
  SyncCoordinator({
    required OutboxStore outboxStore,
    required RemoteGateway remoteGateway,
    required DateTime Function() nowUtc,
    SyncStateStore? syncStateStore,
    LocalApplier? localApplier,
    int pushBatchSize = 50,
    int pullBatchSize = 50,
    int maxAttemptsBeforeDead = 10,
  })  : _outboxStore = outboxStore,
        _syncStateStore = syncStateStore,
        _remoteGateway = remoteGateway,
        _localApplier = localApplier,
        _nowUtc = nowUtc,
        _pullBatchSize = pullBatchSize,
        _pusher = OutboxPusher(
          outboxStore: outboxStore,
          remoteGateway: remoteGateway,
          nowUtc: nowUtc,
          batchSize: pushBatchSize,
          maxAttemptsBeforeDead: maxAttemptsBeforeDead,
        ),
        _status = const SyncStatus(
          state: SyncRunState.stopped,
          scopeUid: null,
          backlogCount: null,
          deadCount: null,
          lastSuccessAtUtc: null,
          lastError: null,
        );

  final OutboxStore _outboxStore;
  final SyncStateStore? _syncStateStore;
  final RemoteGateway _remoteGateway;
  final LocalApplier? _localApplier;
  final DateTime Function() _nowUtc;
  final int _pullBatchSize;
  final OutboxPusher _pusher;
  SyncStatus _status;

  SyncStatus get status => _status;

  Future<OutboxPushRunResult> pushOnce({required String scopeUid}) async {
    _status = _status.copyWith(
      state: SyncRunState.syncing,
      scopeUid: scopeUid,
      backlogCount: await _outboxStore.backlogCount(scopeUid),
      deadCount: await _outboxStore.deadCount(scopeUid),
      lastError: null,
    );

    final result = await _pusher.runOnce(scopeUid: scopeUid);

    final backlog = await _outboxStore.backlogCount(scopeUid);
    final deadCount = await _outboxStore.deadCount(scopeUid);
    final atUtc = _nowUtc();

    if (!result.hasError) {
      final store = _syncStateStore;
      if (store != null) {
        await store.markPushedAt(scopeUid: scopeUid, atUtc: atUtc);
      }
    }

    _status = _status.copyWith(
      state: result.hasError ? SyncRunState.error : SyncRunState.idle,
      backlogCount: backlog,
      deadCount: deadCount,
      lastSuccessAtUtc: result.hasError ? _status.lastSuccessAtUtc : atUtc,
      lastPushAtUtc: result.hasError ? _status.lastPushAtUtc : atUtc,
      lastError: result.lastError,
    );

    return result;
  }

  int _countSkipped(List<ChangeApplyOutcome> outcomes) {
    var count = 0;
    for (final o in outcomes) {
      if (o.decision == ChangeApplyDecision.skipped) count += 1;
    }
    return count;
  }

  Future<PullRunResult> pullOnce({
    required String scopeUid,
    required String entityType,
    int? limit,
    int maxPages = 100,
  }) async {
    final stateStore = _syncStateStore;
    final applier = _localApplier;

    if (stateStore == null || applier == null) {
      throw StateError('Pull requires syncStateStore and localApplier');
    }

    _status = _status.copyWith(
      state: SyncRunState.syncing,
      scopeUid: scopeUid,
      backlogCount: await _outboxStore.backlogCount(scopeUid),
      deadCount: await _outboxStore.deadCount(scopeUid),
      lastPullEntityType: entityType,
      lastPullOutcomes: const [],
      lastError: null,
    );

    var cursor =
        await stateStore.getCursor(scopeUid: scopeUid, entityType: entityType);

    var pages = 0;
    var fetched = 0;
    var appliedCount = 0;
    var skippedCount = 0;
    var advanced = false;
    final outcomes = <ChangeApplyOutcome>[];
    SyncError? lastError;

    while (pages < maxPages) {
      final page = await _remoteGateway.listChanges(
        scopeUid: scopeUid,
        entityType: entityType,
        sinceCursor: cursor,
        limit: limit ?? _pullBatchSize,
      );

      pages += 1;
      fetched += page.changes.length;

      if (page.changes.isEmpty) break;

      final applyResult = await applier.applyRemoteChanges(
        scopeUid: scopeUid,
        entityType: entityType,
        changes: page.changes,
      );

      appliedCount += applyResult.appliedCount;
      outcomes.addAll(applyResult.outcomes);
      skippedCount += _countSkipped(applyResult.outcomes);

      if (!applyResult.canAdvanceCursor || applyResult.lastError != null) {
        lastError = applyResult.lastError ??
            const SyncError(
              code: SyncErrorCode.invalidData,
              message: 'applyRemoteChanges failed',
            );
        break;
      }

      if (page.nextCursor != null) {
        await stateStore.setCursorIfNewer(
          scopeUid: scopeUid,
          entityType: entityType,
          cursor: page.nextCursor!,
          atUtc: _nowUtc(),
        );
        cursor = page.nextCursor;
        advanced = true;
      }

      if (!page.hasMore) break;
    }

    if (lastError == null) {
      await stateStore.markPulledAt(
        scopeUid: scopeUid,
        entityType: entityType,
        atUtc: _nowUtc(),
      );
    }

    final cappedOutcomes = outcomes.length <= 200
        ? outcomes
        : outcomes.sublist(outcomes.length - 200);

    _status = _status.copyWith(
      state: lastError == null ? SyncRunState.idle : SyncRunState.error,
      backlogCount: await _outboxStore.backlogCount(scopeUid),
      deadCount: await _outboxStore.deadCount(scopeUid),
      lastSuccessAtUtc:
          lastError == null ? _nowUtc() : _status.lastSuccessAtUtc,
      lastPullAtUtc: lastError == null ? _nowUtc() : _status.lastPullAtUtc,
      lastPullEntityType: entityType,
      lastPullOutcomes: cappedOutcomes,
      lastError: lastError,
    );

    return PullRunResult(
      pages: pages,
      fetched: fetched,
      applied: appliedCount,
      skipped: skippedCount,
      advanced: advanced,
      outcomes: outcomes,
      lastError: lastError,
    );
  }
}
