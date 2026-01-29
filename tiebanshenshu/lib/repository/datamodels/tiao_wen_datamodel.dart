import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tiao_wen_datamodel.g.dart';

@JsonSerializable()
class TiaoWenDataModel {
  int id;
  DiZhi setName;
  String content1;
  String? content2;
  List<int>? ageSet1;
  List<int>? ageSet2;

  TiaoWenDataModel({
    required this.id,
    required this.setName,
    required this.content1,
    this.content2,
    required this.ageSet1,
    this.ageSet2,
  });
  factory TiaoWenDataModel.fromJson(Map<String, dynamic> json) =>
      _$TiaoWenDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$TiaoWenDataModelToJson(this);
}
