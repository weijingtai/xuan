import 'package:flutter/material.dart';
import 'package:qimendunjia/navigator.dart';
import 'package:qimendunjia/di/service_locator.dart';

void main() {
  // 初始化依赖注入
  serviceLocator.init();

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
      ),
      debugShowCheckedModeBanner: false,
      // 首页：架构选择页面
      home: const ArchitectureSelectionPage(),
      onGenerateRoute: NavigatorGenerator.generateRoute,
      navigatorObservers: [NavigatorGenerator.routeObserver],
    );
  }
}

/// 架构选择页面
///
/// 允许用户选择使用传统架构或MVVM+UseCase架构
class ArchitectureSelectionPage extends StatelessWidget {
  const ArchitectureSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('奇门遁甲'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '选择应用架构',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '本应用提供两种架构实现，功能相同',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),

              // 旧版架构卡片
              _buildArchitectureCard(
                context,
                title: '传统架构版本',
                subtitle: 'ViewModel + UI直接通信',
                description: '• 简单直接的状态管理\n• ViewModel直接处理业务逻辑\n• 适合快速开发和原型验证',
                color: Colors.blue,
                icon: Icons.layers,
                route: '/qimendunjia',
              ),

              const SizedBox(height: 24),

              // 新版架构卡片
              _buildArchitectureCard(
                context,
                title: 'MVVM+UseCase版本',
                subtitle: 'Clean Architecture分层架构',
                description: '• Domain层独立业务逻辑\n• UseCase封装用例场景\n• Repository模式分离数据层',
                color: Colors.green,
                icon: Icons.architecture,
                route: '/qimendunjia/mvvm',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchitectureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required IconData icon,
    required String route,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
