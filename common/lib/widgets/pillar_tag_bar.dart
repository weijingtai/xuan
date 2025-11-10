import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/models/pillar_data.dart';
import 'package:flutter/material.dart';

/// PillarTagBar - 底部 20% 高度的小型可拖拽 Tag 列表（含抓手 icon）
///
/// 功能：
/// - 以更紧凑的标签形式展示各“柱”入口
/// - 支持将标签拖拽到画布（DragTarget）以添加对应柱
/// - 标签内提供抓手图标（drag_indicator），更直观的拖拽提示
class PillarTagBar extends StatelessWidget {
  const PillarTagBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = <_TagSpec>[
      _TagSpec('year', '年柱', Icons.calendar_today),
      _TagSpec('month', '月柱', Icons.calendar_month),
      _TagSpec('day', '日柱', Icons.today),
      _TagSpec('time', '时柱', Icons.schedule),
      _TagSpec('taiyuan', '胎元', Icons.compost),
      _TagSpec('dayun', '大运', Icons.trending_up),
      _TagSpec('liunian', '流年', Icons.event),
      _TagSpec('more', '更多...', Icons.more_horiz),
    ];

    return Container(
      // 高度由外层 Flexible 控制，此处填充可用空间
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
      ),
      child: SizedBox(
        // 为横向 ListView 提供有界高度，避免出现 "Horizontal viewport was given unbounded height" 错误
        height: 64, // 标签高度 48 + 上下内边距与分隔留白
        child: ListView.separated(
          // 关闭默认主滚动控制并启用收缩以避免未绑定高度错误
          primary: false,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: tags.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final t = tags[index];
            final data =
                PillarData(pillarId: t.id, label: t.label, jiaZi: JiaZi.JIA_ZI);
            return Draggable<PillarData>(
              data: data,
              feedback: _TagFeedback(label: t.label, icon: t.icon),
              childWhenDragging: Opacity(
                opacity: 0.35,
                child: _Tag(label: t.label, icon: t.icon),
              ),
              child: _Tag(label: t.label, icon: t.icon),
            );
          },
        ),
      ),
    );
  }
}

/// 标签规格（数据结构）
class _TagSpec {
  const _TagSpec(this.id, this.label, this.icon);
  final String id;
  final String label;
  final IconData icon;
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
      width: 108,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.drag_indicator,
              size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelLarge,
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
        width: 128,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
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
            Icon(Icons.drag_indicator,
                size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelLarge
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
