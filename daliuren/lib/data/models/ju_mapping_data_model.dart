import 'package:json_annotation/json_annotation.dart';
// Assuming JiaZi, DiZhi, YinYang are here or defined elsewhere

part 'ju_mapping_data_model.g.dart';

@JsonSerializable()
class JuMappingDataModel {
  @JsonKey(name: 'dayJiaZi')
  final String
      dayJiaZiName; // Store as String, convert to JiaZi enum in domain/repository layer

  @JsonKey(name: 'timeDiZhi')
  final String timeDiZhiName; // Store as String, convert to DiZhi enum

  @JsonKey(name: 'yinYang')
  final String yinYangValue; // "yang" or "yin", convert to YinYang enum

  final int juNumber;

  JuMappingDataModel({
    required this.dayJiaZiName,
    required this.timeDiZhiName,
    required this.yinYangValue,
    required this.juNumber,
  });

  factory JuMappingDataModel.fromJson(Map<String, dynamic> json) =>
      _$JuMappingDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$JuMappingDataModelToJson(this);
}
