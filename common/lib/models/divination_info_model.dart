import 'package:common/datamodel/datetime_divination_datamodel.dart';
import 'package:common/datamodel/divination_request_info_datamodel.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'divination_info_model.g.dart';

@JsonSerializable()
class DivinationInfoModel extends Equatable {
  final DivinationRequestInfoDataModel divination;
  final DatatimeDivinationDetailsDataModel divinationDatetime;
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
