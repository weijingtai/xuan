import 'package:flutter/material.dart';
import '../enums/layout_template_enums.dart';
import '../models/drag_payloads.dart';
import '../models/row_strategy.dart';
import '../models/text_style_config.dart';

/// 四柱卡片添加面板
///
/// 功能描述：
/// - 提供四个可拖拽入口，分别用于向“四柱卡片”添加：
///   1) 列：大运柱（`PillarPayload.luckCycle`）
///   2) 列：柱分隔符（`PillarType.separator`）
///   3) 行：空亡行（`RowInfoPayload.kongWang`）
///   4) 行：行分割符（`RowInfoPayload(rowType: RowType.separator)`）
/// - 这些入口可以直接拖拽到可编辑四柱卡片（V3）上的行/列插入目标处来完成添加。
class FourZhuAddPalette extends StatelessWidget {
  const FourZhuAddPalette({super.key});

  /// 构建组件入口视图
  ///
  /// 参数：
  /// - [context]: Flutter 构建上下文。
  /// 返回：
  /// - [Widget]: 水平排列的四个可拖拽 Chip。
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _LuckCyclePillarDraggable(),
          _SeparatorPillarDraggable(),
          _KongWangRowDraggable(),
          _RowSeparatorDraggable(),
        ],
      ),
    );
  }
}

/// 大运柱拖拽入口
///
/// 功能：提供 `PillarPayload.luckCycle` 作为外部列插入的拖拽数据。
class _LuckCyclePillarDraggable extends StatelessWidget {
  const _LuckCyclePillarDraggable();

  /// 构建拖拽入口视图
  ///
  /// 返回：携带 `PillarPayload.luckCycle` 的 Draggable。
  @override
  Widget build(BuildContext context) {
    final payload = PillarPayload(
      uuid: 'luckCycle',
      pillarType: PillarType.luckCycle,
      pillarLabel: '大运',
    );
    return Draggable<PillarPayload>(
      data: payload,
      feedback: Material(
        elevation: 6,
        color: Colors.transparent,
        child: const Chip(label: Text('拖拽: 大运柱')),
      ),
      childWhenDragging:
          const Opacity(opacity: 0.5, child: Chip(label: Text('大运柱'))),
      child: const Chip(label: Text('大运柱')),
    );
  }
}

/// 柱分隔符拖拽入口
///
/// 功能：提供 `PillarType.separator` 作为外部列插入的拖拽数据。
class _SeparatorPillarDraggable extends StatelessWidget {
  const _SeparatorPillarDraggable();

  /// 构建拖拽入口视图
  ///
  /// 返回：携带 `PillarType.separator` 的 Draggable。
  @override
  Widget build(BuildContext context) {
    return Draggable<PillarPayload>(
      data: SeparatorPillarPayload(uuid: 'sep'),
      feedback: Material(
        elevation: 6,
        color: Colors.transparent,
        child: const Chip(label: Text('拖拽: 列分隔符')),
      ),
      childWhenDragging:
          const Opacity(opacity: 0.5, child: Chip(label: Text('列分隔符'))),
      child: const Chip(label: Text('列分隔符')),
    );
  }
}

/// 空亡行拖拽入口
///
/// 功能：提供 `RowInfoPayload.kongWang` 作为外部行插入的拖拽数据。
class _KongWangRowDraggable extends StatelessWidget {
  const _KongWangRowDraggable();

  /// 构建拖拽入口视图
  ///
  /// 返回：携带 `RowInfoPayload.kongWang` 的 Draggable。
  @override
  Widget build(BuildContext context) {
    final payload = TextRowPayload(
      rowType: RowType.kongWang,
      uuid: 'kongwang_drag',
      titleInCell: false,
      rowLabel: '空亡',
    );
    return Draggable<TextRowPayload>(
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

/// 行分割符拖拽入口
///
/// 功能：提供 `RowInfoPayload(rowType: RowType.separator)` 作为外部行插入的拖拽数据。
class _RowSeparatorDraggable extends StatelessWidget {
  const _RowSeparatorDraggable();

  /// 构建拖拽入口视图
  ///
  /// 返回：携带 `RowInfoPayload(rowType: RowType.separator)` 的 Draggable。
  @override
  Widget build(BuildContext context) {
    var payload = RowSeparatorPayload(uuid: 'row_sep');
    return Draggable<RowPayload>(
      data: payload,
      feedback: Material(
        elevation: 6,
        color: Colors.transparent,
        child: const Chip(label: Text('拖拽: 行分割符')),
      ),
      childWhenDragging:
          const Opacity(opacity: 0.5, child: Chip(label: Text('行分割符'))),
      child: const Chip(label: Text('行分割符')),
    );
  }
}
