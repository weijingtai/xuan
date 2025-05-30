import 'package:common/datamodel/base_divination_datetime_datamodel.dart';
import 'package:common/datamodel/divination_data_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'divination_info_model.g.dart';

@JsonSerializable()
class DivinationInfoModel extends Equatable {
  final DivinationDataModel divination;
  final BaseDivinationDatetimeDataModel divinationDatetime;
  const DivinationInfoModel({
    required this.divination,
    required this.divinationDatetime,
  });

  @override
  List<Object?> get props => [divination, divinationDatetime];

  factory DivinationInfoModel.fromJson(Map<String, dynamic> json) =>
      _$DivinationInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$DivinationInfoModelToJson(this);
}
