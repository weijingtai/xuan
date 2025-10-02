import 'package:tuple/tuple.dart';

import 'enum_di_zhi.dart';
import 'enum_twelve_star_seq.dart';

enum TwelveEclipticGong{

  ARI(0,"白羊","Aries","♈︎",Tuple2(0, 30)), // MonthGeneral.XU_TIAN_KUI,
  TAU(1,"金牛","Taurus","♉︎",Tuple2(30, 60)), // MonthGeneral.YOU_CONG_KUI,
  GEM(2,"双子","Gemini","♊︎",Tuple2(60, 90)), // MonthGeneral.SHEN_CHUAN_SONG,
  CAN(3,"巨蟹","Cancer","♋︎",Tuple2(90, 120)), // MonthGeneral.WEI_XIAO_JI,
  LEO(4,"狮子","Leo","♌︎",Tuple2(120, 150)), // MonthGeneral.WU_SHENG_GUANG,
  VIR(5,"处女","Virgo","♍︎",Tuple2(150, 180)), // MonthGeneral.SI_TAI_YI,
  LIB(6,"天枰","Libra","♎︎",Tuple2(180, 210)), // MonthGeneral.CHEN_TIAN_GANG,
  SCO(7,"天蝎","Scorpio","♏︎",Tuple2(210, 240)), // MonthGeneral.MAO_TAI_CHONG,
  SAG(8,"射手","Sagittarius","♐︎",Tuple2(240, 270)), // MonthGeneral.YIN_GONG_CAO,
  CAP(9,"摩羯","Capricornus","♑︎",Tuple2(270, 300)), // MonthGeneral.CHOU_DA_JI,
  AQU(10,"水瓶","Aquarius","♒︎",Tuple2(300, 330)), // MonthGeneral.ZI_SHEN_HOU,
  PIS(11,"双鱼","Pisces","♓︎",Tuple2(330, 360)); // MonthGeneral.HAI_ZHENG_MING,


  final int order;
  final String name;
  final String latinName;
  final String unicode;
  final Tuple2<int,int> solarAngleRange;
  // final MonthGeneral monthGeneral;

  const TwelveEclipticGong(
      this.order,
      this.name,
      this.latinName,
      this.unicode,
      // this.monthGeneral,
      this.solarAngleRange);

  String get threeCharName => name.substring(0,3);

  TwelveStarSeq get twelveStarSeq => TwelveStarSeq.fromOrder(order);
 static TwelveEclipticGong fromDiZhi(DiZhi zhi){
   return [AQU,CAP,SAG,SCO,LIB,VIR,LEO,CAN,GEM,TAU,ARI,PIS][zhi.order-1];
 }
  /// get by name
  static TwelveEclipticGong fromName(String name){
    return values.firstWhere((e) => e.name == name);
  }
  /// get by order
  static TwelveEclipticGong fromOrder(int order){
    return values.firstWhere((e) => e.order == order);
  }
}

