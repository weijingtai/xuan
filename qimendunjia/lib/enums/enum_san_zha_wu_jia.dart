import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_eight_gods.dart';
import 'package:qimendunjia/model/each_gong.dart';

import '../model/each_gong_ge_ju.dart';

enum SanZhaWuJiaEnum {
  Zhen_Zha("三诈·真诈"),
  Xiu_Zha("三诈·休诈"),
  Chong_Zha("三诈·重诈"),

  Tian_Jia("五假·天假"),
  Di_Jia("五假·地假"),
  Ren_Jia("五假·人假"),
  Shen_Jia("五假·神假"),
  Gui_Jia("五假·鬼假");

  final String name;
  const SanZhaWuJiaEnum(this.name);

  static EachGongSanZhaWuJia checkSanZhaWuJiaByEachGong(EachGong gong) {
    SanZhaWuJiaEnum? tianPan =
        checkSanZhaWuJia(gong.tianPan, gong.door, gong.god);
    SanZhaWuJiaEnum? tianPanJiGan =
        checkSanZhaWuJia(gong.tianPan, gong.door, gong.god);
    return EachGongSanZhaWuJia(tianPanGan: tianPan, tianPanJiGan: tianPanJiGan);
  }

  static SanZhaWuJiaEnum? checkSanZhaWuJia(
      TianGan gan, EightDoorEnum door, EightGodsEnum god) {
    if (TianGan.REN == gan) {
      return EightDoorEnum.JING_W == door && EightGodsEnum.JIU_TIAN == god
          ? SanZhaWuJiaEnum.Ren_Jia
          : null;
    } else if ([TianGan.YI, TianGan.BING, TianGan.DING].contains(gan)) {
      if (EightDoorEnum.JING_S == door) {
        return EightGodsEnum.JIU_TIAN == god ? SanZhaWuJiaEnum.Tian_Jia : null;
      } else if ([EightDoorEnum.KAI, EightDoorEnum.XIU, EightDoorEnum.SHENG]
          .contains(door)) {
        switch (god) {
          case EightGodsEnum.TAI_YIN:
            return SanZhaWuJiaEnum.Zhen_Zha;
          case EightGodsEnum.LIU_HE:
            return SanZhaWuJiaEnum.Xiu_Zha;
          case EightGodsEnum.JIU_DI:
            return SanZhaWuJiaEnum.Chong_Zha;
          default:
            return null;
        }
      }
    } else if ([TianGan.DING, TianGan.JI, TianGan.GUI].contains(gan)) {
      if (EightDoorEnum.SHANG == door) {
        return EightGodsEnum.JIU_DI == god ? SanZhaWuJiaEnum.Shen_Jia : null;
      } else if (EightDoorEnum.SI == door) {
        return EightGodsEnum.JIU_DI == god ? SanZhaWuJiaEnum.Gui_Jia : null;
      } else if (EightDoorEnum.DU == door) {
        return [
          EightGodsEnum.TAI_YIN,
          EightGodsEnum.LIU_HE,
          EightGodsEnum.JIU_DI
        ].contains(god)
            ? SanZhaWuJiaEnum.Di_Jia
            : null;
      }
    }
    return null;
  }

  static bool isSanZha(TianGan gan, EightDoorEnum door, EightGodsEnum god) {
    return [TianGan.YI, TianGan.BING, TianGan.DING].contains(gan) &&
        [EightDoorEnum.KAI, EightDoorEnum.XIU, EightDoorEnum.SHENG]
            .contains(door) &&
        [EightGodsEnum.TAI_YIN, EightGodsEnum.LIU_HE, EightGodsEnum.JIU_DI]
            .contains(god);
  }

  static bool? isZhenZha(TianGan gan, EightDoorEnum door, EightGodsEnum god) {
    return [TianGan.YI, TianGan.BING, TianGan.DING].contains(gan) &&
        [EightDoorEnum.KAI, EightDoorEnum.XIU, EightDoorEnum.SHENG]
            .contains(door) &&
        EightGodsEnum.TAI_YIN == god;
  }

  static bool? isXiuZha(TianGan gan, EightDoorEnum door, EightGodsEnum god) {
    return [TianGan.YI, TianGan.BING, TianGan.DING].contains(gan) &&
        [EightDoorEnum.KAI, EightDoorEnum.XIU, EightDoorEnum.SHENG]
            .contains(door) &&
        EightGodsEnum.LIU_HE == god;
  }

  static bool? isChongZha(TianGan gan, EightDoorEnum door, EightGodsEnum god) {
    return [TianGan.YI, TianGan.BING, TianGan.DING].contains(gan) &&
        [EightDoorEnum.KAI, EightDoorEnum.XIU, EightDoorEnum.SHENG]
            .contains(door) &&
        EightGodsEnum.JIU_DI == god;
  }

  static bool? isTianJia(TianGan gan, EightDoorEnum door, EightGodsEnum god) {
    return [TianGan.YI, TianGan.BING, TianGan.DING].contains(gan) &&
        EightDoorEnum.JING_S == door &&
        EightGodsEnum.JIU_TIAN == god;
  }

  static bool? isDiJia(TianGan gan, EightDoorEnum door, EightGodsEnum god) {
    return [TianGan.DING, TianGan.JI, TianGan.GUI].contains(gan) &&
        EightDoorEnum.DU == door &&
        [EightGodsEnum.TAI_YIN, EightGodsEnum.LIU_HE, EightGodsEnum.JIU_DI]
            .contains(god);
  }

  static bool? isShenJia(TianGan gan, EightDoorEnum door, EightGodsEnum god) {
    return [TianGan.DING, TianGan.JI, TianGan.GUI].contains(gan) &&
        EightDoorEnum.SHANG == door &&
        EightGodsEnum.JIU_DI == god;
  }

  static bool? isGuiJia(TianGan gan, EightDoorEnum door, EightGodsEnum god) {
    return [TianGan.DING, TianGan.JI, TianGan.GUI].contains(gan) &&
        EightDoorEnum.SI == door &&
        EightGodsEnum.JIU_DI == god;
  }

  static bool? isRenJia(TianGan gan, EightDoorEnum door, EightGodsEnum god) {
    return TianGan.REN == gan &&
        EightDoorEnum.JING_W == door &&
        EightGodsEnum.JIU_TIAN == god;
  }
}
