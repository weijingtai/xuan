import 'package:flutter/material.dart';

import '../enums/layout_template_enums.dart';

/// A simple test-only draggable widget that can be dragged into EditableFourZhuCard.
/// It carries a PillarType as drag data.
class TestPillarDraggable extends StatelessWidget {
  const TestPillarDraggable({super.key, required this.type});

  final PillarType type;

  @override
  Widget build(BuildContext context) {
    return Draggable<PillarType>(
      data: type,
      feedback: Material(
        elevation: 6,
        color: Colors.transparent,
        child: Chip(label: Text('拖拽: ${_label(type)}')),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Chip(label: Text(_label(type))),
      ),
      child: Chip(label: Text(_label(type))),
    );
  }

  String _label(PillarType type) {
    switch (type) {
      case PillarType.year:
        return '年柱';
      case PillarType.month:
        return '月柱';
      case PillarType.day:
        return '日柱';
      case PillarType.hour:
        return '时柱';
      case PillarType.separator:
        return '列分隔符';
      default:
        return type.name;
    }
  }
}
