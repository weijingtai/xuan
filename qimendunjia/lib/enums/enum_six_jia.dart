import 'package:common/enums.dart';

enum SixJia {
  JIA_ZI_WU("甲子戊", JiaZi.JIA_ZI, TianGan.WU),
  JIA_XU_JI("甲戌己", JiaZi.JIA_XU, TianGan.JI),
  JIA_SHEN_GENG("甲申庚", JiaZi.JIA_SHEN, TianGan.GENG),
  JIA_WU_XIN("甲午辛", JiaZi.JIA_WU, TianGan.XIN),
  JIA_CHNE_REN("甲辰壬", JiaZi.JIA_CHEN, TianGan.REN),
  JIA_YIN_GUI("甲寅癸", JiaZi.JIA_YIN, TianGan.GUI);

  final String name;
  final JiaZi jiaZi;
  final TianGan gan;
  const SixJia(this.name, this.jiaZi, this.gan);

  // 是否为六仪击刑
  bool isSixJiXing(HouTianGua luoGong) {
    // 甲子戊 在 震
    // 甲戌己 在 坤
    // 甲申庚 在 艮
    // 甲寅癸 在 巽
    // 甲辰壬 在 巽
    // 甲午辛 在 离
    switch (this) {
      case SixJia.JIA_ZI_WU:
        return luoGong == HouTianGua.Zhen;
      case SixJia.JIA_XU_JI:
        return luoGong == HouTianGua.Kun;
      case SixJia.JIA_SHEN_GENG:
        return luoGong == HouTianGua.Gen;
      case SixJia.JIA_WU_XIN:
        return luoGong == HouTianGua.Li;
      case SixJia.JIA_CHNE_REN:
      case SixJia.JIA_YIN_GUI:
        return luoGong == HouTianGua.Xun;
      default:
        return false;
    }
  }

  static SixJia getSixJiaByName(String name) {
    SixJia? result;
    for (SixJia sixJia in SixJia.values) {
      if (sixJia.name == name) {
        result = sixJia;
      }
    }
    if (result == null) {
      throw ArgumentError("未找到六甲, '$name'");
    }
    return result;
  }

  static SixJia getSixJiaByJiaZi(JiaZi jiaZi) {
    if (!jiaZi.name.startsWith("甲")) {
      throw ArgumentError("当前并不是六甲， ${jiaZi.name}");
    }
    return SixJia.values.firstWhere((sixJia) => sixJia.jiaZi == jiaZi,
        orElse: () => throw ArgumentError("当前并不是六甲， ${jiaZi.name}"));
  }
}
