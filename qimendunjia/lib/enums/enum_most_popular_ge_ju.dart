import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_san_zha_wu_jia.dart';
import 'package:qimendunjia/enums/enum_six_jia.dart';
import 'package:qimendunjia/enums/nine_dun.dart';
import 'package:qimendunjia/model/each_gong.dart';

import '../model/each_gong_ge_ju.dart';
import 'enum_eight_gods.dart';

enum EnumMostPopularGeJu {
  Wu_Bu_Yu_Shi("五不遇时", JiXiongEnum.DA_XIONG),
  Tian_Fu_Ji_Shi("天辅吉时", JiXiongEnum.DA_JI),
  Tian_Xian_Shi_Ge("天显时格", JiXiongEnum.JI),

  Jiu_Dun("九遁", JiXiongEnum.DA_JI),
  San_Zha_Wu_Jia("三诈五假", JiXiongEnum.JI),

  San_Qi_De_Shi("三奇得使", JiXiongEnum.JI),
  Huan_Yi("欢怡", JiXiongEnum.JI),
  Qi_Yi_Xiang_He("奇仪相合", JiXiongEnum.DA_JI),
  // Men_Gong_He_Yi("门宫和义",JiXiongEnum.JI),
  Jiao_Tai("交泰", JiXiongEnum.DA_JI),
  Xiang_Zuo("相佐", JiXiongEnum.DA_JI),
  Tian_Yun_Chang_Qi("天运昌气", JiXiongEnum.DA_JI),
  Yu_Nv_Shou_Men("玉女守门", JiXiongEnum.JI),
  San_Qi_Sheng_Dian("三奇升殿", JiXiongEnum.JI),
  San_Qi_Zhi_Ling("三奇之灵", JiXiongEnum.JI),
  Qi_You_Lu_Wei("奇游禄位", JiXiongEnum.DA_JI),

  San_Qi_Ru_Mu("三奇入墓", JiXiongEnum.PING),
  San_Qi_Shou_Xing("三奇受刑", JiXiongEnum.XIONG),
  Shi_Gan_Ru_Mu("时干入墓", JiXiongEnum.XIONG),

  Six_Yi_Ji_Xiong("六仪击刑", JiXiongEnum.DA_XIONG),
  Fu_Yin("伏吟", JiXiongEnum.XIONG),
  Fan_Yin("反吟", JiXiongEnum.XIONG),

  Qing_Long_Fan_Shou("青龙返首", JiXiongEnum.DA_JI),
  Fei_Niao_Die_Xue("飞鸟跌穴", JiXiongEnum.DA_JI),

  Teng_She_Yao_Jiao("腾蛇妖娇", JiXiongEnum.DA_XIONG),
  Zhu_Que_Tou_Jiang("朱雀投江", JiXiongEnum.DA_XIONG),
  Bai_Hu_Chang_Kuang("白虎猖狂", JiXiongEnum.DA_XIONG),
  Qing_Long_Tao_Zou("青龙逃走", JiXiongEnum.DA_XIONG),
  Tai_Bai_Ru_Ying("太白入荧", JiXiongEnum.DA_XIONG),
  Ying_Ru_Tai_Bai("荧入太白", JiXiongEnum.DA_XIONG),
  Tian_Wang_Si_Zhang("天网四张", JiXiongEnum.DA_XIONG);
  // 天网四张指癸加癸的凶格。六癸属阴，是十干气尽之时。犯之者，如入网中，幽暗难出。网有高低之分，看所用之时加诸六癸在何宫。若在坎一宫则高一尺，在坤二宫则高两尺，随宫而言高下。一二三四五宫尺寸低，六七八九宫尺寸高。
  // 天网一二尺者，遇之可跨而出，倘高在三尺以上，则不可逃离，此时可以偃旗息鼓，弃甲衔枚匍匐前行而逃脱，不可急行军。
  // 军事行动中，吾军陷入敌军包围，或从天门而出，或从玉女而去，或从三奇方去斩敌。见了血光，则臂横刀刃，呼天辅之神号，扬旗擂鼓，举喊震声，并力突出而网破矣。
  // 若敌人来追，则敌身陷投网内，可回军奋击，后军必慌忙失措，破阵丧师，或敌人入吾所布之网，敌人作法而奔我军，慎不可追敌，追则我军反投入网中矣。故诀云：“天网四张，万物尽伤，高用匍匐，低用声扬也。”
  // 总之，天网四张不利于合作做事，不利于成群结伴。如果是自己单独行动或独立做事则没有关系，反而有利，可以乘其不备。
  // 但是看命局的话，“高网任东西”为贵格（六七八九宫为网高，其余为网低，不管阴阳遁），合局者化为华盖，可为上流社会富贵人物；低网为凶；又逢失局则天网缠身，寂寂孤贫，下等贫民。 作者：奇门乾柱 https://www.bilibili.com/read/cv9940171/ 出处：bilibili

  final String name;
  final JiXiongEnum jiXiong;
  const EnumMostPopularGeJu(this.name, this.jiXiong);

  /// TODO 当前没有添加 与十干克应相关的 格局 如“天网四张”、“飞鸟跌穴”
  static EachGongGeJu checkGeJuAtEachGong(
      JiaZi timeJiaZi, SixJia sixJia, EightDoorEnum zhiShiDoor, EachGong gong) {
    TianGan timeGan = timeJiaZi.gan;
    if (timeGan == TianGan.JIA) {
      timeGan = SixJia.getSixJiaByJiaZi(timeJiaZi).gan;
    }

    List<EnumMostPopularGeJu> tianDiPanGeJuList = [];
    List<EnumMostPopularGeJu>? tianPanJiGanWithDiPanList;
    List<EnumMostPopularGeJu>? tianPanWithDiPanJiGanList;
    List<EnumMostPopularGeJu>? tianDiJiGanList;

    // 1. 处理 天地盘 间的克应
    tianDiPanGeJuList = checkByTianDiPan(sixJia, zhiShiDoor, gong.tianPan,
        gong.diPan, gong.gongGua, gong.door, gong.god);
    if (timeGan == gong.tianPan || timeGan == gong.diPan) {
      var isIt = isShiGanRuMu(timeGan, gong.gongGua);
      if (isIt != null) {
        tianDiPanGeJuList.add(isIt);
      }
      var isJiXing = isSixYiJiXing(gong.tianPan, gong.gongGua);
      if (isJiXing != null) {
        tianDiPanGeJuList.add(isJiXing);
      }
      isJiXing = isSixYiJiXing(gong.tianPan, gong.gongGua);
      if (isJiXing != null && !tianDiPanGeJuList.contains(Six_Yi_Ji_Xiong)) {
        tianDiPanGeJuList.add(isJiXing);
      }
    }
    NineDunEnum? tianDiPanNineDun = NineDunEnum.checkAndGetNineDun(
        sixJia, gong.tianPan, gong.diPan, gong.god, gong.door, gong.gongGua);
    SanZhaWuJiaEnum? tianDiPanZhaJia =
        SanZhaWuJiaEnum.checkSanZhaWuJia(gong.tianPan, gong.door, gong.god);
    NineDunEnum? tianPanJiNineDun;
    SanZhaWuJiaEnum? tianPanJiDiPan;
    // 2. 如果天盘有寄干，处理 天盘寄干 与 地盘干的关系
    if (gong.tianPanJiGan != null) {
      tianPanJiNineDun = NineDunEnum.checkAndGetNineDun(sixJia,
          gong.tianPanJiGan!, gong.diPan, gong.god, gong.door, gong.gongGua);
      tianPanJiDiPan = SanZhaWuJiaEnum.checkSanZhaWuJia(
          gong.tianPanJiGan!, gong.door, gong.god);
      tianPanJiGanWithDiPanList = checkByTianDiPan(sixJia, zhiShiDoor,
          gong.tianPanJiGan!, gong.diPan, gong.gongGua, gong.door, gong.god);
      if (timeGan == gong.tianPanJiGan) {
        var isIt = isShiGanRuMu(timeGan, gong.gongGua);
        if (isIt != null) {
          tianPanJiGanWithDiPanList.add(isIt);
        }
      }
      var isJiXing = isSixYiJiXing(gong.tianPanJiGan!, gong.gongGua);
      if (isJiXing != null && !tianDiPanGeJuList.contains(Six_Yi_Ji_Xiong)) {
        tianPanJiGanWithDiPanList.add(isJiXing);
      }
    }

    // 3. 如果地盘有寄干，处理 地盘寄干 与 天盘干的关系

    NineDunEnum? tianPanDiPanJiNineDun;
    if (gong.diPanJiGan != null) {
      tianPanDiPanJiNineDun = NineDunEnum.checkAndGetNineDun(sixJia,
          gong.tianPan, gong.diPanJiGan!, gong.god, gong.door, gong.gongGua);

      tianPanWithDiPanJiGanList = checkByTianDiPan(sixJia, zhiShiDoor,
          gong.tianPan, gong.diPanJiGan!, gong.gongGua, gong.door, gong.god);

      if (timeGan == gong.diPanJiGan) {
        var isIt = isShiGanRuMu(timeGan, gong.gongGua);
        if (isIt != null) {
          tianPanWithDiPanJiGanList.add(isIt);
        }
      }
      var isJiXing = isSixYiJiXing(gong.diPanJiGan!, gong.gongGua);
      if (isJiXing != null && !tianDiPanGeJuList.contains(Six_Yi_Ji_Xiong)) {
        tianPanWithDiPanJiGanList.add(isJiXing);
      }
    }
    // 4. 如果天、地盘 同时有寄干，还需要处理这两者
    if (gong.tianPanJiGan != null && gong.diPanJiGan != null) {
      tianDiJiGanList = checkByTianDiPan(sixJia, zhiShiDoor, gong.tianPanJiGan!,
          gong.diPanJiGan!, gong.gongGua, gong.door, gong.god);
    }

    return EachGongGeJu(
        tianDiPanGeJuList: tianDiPanGeJuList,
        tianPanJiGanWithDiPanList: tianPanJiGanWithDiPanList,
        tianPanWithDiPanJiGanList: tianPanWithDiPanJiGanList,
        tianDiJiGanList: tianDiJiGanList,
        tianDiPanNineDun: tianDiPanNineDun,
        tianDiPanZhaJia: tianDiPanZhaJia,
        tianJiDiPanNineDun: tianPanJiNineDun,
        tianJiDiPanZhaJia: tianDiPanZhaJia,
        tianDiJiPanNineDun: tianPanDiPanJiNineDun);
  }

  static List<EnumMostPopularGeJu> checkByTianDiPan(
      SixJia sixJia,
      EightDoorEnum zhiShiDoor,
      TianGan tianPan,
      TianGan diPan,
      HouTianGua gongGua,
      EightDoorEnum door,
      EightGodsEnum god) {
    Set<EnumMostPopularGeJu?> result = {};
    TianGan sixJiaGan = sixJia.gan;
    result.add(isQiYiHe(sixJiaGan, tianPan, diPan));
    result.add(isSanQiDeShi(sixJiaGan, zhiShiDoor, tianPan, diPan, door));
    result.add(isHuanYi(sixJiaGan, tianPan, diPan));
    result.add(isQiYiHe(sixJiaGan, tianPan, diPan));
    result.add(isXiangZuo(sixJiaGan, tianPan, diPan));
    result.add(isJiaoTai(tianPan, diPan, door));

    result.add(isTianYunChangQi(tianPan, diPan));
    result.add(isYuNvShouMen(zhiShiDoor, diPan, door));
    result.add(isSanQiZhiLing(tianPan, diPan, door, god));
    result.add(isQiYouLuWei(tianPan, gongGua));

    result.add(isSanQiShengDian(tianPan, diPan, gongGua));
    result.add(isSanQiRuMu(tianPan, diPan, gongGua));
    result.add(isSanQiShouXing(tianPan, diPan, gongGua));

    result.removeWhere((e) => e == null);
    return result.map((e) => e!).toList();

    // Shi_Gan_Ru_Mu("时干入墓",JiXiongEnum.XIONG),
    // result.add(isShiGanRuMu(gong));

    // Tian_Xian_Shi_Ge("天显时格",JiXiongEnum.JI),
  }

  // static List<EnumMostPopularGeJu> checkDayTimeGeJu(){
  // }
  static EnumMostPopularGeJu? isSixYiJiXing(TianGan gan, HouTianGua gongGua) {
    // 甲子戊 在 震
    // 甲戌己 在 坤
    // 甲申庚 在 艮
    // 甲寅癸 在 巽
    // 甲辰壬 在 巽
    // 甲午辛 在 离
    switch (gan) {
      case TianGan.WU:
        return gongGua == HouTianGua.Zhen ? Six_Yi_Ji_Xiong : null;
      case TianGan.JI:
        return gongGua == HouTianGua.Kun ? Six_Yi_Ji_Xiong : null;
      case TianGan.GENG:
        return gongGua == HouTianGua.Gen ? Six_Yi_Ji_Xiong : null;
      case TianGan.XIN:
        return gongGua == HouTianGua.Li ? Six_Yi_Ji_Xiong : null;
      case TianGan.REN:
      case TianGan.GUI:
        return gongGua == HouTianGua.Xun ? Six_Yi_Ji_Xiong : null;
      default:
        return null;
    }
  }

  // 奇仪相合
  static EnumMostPopularGeJu? isQiYiHe(
      TianGan zhiFuGan, TianGan tianPan, TianGan diPan) {
    bool itIs = false;
    if ([tianPan, diPan].contains(zhiFuGan)) {
      itIs = TianGanFiveCombine.isCombine(tianPan, diPan);
    }
    if (zhiFuGan == tianPan) {
      itIs = diPan == TianGan.JI;
    }
    if (zhiFuGan == diPan) {
      itIs = tianPan == TianGan.JI;
    }
    return itIs ? Qi_Yi_Xiang_He : null;
  }

  // 三奇得使
  static EnumMostPopularGeJu? isSanQiDeShi(
      TianGan zhiFuGan,
      EightDoorEnum zhiShiDoor,
      TianGan tianPan,
      TianGan diPan,
      EightDoorEnum door) {
    bool itIs = false;
    if (door == zhiShiDoor) {
      if (zhiFuGan == diPan) {
        itIs = [TianGan.YI, TianGan.BING, TianGan.DING].contains(tianPan);
      }
    }
    return itIs ? San_Qi_De_Shi : null;
  }

  static EnumMostPopularGeJu? isTianFuJiShi(JiaZi dayJiaZi, JiaZi timeJiaZi) {
    bool itIs = false;
    switch (dayJiaZi.tianGan) {
      case TianGan.JIA:
      case TianGan.JI:
        itIs = timeJiaZi == JiaZi.JI_SI;
      case TianGan.YI:
      case TianGan.GENG:
        itIs = timeJiaZi == JiaZi.JIA_SHEN;
      case TianGan.BING:
      case TianGan.XIN:
        itIs = timeJiaZi == JiaZi.JIA_WU;
      case TianGan.DING:
      case TianGan.REN:
        itIs = timeJiaZi == JiaZi.JIA_CHEN;
      case TianGan.WU:
      case TianGan.GUI:
        itIs = timeJiaZi == JiaZi.JIA_YIN;
      default:
        {}
    }

    return itIs ? EnumMostPopularGeJu.Tian_Fu_Ji_Shi : null;
  }

  static EnumMostPopularGeJu? isTianYunChangQi(TianGan tianPan, TianGan diPan) {
    bool itIs = false;
    if (tianPan == TianGan.DING && diPan == TianGan.YI) {
      itIs = true;
    }
    return itIs ? EnumMostPopularGeJu.Tian_Yun_Chang_Qi : null;
  }

  static EnumMostPopularGeJu? isXiangZuo(
      TianGan zhiFuGan, TianGan tianPan, TianGan diPan) {
    bool itIs = false;
    if (zhiFuGan == tianPan) {
      itIs = [TianGan.YI, TianGan.BING, TianGan.DING].contains(diPan);
    }
    // return null;

    return itIs ? EnumMostPopularGeJu.Xiang_Zuo : null;
  }

  static List<EnumMostPopularGeJu>? checkDayTimeGeJu(
      JiaZi dayJiaZi, JiaZi timeJiaZi) {
    List<EnumMostPopularGeJu> result = [];
    EnumMostPopularGeJu? wuBuYuShi = isWuBuYuShi(dayJiaZi, timeJiaZi);
    if (wuBuYuShi != null) {
      result.add(wuBuYuShi);
    }
    EnumMostPopularGeJu? tianFuJiShi = isTianFuJiShi(dayJiaZi, timeJiaZi);
    if (tianFuJiShi != null) {
      result.add(tianFuJiShi);
    }
    EnumMostPopularGeJu? tianXianShiGe = isTianXianShiGe(dayJiaZi, timeJiaZi);
    if (tianXianShiGe != null) {
      result.add(tianXianShiGe);
    }
    EnumMostPopularGeJu? yuNvShouMen = isYuNvShouMenByTimeJiaZi(timeJiaZi);
    if (yuNvShouMen != null) {
      result.add(yuNvShouMen);
    }
    return result.isEmpty ? null : result;
  }

  /// 交泰
  static EnumMostPopularGeJu? isJiaoTai(
      TianGan tianPan, TianGan diPan, EightDoorEnum door) {
    bool itIs = false;
    if ([EightDoorEnum.KAI, EightDoorEnum.XIU, EightDoorEnum.SHENG]
        .contains(door)) {
      itIs = (tianPan == TianGan.YI && diPan == TianGan.DING) ||
          (tianPan == TianGan.DING && diPan == TianGan.YI) ||
          (tianPan == TianGan.DING && diPan == TianGan.BING) ||
          (tianPan == TianGan.BING && diPan == TianGan.DING);
    }
    // return null;

    return itIs ? EnumMostPopularGeJu.Jiao_Tai : null;
  }

  // 欢怡
  static EnumMostPopularGeJu? isHuanYi(
      TianGan zhiFuGan, TianGan tianPan, TianGan diPan) {
    bool itIs = false;
    if (tianPan.isThreeQi) {
      itIs = zhiFuGan == diPan;
    }

    return itIs ? EnumMostPopularGeJu.Huan_Yi : null;
  }

  static EnumMostPopularGeJu? isWuBuYuShi(JiaZi dayJiaZi, JiaZi timeJiaZi) {
    bool itIs = false;
    switch (dayJiaZi.tianGan) {
      case TianGan.JIA:
        itIs = timeJiaZi == JiaZi.GENG_WU;
      case TianGan.YI:
        itIs = timeJiaZi == JiaZi.XIN_SI;
      case TianGan.BING:
        itIs = timeJiaZi == JiaZi.REN_WU;
      case TianGan.DING:
        itIs = timeJiaZi == JiaZi.GUI_MAO;
      case TianGan.WU:
        itIs = timeJiaZi == JiaZi.JIA_YIN;
      case TianGan.JI:
        itIs = timeJiaZi == JiaZi.YI_CHOU;
      case TianGan.GENG:
        itIs = timeJiaZi == JiaZi.BING_ZI;
      case TianGan.XIN:
        itIs = timeJiaZi == JiaZi.DING_YOU;
      case TianGan.REN:
        itIs = timeJiaZi == JiaZi.WU_SHEN;
      case TianGan.GUI:
        itIs = timeJiaZi == JiaZi.JI_WEI;
      default:
        {}
    }
    return itIs ? EnumMostPopularGeJu.Wu_Bu_Yu_Shi : null;
  }

  static EnumMostPopularGeJu? isShiGanRuMu(TianGan gan, HouTianGua gongGua) {
    bool itIs = false;
    switch (gan) {
      case TianGan.YI:
        itIs = [HouTianGua.Qian, HouTianGua.Kun].contains(gongGua);
      case TianGan.BING:
      case TianGan.WU:
        itIs = HouTianGua.Qian == gongGua;
      case TianGan.DING:
      case TianGan.JI:
        itIs = HouTianGua.Gen == gongGua;
      case TianGan.GENG:
      case TianGan.GUI:
        itIs = HouTianGua.Kun == gongGua;
      case TianGan.REN:
        itIs = HouTianGua.Xun == gongGua;
      default:
        {}
    }
    return itIs ? EnumMostPopularGeJu.Shi_Gan_Ru_Mu : null;
  }

  static EnumMostPopularGeJu? isSanQiShouXing(
      TianGan tianPan, TianGan diPan, HouTianGua gongGua) {
    bool itIs = false;
    if ([TianGan.BING, TianGan.DING].contains(tianPan) &&
        ([TianGan.REN, TianGan.GUI].contains(diPan) ||
            HouTianGua.Kan == gongGua)) {
      itIs = true;
    } else if (TianGan.YI == tianPan &&
        ([TianGan.GENG, TianGan.XIN].contains(diPan) ||
            [HouTianGua.Dui, HouTianGua.Qian].contains(gongGua))) {
      itIs = true;
    }

    return itIs ? EnumMostPopularGeJu.San_Qi_Shou_Xing : null;
  }

  // 三奇入墓
  static EnumMostPopularGeJu? isSanQiRuMu(
      TianGan tianPan, TianGan diPan, HouTianGua gongGua) {
    bool itIs = false;
    switch (tianPan) {
      case TianGan.YI:
        itIs = [HouTianGua.Qian, HouTianGua.Kun].contains(gongGua);
      case TianGan.BING:
        itIs = HouTianGua.Qian == gongGua;
      case TianGan.DING:
        itIs = HouTianGua.Gen == gongGua;
      default:
        {}
    }
    return itIs ? EnumMostPopularGeJu.San_Qi_Ru_Mu : null;
  }

  // 天显时格
  static EnumMostPopularGeJu? isTianXianShiGe(JiaZi dayJiaZi, JiaZi timeJiaZi) {
    bool itIs = false;
    TianGan dayTianGan = dayJiaZi.tianGan;
    switch (dayTianGan) {
      case TianGan.JIA:
      case TianGan.JI:
        itIs = [JiaZi.JIA_ZI, JiaZi.JIA_XU].contains(timeJiaZi);
      case TianGan.YI:
      case TianGan.GENG:
        itIs = timeJiaZi == JiaZi.JIA_SHEN;
      case TianGan.BING:
      case TianGan.XIN:
        itIs = timeJiaZi == JiaZi.JIA_WU;
      case TianGan.DING:
      case TianGan.REN:
        itIs = timeJiaZi == JiaZi.JIA_CHEN;
      case TianGan.WU:
      case TianGan.GUI:
        itIs = timeJiaZi == JiaZi.JIA_YIN;
      default:
        {}
    }

    return itIs ? EnumMostPopularGeJu.Tian_Xian_Shi_Ge : null;
  }

  // 三奇贵人升殿
  static EnumMostPopularGeJu? isSanQiShengDian(
      TianGan tianPan, TianGan diPan, HouTianGua gongGua) {
    bool itIs = false;
    switch (tianPan) {
      case TianGan.YI:
        itIs = gongGua == HouTianGua.Zhen;
      case TianGan.BING:
        itIs = gongGua == HouTianGua.Li;
      case TianGan.DING:
        itIs = gongGua == HouTianGua.Dui;
      default:
        {}
    }
    return itIs ? EnumMostPopularGeJu.San_Qi_Sheng_Dian : null;
  }

  // 玉女守门
  static EnumMostPopularGeJu? isYuNvShouMenByTimeJiaZi(JiaZi timeJiaZi) {
    bool itIs = false;
    switch (timeJiaZi.xunHeader) {
      case JiaZi.JIA_ZI:
        itIs = timeJiaZi == JiaZi.GENG_WU;
      case JiaZi.JIA_XU:
        itIs = timeJiaZi == JiaZi.JI_MAO;
      case JiaZi.JIA_SHEN:
        itIs = timeJiaZi == JiaZi.WU_ZI;
      case JiaZi.JIA_WU:
        itIs = timeJiaZi == JiaZi.DING_YOU;
      case JiaZi.JIA_CHEN:
        itIs = timeJiaZi == JiaZi.BING_WU;
      case JiaZi.JIA_YIN:
        itIs = timeJiaZi == JiaZi.YI_MAO;
      default:
        {}
    }
    return itIs ? EnumMostPopularGeJu.Yu_Nv_Shou_Men : null;
  }

  // 玉女守门
  static EnumMostPopularGeJu? isYuNvShouMen(
      EightDoorEnum zhiShiDoor, TianGan diPan, EightDoorEnum door) {
    bool itIs = zhiShiDoor == door && diPan == TianGan.DING;

    return itIs ? EnumMostPopularGeJu.Yu_Nv_Shou_Men : null;
  }

  // 三奇之灵
  static EnumMostPopularGeJu? isSanQiZhiLing(
      TianGan tianPan, TianGan diPan, EightDoorEnum door, EightGodsEnum god) {
    bool itIs = [TianGan.YI, TianGan.BING, TianGan.DING].contains(tianPan) &&
        [EightDoorEnum.KAI, EightDoorEnum.XIU, EightDoorEnum.SHENG]
            .contains(door) &&
        [
          EightGodsEnum.TAI_YIN,
          EightGodsEnum.LIU_HE,
          EightGodsEnum.JIU_DI,
          EightGodsEnum.JIU_TIAN
        ].contains(god);
    return itIs ? EnumMostPopularGeJu.San_Qi_Zhi_Ling : null;
  }

  // 奇游禄位
  static EnumMostPopularGeJu? isQiYouLuWei(
      TianGan tianPan, HouTianGua gongGua) {
    bool itIs = false;
    switch (tianPan) {
      case TianGan.YI:
        itIs = gongGua == HouTianGua.Zhen;
      case TianGan.BING:
        itIs = gongGua == HouTianGua.Xun;
      case TianGan.DING:
        itIs = gongGua == HouTianGua.Li;
      default:
        {}
    }
    return itIs ? EnumMostPopularGeJu.Qi_You_Lu_Wei : null;
  }

  // 六庚
  // static EnumMostPopularGeJu? isSixGengGe(TianGan xunShouGan,EachGong gong){
  //
  // EnumMostPopularGeJu? inner_fun(TianGan diPan){
  //   switch (gong.diPan) {
  //     case TianGan.REN:
  //       return Xiao_Ge;
  //     case TianGan.GUI:
  //       return Da_Ge;
  //     case TianGan.JI:
  //       return Xing_Ge;
  //     case TianGan.YI:
  //     case TianGan.BING:
  //     case TianGan.DING:
  //       return Qi_Ge;
  //     case TianGan.WU:
  //       return Tian_Yi_Fu_Gong;
  //     default:
  //       return null;
  //     }
  //   }
  //
  //   if (![gong.tianPan,gong.diPan,].contains(gong)){
  //     return null;
  //   }
  //   List<EnumMostPopularGeJu> _list = [];
  // if (xunShouGan == TianGan.GENG){
  //   return Shi_Gan_Ge;
  // }
  //   if (gong.tianPan == TianGan.GENG){
  //     if (gong.diPan == xunShouGan){
  //       _list.add(Shi_Gan_Ge);
  //     }
  //     var res = inner_fun(gong.diPan);
  //     if (res != null){
  //       _list.add(res);
  //     }
  //     if (gong.diPanJiGan != null) {
  //       res = inner_fun(gong.diPanJiGan!);
  //       if (res != null) {
  //         _list.add(res);
  //       }
  //     }
  //   }
  //
  // Da_Ge("庚格·大格",JiXiongEnum.DA_XIONG), // 天盘六庚，地盘六癸
  // Xiao_Ge("庚格·小格",JiXiongEnum.DA_XIONG), // 天盘六庚，地盘六壬， 也叫“上格”或“伏格”
  // Xing_Ge("庚格·刑格",JiXiongEnum.DA_XIONG), // 天盘六庚，地盘六己
  // Qi_Ge("庚格·奇格",JiXiongEnum.DA_XIONG), // 天盘六庚，地盘乙丙丁，
  // // 其中庚加丙丁，遇景门、天英星，为下克上，用兵先举者败，所以出兵无回道之期，用则有失。庚加丙利客，主进，应积极进取；
  // // 丙加庚利主，主退，应防守或放弃。
  // // 若庚加乙奇，遇伤杜两门、天冲天辅，微上克下，用兵先举者胜，所向无敌。
  // Shi_Gan_Ge("庚格·时干格",JiXiongEnum.XIONG), // 凡六庚为值符，十时皆为“时干格”
  //
  //
  //
  //   Fei_Gong_Ge("庚格·飞宫格",JiXiongEnum.DA_XIONG), // 天盘值符，地盘六庚
  //   Fu_Gong_Ge("庚格·伏宫格",JiXiongEnum.DA_XIONG), // 天盘六庚，地盘值符
  //   Sui_Ge("庚格·岁格",JiXiongEnum.DA_XIONG),
  //   Yue_Ge("庚格·月格",JiXiongEnum.DA_XIONG),
  //   Fu_Gan_Ge("庚格·伏干格",JiXiongEnum.DA_XIONG), // 天盘六庚，地盘日干
  //   Fei_Gan_Ge("庚格·飞干戈",JiXiongEnum.DA_XIONG), // 天盘日干，地盘六庚
  //   Shi_Ge("庚格·时格",JiXiongEnum.DA_XIONG),
  //
  //
  // }
}
