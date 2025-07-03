import 'package:common/common_logger.dart';
import 'package:common/database/app_database.dart' as db;
import 'package:common/database/world_info_database.dart' as db;
import 'package:common/datasource/geo_location_repository.dart';
import 'package:common/datasource/loca_binary/world_country_repository.dart';
import 'package:common/viewmodels/dev_enter_page_view_model.dart';
import 'package:common/viewmodels/timezone_location_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:qimendunjia/navigator.dart';
import 'package:common/enums.dart';

Future<void> initServices() async {
  // 初始化时区数据
  tz.initializeTimeZones();

  // Web平台使用路径URL策略
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // 确保Flutter绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 记录启动日志
  CommonLogger().logger.i("奇门遁甲模块已启动");
}

void main() async {
  // 初始化服务
  await initServices();

  // 启动应用
  runApp(const QiMenDunJiaApp());
  // runApp(
  //   MultiProvider(
  //     providers: [],
  //     // providers: [
  //     //   // 数据库提供者
  //     //   Provider<db.AppDatabase>(
  //     //     create: (ctx) => db.AppDatabase(),
  //     //     dispose: (ctx, db) => db.close(),
  //     //   ),
  //     //   Provider<db.WorldInfoDatabase>(
  //     //     create: (ctx) => db.WorldInfoDatabase(),
  //     //     dispose: (ctx, db) => db.close(),
  //     //   ),
  //     //   // 开发页面视图模型
  //     //   ListenableProvider<DevEnterPageViewModel>(
  //     //     create: (ctx) =>
  //     //         DevEnterPageViewModel(appDatabase: ctx.read<db.AppDatabase>())
  //     //           ..initState(),
  //     //   ),
  //     //   // 时区位置视图模型
  //     //   ListenableProvider<TimezoneLocationViewModel>(
  //     //     create: (ctx) => TimezoneLocationViewModel(
  //     //       appFeatureModule: AppFeatureModule.QiMenDunJia,
  //     //     ),
  //     //   ),
  //     // ],
  //     child: const QiMenDunJiaApp(),
  //   ),
  // );
}

class QiMenDunJiaApp extends StatelessWidget {
  const QiMenDunJiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '奇门遁甲',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        // 可以在这里添加更多主题配置
        fontFamily: 'NotoSansSC-Regular',
      ),
      // 设置初始路由为奇门遁甲主页面
      initialRoute: '/qimendunjia',
      // 使用项目的导航生成器
      onGenerateRoute: NavigatorGenerator.generateRoute,
      // 添加路由观察者用于调试
      navigatorObservers: [NavigatorGenerator.routeObserver],
      // 调试横幅设置
      debugShowCheckedModeBanner: false,
    );
  }
}
