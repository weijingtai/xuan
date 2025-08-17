import 'package:common/main.dart';
import 'package:flutter/material.dart';
import 'package:tiebanshenshu/ui/views/algorithm_editor_view.dart';
import 'package:tiebanshenshu/ui/views/algorithm_list_view.dart';
import 'package:tiebanshenshu/ui/views/step_editor_view.dart';
import 'package:tiebanshenshu/algorithm/models/execution_step.dart';
import 'package:logger/logger.dart';

import 'package:qimendunjia/navigator.dart' as QiMenDunJia;
import 'package:qizhengsiyu/navigator.dart' as QiZhengSiYu;
import 'package:taiyishenshu/navigator.dart' as TaiYiShenShu;
import 'package:daliuren/navigator.dart' as DaLiuRen;
import 'package:common/navigator.dart' as Common;
import 'package:xuan/pages/one_year_circle.dart';

class NavigatorGenerator {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
  static Logger logger = Logger();
  static final routes = {
    '/algorithm_editor': (context, {arguments}) => const AlgorithmListView(),
    '/algorithm_editor/edit': (context, {arguments}) {
      final args = arguments as Map<String, dynamic>?;
      return AlgorithmEditorView(algorithmId: args?['id'] as String?);
    },
    '/algorithm_editor/step': (context, {arguments}) {
      final args = arguments as Map<String, dynamic>;
      return StepEditorView(
        editingStep: args['editingStep'] as ExecutionStep?,
        precedingSteps: args['precedingSteps'] as List<ExecutionStep>,
      );
    },
    // "/": (context,{arguments}) => RootPage(),
    // "/": (context, {arguments}) => CityPickerPage(),
    "/one_year": (context, {arguments}) => OneYearCircle(),
    "/widget_dev": (context, {arguments}) => MyHomePage(
          title: 'widgets dev',
        ),
    ...Common.NavigatorGenerator.routes,
    ...QiMenDunJia.NavigatorGenerator.routes,
    ...QiZhengSiYu.NavigatorGenerator.routes,
    ...TaiYiShenShu.NavigatorGenerator.routes,
    ...DaLiuRen.NavigatorGenerator.routes
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? name = settings.name;
    if (name != null && name.isNotEmpty) {
      final Function? pageContentBuilder = routes[name];
      if (pageContentBuilder != null) {
        final Route route = MaterialPageRoute(
            builder: (context) =>
                pageContentBuilder(context, arguments: settings.arguments));
        return route;
      } else {
        return _errorPage('Could not found route for $name');
      }
    } else {
      return _errorPage("Navigator required naviation name.");
    }
  }

  static Route _errorPage(msg) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
          appBar: AppBar(title: Text('未知页面')), body: Center(child: Text(msg)));
    });
  }
}
