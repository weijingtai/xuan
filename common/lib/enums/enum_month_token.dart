import 'enum_di_zhi.dart';
import 'enum_five_xing.dart';
import 'enum_five_xing_relationship.dart';
import 'enum_tian_gan.dart';

enum MonthToken {
  ZI(DiZhi.ZI, TianGan.GUI),
  CHOU(DiZhi.CHOU, TianGan.JI),
  YIN(DiZhi.YIN, TianGan.JIA),
  MAO(DiZhi.MAO, TianGan.YI),
  CHEN(DiZhi.CHEN, TianGan.WU),
  SI(DiZhi.SI, TianGan.BING),
  WU(DiZhi.WU, TianGan.DING),
  WEI(DiZhi.WEI, TianGan.JI),
  SHEN(DiZhi.SHEN, TianGan.GENG),
  YOU(DiZhi.YOU, TianGan.XIN),
  XU(DiZhi.XU, TianGan.WU),
  HAI(DiZhi.HAI, TianGan.REN);

  final DiZhi diZhi;
  final TianGan majorQi;
  const MonthToken(this.diZhi, this.majorQi);
  // 通过地支获取
  static MonthToken fromDiZhi(DiZhi diZhi) =>
      values.firstWhere((element) => element.diZhi == diZhi);
  FiveEnergyStatus checkFiveXingWangShuai(FiveXing fiveXing) =>
      FiveEnergyStatus.getFiveXingWangShuaiAtDiZhi(diZhi, fiveXing);
}
