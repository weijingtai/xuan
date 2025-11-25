import 'package:common/enums/enum_jia_zi.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/layout_template_enums.dart';

part 'pillar_data.g.dart';

@JsonSerializable()
class PillarData extends Equatable {
  final String pillarId; // A unique ID, e.g., "year", "month", "da_yun_1"
  final PillarType pillarType;
  final String label; // The display label, e.g., "年", "月", "大运"
  final JiaZi jiaZi; // The core Stem-Branch data

  const PillarData({
    required this.pillarId,
    required this.pillarType,
    required this.label,
    required this.jiaZi,
  });

  factory PillarData.fromJson(Map<String, dynamic> json) =>
      _$PillarDataFromJson(json);

  Map<String, dynamic> toJson() => _$PillarDataToJson(this);

  @override
  List<Object?> get props => [pillarId, pillarType, label, jiaZi];
}
