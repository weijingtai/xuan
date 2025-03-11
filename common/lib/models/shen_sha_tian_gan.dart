import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_ji_xiong.dart';
import 'shen_sha.dart';

part 'shen_sha_tian_gan.g.dart';

@JsonSerializable()
class TianGanShenSha extends ShenSha {
  TianGanShenSha(
    String name,
    JiXiongEnum jiXiong,
    List<String> descriptionList,
    List<String> locationDescriptionList,
  ) : super(name, jiXiong, descriptionList, locationDescriptionList);

  factory TianGanShenSha.fromJson(Map<String, dynamic> json) =>
      _$TianGanShenShaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TianGanShenShaToJson(this);
}
