import 'package:common/model/enum_di_zhi.dart';
import 'package:common/model/enum_twelve_star_seq.dart';
import 'package:common/module.dart';

import 'enum_qi_zheng.dart';
import 'enum_stars.dart';

enum EnumDestinyTwelveGong {
  Ming(0, "命宫", true),
  CaiBo(1, "财帛", true),
  XiongDi(2, "兄弟", false),
  TianZhai(3, "田宅", true),
  NanNv(4, "男女", false),
  NuPu(5, "奴仆", false),
  FuQi(6, "夫妻", true),
  JiE(7, "疾厄", false),
  QianYi(8, "迁移", false),
  GuanLu(9, "官禄", true),
  FuDe(10, "福德", true),
  XiangMao(11, "相貌", false);

  final int orderedIndex;
  final String name;
  final bool isStrong;
  const EnumDestinyTwelveGong(
    this.orderedIndex,
    this.name,
    this.isStrong,
  );
}

enum EnumTwelveGong {
  Zi(DiZhi.ZI, HouTianGua.Kan, EnumStars.Soil, TwelveStarSeq.Xuang_Xiao,
      TwelveEclipticGong.AQU, false),
  Chou(DiZhi.CHOU, HouTianGua.Kan, EnumStars.Soil, TwelveStarSeq.Xing_Ji,
      TwelveEclipticGong.CAP, false),
  Yin(DiZhi.YIN, HouTianGua.Gen, EnumStars.Wood, TwelveStarSeq.Xi_Mu,
      TwelveEclipticGong.SAG, false),
  Mao(DiZhi.MAO, HouTianGua.Zhen, EnumStars.Fire, TwelveStarSeq.Da_Huo,
      TwelveEclipticGong.SCO, true),
  Chen(DiZhi.CHEN, HouTianGua.Xun, EnumStars.Golden, TwelveStarSeq.Shou_Xing,
      TwelveEclipticGong.LIB, true),
  Si(DiZhi.SI, HouTianGua.Xun, EnumStars.Water, TwelveStarSeq.Chun_Wei,
      TwelveEclipticGong.VIR, true),
  Wu(DiZhi.WU, HouTianGua.Li, EnumStars.Sun, TwelveStarSeq.Chun_Huo,
      TwelveEclipticGong.LEO, true),
  Wei(DiZhi.WEI, HouTianGua.Kun, EnumStars.Moon, TwelveStarSeq.Chun_Shou,
      TwelveEclipticGong.CAN, true),
  Shen(DiZhi.SHEN, HouTianGua.Kun, EnumStars.Water, TwelveStarSeq.Shi_Shen,
      TwelveEclipticGong.GEM, true),
  You(DiZhi.YOU, HouTianGua.Dui, EnumStars.Golden, TwelveStarSeq.Da_Liang,
      TwelveEclipticGong.TAU, false),
  Xu(DiZhi.XU, HouTianGua.Qian, EnumStars.Fire, TwelveStarSeq.Jiang_Lou,
      TwelveEclipticGong.ARI, false),
  Hai(DiZhi.HAI, HouTianGua.Qian, EnumStars.Wood, TwelveStarSeq.Ju_Zi,
      TwelveEclipticGong.PIS, false);

  final DiZhi zhi;
  final HouTianGua houTianGua;
  final EnumStars zheng;
  final TwelveStarSeq starSeq;
  final TwelveEclipticGong twelveEclipticGong;

  final bool isDayOrNight;
  String get fullname => "${zhi.name}${houTianGua.name}${zheng.singleName}";
  static get eclipticSeq =>
      [Xu, You, Shen, Wei, Wu, Si, Chen, Mao, Yin, Chou, Zi, Hai];

  const EnumTwelveGong(this.zhi, this.houTianGua, this.zheng, this.starSeq,
      this.twelveEclipticGong, this.isDayOrNight);
  static EnumTwelveGong getEnumTwelveGongByZhi(DiZhi zhi) {
    return EnumTwelveGong.values.where((e) => e.zhi == zhi).first;
  }
}
