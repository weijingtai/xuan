import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:common/database/app_database.dart';
import 'package:common/persistence/outbox_pusher.dart';

class FirestoreDeviceIdentity {
  const FirestoreDeviceIdentity({
    required this.deviceId,
    required this.platform,
    required this.formFactor,
    this.model,
    this.osVersion,
    this.appVersion,
  });

  final String deviceId;
  final String platform;
  final String formFactor;
  final String? model;
  final String? osVersion;
  final String? appVersion;

  Map<String, Object?> toMap() {
    return {
      'deviceId': deviceId,
      'platform': platform,
      'formFactor': formFactor,
      'model': model,
      'osVersion': osVersion,
      'appVersion': appVersion,
    };
  }
}

class FirestoreRemoteGateway {
  FirestoreRemoteGateway({
    required FirebaseFirestore firestore,
    required FirestoreDeviceIdentity device,
    required DateTime Function() nowUtc,
    String module = 'common',
    int maxAttemptsBeforeDead = 10,
  })  : _firestore = firestore,
        _device = device,
        _nowUtc = nowUtc,
        _module = module,
        _maxAttemptsBeforeDead = maxAttemptsBeforeDead;

  final FirebaseFirestore _firestore;
  final FirestoreDeviceIdentity _device;
  final DateTime Function() _nowUtc;
  final String _module;
  final int _maxAttemptsBeforeDead;

  RemotePushFn get remotePush => pushOutboxRecord;

  RemoteListChangesFn get remoteListChanges => listChanges;

  Future<SyncError?> pushOutboxRecord(OutboxRecordRow record) async {
    final atUtc = _nowUtc().toUtc();

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

    try {
      await _firestore.runTransaction((tx) async {
        var attemptForWrite = nextAttempt;

        final oplogSnap = await tx.get(oplogRef);
        if (oplogSnap.exists) {
          final data = oplogSnap.data();
          final result = data?['result'] as Map?;
          final status = result?['status'];
          if (status == 'success') return;
          if (status == 'dead') {
            throw const _RemotePayloadInvalid('oplog is dead');
          }

          final remoteAttempt = result?['attempt'];
          if (remoteAttempt is int && remoteAttempt > attemptForWrite) {
            attemptForWrite = remoteAttempt;
          }
        } else {
          tx.set(oplogRef, _buildOplogCreateData(record));
        }

        if (record.opType == 'upsert') {
          final payload = _parseLayoutTemplatePayload(record.payloadJson);
          if (payload == null) {
            throw const _RemotePayloadInvalid(
                'invalid layout_template payload');
          }

          tx.set(
            entityRef,
            _buildLayoutTemplateUpsertData(
              record: record,
              atUtc: atUtc,
              payload: payload,
            ),
          );
        } else if (record.opType == 'softDelete') {
          final existing = await tx.get(entityRef);
          if (!existing.exists) {
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

      return null;
    } on _RemotePayloadInvalid catch (e) {
      final error = SyncError(
        code: e.message == 'oplog is dead'
            ? SyncErrorCode.conflict
            : SyncErrorCode.invalidData,
        message: e.message,
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
      await _tryUpdateOplogFailed(
        oplogRef: oplogRef,
        record: record,
        nextAttempt: nextAttempt,
        error: error,
        atUtc: atUtc,
      );
      return error;
    } catch (e) {
      final error = SyncError(code: SyncErrorCode.unknown, message: '$e');
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

  Future<RemoteChangesPage> listChanges({
    required String scopeUid,
    required String entityType,
    required PullCursor? sinceCursor,
    required int limit,
  }) async {
    if (limit <= 0) {
      return const RemoteChangesPage(changes: [], nextCursor: null, hasMore: false);
    }

    if (entityType != 'layout_template') {
      throw _RemotePayloadInvalid('unsupported entityType: $entityType');
    }

    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(scopeUid)
        .collection('modules')
        .doc(_module)
        .collection('layout_templates')
        .orderBy('serverUpdatedAt')
        .orderBy('lastOperationId');

    if (sinceCursor is TimestampCursor) {
      query = query.startAfter([
        Timestamp.fromDate(sinceCursor.serverUpdatedAtUtc.toUtc()),
        sinceCursor.tieBreaker,
      ]);
    } else if (sinceCursor != null) {
      throw _RemotePayloadInvalid('unsupported cursor type: ${sinceCursor.runtimeType}');
    }

    final snap = await query.limit(limit + 1).get();
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
        payload['deletedAt'] = deletedAtValue.toDate().toUtc().toIso8601String();
      } else {
        payload['deletedAt'] = null;
      }

      if (opType == 'upsert') {
        final template = data['template'];
        if (template is Map) {
          payload['template'] = Map<String, Object?>.from(template as Map);
        }
      }

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
          payloadJson: jsonEncode(payload),
          serverTimeUtc: serverUpdatedAt.toDate().toUtc(),
        ),
      );
    }

    PullCursor? nextCursor;
    if (pageDocs.isNotEmpty) {
      final data = pageDocs.last.data();
      final lastOperationId = data['lastOperationId'] as String?;
      final serverUpdatedAt = data['serverUpdatedAt'];
      if (lastOperationId != null && lastOperationId.isNotEmpty && serverUpdatedAt is Timestamp) {
        nextCursor = TimestampCursor(
          serverUpdatedAtUtc: serverUpdatedAt.toDate().toUtc(),
          tieBreaker: lastOperationId,
        );
      }
    }

    return RemoteChangesPage(
      changes: changes,
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
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

  DocumentReference<Map<String, dynamic>> _entityDoc({
    required String scopeUid,
    required String entityType,
    required String entityId,
  }) {
    if (entityType == 'layout_template') {
      return _firestore
          .collection('users')
          .doc(scopeUid)
          .collection('modules')
          .doc(_module)
          .collection('layout_templates')
          .doc(entityId);
    }

    throw _RemotePayloadInvalid('unsupported entityType: $entityType');
  }

  Map<String, Object?> _buildOplogCreateData(OutboxRecordRow record) {
    return {
      'operationId': record.operationId,
      'entityType': record.entityType,
      'entityId': record.entityId,
      'opType': record.opType,
      'clientTimeUtc': Timestamp.fromDate(record.createdAtUtc.toUtc()),
      'device': _device.toMap(),
      'result': _buildOplogResult(
        status: 'pending',
        attempt: 0,
        errorCode: null,
        errorMessage: null,
        syncedAt: null,
      ),
    };
  }

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

  Map<String, Object?> _buildLayoutTemplateUpsertData({
    required OutboxRecordRow record,
    required DateTime atUtc,
    required _LayoutTemplatePayload payload,
  }) {
    return {
      'schemaVersion': 1,
      'entityId': record.entityId,
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
      template: Map<String, Object?>.from(template as Map),
      version: version,
    );
  }

  SyncError _mapFirebaseException(FirebaseException e) {
    final code = e.code;
    if (code == 'permission-denied' || code == 'unauthenticated') {
      return SyncError(
          code: SyncErrorCode.permission, message: e.message ?? code);
    }
    if (code == 'unavailable' || code == 'deadline-exceeded') {
      return SyncError(code: SyncErrorCode.network, message: e.message ?? code);
    }
    return SyncError(code: SyncErrorCode.unknown, message: e.message ?? code);
  }

  Future<void> _tryUpdateOplogFailed({
    required DocumentReference<Map<String, dynamic>> oplogRef,
    required OutboxRecordRow record,
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

      var status = attemptForWrite >= _maxAttemptsBeforeDead ? 'dead' : 'failed';
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
    } catch (_) {}
  }
}

class _LayoutTemplatePayload {
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
  const _RemotePayloadInvalid(this.message);

  final String message;

  @override
  String toString() => message;
}
