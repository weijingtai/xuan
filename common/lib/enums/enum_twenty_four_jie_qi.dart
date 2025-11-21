import 'enum_four_seasons.dart';
import 'package:json_annotation/json_annotation.dart';

import 'enum_month_token.dart';
import 'enum_twelve_ecliptic_gong.dart';
import 'enum_yin_yang.dart';

enum TwentyFourJieQi {
  @JsonValue("冬至")
  DONG_ZHI(
      0, "冬至", FourSeasons.WINTER, MonthToken.ZI, 270, TwelveEclipticGong.CAP),
  @JsonValue("小寒")
  XIAO_HAN(1, "小寒", FourSeasons.WINTER, MonthToken.CHOU, 285,
      TwelveEclipticGong.CAP),
  @JsonValue("大寒")
  DA_HAN(2, "大寒", FourSeasons.WINTER, MonthToken.CHOU, 300,
      TwelveEclipticGong.AQU),

  @JsonValue("立春")
  LI_CHUN(
      3, "立春", FourSeasons.SPRING, MonthToken.YIN, 315, TwelveEclipticGong.AQU),
  @JsonValue("雨水")
  YU_SHUI(
      4, "雨水", FourSeasons.SPRING, MonthToken.YIN, 330, TwelveEclipticGong.GEM),
  @JsonValue("惊蛰")
  JING_ZHE(
      5, "惊蛰", FourSeasons.SPRING, MonthToken.MAO, 345, TwelveEclipticGong.GEM),

  @JsonValue("春分")
  CHUN_FEN(
      6, "春分", FourSeasons.SPRING, MonthToken.MAO, 0, TwelveEclipticGong.ARI),
  @JsonValue("清明")
  QING_MING(
      7, "清明", FourSeasons.SPRING, MonthToken.CHEN, 15, TwelveEclipticGong.ARI),
  @JsonValue("谷雨")
  GU_YU(
      8, "谷雨", FourSeasons.SPRING, MonthToken.CHEN, 30, TwelveEclipticGong.TAU),

  @JsonValue("立夏")
  LI_XIA(
      9, "立夏", FourSeasons.SUMMER, MonthToken.SI, 45, TwelveEclipticGong.TAU),
  @JsonValue("小满")
  XIAO_MAN(
      10, "小满", FourSeasons.SUMMER, MonthToken.SI, 60, TwelveEclipticGong.GEM),
  @JsonValue("芒种")
  MANG_ZHONG(
      11, "芒种", FourSeasons.SUMMER, MonthToken.WU, 75, TwelveEclipticGong.GEM),
  @JsonValue("夏至")
  XIA_ZHI(
      12, "夏至", FourSeasons.SUMMER, MonthToken.WU, 90, TwelveEclipticGong.CAN),
  @JsonValue("小暑")
  XIAO_SHU(13, "小暑", FourSeasons.SUMMER, MonthToken.WEI, 105,
      TwelveEclipticGong.CAN),
  @JsonValue("大暑")
  DA_SHU(14, "大暑", FourSeasons.SUMMER, MonthToken.WEI, 120,
      TwelveEclipticGong.LEO),

  @JsonValue("立秋")
  LI_QIU(15, "立秋", FourSeasons.AUTUMN, MonthToken.SHEN, 135,
      TwelveEclipticGong.GEM),
  @JsonValue("处暑")
  CHU_SHU(16, "处暑", FourSeasons.AUTUMN, MonthToken.SHEN, 150,
      TwelveEclipticGong.VIR),
  @JsonValue("白露")
  BAI_LU(17, "白露", FourSeasons.AUTUMN, MonthToken.YOU, 165,
      TwelveEclipticGong.VIR),
  @JsonValue("秋分")
  QIU_FEN(18, "秋分", FourSeasons.AUTUMN, MonthToken.YOU, 180,
      TwelveEclipticGong.LIB),
  @JsonValue("寒露")
  HAN_LU(
      19, "寒露", FourSeasons.AUTUMN, MonthToken.XU, 195, TwelveEclipticGong.LIB),
  @JsonValue("霜降")
  SHUANG_JIANG(
      20, "霜降", FourSeasons.AUTUMN, MonthToken.XU, 210, TwelveEclipticGong.SCO),

  @JsonValue("立冬")
  LI_DONG(21, "立冬", FourSeasons.WINTER, MonthToken.HAI, 225,
      TwelveEclipticGong.SCO),
  @JsonValue("小雪")
  XIAO_XUE(22, "小雪", FourSeasons.WINTER, MonthToken.HAI, 240,
      TwelveEclipticGong.SAG),
  @JsonValue("大雪")
  DA_XUE(
      23, "大雪", FourSeasons.WINTER, MonthToken.ZI, 255, TwelveEclipticGong.SAG);

  final int order;
  final String name;
  final FourSeasons season;
  final MonthToken monthToken;
  final TwelveEclipticGong twelveEclipticGong;
  final int solarAngle;
  const TwentyFourJieQi(this.order, this.name, this.season, this.monthToken,
      this.solarAngle, this.twelveEclipticGong);
  static TwentyFourJieQi fromOrder(int order) {
    return values.firstWhere((element) => element.order == order);
  }

  static TwentyFourJieQi fromName(String name) {
    return values.firstWhere((element) => element.name == name);
  }

  // getPrevious
  TwentyFourJieQi get previous {
    int order = this.order - 1;
    if (order < 0) {
      order = 23;
    }
    return values[order];
  }

  TwentyFourJieQi get next {
    int order = this.order + 1;
    if (order > 23) {
      order = 0;
    }
    return values[order];
  }

  /// 获取节
  static List<TwentyFourJieQi> listJie() {
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
      XIAO_HAN
    ];
  }

  static List<TwentyFourJieQi> listQi() {
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
      DA_HAN
    ];
  }

  // 冬至及冬至之后的节气为阳遁
  // 夏至以及夏至之后的节气为阴遁
  YinYang get yinYangDun =>
      order >= TwentyFourJieQi.XIA_ZHI.order ? YinYang.YIN : YinYang.YANG;
  // 返回当前节气所属的八节
  TwentyFourJieQi underEightJie() => checkEightJieByJieQi(this);
  // 根据给定节气找到对应所属的“四立”
  static TwentyFourJieQi checkEightJieByJieQi(TwentyFourJieQi jieQi) {
    if ({3, 4, 5}.contains(jieQi.order)) {
      return LI_CHUN;
    } else if ({6, 7, 8}.contains(jieQi.order)) {
      return CHUN_FEN;
    } else if ({9, 10, 11}.contains(jieQi.order)) {
      return LI_XIA;
    } else if ({12, 13, 14}.contains(jieQi.order)) {
      return XIA_ZHI;
    } else if ({15, 16, 17}.contains(jieQi.order)) {
      return LI_QIU;
    } else if ({18, 19, 20}.contains(jieQi.order)) {
      return QIU_FEN;
    } else if ({21, 22, 23}.contains(jieQi.order)) {
      return LI_DONG;
    } else {
      return DONG_ZHI;
    }
  }

  // 根据给定节气找到对应所属的“四立”
  static TwentyFourJieQi checkFourLiByJieQi(TwentyFourJieQi jieQi) {
    if (jieQi.order >= 3 && jieQi.order <= 8) {
      return TwentyFourJieQi.LI_CHUN;
    } else if (jieQi.order >= 9 && jieQi.order <= 14) {
      return TwentyFourJieQi.LI_XIA;
    } else if (jieQi.order >= 15 && jieQi.order <= 20) {
      return TwentyFourJieQi.LI_QIU;
    } else {
      return TwentyFourJieQi.LI_DONG;
    }
  }
}
