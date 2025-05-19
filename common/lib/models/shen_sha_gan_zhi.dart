import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import 'shen_sha.dart';
part 'shen_sha_gan_zhi.g.dart';

@JsonSerializable()
class GanZhiShenSha extends ShenSha {
  Map<DiZhi, List<JiaZi>> locationMapper;

  GanZhiShenSha(String name, JiXiongEnum jiXiong, List<String>? descriptionList,
      List<String>? locationDescriptionList, this.locationMapper)
      : super(name, jiXiong, descriptionList, locationDescriptionList);

  factory GanZhiShenSha.fromJson(Map<String, dynamic> json) =>
      _$GanZhiShenShaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GanZhiShenShaToJson(this);
}
