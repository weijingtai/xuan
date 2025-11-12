import 'package:flutter/foundation.dart';

import '../enums/layout_template_enums.dart';
import '../models/layout_template.dart';
import '../models/text_style_config.dart';

/// Shared controller for FourZhu layout (pillars and rows).
/// Holds a single source of truth so multiple cards stay in sync.
class FourZhuLayoutController {
  /// Current pillar order
  final ValueNotifier<List<PillarType>> pillars;

  /// Current row configurations
  final ValueNotifier<List<RowConfig>> rows;

  /// Column-level overrides: per column index, map row type -> display value
  final ValueNotifier<Map<int, Map<RowType, String>>> columnOverrides;

  /// Custom pillar labels: per column index -> label text
  final ValueNotifier<Map<int, String>> pillarLabelOverrides;

  /// Row-level overrides: per row index, map pillar type -> display value
  final ValueNotifier<Map<int, Map<PillarType, String>>> rowOverrides;

  /// Custom row labels: per row index -> label text
  final ValueNotifier<Map<int, String>> rowLabelOverrides;

  FourZhuLayoutController({
    List<PillarType>? pillars,
    List<RowConfig>? rows,
    Map<int, Map<RowType, String>>? columnOverrides,
    Map<int, String>? pillarLabelOverrides,
    Map<int, Map<PillarType, String>>? rowOverrides,
    Map<int, String>? rowLabelOverrides,
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
              [
                RowConfig(
                    type: RowType.heavenlyStem,
                    isVisible: true,
                    isTitleVisible: true,
                    textStyleConfig: TextStyleConfig.defaultConfig),
                RowConfig(
                    type: RowType.earthlyBranch,
                    isVisible: true,
                    isTitleVisible: true,
                    textStyleConfig: TextStyleConfig.defaultConfig),
                RowConfig(
                    type: RowType.naYin,
                    isVisible: true,
                    isTitleVisible: true,
                    textStyleConfig: TextStyleConfig.defaultConfig),
              ]),
        ),
        columnOverrides = ValueNotifier<Map<int, Map<RowType, String>>>(
          Map<int, Map<RowType, String>>.of(columnOverrides ?? const {}),
        ),
        pillarLabelOverrides = ValueNotifier<Map<int, String>>(
          Map<int, String>.of(pillarLabelOverrides ?? const {}),
        ),
        rowOverrides = ValueNotifier<Map<int, Map<PillarType, String>>>(
          Map<int, Map<PillarType, String>>.of(rowOverrides ?? const {}),
        ),
        rowLabelOverrides = ValueNotifier<Map<int, String>>(
          Map<int, String>.of(rowLabelOverrides ?? const {}),
        );

  void setPillars(List<PillarType> next) {
    pillars.value = List<PillarType>.of(next);
  }

  void setRows(List<RowConfig> next) {
    rows.value = List<RowConfig>.of(next);
  }

  void setColumnOverrides(Map<int, Map<RowType, String>> next) {
    columnOverrides.value = next.map(
      (k, v) => MapEntry(k, Map<RowType, String>.of(v)),
    );
  }

  void setPillarLabelOverrides(Map<int, String> next) {
    pillarLabelOverrides.value = Map<int, String>.of(next);
  }

  void setRowOverrides(Map<int, Map<PillarType, String>> next) {
    rowOverrides.value = next.map(
      (k, v) => MapEntry(k, Map<PillarType, String>.of(v)),
    );
  }

  void setRowLabelOverrides(Map<int, String> next) {
    rowLabelOverrides.value = Map<int, String>.of(next);
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
    columnOverrides.dispose();
    pillarLabelOverrides.dispose();
    rowOverrides.dispose();
    rowLabelOverrides.dispose();
  }
}
