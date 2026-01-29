/// 元堂卦流年卦展示列表组件
///
/// 用于展示单个大运期内的所有流年卦，支持点击展开流月详情
library;

import 'package:flutter/material.dart';
import '../../domain/models/yuan_tang_base_number_model.dart';
import 'gua_change_visualization.dart';

/// 流年卦展示列表组件
///
/// 展示单个大运期的所有流年卦（6-9个），每个流年卡片显示：
/// - 年龄
/// - 卦象可视化（使用GuaChangeVisualization）
/// - 变爻标注
/// - 支持点击展开流月详情（通过回调）
class YuanTangLiunianList extends StatelessWidget {
  /// 大运期信息
  final YuanTangDayunPeriod dayunPeriod;

  /// 流年卦列表（该大运期的所有流年卦）
  final List<YuanTangLiunianGua> liunianList;

  /// 卦象来源标签（"先天卦" / "后天卦"）
  final String guaSource;

  /// 强调色（先天卦/后天卦使用不同颜色）
  final Color accentColor;

  /// 点击流年卡片的回调（返回年龄，用于展开流月详情）
  final void Function(int age)? onLiunianTap;

  /// 是否显示大运期标题
  final bool showDayunTitle;

  const YuanTangLiunianList({
    super.key,
    required this.dayunPeriod,
    required this.liunianList,
    required this.guaSource,
    required this.accentColor,
    this.onLiunianTap,
    this.showDayunTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 大运期标题
        if (showDayunTitle) ...[
          _buildDayunHeader(theme),
          const SizedBox(height: 12.0),
        ],

        // 流年卦横向滚动列表
        SizedBox(
          height: 200.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: liunianList.length,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            separatorBuilder: (_, __) => const SizedBox(width: 12.0),
            itemBuilder: (context, index) {
              final liunianGua = liunianList[index];
              return _buildLiunianCard(context, liunianGua, theme);
            },
          ),
        ),
      ],
    );
  }

  /// 构建大运期标题
  Widget _buildDayunHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timeline, size: 20.0, color: accentColor),
          const SizedBox(width: 8.0),
          Text(
            '${dayunPeriod.yaoLabel}爻大运',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: dayunPeriod.yinYang == '阳'
                  ? Colors.blue.withOpacity(0.15)
                  : Colors.purple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              '${dayunPeriod.yinYang}爻',
              style: theme.textTheme.labelSmall?.copyWith(
                color: dayunPeriod.yinYang == '阳' ? Colors.blue : Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            '${dayunPeriod.ageRange}岁',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 4.0),
          Text(
            '(${dayunPeriod.years}年)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个流年卡片
  Widget _buildLiunianCard(
    BuildContext context,
    YuanTangLiunianGua liunianGua,
    ThemeData theme,
  ) {
    final isFirstYear = liunianGua.isFirstYearOfDayun;
    final hasChange = liunianGua.changedYaoIndex != -1;

    return GestureDetector(
      onTap: onLiunianTap != null ? () => onLiunianTap!(liunianGua.age) : null,
      child: Card(
        elevation: isFirstYear ? 4.0 : 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: isFirstYear
              ? BorderSide(color: accentColor, width: 2.0)
              : BorderSide.none,
        ),
        child: Container(
          width: 160.0,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 年龄标签
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${liunianGua.age}岁',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  if (isFirstYear) ...[
                    const SizedBox(width: 4.0),
                    Icon(Icons.star, size: 16.0, color: accentColor),
                  ],
                ],
              ),
              const SizedBox(height: 8.0),

              // 卦象可视化
              Expanded(
                child: Center(
                  child: GuaChangeVisualization(
                    gua: liunianGua.gua.name,
                    changedYaoIndex: hasChange
                        ? liunianGua.changedYaoIndex
                        : null,
                    showGuaName: true,
                    sourceLabel: null, // 不显示来源标签（已在大运标题显示）
                    accentColor: accentColor,
                  ),
                ),
              ),

              // 变化说明
              const SizedBox(height: 8.0),
              if (hasChange)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    '变${liunianGua.yaoLabel}爻',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    '未变换',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),

              // 点击提示
              if (onLiunianTap != null) ...[
                const SizedBox(height: 4.0),
                Icon(
                  Icons.touch_app,
                  size: 14.0,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 流年卡片紧凑型组件
///
/// 更简洁的流年卡片，用于空间受限的场景
class YuanTangLiunianCompactCard extends StatelessWidget {
  /// 流年卦信息
  final YuanTangLiunianGua liunianGua;

  /// 强调色
  final Color accentColor;

  /// 点击回调
  final VoidCallback? onTap;

  const YuanTangLiunianCompactCard({
    super.key,
    required this.liunianGua,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasChange = liunianGua.changedYaoIndex != -1;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${liunianGua.age}岁',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                liunianGua.gua.fullname,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasChange) ...[
                const SizedBox(height: 2.0),
                Text(
                  '变${liunianGua.yaoLabel}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accentColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
