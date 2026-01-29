import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiebanshenshu/navigator.dart';
import 'package:tiebanshenshu/infrastructure/di/strategy_providers.dart';
import 'package:tiebanshenshu/providers/datetime_provider.dart';
import 'package:common/dev_constant.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  // Initialize timezone data
  tz.initializeTimeZones();

  runApp(
    MultiProvider(
      providers: [
        // Basic configuration providers
        Provider<String>.value(value: 'example_app'),

        // DateTime provider from tiebanshenshu
        ChangeNotifierProvider<DateTimeProvider>(
          create: (_) =>
              DateTimeProvider()..updateDateTime(DevConstant.dev_usa),
        ),

        // All strategy related providers from tiebanshenshu
        ...StrategyProviders.providers,
      ],
      child: const TieBanShenShuExampleApp(),
    ),
  );
}

class TieBanShenShuExampleApp extends StatelessWidget {
  const TieBanShenShuExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '铁版神数示例程序',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // Use the navigator generator from the tiebanshenshu module
      initialRoute: '/dev',
      onGenerateRoute: NavigatorGenerator.generateRoute,
      builder: (context, child) {
        // You can add global overlays or wrappers here if needed
        return child!;
      },
    );
  }
}
