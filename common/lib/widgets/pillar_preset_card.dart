import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';
import '../models/pillar_data.dart';
import '../enums/enum_jia_zi.dart';
import '../models/pillar_preset.dart';

class PillarPresetCard extends StatelessWidget {
  const PillarPresetCard({
    super.key,
    required this.preset,
    this.onTap,
  });

  final PillarPreset preset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = _formatDate(preset.updatedAt);
    final data = PillarData(
      pillarId: preset.pillarIds.isNotEmpty ? preset.pillarIds.first : 'year',
      pillarType: PillarType.year,
      label: preset.name,
      jiaZi: JiaZi.JIA_ZI,
    );

    return LongPressDraggable<Object>(
      // 传递整张模板卡以便批量插入；看板也兼容单柱拖拽（PillarData）
      data: preset,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: _CardBody(
              theme: theme, dateText: dateText, dragging: true, preset: preset),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: _CardBody(
          theme: theme,
          dateText: dateText,
          dragging: false,
          preset: preset,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.theme,
    required this.dateText,
    required this.dragging,
    required this.preset,
  });

  final ThemeData theme;
  final String dateText;
  final bool dragging;
  final PillarPreset preset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
        boxShadow: dragging
            ? [
                const BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 4),
                    color: Color(0x22000000))
              ]
            : [
                const BoxShadow(
                    blurRadius: 2,
                    offset: Offset(0, 1),
                    color: Color(0x14000000))
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  preset.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Icon(preset.favorite ? Icons.star : Icons.star_border,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              const Icon(Icons.drag_indicator, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: -6,
            children: preset.pillarIds
                .map((id) => Chip(
                      label: Text(_pillarLabel(id)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.sensor_occupied, size: 14, color: theme.hintColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  preset.scene,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall,
                ),
              ),
              Text(dateText, style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  String _pillarLabel(String id) {
    switch (id) {
      case 'year':
        return '年柱';
      case 'month':
        return '月柱';
      case 'day':
        return '日柱';
      case 'time':
        return '时柱';
      case 'dayun':
        return '大运';
      case 'liunian':
        return '流年';
    }
    return id;
  }
}
