/// 错误组件
///
/// 提供统一的错误状态显示
library;

import 'package:flutter/material.dart';

/// 自定义错误组件
class CustomErrorWidget extends StatelessWidget {
  /// 错误消息
  final String message;

  /// 重试回调
  final VoidCallback? onRetry;

  /// 是否显示详细信息
  final bool showDetails;

  /// 详细错误信息
  final String? details;

  /// 错误图标
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.showDetails = false,
    this.details,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 错误图标
            Icon(
              icon ?? Icons.error_outline,
              size: 64.0,
              color: theme.colorScheme.error,
            ),
            
            const SizedBox(height: 16.0),
            
            // 错误标题
            Text(
              '出现错误',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8.0),
            
            // 错误消息
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            
            // 详细信息
            if (showDetails && details != null) ...[
              const SizedBox(height: 16.0),
              _buildDetailsSection(theme),
            ],
            
            // 重试按钮
            if (onRetry != null) ...[
              const SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建详细信息部分
  Widget _buildDetailsSection(ThemeData theme) {
    return ExpansionTile(
      title: Text(
        '查看详细信息',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Text(
            details!,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}

/// 简单错误组件
class SimpleErrorWidget extends StatelessWidget {
  /// 错误消息
  final String message;

  /// 重试回调
  final VoidCallback? onRetry;

  const SimpleErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
            size: 20.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8.0),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              iconSize: 20.0,
              color: theme.colorScheme.primary,
              tooltip: '重试',
            ),
          ],
        ],
      ),
    );
  }
}