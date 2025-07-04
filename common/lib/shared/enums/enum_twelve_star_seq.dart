import 'package:tuple/tuple.dart';

import 'enum_twelve_ecliptic_gong.dart';

enum TwelveStarSeq {
  Jiang_Lou(0, "降娄", Tuple2(0, 30)), // MonthGeneral.XU_TIAN_KUI,
  Da_Liang(1, "大梁", Tuple2(30, 60)), // MonthGeneral.YOU_CONG_KUI,
  Shi_Shen(2, "实沈", Tuple2(60, 90)), // MonthGeneral.SHEN_CHUAN_SONG,
  Chun_Shou(3, "鹑首", Tuple2(90, 120)), // MonthGeneral.WEI_XIAO_JI,
  Chun_Huo(4, "鹑火", Tuple2(120, 150)), // MonthGeneral.WU_SHENG_GUANG,
  Chun_Wei(5, "鹑尾", Tuple2(150, 180)), // MonthGeneral.SI_TAI_YI,
  Shou_Xing(6, "寿星", Tuple2(180, 210)), // MonthGeneral.CHEN_TIAN_GANG,
  Da_Huo(7, "大火", Tuple2(210, 240)), // MonthGeneral.MAO_TAI_CHONG,
  Xi_Mu(8, "析木", Tuple2(240, 270)), // MonthGeneral.YIN_GONG_CAO,
  Xing_Ji(9, "星纪", Tuple2(270, 300)), // MonthGeneral.CHOU_DA_JI,
  Xuang_Xiao(10, "玄枵", Tuple2(300, 330)), // MonthGeneral.ZI_SHEN_HOU,
  Ju_Zi(11, "娵訾", Tuple2(330, 360)); // MonthGeneral.HAI_ZHENG_MING,

  final int order;
  final String name;
  final Tuple2<int, int> solarAngleRange;
  // final MonthGeneral monthGeneral;

  const TwelveStarSeq(this.order, this.name, this.solarAngleRange);

  TwelveEclipticGong get twelveEclipticGong =>
      TwelveEclipticGong.fromOrder(order);

  /// get by name
  static TwelveStarSeq fromName(String name) {
    return values.firstWhere((e) => e.name == name);
  }

  /// get by order
  static TwelveStarSeq fromOrder(int order) {
    return values.firstWhere((e) => e.order == order);
  }
}
