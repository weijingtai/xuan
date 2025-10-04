import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import 'shen_sha.dart';

part 'shen_sha_tian_gan.g.dart';

@JsonSerializable()
class TianGanShenSha extends ShenSha {
  Map<TianGan, DiZhi> locationMapper;
  TianGanShenSha(
    String name,
    JiXiongEnum jiXiong,
    List<String>? descriptionList,
    List<String>? locationDescriptionList,
    this.locationMapper,
  ) : super(name, jiXiong, descriptionList, locationDescriptionList);

  factory TianGanShenSha.fromJson(Map<String, dynamic> json) =>
      _$TianGanShenShaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TianGanShenShaToJson(this);
}
