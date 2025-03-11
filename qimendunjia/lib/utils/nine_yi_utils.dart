import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_most_popular_ge_ju.dart';

import '../enums/enum_nine_stars.dart';

class NineYiUtils {
  static bool isDoorRuMu(EightDoorEnum door, HouTianGua gong) {
    switch (door) {
      case EightDoorEnum.XIU:
      case EightDoorEnum.SHENG:
      case EightDoorEnum.SI:
        return HouTianGua.Xun == gong;
      case EightDoorEnum.SHENG:
      case EightDoorEnum.DU:
        return HouTianGua.Kun == gong;
      case EightDoorEnum.JING_S:
        return HouTianGua.Qian == gong;
      case EightDoorEnum.JING_W:
      case EightDoorEnum.KAI:
        return HouTianGua.Gen == gong;
      default:
        return false;
    }
  }

  // 是否为六仪击刑
  static bool isLiuYiJiXing(TianGan qi, HouTianGua gong) {
    return EnumMostPopularGeJu.isSixYiJiXing(qi, gong) != null;
  }

  /// null 为不是墓也不是库
  /// true 为墓
  /// false 为库
  static bool? checkMuOrKu(MonthToken month, TianGan gan, HouTianGua gong) {
    // 乙在 寅卯 落乾宫为库
    if (gan == TianGan.YI && HouTianGua.Qian == gong) {
      return ![MonthToken.YIN, MonthToken.MAO].contains(month);
    }
    if (gan == TianGan.YI && HouTianGua.Kun == gong) {
      return true;
    }
    if (gan == TianGan.BING && HouTianGua.Qian == gong) {
      return ![MonthToken.YIN, MonthToken.MAO, MonthToken.SI, MonthToken.WU]
          .contains(month);
    }
    if (gan == TianGan.BING && HouTianGua.Gen == gong) {
      return ![MonthToken.YIN, MonthToken.MAO, MonthToken.SI, MonthToken.WU]
          .contains(month);
    }
    if (gan == TianGan.WU && HouTianGua.Qian == gong) {
      return ![MonthToken.CHEN, MonthToken.XU, MonthToken.CHOU, MonthToken.WEI]
          .contains(month);
    }
    if (gan == TianGan.JI && HouTianGua.Gen == gong) {
      return ![MonthToken.CHEN, MonthToken.XU, MonthToken.CHOU, MonthToken.WEI]
          .contains(month);
    }

    if (gan == TianGan.GENG && HouTianGua.Gen == gong) {
      return ![
        MonthToken.SHEN,
        MonthToken.YOU,
        MonthToken.CHEN,
        MonthToken.XU,
        MonthToken.CHOU,
        MonthToken.WEI
      ].contains(month);
    }
    if (gan == TianGan.XIN && HouTianGua.Xun == gong) {
      return ![
        MonthToken.SHEN,
        MonthToken.YOU,
        MonthToken.CHEN,
        MonthToken.XU,
        MonthToken.CHOU,
        MonthToken.WEI
      ].contains(month);
    }

    if (gan == TianGan.REN && HouTianGua.Xun == gong) {
      return ![MonthToken.SHEN, MonthToken.YOU, MonthToken.HAI, MonthToken.ZI]
          .contains(month);
    }

    if (gan == TianGan.GUI && HouTianGua.Kun == gong) {
      return ![MonthToken.SHEN, MonthToken.YOU, MonthToken.HAI, MonthToken.ZI]
          .contains(month);
    }
    return null;
  }

  static TwelveZhangSheng qiYiZhangSheng(JiaZi shiJiaZi, TianGan qi,
      HouTianGua gong, YinYang yinYangDun, GanGongTypeEnum type) {
    if (gong.isZheng) {
      // 四正宫 坎离震兑
      return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, gong.diZhi1);
    } else {
      // 四余宫 艮巽乾坤

      List<DiZhi> diZhiList = [gong.diZhi1, gong.diZhi2!];

      // 遇旺则旺，遇墓则墓
      if (type == GanGongTypeEnum.SHI_GAN_YIN_YANG) {
        return checkFourWeiGongWangShuaiByShiZhi(
            shiJiaZi, qi, diZhiList.toSet());
      } else if (type == GanGongTypeEnum.YIN_YANG_DUN) {
        return checkWithYinYangDun(qi, gong, yinYangDun);
      } else {
        return checkFourWeiGongWangShuaiByTraditional(
            diZhiList.toSet(),
            diZhiList
                .map((e) => TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, e))
                .toList());
      }
      // 十干阴阳 定旺衰
      // checkFourWeiGongWangShuaiByShiZhi（）

      // // 1. 有墓时先论墓
      // if (_tmpList.contains(TwelveZhangSheng.MU)){
      //   return TwelveZhangSheng.MU;
      // }
      // else if (_tmpList.contains(TwelveZhangSheng.DI_WANG)){
      //   // 2.有帝旺论帝旺
      //   return TwelveZhangSheng.DI_WANG;
      // }
      // else if (_tmpList.contains(TwelveZhangSheng.MU_YU)){
      //   // 3. 有沐浴论沐浴
      //   return TwelveZhangSheng.MU_YU;
      // }
      // else if (_tmpList.contains(TwelveZhangSheng.LIN_GUAN)){
      //   // 4. 有临官论临官
      //   return TwelveZhangSheng.LIN_GUAN;
      // }
      // else if (_tmpList.contains(TwelveZhangSheng.BING)){
      //   // 5. 有病论病
      //   return TwelveZhangSheng.BING;
      // }
      // else if (_tmpList.contains(TwelveZhangSheng.ZHANG_SHEN)){
      //   // 6. 有长生论长生
      //   return TwelveZhangSheng.ZHANG_SHEN;
      // }
      // else if (_tmpList.contains(TwelveZhangSheng.TAI)){
      //   // 7.有胎论胎
      //   return TwelveZhangSheng.TAI;
      // }
    }
    return TwelveZhangSheng.SI;
  }

  static TwelveZhangSheng checkWithGong(TianGan qi, HouTianGua gong) {
    if (gong.isZheng) {
      // 四正宫 坎离震兑
      return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, gong.diZhi1);
    } else {
      // 四余宫 艮巽乾坤

      List<DiZhi> diZhiList = [gong.diZhi1, gong.diZhi2!];
      // 以下存疑：
      // 先看九仪的五行属性，并看四余中是否有对应五行的“墓库”如果有墓库则按墓库论
      // 如 乙木，坤宫中未土为木之"墓库" 所以，乙木在坤宫中，九仪为墓
      // if (qi.fiveXing == FiveXing.MU && _diZhiList.contains(DiZhi.WEI)){
      //   return TwelveZhangSheng.MU;
      // }else if (qi.fiveXing == FiveXing.HUO && _diZhiList.contains(DiZhi.XU)){
      //   return TwelveZhangSheng.MU;
      // }else if (qi.fiveXing == FiveXing.SHUI && _diZhiList.contains(DiZhi.CHEN)){
      //   return TwelveZhangSheng.MU;
      // }else if (qi.fiveXing == FiveXing.JIN && _diZhiList.contains(DiZhi.CHOU)){
      //   return TwelveZhangSheng.MU;
      // }

      List<TwelveZhangSheng> tmpList = diZhiList
          .map((e) => TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, e))
          .toList();

      // 遇旺则旺，遇墓则墓
      checkFourWeiGongWangShuaiByTraditional(diZhiList.toSet(), tmpList);
      // 十干阴阳 定旺衰
      // checkFourWeiGongWangShuaiByShiZhi（）

      // // 1. 有墓时先论墓
      // if (_tmpList.contains(TwelveZhangSheng.MU)){
      //   return TwelveZhangSheng.MU;
      // }
      // else if (_tmpList.contains(TwelveZhangSheng.DI_WANG)){
      //   // 2.有帝旺论帝旺
      //   return TwelveZhangSheng.DI_WANG;
      // }
      // else if (_tmpList.contains(TwelveZhangSheng.MU_YU)){
      //   // 3. 有沐浴论沐浴
      //   return TwelveZhangSheng.MU_YU;
      // }
      // else if (_tmpList.contains(TwelveZhangSheng.LIN_GUAN)){
      //   // 4. 有临官论临官
      //   return TwelveZhangSheng.LIN_GUAN;
      // }
      // else if (_tmpList.contains(TwelveZhangSheng.BING)){
      //   // 5. 有病论病
      //   return TwelveZhangSheng.BING;
      // }
      // else if (_tmpList.contains(TwelveZhangSheng.ZHANG_SHEN)){
      //   // 6. 有长生论长生
      //   return TwelveZhangSheng.ZHANG_SHEN;
      // }
      // else if (_tmpList.contains(TwelveZhangSheng.TAI)){
      //   // 7.有胎论胎
      //   return TwelveZhangSheng.TAI;
      // }
    }
    return TwelveZhangSheng.SI;
  }

  // 主事地支，分阴阳遁 以及 阴阳宫，如：
  // 1.阳遁时：
  //    a. 阳宫，艮宫主事为“寅”，巽宫主事为“巳”
  //    b. 阴宫，坤宫主事为“未”，乾宫主事为“戌”
  // 2.阴遁时：正与阳遁相反
  //    a. 阳宫，艮宫主事为“丑”，巽宫主事为“辰”
  //    b. 阴宫，坤宫主事为“申”，乾宫主事为“亥”
  static TwelveZhangSheng checkWithYinYangDun(
      TianGan qi, HouTianGua gong, YinYang yinYangDun) {
    if (yinYangDun.isYang) {
      if (gong == HouTianGua.Gen) {
        return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, DiZhi.YIN);
      } else if (gong == HouTianGua.Xun) {
        return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, DiZhi.SI);
      } else if (gong == HouTianGua.Kun) {
        return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, DiZhi.WEI);
      } else if (gong == HouTianGua.Qian) {
        return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, DiZhi.XU);
      }
    } else {
      if (gong == HouTianGua.Gen) {
        return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, DiZhi.CHOU);
      } else if (gong == HouTianGua.Xun) {
        return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, DiZhi.CHEN);
      } else if (gong == HouTianGua.Kun) {
        return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, DiZhi.SHEN);
      } else if (gong == HouTianGua.Qian) {
        return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, DiZhi.HAI);
      }
    }
    return TwelveZhangSheng.SI;
  }

  ///  必须确保 gong 为 四维卦 也就是 乾坤艮巽
  static TwelveZhangSheng checkWithSpecificalQi(TianGan qi, HouTianGua gong) {
    if ({HouTianGua.Qian, HouTianGua.Kun, HouTianGua.Gen, HouTianGua.Xun}
        .contains(gong)) {
      throw ArgumentError("checkWithSpecificalQi only for 四维宫");
    }
    if (qi == TianGan.YI && {HouTianGua.Kun, HouTianGua.Qian}.contains(gong)) {
      // 乙奇在坤二宫 地支未 入墓（当测怀孕时，坤二为胎或是养）
      // 代表木的甲被遁去，所以由乙代替在乾宫入墓
      return TwelveZhangSheng.MU;
    } else if (qi == TianGan.BING && HouTianGua.Qian == gong) {
      // 丙火代表火，在乾宫入墓
      return TwelveZhangSheng.MU;
    } else if (qi == TianGan.DING && HouTianGua.Gen == gong) {
      // 丁火只在艮宫入墓
      return TwelveZhangSheng.MU;
    } else if (qi == TianGan.WU && HouTianGua.Qian == gong) {
      // 戊土代表土，在乾六 入墓
      return TwelveZhangSheng.MU;
    } else if (qi == TianGan.JI && HouTianGua.Gen == gong) {
      // 己土只在艮宫入墓
      return TwelveZhangSheng.MU;
    } else if (qi == TianGan.GENG && HouTianGua.Gen == gong) {
      // 庚代表金 在艮八 入墓
      return TwelveZhangSheng.MU;
    } else if (qi == TianGan.XIN && HouTianGua.Xun == gong) {
      // 辛只在巽宫 入墓
      return TwelveZhangSheng.MU;
    } else if (qi == TianGan.REN && HouTianGua.Xun == gong) {
      // 壬代表水，在巽四入墓
      return TwelveZhangSheng.MU;
    } else if (qi == TianGan.GUI && HouTianGua.Kun == gong) {
      // 癸只在丑 入墓
      return TwelveZhangSheng.MU;
    } else {
      return TwelveZhangSheng.SI;
    }
  }

  /// 四维宫旺衰判断一 遇旺以旺为主，遇墓以墓为主
  static TwelveZhangSheng checkFourWeiGongWangShuaiByTraditional(
      Set<DiZhi> diZhiList, List<TwelveZhangSheng> zhangShengList) {
    // 1. 有墓时先论墓
    if (diZhiList.containsAll({TwelveZhangSheng.SI, TwelveZhangSheng.MU})) {
      return TwelveZhangSheng.MU;
    } else if (diZhiList
        .containsAll({TwelveZhangSheng.GUAN_DAI, TwelveZhangSheng.LIN_GUAN})) {
      // 2.有帝旺论帝旺
      return TwelveZhangSheng.DI_WANG;
    } else if (diZhiList
        .containsAll({TwelveZhangSheng.MU_YU, TwelveZhangSheng.GUAN_DAI})) {
      // 3. 有沐浴论沐浴
      return TwelveZhangSheng.MU_YU;
    } else if (diZhiList
        .containsAll({TwelveZhangSheng.MU_YU, TwelveZhangSheng.LIN_GUAN})) {
      // 4. 有临官论临官
      return TwelveZhangSheng.LIN_GUAN;
    } else if (diZhiList
        .containsAll({TwelveZhangSheng.BING, TwelveZhangSheng.SHUAI})) {
      // 5. 有病论病
      return TwelveZhangSheng.BING;
    } else if (diZhiList
        .containsAll({TwelveZhangSheng.ZHANG_SHEN, TwelveZhangSheng.YANG})) {
      // 6. 有长生论长生
      return TwelveZhangSheng.ZHANG_SHEN;
    } else if (diZhiList
        .containsAll({TwelveZhangSheng.TAI, TwelveZhangSheng.YANG})) {
      // 7.有胎论胎
      return TwelveZhangSheng.TAI;
    }
    return TwelveZhangSheng.SI;
  }

  /// 四维宫旺衰判断二 时干为阳只论奇仪在阳支的状态；时干为阴时，只论阴支的状态
  static TwelveZhangSheng checkFourWeiGongWangShuaiByShiZhi(
      JiaZi shiJiaZi, TianGan qiGan, Set<DiZhi> diZhiSet) {
    if (shiJiaZi.tianGan.isYang) {
      DiZhi yangZhi = diZhiSet.firstWhere((d) => d.isYang);
      return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qiGan, yangZhi);
    } else {
      DiZhi yangZhi = diZhiSet.firstWhere((d) => d.isYin);
      return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qiGan, yangZhi);
    }
  }

  static TwelveZhangSheng checkWithMonthToken(TianGan qi, DiZhi token) {
    return TwelveZhangSheng.getZhangShengByTianGanDiZhi(qi, token);
  }
}
