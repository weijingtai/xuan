import 'package:common/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:xuan/pages/conditional_route_widget.dart';
import 'package:xuan/pages/cross_platform_main_page.dart';
import 'package:xuan/pages/root_page.dart';
import 'package:xuan/routes.dart';
import 'ephe_web_helper.dart' if (dart.library.ffi) 'ephe_io_helper.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'NavigatorGenerator.dart';

Future<void> initServices() async {
  // 在这里可以进行其他异步初始化操作
  // 例如加载配置文件等

  tz.initializeTimeZones();
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  WidgetsFlutterBinding.ensureInitialized();
  await initSweph([
    'packages/sweph/assets/ephe/sefstars.txt', // For star position
  ]);
}

void main() async {
  // runApp(
  //   MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider<ShiJiaQiMenViewModel>(create: (context) => ShiJiaQiMenViewModel(context)),
  //     ],
  //     child: const MyApp(),
  //   ),
  // );
  initServices().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return buildNewXuan();
    return MaterialApp(
      title: '玄学',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      showSemanticsDebugger: false,
      onGenerateRoute: NavigatorGenerator.generateRoute,
      // initialRoute: '/qizhengsiyu',
      // initialRoute: '/one_year',
      initialRoute: '/qizhengsiyu', // 七政四余
      // initialRoute: '/taiyishenshu', // 太乙神数
      // initialRoute: '/daliuren/dev', // 大六壬
      // initialRoute: '/qimendunjia', // 奇门遁甲
      // initialRoute: '/', // main
      // initialRoute: '/widget_dev', // 奇门遁甲
      // onGenerateRoute: NavigatorGenerator.generateRoute,
    );
  }

  Widget buildNewXuan() {
    return MaterialApp(
      title: '玄学',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      showSemanticsDebugger: false,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        breakpoints: [
          const Breakpoint(start: 0, end: 480, name: MOBILE),
          const Breakpoint(start: 481, end: 800, name: PHONE),
          const Breakpoint(start: 801, end: 1024, name: TABLET),
          const Breakpoint(start: 1025, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
        child: child!,
      ),
      initialRoute: "/",
      onGenerateInitialRoutes: (initialRoute) {
        final Uri uri = Uri.parse(initialRoute);
        return [
          buildPage(path: uri.path, queryParams: uri.queryParameters),
        ];
      },
      onGenerateRoute: (RouteSettings settings) {
        // A custom `fadeThrough` route transition animation.
        final Uri uri = Uri.parse(settings.name ?? '/');
        return Routes.fadeThrough(
            settings: settings,
            builder: (context) {
              // Wrap widgets with another widget based on the route.
              // Wrap the page with the ResponsiveScaledBox for desired pages.
              //   final Uri uri = Uri.parse(settings.name ?? '/');
              return ConditionalRouteWidget(
                  routesExcluded: const [], // Excluding a page from AutoScale.
                  builder: (context, child) => child != null
                      ? child
                      : ResponsiveScaledBox(
                          // ResponsiveScaledBox renders its child with a FittedBox set to the `width` value.
                          // Set the fixed width value based on the active breakpoint.
                          width: ResponsiveValue<double>(context,
                              conditionalValues: [
                                // const Condition.equals(name: MOBILE, value: 450),
                                const Condition.between(
                                    start: 0, end: 450, value: 0),
                                const Condition.between(
                                    start: 800, end: 1100, value: 800),
                                Condition.between(
                                    start: 1000,
                                    end: double.maxFinite.toInt(),
                                    value: 1000),
                              ]).value,
                          child: child!),
                  child: BouncingScrollWrapper.builder(
                      context, buildPageByName(uri.path),
                      dragWithMouse: true));
            });
      },
      // onGenerateRoute: (RouteSettings settings) {
      //   final Uri uri = Uri.parse(settings.name ?? '/');
      //   return buildPage(path: uri.path, queryParams: uri.queryParameters);
      // },

      // initialRoute: '/qizhengsiyu',
      // initialRoute: '/one_year',
      // initialRoute: '/qizhengsiyu', // 七政四余
      // initialRoute: '/taiyishenshu', // 太乙神数
      // initialRoute: '/daliuren', // 大六壬
      // initialRoute: '/qimendunjia', // 奇门遁甲
      // initialRoute: '/', // mai
      // initialRoute: '/widget_dev', // 奇门遁甲
      // onGenerateRoute: NavigatorGenerator.generateRoute,
    );
  }

  Widget buildPageByName(String name) {
    switch (name) {
      case '/':
      case CrossPlatformMainPage.routeName:
        return const CrossPlatformMainPage();
      // case PostPage.name:
      //   return const PostPage();
      // case TypographyPage.name:
      //   return const TypographyPage();
      default:
        return const SizedBox.shrink();
    }
  }

  Route<dynamic> buildPage(
      {required String path, Map<String, String> queryParams = const {}}) {
    return Routes.noAnimation(
        settings: RouteSettings(
            name: (path.startsWith('/') == false) ? '/$path' : path),
        builder: (context) {
          String pathName =
              path != '/' && path.startsWith('/') ? path.substring(1) : path;
          return switch (pathName) {
            // '/' || ListPage.name => const ListPage(),
            "ok" =>
              // Breakpoints can be nested.
              // Here's an example of custom "per-page" breakpoints.
              ResponsiveBreakpoints(breakpoints: [
                Breakpoint(start: 0, end: 480, name: MOBILE),
                Breakpoint(start: 481, end: 1200, name: TABLET),
                Breakpoint(start: 1201, end: double.infinity, name: DESKTOP),
              ], child: RootPage()),
            '/' ||
            CrossPlatformMainPage.routeName =>
              const CrossPlatformMainPage(),
            // TypographyPage.name => const TypographyPage(),
            _ => const SizedBox.shrink(),
          };
        });
  }
}
