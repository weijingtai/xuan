import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_ji_xiong.dart';

part 'shen_sha.g.dart';

abstract class ShenShaInterface {
  String get name;
  JiXiongEnum get jiXiong;
  List<String>? get descriptionList;
  List<String>? get locationDescriptionList;
}

// enum ShenShaTypeEnum {
//   @JsonValue("year")
//   Year, // 年上神煞
//   @JsonValue("month")
//   Month, // 月上神煞
//   @JsonValue("day")
//   Day, // 日上神煞
//   @JsonValue("time")
//   Time; // 时上神煞
// }
@JsonSerializable()
class ShenSha implements ShenShaInterface {
  @override
  String name;
  @override
  JiXiongEnum jiXiong;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  List<String>? descriptionList;
  @override
  @JsonKey(includeFromJson: true, includeToJson: false)
  List<String>? locationDescriptionList;

  ShenSha(this.name, this.jiXiong, this.descriptionList,
      this.locationDescriptionList);

  factory ShenSha.fromJson(Map<String, dynamic> json) =>
      _$ShenShaFromJson(json);
  Map<String, dynamic> toJson() => _$ShenShaToJson(this);
}

@JsonSerializable()
class ShenShaItem extends ShenSha {
  ShenShaItem({required String name, required JiXiongEnum jiXiong})
      : super(name, jiXiong, null, null);

  factory ShenShaItem.fromJson(Map<String, dynamic> json) =>
      _$ShenShaItemFromJson(json);
  Map<String, dynamic> toJson() => _$ShenShaItemToJson(this);

  static ShenShaItem fromShenSha(ShenSha shenSha) {
    return ShenShaItem(
      name: shenSha.name,
      jiXiong: shenSha.jiXiong,
    );
  }
}
