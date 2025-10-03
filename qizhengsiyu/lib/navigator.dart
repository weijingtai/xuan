import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:qizhengsiyu/presentation/pages/beauty_page_viewmodel.dart';
import 'package:qizhengsiyu/presentation/pages/beauty_view_page.dart';
import 'package:qizhengsiyu/presentation/pages/primary_page.dart';
import 'package:qizhengsiyu/presentation/viewmodels/qi_zheng_si_yu_viewmodel.dart';

import 'data/datasources/local/app_database.dart';
import 'data/repositories/interfaces/i_qizhengsiyu_pan_repository.dart';
import 'data/repositories/qizhengsiyu_pan_repository.dart';
import 'di.dart';
import 'domain/managers/hua_yao_manager.dart';
import 'domain/managers/shen_sha_manager.dart';
import 'domain/managers/zhou_tian_model_manager.dart';
import 'domain/usecases/calculate_fate_dong_wei_usecase.dart';
import 'domain/usecases/save_calculated_panel_usecase.dart';

class NavigatorGenerator {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
  static Logger logger = Logger();
  static final routes = {
    // "/qizhengsiyu": (context, {arguments}) => PrimaryPage(),
    // "/qizhengsiyu": (context, {arguments}) => BeautyPage(),
    // "/qizhengsiyu": (context, {arguments}) => MultiProvider(
    //       providers: [
    //         ChangeNotifierProvider<PanelConfigViewModel>(
    //             create: (context) => PanelConfigViewModel(context)),
    //       ],
    //       child: const QiZhengSiYuConfigPage(),
    //       // child: ShiJiaQiMenViewPage(),
    //     ),
    // "/qizhengsiyu/panel": (context, {arguments}) => MultiProvider(
    //       providers: [
    //         ChangeNotifierProvider<BeautyPageViewModel>(
    //             create: (context) => BeautyPageViewModel()..init()),
    //       ],
    //       child: const BeautyViewPage(),
    //       // child: ShiJiaQiMenViewPage(),
    //     ),
    // "/qizhengsiyu/panel": (context, {arguments}) =>
    //     BeautyViewPage(params: BeautyViewPageParams.devDefault)

    "/qizhengsiyu/panel": (context, {arguments}) =>MultiProvider(      providers: [
      ...createProviders(),
      Provider<AppDatabase>(
        create: (ctx) => AppDatabase(),
        dispose: (ctx, db) => db.close(),
      ),
      Provider<IQiZhengSiYuPanRepository>(
        create: (ctx) => QiZhengSiYuPanRepository(
          appDatabase: ctx.read<AppDatabase>(),
        ),
      ),
      Provider<SaveCalculatedPanelUseCase>(
          create: (ctx) => SaveCalculatedPanelUseCase(
              qiZhengSiYuPanRepository: ctx.read<IQiZhengSiYuPanRepository>())),
      ChangeNotifierProvider<BeautyPageViewModel>(
          create: (ctx) => BeautyPageViewModel(
            calculateFateDongWeiUseCase: CalculateFateDongWeiUseCase(),
            saveCalculatedPanelUseCase:
            ctx.read<SaveCalculatedPanelUseCase>(),
            shenShaManager: ctx.read<ShenShaManager>(),
            huaYaoManager: ctx.read<HuaYaoManager>(),
            zhouTianModelManager: ctx.read<ZhouTianModelManager>(),
          )),
      ChangeNotifierProvider<QiZhengSiYuViewModel>(
          create: (ctx) => QiZhengSiYuViewModel(
            shenShaManager: ctx.read<ShenShaManager>(),
            huaYaoManager: ctx.read<HuaYaoManager>(),
            zhouTianModelManager: ctx.read<ZhouTianModelManager>(),
          )),
    ],
        child:BeautyViewPage(params: BeautyViewPageParams.devDefault))
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
      case '/qizhengsiyu/primary':
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
