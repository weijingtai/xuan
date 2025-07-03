import 'package:json_annotation/json_annotation.dart';
import 'each_chuan_data_model.dart'; // Updated import
import 'package:daliuren/domain/enums/nine_zong_men.dart'; // Updated import

part 'three_chuan_data_model.g.dart';

@JsonSerializable()
class ThreeChuanDataModel {
  final EachChuanDataModel first;
  final EachChuanDataModel second;
  final EachChuanDataModel third;

  // NineZongMen enum from domain/enums now has @JsonValue
  final NineZongMen nineZongMen; // 课体 九宗门

  ThreeChuanDataModel({
    required this.first,
    required this.second,
    required this.third,
    required this.nineZongMen,
  });

  factory ThreeChuanDataModel.fromJson(Map<String, dynamic> json) =>
      _$ThreeChuanDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$ThreeChuanDataModelToJson(this);
}
