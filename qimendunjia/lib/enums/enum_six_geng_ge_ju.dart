import 'package:common/enums.dart';

import '../model/each_gong.dart';
import '../model/shi_jia_qi_men.dart';
import 'enum_six_jia.dart';

enum EnumSixGengGeJu {
  // 六庚
  Tian_Yi_Fu_Gong("天乙伏宫", JiXiongEnum.XIONG), // 天庚加地戊
  Tian_Yi_Tai_Bai("天乙太白", JiXiongEnum.DA_XIONG), // 庚加庚
  Bai_Hu_Gan_Ge("白虎干格", JiXiongEnum.DA_XIONG), // 庚加庚
  Fei_Gong_Ge("庚格·飞宫格", JiXiongEnum.DA_XIONG), // 天盘值符，地盘六庚

  Fu_Gong_Ge("庚格·伏宫格", JiXiongEnum.DA_XIONG), // 天盘六庚，地盘值符
  Da_Ge("庚格·大格", JiXiongEnum.DA_XIONG), // 天盘六庚，地盘六癸
  Xiao_Ge("庚格·小格", JiXiongEnum.DA_XIONG), // 天盘六庚，地盘六壬， 也叫“上格”或“伏格”
  Xing_Ge("庚格·刑格", JiXiongEnum.DA_XIONG), // 天盘六庚，地盘六己
  Qi_Ge("庚格·奇格", JiXiongEnum.DA_XIONG), // 天盘六庚，地盘乙丙丁，
  // 其中庚加丙丁，遇景门、天英星，为下克上，用兵先举者败，所以出兵无回道之期，用则有失。庚加丙利客，主进，应积极进取；
  // 丙加庚利主，主退，应防守或放弃。
  // 若庚加乙奇，遇伤杜两门、天冲天辅，微上克下，用兵先举者胜，所向无敌。
  Shi_Gan_Ge("庚格·时干格", JiXiongEnum.XIONG), // 凡六庚为值符，十时皆为“时干格"
  Year("庚格·岁格", JiXiongEnum.DA_XIONG),
  Month("庚格·月格", JiXiongEnum.DA_XIONG),
  Fu_Gan_Ge("庚格·伏干格", JiXiongEnum.DA_XIONG), // 天盘六庚，地盘日干
  Fei_Gan_Ge("庚格·飞干格", JiXiongEnum.DA_XIONG), // 天盘日干，地盘六庚
  Time("庚格·时格", JiXiongEnum.DA_XIONG);

  final String name;
  final JiXiongEnum jiXiong;
  const EnumSixGengGeJu(this.name, this.jiXiong);

  static List<EnumSixGengGeJu> checkGengGeForPanel(ShiJiaQiMen pan) {
    TianGan yearGan = pan.yearJiaZi.tianGan == TianGan.JIA
        ? pan.xunHeaderTianGan
        : pan.yearJiaZi.tianGan;
    TianGan monthGan = pan.monthJiaZi.tianGan == TianGan.JIA
        ? pan.xunHeaderTianGan
        : pan.monthJiaZi.tianGan;
    TianGan timeGan = pan.timeJiaZi.tianGan == TianGan.JIA
        ? pan.xunHeaderTianGan
        : pan.timeJiaZi.tianGan;
    TianGan dayGan = pan.dayJiaZi.tianGan == TianGan.JIA
        ? pan.xunHeaderTianGan
        : pan.dayJiaZi.tianGan;

    List<EnumSixGengGeJu> ganAsTianPan(TianGan diPanGan) {
      List<EnumSixGengGeJu> res = [];
      // 天盘为庚, 地盘为其他三奇六仪
      switch (diPanGan) {
        case TianGan.YI:
        case TianGan.BING:
        case TianGan.DING:
          res.add(Qi_Ge);
          break;
        case TianGan.WU:
          res.add(Tian_Yi_Fu_Gong);
          break;
        case TianGan.JI:
          res.add(Xing_Ge);
          break;
        case TianGan.GENG:
          res.add(Tian_Yi_Tai_Bai);
          break;
        case TianGan.XIN:
          res.add(Bai_Hu_Gan_Ge);
          break;
        case TianGan.REN:
          res.add(Xiao_Ge);
          break;
        case TianGan.GUI:
          res.add(Da_Ge);
          break;
        default:
          break;
      }
      // 查看地盘奇仪是否为 年月日时
      if (diPanGan == pan.zhiFuGan) {
        // 天盘六庚 + 地盘值符
        res.add(Fu_Gong_Ge);
      }
      if (diPanGan == yearGan) {
        res.add(Year);
      }
      if (diPanGan == monthGan) {
        res.add(Month);
      }
      if (diPanGan == dayGan) {
        res.add(Fu_Gan_Ge);
      }
      if (diPanGan == timeGan) {
        res.add(Time);
      }
      return res;
    }

    List<EnumSixGengGeJu> ganAsDiPan(TianGan tianPanGan) {
      List<EnumSixGengGeJu> res = [];
      if (tianPanGan == pan.zhiFuGan) {
        res.add(Fei_Gong_Ge);
      }
      if (tianPanGan == dayGan) {
        res.add(Fei_Gan_Ge);
      }
      return res;
    }

    List<EnumSixGengGeJu> finalResults = [];
    if (pan.zhiFuGan == TianGan.GENG) {
      // 凡六庚为值符，十时皆为“时干格"
      finalResults.add(Shi_Gan_Ge);
    }
    for (var entries in pan.gongMapper.entries) {
      EachGong gong = entries.value;
      if (gong.tianPan == TianGan.GENG) {
        finalResults.addAll(ganAsTianPan(gong.diPan));
        // 检查此宫的地盘是否存在 “寄干”
        if (gong.diPanJiGan != null) {
          finalResults.addAll(ganAsTianPan(gong.diPanJiGan!));
        }
      }
      if (gong.tianPanJiGan != null && gong.tianPanJiGan == TianGan.GENG) {
        finalResults.addAll(ganAsTianPan(gong.diPan));

        // 检查此宫的地盘是否存在 “寄干”
        if (gong.diPanJiGan != null) {
          finalResults.addAll(ganAsTianPan(gong.diPanJiGan!));
        }
      }

      if (gong.diPan == TianGan.GENG) {
        finalResults.addAll(ganAsDiPan(gong.tianPan));
        if (gong.tianPanJiGan != null) {
          finalResults.addAll(ganAsDiPan(gong.tianPanJiGan!));
        }
      }
      if (gong.diPanJiGan != null && gong.diPanJiGan == TianGan.GENG) {
        finalResults.addAll(ganAsDiPan(gong.tianPan));
        if (gong.tianPanJiGan != null) {
          finalResults.addAll(ganAsDiPan(gong.tianPanJiGan!));
        }
      }
    }
    return finalResults;
  }

  //岁格
  static EnumSixGengGeJu? isSuiGe(JiaZi yearJiaZi, EachGong gong) {
    if (gong.tianPan != TianGan.GENG) {
      return null;
    }
    TianGan targetDiPanGan = yearJiaZi.tianGan;
    if (yearJiaZi.tianGan == TianGan.JIA) {
      targetDiPanGan = SixJia.getSixJiaByJiaZi(yearJiaZi.xunHeader).gan;
    }
    return gong.diPan == targetDiPanGan ? EnumSixGengGeJu.Year : null;
  }

  // 月格
  static EnumSixGengGeJu? isYueGe(JiaZi monthJiaZi, EachGong gong) {
    if (gong.tianPan != TianGan.GENG) {
      return null;
    }
    TianGan targetDiPanGan = monthJiaZi.tianGan;
    if (monthJiaZi.tianGan == TianGan.JIA) {
      targetDiPanGan = SixJia.getSixJiaByJiaZi(monthJiaZi.xunHeader).gan;
    }
    return gong.diPan == targetDiPanGan ? EnumSixGengGeJu.Month : null;
  }

  // 时格
  static EnumSixGengGeJu? isShiGanGe(JiaZi timeJiaZi, EachGong gong) {
    if (gong.tianPan != TianGan.GENG) {
      return null;
    }
    TianGan targetDiPanGan = timeJiaZi.tianGan;
    if (timeJiaZi.tianGan == TianGan.JIA) {
      targetDiPanGan = SixJia.getSixJiaByJiaZi(timeJiaZi.xunHeader).gan;
    }
    return gong.diPan == targetDiPanGan ? EnumSixGengGeJu.Time : null;
  }

  // 飞干戈
  static EnumSixGengGeJu? isFeiGanGe(JiaZi dayJiaZi, EachGong gong) {
    if (gong.diPan != TianGan.GENG) {
      return null;
    }
    TianGan targetTianPanGan = dayJiaZi.tianGan;
    if (dayJiaZi.tianGan == TianGan.JIA) {
      targetTianPanGan = SixJia.getSixJiaByJiaZi(dayJiaZi.xunHeader).gan;
    }
    return gong.tianPan == targetTianPanGan ? EnumSixGengGeJu.Fei_Gan_Ge : null;
  }

  // 伏干格
  static EnumSixGengGeJu? isFuGanGe(JiaZi dayJiaZi, EachGong gong) {
    if (gong.tianPan != TianGan.GENG) {
      return null;
    }
    TianGan targetDiPanGan = dayJiaZi.tianGan;
    if (dayJiaZi.tianGan == TianGan.JIA) {
      targetDiPanGan = SixJia.getSixJiaByJiaZi(dayJiaZi.xunHeader).gan;
    }

    return gong.diPan == targetDiPanGan ? EnumSixGengGeJu.Fu_Gan_Ge : null;
  }
}
