import 'package:common/database/app_database.dart';
import 'package:common/database/daos/outbox_records_dao.dart';
import 'package:common/database/daos/sync_states_dao.dart';

enum SyncErrorCode {
  network,
  permission,
  conflict,
  invalidData,
  unknown,
}

class SyncError {
  const SyncError({
    required this.code,
    required this.message,
  });

  final SyncErrorCode code;
  final String message;
}

typedef RemotePushFn = Future<SyncError?> Function(OutboxRecordRow record);

class OutboxPushRunResult {
  const OutboxPushRunResult({
    required this.processed,
    required this.succeeded,
    required this.failed,
    required this.dead,
    required this.lastError,
  });

  final int processed;
  final int succeeded;
  final int failed;
  final int dead;
  final SyncError? lastError;

  bool get hasError => lastError != null;
}

enum SyncRunState {
  stopped,
  idle,
  syncing,
  error,
}

class SyncStatus {
  const SyncStatus({
    required this.state,
    required this.scopeUid,
    required this.backlogCount,
    required this.deadCount,
    required this.lastSuccessAtUtc,
    required this.lastError,
    this.lastPushAtUtc,
    this.lastPullAtUtc,
    this.lastPullEntityType,
    this.lastPullOutcomes,
  });

  final SyncRunState state;
  final String? scopeUid;
  final int? backlogCount;
  final int? deadCount;
  final DateTime? lastSuccessAtUtc;
  final SyncError? lastError;
  final DateTime? lastPushAtUtc;
  final DateTime? lastPullAtUtc;
  final String? lastPullEntityType;
  final List<ChangeApplyOutcome>? lastPullOutcomes;

  static const Object _unset = Object();

  SyncStatus copyWith({
    SyncRunState? state,
    Object? scopeUid = _unset,
    Object? backlogCount = _unset,
    Object? deadCount = _unset,
    Object? lastSuccessAtUtc = _unset,
    Object? lastError = _unset,
    Object? lastPushAtUtc = _unset,
    Object? lastPullAtUtc = _unset,
    Object? lastPullEntityType = _unset,
    Object? lastPullOutcomes = _unset,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      scopeUid: identical(scopeUid, _unset) ? this.scopeUid : scopeUid as String?,
      backlogCount: identical(backlogCount, _unset)
          ? this.backlogCount
          : backlogCount as int?,
      deadCount:
          identical(deadCount, _unset) ? this.deadCount : deadCount as int?,
      lastSuccessAtUtc: identical(lastSuccessAtUtc, _unset)
          ? this.lastSuccessAtUtc
          : lastSuccessAtUtc as DateTime?,
      lastError:
          identical(lastError, _unset) ? this.lastError : lastError as SyncError?,
      lastPushAtUtc: identical(lastPushAtUtc, _unset)
          ? this.lastPushAtUtc
          : lastPushAtUtc as DateTime?,
      lastPullAtUtc: identical(lastPullAtUtc, _unset)
          ? this.lastPullAtUtc
          : lastPullAtUtc as DateTime?,
      lastPullEntityType: identical(lastPullEntityType, _unset)
          ? this.lastPullEntityType
          : lastPullEntityType as String?,
      lastPullOutcomes: identical(lastPullOutcomes, _unset)
          ? this.lastPullOutcomes
          : lastPullOutcomes as List<ChangeApplyOutcome>?,
    );
  }
}

class OutboxPusher {
  OutboxPusher({
    required OutboxRecordsDao outboxDao,
    required RemotePushFn remotePush,
    required DateTime Function() nowUtc,
    int batchSize = 50,
    int maxAttemptsBeforeDead = 10,
  })  : _outboxDao = outboxDao,
        _remotePush = remotePush,
        _nowUtc = nowUtc,
        _batchSize = batchSize,
        _maxAttemptsBeforeDead = maxAttemptsBeforeDead;

  final OutboxRecordsDao _outboxDao;
  final RemotePushFn _remotePush;
  final DateTime Function() _nowUtc;
  final int _batchSize;
  final int _maxAttemptsBeforeDead;

  Future<OutboxPushRunResult> runOnce({required String scopeUid}) async {
    final batch = await _outboxDao.peekBatch(
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
      final error = await _remotePush(record);

      if (error == null) {
        await _outboxDao.markSuccess(
          operationId: record.operationId,
          atUtc: atUtc,
        );
        succeeded += 1;
      } else {
        lastError = error;
        failed += 1;

        final isDead = nextAttempt >= _maxAttemptsBeforeDead;
        if (isDead) dead += 1;

        await _outboxDao.markFailed(
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

abstract class PullCursor {
  const PullCursor();
}

class TimestampCursor extends PullCursor {
  const TimestampCursor({
    required this.serverUpdatedAtUtc,
    required this.tieBreaker,
  });

  final DateTime serverUpdatedAtUtc;
  final String tieBreaker;
}

class RevisionCursor extends PullCursor {
  const RevisionCursor({required this.revision});

  final int revision;
}

class RemoteChange {
  const RemoteChange({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.cursor,
    required this.payloadJson,
    required this.serverTimeUtc,
  });

  final String operationId;
  final String entityType;
  final String entityId;
  final String opType;
  final PullCursor cursor;
  final String payloadJson;
  final DateTime? serverTimeUtc;
}

class RemoteChangesPage {
  const RemoteChangesPage({
    required this.changes,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<RemoteChange> changes;
  final PullCursor? nextCursor;
  final bool hasMore;
}

typedef RemoteListChangesFn = Future<RemoteChangesPage> Function({
  required String scopeUid,
  required String entityType,
  required PullCursor? sinceCursor,
  required int limit,
});

enum ChangeApplyDecision {
  applied,
  skipped,
  failed,
}

enum SkipReasonCode {
  alreadyApplied,
  olderThanLocal,
  conflictLwwLost,
  invalidPayload,
  unknown,
}

class ChangeApplyOutcome {
  const ChangeApplyOutcome({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.decision,
    required this.reason,
    required this.message,
  });

  final String operationId;
  final String entityType;
  final String entityId;
  final ChangeApplyDecision decision;
  final SkipReasonCode? reason;
  final String? message;
}

class LocalApplyResult {
  const LocalApplyResult({
    required this.canAdvanceCursor,
    required this.appliedCount,
    required this.outcomes,
    required this.lastError,
  });

  final bool canAdvanceCursor;
  final int appliedCount;
  final List<ChangeApplyOutcome> outcomes;
  final SyncError? lastError;
}

typedef LocalApplyFn = Future<LocalApplyResult> Function({
  required String scopeUid,
  required String entityType,
  required List<RemoteChange> changes,
});

class PullRunResult {
  const PullRunResult({
    required this.pages,
    required this.fetched,
    required this.applied,
    required this.skipped,
    required this.advanced,
    required this.outcomes,
    required this.lastError,
  });

  final int pages;
  final int fetched;
  final int applied;
  final int skipped;
  final bool advanced;
  final List<ChangeApplyOutcome> outcomes;
  final SyncError? lastError;

  bool get hasError => lastError != null;
}

class SyncCoordinator {
  SyncCoordinator({
    required OutboxRecordsDao outboxDao,
    required RemotePushFn remotePush,
    required DateTime Function() nowUtc,
    SyncStatesDao? syncStatesDao,
    RemoteListChangesFn? remoteListChanges,
    LocalApplyFn? localApply,
    int pushBatchSize = 50,
    int pullBatchSize = 50,
    int maxAttemptsBeforeDead = 10,
  })  : _outboxDao = outboxDao,
        _syncStatesDao = syncStatesDao,
        _remoteListChanges = remoteListChanges,
        _localApply = localApply,
        _nowUtc = nowUtc,
        _pullBatchSize = pullBatchSize,
        _pusher = OutboxPusher(
          outboxDao: outboxDao,
          remotePush: remotePush,
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

  final OutboxRecordsDao _outboxDao;
  final SyncStatesDao? _syncStatesDao;
  final RemoteListChangesFn? _remoteListChanges;
  final LocalApplyFn? _localApply;
  final DateTime Function() _nowUtc;
  final int _pullBatchSize;
  final OutboxPusher _pusher;
  SyncStatus _status;

  SyncStatus get status => _status;

  Future<OutboxPushRunResult> pushOnce({required String scopeUid}) async {
    _status = _status.copyWith(
      state: SyncRunState.syncing,
      scopeUid: scopeUid,
      backlogCount: await _outboxDao.backlogCount(scopeUid),
      deadCount: await _outboxDao.deadCount(scopeUid),
      lastError: null,
    );

    try {
      final result = await _pusher.runOnce(scopeUid: scopeUid);
      final backlog = await _outboxDao.backlogCount(scopeUid);
      final deadCount = await _outboxDao.deadCount(scopeUid);
      final atUtc = _nowUtc();

      if (!result.hasError) {
        final dao = _syncStatesDao;
        if (dao != null) {
          await dao.markPushedAt(scopeUid: scopeUid, atUtc: atUtc);
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
    } catch (e) {
      _status = _status.copyWith(
        state: SyncRunState.error,
        lastError: SyncError(code: SyncErrorCode.unknown, message: '$e'),
      );
      rethrow;
    }
  }

  PullCursor? _cursorFromRow(SyncStateRow row) {
    switch (row.cursorType) {
      case 'timestamp':
        final ts = row.serverUpdatedAtUtc;
        final tb = row.tieBreaker;
        if (ts == null || tb == null) return null;
        return TimestampCursor(
          serverUpdatedAtUtc: ts.toUtc(),
          tieBreaker: tb,
        );
      case 'revision':
        final rev = row.revision;
        if (rev == null) return null;
        return RevisionCursor(revision: rev);
      default:
        return null;
    }
  }

  Future<void> _storeCursor({
    required String scopeUid,
    required String entityType,
    required PullCursor cursor,
  }) async {
    final dao = _syncStatesDao;
    if (dao == null) return;

    final atUtc = _nowUtc();
    if (cursor is TimestampCursor) {
      await dao.setTimestampCursorIfNewer(
        scopeUid: scopeUid,
        entityType: entityType,
        serverUpdatedAtUtc: cursor.serverUpdatedAtUtc,
        tieBreaker: cursor.tieBreaker,
        atUtc: atUtc,
      );
      return;
    }

    if (cursor is RevisionCursor) {
      await dao.setRevisionCursorIfNewer(
        scopeUid: scopeUid,
        entityType: entityType,
        revision: cursor.revision,
        atUtc: atUtc,
      );
      return;
    }
  }

  Future<PullRunResult> pullOnce({
    required String scopeUid,
    required String entityType,
    int? limit,
    int maxPages = 100,
  }) async {
    final dao = _syncStatesDao;
    final remote = _remoteListChanges;
    final apply = _localApply;

    if (dao == null || remote == null || apply == null) {
      throw StateError('Pull requires syncStatesDao, remoteListChanges, localApply');
    }

    _status = _status.copyWith(
      state: SyncRunState.syncing,
      scopeUid: scopeUid,
      backlogCount: await _outboxDao.backlogCount(scopeUid),
      deadCount: await _outboxDao.deadCount(scopeUid),
      lastPullEntityType: entityType,
      lastPullOutcomes: const [],
      lastError: null,
    );

    final existing = await dao.find(scopeUid: scopeUid, entityType: entityType);
    var cursor = existing == null ? null : _cursorFromRow(existing);

    var pages = 0;
    var fetched = 0;
    var appliedCount = 0;
    var skippedCount = 0;
    var advanced = false;
    final outcomes = <ChangeApplyOutcome>[];
    SyncError? lastError;

    while (pages < maxPages) {
      final page = await remote(
        scopeUid: scopeUid,
        entityType: entityType,
        sinceCursor: cursor,
        limit: limit ?? _pullBatchSize,
      );

      pages += 1;
      fetched += page.changes.length;

      if (page.changes.isEmpty) break;

      final applyResult = await apply(
        scopeUid: scopeUid,
        entityType: entityType,
        changes: page.changes,
      );

      appliedCount += applyResult.appliedCount;
      outcomes.addAll(applyResult.outcomes);
      skippedCount += applyResult.outcomes
          .where((o) => o.decision == ChangeApplyDecision.skipped)
          .length;

      if (!applyResult.canAdvanceCursor || applyResult.lastError != null) {
        lastError = applyResult.lastError ??
            const SyncError(
              code: SyncErrorCode.invalidData,
              message: 'applyRemoteChanges failed',
            );
        break;
      }

      if (page.nextCursor != null) {
        await _storeCursor(
          scopeUid: scopeUid,
          entityType: entityType,
          cursor: page.nextCursor!,
        );
        cursor = page.nextCursor;
        advanced = true;
      }

      if (!page.hasMore) break;
    }

    if (lastError == null) {
      await dao.markPulledAt(
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
      backlogCount: await _outboxDao.backlogCount(scopeUid),
      deadCount: await _outboxDao.deadCount(scopeUid),
      lastSuccessAtUtc: lastError == null ? _nowUtc() : _status.lastSuccessAtUtc,
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
