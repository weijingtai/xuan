import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/models/pillar_data.dart';
import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';

/// PillarTagBar - 底部 20% 高度的小型可拖拽 Tag 列表（含抓手 icon）
///
/// 功能：
/// - 以更紧凑的标签形式展示各“柱”入口
/// - 支持将标签拖拽到画布（DragTarget）以添加对应柱
/// - 标签内提供抓手图标（drag_indicator），更直观的拖拽提示
class PillarTagBar extends StatelessWidget {
  const PillarTagBar({super.key, this.disabledTypes = const {}});

  final Set<PillarType> disabledTypes;

  static const double _barHeight = 28;
  static const double _tagHeight = 28;
  static const double _tagWidth = 92;

  List<PillarData> get pillars => [
        const PillarData(
            pillarId: "separator_pillar",
            pillarType: PillarType.separator,
            label: "分割符号",
            jiaZi: JiaZi.JIA_ZI),
        const PillarData(
            pillarId: "title_pillar",
            pillarType: PillarType.rowTitleColumn,
            label: "标题柱",
            jiaZi: JiaZi.JIA_ZI),
        const PillarData(
            pillarId: 'pillar_pillar_year',
            label: '年',
            pillarType: PillarType.year,
            jiaZi: JiaZi.JIA_ZI),
        const PillarData(
            pillarId: 'pillar_month',
            label: '月',
            pillarType: PillarType.month,
            jiaZi: JiaZi.YI_CHOU),
        const PillarData(
            pillarId: 'pillar_day',
            label: '日',
            pillarType: PillarType.day,
            jiaZi: JiaZi.BING_YIN),
        const PillarData(
            pillarId: 'pillar_time',
            label: '时',
            pillarType: PillarType.hour,
            jiaZi: JiaZi.DING_MAO),
        const PillarData(
            pillarId: 'pillar_ke',
            label: '刻',
            pillarType: PillarType.ke,
            jiaZi: JiaZi.WU_CHEN),
        const PillarData(
            pillarId: 'pillar_dayun',
            pillarType: PillarType.luckCycle,
            label: '大运',
            jiaZi: JiaZi.JI_SI),
        const PillarData(
            pillarId: 'pillar_liunian',
            pillarType: PillarType.annual,
            label: '流年',
            jiaZi: JiaZi.GENG_WU),
        const PillarData(
            pillarId: 'pillar_liuyue',
            pillarType: PillarType.monthly,
            label: '流月',
            jiaZi: JiaZi.XIN_WEI),
        const PillarData(
            pillarId: 'pillar_liuri',
            pillarType: PillarType.daily,
            label: '流日',
            jiaZi: JiaZi.REN_SHEN),
        const PillarData(
            pillarId: 'pillar_liushi',
            pillarType: PillarType.hourly,
            label: '流时',
            jiaZi: JiaZi.GUI_YOU),
        const PillarData(
            pillarId: 'pillar_liuke',
            pillarType: PillarType.kely,
            label: '流刻',
            jiaZi: JiaZi.JIA_XU),
        const PillarData(
            pillarId: 'pillar_bodyHouse',
            pillarType: PillarType.bodyHouse,
            label: '身宫',
            jiaZi: JiaZi.JI_HAI),
        const PillarData(
            pillarId: 'pillar_lifeHouse',
            pillarType: PillarType.lifeHouse,
            label: '命宫',
            jiaZi: JiaZi.BING_ZI),
        const PillarData(
            pillarId: 'pillar_taiMeta',
            pillarType: PillarType.taiMeta,
            label: '胎元',
            jiaZi: JiaZi.JI_MAO),
        const PillarData(
            pillarId: 'pillar_taiDay',
            pillarType: PillarType.taiDay,
            label: '胎日',
            jiaZi: JiaZi.DING_CHOU),
        const PillarData(
            pillarId: 'pillar_taiMonth',
            pillarType: PillarType.taiMonth,
            label: '胎月',
            jiaZi: JiaZi.WU_YIN),
      ];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sort items: enabled first, disabled last.
    // Use stable partitioning to maintain relative order within groups.
    final enabledPillars =
        pillars.where((p) => !disabledTypes.contains(p.pillarType)).toList();
    final disabledPillarsList =
        pillars.where((p) => disabledTypes.contains(p.pillarType)).toList();
    final sortedPillars = [...enabledPillars, ...disabledPillarsList];

    return Container(
      // 高度由外层 Flexible 控制，此处填充可用空间
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
      ),
      child: SizedBox(
        // 为横向 ListVie6 提供有界高度，避免出现 "Horizontal viewport was given unbounded height" 错误
        height: _barHeight,
        child: ListView.separated(
          // 关闭默认主滚动控制并启用收缩以避免未绑定高度错误
          primary: false,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: sortedPillars.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final t = sortedPillars[index];
            final isDisabled = disabledTypes.contains(t.pillarType);

            if (isDisabled) {
              return Opacity(
                opacity: 0.5,
                child: _Tag(label: t.label, icon: Icons.drag_indicator),
              );
            }

            return Draggable<PillarData>(
              data: t,
              feedback:
                  _TagFeedback(label: t.label, icon: Icons.drag_indicator),
              childWhenDragging: Opacity(
                opacity: 0.35,
                child: _Tag(label: t.label, icon: Icons.drag_indicator),
              ),
              child: _Tag(label: t.label, icon: Icons.drag_indicator),
            );
          },
        ),
      ),
    );
  }
}

/// 标签的常态样式：小型卡片 + 抓手图标
class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: PillarTagBar._tagWidth,
      height: PillarTagBar._tagHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 标签的拖拽反馈：更明显的边框与阴影
class _TagFeedback extends StatelessWidget {
  const _TagFeedback({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      color: Colors.transparent,
      child: Container(
        width: 112,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
