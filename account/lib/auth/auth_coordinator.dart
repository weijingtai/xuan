import 'dart:async';

import 'package:flutter/foundation.dart';

import '../logging/account_log.dart';
import 'account_record.dart';
import 'account_registry.dart';
import 'active_account_store.dart';
import 'auth_adapter.dart';
import 'auth_session.dart';
import 'identity_resolver.dart';

class GuestAccountConflict implements Exception {
  const GuestAccountConflict({
    required this.session,
    required this.guestAppUserId,
    required this.accountAppUserId,
  });

  final AuthSession session;
  final String guestAppUserId;
  final String accountAppUserId;

  @override
  String toString() {
    return 'GuestAccountConflict(guestAppUserId=$guestAppUserId, accountAppUserId=$accountAppUserId)';
  }
}

abstract class GuestAccountConflictDelegate {
  Future<void> mergeGuestIntoAccount({
    required String guestAppUserId,
    required String accountAppUserId,
  });

  Future<void> discardGuest({required String guestAppUserId});
}

class AuthCoordinator {
  AuthCoordinator({
    required AuthAdapter authAdapter,
    required IdentityResolver identityResolver,
    required AccountRegistry accountRegistry,
    required ActiveAccountStore activeAccountStore,
  })  : _authAdapter = authAdapter,
        _identityResolver = identityResolver,
        _accountRegistry = accountRegistry,
        _activeAccountStore = activeAccountStore;

  final AuthAdapter _authAdapter;
  final IdentityResolver _identityResolver;
  final AccountRegistry _accountRegistry;
  final ActiveAccountStore _activeAccountStore;

  Stream<AuthSession?> sessionChanges() => _authAdapter.sessionChanges();

  Future<void> signInAnonymously() async {
    final flowId = AccountLog.newFlowId();
    final sw = Stopwatch()..start();
    AccountLog.log.i({
      'event': 'auth.sign_in_anonymous.start',
      'flowId': flowId,
      'provider': 'anonymous',
    });

    try {
      final session = await _authAdapter
          .signInAnonymously()
          .timeout(const Duration(seconds: 20));

      final guestAppUserId = _activeAccountStore.isGuest
          ? _activeAccountStore.activeAppUserId
          : null;

      if (guestAppUserId != null && guestAppUserId.isNotEmpty) {
        await _identityResolver
            .ensureIdentityMapping(session: session, appUserId: guestAppUserId)
            .timeout(const Duration(seconds: 12));

        await _activateAppUserId(
          appUserId: guestAppUserId,
          session: session,
          flowId: flowId,
        );
      } else {
        await _activateFromSession(session, flowId: flowId)
            .timeout(const Duration(seconds: 20));
      }

      AccountLog.log.i({
        'event': 'auth.sign_in_anonymous.ok',
        'flowId': flowId,
        'durationMs': sw.elapsedMilliseconds,
      });
    } catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'auth.sign_in_anonymous.fail',
          'flowId': flowId,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final flowId = AccountLog.newFlowId();
    final sw = Stopwatch()..start();
    AccountLog.log.i({
      'event': 'auth.sign_in.start',
      'flowId': flowId,
      'provider': 'emailPassword',
      'email': AccountLog.maskEmail(email),
    });

    try {
      final session = await _authAdapter
          .signInWithEmailPassword(
            email: email,
            password: password,
            createIfMissing: false,
          )
          .timeout(const Duration(seconds: 20));

      final guestAppUserId = _activeAccountStore.isGuest
          ? _activeAccountStore.activeAppUserId
          : null;

      final accountAppUserId = await _identityResolver
          .resolveAppUserId(session)
          .timeout(const Duration(seconds: 12));

      if (guestAppUserId != null &&
          guestAppUserId.isNotEmpty &&
          accountAppUserId != guestAppUserId) {
        throw GuestAccountConflict(
          session: session,
          guestAppUserId: guestAppUserId,
          accountAppUserId: accountAppUserId,
        );
      }

      await _activateAppUserId(
        appUserId: accountAppUserId,
        session: session,
        flowId: flowId,
      ).timeout(const Duration(seconds: 20));

      AccountLog.log.i({
        'event': 'auth.sign_in.ok',
        'flowId': flowId,
        'durationMs': sw.elapsedMilliseconds,
      });
    } catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'auth.sign_in.fail',
          'flowId': flowId,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> signInOrRegisterWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final flowId = AccountLog.newFlowId();
    final sw = Stopwatch()..start();
    AccountLog.log.i({
      'event': 'auth.sign_in_or_register.start',
      'flowId': flowId,
      'provider': 'emailPassword',
      'email': AccountLog.maskEmail(email),
    });

    try {
      final session = await _authAdapter
          .signInWithEmailPassword(
            email: email,
            password: password,
            createIfMissing: true,
          )
          .timeout(const Duration(seconds: 20));

      final guestAppUserId = _activeAccountStore.isGuest
          ? _activeAccountStore.activeAppUserId
          : null;

      if (guestAppUserId != null && guestAppUserId.isNotEmpty) {
        await _identityResolver
            .ensureIdentityMapping(session: session, appUserId: guestAppUserId)
            .timeout(const Duration(seconds: 12));

        await _activateAppUserId(
          appUserId: guestAppUserId,
          session: session,
          flowId: flowId,
        );
      } else {
        await _activateFromSession(session, flowId: flowId)
            .timeout(const Duration(seconds: 20));
      }

      AccountLog.log.i({
        'event': 'auth.sign_in_or_register.ok',
        'flowId': flowId,
        'durationMs': sw.elapsedMilliseconds,
      });
    } catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'auth.sign_in_or_register.fail',
          'flowId': flowId,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _authAdapter.sendPasswordResetEmail(email: email);
  }

  Future<void> activateSession(AuthSession session) async {
    final flowId = AccountLog.newFlowId();
    await _activateFromResolvedAppUserId(
      session: session,
      appUserId: await _identityResolver.resolveAppUserId(session),
      flowId: flowId,
    );
  }

  Future<void> _activateFromResolvedAppUserId({
    required AuthSession session,
    required String appUserId,
    required String flowId,
  }) async {
    final sw = Stopwatch()..start();
    AccountLog.log.d({
      'event': 'auth.activate_resolved.start',
      'flowId': flowId,
      'baasUid': AccountLog.maskId(session.baasUid),
      'appUserId': AccountLog.maskId(appUserId),
    });

    final record = AccountRecord(
      appUserId: appUserId,
      baasUid: session.baasUid,
      providerType: session.providerType,
      lastLoginAtUtc: DateTime.now().toUtc(),
      email: session.email,
    );
    await _accountRegistry.upsertAccount(record);
    await _activeAccountStore.setActiveAppUserId(appUserId);

    AccountLog.log.i({
      'event': 'auth.activate_resolved.ok',
      'flowId': flowId,
      'appUserId': AccountLog.maskId(appUserId),
      'durationMs': sw.elapsedMilliseconds,
    });
  }

  Future<void> _activateFromSession(
    AuthSession session, {
    required String flowId,
  }) async {
    final sw = Stopwatch()..start();
    AccountLog.log.d({
      'event': 'auth.activate.start',
      'flowId': flowId,
      'baasUid': AccountLog.maskId(session.baasUid),
    });

    try {
      final appUserId = await _identityResolver
          .resolveAppUserId(session)
          .timeout(const Duration(seconds: 12));
      AccountLog.log.d({
        'event': 'auth.activate.identity_resolved',
        'flowId': flowId,
        'appUserId': AccountLog.maskId(appUserId),
        'durationMs': sw.elapsedMilliseconds,
      });

      await _activateFromResolvedAppUserId(
        session: session,
        appUserId: appUserId,
        flowId: flowId,
      );
    } on TimeoutException catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'auth.activate.timeout',
          'flowId': flowId,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      throw StateError('登录超时：身份映射未完成，请检查网络/Firestore 权限');
    }
  }

  Future<void> _activateAppUserId({
    required String appUserId,
    required AuthSession session,
    required String flowId,
  }) async {
    final sw = Stopwatch()..start();
    AccountLog.log.d({
      'event': 'auth.activate_app_user_id.start',
      'flowId': flowId,
      'baasUid': AccountLog.maskId(session.baasUid),
      'appUserId': AccountLog.maskId(appUserId),
    });

    final record = AccountRecord(
      appUserId: appUserId,
      baasUid: session.baasUid,
      providerType: session.providerType,
      lastLoginAtUtc: DateTime.now().toUtc(),
      email: session.email,
    );
    await _accountRegistry.upsertAccount(record);
    await _activeAccountStore.setActiveAppUserId(appUserId);

    AccountLog.log.i({
      'event': 'auth.activate_app_user_id.ok',
      'flowId': flowId,
      'appUserId': AccountLog.maskId(appUserId),
      'durationMs': sw.elapsedMilliseconds,
    });
  }

  Future<void> signOut() async {
    final flowId = AccountLog.newFlowId();
    final sw = Stopwatch()..start();
    AccountLog.log.i({'event': 'auth.sign_out.start', 'flowId': flowId});
    try {
      await _authAdapter.signOut();
      await _activeAccountStore.clear();
      AccountLog.log.i({
        'event': 'auth.sign_out.ok',
        'flowId': flowId,
        'durationMs': sw.elapsedMilliseconds,
      });
    } catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'auth.sign_out.fail',
          'flowId': flowId,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> updatePassword({required String newPassword}) {
    return _authAdapter.updatePassword(newPassword: newPassword);
  }

  Future<void> deleteAccount() async {
    await _authAdapter.deleteAccount();
    await _activeAccountStore.clear();
  }

  String formatAuthError(Object error) {
    if (error is Exception || error is Error) {
      return error.toString();
    }
    return describeIdentity(error);
  }
}
