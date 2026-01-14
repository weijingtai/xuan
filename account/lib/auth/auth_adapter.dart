import 'auth_session.dart';

abstract class AuthAdapter {
  Stream<AuthSession?> sessionChanges();

  Future<AuthSession> signInWithEmailPassword({
    required String email,
    required String password,
    required bool createIfMissing,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> signOut();

  Future<void> updatePassword({required String newPassword});

  Future<void> deleteAccount();
}
