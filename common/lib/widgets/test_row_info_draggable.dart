import 'package:flutter/material.dart';
import '../enums/layout_template_enums.dart';
import '../models/drag_payloads.dart';
import '../models/row_strategy.dart';
import '../models/text_style_config.dart';

/// Demo-only draggable for inserting a row info (e.g., 空亡) with values.
class TestRowInfoDraggable extends StatelessWidget {
  const TestRowInfoDraggable({super.key});

  @override
  Widget build(BuildContext context) {
    // Example payload: 「空亡」: 年柱[戌亥], 月柱[戌亥], 日柱[戌亥], 时柱[戌亥], 大运[戌亥]
    RowInfoPayload payload = RowInfoPayload(
      rowType: RowType.kongWang,
      rowLabel: '空亡',
      // Per-pillar overrides now keyed by pillar `id`.
      // In demo context without concrete pillar ids, keep empty and let strategy compute.
      perPillarValues: {},
      strategy: KongWangRowStrategy(),
      config: TextStyleConfig.defaultConfig,
    );

    return Draggable<RowInfoPayload>(
      data: payload,
      feedback: Material(
        elevation: 6,
        color: Colors.transparent,
        child: const Chip(label: Text('拖拽: 空亡行')),
      ),
      childWhenDragging:
          const Opacity(opacity: 0.5, child: Chip(label: Text('空亡行'))),
      child: const Chip(label: Text('空亡行')),
    );
  }
}
