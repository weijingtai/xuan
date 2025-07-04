import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_twelve_gong.dart';
import '../enums/enum_xing_xian_type.dart';
import 'base_xian_palace.dart';
import 'da_xian_constellation_passage_info.dart';
import 'star_influence_model.dart';

part 'da_xian_palace_info.g.dart';

@JsonSerializable()
class DaXianPalaceInfo extends BaseXianPalace {
  /// 每度对应的年月数(用于计算星宿过限时长)
  final YearMonth rateYearsPerDegree;

  DaXianPalaceInfo({
    required super.order,
    required super.palace,
    required super.durationYears,
    required super.startTime,
    required super.endTime,
    required super.startAge,
    required super.endAge,
    required super.constellationPassages,
    required super.totalGongDegreee,
    required this.rateYearsPerDegree,
    super.xingXianType = EnumXingXianType.daXian, // 默认为大限
  });

  DaXianPalaceInfo copyWith({
    int? order,
    EnumTwelveGong? palace,
    YearMonth? durationYears,
    DateTime? startTime,
    DateTime? endTime,
    YearMonth? startAge,
    YearMonth? endAge,
    YearMonth? rateYearsPerDegree,
    List<DaXianConstellationPassageInfo>? constellationPassages,
    double? totalGongDegreee,
    StarGongInfluence? starGongInfluence,
    Map<EnumInfluenceType, List<DingStarInfluenceModel>>? dingStarMapper,
  }) {
    return DaXianPalaceInfo(
      order: order ?? this.order,
      palace: palace ?? this.palace,
      durationYears: durationYears ?? this.durationYears,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startAge: startAge ?? this.startAge,
      endAge: endAge ?? this.endAge,
      rateYearsPerDegree: rateYearsPerDegree ?? this.rateYearsPerDegree,
      constellationPassages:
          constellationPassages ?? this.constellationPassages,
      totalGongDegreee: totalGongDegreee ?? this.totalGongDegreee,
      // dingStarMapper: dingStarMapper ?? this.dingStarMapper,
    );
  }

  @override
  String toString() {
    String passagesStr =
        constellationPassages.map((p) => p.toString()).join('\n');
    return 'Daxian ${order}: ${palace.name} ($durationYears)\n'
        '  Time: ${startTime.toIso8601String()} - ${endTime.toIso8601String()}\n'
        '  Age:  $startAge - $endAge\n'
        '  Rate: $rateYearsPerDegree yr/deg\n'
        '  Passages:\n$passagesStr';
  }

  factory DaXianPalaceInfo.fromJson(Map<String, dynamic> json) =>
      _$DaXianPalaceInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DaXianPalaceInfoToJson(this);
}
