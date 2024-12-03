import 'dart:ui';

import 'package:qizhengsiyu/enums/enum_qi_zheng.dart';
import 'package:tuple/tuple.dart';

import 'enums/enum_stars.dart';
import 'enums/enum_twelve_gong.dart';
import 'enums/enum_twenty_eight_xing_xiu.dart';
import 'models/star_xiu_type.dart';

class QiZhengSiYuUIConstantResources {
  static final Map<EnumStars,Color> zhengColorMap = {
    EnumStars.Sun: Color.fromRGBO(242,190,69, 1),
    EnumStars.Moon: Color.fromRGBO(214,236,240,1), /// 233,231,239，银白；214,236,240 月白
    EnumStars.Fire: Color.fromRGBO(233,84, 100, 1),
    EnumStars.Soil:Color.fromRGBO(168,132,98, 1),
    EnumStars.Water:Color.fromRGBO(76,141,174, 1), // 23,124,176, 靛青；76,141,174,群青
    EnumStars.Wood:Color.fromRGBO(84,150,136, 1),
    EnumStars.Golden:Color.fromRGBO(240,167,46, 1)

  };
  static final Map<EnumStars,Color> starsColorMap = {
    EnumStars.Sun: Color.fromRGBO(255,164,0, 1), // 橙黄
    EnumStars.Moon: Color.fromRGBO(161,175,201,1), /// 233,231,239，银白；214,236,240 月白；161,175,201，蓝灰
    EnumStars.Fire: Color.fromRGBO(233,84, 100, 1),
    EnumStars.Soil:Color.fromRGBO(137,108,57, 1), // 秋色
    EnumStars.Water:Color.fromRGBO(76,141,174, 1), // 23,124,176, 靛青；76,141,174,群青
    EnumStars.Wood:Color.fromRGBO(84,150,136, 1),
    EnumStars.Golden:Color.fromRGBO(242,190,69, 1), // 赤金


    EnumStars.Qi:Color.fromRGBO(141,75,187, 1), // 141,75,187, 紫色
    EnumStars.Bei:Color.fromRGBO(66,80,102,1),// 161,175,201，蓝灰； 66,80,102 黛蓝
    EnumStars.Ji:Color.fromRGBO(211,177,125, 1),// 200,155,64 昏黄； 211,177,125 枯黄
    EnumStars.Luo:Color.fromRGBO(179,92,68, 1),// 茶色

  };
}