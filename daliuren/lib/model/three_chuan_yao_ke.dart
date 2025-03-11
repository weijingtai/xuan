import 'package:daliuren/model/three_chuan.dart';
import 'package:daliuren/model/three_chuan_detail_type.dart';
import 'package:json_annotation/json_annotation.dart';

import 'each_chuan.dart';
import 'enum_nine_zong_men.dart';
part 'three_chuan_yao_ke.g.dart';

@JsonSerializable()
class ThreeChuanYaoKe extends ThreeChuan {
  YaoKeType? type;
  bool? isBiYong;
  SheHaiType? sheHaiType;
  ThreeChuanYaoKe(
      {this.type,
      required EachChuan first,
      required EachChuan second,
      required EachChuan third,
      this.isBiYong,
      this.sheHaiType})
      : super(
            nineZongMen: NineZongMen.YAO_KE,
            first: first,
            second: second,
            third: third);
  factory ThreeChuanYaoKe.fromJson(Map<String, dynamic> json) =>
      _$ThreeChuanYaoKeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ThreeChuanYaoKeToJson(this);
}
