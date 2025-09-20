import 'package:common/dev_constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/datetime_provider.dart';
import 'ui/pages/node_editor_example_page.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(
    MultiProvider(
      providers: [
        Provider<String>.value(value: 'example'),
        ChangeNotifierProvider<DateTimeProvider>(
          create: (_) =>
              DateTimeProvider()..updateDateTime(DevConstant.dev_usa),
        ),
        // ...AppProviders.providers,
        // ChangeNotifierProvider(create: (_) => DataPanelViewModel()),
        // ChangeNotifierProvider(
        //   create: (context) {
        //     final algorithmViewModel = AlgorithmEditorViewModel();
        //     final dataPanelViewModel = context.read<DataPanelViewModel>();
        //     algorithmViewModel.setDataPanelViewModel(dataPanelViewModel);
        //     return algorithmViewModel;
        //   },
        // ),
        // Provider<AlgorithmRepository>(create: (_) => MockAlgorithmRepository()),
        // Provider<AtomicOperationRepository>(
        //   create: (_) => ProductionAtomicOperationRepository(),
        // ),
        // ChangeNotifierProvider(create: (_) => AlgorithmEditorViewModel()),
        // ChangeNotifierProvider(create: (_) => DataPanelViewModel()),
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
        Provider<String>.value(value: 'example2'),
        // Provider<AlgorithmRepository>(create: (_) => MockAlgorithmRepository()),
        // Provider<AtomicOperationRepository>(
        //   create: (_) => ProductionAtomicOperationRepository(),
        // ),
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
            // case '/':
            //   return MaterialPageRoute(
            //     builder: (_) => const AlgorithmListView(),
            //   );
            // case '/edit':
            //   final args = settings.arguments as Map<String, dynamic>?;
            //   return MaterialPageRoute(
            //     builder: (_) => AlgorithmEditorView(algorithmId: args?['id']),
            //   );
            // case '/step':
            //   final args = settings.arguments as Map<String, dynamic>;
            //   return MaterialPageRoute(
            //     builder: (_) => StepEditorView(
            //       editingStep: args['editingStep'] as ExecutionStep?,
            //       precedingSteps: args['precedingSteps'] as List<ExecutionStep>,
            //     ),
            //   );
            case '/dev':
              return MaterialPageRoute(builder: (_) => NodeEditorExampleApp());
            // case '/devCard':
            //   return MaterialPageRoute(builder: (_) => FlowCardMapperPage());

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
