import 'package:flutter/material.dart';
import 'package:common/viewmodels/editable_four_zhu_theme_controller.dart';

/// 装饰与主题适配层：为 EditableFourZhuCard 提供通用装饰生成函数。
///
/// 职责：
/// - 统一从 `Theme.of(context)` 解析颜色与边框样式；
/// - 提供列/行插入指示线的装饰生成；
/// - 便于后续扩展其他装饰（删除意图高亮、网格分隔等）。
class CardDecorators {
  /// 生成“列插入指示线”装饰。
  ///
  /// 参数：
  /// - context: 上下文，用于解析主题颜色。
  /// - isHover: 当前是否处于悬停态（悬停显示主色边框，否则透明）。
  /// 返回：
  /// - `Decoration`：用于插入线的装饰（边框）。
  static Decoration buildColumnInsertDecoration(
    BuildContext context, {
    required bool isHover,
    EditableFourZhuThemeController? controller,
    Color? color,
  }) {
    // 优先级：显式 color 参数 > 主题控制器解析 > 系统主题色
    final brightness = Theme.of(context).brightness;
    final Color borderColor = color ??
        controller?.resolveCardBorderColorBy(brightness) ??
        Theme.of(context).colorScheme.secondary.withOpacity(0.25);
    final double width = controller?.theme.cell.defaultBorderWidth ?? 1.5;
    return BoxDecoration(
      border: isHover
          ? Border.all(color: borderColor, width: width)
          : Border.all(color: Colors.transparent, width: 0),
    );
  }

  /// 生成“行插入指示线”装饰。
  ///
  /// 参数：
  /// - context: 上下文，用于解析主题颜色。
  /// - isHover: 当前是否处于悬停态（悬停显示主色边框，否则透明）。
  /// 返回：
  /// - `Decoration`：用于插入线的装饰（边框）。
  static Decoration buildRowInsertDecoration(
    BuildContext context, {
    required bool isHover,
    EditableFourZhuThemeController? controller,
    Color? color,
  }) {
    final brightness = Theme.of(context).brightness;
    final Color borderColor = color ??
        controller?.resolveCardBorderColorBy(brightness) ??
        Theme.of(context).colorScheme.primary.withOpacity(0.25);
    final double width = controller?.theme.cell.defaultBorderWidth ?? 1.5;
    return BoxDecoration(
      border: isHover
          ? Border.all(color: borderColor, width: width)
          : Border.all(color: Colors.transparent, width: 0),
    );
  }

  /// 生成“删除意图高亮”装饰。
  ///
  /// 用途：当拖拽物离开卡片可接收区域时，显示红色边框提示删除行为。
  /// 参数：
  /// - context: 上下文，用于解析主题的错误颜色 `colorScheme.error`。
  /// - borderRadius: 边框圆角，默认 `12`，与卡片圆角一致。
  /// - borderWidth: 边框宽度，默认 `2`。
  /// 返回：
  /// - `Decoration`：用于覆盖层的红色边框装饰。
  static Decoration buildDeleteIntentDecoration(
    BuildContext context, {
    double borderRadius = 12,
    double borderWidth = 2,
    EditableFourZhuThemeController? controller,
    Color? color,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: color ?? Theme.of(context).colorScheme.error,
        width: controller?.theme.cell.defaultBorderWidth ?? borderWidth,
      ),
    );
  }

  /// 生成“行分隔线”装饰（顶部边框）。
  ///
  /// 用途：在行之间绘制分隔线，统一使用 `Theme.of(context).dividerColor`。
  /// 参数：
  /// - context: 上下文，用于解析分隔线颜色。
  /// - thickness: 线条厚度（像素）。
  /// 返回：
  /// - `Decoration`：仅包含顶部边框的装饰。
  static Decoration buildRowSeparatorDecoration(
    BuildContext context, {
    required double thickness,
    EditableFourZhuThemeController? controller,
    Color? color,
  }) {
    return BoxDecoration(
      border: Border(
        top: BorderSide(
          color: color ??
              controller?.resolveCardBorderColor() ??
              Theme.of(context).dividerColor,
          width: thickness,
        ),
      ),
    );
  }

  /// 生成“列分隔线”装饰（左侧边框）。
  ///
  /// 用途：在列之间绘制分隔线，统一使用 `Theme.of(context).dividerColor`。
  /// 参数：
  /// - context: 上下文，用于解析分隔线颜色。
  /// - thickness: 线条厚度（像素）。
  /// 返回：
  /// - `Decoration`：仅包含左侧边框的装饰。
  static Decoration buildColumnSeparatorDecoration(
    BuildContext context, {
    required double thickness,
    EditableFourZhuThemeController? controller,
    Color? color,
  }) {
    return BoxDecoration(
      border: Border(
        left: BorderSide(
          color: color ??
              controller?.resolveCardBorderColor() ??
              Theme.of(context).dividerColor,
          width: thickness,
        ),
      ),
    );
  }
}
