import 'package:account/account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const useEmulator = bool.fromEnvironment(
    'USE_FIREBASE_EMULATOR',
    defaultValue: false,
  );
  if (useEmulator) {
    final host = _emulatorHost();
    FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseDatabase.instance.useDatabaseEmulator(host, 9000);
  }

  runApp(const AccountExampleApp());
}

String _emulatorHost() {
  if (kIsWeb) return 'localhost';
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => '10.0.2.2',
    TargetPlatform.iOS => 'localhost',
    TargetPlatform.macOS => 'localhost',
    TargetPlatform.windows => 'localhost',
    TargetPlatform.linux => 'localhost',
    TargetPlatform.fuchsia => 'localhost',
  };
}

class AccountExampleApp extends StatelessWidget {
  const AccountExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Uuid>(create: (_) => const Uuid()),
        Provider<AccountRegistry>(create: (_) => AccountRegistry()),
        Provider<GuestIdentityStore>(
          create: (ctx) => GuestIdentityStore(uuid: ctx.read<Uuid>()),
        ),
        ChangeNotifierProvider<ActiveAccountStore>(
          create: (ctx) => ActiveAccountStore(
            registry: ctx.read<AccountRegistry>(),
            guestIdentityStore: ctx.read<GuestIdentityStore>(),
          )..load(),
        ),
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirebaseDatabase>(create: (_) => FirebaseDatabase.instance),
        Provider<AuthAdapter>(
          create: (ctx) => FirebaseEmailAuthAdapter(
            auth: ctx.read<FirebaseAuth>(),
          ),
        ),
        Provider<IdentityResolver>(
          create: (ctx) => FirebaseRealtimeIdentityResolver(
            database: ctx.read<FirebaseDatabase>(),
            uuid: ctx.read<Uuid>(),
          ),
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
      child: const MaterialApp(home: _ExampleHome()),
    );
  }
}

class _ExampleHome extends StatelessWidget {
  const _ExampleHome();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ActiveAccountStore>();
    final coordinator = context.read<AuthCoordinator>();

    if (!store.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (store.isGuest) {
      final appUserId = store.activeAppUserId ?? '';
      return Scaffold(
        appBar: AppBar(title: const Text('Account Example')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('模式: guest'),
                  const SizedBox(height: 8),
                  Text('appUserId: $appUserId'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      try {
                        await coordinator.signInAnonymously();
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('匿名登录失败: $e')),
                        );
                      }
                    },
                    child: const Text('Firebase 匿名登录（绑定 guest appUserId）'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AuthPage()),
                      );
                    },
                    child: const Text('打开邮箱登录页'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!store.isSignedIn) {
      return const Scaffold(
        body: Center(child: Text('No active account')),
      );
    }

    return const AccountProfilePage();
  }
}
