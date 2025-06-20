
import 'package:qimendunjia/enums/enum_center_gong_ji_gong_type.dart';
import '../enums/enum_arrange_plate_type.dart';
import '../enums/enum_nine_stars.dart';

class PanArrangeSettings{
  ArrangeType arrangeType;
  CenterGongJiGongType jiGong;
  MonthTokenTypeEnum starMonthTokenType;
  GongTypeEnum starFourWeiGongType;
  GongTypeEnum doorFourWeiGongType;
  GanGongTypeEnum ganGongType;
  GodWithGongTypeEnum godWithGongTypeEnum;
  PanArrangeSettings({
    required this.arrangeType,
    required this.jiGong,
    required this.starMonthTokenType,
    required this.starFourWeiGongType,
    required this.doorFourWeiGongType,
    required this.godWithGongTypeEnum,
    required this.ganGongType,
});
}