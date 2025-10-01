import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'di/dependency_injection.dart';
import 'presentation/views/da_liu_ren_view.dart';
import './pages/my_home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // 切换到旧版UI: 注释掉下面的 MultiProvider，取消注释 MaterialApp (旧版)

    // ===== 新版 MVVM UI =====
    //return MultiProvider(
    //providers: DependencyInjection.getProviders(),
    //child: MaterialApp(
    //title: '大六壬 - MVVM',
    //theme: ThemeData(
    //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //useMaterial3: true,
    //),
    //home: const DaLiuRenView(),
    //),
    //);

    // ===== 旧版 UI (取消注释使用) =====
    return MaterialApp(
      title: '大六壬 - 旧版',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '大六壬'),
    );
  }
}
