import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 自定义按钮样式
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonSize size;

  CustomButton({required this.text, required this.onPressed, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double width = 0;
    double height = 0;
    double fontSize = 0;
    if (size == ButtonSize.small) {
      width = 80;
      height = 40;
      fontSize = 14;
    } else if (size == ButtonSize.medium) {
      width = 120;
      height = 50;
      fontSize = 16;
    } else if (size == ButtonSize.large) {
      width = 160;
      height = 60;
      fontSize = 18;
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: theme.colorScheme.onPrimaryContainer, backgroundColor: theme.colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
              color: theme.colorScheme.outlineVariant, width: 2),
        ),
        minimumSize: Size(width, height),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'NotoSansSC',
          fontSize: fontSize,
        ),
      ),
    );
  }
}

enum ButtonSize { small, medium, large }

// 自定义输入框样式
class CustomInputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  CustomInputField({required this.hintText, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'NotoSansSC',
          color: theme.colorScheme.outline,
          fontSize: 14,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: theme.colorScheme.outlineVariant, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(
        fontFamily: 'NotoSansSC',
        color: theme.colorScheme.onSurface,
        fontSize: 16,
      ),
    );
  }
}

// 自定义卡片样式
class CustomCard extends StatelessWidget {
  final Widget child;

  CustomCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: theme.colorScheme.surfaceVariant,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: child,
      ),
    );
  }
}

// 首页
class HomePage extends StatelessWidget {
  final ThemeProvider themeProvider;

  HomePage({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          '命理占卜',
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode
                ? Icons.wb_sunny_outlined
                : Icons.nights_stay_outlined),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton2(
              text: '八字测算',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BaZiPage()),
                );
              },
              size: ButtonSize.large,
            ),
            SizedBox(height: 32),
            CustomButton(
              text: '大六壬',
              onPressed: () {},
              size: ButtonSize.large,
            ),
            SizedBox(height: 32),
            CustomButton(
              text: '风水布局',
              onPressed: () {},
              size: ButtonSize.large,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
            label: '社区',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
            label: '我的',
          ),
        ],
      ),
    );
  }

}
// 自定义按钮样式
class CustomButton2 extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonSize size;

  CustomButton2({required this.text, required this.onPressed, required this.size});

  @override
  _CustomButton2State createState() => _CustomButton2State();
}

class _CustomButton2State extends State<CustomButton2> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double width = 0;
    double height = 0;
    double fontSize = 0;
    EdgeInsetsGeometry padding = EdgeInsets.zero;
    if (widget.size == ButtonSize.small) {
      width = 80;
      height = 40;
      fontSize = 14;
      padding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else if (widget.size == ButtonSize.medium) {
      width = 120;
      height = 50;
      fontSize = 16;
      padding = EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    } else if (widget.size == ButtonSize.large) {
      width = 160;
      height = 60;
      fontSize = 18;
      padding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: theme.colorScheme.onPrimaryContainer, backgroundColor: _isHovered
              ? theme.colorScheme.primaryContainer.withOpacity(0.8)
              : theme.colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: theme.colorScheme.outlineVariant, width: 2),
          ),
          minimumSize: Size(width, height),
          padding: padding,
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}

// 八字测算页面
class BaZiPage extends StatelessWidget {
  final TextEditingController yearController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController hourController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '八字测算',
          style: TextStyle(
            fontFamily: 'NotoSansSC',
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: CustomInputField(
                  hintText: '请输入出生年份',
                  controller: yearController,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: CustomInputField(
                  hintText: '请输入出生月份',
                  controller: monthController,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: CustomInputField(
                  hintText: '请输入出生日期',
                  controller: dayController,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: CustomInputField(
                  hintText: '请输入出生时辰',
                  controller: hourController,
                ),
              ),
              SizedBox(height: 32),
              CustomButton(
                text: '开始测算',
                onPressed: () {},
                size: ButtonSize.large,
              ),
              SizedBox(height: 32),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '测算结果',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '这里将显示八字测算的详细结果。',
                      style: TextStyle(
                        fontFamily: 'NotoSansSC',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFF2E5C9),
      primary: Color(0xFFF2E5C9),
      primaryContainer: Color(0xFFF2E5C9),
      onPrimaryContainer: Color(0xFF333333),
      surface: Colors.white,
      onSurface: Color(0xFF333333),
      surfaceVariant: Color(0xFFF9F5EE),
      onSurfaceVariant: Color(0xFF333333),
      outline: Color(0xFF999999),
      outlineVariant: Color(0xFFD1C2AE),
      background: Color(0xFFF9F5EE),
    ),
    fontFamily: 'NotoSansSC',
  ).copyWith(
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'NotoSansSC',
        fontSize: 20,
        color: Color(0xFF333333),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF333333),
      primary: Color(0xFF333333),
      primaryContainer: Color(0xFF444444),
      onPrimaryContainer: Color(0xFFF2E5C9),
      surface: Color(0xFF111111),
      onSurface: Color(0xFFF2E5C9),
      surfaceVariant: Color(0xFF222222),
      onSurfaceVariant: Color(0xFFF2E5C9),
      outline: Color(0xFF666666),
      outlineVariant: Color(0xFF444444),
      background: Color(0xFF111111),
    ),
    fontFamily: 'NotoSansSC',
  ).copyWith(
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'NotoSansSC',
        fontSize: 20,
        color: Color(0xFFF2E5C9),
      ),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode =!_isDarkMode;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  MyApp({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '命理占卜 APP',
      theme: themeProvider.isDarkMode
          ? AppThemes.darkTheme
          : AppThemes.lightTheme,
      home: HomePage(themeProvider: themeProvider),
    );
  }
}

void main() {
  // 注册免费开源可商用字体
  FontLoader('NotoSansSC-Regular').load().then((_) {
    final themeProvider = ThemeProvider();
    runApp(MyApp(themeProvider: themeProvider));
  });
}
