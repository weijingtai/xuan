import 'package:common/dev_constant.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'domain/models/multi_base_number_selection.dart';
import 'domain/models/yuan_hui_yun_shi.dart';
import 'navigator.dart';
import 'ui/pages/dev_page.dart';
import 'presentation/pages/strategy_demo_page.dart';
import 'presentation/pages/tai_xuan_interactive_page.dart';

import 'providers/datetime_provider.dart';
import 'infrastructure/di/strategy_providers.dart';

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
        // Strategy相关的Provider配置
        ...StrategyProviders.providers,
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
        onGenerateRoute: NavigatorGenerator.generateRoute,

        // onGenerateRoute: (settings) {
        //   switch (settings.name) {
        //     case "/tiebanshenshu/multi_selection":
        //       return MaterialPageRoute(
        //         builder: (context) => MultiBaseNumberSelectionPage(
        //           yuanHuiYunShi: YuanHuiYunShi.fromEightChars(
        //             EightChars(
        //               year: JiaZi.GUI_SI, // 癸巳
        //               month: JiaZi.JIA_ZI, // 甲子
        //               day: JiaZi.DING_YOU, // 丁酉
        //               time: JiaZi.GUI_MAO, // 癸卯
        //             ),
        //           ),
        //           requiredTypes: [
        //             BaseNumberSelectionType.yuanHui,
        //             BaseNumberSelectionType.yunShi,
        //           ],
        //         ),
        //       );
        //     case '/dev':
        //       return MaterialPageRoute(builder: (_) => DevPage());

        //     case '/strategy-demo':
        //       return MaterialPageRoute(
        //         builder: (_) => const StrategyDemoPage(),
        //       );

        //     case '/tai-xuan-interactive':
        //       return MaterialPageRoute(
        //         builder: (_) => const TaiXuanInteractivePage(),
        //       );

        //     case '/huang-ji-interactive':
        //       return MaterialPageRoute(
        //         builder: (_) => const HuangJiInteractivePage(),
        //       );

        //     default:
        //       return MaterialPageRoute(
        //         builder: (_) => const Scaffold(
        //           body: Center(child: Text('Route not found')),
        //         ),
        //       );
        //   }
        // },
      ),
    );
  }
}
