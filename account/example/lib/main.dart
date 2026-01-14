import 'package:account/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
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
        ChangeNotifierProvider<ActiveAccountStore>(
          create: (ctx) =>
              ActiveAccountStore(registry: ctx.read<AccountRegistry>())..load(),
        ),
        Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        Provider<AuthAdapter>(
          create: (ctx) => FirebaseEmailAuthAdapter(
            auth: ctx.read<FirebaseAuth>(),
          ),
        ),
        Provider<IdentityResolver>(
          create: (ctx) => FirebaseIdentityResolver(
            firestore: ctx.read<FirebaseFirestore>(),
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

    if (!store.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!store.isSignedIn) {
      return const AuthPage();
    }

    return const AccountProfilePage();
  }
}
