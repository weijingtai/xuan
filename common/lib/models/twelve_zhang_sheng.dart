import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_ji_xiong.dart';
import 'shen_sha.dart';

part 'twelve_zhang_sheng.g.dart';

@JsonSerializable()
class ZhangSheng12ShenSha extends ShenSha {
  ZhangSheng12ShenSha(
    String name,
    JiXiongEnum jiXiong,
    List<String>? descriptionList,
    List<String>? locationDescriptionList,
  ) : super(name, jiXiong, descriptionList, locationDescriptionList);

  factory ZhangSheng12ShenSha.fromJson(Map<String, dynamic> json) =>
      _$ZhangSheng12ShenShaFromJson(json);
  Map<String, dynamic> toJson() => _$ZhangSheng12ShenShaToJson(this);
}
