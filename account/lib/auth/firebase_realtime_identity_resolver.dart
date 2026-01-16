import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

import '../logging/account_log.dart';
import 'auth_session.dart';
import 'identity_resolver.dart';

class FirebaseRealtimeIdentityResolver implements IdentityResolver {
  FirebaseRealtimeIdentityResolver({
    required FirebaseDatabase database,
    required Uuid uuid,
    DateTime Function()? nowUtc,
  })  : _database = database,
        _uuid = uuid,
        _nowUtc = nowUtc ?? (() => DateTime.now().toUtc());

  final FirebaseDatabase _database;
  final Uuid _uuid;
  final DateTime Function() _nowUtc;

  DatabaseReference _docRef(String baasUid) =>
      _database.ref('identity_map/$baasUid');

  Map<String, Object?>? _asStringKeyedMap(Object? value) {
    if (value is! Map) return null;
    final out = <String, Object?>{};
    value.forEach((k, v) {
      if (k is String) out[k] = v;
    });
    return out;
  }

  Map<String, Object?> _buildDoc({
    required AuthSession session,
    required String appUserId,
    required bool includeCreatedAt,
  }) {
    final ts = _nowUtc().millisecondsSinceEpoch;
    final doc = <String, Object?>{
      'appUserId': appUserId,
      'lastSeenAt': ts,
      'providerType': session.providerType.name,
      'schemaVersion': 1,
    };
    if (includeCreatedAt) {
      doc['createdAt'] = ts;
    }
    return doc;
  }

  @override
  Future<void> ensureIdentityMapping({
    required AuthSession session,
    required String appUserId,
  }) async {
    final flowId = AccountLog.newFlowId();
    final sw = Stopwatch()..start();
    final baasUid = session.baasUid;
    final ref = _docRef(baasUid);

    AccountLog.log.d({
      'event': 'identity.ensure.start',
      'flowId': flowId,
      'baasUid': AccountLog.maskId(baasUid),
      'appUserId': AccountLog.maskId(appUserId),
      'providerType': session.providerType.name,
      'issuedAt': session.issuedAt.toIso8601String(),
      'ref': 'identity_map/${AccountLog.maskId(baasUid)}',
    });

    try {
      var loggedInvalidPayload = false;
      var loggedAbort = false;

      final result = await ref.runTransaction((value) {
        final map = _asStringKeyedMap(value);

        if (value != null && map == null) {
          if (!loggedInvalidPayload) {
            loggedInvalidPayload = true;
            AccountLog.log.w({
              'event': 'identity.ensure.tx.invalid_payload',
              'flowId': flowId,
              'baasUid': AccountLog.maskId(baasUid),
              'valueType': value.runtimeType.toString(),
            });
          }
          return Transaction.abort();
        }

        final existingAppUserId = map == null ? null : map['appUserId'];

        if (existingAppUserId == null) {
          AccountLog.log.d({
            'event': 'identity.ensure.tx.create',
            'flowId': flowId,
            'baasUid': AccountLog.maskId(baasUid),
          });
          return Transaction.success(
            _buildDoc(
              session: session,
              appUserId: appUserId,
              includeCreatedAt: true,
            ),
          );
        }

        if (existingAppUserId is! String) {
          if (!loggedInvalidPayload) {
            loggedInvalidPayload = true;
            AccountLog.log.w({
              'event': 'identity.ensure.tx.invalid_app_user_id_type',
              'flowId': flowId,
              'baasUid': AccountLog.maskId(baasUid),
              'appUserIdType': existingAppUserId.runtimeType.toString(),
            });
          }
          return Transaction.abort();
        }

        if (existingAppUserId.isEmpty) {
          if (!loggedInvalidPayload) {
            loggedInvalidPayload = true;
            AccountLog.log.w({
              'event': 'identity.ensure.tx.empty_app_user_id',
              'flowId': flowId,
              'baasUid': AccountLog.maskId(baasUid),
            });
          }
          return Transaction.abort();
        }

        if (existingAppUserId != appUserId) {
          if (!loggedAbort) {
            loggedAbort = true;
            AccountLog.log.w({
              'event': 'identity.ensure.tx.abort.mismatch',
              'flowId': flowId,
              'baasUid': AccountLog.maskId(baasUid),
              'expectedAppUserId': AccountLog.maskId(appUserId),
              'existingAppUserId': AccountLog.maskId(existingAppUserId),
            });
          }
          return Transaction.abort();
        }

        AccountLog.log.d({
          'event': 'identity.ensure.tx.merge',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
          'appUserId': AccountLog.maskId(existingAppUserId),
        });

        final merged = Map<String, Object?>.of(map ?? const <String, Object?>{});
        merged['lastSeenAt'] = _nowUtc().millisecondsSinceEpoch;
        merged['providerType'] = session.providerType.name;
        merged['schemaVersion'] = 1;
        return Transaction.success(merged);
      }).timeout(const Duration(seconds: 12));

      AccountLog.log.d({
        'event': 'identity.ensure.tx.result',
        'flowId': flowId,
        'baasUid': AccountLog.maskId(baasUid),
        'committed': result.committed,
        'durationMs': sw.elapsedMilliseconds,
      });

      if (!result.committed) {
        final existing = result.snapshot.child('appUserId').value;

        if (existing is String && existing.isNotEmpty && existing != appUserId) {
          throw IdentityMappingConflict(
            baasUid: baasUid,
            expectedAppUserId: appUserId,
            existingAppUserId: existing,
          );
        }

        if (existing != null) {
          AccountLog.log.e({
            'event': 'identity.ensure.aborted_existing_invalid',
            'flowId': flowId,
            'baasUid': AccountLog.maskId(baasUid),
            'existingAppUserIdType': existing.runtimeType.toString(),
          });
          throw StateError('identity_map 数据异常（appUserId 类型不正确或为空），需要人工修复');
        }

        AccountLog.log.w({
          'event': 'identity.ensure.aborted',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
        });
        throw StateError('写入 identity_map 失败：请检查网络/Realtime Database 权限');
      }
    } on IdentityMappingConflict {
      rethrow;
    } on TimeoutException catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'identity.ensure.timeout',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
          'appUserId': AccountLog.maskId(appUserId),
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      throw StateError('写入 identity_map 超时：请检查网络/Realtime Database 权限');
    } catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'identity.ensure.fail',
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
      'event': 'identity.ensure.ok',
      'flowId': flowId,
      'baasUid': AccountLog.maskId(baasUid),
      'appUserId': AccountLog.maskId(appUserId),
      'durationMs': sw.elapsedMilliseconds,
    });
  }

  @override
  Future<String> resolveAppUserId(AuthSession session) async {
    final flowId = AccountLog.newFlowId();
    final sw = Stopwatch()..start();
    final baasUid = session.baasUid;
    final ref = _docRef(baasUid);

    AccountLog.log.d({
      'event': 'identity.resolve.start',
      'flowId': flowId,
      'baasUid': AccountLog.maskId(baasUid),
    });

    try {
      final existingSnap = await ref
          .child('appUserId')
          .get()
          .timeout(const Duration(seconds: 12));
      final existing = existingSnap.value;
      if (existing is String && existing.isNotEmpty) {
        AccountLog.log.i({
          'event': 'identity.resolve.hit',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
          'appUserId': AccountLog.maskId(existing),
          'durationMs': sw.elapsedMilliseconds,
        });
        return existing;
      }

      if (existing != null) {
        AccountLog.log.e({
          'event': 'identity.resolve.invalid_existing',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
          'existingAppUserIdType': existing.runtimeType.toString(),
          'durationMs': sw.elapsedMilliseconds,
        });
        throw StateError('identity_map 数据异常（appUserId 类型不正确或为空），需要人工修复');
      }

      final created = _uuid.v4();
      AccountLog.log.d({
        'event': 'identity.resolve.create_attempt',
        'flowId': flowId,
        'baasUid': AccountLog.maskId(baasUid),
        'appUserId': AccountLog.maskId(created),
      });

      try {
        await ensureIdentityMapping(session: session, appUserId: created);
        AccountLog.log.i({
          'event': 'identity.resolve.created',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
          'appUserId': AccountLog.maskId(created),
          'durationMs': sw.elapsedMilliseconds,
        });
        return created;
      } on IdentityMappingConflict catch (e) {
        AccountLog.log.i({
          'event': 'identity.resolve.raced',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
          'appUserId': AccountLog.maskId(e.existingAppUserId),
          'durationMs': sw.elapsedMilliseconds,
        });
        return e.existingAppUserId;
      }
    } on TimeoutException catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'identity.resolve.timeout',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      throw StateError('读取 identity_map 超时：请检查网络/Realtime Database 权限');
    } catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'identity.resolve.fail',
          'flowId': flowId,
          'baasUid': AccountLog.maskId(baasUid),
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
