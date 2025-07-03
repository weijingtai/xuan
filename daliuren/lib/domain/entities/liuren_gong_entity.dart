// lib/domain/entities/liuren_gong_entity.dart
import 'package:common/enums.dart' as common_enums;
import 'package:daliuren/domain/enums/gui_ren.dart' as domain_gui_ren;

/// Represents a single "Gong" (Palace) in the Liu Ren Pan.
/// Each Gong has a ground plate DiZhi, a sky plate DiZhi, an associated TianGan (if any),
/// a GuiRen (Deity/General), and potentially a full JiaZi cycle representation if not KongWang (Void).
class LiuRenGongEntity {
  /// The DiZhi (Earthly Branch) of the ground plate for this palace.
  final common_enums.DiZhi groundPanDiZhi;

  /// The DiZhi (Earthly Branch) of the sky plate aspect on this palace.
  final common_enums.DiZhi skyPanDiZhi;

  /// The TianGan (Heavenly Stem) associated with the sky plate DiZhi in this palace, if applicable.
  final common_enums.TianGan? tianGan;

  /// The GuiRen (Deity/General) residing in this palace.
  final domain_gui_ren.GuiRen guiRen;

  /// The full JiaZi (Stem-Branch cycle) of the sky plate aspect, if it's not KongWang (Void).
  /// This helps in understanding the complete nature of the sky plate influence.
  final common_enums.JiaZi? jiaZi;

  LiuRenGongEntity({
    required this.groundPanDiZhi,
    required this.skyPanDiZhi,
    this.tianGan,
    required this.guiRen,
    this.jiaZi
  });

  // Consider adding Equatable for value comparison and use in collections.
  // For example:
  // @override
  // List<Object?> get props => [groundPanDiZhi, skyPanDiZhi, tianGan, guiRen, jiaZi];
}
