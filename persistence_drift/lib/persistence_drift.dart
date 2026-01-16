import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';

part 'persistence_drift.g.dart';

@DataClassName('OutboxRecordRow')
class OutboxRecords extends Table {
  @override
  String get tableName => 't_outbox';

  TextColumn get operationId => text().named('operation_id')();
  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  TextColumn get opType => text().named('op_type')();

  TextColumn get payloadJson => text().named('payload_json')();
  TextColumn get payloadSummary => text().nullable().named('payload_summary')();
  TextColumn get payloadHash => text().nullable().named('payload_hash')();

  DateTimeColumn get createdAtUtc => dateTime().named('created_at_utc')();
  IntColumn get attempt =>
      integer().withDefault(const Constant(0)).named('attempt')();
  TextColumn get status =>
      text().withDefault(const Constant('pending')).named('status')();

  TextColumn get lastErrorCode => text().nullable().named('last_error_code')();
  TextColumn get lastErrorMessage =>
      text().nullable().named('last_error_message')();
  DateTimeColumn get lastAttemptAtUtc =>
      dateTime().nullable().named('last_attempt_at_utc')();
  DateTimeColumn get succeededAtUtc =>
      dateTime().nullable().named('succeeded_at_utc')();

  @override
  Set<Column> get primaryKey => {operationId};

  List<Index> get indexes => [
        Index(
          'idx_outbox_scope_status_created',
          'CREATE INDEX idx_outbox_scope_status_created ON t_outbox (scope_uid, status, created_at_utc);',
        ),
        Index(
          'idx_outbox_scope_status',
          'CREATE INDEX idx_outbox_scope_status ON t_outbox (scope_uid, status);',
        ),
      ];
}

@DataClassName('SyncStateRow')
class SyncStates extends Table {
  @override
  String get tableName => 't_sync_state';

  TextColumn get scopeUid => text().named('scope_uid')();
  TextColumn get entityType => text().named('entity_type')();

  TextColumn get cursorType => text().named('cursor_type')();
  IntColumn get revision => integer().nullable().named('revision')();
  DateTimeColumn get serverUpdatedAtUtc =>
      dateTime().nullable().named('server_updated_at_utc')();
  TextColumn get tieBreaker => text().nullable().named('tie_breaker')();

  DateTimeColumn get cursorUpdatedAtUtc =>
      dateTime().named('cursor_updated_at_utc')();
  DateTimeColumn get lastPulledAtUtc =>
      dateTime().nullable().named('last_pulled_at_utc')();
  DateTimeColumn get lastPushedAtUtc =>
      dateTime().nullable().named('last_pushed_at_utc')();

  @override
  Set<Column> get primaryKey => {scopeUid, entityType};

  List<Index> get indexes => [
        Index(
          'idx_sync_state_scope',
          'CREATE INDEX idx_sync_state_scope ON t_sync_state (scope_uid);',
        ),
      ];
}

@DriftAccessor(tables: [OutboxRecords])
class OutboxRecordsDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$OutboxRecordsDaoMixin {
  OutboxRecordsDao(this.db) : super(db);

  final PersistenceDriftDatabase db;

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

  Future<List<OutboxRecordRow>> listRetryable({required String scopeUid}) {
    return (select(db.outboxRecords)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) &
                (t.status.equals('pending') | t.status.equals('failed')),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAtUtc)]))
        .get();
  }

  Future<void> deleteByScope({required String scopeUid}) async {
    await (delete(db.outboxRecords)..where((t) => t.scopeUid.equals(scopeUid)))
        .go();
  }

  Future<void> enqueueMany(List<OutboxRecordsCompanion> companions) async {
    if (companions.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(db.outboxRecords, companions);
    });
  }

  Future<int> backlogCount(String scopeUid) async {
    final countExp = db.outboxRecords.operationId.count();
    final row = await (selectOnly(db.outboxRecords)
          ..addColumns([countExp])
          ..where(
            db.outboxRecords.scopeUid.equals(scopeUid) &
                (db.outboxRecords.status.equals('pending') |
                    db.outboxRecords.status.equals('failed')),
          ))
        .getSingle();
    return row.read(countExp) ?? 0;
  }

  Stream<int> watchBacklogCount(String scopeUid) {
    final countExp = db.outboxRecords.operationId.count();
    return (selectOnly(db.outboxRecords)
          ..addColumns([countExp])
          ..where(
            db.outboxRecords.scopeUid.equals(scopeUid) &
                (db.outboxRecords.status.equals('pending') |
                    db.outboxRecords.status.equals('failed')),
          ))
        .watchSingle()
        .map((row) => row.read(countExp) ?? 0);
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
    await (update(db.outboxRecords)
          ..where((t) => t.operationId.equals(operationId)))
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
    await (update(db.outboxRecords)
          ..where((t) => t.operationId.equals(operationId)))
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

@DriftAccessor(tables: [SyncStates])
class SyncStatesDao extends DatabaseAccessor<PersistenceDriftDatabase>
    with _$SyncStatesDaoMixin {
  SyncStatesDao(this.db) : super(db);

  final PersistenceDriftDatabase db;

  int _compareTimestampCursor({
    required DateTime serverUpdatedAtUtcA,
    required String tieBreakerA,
    required DateTime serverUpdatedAtUtcB,
    required String tieBreakerB,
  }) {
    final tsCmp = serverUpdatedAtUtcA.compareTo(serverUpdatedAtUtcB);
    if (tsCmp != 0) return tsCmp;
    return tieBreakerA.compareTo(tieBreakerB);
  }

  Future<void> setTimestampCursorIfNewer({
    required String scopeUid,
    required String entityType,
    required DateTime serverUpdatedAtUtc,
    required String tieBreaker,
    required DateTime atUtc,
  }) async {
    await db.transaction(() async {
      final existing = await find(scopeUid: scopeUid, entityType: entityType);
      if (existing != null &&
          existing.cursorType == 'timestamp' &&
          existing.serverUpdatedAtUtc != null &&
          existing.tieBreaker != null) {
        final cmp = _compareTimestampCursor(
          serverUpdatedAtUtcA: serverUpdatedAtUtc,
          tieBreakerA: tieBreaker,
          serverUpdatedAtUtcB: existing.serverUpdatedAtUtc!,
          tieBreakerB: existing.tieBreaker!,
        );
        if (cmp <= 0) return;
      }

      await upsert(
        SyncStatesCompanion.insert(
          scopeUid: scopeUid,
          entityType: entityType,
          cursorType: 'timestamp',
          serverUpdatedAtUtc: Value(serverUpdatedAtUtc),
          tieBreaker: Value(tieBreaker),
          cursorUpdatedAtUtc: atUtc,
          revision: const Value(null),
          lastPulledAtUtc: const Value(null),
          lastPushedAtUtc: const Value(null),
        ),
      );
    });
  }

  Future<void> setRevisionCursorIfNewer({
    required String scopeUid,
    required String entityType,
    required int revision,
    required DateTime atUtc,
  }) async {
    await db.transaction(() async {
      final existing = await find(scopeUid: scopeUid, entityType: entityType);
      if (existing != null &&
          existing.cursorType == 'revision' &&
          existing.revision != null) {
        if (revision <= existing.revision!) return;
      }

      await upsert(
        SyncStatesCompanion.insert(
          scopeUid: scopeUid,
          entityType: entityType,
          cursorType: 'revision',
          revision: Value(revision),
          serverUpdatedAtUtc: const Value(null),
          tieBreaker: const Value(null),
          cursorUpdatedAtUtc: atUtc,
          lastPulledAtUtc: const Value(null),
          lastPushedAtUtc: const Value(null),
        ),
      );
    });
  }

  Future<SyncStateRow?> find({
    required String scopeUid,
    required String entityType,
  }) {
    return (select(db.syncStates)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) & t.entityType.equals(entityType),
          ))
        .getSingleOrNull();
  }

  Future<void> upsert(SyncStatesCompanion companion) async {
    await into(db.syncStates).insertOnConflictUpdate(companion);
  }

  Future<void> clear({
    required String scopeUid,
    required String entityType,
  }) async {
    await (delete(db.syncStates)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) & t.entityType.equals(entityType),
          ))
        .go();
  }

  Future<void> markPulledAt({
    required String scopeUid,
    required String entityType,
    required DateTime atUtc,
  }) async {
    await (update(db.syncStates)
          ..where(
            (t) =>
                t.scopeUid.equals(scopeUid) & t.entityType.equals(entityType),
          ))
        .write(SyncStatesCompanion(lastPulledAtUtc: Value(atUtc)));
  }

  Future<void> markPushedAt({
    required String scopeUid,
    required DateTime atUtc,
  }) async {
    await (update(db.syncStates)..where((t) => t.scopeUid.equals(scopeUid)))
        .write(SyncStatesCompanion(lastPushedAtUtc: Value(atUtc)));
  }
}

@DriftDatabase(
  tables: [OutboxRecords, SyncStates],
  daos: [OutboxRecordsDao, SyncStatesDao],
)
class PersistenceDriftDatabase extends _$PersistenceDriftDatabase {
  PersistenceDriftDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}

/// Drift/SQLite implementation of [OutboxStore].
///
/// 功能说明：
/// - 负责 outbox 入队、批量读取、状态流转（success/failed/dead）与计数查询。
/// - 通过 [SyncLogger] 输出结构化埋点，便于定位 outbox 积压、失败率与耗时。
class DriftOutboxStore implements OutboxStore {
  /// Creates a Drift-backed [OutboxStore].
  ///
  /// 功能说明：
  /// - 为同步引擎提供 Outbox 的 Drift/SQLite 实现。
  /// - 通过可注入的 [SyncLogger] 输出结构化埋点，便于开发调试与生产观测。
  ///
  /// 参数说明：
  /// - [dao]：OutboxRecords 的 DAO。
  /// - [logger]：可选日志器；未传入则为 no-op（生产可按需注入 sink）。
  DriftOutboxStore({required OutboxRecordsDao dao, SyncLogger? logger})
      : _dao = dao,
        _logger = logger ?? SyncLogger.noop();

  final OutboxRecordsDao _dao;
  final SyncLogger _logger;

  /// Redacts potentially sensitive identifiers for production logs.
  ///
  /// 功能说明：
  /// - 用于减少在生产环境中暴露 scopeUid/entityId 等信息的风险。
  ///
  /// 参数说明：
  /// - [value]：原始标识。
  ///
  /// 返回值：
  /// - 脱敏后的字符串。
  String _redactId(String value) {
    if (value.isEmpty) return '***';
    if (value.length <= 6) return '***';
    return '${value.substring(0, 3)}…${value.substring(value.length - 3)}';
  }

  /// Returns a safe-to-log error summary.
  ///
  /// 功能说明：
  /// - 避免将异常对象原样写入日志，降低在生产环境中泄露敏感信息的风险。
  ///
  /// 参数说明：
  /// - [error]：捕获到的异常。
  ///
  /// 返回值：
  /// - 可用于日志采集的精简信息。
  Object _errorSummary(Object error) {
    return <String, Object?>{
      'type': error.runtimeType.toString(),
    };
  }

  OutboxRecord _mapRow(OutboxRecordRow row) {
    return OutboxRecord(
      operationId: row.operationId,
      scopeUid: row.scopeUid,
      entityType: row.entityType,
      entityId: row.entityId,
      opType: row.opType,
      payloadJson: row.payloadJson,
      createdAtUtc: row.createdAtUtc.toUtc(),
      attempt: row.attempt,
    );
  }

  /// Enqueues one outbox record.
  ///
  /// 功能说明：
  /// - 将业务写入转换为 outbox 记录（pending），供后续 push 消费。
  ///
  /// 参数说明：
  /// - [record]：待入队的 outbox 记录。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> enqueue(OutboxRecord record) async {
    final sw = Stopwatch()..start();
    _logger.debug(
      'drift_outbox_enqueue_start',
      data: <String, Object?>{
        'operationId': record.operationId,
        'scopeUid': _redactId(record.scopeUid),
        'entityType': record.entityType,
        'entityId': _redactId(record.entityId),
        'opType': record.opType,
        'attempt': record.attempt,
      },
    );

    try {
      await _dao.enqueue(
        OutboxRecordsCompanion.insert(
          operationId: record.operationId,
          scopeUid: record.scopeUid,
          entityType: record.entityType,
          entityId: record.entityId,
          opType: record.opType,
          payloadJson: record.payloadJson,
          createdAtUtc: record.createdAtUtc,
          attempt: Value(record.attempt),
          payloadSummary: const Value(null),
          payloadHash: const Value(null),
        ),
      );

      _logger.debug(
        'drift_outbox_enqueue_success',
        data: <String, Object?>{
          'operationId': record.operationId,
          'durationMs': sw.elapsedMilliseconds,
        },
      );
    } catch (e, st) {
      _logger.error(
        'drift_outbox_enqueue_error',
        data: <String, Object?>{
          'operationId': record.operationId,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Peeks a batch of pending outbox records.
  ///
  /// 功能说明：
  /// - 读取待 push 的记录（通常按 createdAt 排序）。
  /// - 只读取，不更新状态。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [limit]：最大返回数量。
  ///
  /// 返回值：
  /// - outbox 记录列表。
  @override
  Future<List<OutboxRecord>> peekBatch({
    required String scopeUid,
    required int limit,
  }) async {
    final sw = Stopwatch()..start();
    _logger.trace(
      'drift_outbox_peek_batch_start',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'limit': limit,
      },
    );

    try {
      final rows = await _dao.peekBatch(scopeUid: scopeUid, limit: limit);
      final out = rows.map(_mapRow).toList(growable: false);
      _logger.trace(
        'drift_outbox_peek_batch_success',
        data: <String, Object?>{
          'scopeUid': _redactId(scopeUid),
          'requested': limit,
          'returned': out.length,
          'durationMs': sw.elapsedMilliseconds,
        },
      );
      return out;
    } catch (e, st) {
      _logger.error(
        'drift_outbox_peek_batch_error',
        data: <String, Object?>{
          'scopeUid': _redactId(scopeUid),
          'limit': limit,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Marks one outbox record as succeeded.
  ///
  /// 功能说明：
  /// - push 成功后将记录置为 success 并写入成功时间。
  ///
  /// 参数说明：
  /// - [operationId]：操作 id。
  /// - [atUtc]：成功时间（UTC）。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> markSuccess({
    required String operationId,
    required DateTime atUtc,
  }) {
    _logger.debug(
      'drift_outbox_mark_success',
      data: <String, Object?>{
        'operationId': operationId,
        'atUtc': atUtc.toUtc().toIso8601String(),
      },
    );
    return _dao.markSuccess(operationId: operationId, atUtc: atUtc);
  }

  /// Marks one outbox record as failed (or dead).
  ///
  /// 功能说明：
  /// - push 失败时记录错误信息与重试次数；达到阈值时标记为 dead。
  ///
  /// 参数说明：
  /// - [operationId]：操作 id。
  /// - [attempt]：本次失败后 attempt 值。
  /// - [errorCode]：错误码（可用于聚合统计）。
  /// - [errorMessage]：错误信息（注意：该值会写入本地 DB）。
  /// - [atUtc]：失败时间（UTC）。
  /// - [isDead]：是否进入死信。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> markFailed({
    required String operationId,
    required int attempt,
    required String errorCode,
    required String errorMessage,
    required DateTime atUtc,
    required bool isDead,
  }) {
    _logger.debug(
      'drift_outbox_mark_failed',
      data: <String, Object?>{
        'operationId': operationId,
        'attempt': attempt,
        'errorCode': errorCode,
        'isDead': isDead,
        'atUtc': atUtc.toUtc().toIso8601String(),
      },
    );
    return _dao.markFailed(
      operationId: operationId,
      attempt: attempt,
      errorCode: errorCode,
      errorMessage: errorMessage,
      atUtc: atUtc,
      isDead: isDead,
    );
  }

  /// Returns count of pending/failed (non-dead) records for a scope.
  ///
  /// 功能说明：
  /// - 用于观测 backlog 规模与同步压力。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  ///
  /// 返回值：
  /// - backlog 数量。
  @override
  Future<int> backlogCount(String scopeUid) {
    _logger.trace(
      'drift_outbox_backlog_count',
      data: <String, Object?>{'scopeUid': _redactId(scopeUid)},
    );
    return _dao.backlogCount(scopeUid);
  }

  @override
  Stream<int> watchBacklogCount(String scopeUid) {
    _logger.trace(
      'drift_outbox_watch_backlog_count',
      data: <String, Object?>{'scopeUid': _redactId(scopeUid)},
    );
    return _dao.watchBacklogCount(scopeUid).distinct();
  }

  /// Returns count of dead-letter records for a scope.
  ///
  /// 功能说明：
  /// - 用于观测不可恢复失败的积压。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  ///
  /// 返回值：
  /// - dead 数量。
  @override
  Future<int> deadCount(String scopeUid) {
    _logger.trace(
      'drift_outbox_dead_count',
      data: <String, Object?>{'scopeUid': _redactId(scopeUid)},
    );
    return _dao.deadCount(scopeUid);
  }
}

/// Drift/SQLite implementation of [SyncStateStore].
///
/// 功能说明：
/// - 负责保存与推进 pull cursor（timestamp/revision）。
/// - 记录最近 pulledAt/pushedAt 时间，用于观测与诊断。
/// - 通过 [SyncLogger] 输出结构化埋点。
class DriftSyncStateStore implements SyncStateStore {
  /// Creates a Drift-backed [SyncStateStore].
  ///
  /// 功能说明：
  /// - 保存并推进 pull cursor、记录最近 pull/push 时间。
  /// - 通过可注入的 [SyncLogger] 输出结构化埋点。
  ///
  /// 参数说明：
  /// - [dao]：SyncStates 的 DAO。
  /// - [logger]：可选日志器；未传入则为 no-op。
  DriftSyncStateStore({required SyncStatesDao dao, SyncLogger? logger})
      : _dao = dao,
        _logger = logger ?? SyncLogger.noop();

  final SyncStatesDao _dao;
  final SyncLogger _logger;

  /// Redacts potentially sensitive identifiers for production logs.
  ///
  /// 功能说明：
  /// - 用于减少在生产环境中暴露 scopeUid/entityType 的风险。
  ///
  /// 参数说明：
  /// - [value]：原始标识。
  ///
  /// 返回值：
  /// - 脱敏后的字符串。
  String _redactId(String value) {
    if (value.isEmpty) return '***';
    if (value.length <= 6) return '***';
    return '${value.substring(0, 3)}…${value.substring(value.length - 3)}';
  }

  /// Returns current pull cursor for one entity type.
  ///
  /// 功能说明：
  /// - 读取上次 pull 的游标；用于从远端增量拉取。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  ///
  /// 返回值：
  /// - 游标（可能为 null）。
  @override
  Future<PullCursor?> getCursor({
    required String scopeUid,
    required String entityType,
  }) async {
    final sw = Stopwatch()..start();
    final row = await _dao.find(scopeUid: scopeUid, entityType: entityType);
    PullCursor? out;
    String cursorType = 'none';

    if (row != null) {
      cursorType = row.cursorType;

      if (row.cursorType == 'timestamp' &&
          row.serverUpdatedAtUtc != null &&
          row.tieBreaker != null) {
        out = TimestampCursor(
          serverUpdatedAtUtc: row.serverUpdatedAtUtc!.toUtc(),
          tieBreaker: row.tieBreaker!,
        );
      } else if (row.cursorType == 'revision' && row.revision != null) {
        out = RevisionCursor(revision: row.revision!);
      } else {
        out = null;
      }
    }

    _logger.trace(
      'drift_sync_state_get_cursor',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'entityType': entityType,
        'cursorType': cursorType,
        'returned': out?.runtimeType.toString(),
        'durationMs': sw.elapsedMilliseconds,
      },
    );

    return out;
  }

  /// Advances cursor if newer.
  ///
  /// 功能说明：
  /// - 只允许 cursor 单调递增，避免回退导致重复拉取。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  /// - [cursor]：候选新游标。
  /// - [atUtc]：更新时间（UTC）。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> setCursorIfNewer({
    required String scopeUid,
    required String entityType,
    required PullCursor cursor,
    required DateTime atUtc,
  }) {
    _logger.debug(
      'drift_sync_state_set_cursor_if_newer',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'entityType': entityType,
        'cursorType': cursor.runtimeType.toString(),
        'atUtc': atUtc.toUtc().toIso8601String(),
      },
    );
    if (cursor is TimestampCursor) {
      return _dao.setTimestampCursorIfNewer(
        scopeUid: scopeUid,
        entityType: entityType,
        serverUpdatedAtUtc: cursor.serverUpdatedAtUtc,
        tieBreaker: cursor.tieBreaker,
        atUtc: atUtc,
      );
    }

    if (cursor is RevisionCursor) {
      return _dao.setRevisionCursorIfNewer(
        scopeUid: scopeUid,
        entityType: entityType,
        revision: cursor.revision,
        atUtc: atUtc,
      );
    }

    throw UnsupportedError('Unsupported cursor type: ${cursor.runtimeType}');
  }

  /// Clears sync state for one entity type.
  ///
  /// 功能说明：
  /// - 用于重置 cursor（例如需要全量重拉）。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> clear({
    required String scopeUid,
    required String entityType,
  }) {
    _logger.warn(
      'drift_sync_state_clear',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'entityType': entityType,
      },
    );
    return _dao.clear(scopeUid: scopeUid, entityType: entityType);
  }

  /// Marks last pulled timestamp for a scope + entity type.
  ///
  /// 功能说明：
  /// - 仅用于观测与诊断，不影响 cursor。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  /// - [atUtc]：拉取完成时间（UTC）。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> markPulledAt({
    required String scopeUid,
    required String entityType,
    required DateTime atUtc,
  }) {
    _logger.debug(
      'drift_sync_state_mark_pulled_at',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'entityType': entityType,
        'atUtc': atUtc.toUtc().toIso8601String(),
      },
    );
    return _dao.markPulledAt(
        scopeUid: scopeUid, entityType: entityType, atUtc: atUtc);
  }

  /// Marks last pushed timestamp for a scope.
  ///
  /// 功能说明：
  /// - 仅用于观测与诊断，不影响 outbox 逻辑。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [atUtc]：push 完成时间（UTC）。
  ///
  /// 返回值：
  /// - 无。
  @override
  Future<void> markPushedAt({
    required String scopeUid,
    required DateTime atUtc,
  }) {
    _logger.debug(
      'drift_sync_state_mark_pushed_at',
      data: <String, Object?>{
        'scopeUid': _redactId(scopeUid),
        'atUtc': atUtc.toUtc().toIso8601String(),
      },
    );
    return _dao.markPushedAt(scopeUid: scopeUid, atUtc: atUtc);
  }
}
