import 'package:flutter/material.dart';
import '../../domain/models/tiao_wen_list_state.dart';

/// Strategy卡片头部组件
/// 
/// 显示Strategy名称、状态指示器和操作按钮
class StrategyHeader extends StatelessWidget {
  /// Strategy标题
  final String title;
  
  /// 当前状态
  final TiaoWenListState state;
  
  /// 是否展开
  final bool isExpanded;
  
  /// 展开/收起回调
  final VoidCallback onToggle;
  
  /// 刷新回调
  final VoidCallback onRefresh;
  
  /// 摘要信息
  final String? summary;

  const StrategyHeader({
    super.key,
    required this.title,
    required this.state,
    required this.isExpanded,
    required this.onToggle,
    required this.onRefresh,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 状态指示器
            _buildStateIndicator(theme),
            const SizedBox(width: 12.0),
            
            // 标题和摘要
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (summary != null) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      summary!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // 刷新按钮
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              tooltip: '刷新',
            ),
            
            // 展开/收起按钮
            IconButton(
              onPressed: onToggle,
              icon: AnimatedRotation(
                turns: isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.expand_more),
              ),
              tooltip: isExpanded ? '收起' : '展开',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建状态指示器
  Widget _buildStateIndicator(ThemeData theme) {
    switch (state) {
      case TiaoWenListState.initial:
        return Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
        );
        
      case TiaoWenListState.loading:
        return SizedBox(
          width: 12.0,
          height: 12.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            color: theme.primaryColor,
          ),
        );
        
      case TiaoWenListState.success:
        return Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary,
          ),
        );
        
      case TiaoWenListState.error:
        return Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.error,
          ),
        );
    }
  }
}