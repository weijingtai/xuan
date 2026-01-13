import 'package:flutter/foundation.dart';

import 'account_record.dart';
import 'account_registry.dart';
import 'active_account_store.dart';
import 'auth_adapter.dart';
import 'auth_session.dart';
import 'identity_resolver.dart';

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

  Future<void> signInOrRegisterWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final session = await _authAdapter.signInWithEmailPassword(
      email: email,
      password: password,
      createIfMissing: true,
    );
    final appUserId = await _identityResolver.resolveAppUserId(session);
    final record = AccountRecord(
      appUserId: appUserId,
      baasUid: session.baasUid,
      providerType: AuthProviderType.emailPassword,
      lastLoginAtUtc: DateTime.now().toUtc(),
      email: session.email,
    );
    await _accountRegistry.upsertAccount(record);
    await _activeAccountStore.setActiveAppUserId(appUserId);
  }

  Future<void> signOut() async {
    await _authAdapter.signOut();
    await _activeAccountStore.clear();
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
