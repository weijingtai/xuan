import 'package:common/enums.dart';

enum EightGodsEnum {
  ZHI_FU(1, "值符", "值", FiveXing.MU, HouTianGua.Kun),
  TENG_SHE(2, "腾蛇", "螣", FiveXing.HUO, HouTianGua.Li),
  TAI_YIN(3, "太阴", "阴", FiveXing.JIN, HouTianGua.Dui),
  LIU_HE(4, "六合", "合", FiveXing.MU, HouTianGua.Zhen),
  BAI_HU(5, "白虎", "虎", FiveXing.JIN, HouTianGua.Qian),
  XUAN_WU(6, "玄武", "玄", FiveXing.SHUI, HouTianGua.Kan),
  JIU_DI(7, "九地", "地", FiveXing.TU, HouTianGua.Kun),
  JIU_TIAN(8, "九天", "天", FiveXing.JIN, HouTianGua.Qian),
  ZHU_QI(9, "朱雀", "雀", FiveXing.HUO, HouTianGua.Xun),
  GOU_CHEN(10, "勾陈", "陈", FiveXing.MU, HouTianGua.Dui),
  TAI_CHANG(11, "太常", "常", FiveXing.SHUI, HouTianGua.Zhen);

  final String name;
  final int number;
  final String singleCharName;
  final FiveXing fiveXing;
  final HouTianGua gong;
  const EightGodsEnum(
      this.number, this.name, this.singleCharName, this.fiveXing, this.gong);

  static EightGodsEnum fromNumber(int number) =>
      values.firstWhere((element) => element.number == number);
  static EightGodsEnum fromName(String name) =>
      values.firstWhere((element) => element.name == name);
  static EightGodsEnum fromSingleCharName(String name) =>
      values.firstWhere((e) => e.name.startsWith(name));
  // 1、值符 2、螣蛇 3、太阴 4、六合 5、勾陈 6、太常 7、朱雀 8、九地 9、九天
  // 以上为阳遁时所用九神的排列顺序。
  static List<EightGodsEnum> get feiPanYangDunList => [
        ZHI_FU,
        TENG_SHE,
        TAI_YIN,
        LIU_HE,
        GOU_CHEN,
        TAI_CHANG,
        ZHU_QI,
        JIU_DI,
        JIU_TIAN
      ];
  // 1、值符 2、螣蛇 3、太阴 4、六合 5、白虎 6、 太常 7、玄武 8、九地 9、九天
  // 以上为阴遁时所用九神的排列顺序。
  static List<EightGodsEnum> get feiPanYinDunList => [
        ZHI_FU,
        TENG_SHE,
        TAI_YIN,
        LIU_HE,
        BAI_HU,
        TAI_CHANG,
        XUAN_WU,
        JIU_DI,
        JIU_TIAN
      ];
  static List<EightGodsEnum> get yangDunList =>
      [ZHI_FU, TENG_SHE, TAI_YIN, LIU_HE, BAI_HU, XUAN_WU, JIU_DI, JIU_TIAN];
  static List<EightGodsEnum> get yinDunList =>
      [ZHI_FU, JIU_TIAN, JIU_DI, XUAN_WU, BAI_HU, LIU_HE, TAI_YIN, TENG_SHE];
  static Map<int, EightGodsEnum> get mapNumberToEnum =>
      Map.fromEntries(values.map((e) => MapEntry(e.number, e)));

  /// 地盘干的纳卦与八神见的旺衰休囚死
  FiveEnergyStatus checkWangShuaiWithDiPanGanNaGua(TianGan diPanGan) {
    return checkWangShuaiWithGua(HouTianGua.getGuaByName(diPanGan.naJiaGua));
  }

  /// 地盘干的纳卦与八神见的旺衰休囚死
  FiveEnergyStatus checkWangShuaiWithGongGua(HouTianGua gong) {
    return checkWangShuaiWithGua(gong);
  }

  FiveEnergyStatus checkWangShuaiWithGua(HouTianGua gong) {
    FiveXingRelationship relationship =
        FiveXingRelationship.checkRelationship(fiveXing, gong.fiveXing)!;
    switch (relationship) {
      case FiveXingRelationship.SHENG:
        return FiveEnergyStatus.WANG;
      case FiveXingRelationship.TONG:
        return FiveEnergyStatus.XIANG;
      case FiveXingRelationship.XIE:
        return FiveEnergyStatus.XIU;
      case FiveXingRelationship.HAO:
        return FiveEnergyStatus.QIU;
      case FiveXingRelationship.KE:
        return FiveEnergyStatus.SI;
    }
  }
}
