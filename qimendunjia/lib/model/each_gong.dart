import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_eight_gods.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';

import '../enums/enum_six_jia.dart';

class EachGong {
  int gongNumber;
  NineStarsEnum star;
  EightDoorEnum door;
  EightGodsEnum god;
  EightGodsEnum diGod;
  HouTianGua gongGua; // 当前宫
  TianGan diPan;
  TianGan tianPan;
  TianGan? diPanJiGan; // 地盘中宫寄干
  TianGan? tianPanJiGan; // 天盘中宫寄干

  TianGan tianPanAnGan; // 天盘暗干
  TianGan renPanAnGan; // 天盘暗干
  TianGan yinGan;
  bool isJiTianQin = false; // 天芮星宫
  SixJia? sixJiaXunHeader; // 是否为旬首所在宫，如果是则sixJiaXunHeader不为空,
  EachGong({
    required this.gongNumber,
    required this.star,
    required this.door,
    required this.god,
    required this.diGod,
    required this.gongGua,
    required this.diPan,
    required this.tianPan,
    required this.tianPanAnGan,
    required this.renPanAnGan,
    required this.yinGan,
    this.sixJiaXunHeader,
  });

  bool get isSixJiXing =>
      sixJiaXunHeader != null ? sixJiaXunHeader!.isSixJiXing(gongGua) : false;
  bool get isGanFuYin {
    // 天盘干 与 地盘干相同是则为干伏吟
    return diPan == tianPan;
  }

  bool get isDoorFuYin {
    return door.originalGong.houTianOrder == gongNumber;
  }

  bool get isStarFuYin {
    return star.originalGong.houTianOrder == gongNumber;
  }

  bool get isDoorFanYin {
    if (isDoorFuYin) {
      // 当门伏吟时，一定不是反吟
      return false;
    } else {
      return gongGua.isDuiChongWithOther(door.originalGong);
    }
  }

  bool get isStarFanYin {
    if (isStarFuYin) {
      // 当门伏吟时，一定不是反吟
      return false;
    } else {
      return gongGua.isDuiChongWithOther(star.originalGong);
    }
  }

  bool get isGanFanYin {
    // 天盘干 与 地盘干 相冲
    return tianPan.isChong(diPan);
  }
  // bool get isZhiFuFanYin{
  //   // 当前天盘是六甲值符
  //
  // }
}
