
import 'package:common/model/enum_di_zhi.dart';
import 'package:common/model/enum_liu_qin.dart';
import 'package:common/model/enum_tian_gan.dart';
import 'package:daliuren/model/enum_nine_zong_men.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';

import 'each_chuan.dart';
import 'enum_gui_ren.dart';
import 'four_class.dart';
part 'three_chuan.g.dart';


@JsonSerializable()
class ThreeChuan{

  NineZongMen nineZongMen;
  EachChuan first;
  EachChuan second;
  EachChuan third;

  ThreeChuan({
    required this.nineZongMen,
    required this.first,
    required this.second,
    required this.third,
  });

  factory ThreeChuan.fromJson(Map<String, dynamic> json) => _$ThreeChuanFromJson(json);
  Map<String, dynamic> toJson() => _$ThreeChuanToJson(this);
}


// class ThreeChuanMaoXing extends ThreeChuan{
//   ThreeChuanMaoXing({
//     required EachChuan first,
//     required EachChuan second,
//     required EachChuan third,
//   }):super(
//       nineZongMen: NineZongMen.MAO_XING,
//       first: first,
//       second: second,
//       third: third);
// }

