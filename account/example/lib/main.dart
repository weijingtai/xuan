import 'package:account/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AccountExampleApp());
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
      child: const MaterialApp(home: AuthPage()),
    );
  }
}
