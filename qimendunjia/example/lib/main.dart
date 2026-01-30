import 'package:common/common_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:qimendunjia/navigator.dart';
import 'package:qimendunjia/di/service_locator.dart';

Future<void> initServices() async {
  // 初始化时区数据
  tz.initializeTimeZones();

  // Web平台使用路径URL策略
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // 确保Flutter绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化服务定位器 (MVVM架构需要)
  serviceLocator.init();

  // 记录启动日志
  CommonLogger().logger.i("奇门遁甲模块已启动");
}

void main() async {
  // 初始化服务
  await initServices();

  // 启动应用
  runApp(const QiMenDunJiaApp());
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
        fontFamily: 'NotoSansSC-Regular',
      ),
      home: const SelectionPage(),
      // 使用项目的导航生成器
      onGenerateRoute: NavigatorGenerator.generateRoute,
      // 添加路由观察者用于调试
      navigatorObservers: [NavigatorGenerator.routeObserver],
      // 调试横幅设置
      debugShowCheckedModeBanner: false,
    );
  }
}

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('奇门遁甲架构选择')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/qimendunjia');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('老架构 (Direct View)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/qimendunjia/mvvm');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('新架构 (MVVM + UseCase)'),
            ),
          ],
        ),
      ),
    );
  }
}
