import 'package:flutter/material.dart';
import 'dart:math';

// ====================== 主题颜色系统 ======================
class ChineseColors {
  // 五行基础色（HSL模式）
  static final wood = HSLColor.fromAHSL(1, 120, 0.3, 0.5).toColor();
  static final fire = HSLColor.fromAHSL(1, 15, 0.7, 0.6).toColor();
  static final earth = HSLColor.fromAHSL(1, 45, 0.4, 0.55).toColor();
  static final metal = HSLColor.fromAHSL(1, 60, 0.2, 0.7).toColor();
  static final water = HSLColor.fromAHSL(1, 210, 0.4, 0.5).toColor();
  
  // 阴阳色
  static final yang = Colors.white.withOpacity(0.9);
  static final yin = HSLColor.fromAHSL(1, 240, 0.1, 0.15).toColor();

  // 文字色
  static final textPrimary = yin.withOpacity(0.87);
  static final textSecondary = yin.withOpacity(0.6);
}

// ====================== 自定义主题扩展 ======================
class ChineseTheme extends ThemeExtension<ChineseTheme> {
  final Color cardBackground;
  final double cardRadius;
  final TextStyle titleStyle;

  const ChineseTheme({
    required this.cardBackground,
    required this.cardRadius,
    required this.titleStyle,
  });

  @override
  ThemeExtension<ChineseTheme> copyWith() => this;

  @override
  ThemeExtension<ChineseTheme> lerp(
    ThemeExtension<ChineseTheme>? other, 
    double t
  ) => this;
}

// ====================== 组件示例页面 ======================
class WidgetExamplePage extends StatelessWidget {
  const WidgetExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildContent(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        '易经卜卦',
        style: TextStyle(
          fontSize: responsiveSize(context, 24),
          color: ChineseColors.textPrimary,
          // 实际项目需加载自定义字体
          // fontFamily: 'HanYiQinChuan',
        ),
      ),
      backgroundColor: ChineseColors.yang,
      elevation: 2,
      shadowColor: ChineseColors.water.withOpacity(0.1),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: responsiveSize(context, 16),
        horizontal: responsiveSize(context, 24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildHorizontalLayout(context);
          } else {
            return _buildVerticalLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      children: [
        _buildDivinationCard(context),
        SizedBox(height: responsiveSize(context, 24)),
        _buildHexagramGrid(context),
        SizedBox(height: responsiveSize(context, 32)),
        _buildFortuneButton(context),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildDivinationCard(context),
        ),
        SizedBox(width: responsiveSize(context, 32)),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildHexagramGrid(context),
              SizedBox(height: responsiveSize(context, 32)),
              _buildFortuneButton(context),
            ],
          ),
        ),
      ],
    );
  }

  // ====================== 占卜卡片组件 ======================
  Widget _buildDivinationCard(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: responsiveSize(context, 180),
      ),
      padding: EdgeInsets.all(responsiveSize(context, 16)),
      decoration: BoxDecoration(
        color: ChineseColors.yin,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ChineseColors.water.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: ChineseColors.metal,
          width: 1.5,
        ),
      ),
      child: CustomPaint(
        painter: _InkSplashPainter(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日卦象',
              style: TextStyle(
                fontSize: responsiveSize(context, 20),
                color: ChineseColors.yang,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsiveSize(context, 12)),
            Text(
              '天行健，君子以自强不息',
              style: TextStyle(
                fontSize: responsiveSize(context, 16),
                color: ChineseColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================== 卦象按钮矩阵 ======================
  Widget _buildHexagramGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: responsiveSize(context, 16),
      crossAxisSpacing: responsiveSize(context, 16),
      childAspectRatio: 1,
      children: List.generate(6, (index) {
        return _HexagramButton(
          symbol: ['☰', '☷', '☳', '☶', '☵', '☲'][index],
          color: [
            ChineseColors.wood,
            ChineseColors.fire,
            ChineseColors.earth,
            ChineseColors.metal,
            ChineseColors.water,
            ChineseColors.fire,
          ][index],
        );
      }),
    );
  }

  // ====================== 运势生成按钮 ======================
  Widget _buildFortuneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: responsiveSize(context, 16),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsiveSize(context, 32)),
              side: BorderSide(
                color: ChineseColors.fire,
                width: 2,
              ),
            ),
            backgroundColor: ChineseColors.yang,
            elevation: 4,
          ),
          onPressed: () {},
          child: Text(
            '生成运势',
            style: TextStyle(
              fontSize: responsiveSize(context, 18),
              color: ChineseColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ====================== 响应式尺寸计算 ======================
  static double responsiveSize(BuildContext context, double baseSize) {
    final media = MediaQuery.of(context);
    final diagonal = sqrt(
      pow(media.size.width, 2) + pow(media.size.height, 2),
    );
    return baseSize * (diagonal / 1000);
  }
}

// ====================== 水墨效果绘制器 ======================
class _InkSplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          ChineseColors.water.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.2),
          radius: size.width * 0.3,
        ),
      )
      ..blendMode = BlendMode.overlay;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ====================== 卦象按钮组件 ======================
class _HexagramButton extends StatefulWidget {
  final String symbol;
  final Color color;

  const _HexagramButton({
    required this.symbol,
    required this.color,
  });

  @override
  _HexagramButtonState createState() => _HexagramButtonState();
}

class _HexagramButtonState extends State<_HexagramButton> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isActive = !_isActive),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          color: _isActive 
              ? widget.color.withOpacity(0.2) 
              : ChineseColors.yang,
          shape: BoxShape.circle,
          border: Border.all(
            color: _isActive ? widget.color : ChineseColors.metal,
            width: 1.5,
          ),
          boxShadow: _isActive
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: WidgetExamplePage.responsiveSize(context, 24),
              color: _isActive ? widget.color : ChineseColors.textPrimary,
            ),
            child: Text(widget.symbol),
          ),
        ),
      ),
    );
  }
}
