// lib/domain/entities/liuren_pan.dart

/// Represents the complete Liu Ren divination盤 (Pan).
/// This is a core domain entity holding all calculated and contextual information of a divination.
import 'package:common/enums.dart';
import 'package:daliuren/domain/entities/raw_pan_info_model.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:json_annotation/json_annotation.dart';
import '../enums/nine_zong_men.dart';
import '../enums/pan_type.dart';

part 'liu_ren_pan_model.g.dart';

@JsonSerializable()

/// Core domain entity representing a fully calculated Liu Ren Pan.
class LiuRenPanModel {
  // /// The precise date and time for which the pan was cast.
  // /// Nullable because preset pans might not have this specific time.
  // final DateTime? panDateTime;

  /// Name of the Day JiaZi (e.g., "甲子").
  final JiaZi dayJiaZi;

  /// Full GanZhi of the day (e.g., "甲子").
  // final String dayGanZhi

  /// Full GanZhi of the time (e.g., "丙寅").
  final JiaZi timeGanZhi;

  /// Name of the ShiChen DiZhi (e.g., "子").
  DiZhi get timeChen => timeGanZhi.zhi;

  PanType panType;

  /// Name of the YueJiang (Month General, e.g., "登明").
  /// Nullable as preset pans might not explicitly store this.
  final MonthGeneral monthGeneral;

  /// Type of GuiRen used (e.g., "阳贵人", "昼贵", "夜贵").
  final EnumDayNight dayNight;

  /// Heaven Plate information, keyed by DiZhi name. Each entry provides details of the celestial stem and deity on that palace.
  // final Map<String, LiuRenGongEntity> heavenPlate;
  /// Earth Plate information, keyed by DiZhi name. Provides details of the terrestrial stem and deity.
  // final Map<String, LiuRenGongEntity> earthPlate;

  /// List of the Four Classes (四课).
  final List<RawEachClass> fourClasses;

  /// List of the Three Transmissions (三传).
  final List<EachChuan> threeChuans;

  /// The primary KeTi (课体) determined by NineZongMen rules.
  final NineZongMen nineZongMen;

  /// Additional descriptive KeTi names (e.g., "伏吟", "八专").
  final List<String> keTiComplement;

  final Map<DiZhi, EachGong> gongMapper;

  /// The Ju (局数) used or calculated for this pan, if applicable.
  final int ju;
  final List<String> patternName;

  final DiZhi guiRenLocation;

  LiuRenPanModel({
    // this.panDateTime,
    required this.dayJiaZi,
    required this.timeGanZhi,
    required this.fourClasses,
    required this.threeChuans,
    required this.nineZongMen,
    required this.monthGeneral,
    required this.dayNight,
    this.keTiComplement = const [],
    required this.ju,
    required this.panType,
    required this.guiRenLocation,
    required this.gongMapper,
    required this.patternName,
  });

  factory LiuRenPanModel.fromJson(Map<String, dynamic> json) =>
      _$LiuRenPanModelFromJson(json);
  Map<String, dynamic> toJson() => _$LiuRenPanModelToJson(this);
}
