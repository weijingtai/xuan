import 'package:flutter/material.dart';
import 'package:common/pages/editable_four_zhu_card_demo_page.dart';

/// 应用入口：仅加载 EditableFourZhuCardV3 的独立 Demo 页面。
///
/// 功能描述：
/// - 在调试/回归场景下，绕过主应用的其它页面与依赖编译错误；
/// - 直接挂载 `EditableFourZhuCardDemoPage` 进行交互与视觉验证；
/// - 保持最小化的路由与主题配置，避免干扰。
/// 参数说明：无。
/// 返回值：无（Flutter 应用入口）。
void main() {
  runApp(const _CardDemoApp());
}

/// 演示应用壳：提供基本的 `MaterialApp` 与 Scaffold 布局。
class _CardDemoApp extends StatelessWidget {
  const _CardDemoApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Editable Four Zhu Card · Demo',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(child: EditableFourZhuCardDemoPage()),
      ),
    );
  }
}