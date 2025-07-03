// lib/domain/entities/four_class_ke_entity.dart
import 'package:common/enums.dart' as common_enums;
import 'package:daliuren/domain/enums/gui_ren.dart' as domain_gui_ren;
// import 'package:daliuren/domain/enums/each_class_zei_ke_type.dart' as domain_enums; // If ZeiKeType is to be part of this entity

/// Represents a single "Ke" (Class) within the Four Classes (四课) of a Liu Ren Pan.
class FourClassKeEntity {
  /// The order of this Ke (1st, 2nd, 3rd, or 4th).
  final int order;

  /// The DiZhi (Earthly Branch) of the Sky aspect (上神 - Shang Shen) of this Ke.
  final common_enums.DiZhi sky;

  /// The DiZhi (Earthly Branch) of the Ground aspect (下神 - Xia Shen, usually the ground plate DiZhi) of this Ke.
  final common_enums.DiZhi ground;

  /// The GuiRen (Deity/General) associated with the Sky aspect of this Ke.
  final domain_gui_ren.GuiRen guiRen;

  /// The Day Gan (日干 - Heavenly Stem of the Day). This is only applicable and present for the First Ke.
  final common_enums.TianGan? dayGan;

  // /// The ZeiKeType (贼克关系 - Robber/Control Relationship type) if applicable.
  // /// This would typically be calculated by domain logic and could be added here.
  // final domain_enums.EachClassZeiKeType? zeiKeType;

  FourClassKeEntity({
    required this.order,
    required this.sky,
    required this.ground,
    required this.guiRen,
    this.dayGan, // Nullable as it's mostly for the first Ke
    // this.zeiKeType,
  });

  // Consider adding Equatable for value comparison.
  // @override
  // List<Object?> get props => [order, sky, ground, guiRen, dayGan, zeiKeType];
}
