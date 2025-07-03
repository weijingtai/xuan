// lib/domain/entities/liuren_pan.dart

/// Represents the complete Liu Ren divination盤 (Pan).
/// This is a core domain entity holding all calculated and contextual information of a divination.
import 'package:common/enums.dart' as common_enums; // For base enums
import 'package:daliuren/domain/enums/nine_zong_men.dart' as domain_enums; // Using domain-specific enums
import 'liuren_gong_entity.dart';
import 'four_class_ke_entity.dart';
import 'three_chuan_chuan_entity.dart';

/// Core domain entity representing a fully calculated Liu Ren Pan.
class LiuRenPan {
  /// The precise date and time for which the pan was cast.
  /// Nullable because preset pans might not have this specific time.
  final DateTime? panDateTime;

  /// Name of the Day JiaZi (e.g., "甲子").
  final String dayJiaZiName;
  /// Full GanZhi of the day (e.g., "甲子").
  final String dayGanZhi;
  /// Full GanZhi of the time (e.g., "丙寅").
  final String timeGanZhi;
  /// Name of the ShiChen DiZhi (e.g., "子").
  final String shiChenZhiName;
  /// Name of the YueJiang (Month General, e.g., "登明").
  /// Nullable as preset pans might not explicitly store this.
  final String? yueJiangName;
  /// Type of GuiRen used (e.g., "阳贵人", "昼贵", "夜贵").
  final String guiRenType;

  /// Heaven Plate information, keyed by DiZhi name. Each entry provides details of the celestial stem and deity on that palace.
  final Map<String, LiuRenGongEntity> heavenPlate;
  /// Earth Plate information, keyed by DiZhi name. Provides details of the terrestrial stem and deity.
  final Map<String, LiuRenGongEntity> earthPlate;

  /// List of the Four Classes (四课).
  final List<FourClassKeEntity> fourClasses;
  /// List of the Three Transmissions (三传).
  final List<ThreeChuanChuanEntity> threeChuans;

  /// The primary KeTi (课体) determined by NineZongMen rules.
  final domain_enums.NineZongMen nineZongMen;
  /// Additional descriptive KeTi names (e.g., "伏吟", "八专").
  final List<String> keTiComplement;

  // Meta information about the pan calculation or source
  /// Description of how the pan was generated (e.g., "Calculated from Time", "Loaded from Preset").
  final String? sourceDescription;
  /// The Day JiaZi as an enum, if available.
  final common_enums.JiaZi? dayJiaZiEnum;
  /// The ShiChen DiZhi as an enum, if available.
  final common_enums.DiZhi? shiChenEnum;
  /// The YinYang Dun (阳遁/阴遁) used, if applicable.
  final common_enums.YinYang? yinYangDunUsed;
  /// The Ju (局数) used or calculated for this pan, if applicable.
  final int? juUsed;

  LiuRenPan({
    this.panDateTime,
    required this.dayJiaZiName,
    required this.dayGanZhi,
    required this.timeGanZhi,
    required this.shiChenZhiName,
    this.yueJiangName,
    required this.guiRenType,
    required this.heavenPlate,
    required this.earthPlate,
    required this.fourClasses,
    required this.threeChuans,
    required this.nineZongMen,
    this.keTiComplement = const [],
    this.sourceDescription,
    this.dayJiaZiEnum,
    this.shiChenEnum,
    this.yinYangDunUsed,
    this.juUsed,
  });

  // Consider adding Equatable for value comparison if needed in ViewModels/BloCs
  // For example:
  // @override
  // List<Object?> get props => [
  //   panDateTime, dayJiaZiName, ..., keTiComplement, sourceDescription, ...
  // ];
}
