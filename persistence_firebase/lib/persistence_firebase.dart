import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persistence_core/persistence_core.dart';

export 'firebase_realtime_remote_gateway.dart';

/// Firestore implementation of [RemoteGateway].
///
/// 功能说明：
/// - 将 [OutboxRecord] push 到 Firestore（实体文档 + oplog）。
/// - 从 Firestore 按 cursor 增量拉取变更（[RemoteChange]）。
/// - 通过可注入 [SyncLogger] 输出结构化埋点，兼顾开发调试与生产观测。
///
/// 日志策略（建议）：
/// - 开发环境：minLevel=debug，sink=PrintLogSink。
/// - 生产环境：minLevel=warn/info，sink=上报到你的统计/埋点系统。
/// - 本实现不会在日志中输出 payloadJson 等大字段，以降低采集成本与敏感信息风险。
class FirestoreRemoteGateway implements RemoteGateway {
  /// Creates a Firestore-based gateway.
  ///
  /// 功能说明：
  /// - 封装 Firestore 的 push/pull 行为，供 [SyncCoordinator] 调用。
  /// - 日志通过 [SyncLogger] 统一输出，调用方可按环境注入不同 sink/等级。
  ///
  /// 参数说明：
  /// - [firestore]：Firestore 实例。
  /// - [device]：当前设备标识（写入 oplog）。
  /// - [nowUtc]：返回当前 UTC 时间的函数（便于测试/回放）。
  /// - [module]：模块隔离字段（users/{uid}/modules/{module}/...）。
  /// - [maxAttemptsBeforeDead]：到达该次数后标记 oplog 为 dead。
  /// - [logger]：可选日志器；未传入则为 no-op。
  FirestoreRemoteGateway({
    required FirebaseFirestore firestore,
    required DeviceIdentity device,
    required DateTime Function() nowUtc,
    String module = 'persistence_firebase',
    int maxAttemptsBeforeDead = 10,
    SyncLogger? logger,
  })  : _firestore = firestore,
        _device = device,
        _nowUtc = nowUtc,
        _module = module,
        _maxAttemptsBeforeDead = maxAttemptsBeforeDead,
        _logger = logger ?? SyncLogger.noop();

  final FirebaseFirestore _firestore;
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
  /// 功能说明：
  /// - 避免将 FirebaseException 等对象原样写入日志，降低泄露文档路径等信息的风险。
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
    return <String, Object?>{
      'type': error.runtimeType.toString(),
    };
  }

  @override

  /// Pushes one outbox record to Firestore.
  ///
  /// 功能说明：
  /// - 以 Firestore transaction 写入/更新：
  ///   - `users/{scopeUid}/oplog/{operationId}`
  ///   - 实体文档（当前仅支持 layout_template）。
  /// - 幂等：若远端 oplog 已为 success，直接返回 success。
  /// - 本方法不会在日志中输出 payloadJson。
  ///
  /// 参数说明：
  /// - [record]：待 push 的 outbox 记录。
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

    final atUtc = _nowUtc().toUtc();
    final sw = Stopwatch()..start();

    _logger.debug(
      'firestore_push_start',
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

    final oplogRef = _oplogDoc(
      scopeUid: record.scopeUid,
      operationId: record.operationId,
    );

    final entityRef = _entityDoc(
      scopeUid: record.scopeUid,
      entityType: record.entityType,
      entityId: record.entityId,
    );

    final nextAttempt = record.attempt + 1;

    var attemptWritten = nextAttempt;
    var oplogExisted = false;
    String? oplogStatusBefore;

    try {
      await _firestore.runTransaction((tx) async {
        var attemptForWrite = nextAttempt;

        final oplogSnap = await tx.get(oplogRef);
        DocumentSnapshot<Map<String, dynamic>>? entitySnap;

        if (oplogSnap.exists) {
          oplogExisted = true;
          final data = oplogSnap.data();
          final result = data?['result'] as Map?;
          final status = result?['status'];
          oplogStatusBefore = status?.toString();
          if (status == 'success') return;
          if (status == 'dead') {
            throw const _RemotePayloadInvalid('oplog is dead');
          }

          final remoteAttempt = result?['attempt'];
          if (remoteAttempt is int && remoteAttempt > attemptForWrite) {
            attemptForWrite = remoteAttempt;
          }
        }

        if (record.opType == 'softDelete') {
          entitySnap = await tx.get(entityRef);
        }

        if (!oplogSnap.exists) {
          tx.set(oplogRef, _buildOplogCreateData(record));
        }

        attemptWritten = attemptForWrite;

        if (record.opType == 'upsert') {
          if (record.entityType == 'layout_template') {
            final payload = _parseLayoutTemplatePayload(record.payloadJson);
            if (payload == null) {
              throw const _RemotePayloadInvalid(
                'invalid layout_template payload',
              );
            }
            tx.set(
              entityRef,
              _buildLayoutTemplateUpsertData(
                record: record,
                atUtc: atUtc,
                payload: payload,
              ),
            );
          } else {
            tx.set(
              entityRef,
              _buildGenericUpsertData(record: record, atUtc: atUtc),
            );
          }
        } else if (record.opType == 'softDelete') {
          if (entitySnap == null || !entitySnap.exists) {
            throw const _RemotePayloadInvalid(
              'softDelete requires existing remote doc',
            );
          }

          tx.update(entityRef, {
            'deletedAt': Timestamp.fromDate(atUtc),
            'serverUpdatedAt': Timestamp.fromDate(atUtc),
            'lastOperationId': record.operationId,
            'lastDeviceId': _device.deviceId,
          });
        } else {
          throw _RemotePayloadInvalid('unknown opType: ${record.opType}');
        }

        tx.set(
          oplogRef,
          {
            'result': _buildOplogResult(
              status: 'success',
              attempt: attemptForWrite,
              errorCode: null,
              errorMessage: null,
              syncedAt: Timestamp.fromDate(atUtc),
            ),
          },
          SetOptions(merge: true),
        );
      });

      _logger.debug(
        'firestore_push_success',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(record.scopeUid),
          'operationId': record.operationId,
          'attemptWritten': attemptWritten,
          'oplogExisted': oplogExisted,
          'oplogStatusBefore': oplogStatusBefore,
          'durationMs': sw.elapsedMilliseconds,
        },
      );

      return null;
    } on _RemotePayloadInvalid catch (e) {
      final error = SyncError(
        code: e.message == 'oplog is dead'
            ? SyncErrorCode.conflict
            : SyncErrorCode.invalidData,
        message: e.message,
      );

      _logger.warn(
        'firestore_push_rejected',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(record.scopeUid),
          'operationId': record.operationId,
          'errorCode': error.code.name,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
      );

      await _tryUpdateOplogFailed(
        oplogRef: oplogRef,
        record: record,
        nextAttempt: nextAttempt,
        error: error,
        atUtc: atUtc,
      );
      return error;
    } on FirebaseException catch (e) {
      final error = _mapFirebaseException(e);

      _logger.warn(
        'firestore_push_failed',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(record.scopeUid),
          'operationId': record.operationId,
          'firebaseCode': e.code,
          'errorCode': error.code.name,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
      );
      await _tryUpdateOplogFailed(
        oplogRef: oplogRef,
        record: record,
        nextAttempt: nextAttempt,
        error: error,
        atUtc: atUtc,
      );
      return error;
    } catch (e, st) {
      final error = SyncError(code: SyncErrorCode.unknown, message: '$e');

      _logger.error(
        'firestore_push_error',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(record.scopeUid),
          'operationId': record.operationId,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
        stackTrace: st,
      );
      await _tryUpdateOplogFailed(
        oplogRef: oplogRef,
        record: record,
        nextAttempt: nextAttempt,
        error: error,
        atUtc: atUtc,
      );
      return error;
    }
  }

  @override

  /// Lists remote changes after [sinceCursor].
  ///
  /// 功能说明：
  /// - 按 `serverUpdatedAt` + `lastOperationId` 进行稳定排序与分页。
  /// - 当前仅支持 layout_template。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  /// - [sinceCursor]：起始游标（null 表示从头拉）。
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
      'firestore_list_changes_start',
      data: <String, Object?>{
        'module': _module,
        'scopeUid': _redactId(scopeUid),
        'entityType': entityType,
        'limit': limit,
        'sinceCursorType': sinceCursor?.runtimeType.toString(),
      },
    );

    if (limit <= 0) {
      const page = RemoteChangesPage(
        changes: [],
        nextCursor: null,
        hasMore: false,
      );

      _logger.debug(
        'firestore_list_changes_success',
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

    Query<Map<String, dynamic>> query = _entityCollection(
      scopeUid: scopeUid,
      entityType: entityType,
    ).orderBy('serverUpdatedAt').orderBy('lastOperationId');

    if (sinceCursor is TimestampCursor) {
      query = query.startAfter([
        Timestamp.fromDate(sinceCursor.serverUpdatedAtUtc.toUtc()),
        sinceCursor.tieBreaker,
      ]);
    } else if (sinceCursor != null) {
      _logger.error(
        'firestore_list_changes_unsupported_cursor',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(scopeUid),
          'entityType': entityType,
          'sinceCursorType': sinceCursor.runtimeType.toString(),
        },
      );
      throw _RemotePayloadInvalid(
        'unsupported cursor type: ${sinceCursor.runtimeType}',
      );
    }

    QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap = await query.limit(limit + 1).get();
    } on FirebaseException catch (e, st) {
      final mapped = _mapFirebaseException(e);
      _logger.warn(
        'firestore_list_changes_failed',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(scopeUid),
          'entityType': entityType,
          'limit': limit,
          'sinceCursorType': sinceCursor?.runtimeType.toString(),
          'firebaseCode': e.code,
          'mappedErrorCode': mapped.code.name,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: _errorSummary(e),
        stackTrace: st,
      );
      throw mapped;
    } catch (e, st) {
      _logger.error(
        'firestore_list_changes_error',
        data: <String, Object?>{
          'module': _module,
          'scopeUid': _redactId(scopeUid),
          'entityType': entityType,
          'limit': limit,
          'sinceCursorType': sinceCursor?.runtimeType.toString(),
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    final docs = snap.docs;

    final hasMore = docs.length > limit;
    final pageDocs = hasMore ? docs.sublist(0, limit) : docs;

    final changes = <RemoteChange>[];

    for (final doc in pageDocs) {
      final data = doc.data();
      final entityId = (data['entityId'] as String?) ?? doc.id;
      final lastOperationId = data['lastOperationId'] as String?;
      final serverUpdatedAt = data['serverUpdatedAt'];
      if (lastOperationId == null || lastOperationId.isEmpty) continue;
      if (serverUpdatedAt is! Timestamp) continue;

      final deletedAt = data['deletedAt'];
      final opType = deletedAt == null ? 'upsert' : 'softDelete';

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

        final clientUpdatedAt = data['clientUpdatedAt'];
        if (clientUpdatedAt is Timestamp) {
          payload['clientUpdatedAt'] =
              clientUpdatedAt.toDate().toUtc().toIso8601String();
        }

        final deletedAtValue = data['deletedAt'];
        if (deletedAtValue is Timestamp) {
          payload['deletedAt'] =
              deletedAtValue.toDate().toUtc().toIso8601String();
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

      changes.add(
        RemoteChange(
          operationId: lastOperationId,
          entityType: entityType,
          entityId: entityId,
          opType: opType,
          cursor: TimestampCursor(
            serverUpdatedAtUtc: serverUpdatedAt.toDate().toUtc(),
            tieBreaker: lastOperationId,
          ),
          payloadJson: payloadJson,
          serverTimeUtc: serverUpdatedAt.toDate().toUtc(),
        ),
      );
    }

    PullCursor? nextCursor;
    if (pageDocs.isNotEmpty) {
      final data = pageDocs.last.data();
      final lastOperationId = data['lastOperationId'] as String?;
      final serverUpdatedAt = data['serverUpdatedAt'];
      if (lastOperationId != null &&
          lastOperationId.isNotEmpty &&
          serverUpdatedAt is Timestamp) {
        nextCursor = TimestampCursor(
          serverUpdatedAtUtc: serverUpdatedAt.toDate().toUtc(),
          tieBreaker: lastOperationId,
        );
      }
    }

    final page = RemoteChangesPage(
      changes: changes,
      nextCursor: nextCursor,
      hasMore: hasMore,
    );

    _logger.debug(
      'firestore_list_changes_success',
      data: <String, Object?>{
        'module': _module,
        'scopeUid': _redactId(scopeUid),
        'entityType': entityType,
        'requested': limit,
        'fetched': docs.length,
        'returned': changes.length,
        'hasMore': hasMore,
        'nextCursorType': nextCursor?.runtimeType.toString(),
        'durationMs': sw.elapsedMilliseconds,
      },
    );

    return page;
  }

  DocumentReference<Map<String, dynamic>> _oplogDoc({
    required String scopeUid,
    required String operationId,
  }) {
    return _firestore
        .collection('users')
        .doc(scopeUid)
        .collection('oplog')
        .doc(operationId);
  }

  /// Returns entity document reference by type.
  ///
  /// 功能说明：
  /// - 将 core 的 entityType/entityId 映射为 Firestore 文档路径。
  ///
  /// 参数说明：
  /// - [scopeUid]：同步作用域。
  /// - [entityType]：实体类型。
  /// - [entityId]：实体 id。
  ///
  /// 返回值：
  /// - 对应实体的文档引用。
  DocumentReference<Map<String, dynamic>> _entityDoc({
    required String scopeUid,
    required String entityType,
    required String entityId,
  }) {
    return _entityCollection(scopeUid: scopeUid, entityType: entityType)
        .doc(entityId);
  }

  CollectionReference<Map<String, dynamic>> _entityCollection({
    required String scopeUid,
    required String entityType,
  }) {
    final collection = _collectionNameForEntityType(entityType);
    if (scopeUid == _publicScopeUid) {
      return _firestore
          .collection('public')
          .doc(_module)
          .collection(collection);
    }

    return _firestore
        .collection('users')
        .doc(scopeUid)
        .collection('modules')
        .doc(_module)
        .collection(collection);
  }

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

  /// Converts [DeviceIdentity] to a Firestore-storable map.
  ///
  /// 功能说明：
  /// - 为 oplog 写入 device 字段，便于审计与排障。
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

  /// Builds initial oplog document payload.
  ///
  /// 功能说明：
  /// - 当 oplog 不存在时创建，初始 result 为 pending。
  ///
  /// 参数说明：
  /// - [record]：outbox 记录。
  ///
  /// 返回值：
  /// - Firestore 可写入的 map。
  Map<String, Object?> _buildOplogCreateData(OutboxRecord record) {
    return {
      'operationId': record.operationId,
      'entityType': record.entityType,
      'entityId': record.entityId,
      'opType': record.opType,
      'clientTimeUtc': Timestamp.fromDate(record.createdAtUtc.toUtc()),
      'device': _deviceToMap(),
      'result': _buildOplogResult(
        status: 'pending',
        attempt: 0,
        errorCode: null,
        errorMessage: null,
        syncedAt: null,
      ),
    };
  }

  /// Builds oplog result payload.
  ///
  /// 功能说明：
  /// - 统一 result 字段结构，便于统计与规则校验。
  ///
  /// 参数说明：
  /// - [status]：pending/failed/dead/success。
  /// - [attempt]：attempt 次数。
  /// - [errorCode]：错误码（可空）。
  /// - [errorMessage]：错误信息（可空）。
  /// - [syncedAt]：同步时间（可空）。
  ///
  /// 返回值：
  /// - Firestore 可写入的 map。
  Map<String, Object?> _buildOplogResult({
    required String status,
    required int attempt,
    required String? errorCode,
    required String? errorMessage,
    required Timestamp? syncedAt,
  }) {
    return {
      'status': status,
      'attempt': attempt,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'syncedAt': syncedAt,
    };
  }

  /// Builds upsert payload for layout_template entity.
  ///
  /// 功能说明：
  /// - 将 outbox payload 转换为远端实体字段（含 serverUpdatedAt、lastOperationId）。
  ///
  /// 参数说明：
  /// - [record]：outbox 记录。
  /// - [atUtc]：本次写入 server 侧时间（UTC）。
  /// - [payload]：解析后的业务 payload。
  ///
  /// 返回值：
  /// - Firestore 可写入的 map。
  Map<String, Object?> _buildLayoutTemplateUpsertData({
    required OutboxRecord record,
    required DateTime atUtc,
    required _LayoutTemplatePayload payload,
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
      'clientUpdatedAt': Timestamp.fromDate(record.createdAtUtc.toUtc()),
      'serverUpdatedAt': Timestamp.fromDate(atUtc),
      'deletedAt': null,
      'lastOperationId': record.operationId,
      'lastDeviceId': _device.deviceId,
    };
  }

  Map<String, Object?> _buildGenericUpsertData({
    required OutboxRecord record,
    required DateTime atUtc,
  }) {
    return {
      'schemaVersion': 1,
      'entityId': record.entityId,
      'payloadJson': record.payloadJson,
      'clientUpdatedAt': Timestamp.fromDate(record.createdAtUtc.toUtc()),
      'serverUpdatedAt': Timestamp.fromDate(atUtc),
      'deletedAt': null,
      'lastOperationId': record.operationId,
      'lastDeviceId': _device.deviceId,
    };
  }

  /// Parses layout_template payload from outbox JSON.
  ///
  /// 功能说明：
  /// - 对 payload 做最小校验与字段提取，失败返回 null。
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

  /// Maps [FirebaseException] into core [SyncError].
  ///
  /// 功能说明：
  /// - 将常见 Firebase 错误码归一到 core 的 errorCode，便于聚合统计。
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

  /// Tries to update oplog result when push fails.
  ///
  /// 功能说明：
  /// - 尽最大努力将 oplog 状态写为 failed/dead，并记录错误码与信息。
  /// - 该方法失败时不会影响 push 的主流程返回（仅记录日志）。
  ///
  /// 参数说明：
  /// - [oplogRef]：oplog 文档引用。
  /// - [record]：outbox 记录。
  /// - [nextAttempt]：候选 attempt。
  /// - [error]：本次错误。
  /// - [atUtc]：本次失败时间（UTC）。
  ///
  /// 返回值：
  /// - 无。
  Future<void> _tryUpdateOplogFailed({
    required DocumentReference<Map<String, dynamic>> oplogRef,
    required OutboxRecord record,
    required int nextAttempt,
    required SyncError error,
    required DateTime atUtc,
  }) async {
    try {
      final snap = await oplogRef.get();

      final result = (snap.data()?['result'] as Map?);
      final currentStatus = result?['status'];
      final currentAttempt = result?['attempt'];

      var attemptForWrite = nextAttempt;
      if (currentAttempt is int && currentAttempt > attemptForWrite) {
        attemptForWrite = currentAttempt;
      }

      var status =
          attemptForWrite >= _maxAttemptsBeforeDead ? 'dead' : 'failed';
      if (currentStatus == 'dead') status = 'dead';

      if (!snap.exists) {
        await oplogRef.set(_buildOplogCreateData(record));
      }

      await oplogRef.set(
        {
          'result': _buildOplogResult(
            status: status,
            attempt: attemptForWrite,
            errorCode: error.code.name,
            errorMessage: error.message,
            syncedAt: Timestamp.fromDate(atUtc),
          ),
        },
        SetOptions(merge: true),
      );
    } catch (e, st) {
      _logger.warn(
        'firestore_oplog_update_failed',
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
