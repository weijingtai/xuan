// lib/main.dart

import 'package:daliuren/di/service_locator.dart'; // Import the GetIt service locator setup
import 'package:daliuren/presentation/viewmodels/my_home_viewmodel.dart'; // ViewModel for MyHomePage
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For providing ViewModel to the widget tree
import 'presentation/pages/my_home_page.dart'; // The main page of the application

/// Main entry point of the application.
/// Initializes WidgetsFlutterBinding, sets up the service locator,
/// and runs the app with the MyHomePageViewModel provided at the root.
Future<void> main() async {
  // Ensure that Flutter's widget binding is initialized.
  // This is required if you need to call platform channel code (which setupServiceLocator might do indirectly
  // through plugins like path_provider used by Drift) before calling runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all dependencies using the GetIt service locator.
  // This should be done before the UI is built so that all services are available.
  await setupServiceLocator();

  // Run the Flutter application.
  runApp(
    // Use ChangeNotifierProvider to make MyHomePageViewModel available to the widget tree.
    // `create` callback fetches the ViewModel instance from the service locator (`sl`).
    // This allows MyHomePage and its descendants to access the ViewModel.
    ChangeNotifierProvider<MyHomePageViewModel>(
      create: (_) => sl<MyHomePageViewModel>(),
      child: const MyApp(), // The root widget of the application.
    ),
  );
}

/// The root widget of the DaLiuRen application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '大六壬',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true, // Enable Material 3 design features.
        // TODO: Consider defining a more complete theme (brightness, colorScheme, textTheme, etc.)
      ),
      // Set MyHomePage as the home screen.
      home: const MyHomePage(title: '大六壬神课'),
      // TODO: Implement routing for navigation to other pages if the app grows.
      // debugShowCheckedModeBanner: false, // Optionally hide the debug banner.
    );
  }
}
