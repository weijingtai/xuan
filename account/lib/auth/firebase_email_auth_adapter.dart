import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../logging/account_log.dart';
import 'auth_adapter.dart';
import 'auth_session.dart';

class FirebaseEmailAuthAdapter implements AuthAdapter {
  FirebaseEmailAuthAdapter({required fb.FirebaseAuth auth}) : _auth = auth;

  final fb.FirebaseAuth _auth;

  @override
  Stream<AuthSession?> sessionChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final token = await user.getIdToken();
      return AuthSession(
        baasUid: user.uid,
        idToken: token,
        email: user.email,
        providerType: AuthProviderType.emailPassword,
        issuedAt: DateTime.now().toUtc(),
      );
    });
  }

  @override
  Future<AuthSession> signInWithEmailPassword({
    required String email,
    required String password,
    required bool createIfMissing,
  }) async {
    final flowId = AccountLog.newFlowId();
    final sw = Stopwatch()..start();
    AccountLog.log.d({
      'event': 'firebase_auth.sign_in.start',
      'flowId': flowId,
      'email': AccountLog.maskEmail(email),
      'createIfMissing': createIfMissing,
    });

    fb.UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e, st) {
      AccountLog.log.w(
        {
          'event': 'firebase_auth.sign_in.auth_exception',
          'flowId': flowId,
          'code': e.code,
          'email': AccountLog.maskEmail(email),
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );

      if (!createIfMissing) rethrow;

      final shouldTryCreate =
          e.code == 'user-not-found' || e.code == 'invalid-credential';
      if (!shouldTryCreate) rethrow;

      try {
        AccountLog.log.i({
          'event': 'firebase_auth.create_user.start',
          'flowId': flowId,
          'email': AccountLog.maskEmail(email),
        });
        credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on fb.FirebaseAuthException catch (createError, createSt) {
        AccountLog.log.e(
          {
            'event': 'firebase_auth.create_user.fail',
            'flowId': flowId,
            'code': createError.code,
            'email': AccountLog.maskEmail(email),
            'durationMs': sw.elapsedMilliseconds,
          },
          error: createError,
          stackTrace: createSt,
        );

        if (createError.code == 'email-already-in-use') {
          throw e;
        }
        rethrow;
      }
    } catch (e, st) {
      AccountLog.log.e(
        {
          'event': 'firebase_auth.sign_in.fail',
          'flowId': flowId,
          'email': AccountLog.maskEmail(email),
          'durationMs': sw.elapsedMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    final user = credential.user;
    if (user == null) {
      final err = StateError('FirebaseAuth returned null user');
      AccountLog.log.e(
        {
          'event': 'firebase_auth.sign_in.fail_null_user',
          'flowId': flowId,
          'durationMs': sw.elapsedMilliseconds,
        },
        error: err,
      );
      throw err;
    }

    final token = await user.getIdToken();
    final session = AuthSession(
      baasUid: user.uid,
      idToken: token,
      email: user.email,
      providerType: AuthProviderType.emailPassword,
      issuedAt: DateTime.now().toUtc(),
    );

    AccountLog.log.i({
      'event': 'firebase_auth.sign_in.ok',
      'flowId': flowId,
      'baasUid': AccountLog.maskId(session.baasUid),
      'email': AccountLog.maskEmail(session.email),
      'durationMs': sw.elapsedMilliseconds,
    });

    return session;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');
    await user.delete();
  }
}
