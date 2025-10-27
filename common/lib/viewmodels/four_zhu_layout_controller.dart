import 'package:flutter/foundation.dart';

import '../enums/layout_template_enums.dart';
import '../models/layout_template.dart';

/// Shared controller for FourZhu layout (pillars and rows).
/// Holds a single source of truth so multiple cards stay in sync.
class FourZhuLayoutController {
  /// Current pillar order
  final ValueNotifier<List<PillarType>> pillars;

  /// Current row configurations
  final ValueNotifier<List<RowConfig>> rows;

  FourZhuLayoutController({
    List<PillarType>? pillars,
    List<RowConfig>? rows,
  })  : pillars = ValueNotifier<List<PillarType>>(
          List<PillarType>.of(pillars ??
              const [
                PillarType.year,
                PillarType.month,
                PillarType.day,
                PillarType.hour,
              ]),
        ),
        rows = ValueNotifier<List<RowConfig>>(
          List<RowConfig>.of(rows ??
              const [
                RowConfig(
                    type: RowType.heavenlyStem,
                    isVisible: true,
                    isTitleVisible: true),
                RowConfig(
                    type: RowType.earthlyBranch,
                    isVisible: true,
                    isTitleVisible: true),
                RowConfig(
                    type: RowType.naYin, isVisible: true, isTitleVisible: true),
              ]),
        );

  void setPillars(List<PillarType> next) {
    pillars.value = List<PillarType>.of(next);
  }

  void setRows(List<RowConfig> next) {
    rows.value = List<RowConfig>.of(next);
  }

  /// Reorder pillars by indices (same semantics as ReorderableListView)
  void reorderPillars(int oldIndex, int newIndex) {
    final list = List<PillarType>.of(pillars.value);
    final item = list.removeAt(oldIndex);
    // In ReorderableListView, when moving forward, the target index is one past
    if (newIndex > oldIndex) newIndex -= 1;
    list.insert(newIndex, item);
    pillars.value = list;
  }

  /// Reorder rows by indices (same semantics as ReorderableListView)
  void reorderRows(int oldIndex, int newIndex) {
    final list = List<RowConfig>.of(rows.value);
    final item = list.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex -= 1;
    list.insert(newIndex, item);
    rows.value = list;
  }

  /// Optional lifecycle hooks for future persistence
  Future<void> load(String? layoutId) async {}
  Future<void> save() async {}

  void dispose() {
    pillars.dispose();
    rows.dispose();
  }
}
