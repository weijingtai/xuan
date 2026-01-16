import 'dart:convert';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:firebase_database/firebase_database.dart';
import 'package:persistence_core/persistence_core.dart';

/// Firebase Realtime Database implementation of [RemoteGateway].
///
/// 功能说明：
/// - 将 [OutboxRecord] push 到 Realtime Database（实体节点 + oplog 节点）。
/// - 从 Realtime Database 按 cursor 增量拉取变更（[RemoteChange]）。
///
/// 设计选择：
/// - 为了在 RTDB 上实现稳定分页，本实现使用 [RevisionCursor]：
///   - 每个 (scopeUid, entityType) 维护一个自增 revision 计数器；
///   - 每次 upsert/softDelete 写入实体时同时写入 revision；
///   - listChanges 使用 orderByChild('revision') + startAt() + limitToFirst()。
///
/// 路径约定：
/// - user：users/{scopeUid}/modules/{module}/{collection}/{entityId}
/// - public：public/{module}/{collection}/{entityId}
/// - oplog：users/{scopeUid}/oplog/{operationId}
///
/// 注意：
/// - public scope 约定为 pull-only；push 会返回 permission 错误。
class FirebaseRealtimeRemoteGateway implements RemoteGateway {
  /// Creates a Realtime Database based gateway.
  ///
  /// 参数说明：
  /// - [database]：FirebaseDatabase 实例。
  /// - [device]：当前设备标识（写入 oplog）。
  /// - [nowUtc]：返回当前 UTC 时间的函数（便于测试/回放）。
  /// - [module]：模块隔离字段。
  /// - [maxAttemptsBeforeDead]：到达该次数后标记 oplog 为 dead（尽力写入远端状态）。
  /// - [logger]：可选日志器；未传入则为 no-op。
  FirebaseRealtimeRemoteGateway({
    required FirebaseDatabase database,
    required DeviceIdentity device,
    required DateTime Function() nowUtc,
    String module = 'persistence_firebase',
    int maxAttemptsBeforeDead = 10,
    SyncLogger? logger,
  })  : _database = database,
        _device = device,
        _nowUtc = nowUtc,
        _module = module,
        _maxAttemptsBeforeDead = maxAttemptsBeforeDead,
        _logger = logger ?? SyncLogger.noop();

  final FirebaseDatabase _database;
  final DeviceIdentity _device;
  final DateTime Function() _nowUtc;
  final String _module;
  final int _maxAttemptsBeforeDead;
  final SyncLogger _logger;

  static const String _publicScopeUid = 'public';

  /// Redacts potentially sensitive identifiers for production logs.
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
  /// 参数说明：
  /// - [error]：捕获到的异常。
  ///
  /// 返回值：
  /// - 可用于日志采集的精简信息。
  Object _errorSummary(Object error) {
    if (error is FirebaseException) {
      return <String, Object?>{
        'type': 'FirebaseException',
        'plugin': error.plugin,
        'code': error.code,
      };
    }
    if (error is _RemotePayloadInvalid) {
      return <String, Object?>{
        'type': '_RemotePayloadInvalid',
        'message': error.message,
      };
    }
    return <String, Object?>{'type': error.runtimeType.toString()};
  }

  /// Maps [FirebaseException] into core [SyncError].
  ///
  /// 参数说明：
  /// - [e]：FirebaseException。
  ///
  /// 返回值：
  /// - 对应的 [SyncError]。
  SyncError _mapFirebaseException(FirebaseException e) {
    final code = e.code;
    if (code == 'permission-denied' || code == 'unauthenticated') {
      return SyncError(
          code: SyncErrorCode.permission, message: e.message ?? code);
    }
    if (code == 'unavailable' || code == 'deadline-exceeded') {
      return SyncError(code: SyncErrorCode.network, message: e.message ?? code);
    }
    if (code == 'failed-precondition') {
      return SyncError(
          code: SyncErrorCode.invalidData, message: e.message ?? code);
    }
    return SyncError(code: SyncErrorCode.unknown, message: e.message ?? code);
  }

  /// Returns collection name by entity type.
  ///
  /// 参数说明：
  /// - [entityType]：实体类型。
  ///
  /// 返回值：
  /// - collection 名称。
  String _collectionNameForEntityType(String entityType) {
    if (entityType == 'layout_template') return 'layout_templates';
    if (entityType == 'divination') return 'divinations';
    if (entityType == 'seeker') return 'seekers';
    if (entityType == 'timing_divination') return 'timing_divinations';
    if (entityType == 'seeker_divination_map')
      return 'seeker_divination_mappers';
    if (entityType == 'seeker_divination_mapper')
      return 'seeker_divination_mappers';
    if (entityType == 'divination_panel_map') return 'divination_panel_mappers';
    if (entityType == 'divination_panel_mapper')
      return 'divination_panel_mappers';
    return entityType;
  }

  /// Returns remote entity reference.
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  /// - [entityId]：实体 id。
  ///
  /// 返回值：
  /// - 对应的实体引用。
  DatabaseReference _entityRef({
    required String scopeUid,
    required String entityType,
    required String entityId,
  }) {
    final collection = _collectionNameForEntityType(entityType);
    if (scopeUid == _publicScopeUid) {
      return _database.ref('public/$_module/$collection/$entityId');
    }
    return _database
        .ref('users/$scopeUid/modules/$_module/$collection/$entityId');
  }

  /// Returns remote entity collection reference.
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  ///
  /// 返回值：
  /// - 对应的实体集合引用。
  DatabaseReference _entityCollectionRef({
    required String scopeUid,
    required String entityType,
  }) {
    final collection = _collectionNameForEntityType(entityType);
    if (scopeUid == _publicScopeUid) {
      return _database.ref('public/$_module/$collection');
    }
    return _database.ref('users/$scopeUid/modules/$_module/$collection');
  }

  /// Returns oplog reference.
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [operationId]：操作 id。
  ///
  /// 返回值：
  /// - 对应 oplog 引用。
  DatabaseReference _oplogRef({
    required String scopeUid,
    required String operationId,
  }) {
    return _database.ref('users/$scopeUid/oplog/$operationId');
  }

  /// Returns revision counter reference for (scopeUid, entityType).
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  ///
  /// 返回值：
  /// - revision 计数器引用。
  DatabaseReference _revisionRef({
    required String scopeUid,
    required String entityType,
  }) {
    final collection = _collectionNameForEntityType(entityType);
    return _database
        .ref('users/$scopeUid/modules/$_module/__meta/revisions/$collection');
  }

  /// Allocates next revision for one (scopeUid, entityType).
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  ///
  /// 返回值：
  /// - 新 revision 值（>= 1）。
  Future<int> _allocateNextRevision({
    required String scopeUid,
    required String entityType,
  }) async {
    final ref = _revisionRef(scopeUid: scopeUid, entityType: entityType);
    final result = await ref.runTransaction((value) {
      final currentInt = value is int ? value : 0;
      return Transaction.success(currentInt + 1);
    });
    final v = result.snapshot.value;
    if (v is int) return v;
    throw const _RemotePayloadInvalid('revision allocation failed');
  }

  /// Converts [DeviceIdentity] to a JSON-storable map.
  ///
  /// 返回值：
  /// - 可序列化的 map。
  Map<String, Object?> _deviceToMap() {
    return {
      'deviceId': _device.deviceId,
      'platform': _device.platform,
      'formFactor': _device.formFactor,
      'model': _device.model,
      'osVersion': _device.osVersion,
      'appVersion': _device.appVersion,
    };
  }

  /// Builds oplog result payload.
  ///
  /// 参数说明：
  /// - [status]：pending/failed/dead/success。
  /// - [attempt]：attempt 次数。
  /// - [errorCode]：错误码（可空）。
  /// - [errorMessage]：错误信息（可空）。
  ///
  /// 返回值：
  /// - 可写入 RTDB 的 map。
  Map<String, Object?> _buildOplogResult({
    required String status,
    required int attempt,
    required String? errorCode,
    required String? errorMessage,
  }) {
    return {
      'status': status,
      'attempt': attempt,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'syncedAtMs': ServerValue.timestamp,
    };
  }

  /// Builds base oplog create data.
  ///
  /// 参数说明：
  /// - [record]：outbox 记录。
  /// - [attemptForWrite]：本次写入 attempt（通常为 record.attempt + 1）。
  /// - [status]：写入状态。
  /// - [revision]：本次操作的 revision（用于 pull 排序）。
  /// - [error]：可选错误。
  ///
  /// 返回值：
  /// - 可写入 RTDB 的 map。
  Map<String, Object?> _buildOplogData({
    required OutboxRecord record,
    required int attemptForWrite,
    required String status,
    required int revision,
    required SyncError? error,
  }) {
    return {
      'operationId': record.operationId,
      'entityType': record.entityType,
      'entityId': record.entityId,
      'opType': record.opType,
      'clientTimeUtcMs': record.createdAtUtc.toUtc().millisecondsSinceEpoch,
      'device': _deviceToMap(),
      'revision': revision,
      'result': _buildOplogResult(
        status: status,
        attempt: attemptForWrite,
        errorCode: error?.code.name,
        errorMessage: error?.message,
      ),
    };
  }

  /// Builds upsert data for layout_template entity.
  ///
  /// 参数说明：
  /// - [record]：outbox 记录。
  /// - [payload]：解析后的业务 payload。
  /// - [revision]：本次写入 revision。
  ///
  /// 返回值：
  /// - 可写入 RTDB 的 map。
  Map<String, Object?> _buildLayoutTemplateUpsertData({
    required OutboxRecord record,
    required _LayoutTemplatePayload payload,
    required int revision,
  }) {
    return {
      'schemaVersion': 1,
      'entityId': record.entityId,
      'payloadJson': record.payloadJson,
      'collectionId': payload.collectionId,
      'name': payload.name,
      'description': payload.description,
      'template': payload.template,
      'version': payload.version,
      'clientUpdatedAtMs': record.createdAtUtc.toUtc().millisecondsSinceEpoch,
      'serverUpdatedAtMs': ServerValue.timestamp,
      'deletedAtMs': null,
      'lastOperationId': record.operationId,
      'lastDeviceId': _device.deviceId,
      'revision': revision,
    };
  }

  /// Builds generic upsert data for non-layout_template entities.
  ///
  /// 参数说明：
  /// - [record]：outbox 记录。
  /// - [revision]：本次写入 revision。
  ///
  /// 返回值：
  /// - 可写入 RTDB 的 map。
  Map<String, Object?> _buildGenericUpsertData({
    required OutboxRecord record,
    required int revision,
  }) {
    return {
      'schemaVersion': 1,
      'entityId': record.entityId,
      'payloadJson': record.payloadJson,
      'clientUpdatedAtMs': record.createdAtUtc.toUtc().millisecondsSinceEpoch,
      'serverUpdatedAtMs': ServerValue.timestamp,
      'deletedAtMs': null,
      'lastOperationId': record.operationId,
      'lastDeviceId': _device.deviceId,
      'revision': revision,
    };
  }

  /// Parses layout_template payload from outbox JSON.
  ///
  /// 参数说明：
  /// - [payloadJson]：outbox payloadJson。
  ///
  /// 返回值：
  /// - 解析成功返回 [_LayoutTemplatePayload]；失败返回 null。
  _LayoutTemplatePayload? _parseLayoutTemplatePayload(String payloadJson) {
    Object? decoded;
    try {
      decoded = jsonDecode(payloadJson);
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;

    final collectionId = decoded['collectionId'];
    final name = decoded['name'];
    final description = decoded['description'];
    final template = decoded['template'];
    final version = decoded['version'];

    if (collectionId is! String || collectionId.isEmpty) return null;
    if (name is! String || name.isEmpty) return null;
    if (description != null && description is! String) return null;
    if (template is! Map) return null;
    if (version is! int) return null;

    return _LayoutTemplatePayload(
      collectionId: collectionId,
      name: name,
      description: description as String?,
      template: Map<String, Object?>.from(template),
      version: version,
    );
  }

  /// Tries to update oplog result when push fails.
  ///
  /// 参数说明：
  /// - [ref]：oplog 引用。
  /// - [record]：outbox 记录。
  /// - [attemptForWrite]：本次 attempt。
  /// - [revision]：本次 revision。
  /// - [error]：本次错误。
  ///
  /// 返回值：
  /// - 无。
  Future<void> _tryUpdateOplogFailed({
    required DatabaseReference ref,
    required OutboxRecord record,
    required int attemptForWrite,
    required int revision,
    required SyncError error,
  }) async {
    try {
      final snap = await ref.get();
      final data = snap.value;
      final map = data is Map ? Map<Object?, Object?>.from(data) : null;
      final result = map?['result'];
      final resultMap = result is Map
          ? Map<Object?, Object?>.from(result)
          : <Object?, Object?>{};
      final currentStatus = resultMap['status']?.toString();
      final currentAttempt = resultMap['attempt'];
      var attempt = attemptForWrite;
      if (currentAttempt is int && currentAttempt > attempt)
        attempt = currentAttempt;

      var status = attempt >= _maxAttemptsBeforeDead ? 'dead' : 'failed';
      if (currentStatus == 'dead') status = 'dead';

      await ref.set(
        _buildOplogData(
          record: record,
          attemptForWrite: attempt,
          status: status,
          revision: revision,
          error: error,
        ),
      );
    } catch (e, st) {
      _logger.warn(
        'firebase_realtime_oplog_update_failed',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(record.scopeUid),
          'operationId': record.operationId,
          'errorCode': error.code.name,
        },
        error: _errorSummary(e),
        stackTrace: st,
      );
    }
  }

  @override

  /// Pushes one [OutboxRecord] to Realtime Database.
  ///
  /// 返回值：
  /// - 成功返回 null；失败返回 [SyncError]。
  Future<SyncError?> push(OutboxRecord record) async {
    if (record.scopeUid == _publicScopeUid) {
      return const SyncError(
        code: SyncErrorCode.permission,
        message: 'public scope is pull-only',
      );
    }

    final sw = Stopwatch()..start();
    final atUtc = _nowUtc().toUtc();
    final nextAttempt = record.attempt + 1;

    _logger.debug(
      'firebase_realtime_push_start',
      data: <String, Object?>{
        'module': _module,
        'scopeUid': _redactId(record.scopeUid),
        'operationId': record.operationId,
        'entityType': record.entityType,
        'entityId': _redactId(record.entityId),
        'opType': record.opType,
        'attempt': record.attempt,
      },
    );

    final oplogRef =
        _oplogRef(scopeUid: record.scopeUid, operationId: record.operationId);
    final entityRef = _entityRef(
      scopeUid: record.scopeUid,
      entityType: record.entityType,
      entityId: record.entityId,
    );

    int? revisionForWrite;

    try {
      final oplogSnap = await oplogRef.get();
      if (oplogSnap.exists) {
        final v = oplogSnap.value;
        final map = v is Map ? Map<Object?, Object?>.from(v) : null;
        final result = map?['result'];
        final resultMap =
            result is Map ? Map<Object?, Object?>.from(result) : null;
        final status = resultMap?['status']?.toString();
        if (status == 'success') {
          _logger.debug(
            'firebase_realtime_push_idempotent_success',
            data: <String, Object?>{
              'module': _module,
              'scopeUid': _redactId(record.scopeUid),
              'operationId': record.operationId,
              'durationMs': sw.elapsedMilliseconds,
            },
          );
          return null;
        }
        if (status == 'dead') {
          return const SyncError(
              code: SyncErrorCode.conflict, message: 'oplog is dead');
        }
        final rev = map?['revision'];
        if (rev is int) revisionForWrite = rev;
      }

      if (record.opType == 'softDelete') {
        final entitySnap = await entityRef.get();
        if (!entitySnap.exists) {
          return const SyncError(
            code: SyncErrorCode.invalidData,
            message: 'softDelete requires existing remote node',
          );
        }
      }

      revisionForWrite ??= await _allocateNextRevision(
        scopeUid: record.scopeUid,
        entityType: record.entityType,
      );

      final entityData = switch (record.opType) {
        'upsert' => record.entityType == 'layout_template'
            ? () {
                final parsed = _parseLayoutTemplatePayload(record.payloadJson);
                if (parsed == null) {
                  throw const _RemotePayloadInvalid(
                      'invalid layout_template payload');
                }
                return _buildLayoutTemplateUpsertData(
                  record: record,
                  payload: parsed,
                  revision: revisionForWrite!,
                );
              }()
            : _buildGenericUpsertData(
                record: record, revision: revisionForWrite!),
        'softDelete' => <String, Object?>{
            'deletedAtMs': ServerValue.timestamp,
            'serverUpdatedAtMs': ServerValue.timestamp,
            'lastOperationId': record.operationId,
            'lastDeviceId': _device.deviceId,
            'revision': revisionForWrite!,
          },
        _ => throw _RemotePayloadInvalid('unknown opType: ${record.opType}'),
      };

      final attemptForWrite = nextAttempt;

      final rootUpdates = <String, Object?>{
        'users/${record.scopeUid}/oplog/${record.operationId}': _buildOplogData(
          record: record,
          attemptForWrite: attemptForWrite,
          status: 'success',
          revision: revisionForWrite!,
          error: null,
        ),
        if (record.opType == 'upsert')
          'users/${record.scopeUid}/modules/$_module/${_collectionNameForEntityType(record.entityType)}/${record.entityId}':
              entityData,
        if (record.opType == 'softDelete')
          'users/${record.scopeUid}/modules/$_module/${_collectionNameForEntityType(record.entityType)}/${record.entityId}':
              entityData,
      };

      await _database.ref().update(rootUpdates);

      _logger.debug(
        'firebase_realtime_push_success',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(record.scopeUid),
          'operationId': record.operationId,
          'revision': revisionForWrite,
          'durationMs': sw.elapsedMilliseconds,
        },
      );

      return null;
    } on _RemotePayloadInvalid catch (e) {
      final err =
          SyncError(code: SyncErrorCode.invalidData, message: e.message);
      if (revisionForWrite != null) {
        await _tryUpdateOplogFailed(
          ref: oplogRef,
          record: record,
          attemptForWrite: nextAttempt,
          revision: revisionForWrite!,
          error: err,
        );
      }
      _logger.warn(
        'firebase_realtime_push_rejected',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(record.scopeUid),
          'operationId': record.operationId,
          'errorCode': err.code.name,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
      );
      return err;
    } on FirebaseException catch (e, st) {
      final err = _mapFirebaseException(e);
      if (revisionForWrite != null) {
        await _tryUpdateOplogFailed(
          ref: oplogRef,
          record: record,
          attemptForWrite: nextAttempt,
          revision: revisionForWrite!,
          error: err,
        );
      }
      _logger.warn(
        'firebase_realtime_push_failed',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(record.scopeUid),
          'operationId': record.operationId,
          'firebaseCode': e.code,
          'mappedErrorCode': err.code.name,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
        stackTrace: st,
      );
      return err;
    } catch (e, st) {
      final err = SyncError(code: SyncErrorCode.unknown, message: e.toString());
      if (revisionForWrite != null) {
        await _tryUpdateOplogFailed(
          ref: oplogRef,
          record: record,
          attemptForWrite: nextAttempt,
          revision: revisionForWrite!,
          error: err,
        );
      }
      _logger.error(
        'firebase_realtime_push_error',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(record.scopeUid),
          'operationId': record.operationId,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
        stackTrace: st,
      );
      return err;
    }
  }

  @override

  /// Lists remote changes after [sinceCursor].
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  /// - [sinceCursor]：起始游标（支持 [RevisionCursor]）。
  /// - [limit]：分页大小。
  ///
  /// 返回值：
  /// - 变更页（changes/nextCursor/hasMore）。
  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    final sw = Stopwatch()..start();

    _logger.debug(
      'firebase_realtime_list_changes_start',
      data: <String, Object?>{
        'module': _module,
        'scopeUid': _redactId(scopeUid),
        'entityType': entityType,
        'limit': limit,
        'sinceCursorType': sinceCursor?.runtimeType.toString(),
      },
    );

    if (limit <= 0) {
      const page =
          RemoteChangesPage(changes: [], nextCursor: null, hasMore: false);
      _logger.debug(
        'firebase_realtime_list_changes_success',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(scopeUid),
          'entityType': entityType,
          'requested': limit,
          'returned': 0,
          'hasMore': false,
          'nextCursorType': null,
          'durationMs': sw.elapsedMilliseconds,
        },
      );
      return page;
    }

    int startRevision;
    if (sinceCursor == null) {
      startRevision = 1;
    } else if (sinceCursor is RevisionCursor) {
      startRevision = sinceCursor.revision + 1;
    } else {
      throw _RemotePayloadInvalid(
          'unsupported cursor type: ${sinceCursor.runtimeType}');
    }

    final ref =
        _entityCollectionRef(scopeUid: scopeUid, entityType: entityType);

    try {
      final query = ref
          .orderByChild('revision')
          .startAt(startRevision)
          .limitToFirst(limit + 1);
      final snap = await query.get();

      final items = snap.children.toList(growable: false);
      final hasMore = items.length > limit;
      final pageItems = hasMore ? items.sublist(0, limit) : items;

      final changes = <RemoteChange>[];
      int? lastRevision;

      for (final c in pageItems) {
        final raw = c.value;
        if (raw is! Map) continue;
        final data = Map<Object?, Object?>.from(raw);

        final entityId = (data['entityId'] as String?) ?? c.key;
        if (entityId == null || entityId.isEmpty) continue;

        final revisionRaw = data['revision'];
        if (revisionRaw is! int) continue;

        final lastOperationId = data['lastOperationId'];
        if (lastOperationId is! String || lastOperationId.isEmpty) continue;

        final deletedAtMs = data['deletedAtMs'];
        final opType = deletedAtMs == null ? 'upsert' : 'softDelete';

        final serverUpdatedAtMs = data['serverUpdatedAtMs'];
        DateTime? serverTimeUtc;
        if (serverUpdatedAtMs is int) {
          serverTimeUtc = DateTime.fromMillisecondsSinceEpoch(
            serverUpdatedAtMs,
            isUtc: true,
          );
        }

        final payloadJsonRaw = data['payloadJson'];
        String? payloadJson;
        if (payloadJsonRaw is String && payloadJsonRaw.isNotEmpty) {
          payloadJson = payloadJsonRaw;
        } else if (entityType == 'layout_template') {
          final payload = <String, Object?>{
            'schemaVersion': 1,
            'entityType': entityType,
            'entityId': entityId,
            'collectionId': data['collectionId'],
            'name': data['name'],
            'description': data['description'],
            'version': data['version'],
          };

          final clientUpdatedAtMs = data['clientUpdatedAtMs'];
          if (clientUpdatedAtMs is int) {
            payload['clientUpdatedAt'] = DateTime.fromMillisecondsSinceEpoch(
              clientUpdatedAtMs,
              isUtc: true,
            ).toIso8601String();
          }

          if (deletedAtMs is int) {
            payload['deletedAt'] = DateTime.fromMillisecondsSinceEpoch(
              deletedAtMs,
              isUtc: true,
            ).toIso8601String();
          } else {
            payload['deletedAt'] = null;
          }

          if (opType == 'upsert') {
            final template = data['template'];
            if (template is Map) {
              payload['template'] = Map<String, Object?>.from(template);
            }
          }

          payloadJson = jsonEncode(payload);
        }

        if (payloadJson == null) continue;

        lastRevision = revisionRaw;

        changes.add(
          RemoteChange(
            operationId: lastOperationId,
            entityType: entityType,
            entityId: entityId,
            opType: opType,
            cursor: RevisionCursor(revision: revisionRaw),
            payloadJson: payloadJson,
            serverTimeUtc: serverTimeUtc,
          ),
        );
      }

      final nextCursor =
          lastRevision == null ? null : RevisionCursor(revision: lastRevision);

      final page = RemoteChangesPage(
        changes: changes,
        nextCursor: nextCursor,
        hasMore: hasMore,
      );

      _logger.debug(
        'firebase_realtime_list_changes_success',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(scopeUid),
          'entityType': entityType,
          'requested': limit,
          'fetched': items.length,
          'returned': changes.length,
          'hasMore': hasMore,
          'nextCursorType': nextCursor?.runtimeType.toString(),
          'durationMs': sw.elapsedMilliseconds,
        },
      );

      return page;
    } on FirebaseException catch (e, st) {
      final err = _mapFirebaseException(e);
      _logger.warn(
        'firebase_realtime_list_changes_failed',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(scopeUid),
          'entityType': entityType,
          'limit': limit,
          'sinceCursorType': sinceCursor?.runtimeType.toString(),
          'firebaseCode': e.code,
          'mappedErrorCode': err.code.name,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
        stackTrace: st,
      );
      throw err;
    } catch (e, st) {
      _logger.error(
        'firebase_realtime_list_changes_error',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(scopeUid),
          'entityType': entityType,
          'limit': limit,
          'sinceCursorType': sinceCursor?.runtimeType.toString(),
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
        stackTrace: st,
      );
      rethrow;
    }
  }
}

class _LayoutTemplatePayload {
  /// Creates a parsed layout_template payload.
  ///
  /// 参数说明：
  /// - [collectionId]：集合 id。
  /// - [name]：模板名称。
  /// - [description]：描述（可空）。
  /// - [template]：模板内容（map）。
  /// - [version]：版本号。
  ///
  /// 返回值：
  /// - 无。
  const _LayoutTemplatePayload({
    required this.collectionId,
    required this.name,
    required this.description,
    required this.template,
    required this.version,
  });

  final String collectionId;
  final String name;
  final String? description;
  final Map<String, Object?> template;
  final int version;
}

class _RemotePayloadInvalid implements Exception {
  /// Creates an invalid-payload exception.
  ///
  /// 参数说明：
  /// - [message]：错误原因。
  ///
  /// 返回值：
  /// - 无。
  const _RemotePayloadInvalid(this.message);

  final String message;

  @override

  /// Returns string representation.
  ///
  /// 返回值：
  /// - 错误信息。
  String toString() => message;
}
