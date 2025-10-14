/// 元堂卦流月卦展示面板组件
///
/// 用于展示某个流年的12个流月卦，支持按月份展开查看详情
library;

import 'package:flutter/material.dart';
import '../../domain/models/yuan_tang_base_number_model.dart';
import 'gua_change_visualization.dart';

/// 流月卦展示面板组件
///
/// 展示单个流年的12个流月卦，网格布局，每个流月卡片显示：
/// - 月份
/// - 阴阳属性（阳月/阴月）
/// - 卦象可视化
/// - 变爻标注
class YuanTangLiuyuePanel extends StatelessWidget {
  /// 流月卦列表（12个月）
  final List<YuanTangLiuyueGua> liuyueList;

  /// 标题（如"3岁流月卦"）
  final String? title;

  /// 强调色
  final Color accentColor;

  /// 是否显示标题
  final bool showTitle;

  /// 是否使用紧凑布局
  final bool compact;

  const YuanTangLiuyuePanel({
    super.key,
    required this.liuyueList,
    this.title,
    required this.accentColor,
    this.showTitle = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        if (showTitle && title != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_month, size: 18.0, color: accentColor),
                const SizedBox(width: 8.0),
                Text(
                  title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
        ],

        // 流月卦网格
        if (liuyueList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('暂无流月数据'),
            ),
          )
        else if (compact)
          _buildCompactGrid(context, theme)
        else
          _buildNormalGrid(context, theme),
      ],
    );
  }

  /// 构建正常网格（每行3个）
  Widget _buildNormalGrid(BuildContext context, ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: liuyueList.length,
      itemBuilder: (context, index) {
        final liuyueGua = liuyueList[index];
        return _buildLiuyueCard(context, liuyueGua, theme, false);
      },
    );
  }

  /// 构建紧凑网格（每行4个）
  Widget _buildCompactGrid(BuildContext context, ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.7,
        crossAxisSpacing: 6.0,
        mainAxisSpacing: 6.0,
      ),
      itemCount: liuyueList.length,
      itemBuilder: (context, index) {
        final liuyueGua = liuyueList[index];
        return _buildLiuyueCard(context, liuyueGua, theme, true);
      },
    );
  }

  /// 构建单个流月卡片
  Widget _buildLiuyueCard(
    BuildContext context,
    YuanTangLiuyueGua liuyueGua,
    ThemeData theme,
    bool isCompact,
  ) {
    final monthColor = liuyueGua.isYangMonth
        ? Colors.orange.shade700
        : Colors.indigo.shade700;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: monthColor.withOpacity(0.3), width: 1.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 6.0 : 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 月份标签
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${liuyueGua.month}月',
                  style:
                      (isCompact
                              ? theme.textTheme.labelMedium
                              : theme.textTheme.titleSmall)
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: monthColor,
                          ),
                ),
                const SizedBox(width: 4.0),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 3.0 : 4.0,
                    vertical: 1.0,
                  ),
                  decoration: BoxDecoration(
                    color: monthColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Text(
                    liuyueGua.monthTypeLabel,
                    style:
                        (isCompact
                                ? theme.textTheme.labelSmall
                                : theme.textTheme.labelSmall)
                            ?.copyWith(
                              color: monthColor,
                              fontSize: isCompact ? 9.0 : 10.0,
                            ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 4.0 : 6.0),

            // 卦象可视化
            if (isCompact)
              _buildCompactGuaDisplay(liuyueGua, theme)
            else
              Expanded(
                child: Center(
                  child: GuaChangeVisualization(
                    gua: liuyueGua.gua.name,
                    changedYaoIndex: liuyueGua.changedYaoIndex,
                    showGuaName: true,
                    sourceLabel: null,
                    accentColor: accentColor,
                    changeDescription: null,
                  ),
                ),
              ),

            // 变化说明
            SizedBox(height: isCompact ? 2.0 : 4.0),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 4.0 : 6.0,
                vertical: isCompact ? 2.0 : 3.0,
              ),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                '变${liuyueGua.yaoLabel}爻',
                style:
                    (isCompact
                            ? theme.textTheme.labelSmall
                            : theme.textTheme.labelSmall)
                        ?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: isCompact ? 9.0 : 10.0,
                        ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建紧凑型卦象显示（仅显示卦名）
  Widget _buildCompactGuaDisplay(YuanTangLiuyueGua liuyueGua, ThemeData theme) {
    return Text(
      liuyueGua.gua.fullname,
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

/// 流月卡片列表型组件
///
/// 以列表形式展示流月卦，更节省空间
class YuanTangLiuyueListWidget extends StatelessWidget {
  /// 流月卦列表
  final List<YuanTangLiuyueGua> liuyueList;

  /// 标题
  final String? title;

  /// 强调色
  final Color accentColor;

  const YuanTangLiuyueListWidget({
    super.key,
    required this.liuyueList,
    this.title,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8.0),
        ],
        if (liuyueList.isEmpty)
          const Text('暂无流月数据')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: liuyueList.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final liuyueGua = liuyueList[index];
              return _buildLiuyueListTile(context, liuyueGua, theme);
            },
          ),
      ],
    );
  }

  /// 构建流月列表项
  Widget _buildLiuyueListTile(
    BuildContext context,
    YuanTangLiuyueGua liuyueGua,
    ThemeData theme,
  ) {
    final monthColor = liuyueGua.isYangMonth
        ? Colors.orange.shade700
        : Colors.indigo.shade700;

    return ListTile(
      dense: true,
      leading: Container(
        width: 40.0,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${liuyueGua.month}月',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: monthColor,
              ),
            ),
            Text(
              liuyueGua.monthTypeLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: monthColor,
                fontSize: 9.0,
              ),
            ),
          ],
        ),
      ),
      title: Text(
        liuyueGua.gua.fullname,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '变${liuyueGua.yaoLabel}爻',
        style: theme.textTheme.labelSmall?.copyWith(color: accentColor),
      ),
      trailing: Icon(Icons.change_circle, size: 16.0, color: accentColor),
    );
  }
}

/// 流月简略展示组件
///
/// 以Chip形式横向展示所有流月卦，最节省空间
class YuanTangLiuyueChipsWidget extends StatelessWidget {
  /// 流月卦列表
  final List<YuanTangLiuyueGua> liuyueList;

  /// 标题
  final String? title;

  /// 强调色
  final Color accentColor;

  const YuanTangLiuyueChipsWidget({
    super.key,
    required this.liuyueList,
    this.title,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 6.0),
        ],
        if (liuyueList.isEmpty)
          const Text('暂无流月数据')
        else
          Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            children: liuyueList
                .map((liuyue) => _buildLiuyueChip(liuyue, theme))
                .toList(),
          ),
      ],
    );
  }

  /// 构建流月芯片
  Widget _buildLiuyueChip(YuanTangLiuyueGua liuyueGua, ThemeData theme) {
    final monthColor = liuyueGua.isYangMonth
        ? Colors.orange.shade700
        : Colors.indigo.shade700;

    return Chip(
      label: Text(
        '${liuyueGua.month}月:${liuyueGua.gua}',
        style: const TextStyle(fontSize: 11),
      ),
      avatar: CircleAvatar(
        backgroundColor: monthColor.withOpacity(0.2),
        child: Text(
          liuyueGua.isYangMonth ? '阳' : '阴',
          style: TextStyle(
            fontSize: 9,
            color: monthColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      visualDensity: VisualDensity.compact,
      backgroundColor: accentColor.withOpacity(0.05),
    );
  }
}
