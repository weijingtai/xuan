import 'package:firebase_auth/firebase_auth.dart' as fb;

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
    fb.UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      if (!createIfMissing) rethrow;

      final shouldTryCreate =
          e.code == 'user-not-found' || e.code == 'invalid-credential';
      if (!shouldTryCreate) rethrow;

      try {
        credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on fb.FirebaseAuthException catch (createError) {
        if (createError.code == 'email-already-in-use') {
          throw e;
        }
        rethrow;
      }
    }

    final user = credential.user;
    if (user == null) {
      throw StateError('FirebaseAuth returned null user');
    }

    final token = await user.getIdToken();
    return AuthSession(
      baasUid: user.uid,
      idToken: token,
      email: user.email,
      providerType: AuthProviderType.emailPassword,
      issuedAt: DateTime.now().toUtc(),
    );
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
