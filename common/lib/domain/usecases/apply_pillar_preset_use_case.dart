import 'package:common/models/pillar_preset.dart';

class ApplyPillarPresetParams {
  final PillarPreset preset;
  final bool isForBenMing; // To know which set of possible pillars to check against

  ApplyPillarPresetParams({required this.preset, required this.isForBenMing});
}

class ApplyPillarPresetResult {
  final List<String> newPillarOrder;
  final Map<String, bool> newVisibilityFlags;

  ApplyPillarPresetResult({required this.newPillarOrder, required this.newVisibilityFlags});
}

class ApplyPillarPresetUseCase {
  ApplyPillarPresetResult call(ApplyPillarPresetParams params) {
    final newOrder = params.preset.pillars;

    // Define all possible pillars for each card type
    const benMingPillars = ['年', '月', '日', '时', '胎元', '刻'];
    const liuYunPillars = ['大运', '流年', '流月', '流日', '流时'];

    final possiblePillars = params.isForBenMing ? benMingPillars : liuYunPillars;

    final visibilityFlags = <String, bool>{};
    for (final pillar in possiblePillars) {
      visibilityFlags[pillar] = newOrder.contains(pillar);
    }

    return ApplyPillarPresetResult(
      newPillarOrder: newOrder,
      newVisibilityFlags: visibilityFlags,
    );
  }
}
