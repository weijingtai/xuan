
import 'package:common/model/enum_month_general.dart';
import 'package:common/model/enum_month_token.dart';
import 'package:common/model/enum_twelve_ecliptic_gong.dart';
import 'package:tuple/tuple.dart';

import 'enum_yin_yang.dart';

enum FourSeasons{
  SPRING(0,"春"),
  SUMMER(1,"夏"),
  AUTUMN(2,"秋"),
  WINTER(3,"冬");
  final int order;
  final String name;
  const FourSeasons(this.order,this.name);

  // get by name
  static FourSeasons fromName(String name){
    return values.firstWhere((e) => e.name == name);
  }
}
enum TwentyFourJieQi{
  DONG_ZHI(0,"冬至",FourSeasons.WINTER,MonthToken.ZI,270,TwelveEclipticGong.CAP),
  XIAO_HAN(1,"小寒",FourSeasons.WINTER,MonthToken.CHOU,285,TwelveEclipticGong.CAP),
  DA_HAN(2,"大寒",FourSeasons.WINTER,MonthToken.CHOU,300,TwelveEclipticGong.AQU),

  LI_CHUN(3,"立春",FourSeasons.SPRING,MonthToken.YIN,315,TwelveEclipticGong.AQU),
  YU_SHUI(4,"雨水",FourSeasons.SPRING,MonthToken.YIN,330,TwelveEclipticGong.GEM),
  JING_ZHE(5,"惊蛰",FourSeasons.SPRING,MonthToken.MAO,345,TwelveEclipticGong.GEM),

  CHUN_FEN(6,"春分",FourSeasons.SPRING,MonthToken.MAO,0,TwelveEclipticGong.ARI),
  QING_MING(7,"清明",FourSeasons.SPRING,MonthToken.CHEN,15,TwelveEclipticGong.ARI),
  GU_YU(8,"谷雨",FourSeasons.SPRING,MonthToken.CHEN,30,TwelveEclipticGong.TAU),

  LI_XIA(9,"立夏",FourSeasons.SUMMER,MonthToken.SI,45,TwelveEclipticGong.TAU),
  XIAO_MAN(10,"小满",FourSeasons.SUMMER,MonthToken.SI,60,TwelveEclipticGong.GEM),
  MANG_ZHONG(11,"芒种",FourSeasons.SUMMER,MonthToken.WU,75,TwelveEclipticGong.GEM),
  XIA_ZHI(12,"夏至",FourSeasons.SUMMER,MonthToken.WU,90,TwelveEclipticGong.CAN),
  XIAO_SHU(13,"小暑",FourSeasons.SUMMER,MonthToken.WEI,105,TwelveEclipticGong.CAN),
  DA_SHU(14,"大暑",FourSeasons.SUMMER,MonthToken.WEI,120,TwelveEclipticGong.LEO),

  LI_QIU(15,"立秋",FourSeasons.AUTUMN,MonthToken.SHEN,135,TwelveEclipticGong.GEM),
  CHU_SHU(16,"处暑",FourSeasons.AUTUMN,MonthToken.SHEN,150,TwelveEclipticGong.VIR),
  BAI_LU(17,"白露",FourSeasons.AUTUMN,MonthToken.YOU,165,TwelveEclipticGong.VIR),
  QIU_FEN(18,"秋分",FourSeasons.AUTUMN,MonthToken.YOU,180,TwelveEclipticGong.LIB),
  HAN_LU(19,"寒露",FourSeasons.AUTUMN,MonthToken.XU,195,TwelveEclipticGong.LIB),
  SHUANG_JIANG(20,"霜降",FourSeasons.AUTUMN,MonthToken.XU,210,TwelveEclipticGong.SCO),

  LI_DONG(21,"立冬",FourSeasons.WINTER,MonthToken.HAI,225,TwelveEclipticGong.SCO),
  XIAO_XUE(22,"小雪",FourSeasons.WINTER,MonthToken.HAI,240,TwelveEclipticGong.SAG),
  DA_XUE(23,"大雪",FourSeasons.WINTER,MonthToken.ZI,255,TwelveEclipticGong.SAG);


  final int order;
  final String name;
  final FourSeasons season;
  final MonthToken monthToken;
  final TwelveEclipticGong twelveEclipticGong;
  final int solarAngle;
  const TwentyFourJieQi(this.order,this.name,this.season,this.monthToken,this.solarAngle,this.twelveEclipticGong);
  static TwentyFourJieQi fromOrder(int order){
    return values.firstWhere((element) => element.order == order);
  }
  static TwentyFourJieQi fromName(String name){
    return values.firstWhere((element) => element.name == name);
  }
  /// 获取节
  static List<TwentyFourJieQi> listJie(){
    return [
      LI_CHUN,
      JING_ZHE,
      QING_MING,
      LI_XIA,
      MANG_ZHONG,
      XIAO_SHU,
      LI_QIU,
      BAI_LU,
      HAN_LU,
      LI_DONG,
      DA_XUE,
      XIAO_HAN];
  }

  static List<TwentyFourJieQi> listQi(){
    return [
      YU_SHUI,
      CHUN_FEN,
      GU_YU,
      XIAO_MAN,
      XIA_ZHI,
      DA_SHU,
      CHU_SHU,
      QIU_FEN,
      SHUANG_JIANG,
      XIAO_XUE,
      DONG_ZHI,
      DA_HAN];
  }
  // 冬至及冬至之后的节气为阳遁
  // 夏至以及夏至之后的节气为阴遁
  YinYang get yinYangDun => order  >= TwentyFourJieQi.XIA_ZHI.order ? YinYang.YIN : YinYang.YANG;
  // 返回当前节气所属的八节
  TwentyFourJieQi underEightJie()=>checkEightJieByJieQi(this);
  // 根据给定节气找到对应所属的“四立”
  static TwentyFourJieQi checkEightJieByJieQi(TwentyFourJieQi jieQi){
    if ({3,4,5}.contains(jieQi.order)){
      return LI_CHUN;
    }else if ({6,7,8}.contains(jieQi.order)){
      return CHUN_FEN;
    }else if({9,10,11}.contains(jieQi.order)){
      return LI_XIA;
    }else if ({12,13,14}.contains(jieQi.order)){
      return XIA_ZHI;
    }else if ({15,16,17}.contains(jieQi.order)){
      return LI_QIU;
    }else if ({18,19,20}.contains(jieQi.order)){
      return QIU_FEN;
    }else if ({21,22,23}.contains(jieQi.order)){
      return LI_DONG;
    }else{
      return DONG_ZHI;
    }
  }


  // 根据给定节气找到对应所属的“四立”
  static TwentyFourJieQi checkFourLiByJieQi(TwentyFourJieQi jieQi){
    if (jieQi.order >= 3 && jieQi.order <= 8){
      return TwentyFourJieQi.LI_CHUN;
    } else if (jieQi.order >= 9 && jieQi.order <= 14){
      return TwentyFourJieQi.LI_XIA;
    }else if (jieQi.order >= 15 && jieQi.order <= 20){
      return TwentyFourJieQi.LI_QIU;
    }else {
      return TwentyFourJieQi.LI_DONG;
    }
  }
}


