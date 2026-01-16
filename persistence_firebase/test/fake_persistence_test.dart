import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:persistence_firebase/persistence_firebase.dart';

class _WeirdCursor extends PullCursor {
  const _WeirdCursor();
}

DeviceIdentity _device() {
  return const DeviceIdentity(
    deviceId: 'device_1',
    platform: 'ios',
    formFactor: 'phone',
    model: 'iPhone',
    osVersion: '17.0',
    appVersion: '1.0.0',
  );
}

FirestoreRemoteGateway _gateway(
  FirebaseFirestore firestore, {
  DateTime Function()? nowUtc,
  String module = 'persistence_firebase',
  int maxAttemptsBeforeDead = 10,
  SyncLogger? logger,
}) {
  return FirestoreRemoteGateway(
    firestore: firestore,
    device: _device(),
    nowUtc: nowUtc ?? () => DateTime.utc(2026, 1, 11, 10, 0, 0),
    module: module,
    maxAttemptsBeforeDead: maxAttemptsBeforeDead,
    logger: logger,
  );
}

CollectionReference<Map<String, dynamic>> _layoutTemplatesCol(
  FirebaseFirestore firestore,
  String scopeUid, {
  String module = 'persistence_firebase',
}) {
  return firestore
      .collection('users')
      .doc(scopeUid)
      .collection('modules')
      .doc(module)
      .collection('layout_templates');
}

DocumentReference<Map<String, dynamic>> _oplogDoc(
  FirebaseFirestore firestore,
  String scopeUid,
  String operationId,
) {
  return firestore
      .collection('users')
      .doc(scopeUid)
      .collection('oplog')
      .doc(operationId);
}

void main() {
  group('FirestoreRemoteGateway.listChanges', () {
    test('returns empty page when limit <= 0', () async {
      final firestore = FakeFirebaseFirestore();
      final sink = InMemoryLogSink();
      final logger = SyncLogger(sink: sink, minLevel: SyncLogLevel.trace);
      final gw = _gateway(firestore, logger: logger);

      final page = await gw.listChanges(
        scopeUid: 'u1',
        entityType: 'layout_template',
        sinceCursor: null,
        limit: 0,
      );

      expect(page.changes, isEmpty);
      expect(page.nextCursor, isNull);
      expect(page.hasMore, isFalse);

      expect(
        sink.records.any((r) => r.event == 'firestore_list_changes_start'),
        isTrue,
      );
    });

    test('throws on unsupported entityType', () async {
      final firestore = FakeFirebaseFirestore();
      final gw = _gateway(firestore);

      final page = await gw.listChanges(
        scopeUid: 'u1',
        entityType: 'unknown_type',
        sinceCursor: null,
        limit: 10,
      );
      expect(page.changes, isEmpty);
      expect(page.nextCursor, isNull);
      expect(page.hasMore, isFalse);
    });

    test('throws on unsupported cursor type', () async {
      final firestore = FakeFirebaseFirestore();
      final gw = _gateway(firestore);

      expect(
        () => gw.listChanges(
          scopeUid: 'u1',
          entityType: 'layout_template',
          sinceCursor: const _WeirdCursor(),
          limit: 10,
        ),
        throwsA(
          predicate(
            (e) => e.toString().contains('unsupported cursor type'),
          ),
        ),
      );
    });

    test('filters docs missing lastOperationId or serverUpdatedAt', () async {
      const scopeUid = 'u1';
      final firestore = FakeFirebaseFirestore();
      final gw = _gateway(firestore);

      final col = _layoutTemplatesCol(firestore, scopeUid);

      await col.doc('t_ok').set({
        'collectionId': 'c1',
        'name': 'n1',
        'description': null,
        'template': {'k': 1},
        'version': 1,
        'clientUpdatedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 10, 1)),
        'serverUpdatedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 10, 2)),
        'deletedAt': null,
        'lastOperationId': 'op1',
      });

      await col.doc('t_no_op').set({
        'collectionId': 'c1',
        'name': 'n2',
        'template': {'k': 2},
        'version': 1,
        'serverUpdatedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 10, 3)),
      });

      await col.doc('t_no_server_updated_at').set({
        'collectionId': 'c1',
        'name': 'n3',
        'template': {'k': 3},
        'version': 1,
        'lastOperationId': 'op3',
      });

      final page = await gw.listChanges(
        scopeUid: scopeUid,
        entityType: 'layout_template',
        sinceCursor: null,
        limit: 10,
      );

      expect(page.changes, hasLength(1));
      expect(page.changes.single.operationId, equals('op1'));
      expect(page.changes.single.entityId, equals('t_ok'));
    });

    test(
        'orders by (serverUpdatedAt, lastOperationId) and paginates via cursor',
        () async {
      const scopeUid = 'u1';
      final firestore = FakeFirebaseFirestore();
      final gw = _gateway(firestore);

      final col = _layoutTemplatesCol(firestore, scopeUid);

      final ts1 = DateTime.utc(2026, 1, 10, 2, 0, 0);
      final ts2 = DateTime.utc(2026, 1, 10, 3, 0, 0);

      await col.doc('t1').set({
        'collectionId': 'c1',
        'name': 'n1',
        'template': {'k': 1},
        'version': 1,
        'serverUpdatedAt': Timestamp.fromDate(ts1),
        'deletedAt': null,
        'lastOperationId': 'op_a',
      });

      await col.doc('t2').set({
        'collectionId': 'c1',
        'name': 'n2',
        'template': {'k': 2},
        'version': 1,
        'serverUpdatedAt': Timestamp.fromDate(ts1),
        'deletedAt': null,
        'lastOperationId': 'op_b',
      });

      await col.doc('t3').set({
        'collectionId': 'c1',
        'name': 'n3',
        'template': {'k': 3},
        'version': 1,
        'serverUpdatedAt': Timestamp.fromDate(ts2),
        'deletedAt': null,
        'lastOperationId': 'op_c',
      });

      final page1 = await gw.listChanges(
        scopeUid: scopeUid,
        entityType: 'layout_template',
        sinceCursor: null,
        limit: 2,
      );

      expect(page1.hasMore, isTrue);
      expect(page1.changes, hasLength(2));
      expect(page1.changes[0].operationId, equals('op_a'));
      expect(page1.changes[1].operationId, equals('op_b'));
      expect(page1.nextCursor, isA<TimestampCursor>());

      final cursor1 = page1.nextCursor as TimestampCursor;
      expect(cursor1.serverUpdatedAtUtc, equals(ts1));
      expect(cursor1.tieBreaker, equals('op_b'));

      final page2 = await gw.listChanges(
        scopeUid: scopeUid,
        entityType: 'layout_template',
        sinceCursor: cursor1,
        limit: 10,
      );

      expect(page2.hasMore, isFalse);
      expect(page2.changes, hasLength(1));
      expect(page2.changes.single.operationId, equals('op_c'));
    });

    test(
        'payloadJson includes template for upsert and deletedAt for softDelete',
        () async {
      const scopeUid = 'u1';
      final firestore = FakeFirebaseFirestore();
      final gw = _gateway(firestore);

      final col = _layoutTemplatesCol(firestore, scopeUid);

      await col.doc('t_upsert').set({
        'collectionId': 'c1',
        'name': 'Upsert Name',
        'description': 'desc',
        'template': {'a': 1},
        'version': 7,
        'clientUpdatedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 10, 1)),
        'serverUpdatedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 10, 2)),
        'deletedAt': null,
        'lastOperationId': 'op_upsert',
      });

      await col.doc('t_delete').set({
        'collectionId': 'c1',
        'name': 'Deleted Name',
        'description': null,
        'version': 8,
        'serverUpdatedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 10, 3)),
        'deletedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 10, 4)),
        'lastOperationId': 'op_delete',
      });

      final page = await gw.listChanges(
        scopeUid: scopeUid,
        entityType: 'layout_template',
        sinceCursor: null,
        limit: 10,
      );

      expect(page.changes, hasLength(2));

      final upsert =
          page.changes.firstWhere((c) => c.operationId == 'op_upsert');
      expect(upsert.opType, equals('upsert'));
      final upsertPayload =
          jsonDecode(upsert.payloadJson) as Map<String, dynamic>;
      expect(upsertPayload['schemaVersion'], equals(1));
      expect(upsertPayload['entityType'], equals('layout_template'));
      expect(upsertPayload['entityId'], equals('t_upsert'));
      expect(upsertPayload['collectionId'], equals('c1'));
      expect(upsertPayload['name'], equals('Upsert Name'));
      expect(upsertPayload['description'], equals('desc'));
      expect(upsertPayload['version'], equals(7));
      expect(upsertPayload['template'], equals({'a': 1}));
      expect(upsertPayload['deletedAt'], isNull);

      final softDelete =
          page.changes.firstWhere((c) => c.operationId == 'op_delete');
      expect(softDelete.opType, equals('softDelete'));
      final deletePayload =
          jsonDecode(softDelete.payloadJson) as Map<String, dynamic>;
      expect(deletePayload['schemaVersion'], equals(1));
      expect(deletePayload['entityType'], equals('layout_template'));
      expect(deletePayload['entityId'], equals('t_delete'));
      expect(deletePayload['deletedAt'], isA<String>());
      expect(deletePayload.containsKey('template'), isFalse);
    });
  });

  group('FirestoreRemoteGateway.push', () {
    test('public scope is pull-only', () async {
      final firestore = FakeFirebaseFirestore();
      final gw = _gateway(firestore);

      final record = OutboxRecord(
        operationId: 'op_public',
        scopeUid: 'public',
        entityType: 'layout_template',
        entityId: 't1',
        opType: 'upsert',
        payloadJson:
            '{"collectionId":"c1","name":"n","description":null,"template":{},"version":1}',
        createdAtUtc: DateTime.utc(2026, 1, 11, 9, 0, 0),
        attempt: 0,
      );

      final err = await gw.push(record);
      expect(err, isNotNull);
      expect(err!.code, equals(SyncErrorCode.permission));
    });

    test(
        'upsert invalid payload returns invalidData and marks oplog dead at max',
        () async {
      const scopeUid = 'u1';
      const operationId = 'op_invalid';
      final now = DateTime.utc(2026, 1, 11, 10, 0, 0);

      final firestore = FakeFirebaseFirestore();
      final sink = InMemoryLogSink();
      final logger = SyncLogger(sink: sink, minLevel: SyncLogLevel.trace);
      final gw = _gateway(
        firestore,
        nowUtc: () => now,
        maxAttemptsBeforeDead: 1,
        logger: logger,
      );

      final record = OutboxRecord(
        operationId: operationId,
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't1',
        opType: 'upsert',
        payloadJson: '{"collectionId":"","name":"n","template":{},"version":1}',
        createdAtUtc: DateTime.utc(2026, 1, 11, 9, 0, 0),
        attempt: 0,
      );

      final err = await gw.push(record);
      expect(err, isNotNull);
      expect(err!.code, equals(SyncErrorCode.invalidData));
      expect(err.message, contains('invalid layout_template payload'));

      final oplogSnap = await _oplogDoc(firestore, scopeUid, operationId).get();
      expect(oplogSnap.exists, isTrue);
      final data = oplogSnap.data()!;
      final result = data['result'] as Map;
      expect(result['status'], equals('dead'));
      expect(result['attempt'], equals(1));
      expect(result['errorCode'], equals('invalidData'));

      expect(
        sink.records.any((r) => r.event == 'firestore_push_start'),
        isTrue,
      );
      expect(
        sink.records.any((r) => r.event == 'firestore_push_rejected'),
        isTrue,
      );
      expect(
        sink.records.any((r) => r.data.containsKey('payloadJson')),
        isFalse,
      );
    });

    test('oplog dead returns conflict', () async {
      const scopeUid = 'u1';
      const operationId = 'op_dead';
      final now = DateTime.utc(2026, 1, 11, 10, 0, 0);

      final firestore = FakeFirebaseFirestore();
      final gw = _gateway(
        firestore,
        nowUtc: () => now,
        maxAttemptsBeforeDead: 10,
      );

      final oplogRef = _oplogDoc(firestore, scopeUid, operationId);
      await oplogRef.set({
        'result': {
          'status': 'dead',
          'attempt': 99,
          'errorCode': 'invalidData',
          'errorMessage': 'x',
          'syncedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
        },
      });

      final record = OutboxRecord(
        operationId: operationId,
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't1',
        opType: 'upsert',
        payloadJson:
            '{"collectionId":"c1","name":"n","description":null,"template":{},"version":1}',
        createdAtUtc: DateTime.utc(2026, 1, 11, 9, 0, 0),
        attempt: 0,
      );

      final err = await gw.push(record);
      expect(err, isNotNull);
      expect(err!.code, equals(SyncErrorCode.conflict));

      final oplogSnap = await oplogRef.get();
      final result = (oplogSnap.data()!['result'] as Map);
      expect(result['status'], equals('dead'));
    });

    test('softDelete requires existing remote doc', () async {
      const scopeUid = 'u1';
      const operationId = 'op_soft_delete_missing';
      final now = DateTime.utc(2026, 1, 11, 10, 0, 0);

      final firestore = FakeFirebaseFirestore();
      final gw = _gateway(
        firestore,
        nowUtc: () => now,
        maxAttemptsBeforeDead: 10,
      );

      final record = OutboxRecord(
        operationId: operationId,
        scopeUid: scopeUid,
        entityType: 'layout_template',
        entityId: 't_missing',
        opType: 'softDelete',
        payloadJson: '{"schemaVersion":1}',
        createdAtUtc: DateTime.utc(2026, 1, 11, 9, 0, 0),
        attempt: 0,
      );

      final err = await gw.push(record);
      expect(err, isNotNull);
      expect(err!.code, equals(SyncErrorCode.invalidData));
      expect(err.message, contains('softDelete requires existing remote doc'));

      final oplogSnap = await _oplogDoc(firestore, scopeUid, operationId).get();
      expect(oplogSnap.exists, isTrue);
    });
  });
}
