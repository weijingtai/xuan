/// 皇极取数法结果展示组件
///
/// 显示皇极取数法的最终计算结果
library;

import 'package:flutter/material.dart';
import 'package:tiebanshenshu/domain/models/multi_base_number_result.dart';
import 'package:tiebanshenshu/presentation/widgets/tiao_wen_item.dart';

import '../viewmodels/huang_ji_interactive_view_model.dart';
import 'tiao_wen_list_view.dart';

/// 皇极取数法结果展示组件
class HuangJiResultWidget extends StatelessWidget {
  /// Provider实例
  final HuangJiInteractiveViewModel provider;

  const HuangJiResultWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = provider.finalResult;

    if (result == null) {
      return _buildNoResultContent(theme);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 结果头部
          _buildResultHeader(theme),

          const SizedBox(height: 16.0),

          // 计算摘要
          _buildCalculationSummary(theme),

          const SizedBox(height: 16.0),

          // 条文列表
          Expanded(child: _buildTiaoWenList(context, result)),
        ],
      ),
    );
  }

  /// 构建无结果内容
  Widget _buildNoResultContent(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.0,
              color: theme.colorScheme.outline,
            ),

            const SizedBox(height: 16.0),

            Text(
              '暂无结果',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),

            const SizedBox(height: 8.0),

            Text(
              '计算尚未完成或出现错误',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建结果头部
  Widget _buildResultHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 24.0),

          const SizedBox(width: 12.0),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '皇极取数法计算完成',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4.0),

                Text(
                  '已生成 ${provider.finalNumbers.length} 个条文数',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建计算摘要
  Widget _buildCalculationSummary(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.dividerColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '计算摘要',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12.0),

          // 计算信息网格
          _buildSummaryGrid(theme),
        ],
      ),
    );
  }

  /// 构建摘要网格
  Widget _buildSummaryGrid(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                theme,
                '初刻数',
                provider.initialNumber?.toString() ?? '--',
                Icons.looks_one,
              ),
            ),

            const SizedBox(width: 12.0),

            Expanded(
              child: _buildSummaryItem(
                theme,
                '次条文数',
                provider.secondaryNumber?.toString() ?? '--',
                Icons.looks_two,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12.0),

        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                theme,
                '选择的基础数',
                provider.selectedBaseNumber?.toString() ?? '--',
                Icons.star,
              ),
            ),

            const SizedBox(width: 12.0),

            Expanded(
              child: _buildSummaryItem(
                theme,
                '条文数量',
                provider.finalNumbers.length.toString(),
                Icons.list,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建摘要项
  Widget _buildSummaryItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20.0),

          const SizedBox(height: 8.0),

          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4.0),

          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建条文列表
  Widget _buildTiaoWenList(BuildContext context, MultiBaseNumberResult result) {
    print("--------- ${result}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '条文列表',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8.0),

        Expanded(
          child: TiaoWenListView(
            tiaoWenList: result.tiaoWenEntities != null ? result.tiaoWenEntities!
                .map(
                  (e) => TiaoWenItem(
                    number: e.id,
                    content: e.content1,
                    ageInfo: e.ageSet1 != null ? e.ageSet1!.join(", ") : '--',
                  ),
                )
                .toList() : [],
            result: null, // TiaoWenListView 需要 UITiaoWenListResultModel，这里传 null
          ),
        ),
      ],
    );
  }
}
