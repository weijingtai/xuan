import 'package:account/account.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const AccountExampleApp());
}

class AccountExampleApp extends StatelessWidget {
  const AccountExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AccountRegistry>(create: (_) => AccountRegistry()),
        ChangeNotifierProvider<ActiveAccountStore>(
          create: (ctx) =>
              ActiveAccountStore(registry: ctx.read<AccountRegistry>())..load(),
        ),
        Provider<AuthAdapter>(create: (_) => _UnavailableAuthAdapter()),
        Provider<IdentityResolver>(
          create: (_) => _UnavailableIdentityResolver(),
        ),
        Provider<AuthCoordinator>(
          create: (ctx) => AuthCoordinator(
            authAdapter: ctx.read<AuthAdapter>(),
            identityResolver: ctx.read<IdentityResolver>(),
            accountRegistry: ctx.read<AccountRegistry>(),
            activeAccountStore: ctx.read<ActiveAccountStore>(),
          ),
        ),
      ],
      child: const MaterialApp(home: AuthPage()),
    );
  }
}

class _UnavailableAuthAdapter implements AuthAdapter {
  @override
  Stream<AuthSession?> sessionChanges() => const Stream.empty();

  @override
  Future<AuthSession> signInWithEmailPassword({
    required String email,
    required String password,
    required bool createIfMissing,
  }) {
    throw StateError(
      'Firebase 未接入：请在 example 工程中初始化 Firebase，并改用 FirebaseEmailAuthAdapter。',
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updatePassword({required String newPassword}) {
    throw StateError('Firebase 未接入：updatePassword 不可用');
  }

  @override
  Future<void> deleteAccount() {
    throw StateError('Firebase 未接入：deleteAccount 不可用');
  }
}

class _UnavailableIdentityResolver implements IdentityResolver {
  @override
  Future<String> resolveAppUserId(AuthSession session) {
    throw StateError(
      'Firebase 未接入：请改用 FirebaseIdentityResolver(firestore, uuid)。',
    );
  }
}
