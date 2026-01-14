import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../logging/account_log.dart';
import 'auth_session.dart';
import 'identity_resolver.dart';

class FirebaseIdentityResolver implements IdentityResolver {
  FirebaseIdentityResolver({
    required FirebaseFirestore firestore,
    required Uuid uuid,
  })  : _firestore = firestore,
        _uuid = uuid;

  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  @override
  Future<String> resolveAppUserId(AuthSession session) async {
    final flowId = AccountLog.newFlowId();
    final sw = Stopwatch()..start();
    final baasUid = session.baasUid;

    AccountLog.log.d({
      'event': 'identity.resolve.start',
      'flowId': flowId,
      'baasUid': AccountLog.maskId(baasUid),
    });

    final doc = _firestore.collection('identity_map').doc(baasUid);

    late final DocumentSnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await doc.get().timeout(const Duration(seconds: 12));
    } on TimeoutException catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'identity.resolve.get.timeout',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      throw StateError('读取 identity_map 超时：请检查网络/Firestore 权限');
    } catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'identity.resolve.get.fail',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    final existing = snapshot.data();
    final existingAppUserId = existing == null ? null : existing['appUserId'];
    if (existingAppUserId is String && existingAppUserId.isNotEmpty) {
      AccountLog.log.i({
        'event': 'identity.resolve.hit',
        'flowId': flowId,
        'baasUid': AccountLog.maskId(baasUid),
        'appUserId': AccountLog.maskId(existingAppUserId),
        'durationMs': sw.elapsedMilliseconds,
      });
      return existingAppUserId;
    }

    final appUserId = _uuid.v4();
    try {
      await doc
          .set({
            'appUserId': appUserId,
            'createdAt': FieldValue.serverTimestamp(),
            'lastSeenAt': FieldValue.serverTimestamp(),
            'providerType': session.providerType.name,
            'schemaVersion': 1,
          })
          .timeout(const Duration(seconds: 12));
    } on TimeoutException catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'identity.resolve.set.timeout',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
          'appUserId': AccountLog.maskId(appUserId),
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      throw StateError('写入 identity_map 超时：请检查网络/Firestore 权限');
    } catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'identity.resolve.set.fail',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
          'appUserId': AccountLog.maskId(appUserId),
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    AccountLog.log.i({
      'event': 'identity.resolve.created',
      'flowId': flowId,
      'baasUid': AccountLog.maskId(baasUid),
      'appUserId': AccountLog.maskId(appUserId),
      'durationMs': sw.elapsedMilliseconds,
    });

    return appUserId;
  }
}
