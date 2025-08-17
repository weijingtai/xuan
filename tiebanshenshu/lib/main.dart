import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiebanshenshu/data/repositories/algorithm_repository.dart';
import 'package:tiebanshenshu/data/repositories/atomic_operation_repository.dart';
import 'package:tiebanshenshu/data/repositories/mock_algorithm_repository.dart';
import 'package:tiebanshenshu/ui/views/algorithm_editor_view.dart';
import 'package:tiebanshenshu/ui/views/algorithm_list_view.dart';
import 'package:tiebanshenshu/ui/views/step_editor_view.dart';
import 'package:tiebanshenshu/algorithm/models/execution_step.dart';

void main() {
  runApp(const AlgorithmEditorApp());
}

class AlgorithmEditorApp extends StatelessWidget {
  const AlgorithmEditorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AlgorithmRepository>(create: (_) => MockAlgorithmRepository()),
        Provider<AtomicOperationRepository>(
          create: (_) => MockAtomicOperationRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'Algorithm Editor Prototype',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
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
