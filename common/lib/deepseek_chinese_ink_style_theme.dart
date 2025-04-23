import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: const MyApp(),
  ),
);

// 主题状态管理
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
// 主题数据模型
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFB93C5D), // 朱砂红
      secondary: Color(0xFF4A3F3C), // 墨黑
      tertiary: Color(0xFFEFF3F3), // 宣纸白
      background: Color(0xFFF5F0E6), // 米白基底
    ),
    textTheme: GoogleFonts.zcoolKuaiLeTextTheme().merge(TextTheme(
      bodyLarge: TextStyle(fontFamily: 'MaShanZheng'), // 辰宇落雁体
    )),
    extensions: [InkPaintingStyle.light],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF8B572A), // 暗铜色
      secondary: Color(0xFF4A3F3C),
      tertiary: Color(0xFF2A211C), // 深檀木
      brightness: Brightness.dark,
    ),
    extensions: [InkPaintingStyle.dark],
  );
}

// 自定义主题扩展（水墨风格参数）
class InkStyle extends ThemeExtension<InkStyle> {
  final double strokeWidth;
  final Color dryInk;
  final Gradient wetInk;

  const InkStyle({
    required this.strokeWidth,
    required this.dryInk,
    required this.wetInk,
  });

  @override
  InkStyle copyWith() => this;

  @override
  InkStyle lerp(ThemeExtension<InkStyle>? other, double t) => this;
}

// 主应用
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '水墨主题',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      // theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<ThemeProvider>().themeMode,
      home: const HomeScreen(),
    );
  }

  // 亮色主题
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6B4F4A),
        brightness: Brightness.light,
      ),
      extensions: [
        const InkStyle(
          strokeWidth: 2.0,
          dryInk: Color(0xFF4A3F3C),
          wetInk: LinearGradient(colors: [Color(0x334A3F3C), Colors.transparent]),
        ),
        InkPaintingStyle.light

      ],
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'ZCOOLKuHei', fontSize: 24),
        bodyLarge: TextStyle(fontFamily: 'NotoSansSC', fontSize: 16),
      ),
    );
  }

  // 暗色主题
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A3F3C),
        brightness: Brightness.dark,
      ),
      extensions: [
        const InkStyle(
          strokeWidth: 2.0,
          dryInk: Color(0xFFAAAAAA),
          wetInk: LinearGradient(colors: [Color(0x33AAAAAA), Colors.transparent]),
        ),
        InkPaintingStyle.dark,
      ],
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'ZCOOLKuHei', fontSize: 24),
        bodyLarge: TextStyle(fontFamily: 'NotoSansSC', fontSize: 16),
      ),
    );
  }
}

// 主页界面
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inkStyle = Theme.of(context).extension<InkStyle>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('水墨主题', style: TextStyle(fontFamily: 'MaShanZheng')),
        actions: const [ThemeSwitchButton()],
      ),
      body: Center(
        child: Column(
          children: [
            _buildModernCard(context),
            const SizedBox(height: 20),
            _buildInkButton(context, inkStyle),
            const SizedBox(height: 20),
            buildInkButton(context,text: "大六壬"),
            const SizedBox(height: 20),
            buildXuanPaperCard(context,child: Container(color:Colors.white,width: 256,height: 256,)),
          ],
        ),
      ),
    );
  }

  // 现代风格卡片
  Widget _buildModernCard(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text('易经卦象',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary
        ),
      ),
    );
  }

  // 水墨风格按钮
  Widget _buildInkButton(BuildContext context, InkStyle style) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: style.dryInk, width: style.strokeWidth),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      onPressed: () {},
      child: Text('开始占卜',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSecondary
        ),
      ),
    );
  }
  Widget buildInkButton(BuildContext context, {required String text}) {
    final style = Theme.of(context).extension<InkPaintingStyle>()!;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: style.dryInk, width: 2),
        gradient: style.inkDiffusion,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          splashColor: style.wetInk,
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ),
      ),
    );
  }

}

// 主题切换按钮
class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().themeMode == ThemeMode.dark;

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isDark
            ? const Icon(Icons.dark_mode, key: ValueKey('dark'))
            : const Icon(Icons.light_mode, key: ValueKey('light')),
      ),
      onPressed: () => context.read<ThemeProvider>().toggleTheme(),
    );
  }


}


// 水墨风格扩展
class InkPaintingStyle extends ThemeExtension<InkPaintingStyle> {
  final Color dryInk;    // 干墨色
  final Color wetInk;    // 湿墨色
  final Gradient inkDiffusion; // 水墨扩散渐变
  InkPaintingStyle({
    required this.dryInk,
    required this.wetInk,
    required this.inkDiffusion,
});

  static InkPaintingStyle get light => InkPaintingStyle(
      dryInk: Color(0xFF4A3F3C),
      wetInk: Color(0x664A3F3C),
      inkDiffusion: LinearGradient(colors: [Color(0x334A3F3C), Colors.transparent])
  );

  static InkPaintingStyle get dark => InkPaintingStyle(
      dryInk: Color(0xFFAAAAAA),
      wetInk: Color(0x33AAAAAA),
      inkDiffusion: LinearGradient(colors: [Color(0x33FFFFFF), Colors.transparent])
  );

  @override
  InkPaintingStyle copyWith() => this;

  @override
  InkPaintingStyle lerp(ThemeExtension<InkPaintingStyle>? other, double t) => this;
}
Widget buildXuanPaperCard(BuildContext context, {required Widget child}) {
  return Container(
    margin: EdgeInsets.all(16),
    decoration: BoxDecoration(
      // image: DecorationImage(
      //   image: AssetImage('assets/xuan_paper.png'), // 宣纸纹理
      //   fit: BoxFit.cover,
      // ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4)
        )
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: child,
      ),
    ),
  );
}