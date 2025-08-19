import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiebanshenshu/data/repositories/algorithm_repository.dart';
import 'package:tiebanshenshu/data/repositories/atomic_operation_repository.dart';
import 'package:tiebanshenshu/data/repositories/mock_algorithm_repository.dart';
import 'package:tiebanshenshu/data/repositories/production_atomic_operation_repository.dart';
import 'package:tiebanshenshu/tmp_dart/lib/providers/app_providers.dart';
import 'package:tiebanshenshu/tmp_dart/lib/viewmodels/data_panel_viewmodel.dart';
import 'package:tiebanshenshu/ui/views/algorithm_editor_view.dart';
import 'package:tiebanshenshu/ui/views/algorithm_list_view.dart';
import 'package:tiebanshenshu/ui/views/step_editor_view.dart';
import 'package:tiebanshenshu/algorithm/models/execution_step.dart';

import 'tmp_dart/lib/viewmodels/algorithm_editor_viewmodel.dart';
import 'tmp_dart/lib/views/pages/algorithm_editor_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<AlgorithmRepository>(create: (_) => MockAlgorithmRepository()),
        Provider<AtomicOperationRepository>(
          create: (_) => ProductionAtomicOperationRepository(),
        ),
        ...AppProviders.providers,
        ChangeNotifierProvider(create: (_) => AlgorithmEditorViewModel()),
        ChangeNotifierProvider(create: (_) => DataPanelViewModel()),
      ],
      child: const AlgorithmEditorApp(),
    ),
  );
}

class AlgorithmEditorApp extends StatelessWidget {
  const AlgorithmEditorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AlgorithmRepository>(create: (_) => MockAlgorithmRepository()),
        Provider<AtomicOperationRepository>(
          create: (_) => ProductionAtomicOperationRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'Algorithm Editor Prototype',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/dev',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => const AlgorithmListView(),
              );
            case '/edit':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => AlgorithmEditorView(algorithmId: args?['id']),
              );
            case '/step':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => StepEditorView(
                  editingStep: args['editingStep'] as ExecutionStep?,
                  precedingSteps: args['precedingSteps'] as List<ExecutionStep>,
                ),
              );
            case '/dev':
              return MaterialPageRoute(builder: (_) => AlgorithmEditorPage());
            default:
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Route not found')),
                ),
              );
          }
        },
      ),
    );
  }
}
