import 'package:flutter/material.dart';
import 'package:common/pages/editable_four_zhu_card_demo_page.dart';
import 'package:xuan/dev_style_preview.dart' show DevStylePreviewHomePage;

/// 统一预览入口：整合「样式集中化联动预览」与「EditableFourZhuCardV3 Demo」。
///
/// - 目标：减少分散入口与重复运行，统一在一个应用中切换两类预览；
/// - 使用：`flutter run -d web-server -t lib/dev_unified_preview.dart --web-port 60087`；
/// - 说明：顶部 `TabBar` 提供两页切换，左页为样式集中化联动预览，右页为 V3 卡片 Demo。
void main() {
  runApp(const DevUnifiedPreviewApp());
}

/// 统一预览应用壳组件。
///
/// 提供 `MaterialApp` 与基础主题，首页为 `DevUnifiedPreviewHome`，承载两个预览页签。
class DevUnifiedPreviewApp extends StatelessWidget {
  const DevUnifiedPreviewApp({super.key});

  /// 构建应用根部件。
  ///
  /// 返回：`MaterialApp`，启用 Material3 并设置种子配色，主页为统一预览首页。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unified Preview · Styles & FourZhu Card',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DevUnifiedPreviewHome(),
    );
  }
}

/// 统一预览首页组件。
///
/// 通过 `TabBar`/`TabBarView` 提供两页预览：
/// - 「样式集中化 · 联动预览」：验证分组样式编辑输出在集中化解析中的生效；
/// - 「Editable FourZhuCard V3 · Demo」：演示卡片的行内容、拖拽、分组字体解析等交互。
class DevUnifiedPreviewHome extends StatelessWidget {
  const DevUnifiedPreviewHome({super.key});

  /// 构建包含两个页签的统一预览界面。
  ///
  /// 返回：一个 `Scaffold`，顶部含 `TabBar`，主体为两个预览页的 `TabBarView`。
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('统一预览入口'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '样式集中化'),
              Tab(text: 'V3 卡片 Demo'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // 左页：样式集中化联动预览（复用现有预览页，实现避免重复逻辑）
            DevStylePreviewHomePage(),
            // 右页：EditableFourZhuCard 的独立演示页面
            SafeArea(child: EditableFourZhuCardDemoPage()),
          ],
        ),
      ),
    );
  }
}