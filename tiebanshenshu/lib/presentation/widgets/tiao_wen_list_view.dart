import 'package:flutter/material.dart';
import '../models/ui_tiao_wen_list_result_model.dart';
import 'tiao_wen_item.dart';
import 'empty_state_widget.dart';

/// 条文列表视图组件
class TiaoWenListView extends StatelessWidget {
  /// 条文列表数据
  final List<TiaoWenItem> tiaoWenList;

  /// 是否显示加载状态
  final bool isLoading;

  /// 错误消息
  final String? errorMessage;

  /// 重试回调
  final VoidCallback? onRetry;

  const TiaoWenListView({
    super.key,
    required this.tiaoWenList,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    required result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.0,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16.0),
            Text(
              errorMessage!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16.0),
              ElevatedButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ],
        ),
      );
    }

    if (tiaoWenList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48.0,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16.0),
            Text(
              '暂无条文数据',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiaoWenList.length,
      itemBuilder: (context, index) {
        return tiaoWenList[index];
      },
    );
  }
}

/// 条文列表头部组件
class TiaoWenHeader extends StatelessWidget {
  /// 总条文数量
  final int totalCount;

  /// 计算方法
  final String calculationMethod;

  const TiaoWenHeader({
    super.key,
    required this.totalCount,
    required this.calculationMethod,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.list_alt, size: 20.0, color: theme.colorScheme.primary),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              '条文列表 ($totalCount条)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              calculationMethod,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 紧凑型条文列表组件
class CompactTiaoWenListView extends StatelessWidget {
  final UITiaoWenListResultModel result;
  final int maxItems;

  const CompactTiaoWenListView({
    super.key,
    required this.result,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (result.tiaoWenCount == 0) {
      return const SimpleEmptyWidget(
        message: '暂无条文',
        icon: Icons.article_outlined,
      );
    }

    final items = result.tiaoWenItems.take(maxItems).toList();
    final hasMore = result.tiaoWenCount > maxItems;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          final item = items[index];
          return CompactTiaoWenItem(
            number: item.number,
            content: item.content,
            ageInfo: item.ageInfo,
          );
        } else {
          // 显示"还有更多"的提示
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '还有 ${result.tiaoWenCount - maxItems} 条...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          );
        }
      },
    );
  }
}
