import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_eight_gods.dart';
import 'package:qimendunjia/enums/enum_six_jia.dart';
import 'package:qimendunjia/model/each_gong.dart';

import '../model/each_gong_ge_ju.dart';

enum NineDunEnum {
  SKY("九遁·天遁"),
  EARTH("九遁·地遁"),
  HUMAN("九遁·人遁"),
  GOD("九遁·神遁"),
  GHOST("九遁·鬼遁"),
  CLOUD("九遁·云遁"),
  WIND("九遁·风遁"),
  LOONG("九遁·龙遁"),
  TIGER("九遁·虎遁");

  final String name;
  const NineDunEnum(this.name);

  // 包含天盘、地盘以及天盘寄干，地盘寄干
  static EachGongNineDun? checkNineDunAtEachGong(
      SixJia xunShou, EachGong gong) {
    // 1. 根据天地盘
    NineDunEnum? tianDiPan = checkAndGetNineDun(
        xunShou, gong.tianPan, gong.diPan, gong.god, gong.door, gong.gongGua);
    NineDunEnum? tianJiGanDiPan;
    if (gong.tianPanJiGan != null) {
      tianJiGanDiPan = checkAndGetNineDun(xunShou, gong.tianPanJiGan!,
          gong.diPan, gong.god, gong.door, gong.gongGua);
    }
    NineDunEnum? tianPanDiPanJiGan;
    if (gong.diPanJiGan != null) {
      tianPanDiPanJiGan = checkAndGetNineDun(xunShou, gong.tianPan,
          gong.diPanJiGan!, gong.god, gong.door, gong.gongGua);
    }
    return EachGongNineDun(
        tianDiPanGeJuList: tianDiPan,
        tianPanJiGanWithDiPan: tianJiGanDiPan,
        tianPanWithDiPanJiGan: tianPanDiPanJiGan);
  }

  static NineDunEnum? checkAndGetNineDun(
      SixJia xunShou,
      TianGan tianPan,
      TianGan diPan,
      EightGodsEnum god,
      EightDoorEnum door,
      HouTianGua gongGua) {
    if (TianGan.YI == tianPan) {
      if (isWind(tianPan, god, door, gongGua)) {
        return WIND;
      }
      if (isCloud(tianPan, diPan, god, door)) {
        return CLOUD;
      }
      if (isLoong(tianPan, diPan, god, door, gongGua)) {
        return LOONG;
      }
      if (isHuman(tianPan, god, door)) {
        return NineDunEnum.HUMAN;
      }
      if (isTiger(xunShou, tianPan, diPan, god, door, gongGua)) {
        return NineDunEnum.TIGER;
      }
      if (isEarth(tianPan, diPan, god, door)) {
        return NineDunEnum.EARTH;
      }

      return null;
    } else if (TianGan.BING == tianPan) {
      if (isSky(tianPan, diPan, god, door)) {
        return NineDunEnum.SKY;
      }
      if (isGod(tianPan, god, door)) {
        return NineDunEnum.GOD;
      }
    } else if (TianGan.DING == tianPan) {
      if (isGhost(tianPan, god, door)) {
        return NineDunEnum.GHOST;
      }
    } else if (TianGan.GENG == tianPan) {
      if (isTiger(xunShou, tianPan, diPan, god, door, gongGua)) {
        return NineDunEnum.TIGER;
      }
    }
    return null;
  }

  static bool isWind(TianGan tianPan, EightGodsEnum god, EightDoorEnum door,
      HouTianGua gongGua) {
    return tianPan == TianGan.YI &&
        gongGua == HouTianGua.Xun &&
        [EightDoorEnum.KAI, EightDoorEnum.XIU, EightDoorEnum.SHENG]
            .contains(door);
  }

  static bool isCloud(
      TianGan tianPan, TianGan diPan, EightGodsEnum god, EightDoorEnum door) {
    return tianPan == TianGan.YI &&
        diPan == TianGan.XIN &&
        [EightDoorEnum.KAI, EightDoorEnum.XIU, EightDoorEnum.SHENG]
            .contains(door);
  }

  static bool isLoong(TianGan tianPan, TianGan diPan, EightGodsEnum god,
      EightDoorEnum door, HouTianGua gongGua) {
    return tianPan == TianGan.YI &&
        [EightDoorEnum.KAI, EightDoorEnum.XIU, EightDoorEnum.SHENG]
            .contains(door) &&
        (gongGua == HouTianGua.Kan || diPan == TianGan.GUI);
  }

  static bool isTiger(SixJia xunShou, TianGan tianPan, TianGan diPan,
      EightGodsEnum god, EightDoorEnum door, HouTianGua gongGua) {
    if (xunShou == SixJia.JIA_SHEN_GENG) {
      return xunShou.gan == tianPan &&
          gongGua == HouTianGua.Dui &&
          door == EightDoorEnum.KAI;
    }

    return tianPan == TianGan.YI &&
        diPan == TianGan.XIN &&
        gongGua == HouTianGua.Gen &&
        [EightDoorEnum.XIU, EightDoorEnum.SHENG].contains(door);
  }

  static bool isSky(
      TianGan tianPan, TianGan diPan, EightGodsEnum god, EightDoorEnum door) {
    return tianPan == TianGan.BING &&
        diPan == TianGan.DING &&
        door == EightDoorEnum.SHENG;
  }

  static bool isEarth(
      TianGan tianPan, TianGan diPan, EightGodsEnum god, EightDoorEnum door) {
    return tianPan == TianGan.YI &&
        diPan == TianGan.JI &&
        door == EightDoorEnum.KAI;
  }

  static bool isHuman(TianGan tianPan, EightGodsEnum god, EightDoorEnum door) {
    return tianPan == TianGan.YI &&
        god == EightGodsEnum.TAI_YIN &&
        door == EightDoorEnum.XIU;
  }

  static bool isGod(TianGan tianPan, EightGodsEnum god, EightDoorEnum door) {
    return tianPan == TianGan.BING &&
        god == EightGodsEnum.JIU_DI &&
        door == EightDoorEnum.SHENG;
  }

  static bool isGhost(TianGan tianPan, EightGodsEnum god, EightDoorEnum door) {
    return tianPan == TianGan.DING &&
        god == EightGodsEnum.JIU_DI &&
        [EightDoorEnum.KAI, EightDoorEnum.DU].contains(door);
  }
}
