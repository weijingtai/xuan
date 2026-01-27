// enum TianGan { jia, yi, bing, ding, wu, ji, geng, xin, ren, gui }

// enum DiZhi { zi, chou, yin, mao, chen, si, wu, wei, shen, you, xu, hai }

// enum EnumDayNight { day, night }

import 'package:common/enums.dart';

import 'calculate_month_general_service.dart';

class CalculateGuiRenPositionService {
  // 甲戊庚牛羊
  static Map<TianGan, DiZhi> version1DayGod = {
    TianGan.JIA: DiZhi.WEI,
    TianGan.YI: DiZhi.SHEN,
    TianGan.BING: DiZhi.YOU,
    TianGan.DING: DiZhi.XU,
    TianGan.WU: DiZhi.CHOU,
    TianGan.JI: DiZhi.ZI,
    TianGan.GENG: DiZhi.CHOU,
    TianGan.XIN: DiZhi.YIN,
    TianGan.REN: DiZhi.MAO,
    TianGan.GUI: DiZhi.SI,
  };
  // 甲戊庚牛羊
  static Map<TianGan, DiZhi> version1NightGod = {
    TianGan.JIA: DiZhi.CHOU,
    TianGan.YI: DiZhi.ZI,
    TianGan.BING: DiZhi.HAI,
    TianGan.DING: DiZhi.YOU,
    TianGan.WU: DiZhi.WEI,
    TianGan.JI: DiZhi.SHEN,
    TianGan.GENG: DiZhi.WEI,
    TianGan.XIN: DiZhi.WU,
    TianGan.REN: DiZhi.SI,
    TianGan.GUI: DiZhi.MAO,
  };

  // 甲戊兼牛羊
  static Map<TianGan, DiZhi> version2DayGod = {
    TianGan.JIA: DiZhi.CHOU,
    TianGan.YI: DiZhi.SHEN,
    TianGan.BING: DiZhi.YOU,
    TianGan.DING: DiZhi.HAI,
    TianGan.WU: DiZhi.CHOU,
    TianGan.JI: DiZhi.ZI,
    TianGan.GENG: DiZhi.WEI,
    TianGan.XIN: DiZhi.WU,
    TianGan.REN: DiZhi.MAO,
    TianGan.GUI: DiZhi.SI,
  };
  // 甲戊兼牛羊
  static Map<TianGan, DiZhi> version2NightGod = {
    TianGan.JIA: DiZhi.WEI,
    TianGan.YI: DiZhi.ZI,
    TianGan.BING: DiZhi.HAI,
    TianGan.DING: DiZhi.YOU,
    TianGan.WU: DiZhi.WEI,
    TianGan.JI: DiZhi.SHEN,
    TianGan.GENG: DiZhi.CHOU,
    TianGan.XIN: DiZhi.YIN,
    TianGan.REN: DiZhi.SI,
    TianGan.GUI: DiZhi.MAO,
  };

  // 甲羊戊庚牛
  static Map<TianGan, DiZhi> version3DayGod = {
    TianGan.JIA: DiZhi.WEI,
    TianGan.YI: DiZhi.SHEN,
    TianGan.BING: DiZhi.YOU,
    TianGan.DING: DiZhi.HAI,
    TianGan.WU: DiZhi.CHOU,
    TianGan.JI: DiZhi.ZI,
    TianGan.GENG: DiZhi.CHOU,
    TianGan.XIN: DiZhi.YIN,
    TianGan.REN: DiZhi.MAO,
    TianGan.GUI: DiZhi.SI,
  };

  // 甲羊戊庚牛
  static Map<TianGan, DiZhi> version3NightGod = {
    TianGan.JIA: DiZhi.CHOU,
    TianGan.YI: DiZhi.ZI,
    TianGan.BING: DiZhi.HAI,
    TianGan.DING: DiZhi.YOU,
    TianGan.WU: DiZhi.WEI,
    TianGan.JI: DiZhi.SHEN,
    TianGan.GENG: DiZhi.WEI,
    TianGan.XIN: DiZhi.WU,
    TianGan.REN: DiZhi.SI,
    TianGan.GUI: DiZhi.MAO,
  };

  static DiZhi calculate(TianGan stem, EnumDayNight dayNight, GuiRenType type) {
    switch (type) {
      case GuiRenType.Jia_Wu_Geng_Niu_Yang:
        return dayNight.isDay ? version1DayGod[stem]! : version1NightGod[stem]!;
      case GuiRenType.Jia_Wu_Jian_Niu_Yang:
        return dayNight.isDay ? version2DayGod[stem]! : version2NightGod[stem]!;
      case GuiRenType.Jia_Yang_Wu_Geng_Niu:
        return dayNight.isDay ? version3DayGod[stem]! : version3NightGod[stem]!;
      default:
        throw ArgumentError("版本号必须是1、2或3");
    }
  }
}
