import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_ji_xiong.dart';

part 'shen_sha.g.dart';

abstract class ShenShaInterface {
  String get name;
  JiXiongEnum get jiXiong;
  List<String> get descriptionList;
  List<String> get locationDescriptionList;
}

@JsonSerializable()
class ShenSha implements ShenShaInterface {
  @override
  String name;
  @override
  JiXiongEnum jiXiong;
  @override
  List<String> descriptionList;
  @override
  List<String> locationDescriptionList;

  ShenSha(this.name, this.jiXiong, this.descriptionList,
      this.locationDescriptionList);

  factory ShenSha.fromJson(Map<String, dynamic> json) =>
      _$ShenShaFromJson(json);
  Map<String, dynamic> toJson() => _$ShenShaToJson(this);
}
