import 'package:flutter/material.dart';

/// 空状态组件
/// 
/// 提供统一的空状态显示，支持自定义图标、文本和操作按钮
class EmptyStateWidget extends StatelessWidget {
  /// 空状态图标
  final IconData? icon;
  
  /// 主要文本
  final String message;
  
  /// 描述文本
  final String? description;
  
  /// 操作按钮文本
  final String? actionText;
  
  /// 操作回调
  final VoidCallback? onAction;
  
  /// 图标大小
  final double iconSize;
  
  /// 是否显示图标
  final bool showIcon;

  const EmptyStateWidget({
    super.key,
    this.icon,
    required this.message,
    this.description,
    this.actionText,
    this.onAction,
    this.iconSize = 64.0,
    this.showIcon = true,
  });

  /// 无数据构造函数
  const EmptyStateWidget.noData({
    super.key,
    this.actionText,
    this.onAction,
  }) : icon = Icons.inbox_outlined,
       message = '暂无数据',
       description = '当前没有可显示的内容',
       iconSize = 64.0,
       showIcon = true;

  /// 无结果构造函数
  const EmptyStateWidget.noResults({
    super.key,
    this.actionText,
    this.onAction,
  }) : icon = Icons.search_off,
       message = '无搜索结果',
       description = '未找到符合条件的内容',
       iconSize = 64.0,
       showIcon = true;

  /// 无条文构造函数
  const EmptyStateWidget.noTiaoWen({
    super.key,
    this.actionText,
    this.onAction,
  }) : icon = Icons.article_outlined,
       message = '暂无条文',
       description = '当前策略未生成条文内容',
       iconSize = 64.0,
       showIcon = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 空状态图标
            if (showIcon) ...[
              Icon(
                icon ?? Icons.inbox_outlined,
                size: iconSize,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(height: 24.0),
            ],
            
            // 主要文本
            Text(
              message,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 描述文本
            if (description != null) ...[
              const SizedBox(height: 8.0),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // 操作按钮
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 12.0,
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 简单空状态组件
class SimpleEmptyWidget extends StatelessWidget {
  final String message;
  final IconData? icon;

  const SimpleEmptyWidget({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 48.0,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(height: 16.0),
            ],
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}