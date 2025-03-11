import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

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
  @JsonValue("子")
  Zi(DiZhi.ZI, HouTianGua.Kan, EnumStars.Saturn, TwelveStarSeq.Xuang_Xiao,
      TwelveEclipticGong.AQU, false, YinYang.YANG),
  @JsonValue("丑")
  Chou(DiZhi.CHOU, HouTianGua.Kan, EnumStars.Saturn, TwelveStarSeq.Xing_Ji,
      TwelveEclipticGong.CAP, false, YinYang.YIN),
  @JsonValue("寅")
  Yin(DiZhi.YIN, HouTianGua.Gen, EnumStars.Jupiter, TwelveStarSeq.Xi_Mu,
      TwelveEclipticGong.SAG, false, YinYang.YANG),

  @JsonValue("卯")
  Mao(DiZhi.MAO, HouTianGua.Zhen, EnumStars.Mars, TwelveStarSeq.Da_Huo,
      TwelveEclipticGong.SCO, true, YinYang.YIN),

  @JsonValue("辰")
  Chen(DiZhi.CHEN, HouTianGua.Xun, EnumStars.Venus, TwelveStarSeq.Shou_Xing,
      TwelveEclipticGong.LIB, true, YinYang.YANG),

  @JsonValue("巳")
  Si(DiZhi.SI, HouTianGua.Xun, EnumStars.Mercury, TwelveStarSeq.Chun_Wei,
      TwelveEclipticGong.VIR, true, YinYang.YIN),

  @JsonValue("午")
  Wu(DiZhi.WU, HouTianGua.Li, EnumStars.Sun, TwelveStarSeq.Chun_Huo,
      TwelveEclipticGong.LEO, true, YinYang.YANG),
  @JsonValue("未")
  Wei(DiZhi.WEI, HouTianGua.Kun, EnumStars.Moon, TwelveStarSeq.Chun_Shou,
      TwelveEclipticGong.CAN, true, YinYang.YIN),
  @JsonValue("申")
  Shen(DiZhi.SHEN, HouTianGua.Kun, EnumStars.Mercury, TwelveStarSeq.Shi_Shen,
      TwelveEclipticGong.GEM, true, YinYang.YANG),

  @JsonValue("酉")
  You(DiZhi.YOU, HouTianGua.Dui, EnumStars.Venus, TwelveStarSeq.Da_Liang,
      TwelveEclipticGong.TAU, false, YinYang.YIN),

  @JsonValue("戌")
  Xu(DiZhi.XU, HouTianGua.Qian, EnumStars.Mars, TwelveStarSeq.Jiang_Lou,
      TwelveEclipticGong.ARI, false, YinYang.YANG),

  @JsonValue("亥")
  Hai(DiZhi.HAI, HouTianGua.Qian, EnumStars.Jupiter, TwelveStarSeq.Ju_Zi,
      TwelveEclipticGong.PIS, false, YinYang.YIN);

  final DiZhi zhi;
  final HouTianGua houTianGua;
  final EnumStars zheng;
  final TwelveStarSeq starSeq;
  final TwelveEclipticGong twelveEclipticGong;

  final bool isDayOrNight;
  final YinYang yinYangGong;
  String get fullname => "${zhi.name}${houTianGua.name}${zheng.singleName}";
  static get eclipticSeq =>
      [Xu, You, Shen, Wei, Wu, Si, Chen, Mao, Yin, Chou, Zi, Hai];

  const EnumTwelveGong(this.zhi, this.houTianGua, this.zheng, this.starSeq,
      this.twelveEclipticGong, this.isDayOrNight, this.yinYangGong);
  static EnumTwelveGong getEnumTwelveGongByZhi(DiZhi zhi) {
    return EnumTwelveGong.values.where((e) => e.zhi == zhi).first;
  }
}
