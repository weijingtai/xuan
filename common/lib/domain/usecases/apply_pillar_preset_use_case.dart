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
    // Use the preset's pillar id list
    final newOrder = params.preset.pillarIds;

    // Define all possible pillars for each card type
    // Possible pillar ids for each scene (keep ids consistent with PillarType mapping)
    const benMingPillars = ['year', 'month', 'day', 'time', 'taiyuan', 'ke'];
    const liuYunPillars = ['dayun', 'liunian'];

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
