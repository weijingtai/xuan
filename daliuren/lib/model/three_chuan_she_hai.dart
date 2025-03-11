import 'package:daliuren/model/three_chuan.dart';
import 'package:daliuren/model/three_chuan_detail_type.dart';
import 'package:json_annotation/json_annotation.dart';

import 'each_chuan.dart';
import 'enum_nine_zong_men.dart';
part 'three_chuan_she_hai.g.dart';

@JsonSerializable()
class ThreeChuanSheHai extends ThreeChuan {
  SheHaiType type;
  ThreeChuanSheHai({
    required this.type,
    required EachChuan first,
    required EachChuan second,
    required EachChuan third,
  }) : super(
            nineZongMen: NineZongMen.SHE_HAI,
            first: first,
            second: second,
            third: third);

  factory ThreeChuanSheHai.fromJson(Map<String, dynamic> json) =>
      _$ThreeChuanSheHaiFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ThreeChuanSheHaiToJson(this);
}
