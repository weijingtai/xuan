import 'package:flutter/material.dart';

/// Strategy演示页面样式定义
/// 
/// 提供统一的样式配置，支持主题切换和响应式布局
class StrategyDemoStyles {
  /// 卡片样式
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );
  
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  
  static const double cardElevation = 2.0;
  
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(12.0),
  );

  /// 间距定义
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  /// 图标尺寸
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  static const double iconSizeXL = 48.0;

  /// 条文编号圆圈尺寸
  static const double tiaoWenNumberSize = 40.0;
  static const double tiaoWenNumberSizeCompact = 24.0;

  /// 动画时长
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);

  /// 响应式断点
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  /// 获取响应式边距
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
    } else if (screenWidth < tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
    }
  }

  /// 获取响应式内边距
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return const EdgeInsets.all(16.0);
    } else if (screenWidth < tabletBreakpoint) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  /// 获取响应式列数
  static int getResponsiveColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return 1;
    } else if (screenWidth < tabletBreakpoint) {
      return 2;
    } else {
      return 3;
    }
  }

  /// 主题相关样式
  static BoxDecoration getCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: cardBorderRadius,
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withOpacity(0.1),
          blurRadius: 8.0,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// 状态指示器样式
  static BoxDecoration getStateIndicatorDecoration(
    BuildContext context,
    Color color,
  ) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 4.0,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  /// 标签样式
  static BoxDecoration getTagDecoration(
    BuildContext context,
    Color backgroundColor,
  ) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
    );
  }

  /// 分割线样式
  static BoxDecoration getDividerDecoration(BuildContext context) {
    final theme = Theme.of(context);
    
    return BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: theme.dividerColor,
          width: 0.5,
        ),
      ),
    );
  }

  /// 文本样式扩展
  static TextStyle? getTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle? getSubtitleStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.7),
    );
  }

  static TextStyle? getCaptionStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
    );
  }

  /// 按钮样式
  static ButtonStyle getElevatedButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 12.0,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }

  static ButtonStyle getTextButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }
}

/// 响应式布局辅助类
class ResponsiveLayout {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < StrategyDemoStyles.mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= StrategyDemoStyles.mobileBreakpoint && 
           width < StrategyDemoStyles.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= StrategyDemoStyles.tabletBreakpoint;
  }

  /// 获取适合的最大宽度
  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200.0;
    } else if (isTablet(context)) {
      return 800.0;
    } else {
      return double.infinity;
    }
  }
}