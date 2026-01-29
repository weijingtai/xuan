/// 交互式结果组件
///
/// 显示交互式计算的最终结果
library;

import 'package:flutter/material.dart';
import 'package:tiebanshenshu/presentation/widgets/tiao_wen_item.dart';

import '../viewmodels/tai_xuan_four_zhu_interactive_view_model.dart';
import '../widgets/tiao_wen_list_view.dart';

/// 交互式结果组件
class InteractiveResultWidget extends StatelessWidget {
  /// Provider实例
  final TaiXuanFourZhuInteractiveViewModel provider;

  /// 重新开始回调
  final VoidCallback onRestart;

  const InteractiveResultWidget({
    super.key,
    required this.provider,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final result = provider.finalResult;
    if (result == null) {
      return _buildNoResultState(context);
    }

    return Column(
      children: [
        // 结果头部
        _buildResultHeader(context, result),

        // 条文列表
        Expanded(child: _buildTiaoWenList(context, result)),

        // 操作按钮
        _buildActionButtons(context),
      ],
    );
  }

  /// 构建无结果状态
  Widget _buildNoResultState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64.0,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16.0),
          Text(
            '暂无计算结果',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建结果头部
  Widget _buildResultHeader(BuildContext context, dynamic result) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 成功图标和标题
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24.0),
              const SizedBox(width: 8.0),
              Text(
                '计算完成',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // 结果统计
          _buildResultStats(theme, result),
        ],
      ),
    );
  }

  /// 构建结果统计
  Widget _buildResultStats(ThemeData theme, dynamic result) {
    // 这里需要根据实际的MultiBaseNumberResult结构来获取数据
    final tiaoWenCount = result.allTiaoWenNumbers?.length ?? 0;
    final calculationMethod = result.algorithmName ?? '未知';

    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: [
        _buildStatItem(theme, Icons.list_alt, '条文数量', '$tiaoWenCount'),
        _buildStatItem(theme, Icons.calculate, '计算方法', calculationMethod),
        _buildStatItem(
          theme,
          Icons.access_time,
          '计算时长',
          provider.getSessionDurationText(),
        ),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16.0,
          color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
        ),
        const SizedBox(width: 4.0),
        Text(
          '$label: $value',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  /// 构建条文列表
  Widget _buildTiaoWenList(BuildContext context, dynamic result) {
    // 获取条文列表结果
    final multiBaseNumberResult = provider.finalResult;

    if (multiBaseNumberResult == null ||
        multiBaseNumberResult.tiaoWenEntities == null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '暂无条文数据',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      );
    }
    final tiaoWenList = multiBaseNumberResult.tiaoWenEntities!
        .map(
          (e) => TiaoWenItem(
            number: e.id,
            content: e.content1 ?? '',
            ageInfo: e.ageSet1?.join(" ") ?? '',
          ),
        )
        .toList();
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TiaoWenListView(tiaoWenList: tiaoWenList, result: null),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // 重新开始按钮
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text('重新开始'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),

          const SizedBox(width: 16.0),

          // 分享按钮
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _shareResult(context),
              icon: const Icon(Icons.share),
              label: const Text('分享结果'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 分享结果
  void _shareResult(BuildContext context) {
    // 实现分享功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('分享功能待实现')));
  }
}
