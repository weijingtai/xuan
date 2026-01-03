import 'package:flutter/material.dart';
import 'package:common/pages/four_zhu_edit_page.dart';
import 'package:provider/provider.dart';

import 'package:common/database/app_database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>(
          create: (ctx) => AppDatabase(null, false),
          dispose: (ctx, db) => db.close(),
        ),
      ],
      child: MaterialApp(
        title: 'FourZhu Edit Preview',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        home: const FourZhuEditPage(),
      ),
    );
  }
}
