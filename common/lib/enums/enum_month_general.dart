import 'enum_di_zhi.dart';
import 'package:tuple/tuple.dart';

import 'enum_twenty_four_jie_qi.dart';

enum MonthGeneral {
  HAI_ZHENG_MING(
      1,
      DiZhi.HAI,
      "征明",
      Tuple2<TwentyFourJieQi, TwentyFourJieQi>(
          TwentyFourJieQi.YU_SHUI, TwentyFourJieQi.CHUN_FEN)),
  XU_TIAN_KUI(
      2,
      DiZhi.XU,
      "天魁",
      Tuple2<TwentyFourJieQi, TwentyFourJieQi>(
          TwentyFourJieQi.CHUN_FEN, TwentyFourJieQi.GU_YU)),
  YOU_CONG_KUI(
      3,
      DiZhi.YOU,
      "从魁",
      Tuple2<TwentyFourJieQi, TwentyFourJieQi>(
          TwentyFourJieQi.GU_YU, TwentyFourJieQi.XIAO_MAN)),
  SHEN_CHUAN_SONG(
      4,
      DiZhi.SHEN,
      "传送",
      Tuple2<TwentyFourJieQi, TwentyFourJieQi>(
          TwentyFourJieQi.XIAO_MAN, TwentyFourJieQi.XIA_ZHI)),
  WEI_XIAO_JI(
      5,
      DiZhi.WEI,
      "小吉",
      Tuple2<TwentyFourJieQi, TwentyFourJieQi>(
          TwentyFourJieQi.XIA_ZHI, TwentyFourJieQi.DA_SHU)),
  WU_SHENG_GUANG(
      6,
      DiZhi.WU,
      "胜光",
      Tuple2<TwentyFourJieQi, TwentyFourJieQi>(
          TwentyFourJieQi.DA_SHU, TwentyFourJieQi.CHU_SHU)),
  SI_TAI_YI(
      7,
      DiZhi.SI,
      "太乙",
      Tuple2<TwentyFourJieQi, TwentyFourJieQi>(
          TwentyFourJieQi.CHU_SHU, TwentyFourJieQi.QIU_FEN)),
  CHEN_TIAN_GANG(
      8,
      DiZhi.CHEN,
      "天罡",
      Tuple2<TwentyFourJieQi, TwentyFourJieQi>(
          TwentyFourJieQi.QIU_FEN, TwentyFourJieQi.SHUANG_JIANG)),
  MAO_TAI_CHONG(
      9,
      DiZhi.MAO,
      "太冲",
      Tuple2<TwentyFourJieQi, TwentyFourJieQi>(
          TwentyFourJieQi.SHUANG_JIANG, TwentyFourJieQi.XIAO_XUE)),
  YIN_GONG_CAO(
      10,
      DiZhi.YIN,
      "功曹",
      Tuple2<TwentyFourJieQi, TwentyFourJieQi>(
          TwentyFourJieQi.XIAO_XUE, TwentyFourJieQi.DONG_ZHI)),
  CHOU_DA_JI(
      11,
      DiZhi.CHOU,
      "大吉",
      Tuple2<TwentyFourJieQi, TwentyFourJieQi>(
          TwentyFourJieQi.DONG_ZHI, TwentyFourJieQi.DA_HAN)),
  ZI_SHEN_HOU(
      12,
      DiZhi.ZI,
      "神后",
      Tuple2<TwentyFourJieQi, TwentyFourJieQi>(
          TwentyFourJieQi.DA_HAN, TwentyFourJieQi.YU_SHUI));

  final int month;
  final String name;
  final Tuple2<TwentyFourJieQi, TwentyFourJieQi> jieSegment;
  final DiZhi generalZhi;
  const MonthGeneral(this.month, this.generalZhi, this.name, this.jieSegment);

  static MonthGeneral fromMonth(int month) =>
      values.firstWhere((element) => element.month == month);
  static MonthGeneral fromByStartAtJie(String startAtJie) {
    var jieQi = TwentyFourJieQi.fromName(startAtJie);
    return values.firstWhere((e) => e.jieSegment.item1 == jieQi);
  }

  static MonthGeneral getByDiZhi(DiZhi diZhi) {
    return values.firstWhere((e) => e.generalZhi == diZhi);
  }
}
