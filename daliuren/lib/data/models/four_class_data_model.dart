import 'package:json_annotation/json_annotation.dart';
import 'package:common/enums.dart'; // For TianGan
import 'each_class_data_model.dart'; // Updated import

part 'four_class_data_model.g.dart';

@JsonSerializable()
class FourClassDataModel {
  // The first class's details, including its TianGan
  final EachClassDataModel first;
  @JsonKey(toJson: _tianGanToJson, fromJson: _tianGanFromJson)
  final TianGan firstClassDayGan; // Specifically storing the Day Gan for the first class

  final EachClassDataModel second;
  final EachClassDataModel third;
  final EachClassDataModel fourth;

  FourClassDataModel({
    required this.first,
    required this.firstClassDayGan,
    required this.second,
    required this.third,
    required this.fourth,
  });

  factory FourClassDataModel.fromJson(Map<String, dynamic> json) {
    // Custom logic might be needed here if the original JSON for 'first' class
    // implicitly contained TianGan or was structured as the old 'FirstClass' model.
    // Assuming the JSON structure for 'first' is an EachClassDataModel,
    // and 'firstClassDayGan' is a separate field in the JSON for FourClassDataModel.
    // If JSON has `first: {tianGan: '甲', ...other EachClass fields}`, then manual mapping is needed.
    // For now, assume `firstClassDayGan` is a direct field in FourClass's JSON.
    return _$FourClassDataModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$FourClassDataModelToJson(this);

  static String _tianGanToJson(TianGan gan) => gan.name;
  static TianGan _tianGanFromJson(String name) => TianGan.values.firstWhere((e) => e.name == name);
}
