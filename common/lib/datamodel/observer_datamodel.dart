import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../models/divination_datetime.dart';
import 'location.dart';
part 'observer_datamodel.g.dart';

@JsonSerializable()
class ObserverDataModel extends Equatable {
  final Coordinates? coordinate;
  final Location? location;
  final String timezoneStr;
  final EnumDatetimeType type;
  final int? hourAdjusted; // RemoveDST特有
  final bool isManualCalibration;

  ObserverDataModel(
      {required this.timezoneStr,
      required this.type,
      this.coordinate,
      this.location,
      this.hourAdjusted,
      this.isManualCalibration = false});
  factory ObserverDataModel.fromJson(Map<String, dynamic> json) =>
      _$ObserverDataModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ObserverDataModelToJson(this);

  @override
  List<Object?> get props => [
        coordinate,
        location,
        timezoneStr,
        type,
        hourAdjusted,
        isManualCalibration
      ];

  copyWith({
    Coordinates? coordinate,
    Location? location,
    String? timezoneStr,
    EnumDatetimeType? type,
    int? hourAdjusted,
    bool? isManualCalibration,
  }) {
    return ObserverDataModel(
        coordinate: coordinate ?? this.coordinate,
        location: location ?? this.location,
        timezoneStr: timezoneStr ?? this.timezoneStr,
        type: type ?? this.type,
        hourAdjusted: hourAdjusted ?? this.hourAdjusted,
        isManualCalibration: isManualCalibration ?? this.isManualCalibration);
  }
}
