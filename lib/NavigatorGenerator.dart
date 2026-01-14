import 'package:common/main.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:qimendunjia/navigator.dart' as QiMenDunJia;
import 'package:qizhengsiyu/navigator.dart' as QiZhengSiYu;
import 'package:taiyishenshu/navigator.dart' as TaiYiShenShu;
import 'package:daliuren/navigator.dart' as DaLiuRen;
import 'package:common/navigator.dart' as Common;
import 'package:xuan/pages/one_year_circle.dart';
import 'package:account/account.dart';

class NavigatorGenerator {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
  static Logger logger = Logger();
  static final routes = {
    // "/": (context,{arguments}) => RootPage(),
    // "/": (context, {arguments}) => CityPickerPage(),
    "/one_year": (context, {arguments}) => OneYearCircle(),
    "/widget_dev": (context, {arguments}) => MyHomePage(
          title: 'widgets dev',
        ),
    AuthPage.routeName: (context, {arguments}) => const AuthPage(),
    AccountProfilePage.routeName: (context, {arguments}) =>
        const AccountProfilePage(),
        
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
