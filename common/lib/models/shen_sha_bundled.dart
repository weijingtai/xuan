import 'package:common/models/shen_sha.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:common/enums.dart';

part 'shen_sha_bundled.g.dart';

enum BundledShenShaType {
  @JsonValue("驾前")
  beforeJia, // 驾前十二论宫煞
  @JsonValue("驾后")
  afterJia, // 驾后神煞
  @JsonValue("马前")
  beforeHorse; // 马前诸课
}

@JsonSerializable()
class BundledShenSha extends ShenSha {
  BundledShenShaType type;
  String name;
  JiXiongEnum jiXiong;
  int offset; // 马前诸煞的offset 是相对于 红鸾的而非太岁

  @JsonKey(includeFromJson: true, includeToJson: false)
  List<String>? descriptionList;

  @JsonKey(includeFromJson: true, includeToJson: false)
  List<String>? locationDescriptionList;

  BundledShenSha(this.type, this.name, this.jiXiong, this.offset,
      this.descriptionList, this.locationDescriptionList)
      : super(name, jiXiong, descriptionList, locationDescriptionList);

  factory BundledShenSha.fromJson(Map<String, dynamic> json) =>
      _$BundledShenShaFromJson(json);
  Map<String, dynamic> toJson() => _$BundledShenShaToJson(this);
}

@JsonSerializable()
class OtherShenSha extends ShenSha {
  String name;
  JiXiongEnum jiXiong;
  List<String>? descriptionList;
  List<String>? locationDescriptionList;

  OtherShenSha(this.name, this.jiXiong, this.descriptionList,
      this.locationDescriptionList)
      : super(name, jiXiong, descriptionList, locationDescriptionList);

  factory OtherShenSha.fromJson(Map<String, dynamic> json) =>
      _$OtherShenShaFromJson(json);
  Map<String, dynamic> toJson() => _$OtherShenShaToJson(this);
}
