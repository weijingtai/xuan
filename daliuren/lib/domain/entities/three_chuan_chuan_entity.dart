// lib/domain/entities/three_chuan_chuan_entity.dart
import 'package:common/enums.dart' as common_enums;
import 'package:daliuren/domain/enums/gui_ren.dart' as domain_gui_ren;

/// Represents a single "Chuan" (Transmission) within the Three Transmissions (三传) of a Liu Ren Pan.
/// The Three Transmissions are First (初传), Middle (中传), and Last (末传).
class ThreeChuanChuanEntity {
  /// The DiZhi (Earthly Branch) where this Transmission lands.
  final common_enums.DiZhi diZhi;

  /// The TianGan (Heavenly Stem) associated with this Transmission's DiZhi, if applicable (e.g., not KongWang/Void).
  final common_enums.TianGan? tianGan;

  /// The GuiRen (Deity/General) on this Transmission.
  final domain_gui_ren.GuiRen guiRen;

  /// The LiuQin (Six Kinship) relationship of this Transmission's DiZhi with the Day Gan (日干).
  final common_enums.LiuQin liuQin;

  ThreeChuanChuanEntity({
    required this.diZhi,
    this.tianGan,
    required this.guiRen,
    required this.liuQin
  });

  // Consider adding Equatable for value comparison.
  // @override
  // List<Object?> get props => [diZhi, tianGan, guiRen, liuQin];
}
