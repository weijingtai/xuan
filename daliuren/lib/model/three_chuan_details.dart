import 'package:daliuren/model/enum_nine_zong_men.dart';
import 'package:json_annotation/json_annotation.dart';

import '../domain/enums/each_class_zei_ke_type.dart';
import '../domain/enums/she_hai_type.dart';
import '../domain/enums/yao_ke_type.dart';
import '../domain/enums/zei_ke_type.dart';
import 'da_liu_ren_ke_pan.dart';
import 'each_chuan.dart';
import 'three_chuan.dart';

part 'three_chuan_details.g.dart';

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
