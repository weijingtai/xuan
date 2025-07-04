import 'package:daliuren/model/three_chuan.dart';
import 'package:json_annotation/json_annotation.dart';

import '../domain/enums/each_class_zei_ke_type.dart';
import '../domain/enums/nine_zong_men.dart';
import '../domain/enums/zei_ke_type.dart';
import 'each_chuan.dart';

part 'three_chuan_zei_ke.g.dart';

@JsonSerializable()
class ThreeChuanZeiKe extends ThreeChuan {
  ZeiKeType type;
  EachClassZeiKeType zeiKeType;
  ThreeChuanZeiKe({
    required this.type,
    required this.zeiKeType,
    required EachChuan first,
    required EachChuan second,
    required EachChuan third,
  }) : super(
            nineZongMen: NineZongMen.ZEI_KE,
            first: first,
            second: second,
            third: third);

  factory ThreeChuanZeiKe.fromJson(Map<String, dynamic> json) =>
      _$ThreeChuanZeiKeFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ThreeChuanZeiKeToJson(this);
}
