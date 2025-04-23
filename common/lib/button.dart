import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() => runApp(
  ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, child) => MaterialApp(
      title: '水墨按钮',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB22222),
          secondary: const Color(0xFF4A312C),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'ZCOOLKuHei',
            letterSpacing: 2.0,
          ),
        ),
      ),
      home: const HomeScreen(),
    ),
  ),
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('无障碍水墨按钮'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            return Semantics(
              container: true,
              label: "占卜功能入口按钮",
              hint: "双击激活",
              child: ExcludeSemantics(
                child: InkStyleButton(
                  minWidth: maxWidth.clamp(40.w, 80.w),
                  height: 56.h,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class InkStyleButton extends StatelessWidget {
  final double minWidth;
  final double height;

  const InkStyleButton({
    super.key,
    required this.minWidth,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: "占卜启程按钮",
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick(); // 触觉反馈
        },
        child: AspectRatio(
          aspectRatio: 1.618,
          child: Container(
            constraints: BoxConstraints(
              minWidth: minWidth,
              maxWidth: 400.w,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.r),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(32.r),
                onTap: () {},
                splashColor: Colors.black.withOpacity(0.1),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    '占卜启程',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16.sp,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    semanticsLabel: "开启占卜之旅",
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}