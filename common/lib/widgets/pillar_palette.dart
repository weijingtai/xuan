import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/models/pillar_data.dart';
import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';

class PillarPalette extends StatelessWidget {
  const PillarPalette({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 120,
      color: theme.cardColor,
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPillarPaletteItem(context, '年柱', Icons.calendar_today, 'year'),
          _buildPillarPaletteItem(context, '月柱', Icons.calendar_month, 'month'),
          _buildPillarPaletteItem(context, '日柱', Icons.today, 'day'),
          _buildPillarPaletteItem(context, '时柱', Icons.schedule, 'time'),
          _buildPillarPaletteItem(context, '胎元', Icons.compost, 'taiyuan'),
          _buildPillarPaletteItem(context, '大运', Icons.trending_up, 'dayun'),
          _buildPillarPaletteItem(context, '流年', Icons.event, 'liunian'),
          _buildPillarPaletteItem(context, '更多...', Icons.more_horiz, 'more'),
        ],
      ),
    );
  }

  Widget _buildPillarPaletteItem(
      BuildContext context, String label, IconData icon, String pillarId) {
    final theme = Theme.of(context);
    final pillarData = PillarData(
        pillarId: pillarId,
        pillarType: PillarType.year,
        label: label,
        jiaZi: JiaZi.JIA_ZI);

    return Draggable<PillarData>(
      data: pillarData,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.2),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.drag_indicator,
                      size: 14,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '$label柱',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // 天干
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  pillarData.jiaZi.tianGan.value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // 地支
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  pillarData.jiaZi.diZhi.value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // 纳音
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Text(
                  pillarData.jiaZi.naYin.name,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Container(
          width: 100,
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 40,
                  color: theme.colorScheme.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 8),
              Text(label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.3),
                  )),
            ],
          ),
        ),
      ),
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
