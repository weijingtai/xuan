import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';
import '../enums/enum_twelve_gong.dart';
import '../enums/enum_xing_xian_type.dart';
import 'base_xian_palace.dart';
import 'da_xian_constellation_passage_info.dart';
import 'da_xian_palace_info.dart';
import 'fei_xian_calculator.dart';
import 'star_influence_model.dart';

part 'fei_xian_detail_palace.g.dart';

/// 洞微飞限信息
@JsonSerializable()
class FeiXianDetailPalace extends BaseXianPalace {
  final FeiXianGongType feiXianGongType;
  final int? triangleIndex;

  FeiXianDetailPalace({
    required super.order,
    required super.palace,
    required super.startAge,
    required super.endAge,
    required super.startTime,
    required super.endTime,
    required super.durationYears,
    required super.constellationPassages,
    required super.totalGongDegreee,
    // super.dingStarMapper,
    super.xingXianType = EnumXingXianType.feiXian, // 默认为飞限,
    required this.feiXianGongType,
    this.triangleIndex,
  });

  copyWith({
    int? order,
    EnumTwelveGong? palace,
    YearMonth? startAge,
    YearMonth? endAge,
    DateTime? startTime,
    DateTime? endTime,
    YearMonth? durationYears,
    List<DaXianConstellationPassageInfo>? constellationPassages,
    double? totalGongDegreee,
    StarGongInfluence? starGongInfluence,
    // Map<EnumDingStar, List<StarInfluenceModel>>? dingStarMapper,
    FeiXianGongType? feiXianGongType,
    int? triangleIndex,
  }) =>
      FeiXianDetailPalace(
        order: order ?? this.order,
        palace: palace ?? this.palace,
        startAge: startAge ?? this.startAge,
        endAge: endAge ?? this.endAge,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        durationYears: durationYears ?? this.durationYears,
        constellationPassages:
            constellationPassages ?? this.constellationPassages,
        totalGongDegreee: totalGongDegreee ?? this.totalGongDegreee,
        // dingStarMapper: dingStarMapper?? this.dingStarMapper,
        feiXianGongType: feiXianGongType ?? this.feiXianGongType,
        triangleIndex: triangleIndex ?? this.triangleIndex,
      );

  factory FeiXianDetailPalace.fromJson(Map<String, dynamic> json) =>
      _$FeiXianDetailPalaceFromJson(json);
  Map<String, dynamic> toJson() => _$FeiXianDetailPalaceToJson(this);
}
