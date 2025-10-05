import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:common/enums.dart';
import 'shen_sha.dart';
part 'shen_sha_di_zhi.g.dart';

@JsonSerializable()
class DiZhiShenSha extends ShenSha {
  Map<DiZhi, DiZhi> locationMapper;

  DiZhiShenSha(String name, JiXiongEnum jiXiong, List<String>? descriptionList,
      List<String>? locationDescriptionList, this.locationMapper)
      : super(name, jiXiong, descriptionList, locationDescriptionList);

  factory DiZhiShenSha.fromJson(Map<String, dynamic> json) =>
      _$DiZhiShenShaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DiZhiShenShaToJson(this);
}
