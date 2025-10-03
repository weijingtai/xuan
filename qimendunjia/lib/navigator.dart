import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:qimendunjia/pages/primary_page.dart';
import 'package:qimendunjia/pages/scalable_shi_jia_qi_men_view_page.dart';
import 'package:qimendunjia/pages/shi_jia_qi_men_view_model.dart';
import 'package:qimendunjia/presentation/pages/qimen_mvvm_page.dart';
import 'package:qimendunjia/di/service_locator.dart';

class NavigatorGenerator {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
  static Logger logger = Logger();
  static final routes = {
    // 旧版实现（传统架构）
    // "/qimendunjia": (context, {arguments}) => PrimaryPage(),
    // "/qimendunjia": (context, {arguments}) => BeautifulPage(),
    "/qimendunjia": (context, {arguments}) => MultiProvider(
          providers: [
            ChangeNotifierProvider<ShiJiaQiMenViewModel>(
                create: (context) => ShiJiaQiMenViewModel(context)),
          ],
          child: ScalableShiJiaQiMenViewPage(),
          // child: ShiJiaQiMenViewPage(),
        ),

    // 新版实现（MVVM + UseCase架构）
    "/qimendunjia/mvvm": (context, {arguments}) => ChangeNotifierProvider(
          create: (_) => serviceLocator.createQiMenViewModel(),
          child: const QiMenMvvmPage(),
        ),
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
          appBar: AppBar(title: const Text('奇门遁甲_未知页面')),
          body: Center(child: Text(msg)));
    });
  }

  static Route<dynamic> generateRoute1(RouteSettings settings) {
    switch (settings.name) {
      case '/qimendunjia/primary':
        return PageRouteBuilder(
            settings:
                settings, // Pass this to make popUntil(), pushNamedAndRemoveUntil(), works
            // pageBuilder: (_, __, ___) => CreateOrderPage(settings.arguments == null ?null:settings.arguments as CreateOrderPageArgs),
            pageBuilder: (_, __, ___) => const PrimaryPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween = Tween(begin: begin, end: end);
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: curve,
              );
              return SlideTransition(
                position: tween.animate(curvedAnimation),
                child: child,
              );
            });
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
