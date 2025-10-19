import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/models/pillar_data.dart';
import 'package:flutter/material.dart';

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

  Widget _buildPillarPaletteItem(BuildContext context, String label, IconData icon, String pillarId) {
    final theme = Theme.of(context);
    final pillarData = PillarData(pillarId: pillarId, label: label, jiaZi: JiaZi.JIA_ZI);

    return Draggable<PillarData>(
      data: pillarData,
      feedback: Material(
        child: Container(
          width: 100,
          height: 100,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
          child: Center(
            child: Text(label, style: const TextStyle(color: Colors.white)),
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
