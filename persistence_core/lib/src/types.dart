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
      scopeUid:
          identical(scopeUid, _unset) ? this.scopeUid : scopeUid as String?,
      backlogCount: identical(backlogCount, _unset)
          ? this.backlogCount
          : backlogCount as int?,
      deadCount:
          identical(deadCount, _unset) ? this.deadCount : deadCount as int?,
      lastSuccessAtUtc: identical(lastSuccessAtUtc, _unset)
          ? this.lastSuccessAtUtc
          : lastSuccessAtUtc as DateTime?,
      lastError: identical(lastError, _unset)
          ? this.lastError
          : lastError as SyncError?,
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

class OutboxRecord {
  const OutboxRecord({
    required this.operationId,
    required this.scopeUid,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.payloadJson,
    required this.createdAtUtc,
    required this.attempt,
  });

  final String operationId;
  final String scopeUid;
  final String entityType;
  final String entityId;
  final String opType;
  final String payloadJson;
  final DateTime createdAtUtc;
  final int attempt;

  OutboxRecord copyWith({
    String? operationId,
    String? scopeUid,
    String? entityType,
    String? entityId,
    String? opType,
    String? payloadJson,
    DateTime? createdAtUtc,
    int? attempt,
  }) {
    return OutboxRecord(
      operationId: operationId ?? this.operationId,
      scopeUid: scopeUid ?? this.scopeUid,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      opType: opType ?? this.opType,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      attempt: attempt ?? this.attempt,
    );
  }
}

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
