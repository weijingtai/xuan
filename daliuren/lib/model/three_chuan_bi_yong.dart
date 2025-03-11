import 'package:daliuren/model/three_chuan.dart';
import 'package:json_annotation/json_annotation.dart';

import 'each_chuan.dart';
import 'enum_nine_zong_men.dart';
part 'three_chuan_bi_yong.g.dart';

@JsonSerializable()
class ThreeChuanBiYong extends ThreeChuan {
  ThreeChuanBiYong({
    required EachChuan first,
    required EachChuan second,
    required EachChuan third,
  }) : super(
            nineZongMen: NineZongMen.BI_YONG,
            first: first,
            second: second,
            third: third);

  factory ThreeChuanBiYong.fromJson(Map<String, dynamic> json) =>
      _$ThreeChuanBiYongFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ThreeChuanBiYongToJson(this);
}
