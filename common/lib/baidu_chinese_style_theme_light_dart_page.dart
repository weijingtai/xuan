// widget_example_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ====================== 主题状态管理 ======================
enum AppThemeMode { light, dark, system }

class ThemeManager extends ChangeNotifier {
  AppThemeMode _mode = AppThemeMode.system;
  static const String _prefKey = 'app_theme_mode';

  AppThemeMode get mode => _mode;
  bool get isDarkMode {
    if (_mode == AppThemeMode.system) {
      return WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    }
    return _mode == AppThemeMode.dark;
  }

  ThemeManager() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_prefKey) ?? AppThemeMode.system.index;
    _mode = AppThemeMode.values[index];
    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, mode.index);
  }

  void toggleTheme() {
    final newMode = isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    setTheme(newMode);
  }
}

// ====================== 主题数据扩展 ======================
class ChineseTheme extends ThemeExtension<ChineseTheme> {
  final Color cardBackground;
  final Color yinYangBorder;
  final Color hexagramActive;
  final TextStyle fortuneTextStyle;

  const ChineseTheme({
    required this.cardBackground,
    required this.yinYangBorder,
    required this.hexagramActive,
    required this.fortuneTextStyle,
  });

  @override
  ThemeExtension<ChineseTheme> copyWith() => this;

  @override
  ThemeExtension<ChineseTheme> lerp(
    ThemeExtension<ChineseTheme>? other, 
    double t
  ) => this;

  static ChineseTheme light() => ChineseTheme(
    cardBackground: const Color(0xFF3A2E28),
    yinYangBorder: const Color(0xFFD4AF37),
    hexagramActive: const Color(0xFFCD3700),
    fortuneTextStyle: const TextStyle(
      fontFamily: 'HanYiQinChuan',
      fontSize: 18,
      color: Color(0xFF3A2E28),
    ),
  );

  static ChineseTheme dark() => ChineseTheme(
    cardBackground: const Color(0xFF232220),
    yinYangBorder: const Color(0xFFA89B7C),
    hexagramActive: const Color(0xFFFF6B6B),
    fortuneTextStyle: const TextStyle(
      fontFamily: 'HanYiQinChuan',
      fontSize: 18,
      color: Color(0xFFD4CCC5),
    ),
  );
}

// ====================== 示例页面 ======================
class WidgetExamplePage extends StatelessWidget {
  const WidgetExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chineseTheme = Theme.of(context).extension<ChineseTheme>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text('易经卜卦', style: theme.textTheme.titleLarge),
        actions: [const _ThemeSwitchButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DivinationCard(theme: chineseTheme),
            const SizedBox(height: 24),
            const _HexagramGrid(),
            const SizedBox(height: 32),
            _FortuneButton(theme: chineseTheme),
          ],
        ),
      ),
    );
  }
}

// ====================== 主题切换按钮 ======================
class _ThemeSwitchButton extends StatelessWidget {
  const _ThemeSwitchButton();

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<ThemeManager>();
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          manager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          key: ValueKey(manager.isDarkMode),
        ),
      ),
      onPressed: () => manager.toggleTheme(),
    );
  }
}

// ====================== 占卜卡片组件 ======================
class _DivinationCard extends StatelessWidget {
  final ChineseTheme theme;

  const _DivinationCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.yinYangBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('今日卦象', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('天行健，君子以自强不息', 
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}

// ====================== 卦象按钮矩阵 ======================
class _HexagramGrid extends StatelessWidget {
  const _HexagramGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<ChineseTheme>()!;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: List.generate(6, (index) => _HexagramButton(
        symbol: ['☰', '☷', '☳', '☶', '☵', '☲'][index],
        activeColor: theme.hexagramActive,
      )),
    );
  }
}

// ====================== 单个卦象按钮 ======================
class _HexagramButton extends StatefulWidget {
  final String symbol;
  final Color activeColor;

  const _HexagramButton({required this.symbol, required this.activeColor});

  @override
  State<_HexagramButton> createState() => _HexagramButtonState();
}

class _HexagramButtonState extends State<_HexagramButton> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _active = !_active),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _active ? widget.activeColor.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: _active ? widget.activeColor : Colors.grey),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(widget.symbol, 
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: _active ? widget.activeColor : null
            )),
        ),
      ),
    );
  }
}

// ====================== 运势生成按钮 ======================
class _FortuneButton extends StatelessWidget {
  final ChineseTheme theme;

  const _FortuneButton({required this.theme});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.cardBackground,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: theme.yinYangBorder),
        ),
      ),
      onPressed: () {},
      child: Text('生成运势', style: theme.fortuneTextStyle),
    );
  }
}

// ====================== 主题配置 ======================
class AppThemes {
  static ThemeData lightTheme() => ThemeData.light().copyWith(
    extensions: [ChineseTheme.light()],
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 24, color: Color(0xFF3A2E28)),
      titleMedium: TextStyle(fontSize: 20, color: Color(0xFF3A2E28)),
      bodyMedium: TextStyle(color: Color(0xFF5C504A)),
    ),
  );

  static ThemeData darkTheme() => ThemeData.dark().copyWith(
    extensions: [ChineseTheme.dark()],
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 24, color: Color(0xFFD4CCC5)),
      titleMedium: TextStyle(fontSize: 20, color: Color(0xFFD4CCC5)),
      bodyMedium: TextStyle(color: Color(0xFFA89B7C)),
    ),
  );
}
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, manager, _) => MaterialApp(
        theme: AppThemes.lightTheme(),
        darkTheme: AppThemes.darkTheme(),
        debugShowCheckedModeBanner: false,
        themeMode: manager.mode == AppThemeMode.system
            ? ThemeMode.system
            : manager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const WidgetExamplePage(),
      ),
    );
  }
}
