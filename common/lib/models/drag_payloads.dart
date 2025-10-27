import '../enums/layout_template_enums.dart';

/// Payload for dragging a pillar (column) into a card.
class PillarPayload {
  const PillarPayload({
    required this.pillarType,
    this.pillarLabel,
    this.perRowValues = const {},
  });

  /// The type of pillar to insert (e.g., PillarType.luckCycle for 大运).
  final PillarType pillarType;

  /// Optional custom label to display for the inserted pillar.
  final String? pillarLabel;

  /// Optional overrides for each row in this pillar.
  /// For example: {RowType.heavenlyStem: '乙', RowType.earthlyBranch: '亥'}
  final Map<RowType, String> perRowValues;
}

/// Payload for dragging a row info into a card (to insert a new row).
class RowInfoPayload {
  const RowInfoPayload({
    required this.rowType,
    this.rowLabel,
    this.perPillarValues = const {},
  });

  /// The type of row to insert (e.g., RowType.kongWang for 空亡).
  final RowType rowType;

  /// Optional custom label to display for the inserted row.
  final String? rowLabel;

  /// Optional overrides for each pillar in this row.
  /// For example: {PillarType.year: '戌亥', PillarType.month: '戌亥'}
  final Map<PillarType, String> perPillarValues;
}
