import 'package:common/enums.dart';
import 'package:daliuren/model/zei_key_type.dart';
import 'package:json_annotation/json_annotation.dart';

import 'each_class.dart';
import 'enum_gui_ren.dart';
part 'first_class.g.dart';

@JsonSerializable()
class FirstClass extends EachClass {
  TianGan tianGan;
  FirstClass({
    required DiZhi sky,
    required DiZhi ground,
    required GuiRen guiRen,
    required this.tianGan,
  }) : super(
            order: 0,
            sky: sky,
            ground: tenGanJiGongMapper[tianGan]!,
            guiRen: guiRen,
            isFirstClass: true) {
    // 当前为“贼” -- “下克上”
    bool isZei = FiveXingRelationship.checkRelationship(
            sky.fiveXing, tianGan.fiveXing) ==
        FiveXingRelationship.KE;
    zeiKeType = null;
    isSkyKeDayGan = null;
    if (isZei) {
      zeiKeType = EachClassZeiKeType.ZEI;
      isSkyKeDayGan = false;
    }
    // print("${tianGan.value} --- ${sky.value} --- $isZei --- ${zeiKeType?.name}");
    // 当前为“克” -- “上克下”
    bool isKe = FiveXingRelationship.checkRelationship(
            tianGan.fiveXing, sky.fiveXing) ==
        FiveXingRelationship.KE;
    if (isKe) {
      zeiKeType = EachClassZeiKeType.KE;
      isSkyKeDayGan = true;
    }
    isSkySameYinYangWithDayGan = tianGan.yinYang == sky.yinYang;
  }
  factory FirstClass.fromJson(Map<String, dynamic> json) =>
      _$FirstClassFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FirstClassToJson(this);
}
