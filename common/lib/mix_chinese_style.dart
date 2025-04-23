import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => ThemeModel(),
    child: const MyApp(),
  ),
);

// 主题状态管理（参考网页1）
class ThemeModel with ChangeNotifier {
  ThemeData _currentTheme = lightTheme;
  ThemeData get theme => _currentTheme;

  void toggleTheme() {
    _currentTheme = _currentTheme == lightTheme ? darkTheme : lightTheme;
    notifyListeners();
  }
}

// 主题配置系统（综合网页2、4、9）
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFB22222),    // 朱砂红
    secondary: Color(0xFF4A312C),   // 墨黑
    tertiary: Color(0xFFF5F0E6),    // 宣纸白
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF8F5F2), // 米色基底
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: 'ZCOOLXiaoWei', fontSize: 28), // 站酷小篆
    bodyLarge: TextStyle(fontFamily: 'FangSong', fontSize: 16),      // 仿宋
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF4A312C), width: 1)
    ),
    elevation: 4,
    shadowColor: Colors.black.withOpacity(0.1),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8B0000),     // 暗朱红
    secondary: Color(0xFF3E2723),   // 深檀木
    tertiary: Color(0xFF2D201E),    // 深灰
    surface: Color(0xFF1A1A1A),
    background: Color(0xFF242424), // 深色基底
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.white,
  ),
  textTheme: lightTheme.textTheme.apply(
      displayColor: Colors.white,
      bodyColor: Colors.white70
  ),
);

// 主应用结构（参考网页4）
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '水墨主题',
      theme: context.watch<ThemeModel>().theme,
      home: const HomeScreen(),
    );
  }
}

// 主页组件（整合网页5、10的交互设计）
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('易经占卜', style: TextStyle(fontFamily: 'ZCOOLXiaoWei')),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: theme.brightness == Brightness.light
                  ? const Icon(Icons.nightlight_round, key: ValueKey('dark'))
                  : const Icon(Icons.wb_sunny, key: ValueKey('light')),
            ),
            onPressed: () => context.read<ThemeModel>().toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            _buildChineseCard(context),
            const SizedBox(height: 24),
            _buildInkStyleButton(context),
          ],
        ),
      ),
    );
  }

  // 传统风格卡片（参考网页9、11）
  Widget _buildChineseCard(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
              color: Theme.of(context).colorScheme.secondary,
              width: 1.5
          )
      ),
      child: Text('乾为天，坤为地',
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary
        ),
      ),
    );
  }

  // 水墨风格按钮（参考网页10）
  Widget _buildInkStyleButton(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight
          ),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4)
            )
          ]
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () {},
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Text('开始占卜',
              style: TextStyle(
                  fontFamily: 'FangSong',
                  fontSize: 18,
                  color: Colors.white
              ),
            ),
          ),
        ),
      ),
    );
  }
}