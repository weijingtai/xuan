import 'package:flutter/material.dart';
import '../../../domain/models/tiao_wen_result.dart';
import '../kao_ke_session_models.dart';

/// 最终结果展示Widget
///
/// 按计算方法分组展示条文结果,使用Tab分隔
class FinalResultDisplayWidget extends StatelessWidget {
  /// 按计算方法分组的条文结果
  final Map<KaoKeCalculationMethod, List<TiaoWenResult>> finalResults;

  const FinalResultDisplayWidget({
    super.key,
    required this.finalResults,
  });

  @override
  Widget build(BuildContext context) {
    if (finalResults.isEmpty) {
      return _buildEmptyState(context);
    }

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.auto_stories,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  '条文计算结果',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          // Tab视图
          Expanded(
            child: DefaultTabController(
              length: finalResults.length,
              child: Column(
                children: [
                  // Tab栏
                  TabBar(
                    tabs: finalResults.keys.map((method) {
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getMethodIcon(method), size: 18),
                            const SizedBox(width: 8),
                            Text(method.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  // Tab内容
                  Expanded(
                    child: TabBarView(
                      children: finalResults.entries.map((entry) {
                        return _buildMethodResults(
                          context,
                          entry.key,
                          entry.value,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodResults(
    BuildContext context,
    KaoKeCalculationMethod method,
    List<TiaoWenResult> results,
  ) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '${method.displayName}未找到条文结果',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildTiaoWenCard(context, result, index + 1);
      },
    );
  }

  Widget _buildTiaoWenCard(
    BuildContext context,
    TiaoWenResult result,
    int displayIndex,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            displayIndex.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              '条文 ${result.tiaoWenNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                result.formulaName,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          result.tiaoWenContent,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 条文内容
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result.tiaoWenContent,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                // 计算详情
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calculate,
                            size: 16,
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '计算详情',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.calculationDetail,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onTertiaryContainer,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无计算结果',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getMethodIcon(KaoKeCalculationMethod method) {
    switch (method) {
      case KaoKeCalculationMethod.baGuaJiaZe:
        return Icons.hub;
      case KaoKeCalculationMethod.liuYaoGanZhiHe:
        return Icons.balance;
    }
  }
}
