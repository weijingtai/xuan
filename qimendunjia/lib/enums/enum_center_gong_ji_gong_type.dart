import 'package:common/enums.dart'; // For HouTianGua, FourSeasons, TwentyFourJieQi, YinYang

/// 中宫寄宫类型枚举。
///
/// 定义了中宫内天干、星、门等需要寄宫时的不同策略。
enum CenterGongJiGongType {
  ONLY_KUN_GONG("坤宫"), // 只在坤宫
  KUN_GEN_GONG("艮坤"), // 坤艮宫，阴遁坤二宫，阳遁艮八宫
  FOUR_WEI_GONG("四维"), // 四维宫，立春（春）在艮八，立夏（夏）在巽四，立秋（秋）在坤二，立冬（冬）在前六
  EIGTH_GONG("八宫"); // 根据八节寄宫

  final String name;
  const CenterGongJiGongType(this.name);

  /// 根据当前的阴阳遁和节气，获取中宫内元素的寄宫宫位。
  ///
  /// [yinYangDun]: 当前局的阴阳遁。
  /// [jieQi]: 当前的节气。
  /// 返回寄宫的 [HouTianGua] (后天卦位)。
  HouTianGua getJiGong(YinYang yinYangDun, TwentyFourJieQi jieQi) {
    switch (this) {
      case KUN_GEN_GONG:
        return atKunGen(yinYangDun);
      case FOUR_WEI_GONG:
        return atFourWei(jieQi);
      case EIGTH_GONG:
        return atEightGong(jieQi);
      default: // Default is ONLY_KUN_GONG
        return atKun();
    }
  }

  /// 只寄坤二宫。
  HouTianGua atKun() {
    return HouTianGua.Kun;
  }

  /// 根据阴阳遁决定寄坤二宫或艮八宫。
  /// 阳遁寄艮八宫，阴遁寄坤二宫。
  HouTianGua atKunGen(YinYang yinYangDun) {
    return yinYangDun.isYang ? HouTianGua.Gen : HouTianGua.Kun;
  }

  /// 根据四季（通过节气判断）决定寄四维宫。
  /// 春季寄艮八宫，夏季寄巽四宫，秋季寄坤二宫，冬季寄乾六宫。
  HouTianGua atFourWei(TwentyFourJieQi jieQi) {
    HouTianGua atGong;
    switch (jieQi.season) {
      case FourSeasons.SPRING:
        atGong = HouTianGua.Gen;
        break;
      case FourSeasons.SUMMER:
        atGong = HouTianGua.Xun;
        break;
      case FourSeasons.AUTUMN:
        atGong = HouTianGua.Kun;
        break;
      default: // WINTER
        atGong = HouTianGua.Qian;
        break;
    }
    return atGong;
  }

  /// 根据八节（节令）决定寄宫。
  /// 例如：立春寄艮，春分寄震等。
  HouTianGua atEightGong(TwentyFourJieQi jieQi) {
    HouTianGua atGong;
    // mapping specific JieQi to their respective BaGua palaces for JiGong
    switch (jieQi) {
      case TwentyFourJieQi.LI_CHUN:
      case TwentyFourJieQi.YU_SHUI: // Assuming YuShui and JingZhe follow LiChun's palace if not explicitly defined
      case TwentyFourJieQi.JING_ZHE:
        atGong = HouTianGua.Gen;
        break;
      case TwentyFourJieQi.CHUN_FEN:
      case TwentyFourJieQi.QING_MING:
      case TwentyFourJieQi.GU_YU:
        atGong = HouTianGua.Zhen;
        break;
      case TwentyFourJieQi.LI_XIA:
      case TwentyFourJieQi.XIAO_MAN:
      case TwentyFourJieQi.MANG_ZHONG:
        atGong = HouTianGua.Xun;
        break;
      case TwentyFourJieQi.XIA_ZHI:
      case TwentyFourJieQi.XIAO_SHU:
      case TwentyFourJieQi.DA_SHU:
        atGong = HouTianGua.Li;
        break;
      case TwentyFourJieQi.LI_QIU:
      case TwentyFourJieQi.CHU_SHU:
      case TwentyFourJieQi.BAI_LU:
        atGong = HouTianGua.Kun;
        break;
      case TwentyFourJieQi.QIU_FEN:
      case TwentyFourJieQi.HAN_LU:
      case TwentyFourJieQi.SHUANG_JIANG:
        atGong = HouTianGua.Dui;
        break;
      case TwentyFourJieQi.LI_DONG:
      case TwentyFourJieQi.XIAO_XUE:
      case TwentyFourJieQi.DA_XUE:
        atGong = HouTianGua.Qian;
        break;
      case TwentyFourJieQi.DONG_ZHI: // DongZhi, XiaoHan, DaHan
      case TwentyFourJieQi.XIAO_HAN:
      case TwentyFourJieQi.DA_HAN:
      default: // Defaulting to Kan for winter solstice period if not covered
        atGong = HouTianGua.Kan;
        break;
    }
    return atGong;
  }
}
